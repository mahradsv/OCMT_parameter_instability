function o=predict_o(y,Z,X,Zf,Xf, weight)
nw=size(weight,2);
[T,n]=size(X);
yf=NaN(1,nw);
nvars=ones(1,nw)*4;
inds=false(n,nw); inds(1:4,:)=true;
beta=zeros(n,nw);

% select true signals
X=X(:,1:4);
Xf=Xf(:,1:4);

for i=1:nw
    w=weight(i);
    % down-weight data, estimate model, compute forecast
    T=size(y,1);
    Xw = w.^([T-1:-1:0]').* X;
    Zw = w.^([T-1:-1:0]').* Z;
    yw = w.^([T-1:-1:0]').* y;
    Xreg=[Xw,Zw];
    b=Xreg\yw;
    Xrf=[Xf,Zf];
    yf(1,i)=Xrf*b;
    beta(1:4,i)=b(1:4,1);
end

o.yf=yf;
o.nvars=nvars;
o.inds=inds;
o.beta=beta;
end