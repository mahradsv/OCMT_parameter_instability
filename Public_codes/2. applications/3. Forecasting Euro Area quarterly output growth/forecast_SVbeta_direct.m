function [Forecasts, npred]=forecast_SVbeta_direct(D,SV,SVcoef,variables_to_forecast,sample,tf)

X=D.X;
codes=D.codes;
maxlag=D.maxlag;
noX=size(X,2);
Forecasts=NaN(size(X));
npred=NaN(size(X,2),1);


no_vf=size(variables_to_forecast,2);

h=(tf-max(sample)+1)/2;


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
%     if i==93
%         'here'
%     end
    
    posf=posv(i);
    posf_nox=i;
    indf=SV(posf,:);
    % get data
    %set = sum(isnan(X(sample,posf)),2)==0;
    y=X(sample+h-1,posf);
    reg=[X(sample,indf)]; 
    npred(posf,1)=size(reg,2);
%     ycode=codes(:,posf)
%     regcodes=codes(:,indf)


%     for i = 1:length(weight)
%         w = weight(i);
%         w_reg = w.^([sum(set)-1:-1:0]').* reg;
%         w_yr = w.^([sum(set)-1:-1:0]').* yr;
%         b = w_reg\w_yr;
%         yf_hat(i) = regf*b; % Forcast
% 
%     end
    % run LS regression
    %b=reg\y;
    b=SVcoef(posf,indf);
    regf=[X(max(sample)+1+h-1,indf)]; 
    Forecasts(tf,posf)=regf*b';
end 

return