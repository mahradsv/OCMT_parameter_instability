function [D]=load_data(input_data_file, h)

T=59; N=1;   % time and country dimensions 
Sheet_names={'GDP_H1_test_K_4'};
no_sn=size(Sheet_names,2);
missing_value_code=123456789;
X=[]; codes=[];
for i=1:no_sn
    [A, cn]=xlsread(input_data_file,Sheet_names{i},'B1:AC60'); 
        % cn is 1 x 33 cell of country names
        % A is 151 x 33 matrix of y data (T=151 from 1979Q2 to 2016Q4, and N=33 countries)
    % replace missing values with NaNs
    A(A==missing_value_code)=NaN;
    
    X=[X,A];
    Ni=size(A,2);
    vn=repmat({'v'},size(cn)); vn(1,26:28)=cn(1,26:28);
    acv=[cn;vn];
    codes=[codes,acv];
    


end

% load time periods names
 [tp]=xlsread(input_data_file,Sheet_names{i},'A2:A60'); 



% delete NaNs (missing values)
missing_values_ind=isnan(X(1,:));
X(:,missing_values_ind)=[];
codes(:,missing_values_ind)=[];


 

FX=X;

% add constant codes 999,999
FX=[FX, ones(T,1)];
cconst=[{'deterministics'};{'constant'}];
codes=[codes,cconst];

maxlag=0; % max lag considered
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
%[A,B]=xlsread(input_data_file,'country groups','B1:AH4'); 

D.country_names={'Realization'}; 
D.groups={};


return
