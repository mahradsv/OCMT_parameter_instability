load('init.mat');
[~,~,sel_set_of_experiments]=experimentID();
ext='vn_';

% define working path and filenames
path=pwd; 
matlab_results_file='/exp_'; % start of the name of xls file where selected results will be stored
matlab_results_file_all='/mcresults_all'; % name of mat file where all results are stored


% experiments
for d1=1          : idex(1)
for d2=1           : idex(2)
for d3=1           : idex(3)   
for d4=1           : idex(4) 
for d5=1           : idex(5) 
for d6=1           : idex(6)
for d7=1           : idex(7)
for d8=1           : idex(8)
    


d=[d1,d2,d3,d4,d5,d6,d7,d8];
eid=experimentID(d, nall, Tall,R);
bN=length(nall); 
bT=length(Tall); 

Rr1=initialize_results(idex,bN, bT);
Rra=repmat(Rr1,[1,1,1,1,1,1,1,1,1,1,NoEst]);

Rr1NaN=initialize_resultsNaN(idex,bN, bT);
RraNaN=repmat(Rr1NaN,[1,1,1,1,1,1,1,1,1,1,NoEst]);
if  sum(eid.no==sel_set_of_experiments)==1
     
    [eid.no, d1,d2,d3, d4]
    
    for ni=1:bNmax
        N=nall(ni);
       
        for nt=1:bTmax
            T=Tall(nt);   strcat('N=',int2str(N), ' T=',int2str(T), ' didex=', int2str(d1),',',int2str(d2),',',int2str(d3),',',int2str(d4),',',int2str(d5),',',int2str(d6))
            
            [Re1,rer]=i_r_cycle(R, NoEst);
            Re=repmat(Re1,1,NoEst);
            tms=zeros(R,1);
        d=[d1,d2,d3,d4,d5,d6,d7,d8];
        eid=experimentID(d,nall, Tall,R);
        
        file_saveM=strcat(path,matlab_results_file,ext,int2str(eid.no),'_ni',int2str(ni), '_nt',int2str(nt),'.mat');
        try
            load(file_saveM);
            tmsall(ni, nt,:)=mean(tms);
            Rra(d1,d2,d3,d4,d5,d6,d7,d8,ni,nt,:)=Rr(d1,d2,d3,d4,d5,d6,d7,d8,ni,nt,:);
        catch me
            Rra(d1,d2,d3,d4,d5,d6,d7,d8,ni,nt,:)=RraNaN(d1,d2,d3,d4,d5,d6,d7,d8,ni,nt,:);
            tmsall(ni, nt,:)=NaN; 
        end
    
        end %nt
    end %ni
 Rr=Rra;
  
     
        d=[d1,d2,d3,d4,d5,d6,d7,d8];
        eid=experimentID(d, nall, Tall,R);
        strcat('saving exp. no. ',int2str(eid.no))

        file_saveM=strcat(path,matlab_results_file,ext,int2str(eid.no),'.mat');
        save(file_saveM, 'Rr' );
  
end %if eid.no 

end %d8
end %d7
end %d6
end %d5
end %d4
end %d3
end %d2
end %d1



save_to_xls_vn



