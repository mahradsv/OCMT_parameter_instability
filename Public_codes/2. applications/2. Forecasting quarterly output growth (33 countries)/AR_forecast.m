function [of, oflasso]=AR_forecast(D, variables_to_forecast, sample,tf,weight,weight_ave)


X=D.X;
codes=D.codes;
maxlag=D.maxlag;

no_vf=size(variables_to_forecast,2);
nox=size(X,2);

SV=false(nox,nox); % boolean matrix of selected variables 

for i=1:no_vf
     vf=variables_to_forecast{i};
     vcode=[{''};{vf}; {'lag0'}];
     ind_compare=[false,true,true];
     indvars=fvi(vcode, codes, ind_compare);
     pos_all=[1:nox];
     N= sum(indvars); % dimension of the variable type vf
     pos_sel=pos_all(indvars);
    for j=1:N
        % code of variable to forecast
        cn=codes(1,pos_sel(j));
        vcode=[cn;{vf}; {'lag0'}];
        if strcmp(cn{1},'deterministics')
           if strcmp(vf,'constant')
              % forecast index set is set to det,const, lag1
              vcodel=[{'deterministics'};{'constant'}; {'lag1'}];
              inds=fv(vcodel, codes);
              SV(pos_sel(j),:)=inds;
           end
        else
        % set the conditioning set
        vcode(2,1)={'y'};
        inds=AR_regressor_set(vcode, codes);
        SV(pos_sel(j),:)=inds;
        end
    end % j
end % i




%[of.forecasts, of.npred]=forecast_LS(D,SV,variables_to_forecast,sample,tf);
%oflasso.forecasts=forecast_Lasso(D,SV,variables_to_forecast,sample,tf);
FMAT=zeros(size(D.X));
for i=1:length(weight)
    w=weight(i);
    [of{i}.forecasts, of{i}.npred, of{i}.Rsquared, Coefs]=forecast_LSW_direct(D,SV,variables_to_forecast,sample,tf, w);
    FMAT=FMAT+weight_ave(i)*of{i}.forecasts;
    % report variables used in the forecasting regression
    SVcell=report_selections(SV,codes, Coefs);
    of{i}.SVcell=SVcell;
    of{i}.method_name=['AR(1) with downweighting using lamnda=',num2str(w)];
end
of{length(weight)+1}.forecasts=FMAT;
of{length(weight)+1}.npred=of{length(weight)}.npred;
of{length(weight)+1}.Rsquared=NaN(size(of{length(weight)}.Rsquared));
of{length(weight)+1}.SVcell=SVcell;
of{length(weight)+1}.method_name=['ave lambda AR(1)'];

oflasso=0;

return