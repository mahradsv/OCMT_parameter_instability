function obj = Predict_OCMT(indy,Zind, Aind,Xall, sample,tf, pval,delta,deltastar,weight)

if nargin < 9
    weight = 1;
end

y=Xall(sample,indy);
Z=Xall(sample,Zind);
X=Xall(sample,Aind);
Zf=Xall(tf,Zind);
Xf=Xall(tf,Aind);

nvall=size(Xall,2);



[T,~]=size(X);
Z_plus=[Z]; % no need to add intercept
maxregthreshold=floor(T/2);
[ind, ~, ~,~]=unbalance_OCMT(y ,Z_plus, X , pval,delta,deltastar, maxregthreshold);
inds=assign(Aind,ind);


% find t-ratios to eliminate insignificant conditioning variables if any
% no_con=sum(Zind);
% if no_con>0 
%     Xreg=[Xall(sample,Zind), Xall(sample,inds)];
%     [Tr, kr]=size(Xreg);
%     b=Xreg\y;
%     e=y-Xreg*b;
%     kr=size(Xreg,2);
%     ve=e'*e/(Tr-kr);
%     App=inv(Xreg'*Xreg); %pinv(Xr'*Xr);
%     seb=(diag(App)*ve).^0.5; 
%     tstats=abs(b)./seb;
%     cond_ind=tstats(1:no_con,1)>1.96;
% end
% cond_ind=false(nvall,1);
% cond_ind(Zind(cond_ind))=true;
% indf =inds | cond_ind; % this is index set of variables 
indf =inds | Zind;

if all(isnan(indf))
%     a = nan(1); % intercept only
%     beta_z = nan(size(Z,2),1);
%     beta_x = nan(size(ind));
    yf_hat = nan; % Forcast Error
    nvars = nan; % number of selected variables
else 
    nvars = sum(indf); % number of selected variables
    yf_hat = nan(1,length(weight));
    set = sum(isnan(Xall(sample,indf)),2)==0;
    reg=[Xall(set,indf)]; 
    regf = [Xall(tf,indf)];
    yr = y(set);
    for i = 1:length(weight)
        w = weight(i);
        %w_reg = reg;
        %w_reg(:,2:end) = w.^([sum(set)-1:-1:0]').* reg(:,2:end);
        w_reg = w.^([sum(set)-1:-1:0]').* reg;
        w_yr = w.^([sum(set)-1:-1:0]').* yr;
        b = w_reg\w_yr;
        yf_hat(i) = regf*b; % Forcast
        %     a = b(1); % intercept only
        %     beta_z = b(2:size(Z_plus,2));
        %     beta_x(ind) = b(size(Z_plus,2)+1:end);
    end
end
% obj.a = a;
% obj.beta_z = beta_z;
% obj.beta_x = beta_x;
obj.yf_hat = yf_hat;
obj.ind = indf;
obj.nvars = nvars;

end