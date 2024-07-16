clc
clear

weight = 2; % 1:light 2:heavy
if weight == 1
    filename = 'Result_expanding_light_weight.mat';
elseif weight == 2
    filename = 'Result_expanding_heavy_weight.mat';
end

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

DM_result = nan(NoEst,NoEst,NoPredictant);

for i = 1:NoPredictant
    DM_result(:,:,i) = DMtests(Forecast(:,i,:),ActFutVal(:,i,:));
end

Comparetive_tab_DM = nan(4,2);

Comparetive_tab_DM(1,1)= sum(DM_result(7,6,:) > 1.96);
Comparetive_tab_DM(2,1)= sum(DM_result(3,1,:) > 1.96);
Comparetive_tab_DM(3,1)= sum(DM_result(8,6,:) > 1.96);
Comparetive_tab_DM(4,1)= sum(DM_result(4,1,:) > 1.96);
Comparetive_tab_DM(5,1)= sum(DM_result(9,6,:) > 1.96);
Comparetive_tab_DM(6,1)= sum(DM_result(5,1,:) > 1.96);

Comparetive_tab_DM

Comparetive_tab_DM(1,2)= sum(DM_result(6,7,:) > 1.96);
Comparetive_tab_DM(2,2)= sum(DM_result(1,3,:) > 1.96);
Comparetive_tab_DM(3,2)= sum(DM_result(6,8,:) > 1.96);
Comparetive_tab_DM(4,2)= sum(DM_result(1,4,:) > 1.96);
Comparetive_tab_DM(5,2)= sum(DM_result(6,8,:) > 1.96);
Comparetive_tab_DM(6,2)= sum(DM_result(1,5,:) > 1.96);

Comparetive_tab_DM
