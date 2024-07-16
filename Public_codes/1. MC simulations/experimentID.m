function [eid, idex, sel_set_of_experiments, selexpnames_short,selexpnames_long ]=...
            experimentID(d, Ns, Ts,R)       
% This function provides experiment definitions, and assigns experiment IDs. 
% there are two options how to call this function:
% 1 - without input parametrs (eid is returned as NaN)
% 2 - with all input parameters (eid collects info on specific selected experiment)

%% definitions
idex=[2,2,2,2,1,1,1,1]; % set maximum numbers for the experiment identifiers idex=(id1max,id2max...,id8max);
% explanation for experiment identifier vector (id1,id2,...,id8):
% id1 for R squared        (1) low (30%)                           (2) high (50%) 
% id2 for rhoy_t choice    (1) zero (static)                       (2) nonzero (dynamic)    
% id3 for m                (1) zero                                (2) 4
% id4 for breaks choice     (1) with breaks in slopes and intercepts (2) no breaks baseline
% id5 for ... (unused)     (1) (default)
% id6 for ... (unused)     (1) (default)
% id7 for ... (unused)     (1) (default)
% id8 for ... (unused)     (1) (default)

%id_descriptions
d1_desc{1}='low Rsquared';    d1_desc{2}='high Rsquared';
d2_desc{1}='static case (rho_yt=0)'; d2_desc{2}='dynamic case (rho_yt is nonzero)';
d3_desc{1}='m=0'; d3_desc{2}='m=4';
d4_desc{1}='breaks in slopes and intercepts';  d4_desc{2}='no breaks baseline';
d5_desc{1}='';
d6_desc{1}='';
d7_desc{1}='';
d8_desc{1}='';

% Experiment ID number is computed from (id1,id2,...,id8) as follows:
%   expID= id1 + (id2-1)*id1max + (id3-1)*(id1max*id2max) +  (id4-1)*(id1max*id2max*id3max) + etc.

sel_set_of_experiments=[1:12]; % set of selected experiments (might be a subset of all combinations in id1-id8)

for i=1:size(sel_set_of_experiments,2)
    expNo=(sel_set_of_experiments(i));
    dd=einv(expNo, idex);
    selexpnames_short{i}=['Exp',int2str(expNo)]; 
    selexpnames_long{i,1}=['Exp',int2str(expNo),': using ',d1_desc{dd(1)}, ', ',d2_desc{dd(2)}, ', ',d3_desc{dd(3)},', ',d4_desc{dd(4)}];
end
if nargin==0
    eid=NaN;
else

eid.no=d(1) +(d(2)-1)*idex(1)+(d(3)-1)*prod(idex(1:2))+ ...
        (d(4)-1)*prod(idex(1:3))+(d(5)-1)*prod(idex(1:4))+...
        (d(6)-1)*prod(idex(1:5))+(d(7)-1)*prod(idex(1:6))+...
        (d(8)-1)*prod(idex(1:7)); % experiment ID no.

eid.desc=cell(1,8); % description of specific experiments can go here
eid.Ns=Ns;
eid.Ts=Ts;
eid.R=R;
eid.name=cell(1,1);

% % descriptions
% 
% 
%     eid.desc{1,1}=d1_desc{d(i)};
%     eid.desc{1,2}=d2_desc{d(i)};
%     eid.desc{1,3}=d3_desc{d(i)};
%     eid.desc{1,4}=d4_desc{d(i)};
%     eid.desc{1,5}=d5_desc{d(i)};
%     eid.desc{1,6}=d6_desc{d(i)};
%     eid.desc{1,7}=d7_desc{d(i)};
%     eid.desc{1,8}=d8_desc{d(i)};

% selected names
if sum(eid.no==sel_set_of_experiments)>0
    eid.name=selexpnames_long(eid.no);
else
    eid.name={['not selected to be computed']};
end

end % function