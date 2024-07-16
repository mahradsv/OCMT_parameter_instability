%% this procedure computes tau_u by simulations
clc
clear

T= 500;
N = 4;
R = 5;
grid = 1:0.01:15;
n_grid = length(grid);
Rs = NaN(R,n_grid);
meanRs = NaN(2,n_grid); % static and dynamic
nobreaks = false; mxv = 0;                      
for z = 1:2
    if z==1
        use_ldv = false;
    else
        use_ldv = true;
    end
                        
parfor r=1:R  
  rsj=zeros(1,n_grid);
  for j=1:n_grid
   rng(1234+r);
   Data=generate_data(N,T,grid(j), use_ldv, mxv,nobreaks); 
   
   if use_ldv
      X = [ones(T-1,1), Data.x(2:T,1:Data.kreg), Data.y(1:T-1,1)];  
      y = Data.y(2:T,1); 
   else
      X=[ones(T,1), Data.x(1:T,1:Data.kreg)];  
      y=Data.y(1:T,1);
   end
   
   b=X\y;
   res=y-X*b;
   fit=X*b;
   ydm=y-mean(y);
   fitdm=fit-mean(fit);
   sstot=ydm'*ydm;
   ssreg=fitdm'*fitdm;
   ssres=res'*res;
   rsj(1,j)=ssreg/sstot;
  end
  Rs(r,:)=rsj;
end
meanRs(z,:) = mean(Rs);
end

low_Rstarget = 0.2;

[value, idx] = min(abs(meanRs(1,:) - low_Rstarget));
[grid(idx), value, meanRs(1,idx), low_Rstarget]
static_low_tau_u = grid(idx);
static_low_Rs_break = meanRs(1,idx);

[value, idx] = min(abs(meanRs(2,:) - low_Rstarget));
[grid(idx), value, meanRs(2,idx), low_Rstarget]
dynamic_low_tau_u = grid(idx);
dynamic_low_Rs_break = meanRs(2,idx);

high_Rstarget = 0.5;

[value, idx] = min(abs(meanRs(1,:) - high_Rstarget));
[grid(idx), value, meanRs(1,idx), high_Rstarget]
static_high_tau_u = grid(idx);
static_high_Rs_break = meanRs(1,idx);

[value, idx] = min(abs(meanRs(2,:) - high_Rstarget));
[grid(idx), value,meanRs(2,idx),high_Rstarget]
dynamic_high_tau_u = grid(idx);
dynamic_high_Rs_break = meanRs(2,idx);

nobreaks = true; mxv = 0;
Rs = NaN(R,1);
meanRs = NaN(2); % static and dynamic
for z = 1:2
    if z==1
        use_ldv = false;
        tau = static_high_tau_u;
    else
        use_ldv = true;
        tau = dynamic_high_tau_u;
    end
    
    parfor r=1:R
        rng(1234+r);
        Data=generate_data(N,T,tau, use_ldv, mxv,nobreaks);
        
        if use_ldv
            X = [ones(T-1,1), Data.x(2:T,1:Data.kreg), Data.y(1:T-1,1)];
            y = Data.y(2:T,1);
        else
            X=[ones(T,1), Data.x(1:T,1:Data.kreg)];
            y=Data.y(1:T,1);
        end
        
        b=X\y;
        res=y-X*b;
        fit=X*b;
        ydm=y-mean(y);
        fitdm=fit-mean(fit);
        sstot=ydm'*ydm;
        ssreg=fitdm'*fitdm;
        ssres=res'*res;
        Rs(r)=ssreg/sstot
    end
    meanRs(z) = mean(Rs);
end
static_high_Rs_nobreak = meanRs(1);
dynamic_high_Rs_nobreak = meanRs(2);

nobreaks = true; mxv = 0;
Rs = NaN(R,1);
meanRs = NaN(2); % static and dynamic
for z = 1:2
    if z==1
        use_ldv = false;
        tau = static_low_tau_u;
    else
        use_ldv = true;
        tau = dynamic_low_tau_u;
    end
    
    parfor r=1:R
        rng(1234+r);
        Data=generate_data(N,T,tau, use_ldv, mxv,nobreaks);
        
        if use_ldv
            X = [ones(T-1,1), Data.x(2:T,1:Data.kreg), Data.y(1:T-1,1)];
            y = Data.y(2:T,1);
        else
            X=[ones(T,1), Data.x(1:T,1:Data.kreg)];
            y=Data.y(1:T,1);
        end
        
        b=X\y;
        res=y-X*b;
        fit=X*b;
        ydm=y-mean(y);
        fitdm=fit-mean(fit);
        sstot=ydm'*ydm;
        ssreg=fitdm'*fitdm;
        ssres=res'*res;
        Rs(r,:)=ssreg/sstot
    end
    meanRs(z) = mean(Rs);
end
static_low_Rs_nobreak = meanRs(1);
dynamic_low_Rs_nobreak = meanRs(2);

save('tau_u.mat','static_low_tau_u',...
    'dynamic_low_tau_u',...
    'static_high_tau_u',...
    'dynamic_high_tau_u',...
    'low_Rstarget',...
    'high_Rstarget',...
    'static_low_Rs_nobreak',...
    'dynamic_low_Rs_nobreak',...
    'static_high_Rs_nobreak',...
    'dynamic_high_Rs_nobreak',...
    'static_low_Rs_break',...
    'dynamic_low_Rs_break',...
    'static_high_Rs_break',...
    'dynamic_high_Rs_break');

 simultaus=ones(3,1)*[static_low_tau_u, static_high_tau_u, dynamic_low_tau_u, dynamic_high_tau_u]

