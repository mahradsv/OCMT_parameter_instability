function [obj1,obj2]= Predict_Lasso(y,Z,X,Zf,Xf,compute_also_ALasso,weight)

if nargin < 1
    weight = 1;
end
%% first Lasso
set = sum(isnan(X),2)==0;
if isempty(Z)
    reg = X(set,:);
else
    reg = [Z(set,:),X(set,:)];
end
yr = y(set);
yf_hat = nan(1,length(weight));
nvars = nan(1,length(weight));
ind_lasso = nan(size(X,2),length(weight));
yf_hata = nan(1,length(weight));
nvarsa = nan(1,length(weight));
ind_lassoa = nan(size(X,2),length(weight));
for i = 1:length(weight)
    w = weight(i);
    w_reg = w.^([sum(set)-1:-1:0]').* reg;
    w_yr = w.^([sum(set)-1:-1:0]').* yr;
    
    options = glmnetSet;
    options.penalty_factor = [zeros(1,size(Z,2)),ones(1,size(X,2))];
    fit = cvglmnet(w_reg,w_yr,'gaussian',options);
    Op_lambda_ind = fit.glmnet_fit.lambda == fit.lambda_min;
    beta_all = fit.glmnet_fit.beta(:,Op_lambda_ind);
    intercept = fit.glmnet_fit.a0(Op_lambda_ind);
    ind = beta_all~=0;
    ind_lasso(:,i) = ind(size(Z,2)+1:end);
    b = [intercept;beta_all];
    regf = [1,Zf,Xf];
    yf_hat(i) = regf*b;
    nvars(i) = sum(ind_lasso(:,i));
    
    if compute_also_ALasso==1
        %% next adaptive Lasso
        if sum(ind_lasso)>0
            options = glmnetSet;
            options.exclude = find(beta_all == 0);
            penalty = 1./abs(beta_all(size(Z,2)+1:end)');
            penalty(penalty == inf) = 1e+16;
            options.penalty_factor = [zeros(1,size(Z,2)),penalty];
            fita = cvglmnet(w_reg,w_yr,'gaussian',options);
            Op_lambda_inda = fita.glmnet_fit.lambda == fita.lambda_min;
            betaa_all = fita.glmnet_fit.beta(:,Op_lambda_inda);
            intercepta = fit.glmnet_fit.a0(Op_lambda_ind);
            inda = betaa_all~=0;
            ind_lassoa(:,i) = inda(size(Z,2)+1:end);
            ba = [intercepta;betaa_all];
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
