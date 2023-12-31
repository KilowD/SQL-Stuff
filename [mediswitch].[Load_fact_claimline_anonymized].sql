/****** Object:  StoredProcedure [mediswitch].[Load_fact_claimline_anonymized]    Script Date: 2023/06/30 14:24:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [mediswitch].[Load_fact_claimline_anonymized]
as
begin
	begin
		---Run this proc after loading the tarrif Codes table

		DROP TABLE IF EXISTS  #tempRS1 	

		;with altron_cte as (
			select
				episode_id = concat([PRACTICENO], cast([UNIQUEPATIENTID] as bigint), [DATEOFSERVICE], [MEDICALAID], [MEDICALAIDOPTIONNAME]) ,
				*,
				case when len([NAPPICODE]) = 9
					then concat('0', [NAPPICODE]) else [NAPPICODE]
					end as nappi_code
			from
				[staging].[mediswitch-anonymized_OMG 202206 - 202305_OMG 202105 - 202205]
			),

			nappi_cte as (
				select
					nappi_code,
					max(product_type) as product_type
				from
					[mediswitch].[dim_nappi_product]
				group by
					nappi_code
			)

			select
					a.episode_id,
					a.[PRACTICENO],
					a.[TREATINGPRACTICENO],
					a.[TREATINGPRACTICENAME],
					a.[DATEOFSERVICE],
					a.[INHOSPITAL],
					a.[DATEOFSUBMISSION],
					a.[CHARGECODE],
					a.[CHARGECODETYPE],
					a.[CHARGECODEDESCIPTION],
					a.nappi_code,
					case
						when b.product_type = 'S' then 'Surgical'
						when b.product_type = 'E' then 'Ethical'
						when a.[CHARGECODE] = '0201' and b.product_type is null then 'NAPPI (unclassified)'
						else 'Tariff' end as line_classification,
					a.[QUANTITY],
					a.[CLAIMEDAMT] as [Claimed_Amount],
					a.[MEDICALAIDPAYABLEAMT] as [Scheme_Payable_Amount]

				into #tempRS1
				from
					altron_cte a
				left join
					nappi_cte b
				on
					a.nappi_code = b.nappi_code

		  --Insert only Deltas
			IF NOT EXISTS (SELECT 1 
						   FROM 
								[mediswitch].[fact_claimline] claims
						   INNER JOIN
								#tempRS1 tempp
							ON	
								claims.episode_id= tempp.episode_id  )
			BEGIN
				INSERT INTO  [mediswitch].[fact_claimline] 
				(
					[episode_id],
					[practice_no] ,
					[treating_practice_no] ,
					[treating_practice_name] ,
					[date_of_service] ,
					[inhospital] ,
					[date_of_submission],
					[tarrif_code] ,
					[charge_code_type],
					[charge_code_description],
					[nappi_node],
					[line_classification] ,
					[quantity],
					[claimed_amount],
					[scheme_payable_amount]
				)
				SELECT 
					 [episode_id],
					 [PRACTICENO],
					 [TREATINGPRACTICENO],
					 [TREATINGPRACTICENAME],
					 [DATEOFSERVICE],
					 [INHOSPITAL],
					 [DATEOFSUBMISSION],
					 [CHARGECODE],
					 [CHARGECODETYPE],
					 [CHARGECODEDESCIPTION],
					 nappi_code,
					 line_classification,
					 [QUANTITY],
					 [Claimed_Amount],
					 [Scheme_Payable_Amount]
			  
				FROM #tempRS1
			PRINT 'New fact ClaimLines Data Inserted'
			END
		ELSE
			PRINT 'No new records extracted'
	end

	begin
		update a
		set 
			a.tarrif_key = b.tarrif_key

			from [mediswitch].[fact_claimline] a
			join  [mediswitch].[dim_tariff_code] b
			on a.[tarrif_code]= b.[Tariff_Code]
	end

		begin -- make sure you have a four digit tarrif_code 

			update b
				set tarrif_code= dd.tarrif_code

				from (
				select
					[episode_id],
					case when ISNUMERIC([tarrif_code])=1  then format(cast([tarrif_code] as int),'0000')
					else  [tarrif_code] end as tarrif_code
				 from [mediswitch].[fact_claimline] 
				 where tarrif_code <> '.') dd
				 join [mediswitch].[fact_claimline]  b
				 on dd.[episode_id] = b.[episode_id]

		end

		begin  ---put a leading zero if it comes as .75 for example
		update a
			set
			  quantity = bb.Modifiedquantity
			  from (
			select
			episode_id,
			CASE
					WHEN quantity LIKE '.%' THEN CONCAT('0', quantity)
					ELSE quantity
				END AS Modifiedquantity
				from [mediswitch].[fact_claimline_de-anonymized]
			where quantity like '%.%') bb
			join [mediswitch].[fact_claimline_de-anonymized] a
			on a.episode_id=bb.episode_id
	end

end


