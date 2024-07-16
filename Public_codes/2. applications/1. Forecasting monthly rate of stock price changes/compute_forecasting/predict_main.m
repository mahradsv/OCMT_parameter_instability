clc
clear

cd ../compute_forecasting
addpath ../glmnet_matlab 

data_file_path = '../matlab_data/monthly/forecasting_final_dataset.mat';
load(data_file_path);

wl = 120; % minimum length for trianing periods

DJname = ["3M (#S)","AMERICAN EXPRESS (#S)","APPLE (#S)","BIOGEN (#S)","CATERPILLAR (#S)","CHEVRON (#S)","CISCO SYSTEMS (#S)",...
    "COCA COLA (#S)","WALT DISNEY (#S)","EXXON MOBIL (#S)","GENERAL ELECTRIC (#S)","GOLDMAN SACHS GP. (#S)","HOME DEPOT (#S)",...
    "INTERNATIONAL BUS.MCHS. (#S)","INTEL (#S)","JOHNSON & JOHNSON (#S)","JP MORGAN CHASE & CO. (#S)","MCDONALDS (#S)",...
    "MERCK & COMPANY (#S)","MICROSOFT (#S)","NIKE 'B' (#S)","PFIZER (#S)","PROCTER & GAMBLE (#S)","TRAVELERS COS. (#S)",...
    "UNITED TECHNOLOGIES (#S)","UNITEDHEALTH GROUP (#S)","VERIZON COMMUNICATIONS (#S)","WALMART (#S)"];

w = 1; % 1:light 2:heavy

if w == 1
    weight = [0.975,0.98,0.985,0.99,0.995,1]; % The set of numbers used for light downweighting in the prediction set
    result_filename = '../forecast_result_summary/Result_expanding_light_weight.mat';
elseif w == 2
    weight = [0.95,0.96,0.97,0.98,0.99,1]; % The set of numbers used for heavy downweighting in the prediction set 
    result_filename = '../forecast_result_summary/Result_expanding_heavy_weight.mat';
end

NoPeriod = 540; % number of forecasting periods
NoPredictant = size(DJname,2); % number of all predictant
NoActset = 40; % number of variables in the active set
NoEst = 5; % number of methods
Noweight = length(weight); % number of exponential decaying weights on data

Forecast = nan(NoPeriod,NoPredictant,NoEst*Noweight);
ActFutVal = nan(NoPeriod,NoPredictant,NoEst*Noweight);
nvars = nan(NoPeriod,NoPredictant,NoEst*Noweight);
Perdiction_Period = NaT(NoPeriod,NoPredictant,NoEst*Noweight);
struc.freq = false(NoPeriod,NoActset,NoEst*Noweight);
Selection_Frequency = repmat(struc,NoPredictant,1);

idx = nan(1,length(DJname));
for z = 1:length(DJname)
    idx(z) = find(contains(financial_stocks_names,DJname(z)));
end

for z = 1:NoPredictant
    i = idx(z);
    set = ~isnan(LP(log_price_change(:,i),1));
    date_all = date(set);
    y_all = log_price_change(set,i); % a predictant
    X_all = LP(independent_variables(i).data,1);
    num_var_list = independent_variables(i).num_var_list;
    X_all = X_all(set,:);
    Z_all = []; % set of variables in the conditioning set
    
    yf_hat_all = nan(NoPeriod,NoEst*Noweight);
    yf_all = nan(NoPeriod,NoEst*Noweight);
    nvars_all = nan(NoPeriod,NoEst*Noweight);
    Forcast_Date_all = NaT(NoPeriod,NoEst*Noweight);
    Sel_Freq_all = false(NoPeriod,NoActset,NoEst*Noweight);
    tic % start timer
    
    for t = 1:sum(set)-wl
        % create vectors for output of time t
        yf_hat_t = nan(1,NoEst*Noweight);
        nvars_t = nan(1,NoEst*Noweight);
        sel_path_t = false(NoActset,NoEst*Noweight);
        forcast_date_t = NaT(1,NoEst*Noweight);
        yf_t = nan(1,NoEst*Noweight);
        
        % subsample of variables used for estimation of parameters
        X = X_all(1:wl+t-1,:);
        if isempty(Z_all)
            Z = [];
        else
            Z = Z_all(1:wl+t-1,:);
        end
        y = y_all(1:wl+t-1);
        
        % subsample of observations used for one step ahead forecast
        Xf = X_all(wl+t,:);
        if isempty(Z_all)
            Zf = [];
        else
            Zf = Z_all(wl+t,:);
        end
        yf = y_all(wl+t,:);
        date_f = date_all(wl+t,:);
        
        % dropping predictors with insufficient number of observations
        inds = ~isnan(Xf) & sum(~isnan(X))>=120;
        X = X(:,inds);
        Xf = Xf(:,inds);
        
        % OCMT no down-weighting selection, down-weighting estimation       
        p_val=0.01; delta = 1; deltastar=2; 
        sel_weight=false; est_weight=true;
        obj1 = predict_ocmt(y,Z,X,Zf,Xf, p_val,delta,deltastar,weight,sel_weight,est_weight);
        yf_hat_t(1:Noweight) = obj1.yf_hat;
        nvars_t(1:Noweight) = obj1.nvars;
        sel_path_t(inds,1:Noweight) = obj1.ind;
        forcast_date_t(1:Noweight) = date_f;
        yf_t(1:Noweight) = yf;

        % OCMT down-weighting selection, down-weighting estimation       
        p_val=0.01; delta=1; deltastar=2;
        sel_weight=true; est_weight=true;
        obj2 = predict_ocmt(y,Z,X,Zf,Xf, p_val,delta,deltastar,weight,sel_weight,est_weight);
        yf_hat_t(Noweight+1:2*Noweight) = obj2.yf_hat;
        nvars_t(Noweight+1:2*Noweight) = obj2.nvars;
        sel_path_t(inds,Noweight+1:2*Noweight) = obj2.ind;
        forcast_date_t(Noweight+1:2*Noweight) = date_f;
        yf_t(Noweight+1:2*Noweight) = yf;

        % Lasso and Adaptive Lasso        
        compute_also_ALasso = 1;
        [obj3, obj4] = predict_lasso(y,Z,X,Zf,Xf,compute_also_ALasso,weight);
        yf_hat_t(2*Noweight+1:3*Noweight) = obj3.yf_hat;
        nvars_t(2*Noweight+1:3*Noweight) = obj3.nvars;
        sel_path_t(inds,2*Noweight+1:3*Noweight) = obj3.ind;
        forcast_date_t(2*Noweight+1:3*Noweight) = date_f;
        yf_t(2*Noweight+1:3*Noweight) = yf;

        yf_hat_t(3*Noweight+1:4*Noweight) = obj4.yf_hat;
        nvars_t(3*Noweight+1:4*Noweight) = obj4.nvars;
        sel_path_t(inds,3*Noweight+1:4*Noweight) = obj4.ind;
        forcast_date_t(3*Noweight+1:4*Noweight) = date_f;
        yf_t(3*Noweight+1:4*Noweight) = yf;
         
        % Boosting with \nu = 0.5 and BIC
        v = 0.5;
        stopping_criterion = "BIC";
        obj5 = predict_boosting(y,Z,X,Zf,Xf,v,stopping_criterion,weight);
        yf_hat_t(4*Noweight+1:5*Noweight) = obj5.yf_hat;
        nvars_t(4*Noweight+1:5*Noweight) = obj5.nvars;
        sel_path_t(inds,4*Noweight+1:5*Noweight) = obj5.ind;
        forcast_date_t(4*Noweight+1:5*Noweight) = date_f;
        yf_t(4*Noweight+1:5*Noweight) = yf;

        % stacking the results over time
        yf_hat_all(t,:) = yf_hat_t;
        nvars_all(t,:) = nvars_t;
        Sel_Freq_all(t,:,:) = sel_path_t;
        Forcast_Date_all(t,:) = forcast_date_t;
        yf_all(t,:) = yf_t;
        
    end
    
    toc % stop timer
    
    Forecast(:,z,:) = yf_hat_all;
    ActFutVal(:,z,:) = yf_all;
    nvars(:,z,:) = nvars_all;
    Perdiction_Period(:,z,:) = Forcast_Date_all;
    Selection_Frequency(z).freq = Sel_Freq_all;
end
act_set = struct;
act_set = repmat(act_set,[NoPredictant,1]);

for z = 1:NoPredictant
    act_set(z).name = independent_variables(z).name;
end

save(result_filename,'Forecast','nvars','ActFutVal','act_set','Selection_Frequency','Perdiction_Period')
