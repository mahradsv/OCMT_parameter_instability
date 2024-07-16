function [obj1,obj2]= predict_lasso(y,Z,X,Zf,Xf,compute_also_ALasso,weight)

if nargin < 7
    weight = 1;
end

%% first Lasso
[T,~]=size(X);
Z_plus = [ones(T,1),Z]; % add intercept

set = sum(isnan(X),2)==0;
y = y(set);
X = X(set,:);
Z_plus = Z_plus(set,:);

yf_hat = nan(1,length(weight));
nvars = nan(1,length(weight));
ind_lasso = nan(size(X,2),length(weight));

yf_hata = nan(1,length(weight));
nvarsa = nan(1,length(weight));
ind_lassoa = nan(size(X,2),length(weight));

for i = 1:length(weight)
    w = weight(i);
    WX = w.^([sum(set)-1:-1:0]').* X;
    WZ_plus = w.^([sum(set)-1:-1:0]').* Z_plus;
    wy = w.^([sum(set)-1:-1:0]').* y;
    
    Pz = WZ_plus*(WZ_plus'*WZ_plus)^-1*WZ_plus';
    MWX = WX - Pz*WX;
    Mwy = wy - Pz*wy;
    options = glmnetSet;
    options.maxit = 10^6;
    options.intr = false;
    rng(123659748); % initialize random sampler
    fit = cvglmnet(MWX,Mwy,'gaussian',options,'deviance',10);
    Op_lambda_ind = fit.glmnet_fit.lambda == fit.lambda_min;
    beta_x = fit.glmnet_fit.beta(:,Op_lambda_ind);
    beta_z = (WZ_plus'*WZ_plus)^-1*WZ_plus'*(wy - WX*beta_x);
    beta_all = [beta_z;beta_x];
    %intercept = fit.glmnet_fit.a0(Op_lambda_ind);
    ind = beta_x~=0;
    ind_lasso(:,i) = ind;
    b = beta_all;
    regf = [1,Zf,Xf];
    yf_hat(i) = regf*b;
    nvars(i) = sum(ind_lasso(:,i));
    
    if compute_also_ALasso==1
        %% next adaptive Lasso
        if sum(ind)>0
            MWXa = MWX(:,ind)*diag(abs(beta_x(ind)));
            options = glmnetSet;
            options.maxit = 10^6;
            options.standardize = false;
            options.intr = false;
            rng(123659748); % initialize random sampler
            fita = cvglmnet(MWXa,Mwy,'gaussian',options);
            Op_lambda_inda = fita.glmnet_fit.lambda == fita.lambda_min;
            betaa = fita.glmnet_fit.beta(:,Op_lambda_inda);
            inda=abs(betaa)>0;
            n=size(X,2);
            od=[1:n]';
            ods1=od(ind);
            ods2=ods1(inda);            
            indaf=false(n,1);
            indaf(ods2)=true;
            betaf_x=zeros(n,1);
            betaf_x(ods1)=betaa;
            betaf_x = betaf_x.*abs(beta_x);
            betaf_z = (WZ_plus'*WZ_plus)^-1*WZ_plus'*(wy - WX*betaf_x);
            ind_lassoa(:,i) = indaf;
            ba = [betaf_z;betaf_x];
            yf_hata(i) = regf*ba;
            nvarsa(i) = sum(ind_lassoa(:,i));
        else
            % 'no variables selected in Lasso'
            yf_hata(i) = yf_hat(i);
            nvarsa(i) = nvars(i);
            ind_lassoa(:,i) = ind_lasso(:,i);
        end
    end
end

obj1.yf_hat = yf_hat;
obj1.nvars = nvars;
obj1.ind = ind_lasso;
obj2.yf_hat = yf_hata;
obj2.nvars = nvarsa;
obj2.ind = ind_lassoa;

end
