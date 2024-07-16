function Forecasts=forecast_Lasso(D,SV,variables_to_forecast,sample,tf)

X=D.X;
codes=D.codes;
maxlag=D.maxlag;
noX=size(X,2);
Forecasts=NaN(size(X));

no_vf=size(variables_to_forecast,2);
% first find vector x of all variables that are forecasted



indv=false(noX,1);
for i=1:no_vf
     vf=variables_to_forecast{i};
     vcode=[{''};{vf}; {'lag0'}];
     ind_compare=[false,true,true];
     indvi=fvi(vcode, codes, ind_compare);
     indv=indvi | indv;
end
posall=[1:noX];
x=X(:,indv); % vector of variables to be forecasted
xcodes=codes(:,indv);
posv=posall(indv); % position of x in X
nox=sum(indv); % number of variables to be forecasted

A0=zeros(nox,nox);
Alags=zeros(nox,nox,maxlag);

% estimate coefficients A0 and Alags
for i=1:nox % need to add exception for the constant term !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    posf=posv(i);
    posf_nox=i;
    indf=SV(posf,:);
    % get data
    %set = sum(isnan(X(sample,posf)),2)==0;
    y=X(sample,posf);
    
    
    reg=[X(sample,indf)]; 
%     for i = 1:length(weight)
%         w = weight(i);
%         w_reg = w.^([sum(set)-1:-1:0]').* reg;
%         w_yr = w.^([sum(set)-1:-1:0]').* yr;
%         b = w_reg\w_yr;
%         yf_hat(i) = regf*b; % Forcast
% 
%     end
    % run Lasso regression
%     b=reg\y;
%     u=y-reg*b;

% find if it is deterministics
vcodel=[{'deterministics'};{'constant'}; {'lag0'}];
fcode=codes(:,posf);
isdet=fv(vcodel,fcode);
 if isdet
     b=1;
 else

        
    options = glmnetSet;
    options.maxit = 10^6;
    options.intr = false;
    options.penalty_factor = [ones(1,size(reg,2))];
    if size(reg,2)==1
        'here'
    end
    try
        fit = cvglmnet(reg,y,'gaussian',options);
    catch me
        'here'
        dbstop
    end

 end
    
    Op_lambda_ind = fit.glmnet_fit.lambda == fit.lambda_min;
    b = fit.glmnet_fit.beta(:,Op_lambda_ind);

    
    % report coefficient estimates
    k=sum(indf);
    bcodes=codes(:,indf);
    for s=1:k
       % assign individual coefficients in b to A0 or Alags
       row=posf_nox;
       % get identity of bi
       vcode=bcodes(:,s);
       % find position of vcode in x
       poss=fv([vcode{1,1};vcode{2,1};{'lag0'}],xcodes);
       if not(sum(poss)==1)
           'error'
           dbstop
       end
       if strcmp(vcode{3,1},'lag0') % is contemporaneous and goes to A0
           A0(row,poss)=b(s);
       else
           ind=strcmp(vcode{3,1},D.lagorders);
           taul=[0:maxlag];
           h=taul(ind);
           Alags(row,poss,h)=b(s);
       end
    end
end


% now compute forecasts
% construct lags of x
xlagsf=zeros(nox,maxlag); % observations on sample_T,samlpe_T-1,...,samlpe_T-maxlag+1
for s=1:maxlag
    xlagsf(:,s)=X(tf-s,indv)';
end

iG0=inv(eye(nox)-A0);
%construct G
G=zeros(nox,nox,maxlag);
xf=zeros(nox,1);
for i=1:maxlag
    Gi=iG0*Alags(:,:,i);
    xf=xf+Gi*xlagsf(:,i);
end
Forecasts(tf,indv)=xf';

return