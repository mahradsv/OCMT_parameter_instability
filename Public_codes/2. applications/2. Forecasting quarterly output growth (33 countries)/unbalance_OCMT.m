function [ind, noadst, ind_first_stage, error]=unbalance_OCMT(y ,Z, X , p_val,delta,deltastar, maxregthreshold)

[~,N]=size(X);

if nargin<7 
    % if the number of selected regressors by OCMT exceeds maxregthreshold thresholds, this function stops and returns NaN;
    % when nargin<7, threshold is not specified, and set to N (and hence it will never be breached)
    maxregthreshold=N;
end

%% stage 1

% one by one
ts=zeros(N,1);
ind=false(N,1);
t_threshold=norminv(1-p_val/2/(N^(delta)),0,1);

for i=1:N
    %i
    set = ~isnan(X(:,i));
    Tr = sum(set);
    Xr = [X(set,i), Z(set,:)];
    yr = y(set);
 
    b=Xr\yr; % pinv(Xr'*Xr)*Xr'*y;
%             if strcmp(lastwarn,'Matrix is singular to working precision.')
%                 'here' %warning('FineId','fine');
%             end    
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
            b=Xr\yr; %pinv(Xr'*Xr)*Xr'*y;

            
            e=yr-Xr*b;
            kr=size(Xr,2);
            ve=e'*e/(Tr-kr);
            iXX=inv(Xr'*Xr); % pinv(Xr'*Xr);
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
