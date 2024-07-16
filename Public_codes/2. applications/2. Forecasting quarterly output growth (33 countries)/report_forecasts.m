function [Stats, DM]=report_forecasts(D, Forecast_errors, Forecast_values,ind, samplef, Nopredictors, Rsq, scfe, report_variable_selection, savefile)

m=size(Forecast_errors,3);

% first basic stats



for i=1:m
   statsm= report_forecasts_m(D, Forecast_errors, Forecast_values,ind, samplef,i, Nopredictors, Rsq);
   Stats{i}=statsm;
end

% save data
if  report_variable_selection
    selected_methods_to_save=[1,78,134,141]; % AR, OCMT, Lasso, A-Lasso - all lambda=1
    for j=selected_methods_to_save
        save_data(D, Forecast_errors, Forecast_values,ind, samplef,j, Nopredictors, Rsq, savefile); 
    end
end

% now DM tests

DM=DMtests(Forecast_errors,samplef, ind, scfe, D) ;



return