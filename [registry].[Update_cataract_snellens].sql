/****** Object:  StoredProcedure [registry].[Update_cataract_snellens]    Script Date: 2023/07/02 19:11:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [registry].[Update_cataract_snellens]
as
begin
	DROP TABLE IF EXISTS  #tempRS1 
		select 
			distinct
			[practiceNumber] ,
			[professionalNumber],
			[snellenmCorrected],
			[snellenmUnorrected],
			[snellenmBestCorrected],
			[snellenmPinhole],
			[snellenfCorrected],
			[snellenfUncorrected],
			[snellenfBestCorrected],
			[snellenfPinhole],
			[postSnellenmCorrected],
			[postSnellenmUnorrected],
			[postSnellenmBestCorrected],
			[postSnellenmPinhole],
			[postSnellenfCorrected],
			[postSnellenfuncorrected],
			[postSnellenfBestCorrected],
			[postSnellenfPinhole],
			[logPinhole],
			[logUncorrected],
			[logCorrected],
			[logBestcorrected],
			[postLogPinhole],
			[postLogUncorrected],
			[postLogCorrected],
			[postLogBestcorrected],
			surgeryDate,
			dob
			into #tempRS1
		from 
			[staging].[Authorisations]
		
		begin  --calculate snellenmCorrected
			with 
			snellenmCorrected_cte as 
				(
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenmCorrected]) = LEN([snellenmCorrected])        THEN LEFT([snellenmCorrected], charindex('+', [snellenmCorrected]) - 1)
							when charindex('-', [snellenmCorrected]) = LEN([snellenmCorrected])        THEN LEFT([snellenmCorrected], charindex('-', [snellenmCorrected]) - 1)
							when (isnumeric([snellenmCorrected]) <> 1 and  [snellenmCorrected] like '%+%'  and  [snellenmCorrected] is not null)  then substring([snellenmCorrected],charindex('+',[snellenmCorrected])+1, len([snellenmCorrected]))
							when (isnumeric([snellenmCorrected]) <> 1 and  [snellenmCorrected] like '%-%'  and  [snellenmCorrected] is not null)  then substring([snellenmCorrected],charindex('-',[snellenmCorrected])+1, len([snellenmCorrected]))
							when (isnumeric([snellenmCorrected]) <> 1 and  [snellenmCorrected] like '%/%'  and  [snellenmCorrected] is not null)  then substring([snellenmCorrected],charindex('/',[snellenmCorrected])+1, len([snellenmCorrected]))
							else  [snellenmCorrected]
							end as 	[snellenmCorrectedPossibleValue]
				FROM #tempRS1
				where [snellenmCorrected] not in ('HM','FC','cf','-','.')
				),
			 snellenmCorrectedCalcValue_cte as
			   (
				select  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						6/Nullif(cast([snellenmCorrectedPossibleValue] AS DECIMAL(10,2)),0) as [snellenmCorrectedCalculatedVCalue] --NULLIF function returns NULL if the Denominator is zero
			
				from snellenmCorrected_cte
				where [snellenmCorrectedPossibleValue] <> '')
				
				UPDATE  cat
				SET 
					cat.[snellenmCorrected_calculatedValue]		= a.[snellenmCorrectedCalculatedVCalue]	
			
				FROM [registry].[fact_cataract] cat
				JOIN snellenmCorrectedCalcValue_cte	    a	
				ON  cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end

				---***********************************************************************************************************

		begin  --calculate snellenmUnCorrected
			 with 
			 snellenmUnorrected_cte as --calculate snellenmUnorrected
				(
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenmUnorrected]) = LEN([snellenmUnorrected])        THEN LEFT([snellenmUnorrected], charindex('+', [snellenmUnorrected]) - 1)
							when charindex('-', [snellenmUnorrected]) = LEN([snellenmUnorrected])        THEN LEFT([snellenmUnorrected], charindex('-', [snellenmUnorrected]) - 1)
							when (isnumeric([snellenmUnorrected]) <> 1 and  [snellenmUnorrected] like '%+%'  and  [snellenmUnorrected] is not null)  then substring([snellenmUnorrected],charindex('+',[snellenmUnorrected])+1, len([snellenmUnorrected]))
							when (isnumeric([snellenmUnorrected]) <> 1 and  [snellenmUnorrected] like '%-%'  and  [snellenmUnorrected] is not null)  then substring([snellenmUnorrected],charindex('-',[snellenmUnorrected])+1, len([snellenmUnorrected]))
							when (isnumeric([snellenmUnorrected]) <> 1 and  [snellenmUnorrected] like '%/%'  and  [snellenmUnorrected] is not null)  then substring([snellenmUnorrected],charindex('/',[snellenmUnorrected])+1, len([snellenmUnorrected]))
							else   [snellenmUnorrected]
							end as 	[snellenmUnorrectedPossibleValue]
				FROM #tempRS1
				where  [snellenmUnorrected] not in ('LP','L/P','HM','hm','FC','F/C','cf','-','.')
				),
			snellenmUnorrectedCalcValue_cte  as 
				(
				select  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						6/Nullif(cast([snellenmUnorrectedPossibleValue] AS DECIMAL(10,2)),0) as [snellenmUnorrectedCalculatedVCalue] 
				from snellenmUnorrected_cte
				where [snellenmUnorrectedPossibleValue] <> '')
				
				UPDATE  cat
				SET 
					cat.[snellenmUnCorrected_calculatedValue]		= a.[snellenmUnorrectedCalculatedVCalue]	
			
				FROM [registry].[fact_cataract] cat
				JOIN snellenmUnorrectedCalcValue_cte	    a	
				ON cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber 
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
						---***********************************************************************************************************

		begin
			with 
			snellenmBestCorrected_cte as --calculate snellenmBestCorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenmBestCorrected]) = LEN([snellenmBestCorrected])        THEN LEFT([snellenmBestCorrected], charindex('+', [snellenmBestCorrected]) - 1)
							when charindex('-', [snellenmBestCorrected]) = LEN([snellenmBestCorrected])        THEN LEFT([snellenmBestCorrected], charindex('-', [snellenmBestCorrected]) - 1)
							when (isnumeric([snellenmBestCorrected]) <> 1 and  [snellenmBestCorrected] like '%+%'  and  [snellenmBestCorrected] is not null)  then substring([snellenmBestCorrected],charindex('+',[snellenmBestCorrected])+1, len([snellenmBestCorrected]))
							when (isnumeric([snellenmBestCorrected]) <> 1 and  [snellenmBestCorrected] like '%-%'  and  [snellenmBestCorrected] is not null)  then substring([snellenmBestCorrected],charindex('-',[snellenmBestCorrected])+1, len([snellenmBestCorrected]))
							when (isnumeric([snellenmBestCorrected]) <> 1 and  [snellenmBestCorrected] like '%/%'  and  [snellenmBestCorrected] is not null)  then substring([snellenmBestCorrected],charindex('/',[snellenmBestCorrected])+1, len([snellenmBestCorrected]))
							when (isnumeric([snellenmBestCorrected]) <> 1 and  [snellenmBestCorrected] like '%>%'  and  [snellenmBestCorrected] is not null)  then substring([snellenmBestCorrected],charindex('>',[snellenmBestCorrected])+1, len([snellenmBestCorrected]))
							else   [snellenmBestCorrected]
							end as 	[snellenmBestCorrectedPossibleValue]
				FROM #tempRS1
				where  [snellenmBestCorrected] not in ('nlp', 'LP', 'HM' ,'FC' ,'CF', 'cf','-','.')
				),
			snellenmBestCorrectedCalcValue_cte  as 
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						6/Nullif(cast([snellenmBestCorrectedPossibleValue] AS DECIMAL(10,2)),0) as [snellenmBestCorrectedCalculatedVCalue] 
				from snellenmBestCorrected_cte
				where [snellenmBestCorrectedPossibleValue] <> '')

				UPDATE  cat
				SET 
					cat.[snellenmBestCorrected_calculatedValue]		= a.[snellenmBestCorrectedCalculatedVCalue]	
			
				FROM [registry].[fact_cataract] cat
				JOIN snellenmBestCorrectedCalcValue_cte	    a	
				ON cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber 
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
						---***********************************************************************************************************

		begin
			with 
			snellenmPinhole_cte as --calculate snellenmPinhole
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenmPinhole]) = LEN([snellenmPinhole])        THEN LEFT([snellenmPinhole], charindex('+', [snellenmPinhole]) - 1)
							when charindex('-', [snellenmPinhole]) = LEN([snellenmPinhole])        THEN LEFT([snellenmPinhole], charindex('-', [snellenmPinhole]) - 1)
							when (isnumeric([snellenmPinhole]) <> 1 and  [snellenmPinhole] like '%+%'  and  [snellenmPinhole] is not null)  then substring([snellenmPinhole],charindex('+',[snellenmPinhole])+1, len([snellenmPinhole]))
							when (isnumeric([snellenmPinhole]) <> 1 and  [snellenmPinhole] like '%-%'  and  [snellenmPinhole] is not null)  then substring([snellenmPinhole],charindex('-',[snellenmPinhole])+1, len([snellenmPinhole]))
							when (isnumeric([snellenmPinhole]) <> 1 and  [snellenmPinhole] like '%/%'  and  [snellenmPinhole] is not null)  then substring([snellenmPinhole],charindex('/',[snellenmPinhole])+1, len([snellenmPinhole]))
							when (isnumeric([snellenmPinhole]) <> 1 and  [snellenmPinhole] like '%>%'  and  [snellenmPinhole] is not null)  then substring([snellenmPinhole],charindex('>',[snellenmPinhole])+1, len([snellenmPinhole]))
							else   [snellenmPinhole]
							end as 	[snellenmPinholePossibleValue]

				FROM #tempRS1
				where  [snellenmPinhole] not in ('NA', 'LP', 'HM' , 'cf','-','.')
				),
			snellenmPinholeCalcValue_cte  as 
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						6/Nullif(cast([snellenmPinholePossibleValue] AS DECIMAL(10,2)),0) as snellenmPinholeCalcValue 
				from snellenmPinhole_cte
				where [snellenmPinholePossibleValue] <> '')	

				UPDATE  cat
				SET 
					cat.[snellenmPinhole_calculatedValue]		= a.snellenmPinholeCalcValue	
			
				FROM [registry].[fact_cataract] cat
				JOIN snellenmPinholeCalcValue_cte	    a	
				ON cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber 
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
					---***********************************************************************************************************
		begin
			with 
			snellenfCorrected_cte as --calculate snellenfCorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenfCorrected]) = LEN([snellenfCorrected])        THEN LEFT([snellenfCorrected], charindex('+', [snellenfCorrected]) - 1)
							when charindex('-', [snellenfCorrected]) = LEN([snellenfCorrected])        THEN LEFT([snellenfCorrected], charindex('-', [snellenfCorrected]) - 1)
							when (isnumeric([snellenfCorrected]) <> 1 and  [snellenfCorrected] like '%+%'  and  [snellenfCorrected] is not null)  then substring([snellenfCorrected],charindex('+',[snellenfCorrected])+1, len([snellenfCorrected]))
							when (isnumeric([snellenfCorrected]) <> 1 and  [snellenfCorrected] like '%-%'  and  [snellenfCorrected] is not null)  then substring([snellenfCorrected],charindex('-',[snellenfCorrected])+1, len([snellenfCorrected]))
							when (isnumeric([snellenfCorrected]) <> 1 and  [snellenfCorrected] like '%/%'  and  [snellenfCorrected] is not null)  then substring([snellenfCorrected],charindex('/',[snellenfCorrected])+1, len([snellenfCorrected]))
							when (isnumeric([snellenfCorrected]) <> 1 and  [snellenfCorrected] like '%>%'  and  [snellenfCorrected] is not null)  then substring([snellenfCorrected],charindex('>',[snellenfCorrected])+1, len([snellenfCorrected]))
							else   [snellenfCorrected]
							end as 	[snellenfCorrectedPossibleValue]
		

				FROM #tempRS1
				where  [snellenfCorrected] <> '.'
				),
			snellenfCorrectedCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						20/Nullif(cast([snellenfCorrectedPossibleValue] AS DECIMAL(10,2)),0) as snellenfCorrectedCalcValue 
				from snellenfCorrected_cte
				where [snellenfCorrectedPossibleValue] <> '')

				UPDATE  cat
					SET 
						cat.[snellenfCorrected_CalculatedValue]		= a.snellenfCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN snellenfCorrectedCalcValue_cte	    a	
					ON cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber 
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
						---***********************************************************************************************************
		begin
			with 
			snellenfUncorrected_cte as --calculate snellenfUncorrected
				(
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenfUncorrected]) = LEN([snellenfUncorrected])        THEN LEFT([snellenfUncorrected], charindex('+', [snellenfUncorrected]) - 1)
							when charindex('-', [snellenfUncorrected]) = LEN([snellenfUncorrected])        THEN LEFT([snellenfUncorrected], charindex('-', [snellenfUncorrected]) - 1)
							when (isnumeric([snellenfUncorrected]) <> 1 and  [snellenfUncorrected] like '%+%'  and  [snellenfUncorrected] is not null)  then substring([snellenfUncorrected],charindex('+',[snellenfUncorrected])+1, len([snellenfUncorrected]))
							when (isnumeric([snellenfUncorrected]) <> 1 and  [snellenfUncorrected] like '%-%'  and  [snellenfUncorrected] is not null)  then substring([snellenfUncorrected],charindex('-',[snellenfUncorrected])+1, len([snellenfUncorrected]))
							when (isnumeric([snellenfUncorrected]) <> 1 and  [snellenfUncorrected] like '%/%'  and  [snellenfUncorrected] is not null)  then substring([snellenfUncorrected],charindex('/',[snellenfUncorrected])+1, len([snellenfUncorrected]))
							when (isnumeric([snellenfUncorrected]) <> 1 and  [snellenfUncorrected] like '%>%'  and  [snellenfUncorrected] is not null)  then substring([snellenfUncorrected],charindex('>',[snellenfUncorrected])+1, len([snellenfUncorrected]))
							else   [snellenfUncorrected]
							end as 	[snellenfUncorrectedPossibleValue]
		

				FROM #tempRS1
				where  [snellenfUncorrected] not in ('CF', 'FC', 'HM', '-','.')
				),
			snellenfUncorrectedCalcValue_cte  as
				(
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						20/Nullif(cast([snellenfUncorrectedPossibleValue] AS DECIMAL(10,2)),0) as snellenfUncorrectedCalcValue 
				from snellenfUncorrected_cte
				where [snellenfUncorrectedPossibleValue] <> '')

				UPDATE  cat
				SET 
					cat.[snellenfUnCorrected_CalculatedValue]		= a.snellenfUncorrectedCalcValue	
			
				FROM [registry].[fact_cataract] cat
				JOIN snellenfUncorrectedCalcValue_cte	    a	
				ON cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber 
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob

		end
			---***********************************************************************************************************

		begin
			with
			snellenfBestCorrected_cte as ---calculate snellenfBestCorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenfBestCorrected]) = LEN([snellenfBestCorrected])        THEN LEFT([snellenfBestCorrected], charindex('+', [snellenfBestCorrected]) - 1)
							when charindex('-', [snellenfBestCorrected]) = LEN([snellenfBestCorrected])        THEN LEFT([snellenfBestCorrected], charindex('-', [snellenfBestCorrected]) - 1)
							when (isnumeric([snellenfBestCorrected]) <> 1 and  [snellenfBestCorrected] like '%+%'  and  [snellenfBestCorrected] is not null)  then substring([snellenfBestCorrected],charindex('+',[snellenfBestCorrected])+1, len([snellenfBestCorrected]))
							when (isnumeric([snellenfBestCorrected]) <> 1 and  [snellenfBestCorrected] like '%-%'  and  [snellenfBestCorrected] is not null)  then substring([snellenfBestCorrected],charindex('-',[snellenfBestCorrected])+1, len([snellenfBestCorrected]))
							when (isnumeric([snellenfBestCorrected]) <> 1 and  [snellenfBestCorrected] like '%/%'  and  [snellenfBestCorrected] is not null)  then substring([snellenfBestCorrected],charindex('/',[snellenfBestCorrected])+1, len([snellenfBestCorrected]))
							when (isnumeric([snellenfBestCorrected]) <> 1 and  [snellenfBestCorrected] like '%>%'  and  [snellenfBestCorrected] is not null)  then substring([snellenfBestCorrected],charindex('>',[snellenfBestCorrected])+1, len([snellenfBestCorrected]))
							else   [snellenfBestCorrected]
							end as 	[snellenfBestCorrectedPossibleValue]
		

				FROM #tempRS1
				where  [snellenfBestCorrected] not in ( '-','.')
				),
			snellenfBestCorrectedCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						20/Nullif(cast([snellenfBestCorrectedPossibleValue] AS DECIMAL(10,2)),0) as snellenfBestCorrectedCalcValue 
				from snellenfBestCorrected_cte
				where [snellenfBestCorrectedPossibleValue] <> '')

				UPDATE  cat
				SET 
					cat.[snellenfBestCorrected_CalculatedValue]		= a.snellenfBestCorrectedCalcValue	
			
				FROM [registry].[fact_cataract] cat
				JOIN snellenfBestCorrectedCalcValue_cte	    a	
				ON cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber 
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob

		end
			---***********************************************************************************************************

		begin
			with
			snellenfPinhole_cte as ---calculate snellenfPinhole
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [snellenfPinhole]) = LEN([snellenfPinhole])        THEN LEFT([snellenfPinhole], charindex('+', [snellenfPinhole]) - 1)
							when charindex('-', [snellenfPinhole]) = LEN([snellenfPinhole])        THEN LEFT([snellenfPinhole], charindex('-', [snellenfPinhole]) - 1)
							when (isnumeric([snellenfPinhole]) <> 1 and  [snellenfPinhole] like '%+%'  and  [snellenfPinhole] is not null)  then substring([snellenfPinhole],charindex('+',[snellenfPinhole])+1, len([snellenfPinhole]))
							when (isnumeric([snellenfPinhole]) <> 1 and  [snellenfPinhole] like '%-%'  and  [snellenfPinhole] is not null)  then substring([snellenfPinhole],charindex('-',[snellenfPinhole])+1, len([snellenfPinhole]))
							when (isnumeric([snellenfPinhole]) <> 1 and  [snellenfPinhole] like '%/%'  and  [snellenfPinhole] is not null)  then substring([snellenfPinhole],charindex('/',[snellenfPinhole])+1, len([snellenfPinhole]))
							when (isnumeric([snellenfPinhole]) <> 1 and  [snellenfPinhole] like '%>%'  and  [snellenfPinhole] is not null)  then substring([snellenfPinhole],charindex('>',[snellenfPinhole])+1, len([snellenfPinhole]))
							else   [snellenfPinhole]
							end as 	[snellenfPinholePossibleValue]
		

				FROM #tempRS1
				where  [snellenfPinhole] not in ( 'HM','-','.')
				),
			snellenfPinholeCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						20/Nullif(cast([snellenfPinholePossibleValue] AS DECIMAL(10,2)),0) as snellenfPinholeCalcValue 
				from snellenfPinhole_cte
				where [snellenfPinholePossibleValue] <> '')

				UPDATE  cat
				SET 
					cat.[snellenmPinhole_calculatedValue]		= a.snellenfPinholeCalcValue	
			
				FROM [registry].[fact_cataract] cat
				JOIN snellenfPinholeCalcValue_cte	    a	
				ON cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber 
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob

		end
		
			---***********************************************************************************************************
		begin
			with 
			postSnellenmCorrected_cte as ---calculate postSnellenmCorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [postSnellenmCorrected]) = LEN([postSnellenmCorrected])        THEN LEFT([postSnellenmCorrected], charindex('+', [postSnellenmCorrected]) - 1)
							when charindex('-', [postSnellenmCorrected]) = LEN([postSnellenmCorrected])        THEN LEFT([postSnellenmCorrected], charindex('-', [postSnellenmCorrected]) - 1)
							when (isnumeric([postSnellenmCorrected]) <> 1 and  [postSnellenmCorrected] like '%+%'  and  [postSnellenmCorrected] is not null)  then substring([postSnellenmCorrected],charindex('+',[postSnellenmCorrected])+1, len([postSnellenmCorrected]))
							when (isnumeric([postSnellenmCorrected]) <> 1 and  [postSnellenmCorrected] like '%-%'  and  [postSnellenmCorrected] is not null)  then substring([postSnellenmCorrected],charindex('-',[postSnellenmCorrected])+1, len([postSnellenmCorrected]))
							when (isnumeric([postSnellenmCorrected]) <> 1 and  [postSnellenmCorrected] like '%/%'  and  [postSnellenmCorrected] is not null)  then substring([postSnellenmCorrected],charindex('/',[postSnellenmCorrected])+1, len([postSnellenmCorrected]))
							when (isnumeric([postSnellenmCorrected]) <> 1 and  [postSnellenmCorrected] like '%>%'  and  [postSnellenmCorrected] is not null)  then substring([postSnellenmCorrected],charindex('>',[postSnellenmCorrected])+1, len([postSnellenmCorrected]))
							else   [postSnellenmCorrected]
							end as 	[postSnellenmCorrectedPossibleValue]

				FROM   #tempRS1
				where  [postSnellenmCorrected] not in ('-','.')
				),
			postSnellenmCorrectedCalcValue_cte  as
			   (
				select [practiceNumber] ,[professionalNumber],surgeryDate,dob,	
					   6/Nullif(cast([postSnellenmCorrectedPossibleValue] AS DECIMAL(10,2)),0) as postSnellenmCorrectedCalcValue 
				from postSnellenmCorrected_cte
				where [postSnellenmCorrectedPossibleValue] <> '')

				UPDATE  cat
					SET 
						cat.[postSnellenmCorrected_CalculatedValue]		= a.postSnellenmCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postSnellenmCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
			---***********************************************************************************************************

		begin
			with
				postSnellenmUnorrected_cte as ---calculate postSnellenmUnorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [postSnellenmUnorrected]) = LEN([postSnellenmUnorrected])        THEN LEFT([postSnellenmUnorrected], charindex('+', [postSnellenmUnorrected]) - 1)
							when charindex('-', [postSnellenmUnorrected]) = LEN([postSnellenmUnorrected])        THEN LEFT([postSnellenmUnorrected], charindex('-', [postSnellenmUnorrected]) - 1)
							when (isnumeric([postSnellenmUnorrected]) <> 1 and  [postSnellenmUnorrected] like '%+%'  and  [postSnellenmUnorrected] is not null)  then substring([postSnellenmUnorrected],charindex('+',[postSnellenmUnorrected])+1, len([postSnellenmUnorrected]))
							when (isnumeric([postSnellenmUnorrected]) <> 1 and  [postSnellenmUnorrected] like '%-%'  and  [postSnellenmUnorrected] is not null)  then substring([postSnellenmUnorrected],charindex('-',[postSnellenmUnorrected])+1, len([postSnellenmUnorrected]))
							when (isnumeric([postSnellenmUnorrected]) <> 1 and  [postSnellenmUnorrected] like '%/%'  and  [postSnellenmUnorrected] is not null)  then substring([postSnellenmUnorrected],charindex('/',[postSnellenmUnorrected])+1, len([postSnellenmUnorrected]))
							when (isnumeric([postSnellenmUnorrected]) <> 1 and  [postSnellenmUnorrected] like '%>%'  and  [postSnellenmUnorrected] is not null)  then substring([postSnellenmUnorrected],charindex('>',[postSnellenmUnorrected])+1, len([postSnellenmUnorrected]))
							else   [postSnellenmUnorrected]
							end as 	[postSnellenmUnorrectedPossibleValue]
		

				FROM   #tempRS1
				where  [postSnellenmUnorrected] not in ('-','.')
				),
			postSnellenmUnorrectedCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						6/Nullif(cast([postSnellenmUnorrectedPossibleValue] AS DECIMAL(10,2)),0) as postSnellenmUnorrectedCalcValue 
				from postSnellenmUnorrected_cte
				where [postSnellenmUnorrectedPossibleValue] <> '')

				UPDATE  cat
					SET 
						cat.[postSnellenmUnorrected_CalculatedValue]		= a.postSnellenmUnorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postSnellenmUnorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
					---***********************************************************************************************************
		begin
			with 
				postSnellenmBestCorrected_cte as ---calculate postSnellenmBestCorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [postSnellenmBestCorrected]) = LEN([postSnellenmBestCorrected])        THEN LEFT([postSnellenmBestCorrected], charindex('+', [postSnellenmBestCorrected]) - 1)
							when charindex('-', [postSnellenmBestCorrected]) = LEN([postSnellenmBestCorrected])        THEN LEFT([postSnellenmBestCorrected], charindex('-', [postSnellenmBestCorrected]) - 1)
							when (isnumeric([postSnellenmBestCorrected]) <> 1 and  [postSnellenmBestCorrected] like '%+%'  and  [postSnellenmBestCorrected] is not null)  then substring([postSnellenmBestCorrected],charindex('+',[postSnellenmBestCorrected])+1, len([postSnellenmBestCorrected]))
							when (isnumeric([postSnellenmBestCorrected]) <> 1 and  [postSnellenmBestCorrected] like '%-%'  and  [postSnellenmBestCorrected] is not null)  then substring([postSnellenmBestCorrected],charindex('-',[postSnellenmBestCorrected])+1, len([postSnellenmBestCorrected]))
							when (isnumeric([postSnellenmBestCorrected]) <> 1 and  [postSnellenmBestCorrected] like '%/%'  and  [postSnellenmBestCorrected] is not null)  then substring([postSnellenmBestCorrected],charindex('/',[postSnellenmBestCorrected])+1, len([postSnellenmBestCorrected]))
							when (isnumeric([postSnellenmBestCorrected]) <> 1 and  [postSnellenmBestCorrected] like '%>%'  and  [postSnellenmBestCorrected] is not null)  then substring([postSnellenmBestCorrected],charindex('>',[postSnellenmBestCorrected])+1, len([postSnellenmBestCorrected]))
							else   [postSnellenmBestCorrected]
							end as 	[postSnellenmBestCorrectedPossibleValue]
		

				FROM #tempRS1
				where  [postSnellenmBestCorrected] not in ('CF','-','.')
				),
			postSnellenmBestCorrectedCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						6/Nullif(cast([postSnellenmBestCorrectedPossibleValue] AS DECIMAL(10,2)),0) as postSnellenmBestCorrectedCalcValue 
				from postSnellenmBestCorrected_cte
				where [postSnellenmBestCorrectedPossibleValue] <> '')

				UPDATE  cat
					SET 
						cat.[postSnellenmBestCorrected_CalculatedValue]		= a.postSnellenmBestCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postSnellenmBestCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
							---***********************************************************************************************************

 		begin
			with 
			postSnellenmPinhole_cte as ---calculate postSnellenmPinhole
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [postSnellenmPinhole]) = LEN([postSnellenmPinhole])        THEN LEFT([postSnellenmPinhole], charindex('+', [postSnellenmPinhole]) - 1)
							when charindex('-', [postSnellenmPinhole]) = LEN([postSnellenmPinhole])        THEN LEFT([postSnellenmPinhole], charindex('-', [postSnellenmPinhole]) - 1)
							when (isnumeric([postSnellenmPinhole]) <> 1 and  [postSnellenmPinhole] like '%+%'  and  [postSnellenmPinhole] is not null)  then substring([postSnellenmPinhole],charindex('+',[postSnellenmPinhole])+1, len([postSnellenmPinhole]))
							when (isnumeric([postSnellenmPinhole]) <> 1 and  [postSnellenmPinhole] like '%-%'  and  [postSnellenmPinhole] is not null)  then substring([postSnellenmPinhole],charindex('-',[postSnellenmPinhole])+1, len([postSnellenmPinhole]))
							when (isnumeric([postSnellenmPinhole]) <> 1 and  [postSnellenmPinhole] like '%/%'  and  [postSnellenmPinhole] is not null)  then substring([postSnellenmPinhole],charindex('/',[postSnellenmPinhole])+1, len([postSnellenmPinhole]))
							when (isnumeric([postSnellenmPinhole]) <> 1 and  [postSnellenmPinhole] like '%>%'  and  [postSnellenmPinhole] is not null)  then substring([postSnellenmPinhole],charindex('>',[postSnellenmPinhole])+1, len([postSnellenmPinhole]))
							else   [postSnellenmPinhole]
							end as 	[postSnellenmPinholePossibleValue]
		

				FROM #tempRS1
				where  [postSnellenmPinhole] not in ('-','.')
				),
			postSnellenmPinholeCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						6/Nullif(cast([postSnellenmPinholePossibleValue] AS DECIMAL(10,2)),0) as postSnellenmPinholeCalcValue 
				from postSnellenmPinhole_cte
				where [postSnellenmPinholePossibleValue] <> '')

			
				UPDATE  cat
					SET 
						cat.[postSnellenmPinhole_CalculatedValue]		= a.postSnellenmPinholeCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postSnellenmPinholeCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
							---***********************************************************************************************************
		begin
			with 
			postSnellenfCorrected_cte as ---calculate postSnellenfCorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [postSnellenfCorrected]) = LEN([postSnellenfCorrected])        THEN LEFT([postSnellenfCorrected], charindex('+', [postSnellenfCorrected]) - 1)
							when charindex('-', [postSnellenfCorrected]) = LEN([postSnellenfCorrected])        THEN LEFT([postSnellenfCorrected], charindex('-', [postSnellenfCorrected]) - 1)
							when (isnumeric([postSnellenfCorrected]) <> 1 and  [postSnellenfCorrected] like '%+%'  and  [postSnellenfCorrected] is not null)  then substring([postSnellenfCorrected],charindex('+',[postSnellenfCorrected])+1, len([postSnellenfCorrected]))
							when (isnumeric([postSnellenfCorrected]) <> 1 and  [postSnellenfCorrected] like '%-%'  and  [postSnellenfCorrected] is not null)  then substring([postSnellenfCorrected],charindex('-',[postSnellenfCorrected])+1, len([postSnellenfCorrected]))
							when (isnumeric([postSnellenfCorrected]) <> 1 and  [postSnellenfCorrected] like '%/%'  and  [postSnellenfCorrected] is not null)  then substring([postSnellenfCorrected],charindex('/',[postSnellenfCorrected])+1, len([postSnellenfCorrected]))
							when (isnumeric([postSnellenfCorrected]) <> 1 and  [postSnellenfCorrected] like '%>%'  and  [postSnellenfCorrected] is not null)  then substring([postSnellenfCorrected],charindex('>',[postSnellenfCorrected])+1, len([postSnellenfCorrected]))
							else   [postSnellenfCorrected]
							end as 	[postSnellenfCorrectedPossibleValue]
		

				FROM #tempRS1
				where  [postSnellenfCorrected] not in ('-','.')
				),
			postSnellenfCorrectedCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						20/Nullif(cast([postSnellenfCorrectedPossibleValue] AS DECIMAL(10,2)),0) as postSnellenfCorrectedCalcValue 
				from postSnellenfCorrected_cte
				where [postSnellenfCorrectedPossibleValue] <> '')

			
				UPDATE  cat
					SET 
						cat.[postSnellenfCorrected_CalculatedValue]		= a.postSnellenfCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postSnellenfCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
							---***********************************************************************************************************

		begin
			with postSnellenfuncorrected_cte as ---calculate postSnellenfuncorrected
		   (
			SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
					case
						when charindex('+', [postSnellenfuncorrected]) = LEN([postSnellenfuncorrected])        THEN LEFT([postSnellenfuncorrected], charindex('+', [postSnellenfuncorrected]) - 1)
						when charindex('-', [postSnellenfuncorrected]) = LEN([postSnellenfuncorrected])        THEN LEFT([postSnellenfuncorrected], charindex('-', [postSnellenfuncorrected]) - 1)
						when (isnumeric([postSnellenfuncorrected]) <> 1 and  [postSnellenfuncorrected] like '%+%'  and  [postSnellenfuncorrected] is not null)  then substring([postSnellenfuncorrected],charindex('+',[postSnellenfuncorrected])+1, len([postSnellenfuncorrected]))
						when (isnumeric([postSnellenfuncorrected]) <> 1 and  [postSnellenfuncorrected] like '%-%'  and  [postSnellenfuncorrected] is not null)  then substring([postSnellenfuncorrected],charindex('-',[postSnellenfuncorrected])+1, len([postSnellenfuncorrected]))
						when (isnumeric([postSnellenfuncorrected]) <> 1 and  [postSnellenfuncorrected] like '%/%'  and  [postSnellenfuncorrected] is not null)  then substring([postSnellenfuncorrected],charindex('/',[postSnellenfuncorrected])+1, len([postSnellenfuncorrected]))
						when (isnumeric([postSnellenfuncorrected]) <> 1 and  [postSnellenfuncorrected] like '%>%'  and  [postSnellenfuncorrected] is not null)  then substring([postSnellenfuncorrected],charindex('>',[postSnellenfuncorrected])+1, len([postSnellenfuncorrected]))
						else   [postSnellenfuncorrected]
						end as 	[postSnellenfuncorrectedPossibleValue]
		

			FROM #tempRS1
			where  [postSnellenfuncorrected] not in ('-','.')
			),
		postSnellenfuncorrectedCalcValue_cte  as
		   (
			select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					20/Nullif(cast([postSnellenfuncorrectedPossibleValue] AS DECIMAL(10,2)),0) as postSnellenfuncorrectedCalcValue 
			from postSnellenfuncorrected_cte
			where [postSnellenfuncorrectedPossibleValue] <> '')

			
			UPDATE  cat
				SET 
					cat.[postSnellenfUncorrected_CalculatedValue]	= a.postSnellenfuncorrectedCalcValue	
			
				FROM [registry].[fact_cataract] cat
				JOIN postSnellenfuncorrectedCalcValue_cte	    a	
				ON  cat.practiceNumber  = a.practiceNumber   
				and cat.professionalNumber    = a.professionalNumber
				and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
			---***********************************************************************************************************

        begin
			with 
			postSnellenfBestCorrected_cte as ---calculate postSnellenfBestCorrected
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [postSnellenfBestCorrected]) = LEN([postSnellenfBestCorrected])        THEN LEFT([postSnellenfBestCorrected], charindex('+', [postSnellenfBestCorrected]) - 1)
							when charindex('-', [postSnellenfBestCorrected]) = LEN([postSnellenfBestCorrected])        THEN LEFT([postSnellenfBestCorrected], charindex('-', [postSnellenfBestCorrected]) - 1)
							when (isnumeric([postSnellenfBestCorrected]) <> 1 and  [postSnellenfBestCorrected] like '%+%'  and  [postSnellenfBestCorrected] is not null)  then substring([postSnellenfBestCorrected],charindex('+',[postSnellenfBestCorrected])+1, len([postSnellenfBestCorrected]))
							when (isnumeric([postSnellenfBestCorrected]) <> 1 and  [postSnellenfBestCorrected] like '%-%'  and  [postSnellenfBestCorrected] is not null)  then substring([postSnellenfBestCorrected],charindex('-',[postSnellenfBestCorrected])+1, len([postSnellenfBestCorrected]))
							when (isnumeric([postSnellenfBestCorrected]) <> 1 and  [postSnellenfBestCorrected] like '%/%'  and  [postSnellenfBestCorrected] is not null)  then substring([postSnellenfBestCorrected],charindex('/',[postSnellenfBestCorrected])+1, len([postSnellenfBestCorrected]))
							when (isnumeric([postSnellenfBestCorrected]) <> 1 and  [postSnellenfBestCorrected] like '%>%'  and  [postSnellenfBestCorrected] is not null)  then substring([postSnellenfBestCorrected],charindex('>',[postSnellenfBestCorrected])+1, len([postSnellenfBestCorrected]))
							else   [postSnellenfBestCorrected]
							end as 	[postSnellenfBestCorrectedPossibleValue]
		

				FROM #tempRS1
				where  [postSnellenfBestCorrected] not in ('-','.')
				),
			postSnellenfBestCorrectedCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						20/Nullif(cast([postSnellenfBestCorrectedPossibleValue] AS DECIMAL(10,2)),0) as postSnellenfBestCorrectedCalcValue 
				from postSnellenfBestCorrected_cte
				where [postSnellenfBestCorrectedPossibleValue] <> '')

			
				UPDATE  cat
					SET 
						cat.[postSnellenfBestCorrected_CalculatedValue]		= a.postSnellenfBestCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postSnellenfBestCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
			---***********************************************************************************************************
		begin
			with 
				postSnellenfPinhole_cte as ---calculate postSnellenfPinhole
			   (
				SELECT  [practiceNumber] ,[professionalNumber],surgeryDate,dob,
						case
							when charindex('+', [postSnellenfPinhole]) = LEN([postSnellenfPinhole])        THEN LEFT([postSnellenfPinhole], charindex('+', [postSnellenfPinhole]) - 1)
							when charindex('-', [postSnellenfPinhole]) = LEN([postSnellenfPinhole])        THEN LEFT([postSnellenfPinhole], charindex('-', [postSnellenfPinhole]) - 1)
							when (isnumeric([postSnellenfPinhole]) <> 1 and  [postSnellenfPinhole] like '%+%'  and  [postSnellenfPinhole] is not null)  then substring([postSnellenfPinhole],charindex('+',[postSnellenfPinhole])+1, len([postSnellenfPinhole]))
							when (isnumeric([postSnellenfPinhole]) <> 1 and  [postSnellenfPinhole] like '%-%'  and  [postSnellenfPinhole] is not null)  then substring([postSnellenfPinhole],charindex('-',[postSnellenfPinhole])+1, len([postSnellenfPinhole]))
							when (isnumeric([postSnellenfPinhole]) <> 1 and  [postSnellenfPinhole] like '%/%'  and  [postSnellenfPinhole] is not null)  then substring([postSnellenfPinhole],charindex('/',[postSnellenfPinhole])+1, len([postSnellenfPinhole]))
							when (isnumeric([postSnellenfPinhole]) <> 1 and  [postSnellenfPinhole] like '%>%'  and  [postSnellenfPinhole] is not null)  then substring([postSnellenfPinhole],charindex('>',[postSnellenfPinhole])+1, len([postSnellenfPinhole]))
							else   [postSnellenfPinhole]
							end as 	[postSnellenfPinholePossibleValue]
		

				FROM #tempRS1
				where  [postSnellenfPinhole] not in ('-','.')
				),
			postSnellenfPinholeCalcValue_cte  as
			   (
				select 	[practiceNumber] ,[professionalNumber],surgeryDate,dob,
						20/Nullif(cast([postSnellenfPinholePossibleValue] AS DECIMAL(10,2)),0) as postSnellenfPinholeCalcValue 
				from postSnellenfPinhole_cte
				where [postSnellenfPinholePossibleValue] <> '')

			
				UPDATE  cat
					SET 
						cat.[postSnellenfPinhole_CalculatedValue]		= a.postSnellenfPinholeCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postSnellenfPinholeCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end

			---***********************************************************************************************************
			
		begin
			with logPinholeCalcValue_cte  as  ---calculate logPinhole
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([logPinhole] as float))  as logPinholeCalcValue 
			from #tempRS1
			where [logPinhole] <> '')
			
				UPDATE  cat
					SET 
						cat.[logPinhole_CalculatedValue]		= a.logPinholeCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN logPinholeCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
		---***********************************************************************************************************
			
		begin
			with logUncorrectedCalcValue_cte  as  ---calculate logUncorrected
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([logUncorrected] as float)) as logUncorrectedCalcValue 
			from #tempRS1
			where [logUncorrected] <> '')
			
				UPDATE  cat
					SET 
						cat.[logUnCorrected_CalculatedValue]		= a.logUncorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN logUncorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
		---***********************************************************************************************************
			
		begin
			with logCorrectedCalcValue_cte  as  ---calculate logCorrected
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([logCorrected] as float))  as logCorrectedCalcValue 
					
			from #tempRS1
			where [logCorrected] <> '')
			
				UPDATE  cat
					SET 
						cat.[logCorrected_CalculatedValue]		= a.logCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN logCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
			---***********************************************************************************************************
			
		begin
			with logBestCorrectedCalcValue_cte  as  ---calculate logBestcorrected
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([logBestcorrected] as float))  as logBestCorrectedCalcValue 
			from #tempRS1
			where [logBestcorrected] <> '')
			
				UPDATE  cat
					SET 
						cat.[logBestCorrected_CalculatedValue]		= a.logBestCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN logBestCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end



		---***********************************************************************************************************
			
		begin
			with postlogPinholeCalcValue_cte  as  ---calculate postLogPinhole
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([postLogPinhole] as float))  as postlogPinholeCalcValue 
			from #tempRS1
			where [postLogPinhole] <> '')
			
				UPDATE  cat
					SET 
						cat.[postlogPinhole_CalculatedValue]		= a.postlogPinholeCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postlogPinholeCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
		---***********************************************************************************************************
			
		begin
			with postlogUncorrectedCalcValue_cte  as  ---calculate postlogUncorrected
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([postLogUncorrected] as float))  as postlogUncorrectedCalcValue 
			from #tempRS1
			where [postLogUncorrected] <> '')
			
				UPDATE  cat
					SET 
						cat.[postlogUnCorrected_CalculatedValue]		= a.postlogUncorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postlogUncorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
		---***********************************************************************************************************
			
		begin
			with postlogCorrectedCalcValue_cte  as  ---calculate postlogCorrected
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([postLogCorrected] as float))   as postlogCorrectedCalcValue 
			from #tempRS1
			where [postLogCorrected] <> '')
			
				UPDATE  cat
					SET 
						cat.[postlogCorrected_CalculatedValue]		= a.postlogCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postlogCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
			---***********************************************************************************************************
			
		begin
			with postlogBestCorrectedCalcValue_cte  as  ---calculate logBestcorrected
		   (
			select 	
					[practiceNumber] ,[professionalNumber],surgeryDate,dob,
					EXP(LOG(10) * -cast([postLogBestcorrected] as float))  as postlogBestCorrectedCalcValue 
			from #tempRS1
			where [postLogBestcorrected] <> '')
			
				UPDATE  cat
					SET 
						cat.[postlogBestCorrected_CalculatedValue]		= a.postlogBestCorrectedCalcValue	
			
					FROM [registry].[fact_cataract] cat
					JOIN postlogBestCorrectedCalcValue_cte	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob
		end
end

 