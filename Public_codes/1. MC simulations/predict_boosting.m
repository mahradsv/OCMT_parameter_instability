function obj = predict_boosting(y,Z,X,Zf,Xf,v,weight)

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

yf_hat = nan(1,length(weight));
nvars = nan(1,length(weight));
ind_boosting = nan(size(X,2),length(weight));

for i = 1:length(weight)
    
    w = weight(i);
    WX = w.^([sum(set)-1:-1:0]').* X;
    WZ_plus = w.^([sum(set)-1:-1:0]').* Z_plus;
    wy = w.^([sum(set)-1:-1:0]').* y;
    
    Pz = WZ_plus*(WZ_plus'*WZ_plus)^-1*WZ_plus';
    MWX = WX - Pz*WX;
    Mwy = wy - Pz*wy;
    
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
    % AIC(1,1)=log(sig2)+(1+trbm/T)/(1-(trbm+2)/T); AICc
    % AIC(1,1)=log(sig2)+2*trbm/T; %AIC
    AIC(1,1)=log(sig2)+trbm*log(T)/T; %BIC
    
    %iterations
    
    for j=2:mupp
        [sel_var,fitsel, betasel] = sel_reg_b(Mwy-fit,MWX,N,T); %iall(j,1)=i;
        fit = fit+v*fitsel;
        fitall(:,j) = fit;
        betas(:,j) = betas(:,j-1);
        betas(sel_var,j) = betas(sel_var,j)+v*betasel;
        xs = MWX(:,sel_var);
        Bc = (I-v*(xs*xs')/sum(xs.^2))*Bc;
        Bm = I - Bc;
        trbm = trace(Bm);
        up = Mwy-Bm*Mwy;
        sig2 = up'*up/T;
        % AIC(j,1) = log(sig2) + (1+trbm/T)/(1-(trbm+2)/T); % AICc
        % AIC(j,1)=log(sig2)+2*trbm/T; %AIC
        AIC(j,1)=log(sig2)+trbm*log(T)/T; %BIC
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
    beta_z = (WZ_plus'*WZ_plus)^-1*WZ_plus'*(wy - fitsel);
    beta_all = [beta_z;beta_x];
    set = sum(isnan(X(:,ind)),2)==0;

    regf = [1,Zf,Xf];
    ind_boosting(:,i) = ind;
    nvars(i) = sum(ind); % number of selected variables
    yf_hat(i) = regf*beta_all; % Forcast
end

obj.yf = yf_hat;
obj.nvars = nvars;
obj.inds = ind_boosting;

end