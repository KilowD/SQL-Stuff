/****** Object:  StoredProcedure [mediswitch].[Load_fact_episode_anonymized]    Script Date: 2023/06/30 15:26:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [mediswitch].[Load_fact_episode_anonymized] 
AS
BEGIN

	Begin

		;with episode_cte 
		as (
			select
				concat([PRACTICENO], cast([UNIQUEPATIENTID] as bigint), [DATEOFSERVICE], [MEDICALAID], [MEDICALAIDOPTIONNAME]) as episode_id,
				PATIENT_ID = concat(cast((convert(bigint,UNIQUEPATIENTID)) as varchar) ,cast([MEDICALAID] as varchar), cast( [AgeDecadeAtDateOfService] as varchar) ,cast([PATIENTGENDER] as varchar) ),
				*,
				ROW_NUMBER() OVER(PARTITION BY [PRACTICENO], [UNIQUEPATIENTID], [DATEOFSERVICE],[MEDICALAIDOPTIONNAME]
							 ORDER BY [DATEOFSUBMISSION] desc) as ranked
			from
				[staging].[mediswitch-anonymized_OMG 202206 - 202305_OMG 202105 - 202205]
			),
	
			icd_cte 
			as (
				select
					episode_id,
					value,
					min(ordinal) as str_rank
				from
					episode_cte
				cross apply
					string_split(episode_cte.[DIAGNOSISVALUES], ',', enable_ordinal=1)
				group by
					episode_id, value
			),

			final_cte as(

			select
					a.episode_id,
					a.PATIENT_ID,
					a.[PRACTICENO],
					a.[DATEOFSERVICE],
					max([INHOSPITAL]) as in_hospital,
					a.[UNIQUEPATIENTID],
					a.[BILLINGPRACTICENAME],
					cast((convert(bigint,a.[PATIENTIDNUM])) AS varchar(20)) AS [PATIENTIDNUM],
					b.[PATIENT_DEPENDANT_CODE],
					a.[MEMBER_POSTAL_CODE] ,
					a.[MEDICALAID],
					a.[MEDICALAIDOPTIONNAME],
					a.[AgeDecadeAtDateOfService],
					b.[PATIENTGENDER],
					case when charindex(',', d.icd_code_string) > 0
						then substring(d.icd_code_string, 1, charindex(',', d.icd_code_string) - 1)
						else d.icd_code_string
						end as primary_icd,
					d.icd_code_string,
					e.charge_code_string,
					a.[DIAGNOSISVALUES],
					e.in_hospital_2,
					sum(isnull(a.[CLAIMEDAMT], 0)) as claimed_amount,
					sum(isnull(a.[MEDICALAIDPAYABLEAMT], 0)) as medicalaid_payable_amount
			from
				episode_cte a,
				(
					select
						episode_id,
						[PATIENT_DEPENDANT_CODE],
						[PATIENTGENDER]
					from
						episode_cte
					where
						ranked = 1
				) b,
				(
					select
						episode_id,
						string_agg(value, ',') within group (order by str_rank) as icd_code_string
					from
						icd_cte
					group by
						episode_id
				) d,
				(
					select
						episode_id,
						string_agg([CHARGECODE], ',') as charge_code_string,
						min(case when [CHARGECODE] in ('3009', '0190', '0191', '0192', '0193', '0004')
							then 0 else 1 end) as in_hospital_2
					from
						episode_cte
					where
						[CHARGECODETYPE] = 'NHRPL'
					group by
						episode_id
				) e
			where
				a.episode_id = b.episode_id
				and a.episode_id = d.episode_id
				and a.episode_id = e.episode_id
			group by
				a.episode_id,
				a.PATIENT_ID,
				a.[PATIENTIDNUM],
				a.[PRACTICENO],
				a.[DATEOFSERVICE],
				a.[UNIQUEPATIENTID],
				a.[BILLINGPRACTICENAME],
				b.[PATIENT_DEPENDANT_CODE],
				a.[MEMBER_POSTAL_CODE],
				a.[MEDICALAID],
				a.[MEDICALAIDOPTIONNAME],
				a.[AgeDecadeAtDateOfService],
				b.[PATIENTGENDER],
				d.icd_code_string,
				e.charge_code_string,
				a.[DIAGNOSISVALUES],
				e.in_hospital_2
			)


		---*** do delta loads ONLY
		MERGE into [mediswitch].[fact_episode]AS target
		USING final_cte AS SOURCE
		ON 
			source.[Episode_id] = target.[Episode_id]

		--insert deltas only
		WHEN NOT matched by target THEN
		INSERT ([Episode_id],
				[patient_id],
				[practice_no] ,
				[unique_patient_id] ,		
				[billing_practice_name] ,
				[inhospital] ,
				[inhospital_indicator],
				[patient_id_num] ,
				[patient_dependent_code] ,
				[member_postal_code] ,
				[medicalaid_option_name] ,
				[date_of_service] ,
				[scheme_name] ,
				[age_decade_at_service_date] ,
				[gender] ,
				[claimed_amount] ,
				[scheme_payable_amount],
				[tariff_code_string] ,
				[diagnosis_values]

				)
		VALUES(
				convert(varchar(max),source.[Episode_id]) ,
				convert(varchar(max),source.[PATIENT_ID]) ,
				source.[PRACTICENO] ,
				source.UNIQUEPATIENTID ,
				source.[BILLINGPRACTICENAME] ,
				source.in_hospital ,
				source.in_hospital_2,
				source.[PATIENTIDNUM] ,
				source.[PATIENT_DEPENDANT_CODE] ,
				source.[MEMBER_POSTAL_CODE] ,
				source.[MEDICALAIDOPTIONNAME] ,
				source.[DATEOFSERVICE] ,
				source.[MEDICALAID] ,
				source.[AgeDecadeAtDateOfService] ,
				source.[PATIENTGENDER] ,
				source.[Claimed_Amount] ,
				source.medicalaid_payable_amount ,
				source.charge_code_string ,
				source.[DIAGNOSISVALUES]
				);
	end

	begin
		
			---Prepare table variable to split ICD10s using a function called fn_split
			DECLARE @t TABLE (items varchar(MAX), episode_id varchar(max) )

			INSERT INTO @t
			SELECT  distinct 
					DIAGNOSISVALUES,
					concat([PRACTICENO], cast([UNIQUEPATIENTID] as bigint), [DATEOFSERVICE], [MEDICALAID], [MEDICALAIDOPTIONNAME]) 
			FROM [staging].[mediswitch-anonymized_OMG 202206 - 202305_OMG 202105 - 202205]

			DROP TABLE IF EXISTS  #tempp
			SELECT 
				aa.episode_id, 
				icd10.ICD_1,
				icd10.ICD_2,
				icd10.ICD_3,
				icd10.ICD_4,
				icd10.ICD_5,
				icd10.ICD_6,
				icd10.ICD_7,
				icd10.ICD_8,
				icd10.ICD_9
		   into #tempp	
		   FROM [mediswitch].[fact_episode]aa 
   
		   --***call function to split DIAGNOSISVALUES into ICD10s
		   CROSS apply
		   (
			SELECT 
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (1)) AS ICD_1,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (2)) AS ICD_2,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (3)) AS ICD_3,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (4)) AS ICD_4,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (5)) AS ICD_5,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (6)) AS ICD_6,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (7)) AS ICD_7,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (8)) AS ICD_8,
				(SELECT item   FROM fn_split(items, '/') a    WHERE idx in (9)) AS ICD_9,
				 episode_id
			  FROM @t) icd10
			  WHERE aa.episode_id= icd10.episode_id

			  Update ss
			  set 
					  ss.ICD_1 = cc.ICD_1,
					  ss.ICD_2 = cc.ICD_2,
					  ss.ICD_3 = cc.ICD_3,
					  ss.ICD_4 = cc.ICD_4,
					  ss.ICD_5 = cc.ICD_5,
					  ss.ICD_6 = cc.ICD_6,
					  ss.ICD_7 = cc.ICD_7,
					  ss.ICD_8 = cc.ICD_8,
					  ss.ICD_9 = cc.ICD_9



			  from #tempp cc
			  inner join [mediswitch].[fact_episode] ss
			  on cc.episode_id=ss.episode_id

	end

END
