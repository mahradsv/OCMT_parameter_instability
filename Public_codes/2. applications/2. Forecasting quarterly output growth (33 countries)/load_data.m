function [D]=load_data(input_data_file, a_differencing)

T=151; N=33;   % time and country dimensions 
Sheet_names={'y','Dp','eq', 'ep', 'r', 'lr', 'ys', 'Dps', 'eqs', 'rs', 'lrs'};
no_sn=size(Sheet_names,2);
missing_value_code=123456789;
X=[]; codes=[];
for i=1:no_sn
    [A, cn]=xlsread(input_data_file,Sheet_names{i},'B1:AH152'); 
        % cn is 1 x 33 cell of country names
        % A is 151 x 33 matrix of y data (T=151 from 1979Q2 to 2016Q4, and N=33 countries)
        
        A(A==missing_value_code)=NaN; % replace missing values with NaNs    
        Ni=size(A,2);
        
    if strcmp(Sheet_names(i),'y') % add output growth
        dA=A(2:end,:)-A(1:end-1,:);
        X=[X,dA];
        vn=repmat(Sheet_names(i),1,Ni);
        acv=[cn;vn];
        codes=[codes,acv];
    end
    if strcmp(Sheet_names(i),'ys') % add foreign output growth
        dA=A(2:end,:)-A(1:end-1,:);
        X=[X,dA];
        vn=repmat(Sheet_names(i),1,Ni);
        acv=[cn;vn];
        codes=[codes,acv];
    end
    if strcmp(Sheet_names(i),'eq')
       %A(1,:)=[]; % delete first observation due to dy above
       X_eq=A(2:end,:)-A(1:end-1,:); % inflation - to be used later (not included in X directly)
       vn=repmat({'deq-dpi'},1,Ni);
       codes_eqpi=[cn;vn];
    end
    if strcmp(Sheet_names(i),'eqs')
       %A(1,:)=[]; % delete first observation due to dy above
       X_eqs=A(2:end,:)-A(1:end-1,:); % inflation - to be used later (not included in X directly)
       vn=repmat({'deqs-dpis'},1,Ni);
       codes_eqpis=[cn;vn];
    end
    
    if strcmp(Sheet_names(i),'Dp')
       %A(1,:)=[]; % delete first observation due to dy above 
       X_pi=A(2:end,:)-A(1:end-1,:); % inflation - to be used later (not included in X directly)
    end
    if strcmp(Sheet_names(i),'Dps')
       %A(1,:)=[]; % delete first observation due to dy above 
       X_pis=A(2:end,:)-A(1:end-1,:); % inflation - to be used later (not included in X directly)
    end
    if strcmp(Sheet_names(i),'r')
       %A(1,:)=[]; % delete first observation due to dy above
       X_r=A(2:end,:)-A(1:end-1,:);
       vn=repmat({'dr-dpi'},1,Ni);
       codes_rpi=[cn;vn];
    end
    if strcmp(Sheet_names(i),'rs')
       %A(1,:)=[]; % delete first observation due to dy above 
       X_rs=A(2:end,:)-A(1:end-1,:);
       vn=repmat({'drs-dpis'},1,Ni);
       codes_rpis=[cn;vn];
    end
    if strcmp(Sheet_names(i),'lr')
       %A(1,:)=[]; % delete first observation due to dy above 
       X_lr=A(2:end,:)-A(1:end-1,:);
       vn=repmat({'dlr-dr'},1,Ni);
       codes_rlr=[cn;vn];
    end
    if strcmp(Sheet_names(i),'lrs')
       %A(1,:)=[]; % delete first observation due to dy above 
       X_lrs=A(2:end,:)-A(1:end-1,:);
       vn=repmat({'dlrs-drs'},1,Ni);
       codes_rlrs=[cn;vn];
    end

end


% load time periods names
 [~, tp]=xlsread(input_data_file,Sheet_names{i},'A2:AH152'); 


% add linear combinations of variables
    %eq-pi
    X=[X,X_eq-X_pi];
    codes=[codes,codes_eqpi];
    X=[X,X_eqs-X_pis];
    codes=[codes,codes_eqpis];
    %r-pi
    X=[X,X_r-X_pi];
    codes=[codes,codes_rpi];
    X=[X,X_rs-X_pis];
    codes=[codes,codes_rpis];
    %spread lr-r
    X=[X,X_lr-X_r];
    codes=[codes,codes_rlr];
    X=[X,X_lrs-X_rs];
    codes=[codes,codes_rlrs];

% delete NaNs (missing values)
missing_values_ind=isnan(X(1,:));
X(:,missing_values_ind)=[];
codes(:,missing_values_ind)=[];


% % load oil and other global variables
%  sheet='poil';
%  [x, vd]=xlsread(input_data_file,sheet,'B1:AH152'); 
%  X=[X,x];
%  acv={'world';'poil'};
%  codes=[codes,acv];
%  
%  sheet='pmat';
%  [x, vd]=xlsread(input_data_file,sheet,'B1:AH152'); 
%  X=[X,x];
%  acv={'world';'pmat'};
%  codes=[codes,acv];
%  
%  sheet='pmetal';
%  [x, vd]=xlsread(input_data_file,sheet,'B1:AH152'); 
%  X=[X,x];
%  acv={'world';'pmetal'};
%  codes=[codes,acv];
 

% delete missing data with value 123456789
missing=X(1,:)==123456789;
X=X(:,not(missing));
codes=codes(:,not(missing));

%Take 4 - sums
sh=4; 
if a_differencing
    hsX=zeros(size(X(sh:end,:)));
    for j=0:sh-1
        hsX=hsX+X(1+j:end-sh+j+1,:); 
    end
    T=T-sh; % sample size after hsums
    tp(1:sh)=[];
    FX=[X(sh:end,:),hsX];
    hcodes=codes;
    for i=1:size(codes,2)
        hcodes{2,i}=['a_',codes{2,i}];
    end
    codes=[codes, hcodes];
else
    FX=[X];
    tp(1)=[];
    T=T-1; % due to dy
end

% add constant codes 999,999
FX=[FX, ones(T,1)];
cconst=[{'deterministics'};{'constant'}];
codes=[codes,cconst];

maxlag=2; % max lag considered
% add lags
Xo=FX;
FX=[];
codes0=codes; [a,b]=size(codes);
codes=cell(a+1,b*(maxlag+1));
for l=0:maxlag
    FX=[FX,Xo(maxlag+1-l:T-l,:)]; % lag l
    codes(1:a,l*b+1:b*(l+1))=codes0;
    codes(a+1,l*b+1:b*(l+1))={['lag',int2str(l)]};
end
T=T-maxlag; % new effective T after lags are taken into account
tp(1:maxlag)=[];


for i=0:maxlag
   lagorders{i+1}=['lag',int2str(i)];
end


% collect all relevant variables in Data output structure
D.T=T;
D.N=N;
D.X=FX;
D.codes=codes;
D.Sheet_names=Sheet_names;
D.maxlag=maxlag;
D.lagorders=lagorders;
D.time_periods_names=tp;

% define list of country names and subgroups
[A,B]=xlsread(input_data_file,'country groups','B1:AH4'); 

D.country_names=B; 
D.groups=A;


return
