This folder contains codes and data for the replication of the first empirical application on forecasting Euro Area quarterly output growth presented in "Variable Selection in High Dimensional Linear Regressions with Parameter Instability", version July 2024, by Alexander Chudik , M. Hashem Pesaran, and Mahrad Sharifvaghefi.

The main file to run is prog_ECB_fcstsurvey.m. This file includes comments that describe the code. This file:
 (i) first loads the data (GDP_H1_test_K_4.xlsx), 
(ii) then computes the results, and
(iii) saves the results in excel file by calling the script report_results.m. 

Weights vector 'weight' (in row 24 of prog_ECB_fcstsurvey.m) is the set of values for the exponential weighting paramater lambda. This can be changed to weight =[1,0.99,0.98,0.97, 0.96, 0.95] for heavy downweighting in the paper, or to weight =[1,0.995,0.99,0.985, 0.98, 0.975] for the light down-weighting considered in the paper. Please note the code needs to be run separately for each selection of the weights. 

Before the script report_results.m is called, all results/variables are saved in mat file ("fcstresults_Realization horizon1  heavy_lambda.mat" for heavy down-weighting and "fcstresults_Realization horizon1  light_lambda.mat" for light downweighting). Script report_results.m saves the relevant results in the following excel files:

(1) Forecasting_results XXXX_Realization horizon1.xlsx, where XXXX is either light or heavy (depending on the chosen weights)
(2) Selected_variables_full_sample XXXX_Realization horizon1.xlsx, where XXXX is either light or heavy (depending on the chosen weights)

The first excel files (listed in (1) above) contain MSFE and panel DM tests results in sheet "Tables" (for Tables S3 and S4 reported in the online supplement). 