function [fcst, npred, Rsquared, svs, mnames]=ocmt_all(D,variables_to_forecast, sample,tf, weight, set_type, weight_ave, a_differencing)

OCMTm1=1;
Noweight=length(weight)+1;
      
       p_val=0.01; delta=1; deltastar=2;  
       of=OCMT_forecasts(D,variables_to_forecast, sample,tf, p_val,delta,deltastar,weight, set_type, weight_ave, a_differencing);
       if length(weight)==1
            fcst(:,OCMTm1)=of.forecasts(tf,:)';
            npred(:,OCMTm1)=of.npred;   
            Rsquared(:,OCMTm1)=of.Rsquared; 
            
       else
        for i=1:2*Noweight
            fcst(:,OCMTm1+i-1)=of{i}.forecasts(tf,:)';
            npred(:,OCMTm1+i-1)=of{i}.npred;
            Rsquared(:,OCMTm1+i-1)=of{i}.Rsquared;
            % report variables used in the forecasting regression
            svs{OCMTm1+i-1}=of{i}.SVcell;
            mnames{OCMTm1+i-1}=of{i}.mnames;
        end
       end
       
        p_val=0.05; posun=2*Noweight;
       of=OCMT_forecasts(D,variables_to_forecast, sample,tf, p_val,delta,deltastar,weight, set_type, weight_ave, a_differencing);
       if length(weight)==1
            fcst(:,OCMTm1+1)=of.forecasts(tf,:)';
            npred(:,OCMTm1+1)=of.npred;
            Rsquared(:,OCMTm1+1)=of.Rsquared;
       else
        for i=1:2*Noweight
            fcst(:,OCMTm1+i-1+posun)=of{i}.forecasts(tf,:)';
            npred(:,OCMTm1+i-1+posun)=of{i}.npred;
            Rsquared(:,OCMTm1+i-1+posun)=of{i}.Rsquared;
            % report variables used in the forecasting regression
            svs{OCMTm1+i-1+posun}=of{i}.SVcell;
            mnames{OCMTm1+i-1+posun}=of{i}.mnames;
        end
       end       
       

       p_val=0.10; posun=4*Noweight;
       of=OCMT_forecasts(D,variables_to_forecast, sample,tf, p_val,delta,deltastar,weight, set_type, weight_ave, a_differencing);
       if length(weight)==1
            fcst(:,OCMTm1+1)=of.forecasts(tf,:)';
            npred(:,OCMTm1+1)=of.npred;
            Rsquared(:,OCMTm1+1)=of.Rsquared;
       else
        for i=1:2*Noweight
            fcst(:,OCMTm1+i-1+posun)=of{i}.forecasts(tf,:)';
            npred(:,OCMTm1+i-1+posun)=of{i}.npred;
            Rsquared(:,OCMTm1+i-1+posun)=of{i}.Rsquared;
            % report variables used in the forecasting regression
            svs{OCMTm1+i-1+posun}=of{i}.SVcell;
            mnames{OCMTm1+i-1+posun}=of{i}.mnames;
        end
       end       
       
       % compute delta averages
       posun=6*Noweight;
       for i=1:2*Noweight
            aves=([1:3]-1)*2*Noweight+OCMTm1+i-1;
            fcst(:,OCMTm1+i-1+posun)=mean(fcst(:,aves),2);
            npred(:,OCMTm1+i-1+posun)=NaN(size(of{1}.npred));
            Rsquared(:,OCMTm1+i-1+posun)=NaN(size(of{1}.Rsquared));
            svs{OCMTm1+i-1+posun}={};
            mnames{OCMTm1+i-1+posun}={};
       end



return