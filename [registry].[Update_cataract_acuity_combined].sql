/****** Object:  StoredProcedure [registry].[Update_cataract_acuity_combined]    Script Date: 2023/07/02 19:02:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [registry].[Update_cataract_acuity_combined]
as
begin
		
	   with acuity_cte_1 
	   as (
       select
            [practiceNumber] ,[professionalNumber],surgeryDate,dob,
            case
                when [visualAcuityUncorrected] > 0 and [visualAcuityUncorrected] <= 2    then [visualAcuityUncorrected]
                when [snellenmUnCorrected_calculatedValue] > 0 and [snellenmUnCorrected_calculatedValue] <= 2  then [snellenmUnCorrected_calculatedValue]
                when [snellenfUnCorrected_CalculatedValue] > 0 and [snellenfUnCorrected_CalculatedValue] <= 2  then [snellenfUnCorrected_CalculatedValue]
                when [logUncorrected_calculatedValue] > 0 and [logUncorrected_calculatedValue] <= 2		then [logUncorrected_calculatedValue]
                else null end as pre_visual_acuity_uncorrected_combined,
            case
                when [postVisualAcuityUncorrected] > 0 and [postVisualAcuityUncorrected] <= 2 then [postVisualAcuityUncorrected]
                when [postSnellenmUnorrected_CalculatedValue] > 0 and [postSnellenmUnorrected_CalculatedValue] <= 2 then [postSnellenmUnorrected_CalculatedValue]
                when [postSnellenfUncorrected_CalculatedValue] > 0 and [postSnellenfUncorrected_CalculatedValue] <= 2  then [postSnellenfUncorrected_CalculatedValue]
                when [postLogUncorrected_calculatedValue] > 0 and [postLogUncorrected_calculatedValue] <= 2 then [postLogUncorrected_calculatedValue]
                else null end as post_visual_acuity_uncorrected_combined,

            case
                when [visualAcuityCorrected] > 0 and [visualAcuityCorrected] <= 2   then [visualAcuityCorrected]
                when [snellenmCorrected_calculatedValue] > 0 and [snellenmCorrected_calculatedValue] <= 2  then [snellenmCorrected_calculatedValue]
                when [snellenfCorrected_CalculatedValue] > 0 and [snellenfCorrected_CalculatedValue] <= 2  then [snellenfCorrected_CalculatedValue]
                when [logCorrected_calculatedValue] > 0 and [logCorrected_calculatedValue] <= 2  then [logCorrected_calculatedValue]
                else null end as pre_visual_acuity_corrected_combined,
            case
                when [postVisualAcuityCorrected] > 0 and [postVisualAcuityCorrected] <= 2 then [postVisualAcuityCorrected]
                when [postSnellenmCorrected_CalculatedValue] > 0 and [postSnellenmCorrected_CalculatedValue] <= 2  then [postSnellenmCorrected_CalculatedValue]
                when [postSnellenfCorrected_CalculatedValue] > 0 and [postSnellenfCorrected_CalculatedValue] <=2 then [postSnellenfCorrected_CalculatedValue]
                when [postLogCorrected_calculatedValue] > 0 and [postLogCorrected_calculatedValue] <= 2 then [postLogCorrected_calculatedValue]
                else null end as post_visual_acuity_corrected_combined,

            case
                when [visualAcuityBestcorrected] > 0 and [visualAcuityBestcorrected] <= 2 then [visualAcuityBestcorrected]
                when [snellenmBestCorrected_calculatedValue] > 0 and [snellenmBestCorrected_calculatedValue] <= 2 then [snellenmBestCorrected_calculatedValue]
                when [snellenfBestCorrected_CalculatedValue] > 0 and [snellenfBestCorrected_CalculatedValue] <= 2 then [snellenfBestCorrected_CalculatedValue]
                when [logBestcorrected_calculatedValue] > 0 and [logBestcorrected_calculatedValue] <= 2 then [logBestcorrected_calculatedValue]
                else null end as pre_visual_acuity_best_corrected_combined,
            case
                when [postVisualAcuityBestcorrected] > 0 and [postVisualAcuityBestcorrected] <= 2  then [postVisualAcuityBestcorrected]
                when [postSnellenmBestCorrected_CalculatedValue] > 0 and [postSnellenmBestCorrected_CalculatedValue] <= 2 then [postSnellenmBestCorrected_CalculatedValue]
                when [postSnellenfBestCorrected_CalculatedValue] > 0 and [postSnellenfBestCorrected_CalculatedValue] <= 2 then [postSnellenfBestCorrected_CalculatedValue]
                when [postLogBestcorrected_calculatedValue] > 0 and [postLogBestcorrected_calculatedValue] <= 2 then [postLogBestcorrected_calculatedValue]
                else null end as post_visual_acuity_best_corrected_combined
    from
            [registry].[fact_cataract]  ),
			acuity_cte_2 as (
                select
                    *,
                    post_visual_acuity_uncorrected_combined - pre_visual_acuity_uncorrected_combined as visual_acuity_uncorrected_improvement,
                    post_visual_acuity_corrected_combined - pre_visual_acuity_corrected_combined as visual_acuity_corrected_improvement,
                    post_visual_acuity_best_corrected_combined - pre_visual_acuity_best_corrected_combined as visual_acuity_best_corrected_improvement
                from
                    acuity_cte_1
       )
	   UPDATE  cat
					SET 
						cat.[pre_visual_acuity_uncorrected_combined]		=	a.[pre_visual_acuity_uncorrected_combined]		,
						cat.[post_visual_acuity_uncorrected_combined]		=	a.[post_visual_acuity_uncorrected_combined]		,
						cat.[pre_visual_acuity_corrected_combined]			=	a.[pre_visual_acuity_corrected_combined]			,
						cat.[post_visual_acuity_corrected_combined]			=	a.[post_visual_acuity_corrected_combined]			,
						cat.[pre_visual_acuity_best_corrected_combined]		=	a.[pre_visual_acuity_best_corrected_combined]		,
						cat.[post_visual_acuity_best_corrected_combined]	=	a.[post_visual_acuity_best_corrected_combined]	,
						cat.[visual_acuity_uncorrected_improvement]			=	a.[visual_acuity_uncorrected_improvement]			,
						cat.[visual_acuity_corrected_improvement]			=	a.[visual_acuity_corrected_improvement]			,
						cat.[visual_acuity_best_corrected_improvement]	    =	a.[visual_acuity_best_corrected_improvement]	
						
					FROM [registry].[fact_cataract] cat
					JOIN acuity_cte_2	    a	
					ON  cat.practiceNumber  = a.practiceNumber   
					and cat.professionalNumber    = a.professionalNumber
					and cat.surgeryDate = a.surgeryDate  and cat.dob = a.dob

end