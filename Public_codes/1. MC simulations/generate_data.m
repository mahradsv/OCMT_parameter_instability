function [Data]=generate_data(N, T, tau_u, use_ldv, mxv, nobreaks)

kreg=4; % number of signals

%% generate betas
 % generate b (means of beta)
 indt=[1:T+1];
 
 b=zeros(T+1,kreg); 
 b(indt<=floor(T/3),1:kreg/2)=2;
 b(indt>floor(2*T/3),1:kreg/2)=1;
 
 b(:,kreg/2+1:kreg)=0.5;
 b(indt>floor(T/2),kreg/2+1:kreg)=1.5;
 targetratio=0.95;
 beta=generatebeta(b,targetratio);
% override selection of betas in case of no breaks
if nobreaks
    beta=ones(T+1,kreg);
end

%% generate x-s
 %generate epsilons
 rhoeps=rand(1,N)*0.95;
 sceps=(ones(1,N)-rhoeps.^2).^0.5;
 eps=zeros(T+1,N); 
 eps(1,:)=randn(1,N);
 eep=zeros(T+1,N);
 eep(1,:)=randn(1,N);
 sigeep=zeros(T+1,N); 
 sigeep(1,:)=ones(1,N);
 alpha1eep=rand(1,N)*0.2;
 alpha2eep=rand(1,N)*0.15+0.6;
 for t=2:T+1
    sigeep(t,:)=(ones(1,N)-alpha1eep-alpha2eep + alpha1eep.*(eep(t-1,:).^2)+ alpha2eep.*(sigeep(t-1,:).^2)).^0.5; 
    eep(t,:)=randn(1,N).*sigeep(t,:);
    eps(t,:)= rhoeps.*eps(t-1,:)+sceps.*eep(t,:);
 end
 % generate R1 and R2
 r1=0.9; r2=0.4;
 for i=1:N
     for j=1:N
        R1(i,j)=r1^abs(i-j);
        R2(i,j)=r2^abs(i-j);
     end
 end
 R1h=R1^0.5;
 R2h=R2^0.5;
 
 % generate lambda vectors, R and x
 x=zeros(T+1,N);
 Omh=R1h;
 x(1,:)=(Omh*eps(1,:)')';
 for t=2:T+1
     if t<floor(T/2)+1
       Omh=R1h;
     else
        Omh=R2h;
     end
     
     x(t,:)=(Omh*eps(t,:)')';
 end
 
%% generate u
 alpha1u=0.2; alpha2u=0.75;
 sigu=zeros(T+1,1);
 sigu(1,1)=1;
 u=zeros(T+1,1);
 if mxv<1
     ua=zeros(T+1,1);
 else
     bxua=zeros(T+1,mxv);
     bxua(1:floor(T^0.25),:)=0.5;
     betaua=generatebeta(bxua,targetratio);
     ua=sum(x(:,kreg+1:kreg+mxv).*betaua,2);
 end
    u(1,1)=randn(1,1);
    for t=2:T+1
     sigu(t,1)= (1-alpha1u-alpha2u + alpha1u*u(t-1)^2 + alpha2u*sigu(t-1,1)^2)^0.5;
     u(t,1)=randn(1,1)*sigu(t,1);
    end 
    u=u+ua;
%% generate ct
 mux=1.5*ones(T+1,kreg); 
 mux(indt <= floor(T/3), 1:2) = 0.6;
 mux(indt > floor(2*T/3), 1:2) = 0.9;
 mux(:,3:4) = 0.9;
 mux(indt <= floor(T/2),3:4) = 1.1;
 mut=sum(mux.*beta,2);
 % override mut in case of no breaks
if nobreaks
    mut=ones(T+1,1)*4; 
end

%% generate y
if use_ldv
    rhoy=NaN(T+1,1);
    rhoy(1:floor(T/2),1)=0.2;
    rhoy(floor(T/2)+1:T+1,1)=0.4;
    if nobreaks
        rhoy=ones(T+1,1)*0.3; 
    end
    
   y0 = mut(1,1)/(1-rhoy(1,1));
   y=NaN(T+1,1);
   y(1,1) = mut(1,1) + rhoy(1,1)*y0 + sum(x(1,1:kreg).*beta(1,:),2) + tau_u*u(1,1);
   for t=2:T+1
       y(t,1) = mut(t,1) + rhoy(t,1)*y(t-1,1) + sum(x(t,1:kreg).*beta(t,:),2) + tau_u*u(t,1);
   end
else
    y = mut + sum(x(:,1:kreg).*beta,2) + tau_u*u;
end


%% assign data
% y is T+1 x 1 (+1 for forecasting)
% x is T+1 x N

Data.y=y;
Data.x=x;
Data.beta=0;
Data.kreg=kreg;


end