function of=OCMT_forecasts(D, variables_to_forecast, sample,tf, p_val,delta,deltastar,weight, set_type, weight_ave, a_differencing)


X=D.X;
codes=D.codes;
maxlag=D.maxlag;

no_vf=size(variables_to_forecast,2);
nox=size(X,2);

SV=false(nox,nox); % boolean matrix of selected variables 
for i=1:length(weight)
    SVw{i}=SV; % initialize dimensions
end

horizon=(tf-max(sample)+1)/2;


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

            if set_type==1
                Zind=conditioningset1(vcode, codes); % const
                Aind=activeset1(vcode, codes, a_differencing);
            end
            if set_type==2
                Zind=conditioningset1(vcode, codes);
                Aind=activeset2(vcode, codes, a_differencing);
            end
            if set_type==3
                Zind=conditioningset1(vcode, codes);
                Aind=activeset3(vcode, codes);
            end
            if set_type==4
                Zind=conditioningset1(vcode, codes);
                Aind=activeset4(vcode, codes);
            end            
        %find dependent variable
        indy=fv(vcode, codes);
    
        % get observations on all variables
          y=X(sample+horizon-1,indy); % dependent variable
          Z=X(sample,Zind); % conditioning set
          A=X(sample,Aind); % active set
        
          % first selection without weighting
          inds = sel_OCMT(indy,Zind, Aind,X, sample,p_val,delta,deltastar, tf);
            if strcmp(lastwarn,'Matrix is singular to working precision.')
                warning('FineId','fine');
            end
            if length(weight)>1 % weighted is computed
                for k=1:length(weight)
                    indsw{k} = sel_OCMTw(indy,Zind, Aind,X, sample,p_val,delta,deltastar, weight(k), tf);
                    SVw{k}(pos_sel(j),:)=indsw{k};
                end
            end
          
          SV(pos_sel(j),:)=inds;
        end
    end % j
end % i

%% now forecast using the selected variables by OCMT 
if length(weight)>1
    % first compute forecasts for inds
    FMAT=zeros(size(D.X));
    for i=1:length(weight)
        w=weight(i);
        [of{i}.forecasts, of{i}.npred, of{i}.Rsquared, Coefs]=forecast_LSW_direct(D,SV,variables_to_forecast,sample,tf, w);
        FMAT=FMAT+weight_ave(i)*of{i}.forecasts;
        % for checking 
       % [of{i}.npred, sum(SVw{i},2)]
           % report variables used in the forecasting regression
        SVcell=report_selections(SV,codes, Coefs);
        of{i}.SVcell=SVcell;
        of{i}.mnames=['OCMTa (selection without downweighting, forecasting regression downweighted), lambda=',num2str(w), ' p=',num2str(p_val),' delta=', num2str(delta), ' deltastar=', num2str(deltastar) ];
    end
    of{length(weight)+1}.forecasts=FMAT;
    of{length(weight)+1}.npred=of{length(weight)}.npred;
    of{length(weight)+1}.Rsquared=NaN(size(of{length(weight)}.Rsquared));
    of{length(weight)+1}.SVcell={};
    of{length(weight)+1}.mnames=['avelambda OCMTa (selection without downweighting, forecasting regression downweighted)', ' p=',num2str(p_val),' delta=', num2str(delta), ' deltastar=', num2str(deltastar) ];
          
    % now compute forecasts for indsw{k}
    FMAT=zeros(size(D.X));
    SVu=false(size(SV));
    for i=1:length(weight)
        w=weight(i);
        [of{length(weight)+1+i}.forecasts, of{length(weight)+1+i}.npred, of{length(weight)+1+i}.Rsquared,Coefs]=forecast_LSW_direct(D,SVw{i},variables_to_forecast,sample,tf, w);
        FMAT=FMAT+weight_ave(i)*of{length(weight)+1+i}.forecasts;
        SVu=SVu | SVw{i};
        SVcell=report_selections(SVw{i},codes, Coefs);
        of{length(weight)+1+i}.SVcell=SVcell;
        of{length(weight)+1+i}.mnames=['OCMTb (selection with downweighting, forecasting regression also downweighted), lambda=',num2str(w), ' p=',num2str(p_val),' delta=', num2str(delta), ' deltastar=', num2str(deltastar) ];
    end
    of{2*length(weight)+2}.forecasts=FMAT;
    of{2*length(weight)+2}.npred=sum(SVu,2);
    of{2*length(weight)+2}.Rsquared=NaN(size(of{length(weight)}.Rsquared));
    of{2*length(weight)+2}.SVcell={};
    of{2*length(weight)+2}.mnames=['avelambda OCMTb (selection with downweighting and forecasting regression also downweighted)', ' p=',num2str(p_val),' delta=', num2str(delta), ' deltastar=', num2str(deltastar) ];
      
else
    [of{1}.forecasts, of{1}.npred, of{1}.Rsquared] =forecast_LSW_direct(D,SV,variables_to_forecast,sample,tf,1);
end


return