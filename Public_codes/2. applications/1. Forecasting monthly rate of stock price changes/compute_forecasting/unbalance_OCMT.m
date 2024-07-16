function [ind, noadst, ind_first_stage, error]=unbalance_OCMT(y, Z, X , p_val,delta,deltastar,weight,intercept,maxregthreshold)

% weight: It can be a vector of weights on observations or a scalar showing the exponantial downweighting parameter lambda
[T,N]=size(X);

if nargin < 7
    maxregthreshold=N;
    weight = 1;
    intercept = true;
end
if nargin < 8
    maxregthreshold=N;
    intercept = true;
end
if nargin<9 
    % if the number of selected regressors by OCMT exceeds maxregthreshold thresholds, this function stops and returns NaN;
    % when nargin<7, threshold is not specified, and set to N (and hence it will never be breached)
    maxregthreshold=N;
end


if size(weight,1)==1
    w = weight;
    X = w.^([sum(T)-1:-1:0]').* X;
    y = w.^([sum(T)-1:-1:0]').* y;
    if ~isempty(Z)
        Z = w.^([sum(T)-1:-1:0]').* Z;
    end
else
    w = weight;
    X = w.* X;
    y = w.* y;
    if ~isempty(Z)
        Z = w.* Z;
    end
end

if intercept
    Z = [ones(T,1),Z]; % add intercept
end
%% stage 1

% one by one
ts=zeros(N,1);
ind=false(N,1);
t_threshold=norminv(1-p_val/2/(N^(delta)),0,1);

for i=1:N
    set = ~isnan(X(:,i));
    Tr = sum(set);
    Xr = [X(set,i), Z(set,:)];
    yr = y(set);
    b=Xr\yr; % pinv(Xr'*Xr)*Xr'*y;
    e=yr-Xr*b;
    kr=size(Xr,2);
    ve=e'*e/(Tr-kr);
    App=inv(Xr'*Xr); %pinv(Xr'*Xr);
    seb=(App(1,1)*ve)^0.5;
    ts(i,1)=abs(b(1))/seb;
    
    ind(i,1)=ts(i,1)>t_threshold;
end

noadst=0; 

if sum(ind)>maxregthreshold
    do_additional=false;
    error = 1;
    ind=NaN(N,1);
else
    error = 0;
    if sum(ind)==0
        do_additional=false;
    else
        do_additional=true;
    end
end

ind_first_stage=ind;
%% now higher stages (if any)

t_threshold=norminv(1-p_val/2/(N^(deltastar)),0,1);

while do_additional
    ind0=ind;
    indb=false(N,1);
    set0 = sum(isnan(X(:,ind0)),2)==0;
    for i=1:N
        if ind0(i,1)==0
            
            Xr=[X(set0,i), X(set0,ind0), Z(set0,:)];
            yr = y(set0);
            set = ~isnan(X(set0,i));
            Tr = sum(set);
            Xr = Xr(set,:);
            yr = yr(set);
            b=pinv(Xr'*Xr)*Xr'*yr; %Xr\yr;
            e=yr-Xr*b;
            kr=size(Xr,2);
            ve=e'*e/(Tr-kr);
            iXX= pinv(Xr'*Xr); %inv(Xr'*Xr);
            seb=(iXX(1,1)*ve)^0.5;
            ts(i,1)=abs(b(1))/seb;

            indb(i,1)=ts(i,1)>t_threshold;
        end
    end
    ind=ind0 | indb;
    if sum(ind)>maxregthreshold
        error = 1;
        do_additional=false;
        ind=NaN(N,1);
    else
        error = 0;
        do_additional=sum(indb)>0;
    end
    if do_additional
        noadst=noadst+1;
    end
end

end 
