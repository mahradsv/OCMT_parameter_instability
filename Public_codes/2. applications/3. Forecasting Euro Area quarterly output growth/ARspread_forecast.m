function of=ARspread_forecast(D, variables_to_forecast, sample,tf)


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
        inds=ARspread_regressor_set(vcode, codes);
        SV(pos_sel(j),:)=inds;
        end
    end % j
end % i


% now forecast using the selected variables by OCMT 

[of.forecasts, of.npred]=forecast_LS(D,SV,variables_to_forecast,sample,tf);



return