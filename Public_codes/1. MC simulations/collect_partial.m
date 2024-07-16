function pom=collect_partial(Re)
% from initialization
pom.bmn=NaN(10,1);

R=size(Re,1); % number of MC replications

pbmisc=zeros(R,10);
for i=1:R
    pbmisc(i,:)=Re(i).bmisc';
end
% take cs average across replications
bmisc=pbmisc'*ones(R,1)/R;

% take cs average of squares across replications
bmisc2=pbmisc'*pbmisc/R;


bmn=NaN(size(bmisc));
bmn(1,1)=bmisc2(1,1); % MSFE 
bmn(2,1)=bmisc(2,1); % nvars
bmn(3:6,1)=bmisc(3:6,1); % TPR, FPR, FDR, FDR6

%% assign values
pom.bmn=bmn;
end