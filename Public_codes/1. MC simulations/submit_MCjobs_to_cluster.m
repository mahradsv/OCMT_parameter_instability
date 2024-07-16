% This script is for batch submission of individual MC jobs to a cluster.
% These jobs compute MC experiments in 
% "Variable Selection in High Dimensional Linear Regressions with Parameter Instability"
% by Alexander Chudik, M. Hashem Pesaran, and Mahrad Sharifvaghefi, July 2024.
% See ReadMe.txt for additional details
% Settings below must be configured for a specific cluster available to you.


%% cluster settings
qn='normal-32g'; % this is queue name (check your cluster for available queue names)
nd=16; % number of CPU cores per node   

c=parcluster('bigtex R2019a'); % your cluster name
c.AdditionalProperties.QueueName = qn; 
c.AdditionalProperties.WallTime= '';
folder_for_saving_results_on_the_cluster='/home/your_username/Fcstb'; % choose the desired folder where results will be saved    
addpath glmnet_matlab % please COPY the folder "glmnet_matlab" in the chosen working folder on line 16!

%% submit job to the specified cluster    

nall=[20, 40,100]; % choices for cross section dimension
Tall=[100, 150, 200]; % choices for Te+1 (effective estimation sample size is Te due to one lag)

NodesNT=[8, 8,  8 ;
        8,  8,  8; 
        8, 8, 8];% This variable can be changed to request the desired number of nodes for given (n,T) pairs. 

bNmax=size(nall,2); 
bTmax=size(Tall,2);
env=cell(4);
env{1}='ni';
env{2}='nt';
env{3}='nall';
env{4}='Tall';
env{5}='experimentno';

[~,~,sel_set_of_experiments]=experimentID(); %ID numbers of selected set of experiments 

start1=tic;
for experimentno=[1:4,9:12] % sel_set_of_experiments

 for ni=1:bNmax
    for nt=1:bTmax
        tic
     [experimentno,ni,nt]
        totalNumberofWorkers= NodesNT(ni,nt)*nd/2;% number of matlab workers
        job=batch(c, 'job_for_cluster', 'Pool', totalNumberofWorkers-1,'EnvironmentVariables', 'env', 'CurrentFolder', folder_for_saving_results_on_the_cluster); %this commands submits the batch job. 
      % job_for_cluster % use this line for local execution only (and comment out line 47).
        toc

    end %bt
  end %bn
end %experimentno
toc(start1)

disp('All selected jobs are submitted.');

