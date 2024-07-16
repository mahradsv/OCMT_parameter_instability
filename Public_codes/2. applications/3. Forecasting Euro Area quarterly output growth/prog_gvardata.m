% this code is for forecasting GVAR dataset (in progress)
%clc

addpath([pwd,'\glmnet_matlab']);

%% load data
data_loaded=0;
h_horizon=8; % forecasting horizon either h=1 or h=4 or h=8
% set a_differencing - variable that determines if annual differences are added to the active sets
if h_horizon>3
    a_differencing=true;
else
    a_differencing=false;
end


if data_loaded==0
    input_data_file='Variable Data (1979Q2-2016Q4).xls'; % this is the data input file (2016 GVAR vintage, downloaded from https://sites.google.com/site/gvarmodelling/data)
                % sheets ys, Dps, eps, rs and lrs were constructed from the file Country Data (1979Q2-2016Q4).xls
                % rs and lrs for usa was constructd as an arithmetic an arithmetic average of the foreign economies
    [D]=load_data(input_data_file, a_differencing); % all data is stored in the structure D
end

Ts=60;         % smallest estimation sample => evaluation period is the last T-Ts-1(lag) periods
weight = [1,0.995,0.99,0.985, 0.98, 0.975]; 
%[1,0.99,0.98,0.97, 0.96, 0.95];
%[1,0.995,0.99,0.985, 0.98, 0.975];
if weight(6)==0.975
    fld=' light';
else
    fld=' heavy';
end
weight_ave= [1,1,1,1,1,1,1]'/6;

NoPeriod=D.T-Ts-2*h_horizon+2; 
NoEst=1;
Noweight=length(weight)+1; 

No_methods=148; %NoEst*(Noweight+1); %NoEst*(Noweight+No_weight_ave)

Fcsts = nan(size(D.X,2),No_methods, size(D.X,1)); %
Npred =  nan(size(D.X,2),No_methods, size(D.X,1)); %
Rsquared =  nan(size(D.X,2),No_methods, size(D.X,1));
%SVs=false(size(D.X,2),size(D.X,2),No_methods,size(D.X,1));
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

if h_horizon==1
     variables_to_forecast={'y'};
else
     variables_to_forecast={'a_y'}; %,'h_Dp','h_r','h_lr','h_eq','y','Dp','r','lr','eq', 'constant'}; % set of variables to forecast
end

he=2*h_horizon-1;
tic
parfor ts=Ts:D.T-2*h_horizon+1 %Ts
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
       
       %variables_to_forecast={'y','Dp','r','lr','eq', 'ys','Dps','rs','lrs','eqs','h_y','h_Dp','h_r','h_lr','h_eq','h_ys','h_Dps','h_rs','h_lrs','h_eqs' 'constant'}; % set of variables to forecast
       set_type=2;
       [focmt, nocmt, rocmt, svsocmt, mnames]=ocmt_all(D,variables_to_forecast, sample,tf, weight, set_type, weight_ave, a_differencing);
       fcst(:,OCMTm2:OCMTm2+8*Noweight-1)=focmt;
       npred(:,OCMTm2:OCMTm2+8*Noweight-1)=nocmt;
       rsq(:,OCMTm2:OCMTm2+8*Noweight-1)=rocmt;
       svs(OCMTm2:OCMTm2+8*Noweight-1)=svsocmt;
       Method_names(OCMTm2:OCMTm2+8*Noweight-1)=mnames;

       %variables_to_forecast={'y','Dp','r','lr','eq','h_y','h_Dp','h_r','h_lr','h_eq', 'constant'}; % set of variables to forecast
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

       
       %variables_to_forecast={'y','Dp','r','lr','eq', 'ys','Dps','rs','lrs','eqs','h_y','h_Dp','h_r','h_lr','h_eq','h_ys','h_Dps','h_rs','h_lrs','h_eqs' 'constant'}; % set of variables to forecast
       set_type=2;
       [ofl, ofa]=Lasso_forecasts(D,variables_to_forecast, sample,tf, weight, set_type, weight_ave, a_differencing);
       for i=1:Noweight
            fcst(:,Lassom2+i-1)=ofl{i}.forecasts(tf,:)';
            npred(:,Lassom2+i-1)=ofl{i}.npred; 
            fcst(:,ALassom2+i-1)=ofa{i}.forecasts(tf,:)';
            npred(:,ALassom2+i-1)=ofa{i}.npred;
            svs(Lassom2+i-1)={ofl{i}.SVcell};
            Method_names(Lassom2+i-1)={ofl{i}.method_name};
            svs(ALassom2+i-1)={ofa{i}.SVcell};
            Method_names(ALassom2+i-1)={ofa{i}.method_name};
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
