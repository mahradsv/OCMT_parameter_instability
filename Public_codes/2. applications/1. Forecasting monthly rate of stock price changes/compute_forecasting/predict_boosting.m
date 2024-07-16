function obj = predict_boosting(y,Z,X,Zf,Xf,v,stopping_criterion,weight)

if nargin < 7
    weight = 1;
end

Z_plus = [ones(length(y),1),Z]; % add intercept
set = sum(isnan(X),2)==0;
y = y(set);
X = X(set,:);
Z_plus = Z_plus(set,:);

[T,N] = size(X);
mupp=500; % max number of boosting replications
I = eye(T);
stop_stat=zeros(mupp,1);
fitall=zeros(T,mupp);

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
    if stopping_criterion == "AIC"
        stop_stat(1,1) = log(sig2)+(1+trbm/T)/(1-(trbm+2)/T);
    elseif stopping_criterion == "BIC"
        stop_stat(1,1) = log(sig2)+trbm*log(T)/T;
    end
    
    %iterations
    
    for j=2:mupp
        [sel_var,fitsel, betasel] = sel_reg_b(Mwy-fit,MWX,N,T); %iall(j,1)=i;
        fit = fit+v*fitsel;
        fitall(:,j) = fit;
        betas(:,j) = betas(:,j-1);
        betas(sel_var,j) = betas(sel_var,j)+v*betasel;
        ind_temp = abs(betas(:,j))>0;
        xs = MWX(:,sel_var);
        Bc = (I-v*(xs*xs')/sum(xs.^2))*Bc;
        Bm = I - Bc;
        trbm = trace(Bm);
        up = Mwy-Bm*Mwy;
        sig2 = up'*up/T;
        if stopping_criterion == "AIC"
            stop_stat(j,1) = log(sig2) + (1+trbm/T)/(1-(trbm+2)/T);
        elseif stopping_criterion == "BIC"
            stop_stat(j,1) = log(sig2) + trbm*log(T)/T;
        end
    end
    
    % determine which iteration is last
    [~, it] = min(stop_stat);
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

obj.yf_hat = yf_hat;
obj.nvars = nvars;
obj.ind = ind_boosting;

end