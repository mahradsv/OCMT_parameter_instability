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

MSFE = nan(NoPredictant,NoEst);
MDA = nan(NoPredictant,NoEst);

for i = 1:NoPredictant
    set = ~isnat(squeeze(Perdiction_Period(:,i,:)));
    idx = set(:,1);
    for j = 1:NoEst
        
        yf = Forecast(idx,i,j);
        y = ActFutVal(idx,i,j);
        [mse,~,~] = FE(y,yf);
        MSFE(i,j) = mse;
        
        reg_approach = false;
        [~,mda,~,~,~]=PT_test(y,yf,reg_approach);
        MDA(i,j) = mda;
        
    end
end
    
Comparetive_tab_msfe = nan(4,2);
Comparetive_tab_mda = nan(4,2);

Comparetive_tab_msfe(1,1)= sum(MSFE(:,6) < MSFE(:,7));
Comparetive_tab_msfe(2,1)= sum(MSFE(:,1) < MSFE(:,3));
Comparetive_tab_msfe(3,1)= sum(MSFE(:,6) < MSFE(:,8));
Comparetive_tab_msfe(4,1)= sum(MSFE(:,1) < MSFE(:,4));
Comparetive_tab_msfe(5,1)= sum(MSFE(:,6) < MSFE(:,9));
Comparetive_tab_msfe(6,1)= sum(MSFE(:,1) < MSFE(:,5));


Comparetive_tab_msfe(1,2)= sum(MSFE(:,6) > MSFE(:,7));
Comparetive_tab_msfe(2,2)= sum(MSFE(:,1) > MSFE(:,3));
Comparetive_tab_msfe(3,2)= sum(MSFE(:,6) > MSFE(:,8));
Comparetive_tab_msfe(4,2)= sum(MSFE(:,1) > MSFE(:,4));
Comparetive_tab_msfe(5,2)= sum(MSFE(:,6) > MSFE(:,9));
Comparetive_tab_msfe(6,2)= sum(MSFE(:,1) > MSFE(:,5));

Comparetive_tab_msfe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Comparetive_tab_mda(1,1)= sum(MDA(:,6) > MDA(:,7));
Comparetive_tab_mda(2,1)= sum(MDA(:,1) > MDA(:,3));
Comparetive_tab_mda(3,1)= sum(MDA(:,6) > MDA(:,8));
Comparetive_tab_mda(4,1)= sum(MDA(:,1) > MDA(:,4));
Comparetive_tab_mda(5,1)= sum(MDA(:,6) > MDA(:,9));
Comparetive_tab_mda(6,1)= sum(MDA(:,1) > MDA(:,4));

Comparetive_tab_mda(1,2)= sum(MDA(:,6) < MDA(:,7));
Comparetive_tab_mda(2,2)= sum(MDA(:,1) < MDA(:,3));
Comparetive_tab_mda(3,2)= sum(MDA(:,6) < MDA(:,8));
Comparetive_tab_mda(4,2)= sum(MDA(:,1) < MDA(:,4));
Comparetive_tab_mda(5,2)= sum(MDA(:,6) < MDA(:,9));
Comparetive_tab_mda(6,2)= sum(MDA(:,1) < MDA(:,5));

Comparetive_tab_mda
