
%load('fcstresults_4a.mat');

 %% report results
 % compute forecast error 
 clear Rsq Nopredictors Forecast_values Forecast_errors
 for m=1:No_methods
    Forecast_errors(:,:,m)=squeeze(Fcsts(:,m,:))'-D.X; % Forecaste is of periods x variables x methods dimension
    Forecast_values(:,:,m)=squeeze(Fcsts(:,m,:))'; % same dimensions as Forecast_errors
    Nopredictors(:,:,m)=squeeze(Npred(:,m,:))';
    Rsq(:,:,m)=squeeze(Rsquared(:,m,:))';
 end

 
 variables_to_save=variables_to_forecast; %{'y'}; %, 'eq', 'r', 'lr'};

 savefile.main=['Forecasting_results',fld,'_',variables_to_forecast{1},' horizon',int2str(h_horizon),'.xlsx']; savesheet='full_sample';
 savefile.selvars=['Selected_variables_full_sample',fld,'_',variables_to_forecast{1},' horizon',int2str(h_horizon),'.xlsx'];
 savefile.data_fcst_errors=['data_and_forecasts',fld,'_',variables_to_forecast{1},' horizon',int2str(h_horizon),'.xlsx'];
 
 
 cutoff='2007Q2'; cutof_time=NaN;
 for i=1:D.T
     if strcmp(D.time_periods_names{i},cutoff)
        cutof_time=i;
     end
 end
 samplef=[Ts+2*h_horizon-1:D.T]'; % full sample [Ts+horizon:D.T]'; [Ts+horizon:Ts+horizon+2]'
 save_sample_results(savefile,savesheet, D, Forecast_errors, Forecast_values, variables_to_save, Nopredictors, samplef, No_methods, Rsq, SVs, Method_names, h_horizon);
 
 
savesheet='precrisis_sample';  savefile.selvars='Selected_variables_precrisis_sample.xlsx'; 
 samplef=[Ts+2*h_horizon-1:cutof_time]'; % 
 save_sample_results(savefile,savesheet, D, Forecast_errors, Forecast_values, variables_to_save, Nopredictors, samplef, No_methods, Rsq, SVs, Method_names, h_horizon);
 
 
 savesheet='postcrisis_sample'; savefile.selvars='Selected_variables_postcrisis_sample.xlsx'; 
 samplef=[cutof_time:D.T]'; % 
 save_sample_results(savefile,savesheet, D, Forecast_errors, Forecast_values, variables_to_save, Nopredictors, samplef, No_methods, Rsq, SVs, Method_names, h_horizon);

