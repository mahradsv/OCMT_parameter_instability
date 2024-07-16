function [obj1,obj2] = predict_post_lasso(y,Z,X,Zf,Xf,compute_also_ALasso,weight)

if nargin < 7
    weight = 1;
end

[T,~]=size(X);
Z_plus = [ones(T,1),Z]; % add intercept

set = sum(isnan(X),2)==0;
y = y(set);
X = X(set,:);
Z_plus = Z_plus(set,:);

% no down-weighting at the selection stage using Lasso
Pz = Z_plus*(Z_plus'*Z_plus)^-1*Z_plus';
MX = X - Pz*X;
My = y - Pz*y;
options = glmnetSet;
options.maxit = 10^6;
options.intr = false;
rng(123659748); % initialize random sampler
fit = cvglmnet(MX,My,'gaussian',options,'deviance',10);
Op_lambda_ind = fit.glmnet_fit.lambda == fit.lambda_min;
beta_x = fit.glmnet_fit.beta(:,Op_lambda_ind);
ind = beta_x~=0;
set = sum(isnan(X(:,ind)),2)==0;
reg=[Z_plus(set,:),X(set,ind)];
yr = y(set);
regf = [1,Zf,Xf(:,ind)];

if compute_also_ALasso==1
    %% next adaptive Lasso
    if sum(ind)>0
        MXa = MX(:,ind)*diag(abs(beta_x(ind)));
        options = glmnetSet;
        options.maxit = 10^6;
        options.standardize = false;
        options.intr = false;
        rng(123659748); % initialize random sampler
        fita = cvglmnet(MXa,My,'gaussian',options);
        Op_lambda_inda = fita.glmnet_fit.lambda == fita.lambda_min;
        betaa = fita.glmnet_fit.beta(:,Op_lambda_inda);
        inda=abs(betaa)>0;
        n=size(X,2);
        od=[1:n]';
        ods1=od(ind);
        ods2=ods1(inda);
        indaf=false(n,1);
        indaf(ods2)=true;
        seta = sum(isnan(X(:,indaf)),2)==0;
        rega=[Z_plus(seta,:),X(seta,indaf)];
        yra = y(seta);
        regfa = [1,Zf,Xf(:,indaf)];        
    end
end


yf_hat = nan(1,length(weight));
nvars = nan(1,length(weight));
ind_lasso = nan(size(X,2),length(weight));

yf_hata = nan(1,length(weight));
nvarsa = nan(1,length(weight));
ind_lassoa = nan(size(X,2),length(weight));

for i = 1:length(weight)
    ind_lasso(:,i) = ind;
    nvars(i) = sum(ind); % number of selected variables
    
    % down-weighting at the estimation stage using LS
    w = weight(i);
    w_reg = w.^([sum(set)-1:-1:0]').* reg;
    w_yr = w.^([sum(set)-1:-1:0]').* yr;
    b = pinv(w_reg'*w_reg)*w_reg'*w_yr; % w_reg\w_yr;
    yf_hat(i) = regf*b; % Forcast
    
    if compute_also_ALasso==1
        %% next adaptive Lasso
        if sum(ind)>0
            ind_lassoa(:,i) = indaf;
            nvarsa(i) = sum(indaf); % number of selected variables
            
            % down-weighting at the estimation stage using LS
            w = weight(i);
            w_rega = w.^([sum(seta)-1:-1:0]').* rega;
            w_yra = w.^([sum(seta)-1:-1:0]').* yra;
            ba = pinv(w_rega'*w_rega)*w_rega'*w_yra; % w_reg\w_yr;
            yf_hata(i) = regfa*ba; % Forcast
        else  % 'no variables selected in Lasso'
            ind_lassoa(:,i) = ind;
            nvarsa(i) = sum(ind); % number of selected variables
            yf_hata(i) = yf_hat(i); % Forcast
            
        end
    end
end

obj1.yf = yf_hat;
obj1.nvars = nvars;
obj1.inds = ind_lasso;

obj2.yf = yf_hata;
obj2.nvars = nvarsa;
obj2.inds = ind_lassoa;

end