function statsm= save_data(D, Forecast_errors, Forecast_values,ind, samplef,i, Nopredictors, Rsq, savefile)

method_name=D.Method_names(i,1);

% get data and forecasts
Ava=squeeze(D.X(:,ind));               % actual values
Fe=squeeze(Forecast_errors(samplef,ind,i)); % forecast errors
Fv=squeeze(Forecast_values(samplef,ind,i)); % forecast values
Av=squeeze(D.X(samplef,ind));               % actual values

[a,b]=size(Ava);
psr=1;
M=cell(a+2+psr,3*b+3); M(1,1)=method_name;
ps=1;
M(2+psr,1+ps:b+ps)=D.country_names;  
M(2+psr,b+2+ps:2*b+1+ps)=D.country_names;
M(2+psr,2*b+3+ps:3*b+2+ps)=D.country_names;
M(1+psr,ps+1)={'actual data'};
M(1+psr,ps+b+2)={'forecasted values'};
M(1+psr,ps+2*b+3)={'forecast errors'};
M(1+psr,1)={'period'};
M(3+psr:end,1)=D.time_periods_names;
M(3+psr:end,ps+1:ps+b)=num2cell(Ava);

M(samplef+2+psr,b+2+ps:2*b+1+ps)=num2cell(Fv);
M(samplef+2+psr,2*b+3+ps:3*b+2+ps)=num2cell(Fe);

% save M
filename= savefile.data_fcst_errors; 
apom=method_name{1};
%xlswrite(filename,M,apom(1:31),'A1');



end