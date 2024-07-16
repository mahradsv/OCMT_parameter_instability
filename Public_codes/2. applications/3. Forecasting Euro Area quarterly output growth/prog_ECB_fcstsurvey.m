% This code is for forecasting Euro Area quarterly output growth empirical application presented in:
% "Variable Selection in High Dimensional Linear Regressions with Parameter Instability", version July 2024, by Alexander Chudik , M. Hashem Pesaran, and Mahrad Sharifvaghefi.

% See ReadMe.txt for additional explanations

addpath([pwd,'\glmnet_matlab']);

%% load data
data_loaded=0;
h_horizon=1; % forecasting horizon - please set to one for the Euro Area quarterly output growth application
% set a_differencing - variable that determines if annual differences are added to the active sets
if h_horizon>3
    a_differencing=true;
else
    a_differencing=false;
end

if data_loaded==0
    input_data_file='GDP_H1_test_K_4.xlsx'; % this is the data input file
   [D]=load_data(input_data_file, a_differencing); % all data is stored in the structure D
end

Ts=20;         % smallest estimation sample => evaluation period is the last T-Ts-1(lag) periods
weight = [1,0.995,0.99,0.985, 0.98, 0.975]; % the chosen set of values for the exponential weighting paramater lambda. See ReadMe.txt for explanation.
%[1,0.99,0.98,0.97, 0.96, 0.95]; % set of heavy weights
%[1,0.995,0.99,0.985, 0.98, 0.975]; % set of light weights
if weight(6)==0.975
    fld=' light';
else
    fld=' heavy';
end
weight_ave= [1,1,1,1,1,1,1]'/6; %simple arithmetic weights

NoPeriod=D.T-Ts-2*h_horizon+2; 
NoEst=1;
Noweight=length(weight)+1; 

No_methods=148; %NoEst*(Noweight+1); %NoEst*(Noweight+No_weight_ave)

Fcsts = nan(size(D.X,2),No_methods, size(D.X,1)); %
Npred =  nan(size(D.X,2),No_methods, size(D.X,1)); %
Rsquared =  nan(size(D.X,2),No_methods, size(D.X,1));
SVs=cell(No_methods,size(D.X,1));


%% forecasting

ARm=1;
%ARspreadm=2;
OCMTm1=ARm+Noweight;
Lassom1= 8*Noweight+OCMTm1;
ALassom1=Lassom1+Noweight;
OCMTm2=Lassom1+2*Noweight;
Lassom2=8*Noweight+OCMTm2;
ALassom2=Lassom2+Noweight;
Method_namesa=cell(No_methods,size(D.X,1));

variables_to_forecast={'Realization'};

he=2*h_horizon-1;
tic
for ts=Ts:D.T-2*h_horizon+1 %Ts
        ts %
        
        sample=[1:ts];tf=ts+2*h_horizon-1;
        Method_names=cell(No_methods,1);
        % first benchmarks
        % AR(1)
         fcst=NaN(size(D.X,2),No_methods);
         npred=NaN(size(D.X,2),No_methods);
         rsq=NaN(size(D.X,2),No_methods);
         %svs=nan(size(D.X,2),size(D.X,2),No_methods);
         svs=cell(No_methods,1);
         
       [of]=AR_forecast(D,variables_to_forecast, sample,tf, weight,weight_ave);
       for i=1:Noweight
            fcst(:,ARm+i-1)=of{i}.forecasts(tf,:)';
            npred(:,ARm+i-1)=of{i}.npred;
            rsq(:,ARm+i-1)=of{i}.Rsquared;
            svs(ARm+i-1)={of{i}.SVcell};
            Method_names(ARm+i-1)={of{i}.method_name};
       end
      
    

       set_type=1; % set_type is for the type of active set
       [focmt, nocmt, rocmt, svsocmt, mnames]=ocmt_all(D,variables_to_forecast, sample,tf, weight, set_type, weight_ave, a_differencing);
       fcst(:,OCMTm1:OCMTm1+8*Noweight-1)=focmt;
       npred(:,OCMTm1:OCMTm1+8*Noweight-1)=nocmt;
       rsq(:,OCMTm1:OCMTm1+8*Noweight-1)=rocmt;
       svs(OCMTm1:OCMTm1+8*Noweight-1)=svsocmt;
       Method_names(OCMTm1:OCMTm1+8*Noweight-1)=mnames;
       
% boosting reported as the  OCMTm1+7*Noweight : OCMTm1+8*Noweight-1            
 
       [ofb]=Boosting_forecasts(D,variables_to_forecast, sample,tf, weight, set_type, weight_ave, a_differencing);
       for i=1:Noweight
            fcst(:,OCMTm1+7*Noweight+i-1)=ofb{i}.forecasts(tf,:)';
            npred(:,OCMTm1+7*Noweight+i-1)=ofb{i}.npred; 
            svs(OCMTm1+7*Noweight+i-1)={ofb{i}.SVcell};
            Method_names(OCMTm1+7*Noweight+i-1)={ofb{i}.method_name};
       end

       set_type=1;
       [ofl, ofa]=Lasso_forecasts(D,variables_to_forecast, sample,tf, weight, set_type, weight_ave, a_differencing);
       for i=1:Noweight
            fcst(:,Lassom1+i-1)=ofl{i}.forecasts(tf,:)';
            npred(:,Lassom1+i-1)=ofl{i}.npred; 
            fcst(:,ALassom1+i-1)=ofa{i}.forecasts(tf,:)';
            npred(:,ALassom1+i-1)=ofa{i}.npred; 
            svs(Lassom1+i-1)={ofl{i}.SVcell};
            Method_names(Lassom1+i-1)={ofl{i}.method_name};
            svs(ALassom1+i-1)={ofa{i}.SVcell};
            Method_names(ALassom1+i-1)={ofa{i}.method_name};
       end
     
        Fcsts(:,:,ts+he)=fcst;
        Npred(:,:,ts+he)=npred;
        Rsquared(:,:,ts+he)=rsq;
        SVs(:,ts+he)=svs;
        Method_namesa(:,ts+he)=Method_names;
 end % ts
toc
Method_names=Method_namesa(:,Ts+2*h_horizon-1);
D.Method_names=Method_names;
 save(['fcstresults_',variables_to_forecast{1},' ','horizon',int2str(h_horizon),' ',fld,'_lambda.mat'], '-v7.3');
 toc
 %dbstop
 report_results
