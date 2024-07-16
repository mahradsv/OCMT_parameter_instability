function indf = sel_OCMT(indy,Zind, Aind,Xall, sample, pval,delta,deltastar, tf)

if nargin < 9
    weight = 1;
end
h=tf-max(sample);

y=Xall(sample+h-1,indy);
Z=Xall(sample,Zind);
X=Xall(sample,Aind);

[T,~]=size(X);
Z_plus=[Z]; % no need to add intercept
maxregthreshold=floor(T/2);
[ind, ~, ~,~]=unbalance_OCMT(y ,Z_plus, X , pval,delta,deltastar, maxregthreshold);
inds=assign(Aind,ind);
% sum(ind)
% if sum(ind)>2
%     'here'
% end

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

end