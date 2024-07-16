function [of]=Boosting_forecasts(D, variables_to_forecast, sample,tf, weight, set_type, weight_ave, a_differencing)


X=D.X;
codes=D.codes;
maxlag=D.maxlag;

horizon=(tf-max(sample)+1)/2;

no_vf=size(variables_to_forecast,2);
nox=size(X,2);
for h=1:length(weight)
    SV{h}=false(nox,nox); % boolean matrix of selected variables 
    SVcoef{h}=NaN(nox,nox); % matrix of coefficients 
    SVa{h}=false(nox,nox); 
    SVcoefa{h}=NaN(nox,nox); 
end

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
     for h = 1:length(weight)
         w=weight(h);
        cn=codes(1,pos_sel(j));
        vcode=[cn;{vf}; {'lag0'}];
       if strcmp(cn{1},'deterministics')
           if strcmp(vf,'constant')
              % forecast index set is set to det,const, lag1
              vcodel=[{'deterministics'};{'constant'}; {'lag1'}];
              inds=fv(vcodel, codes);
              SV{h}(pos_sel(j),:)=inds;
              SVcoef{h}(pos_sel(j),:)=1;
           end
       else
        % set the conditioning and active sets based on set_type

            if set_type==1
                Zind=conditioningset1(vcode, codes); % AR+const
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
        try
          y=X(sample+horizon-1,indy); % dependent variable
        catch me
            'here'
        end
          Z=X(sample,Zind); % conditioning set
          A=X(sample,Aind); % active set
          T=size(y,1);
          Z = w.^([T-1:-1:0]').* Z;
          y = w.^([T-1:-1:0]').* y; 
          A = w.^([T-1:-1:0]').* A;
          
        % filter out Z
        Mz=eye(size(Z,1))-Z*inv(Z'*Z)*Z';
        yz=Mz*y;
        Az=Mz*A;
        
%%      
        MWX=Az;
        Mwy=yz;
        
[T,N]=size(Az);
mupp=500;
v = 0.5; %%%%%%%%%%%%%%
I = eye(T);

    fit = zeros(T,1);
    betas = zeros(N,mupp);
    [sel_var,fitsel,betasel] = sel_reg_b(Mwy,MWX,N,T);
    fit=fit+v*fitsel;
    fitall(:,1)=fit;
    betas(sel_var,1)=v*betasel;
    xs=MWX(:,sel_var);
    Bc=I-v*(xs*xs')/sum(xs.^2);
    Bm=I-Bc;
    trbm=trace(Bm);
    up=Mwy-Bm*Mwy;
    sig2=up'*up/T; %sigs(1,1)=sig2;
   % AIC(1,1)=log(sig2)+(1+trbm/T)/(1-(trbm+2)/T);
     AIC(1,1)=log(sig2)+trbm*log(T)/T; %BIC
     
    %iterations
    
    for jj=2:mupp
        [sel_var,fitsel, betasel] = sel_reg_b(Mwy-fit,MWX,N,T); %iall(j,1)=i;
        fit = fit+v*fitsel;
        fitall(:,jj) = fit;
        betas(:,jj) = betas(:,jj-1);
        betas(sel_var,jj) = betas(sel_var,jj)+v*betasel;
        xs = MWX(:,sel_var);
        Bc = (I-v*(xs*xs')/sum(xs.^2))*Bc;
        Bm = I - Bc;
        trbm = trace(Bm);
        up = Mwy-Bm*Mwy;
        sig2 = up'*up/T;
        %AIC(jj,1) = log(sig2) + (1+trbm/T)/(1-(trbm+2)/T);
         AIC(jj,1)=log(sig2)+trbm*log(T)/T; %BIC
    end
    
    % determine which iteration is last
    [~, it] = min(AIC);
    % select which fit it is
    fitsel = fitall(:,it);
    % compute corresponding betas
    ind = abs(betas(:,it))>0;
    selreg = MWX(:,ind);
    beta_x=zeros(N,1);
    beta_x(ind)=selreg\fitsel;        
    b= beta_x;   
        
        

%          % run Lasso and A-Lasso on filtered variables
%         rng(123456987); % initialize random sampler to avoid variation in Lasso and A-Lasso estimates
%         options = glmnetSet;
%         options.maxit = 10^6;
%         options.intr = false;
%         options.penalty_factor = [ones(1,size(A,2))]; %[zeros(1,size(Z,2)),ones(1,size(A,2))];
%         fit = cvglmnet(Az,yz,'gaussian',options);
%         Op_lambda_ind = fit.glmnet_fit.lambda == fit.lambda_min;
%         b = fit.glmnet_fit.beta(:,Op_lambda_ind);
%         %regind = b~=0;
%         %ind_lasso= regind;

 %%       
        % now compute coefficients for Z
        ya=y-A*b;
        bz=inv(Z'*Z)*Z'*ya;
        ball=[bz;b];
        regindall = ball~=0;
        Rind= Zind | Aind;
        inds=false(size(Rind,1),1);
        inds(Zind)=bz~=0;
        inds(Aind)=b~=0;
        %inds=assign(Rind,regindall);          
        SV{h}(pos_sel(j),:)=inds ;

        
        
        nval=size(Rind,1);
        bs=NaN(nval,1);
        %bs(Rind)=ball;
        bs(Zind)=bz;
        bs(Aind)=b;
        SVcoef{h}(pos_sel(j),:)=bs';
        
        % Adaptive Lasso next
        
%   %% next adaptive Lasso
%         if sum(ind_lasso)>0
%              rng(123456987); % initialize random sampler to avoid variation in Lasso and A-Lasso estimates
%             options = glmnetSet;
%             options.intr = false;
%             options.maxit = 10^6;
%             options.exclude = find(b == 0);
%             penalty = 1./abs(b');
%             penalty(penalty == inf) = 1e+16;
%             options.penalty_factor = [penalty]; %[zeros(1,size(Z,2)),penalty];
%             fita = cvglmnet(Az,yz,'gaussian',options);
%             Op_lambda_inda = fita.glmnet_fit.lambda == fita.lambda_min;
%             ba = fita.glmnet_fit.beta(:,Op_lambda_inda);
%             
%             % now compute coefficients for Z
%             ya=y-A*ba;
%             bz=inv(Z'*Z)*Z'*ya;
%             balla=[bz;ba];
%             regindalla = balla~=0;
%             Rind= Zind | Aind;
%             inds=false(size(Rind,1),1);
%             inds(Zind)=bz~=0;
%             inds(Aind)=ba~=0;
%             %inds=assign(Rind,regindalla);          
%             SVa{h}(pos_sel(j),:)=inds ;
%         
%             nval=size(Rind,1);
%             bsa=NaN(nval,1);
%             %bsa(Rind)=balla;
%             bsa(Zind)=bz;
%             bsa(Aind)=ba;
%             SVcoefa{h}(pos_sel(j),:)=bsa';
%             
%         else
%             % 'no variables selected in Lasso'
%             SVa{h}(pos_sel(j),:)=SV{h}(pos_sel(j),:);
%             SVcoefa{h}(pos_sel(j),:)=SVcoef{h}(pos_sel(j),:);
%         end
   
       end % not det 
     end % h (weight)      
    end % j
    
end % i


% now forecast using the selected variables by OCMT 
for h=1:length(weight)
     w=weight(h);
%     try
    [of{h}.forecasts, of{h}.npred] =forecast_SVbeta_direct(D,SV{h},SVcoef{h},variables_to_forecast,sample,tf);
   % [ofa{h}.forecasts, ofa{h}.npred] =forecast_SVbeta_direct(D,SVa{h},SVcoefa{h},variables_to_forecast,sample,tf);
%     catch me
%         'here'
%         SV
%         SVcoef
%         SVa
%         SVcoefa
%         me
%         dbstop
%     end


of{h}.Rsquared=NaN(size(of{h}.npred));
%ofa{h}.Rsquared=NaN(size(of{h}.npred));

 % report variables used in the forecasting regression
    SVcell=report_selections(SV{h},codes, SVcoef{h});
    %SVcella=report_selections(SVa{h},codes, SVcoefa{h});
    of{h}.SVcell=SVcell;
    of{h}.method_name=['Boosting, expanding window, using lamnda=',num2str(w)];
    
    %ofa{h}.SVcell=SVcella;
    %ofa{h}.method_name=['Adaptive Lasso, expanding window, using lamnda=',num2str(w)];

end

% now forecast ave

FMAT=zeros(size(D.X));
%FMATa=zeros(size(D.X));

for i=1:length(weight)
    FMAT=FMAT+weight_ave(i)*of{i}.forecasts;
    %FMATa=FMATa+weight_ave(i)*ofa{i}.forecasts;
end
of{length(weight)+1}.forecasts=FMAT;
of{length(weight)+1}.npred=NaN(size(of{length(weight)}.npred));
of{length(weight)+1}.Rsquared=NaN(size(of{length(weight)}.Rsquared));
of{length(weight)+1}.method_name={};
of{length(weight)+1}.SVcell={};

% ofa{length(weight)+1}.forecasts=FMATa;
% ofa{length(weight)+1}.npred=NaN(size(ofa{length(weight)}.npred));
% ofa{length(weight)+1}.Rsquared=NaN(size(ofa{length(weight)}.Rsquared));
% ofa{length(weight)+1}.method_name={};
% ofa{length(weight)+1}.SVcell={};

return