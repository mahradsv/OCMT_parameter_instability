%% initialization and some general definitions

% define working path and filenames
path=pwd; %working folder
sf='/'; % subfolder string. Choose '\' or '/' denending on the operating system
addpath glmnet_matlab

matlab_results_file=[sf,'exp_']; % start of the name of the mat file where selected results will be stored


bN=length(nall);  % choices for N
bT=length(Tall);   % choices for T;
R=2000;  % Number of replications (R) 

% weights vectors for downweighting of observations
weightlight = [1,0.995,0.99,0.985, 0.98, 0.975];
weightheavy = [1,0.99,0.98,0.97, 0.96, 0.95];
dimwl=size(weightlight,2); % dimension of the weight vector
dimwh=size(weightheavy,2); % dimension of the weight vector

rng(12345987)
ra=floor(rand(R,1)*(10^8));


%% Main body of program

tic % start timer

% intialize final results fields
nmm=dimwl+dimwh+2; % number of different weight considerations, light, heavy + 2 aves
NoEst=11*nmm; % total number of methods (9= Oracle, 2 x OCMT, Lasso, A-Lasso, Boosting, Post-Lasso, Post-A-Lasso, Post-Boosting)
% explanation on NoEst:
% 1 to nmm is for Oracle in the following order: weight light, avelight, weight heavy, ave heavy.
% nmm+1 to 2*nmm is for OCMT without downweighting in the selection stage
% 2*nmm+1 to 3*nmm is for OCMT with downweighting also in the selection stage
% 3*nmm+1 to 4*nmm is for Lasso
% 4*nmm+1 to 5*nmm is for A-Lasso
% 5*nmm+1 to 6*nmm is for Boosting with nu = 0.5
% 6*nmm+1 to 7*nmm is for Boosting with nu = 1
% 7*nmm+1 to 8*nmm is for Post-Lasso
% 8*nmm+1 to 9*nmm is for Post-A-Lasso
% 9*nmm+1 to 10*nmm is for Post-Boosting with nu = 0.5
% 10*nmm+1 to 11*nmm is for Post-Boosting with nu = 1

% See: method_name=method_names(weightlight,weightheavy,i)

%save params.mat;                   
[~,idex]= experimentID();
Rr1=initialize_results(idex,bN, bT);
Rr=repmat(Rr1,[1,1,1,1,1,1,1,1,1,1,NoEst]);


cvF=zeros(size(Tall));
toc

for d8=1:idex(8)
 for d7=1:idex(7)
  for d6=1:idex(6)
   for d5=1:idex(5)
    for d4=1:idex(4)
     for d3=1:idex(3)   
      for d2=1:idex(2)  
       for d1=1:idex(1)
           
        % determine expID
        d=[d1,d2,d3,d4,d5,d6,d7,d8];
        eid=experimentID(d, nall, Tall,R); % function that assigns experiment ID# (stored as eid.no)
        if sum(eid.no==experimentno)==1  % run the experiment eid.no only if it is selected
            
           % eid.no
           % d
                N=nall(ni);
                T=Tall(nt);   
                    % report what experiments is currently being computed
                    strcat('N=',int2str(N),', T=',int2str(T),', ExpID=',int2str(eid.no),', Name: "',eid.name{1}, '", didex=', int2str(d1),',',int2str(d2),',',int2str(d3),',',int2str(d4),',',int2str(d5),',',int2str(d6),',',int2str(d7),',',int2str(d8))
            
                    % initialize replication-results fields
                    [Re, rer]=i_r_cycle(R, NoEst);

                     tms=zeros(R,1, 'single');

                   parfor r=1:R % replication cycle (can be parfor)
 % r
                         tStart=tic;
                         warning('off');
                      %  tic
                        Res=repmat(rer,1,NoEst);
                        % generate data
                        rng(ra(r)); % initialize random sampler for a possible use in parfor cycel for r
                        simultaus=[4.65, 2.51, 7.58, 4.13, ...
                                   4.65, 2.51, 7.58, 4.13, ...
                                   4.65, 2.51, 7.58, 4.13]; % function simul_fit was used to compute values of tau_u by simulations
                        tau_u=simultaus(experimentno);

                        if d(2)==1
                            use_ldv=false;
                        else
                            use_ldv=true;
                        end
                        if d(3)==1
                            mxv=0;
                        else
                            mxv=4;
                        end
                        if d(4)==1
                            nobreaks=false;
                        else
                            nobreaks=true;
                        end
                       
                        [D]=generate_data(N,T,tau_u, use_ldv, mxv,nobreaks); % this function generates data
                     
                        %toc
                         D.weightlight=weightlight;
                         D.weightheavy=weightheavy;
                         D.nmm=nmm;
                        %'oracle '
                        %tic
                        [Res(1:nmm)] = estim_o(D,use_ldv); % Oracle model
                        %toc
                        sel_weight=false;
                        %'OCMT'
                        %tic
                        [Res(nmm+1:2*nmm)] = estim_ocmt(D,sel_weight,use_ldv); % OCMT model without downweighting in the selection stage
                        sel_weight=true;
                        [Res(2*nmm+1:3*nmm)] = estim_ocmt(D,sel_weight,use_ldv); % OCMT model with downweighting in the selection stage
                        %toc
                       
                        % Lasso estimations
                        %'lasso'
                        %tic
                        [Res(3*nmm+1:4*nmm), Res(4*nmm+1:5*nmm)]= estim_Lasso(D,use_ldv); %Lasso and A-Lasso
                        %toc
                     
                        % Boosting with nu = 0.1
                        %tic
                        v = 0.5;
                        [Res(5*nmm+1:6*nmm)]= estim_boosting(D,use_ldv,v); % Boosting with nu = 0.5
                        %toc
                        
                        % Boosting with nu = 1
                        %tic
                        v = 1;
                        [Res(6*nmm+1:7*nmm)]= estim_boosting(D,use_ldv,v); % Boosting with nu = 1
                        %toc
                    
                        % Post Lasso and Post A-LASSO
                        %tic
                        [Res(7*nmm+1:8*nmm), Res(8*nmm+1:9*nmm)]= estim_post_Lasso(D,use_ldv); %Post Lasso and Post A-Lasso
                        %toc
                        
                        
                        % Post Boosting with nu = 0.1
                        %tic
                        v = 0.5;
                        [Res(9*nmm+1:10*nmm)]= estim_post_boosting(D,use_ldv,v); % Boosting with nu = 0.5
                        %toc
                        
                        % Post Boosting with nu = 1
                        %tic
                        v = 1;
                        [Res(10*nmm+1:11*nmm)]= estim_post_boosting(D,use_ldv,v); % Boosting with nu = 1
                        %toc
                        
                        Re(r,:) = Res;
                        tms(r,1) = toc(tStart);
                        %toc
                    end % r - repetition cycle

                    % collect individual test results
                    for est=1:NoEst
                        Rr(d1,d2,d3,d4,d5,d6,d7,d8,ni,nt,est)=	 collect_partial(Re(:,est));
                    end
clear Re; % to save space                    
 
            toc % timer
            % save individual experiments
            strcat('saving exp. no. ',int2str(eid.no), '_ni',int2str(ni), '_nt',int2str(nt) )
            ext='vn_';
            file_saveM=strcat(path,matlab_results_file,ext,int2str(eid.no),'_ni',int2str(ni), '_nt',int2str(nt),'.mat');
            save(file_saveM, 'Rr', 'tms');
                save('init.mat') 
        end %if sum(eid.no==experiments)==1 
  
       end %d1
      end %d2
     end %d3
    end %d4
   end %d5
  end %d6
 end %d7
end %d8
toc %timer

'Computations are done and saved as mat files.';

%save_to_xls_vn1


