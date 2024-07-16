clc
clear

addpath ../utils

w = 1; % 1:light 2:heavy

if w == 1
    filename = 'Result_expanding_light_weight.mat';
    sheets = {'Light Weighting'}; % Light or Heavy
elseif w == 2
    filename = 'Result_expanding_heavy_weight.mat';
    sheets = {'Heavy Weighting'}; % Light or Heavy
end

excelfile_name = 'summary_all.xlsx';
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

ActFutVal = reshape(ActFutVal,NoPredictant*NoPeriod,NoEst);
nvars = reshape(nvars,NoPredictant*NoPeriod,NoEst);
Forecast = reshape(Forecast,NoPredictant*NoPeriod,NoEst);
Perdiction_Period = reshape(Perdiction_Period,NoPredictant*NoPeriod,NoEst);
set = ~isnat(Perdiction_Period);


methods = ["OCMT with down-weighting for est. only","OCMT with down-weighting for both",...
    "Lasso with down-weighting","AD-Lasso with down-weighting","Boosting with down-weighting",...
    "OCMT with no down-weighting for both","Lasso with no down-weighting",...
    "AD-Lasso with no down-weighting","Boosting with no down-weighting"];

statistics = {'Ave. number of selected variables','Min number of selected variables',...
    'Max number of selected variables','Mean Square Forecast Error','Bias',...
    'Mean Directional Accuracy','Null MDA','Mean Direction of Log Price Change',...
    'Mean Direction of the Prediction','PT test 1','PT test 2'};

char_vec = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
%

writecell(statistics,excelfile_name,'Sheet',sheets{1},'Range','B1');
writematrix(methods',excelfile_name,'Sheet',sheets{1},'Range','A2');

idx = set(:,1);

for j = 1:NoEst
    
    yf = Forecast(idx,j);
    y = ActFutVal(idx,j);
    num_var_sel = nvars(idx,j);
    [mse,~,bias] = FE(y,yf);
    
    reg_approach = false;
    [pt_test_2,mda,null_mda,mdy,mdp]=PT_test(y,yf,reg_approach);
    pt_test_1 = PT_test(y,yf);
    
    forecast_measure = [mean(num_var_sel),min(num_var_sel),max(num_var_sel),...
        mse,bias,mda,null_mda,mdy,mdp,pt_test_1,pt_test_2];
    
    all = true;
    writecell(replacenans(forecast_measure,all),excelfile_name,'Sheet',sheets{1},'Range',strcat('B',num2str(j+1)));
    
end
num_of_predictions = strcat("Total number of prediction is ",num2str(sum(idx)));
writematrix(num_of_predictions,excelfile_name,'Sheet',sheets{1},'Range',strcat('B',num2str(NoEst+2)));
