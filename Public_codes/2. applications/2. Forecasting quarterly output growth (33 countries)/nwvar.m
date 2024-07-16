function v=nwvar(x,q)
% x is Tx1
% q is the truncation parameter

T=size(x,1);
xm=ones(1,T)*x/T;
xd=x-xm*ones(T,1);

G=zeros(q+1);

for s=0:q
    G(s+1)=xd(s+1:T,1)'*xd(1:T-s)/T;    
end

v=G(1);
for s=1:q
   v=v+(1-s/(q+1))*2*G(s+1); 
end
