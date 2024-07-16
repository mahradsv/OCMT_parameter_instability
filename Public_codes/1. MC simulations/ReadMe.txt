These codes are for the Monte Carlo (MC) experiments reported in "Variable Selection in High Dimensional Linear Regressions with Parameter Instability", version July 2024, by Alexander Chudik, M. Hashem Pesaran, and Mahrad Sharifvaghefi. These codes were executed using Matlab R2019a on the Dallas Fed BigTex cluster.

The main file to run is "submit_MCjobs_to_cluster.m". Please see below for explanation on how to execute this file. 

1. This file can be modified for computations to be executed locally, if cluster is not available  (by commenting out line 47, and uncommenting line 48). 
2. This script submits all jobs/experiments to cluster (sequentially). In the case of local execution, jobs are computed sequentially (this can take a long time).
3. Once the jobs are finished, MC results will be saved in the chosen folder on the cluster (as specified on line 16) as individual mat files, for given choices for n,T, and experiment ID. In the case of a local execution, results files will be saved in the local Matlab working folder.
4. If results were computed on a cluster, please copy all of the result mat files to local Matlab working folder.
5. Script save_simul_parts.m loads the results mat files and writes selected results to an Excel file "MC_results.xlsx".

Please see also the comments in "submit_MCjobs_to_cluster.m" for further details. 

Explanation of "MC_results.xlsx":

1. Full set of detailed MC results reported in Section S-3 of the online supplement can be found in sheets "Se1" to "Se4" for the experiments with parameter instabilities, and sheets "Se9" to "Se12" for baseline experiments without parameter instabilites.
2. Summary tables for the main paper and for the supplement can be found in the sheet "Summary Tables"
