function  beta=generatebeta(b,targetratio)

kr=size(b,2);
T=size(b,1)-1;

% generate eta
 alpha1=0.2*ones(1,kr); 
 alpha2=0.75*ones(1,kr);
 rhoeta=0.5*ones(1,kr); 
 scet=(ones(1,kr)-rhoeta.^2).^0.5;
 eta=zeros(T+1,kr);
 eta(1,:)=randn(1,kr);
 e=zeros(T+1,kr);
 sigeta=ones(T+1,kr); %stdevs not variances
 e(1,:)=randn(1,kr).*sigeta(1,:);
 for t=2:T+1
     sigeta(t,:)=((ones(1,kr)-alpha1-alpha2)+alpha1.*(e(t-1,:).^2)+alpha2.*(sigeta(t-1,:).^2)).^0.5;
     e(t,:)=randn(1,kr).*sigeta(t,:);
     eta(t,:)=rhoeta.*eta(t-1,:)+scet.*e(t,:);
 end
 %compute taueta
 nums=diag(b(1:T,:)'*b(1:T,:)/T)';

 taueta=((nums-targetratio*nums)/targetratio).^0.5;
 % compute beta
 beta=b+(ones(T+1,1)*taueta).*eta;
 
 return