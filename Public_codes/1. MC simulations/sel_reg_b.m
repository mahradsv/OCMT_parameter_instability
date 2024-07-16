function [idx,fitsel, beta]=sel_reg_b(y,X,N,T)

fitall=zeros(T,N);
sse=zeros(N,1);
betas=zeros(N,1);
for i=1:N
   Xr=X(:,i);
   b=Xr\y;
   betas(i,1)=b;
   fit=Xr*b;
   e=y-fit;
   fitall(:,i)=fit;
   sse(i,1)=e'*e;
   %eall(:,i)=e;
end
[~, idx]=min(sse);
%u=eall(:,in);
fitsel=fitall(:,idx);
beta=betas(idx);
end