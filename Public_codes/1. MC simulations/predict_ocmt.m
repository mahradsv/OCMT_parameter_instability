function obj = predict_ocmt(y,Z,X,Zf,Xf, pval,delta,deltastar,weight,sel_weight,est_weight) 

if nargin < 9
    weight = 1;
    sel_weight = false;
    est_weight = flase;
end
if nargin < 10
    sel_weight = false;
    est_weight = flase;
end
if nargin < 11
    est_weight = flase;
end

ind = false(size(X,2),length(weight));
yf_hat = nan(1,length(weight));
nvars = nan(1,length(weight));
beta=zeros(size(X,2),length(weight));

[T,~]=size(X);
Z_plus=[ones(T,1),Z]; % add intercept
maxregthreshold=floor(T);
for i = 1:length(weight)
    w = weight(i);
    if sel_weight
        [ind_OCMT, ~,~ ,~]=unbalance_OCMT(y ,Z, X , pval,delta,deltastar,w, true,maxregthreshold);
    else
        [ind_OCMT, ~,~ ,~]=unbalance_OCMT(y ,Z, X , pval,delta,deltastar,1, true,maxregthreshold);
    end
    if all(isnan(ind_OCMT))
        yf_hat = nan; % Forcast
        nvars = nan; % number of selected variables
        nvars_add = nan; % number of selected variables in additional stages
    else
        if ~est_weight
            w = 1;
        end
        ind(:,i) = ind_OCMT;
        set = sum(isnan(X(:,ind(:,i))),2)==0;
        reg=[Z_plus(set,:),X(set,ind(:,i))]; %X(:,ind),ones(T,1)];
        yr = y(set);
        nvars(i) = sum(ind(:,i)); % number of selected variables
        regf = [1,Zf,Xf(:,ind(:,i))];
        w_reg = w.^([sum(set)-1:-1:0]').* reg;
        w_yr = w.^([sum(set)-1:-1:0]').* yr;
        b = pinv(w_reg'*w_reg)*w_reg'*w_yr; % w_reg\w_yr; 
        yf_hat(i) = regf*b; % Forcast
        kz=size(Z_plus(set,:),2);
        beta(ind(:,i),i)=b(kz+1:end);
    end
end

obj.yf = yf_hat;
obj.inds = ind;
obj.nvars = nvars;
obj.beta=beta;
end