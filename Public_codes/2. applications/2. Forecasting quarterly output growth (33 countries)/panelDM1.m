function [ DM1, DM2, DM1a, DM2a ] = panelDM1( Fea, Feb, w )

% input: NxT forecast errors (model a and benchmark model b)
%         w Nx1 vector of weights for alternative aggregation (DM3)
% output: DM1 - assuming serially uncorrelated errors
%         DM2 - adjustment for serial correlation (Newey-West) is made

[N,T]=size(Fea);

% compute z

z=(Fea.^2)-(Feb.^2);
zbi=z*ones(T,1)/T;
zb=ones(1,N)*zbi/N;
zba=w'*zbi;
w2=w.*w;
% compute variance
    % independent error differences across i
sigs=zeros(N,1);
zd=z-zbi*ones(1,T);

sigs=(zd.^2)*ones(T,1)/(T-1);
v1=(N^-2)*ones(1,N)*sigs/T;
v1a=w2'*sigs/T;

DM1=zb/(v1^0.5);
DM1a=zba/(v1a^0.5);

    % error differences are correlated across i (to be finished later)
    sigsnw=zeros(N,1);
    for i=1:N
       sigsnw(i,1)=nwvar(z(i,:)',2); 
    end
v2=(N^-2)*ones(1,N)*sigsnw/T;
v2a=w2'*sigsnw/T;

DM2=zb/(v2^0.5);
DM2a=zba/(v2a^0.5);



end

