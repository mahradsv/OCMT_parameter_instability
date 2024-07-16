This folder contains codes and data for the replication of the empirical application on forecasting output growth forecasts across 33 countries in the GVAR dataset presented in "Variable Selection in High Dimensional Linear Regressions with Parameter Instability", version July 2024, by Alexander Chudik , M. Hashem Pesaran, and Mahrad Sharifvaghefi.

The main file to run is prog_gvardata.m. This file includes comments that describe the code. This file:
 (i) first loads the data (from excel file 'Variable Data (1979Q2-2016Q4).xls'), 
(ii) then computes the results, and
(iii) saves the results in excel file by calling the script report_results.m. 

Variable h_horizon (in row 10 of prog_gvardata.m) can be set to 4 (four-quarter ahead) or to 8 (two-year ahead) forecasts. Please note the code needs to be run separately for each selection of the forecast horizon.
 
Weights vector 'weight' (in row 27 of prog_gvardata.m) is the set of values for the exponential weighting paramater lambda. This can be changed to weight =[1,0.99,0.98,0.97, 0.96, 0.95] for heavy downweighting in the paper, or to weight =[1,0.995,0.99,0.985, 0.98, 0.975] for the light down-weighting considered in the paper. Please note the code needs to be run separately for each selection of the weights. 

Before the script report_results.m is executed, all results/variables are saved in a mat file. Script report_results.m saves selected results in the following excel files:

(1) 'Forecasting_results XXXX_a_y horizonH.xlsx', where XXXX is either light or heavy (depending on the chosen weights), and H is either 4 or 8 (depending on four-quarter or 8-quarter ahead forecasts were chosen).
(2) Selected_variables_full_sample XXXX_Realization horizonH.xlsx, where XXXX is either light or heavy (depending on the chosen weights), and H is either 4 or 8 (depending on four-quarter or 8-quarter ahead forecasts were chosen).

All tables reported in the paper can be found in the Excel file "linked_tables.xlsx":

- Tables 8 and 9 are located in sheet T1
- Tables 10 and 11 are located in sheet T2
- Table 12 is located in sheet T3
- Tables 13 and 14 are located in sheet T4
