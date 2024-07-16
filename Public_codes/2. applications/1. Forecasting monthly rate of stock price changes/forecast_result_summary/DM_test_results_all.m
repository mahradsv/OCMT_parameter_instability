clc
clear

w = 2; % 1:light 2:heavy

if w == 1
    filename = 'Result_expanding_light_weight.mat';
    sheets = {'Light Weighting'}; % Light or Heavy
elseif w == 2
    filename = 'Result_expanding_heavy_weight.mat';
    sheets = {'Heavy Weighting'}; % Light or Heavy
end

excelfile_name = 'summary_DM_all.xlsx';
load(filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[T,n_stocks,M] = size(ActFutVal);
n_wights = 6;
n_method = M/n_wights;
ActFutVal_adj = nan(T,n_stocks,n_method);
Forecast_adj = nan(T,n_stocks,n_method);
nvars_adj = nan(T,n_stocks,n_method);
Perdiction_Period_adj = NaT(T,n_stocks,n_method);
for i = 1:n_method
    ActFutVal_adj(:,:,i) = ActFutVal(:,:,1);
    Forecast_adj(:,:,i) = mean(Forecast(:,:,(i-1)*n_wights + 1:i*n_wights),3);
    nvars_adj(:,:,i) = mean(nvars(:,:,(i-1)*n_wights + 1:i*n_wights),3);
    Perdiction_Period_adj(:,:,i) = Perdiction_Period(:,:,1);
end
for i = 1:4
ActFutVal_adj(:,:,n_method+i) = ActFutVal(:,:,1);
Forecast_adj(:,:,n_method+i) = Forecast(:,:,(i+1)*n_wights);
nvars_adj(:,:,n_method+i) = nvars(:,:,(i+1)*n_wights);
Perdiction_Period_adj(:,:,n_method+i) = Perdiction_Period(:,:,(i+1)*n_wights);
end

ActFutVal = ActFutVal_adj;
Forecast = Forecast_adj;
nvars = nvars_adj;
Perdiction_Period = Perdiction_Period_adj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NoPeriod = size(Perdiction_Period,1);
NoPredictant = size(Perdiction_Period,2);
NoEst = size(Perdiction_Period,3);

DM_result = DMtests(Forecast,ActFutVal);

methods = ["OCMT with down-weighting for est. only","OCMT with down-weighting for both",...
    "Lasso with down-weighting","AD-Lasso with down-weighting","Boosting with down-weighting",...
    "OCMT with no down-weighting for both","Lasso with no down-weighting",...
    "AD-Lasso with no down-weighting","Boosting with no down-weighting"];


writematrix(methods,excelfile_name,'Sheet',sheets{1},'Range','B1');
writematrix(methods',excelfile_name,'Sheet',sheets{1},'Range','A2');
writematrix(DM_result,excelfile_name,'Sheet',sheets{1},'Range','B2');
