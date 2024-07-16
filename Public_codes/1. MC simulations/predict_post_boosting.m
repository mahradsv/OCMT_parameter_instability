function obj = predict_post_boosting(y,Z,X,Zf,Xf,v,weight)

if nargin < 7
    weight = 1;
end

[T,N] = size(X);
mupp=500; % max number of boosting replications
I = eye(T);
AIC=zeros(mupp,1);
fitall=zeros(T,mupp);
Z_plus = [ones(T,1),Z]; % add intercept

set = sum(isnan(X),2)==0;
y = y(set);
X = X(set,:);
Z_plus = Z_plus(set,:);

Pz = Z_plus*(Z_plus'*Z_plus)^-1*Z_plus';
MX = X - Pz*X;
My = y - Pz*y;

% no down-weighting at the selection stage using Boosting
fit = zeros(T,1);
betas = zeros(N,mupp);
[var_sel,fitsel,betasel] = sel_reg_b(My,MX,N,T);
fit = fit + v*fitsel;
fitall(:,1) = fit;
betas(var_sel,1) = v*betasel;
xs = MX(:,var_sel);
Bc = I-v*(xs*xs')/sum(xs.^2);
Bm = I-Bc;
trbm = trace(Bm);
up = My - Bm*My;
sig2 = up'*up/T; %sigs(1,1)=sig2;
%AIC(1,1) = log(sig2) + (1+trbm/T)/(1-(trbm+2)/T);
    % AIC(1,1)=log(sig2)+2*trbm/T; %AIC
    AIC(1,1)=log(sig2)+trbm*log(T)/T; %BIC
    
%iterations

for j=2:mupp
    [var_sel,fitsel, betasel] = sel_reg_b(My-fit,MX,N,T); %iall(j,1)=i;
    fit = fit + v*fitsel;
    fitall(:,j) = fit;
    betas(:,j) = betas(:,j-1);
    betas(var_sel,j) = betas(var_sel,j)+v*betasel;
    xs = MX(:,var_sel);
    Bc = (I-v*(xs*xs')/sum(xs.^2))*Bc;
    Bm = I-Bc;
    trbm = trace(Bm); %trbmal(j,1)=trbm;
    up = My - Bm*My;
    sig2 = up'*up/T;  %sigs(j,1)=sig2;
    %AIC(j,1) = log(sig2) + (1+trbm/T)/(1-(trbm+2)/T);
        % AIC(j,1)=log(sig2)+2*trbm/T; %AIC
        AIC(j,1)=log(sig2)+trbm*log(T)/T; %BIC 
end

% determine which iteration is last
[~, it]=min(AIC);
ind=abs(betas(:,it))>0;

set = sum(isnan(X(:,ind)),2)==0;
reg = [Z_plus(set,:),X(set,ind)];
yr = y(set);
regf = [1,Zf,Xf(:,ind)];

yf_hat = nan(1,length(weight));
nvars = nan(1,length(weight));
ind_boosting = nan(size(X,2),length(weight));
beta = nan(size(X,2),length(weight));

for i = 1:length(weight)
    ind_boosting(:,i) = ind;
    nvars(i) = sum(ind); % number of selected variables
    
    % down-weighting at the estimation stage using LS
    w = weight(i);
    w_reg = w.^([sum(set)-1:-1:0]').* reg;
    w_yr = w.^([sum(set)-1:-1:0]').* yr;
    b = pinv(w_reg'*w_reg)*w_reg'*w_yr; % w_reg\w_yr;
    yf_hat(i) = regf*b; % Forcast
    kz = size(Z_plus(set,:),2);
    beta(ind,i) = b(kz+1:end);
end

obj.yf = yf_hat;
obj.nvars = nvars;
obj.inds = ind_boosting;
obj.beta = beta;
end