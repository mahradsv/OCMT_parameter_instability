%% this function saves selected summary of results from individual mat files to an xls table


xlsfile='MCresults.xlsx';

load('init.mat');
No_fileds_to_report=6;

Noexp=prod(idex(1:8)); % number of all possible experiments

[~,~,sel_set_of_experiments]=experimentID();
Results=zeros([idex,bN, bT,NoEst, No_fileds_to_report]); % initialization of the results array



% for all experiments....
for d8=1:idex(8)
 for d7=1:idex(7)
  for d6=1:idex(6)
   for d5=1:idex(5)
    for d4=1:idex(4)
     for d3=1:idex(3)   
      for d2=1:idex(2)  
       for d1=1:idex(1)
           
        d=[d1,d2,d3,d4,d5,d6,d7,d8];
        eid=experimentID(d, nall, Tall,R); % function that assigns experiment ID# (stored as eid.no)
        if sum(eid.no==sel_set_of_experiments)==1  % run the experiment eid.no only if it is selected
            disp(['loading experiment No. ',int2str(eid.no)]);
            file=strcat('exp_vn_',int2str(eid.no),'.mat') %'exp_vn1_'
            tic
            load(file);
            toc
            % now collect individual results
            for bn=1:bN
                for bt=1:bT
                    for est=1:NoEst

                        Results(d1,d2,d3,d4,d5,d6,d7,d8,bn,bt,est,1:No_fileds_to_report)=Rr(d1,d2,d3,d4,d5,d6,d7,d8,bn,bt,est).bmn(1:No_fileds_to_report);
                    end
                end %bt - T cycle
            end % bn - N cyle 
        end % if exp
        
       end %d1
      end %d2
     end %d3
    end %d4
   end %d5
  end %d6
 end %d7
end %d8

%% now report selective summary tables from Results array
disp(' saving ...')
 filename=[pwd,'\',xlsfile];   
  Excel = actxserver('Excel.Application');

        readOnly = false;
         ExcelWorkbook   =   Excel.workbooks.Open(filename,0,readOnly); 
        if ExcelWorkbook.ReadOnly ~= 0
            %This means the file is probably open in another process.
            error(message('MATLAB:xlswrite:LockedFile', filename));
        end
 
   ExcelFile.ExcelWorkbook=ExcelWorkbook;
   ExcelFile.Excel=Excel;
   ExcelFile.file=filename;

 k=0;
for d8=1:idex(8)
 for d7=1:idex(7)
  for d6=1:idex(6)
   for d5=1:idex(5)
    for d4=1:idex(4)
      for d3=1:idex(3)  
       for d2=1:idex(2)  
        for d1=1:idex(1)
   d=[d1,d2,d3,d4,d5,d6,d7,d8];    
   eid=experimentID(d, nall, Tall,R);
  
   if sum(eid.no==sel_set_of_experiments)==1  % run the experiment eid.no only if it is selected
       sheet_name=['Exp_',int2str(eid.no)]
       save_est=[1:NoEst];
       noest=size(save_est,2);
       k=k+1;
       j=0;
        for j=1:noest
            i=save_est(1,j);
                
                f1=squeeze( Results(d1,d2,d3,d4,d5,d6,d7,d8,:,:,i,1));
                f2=squeeze( Results(d1,d2,d3,d4,d5,d6,d7,d8,:,:,i,2));
                f3=squeeze( Results(d1,d2,d3,d4,d5,d6,d7,d8,:,:,i,3));
                f4=squeeze( Results(d1,d2,d3,d4,d5,d6,d7,d8,:,:,i,4));
                f5=squeeze( Results(d1,d2,d3,d4,d5,d6,d7,d8,:,:,i,5));
                f6=squeeze( Results(d1,d2,d3,d4,d5,d6,d7,d8,:,:,i,6));
                
                cr=['C',int2str(6*(j-1)+6)];
                ExcelFile.ExcelWorkbook=xlswrite_alex(ExcelFile,[f1,f2,f3,f4,f5,f6],sheet_name,cr);
                ExcelFile.ExcelWorkbook=xlswrite_alex(ExcelFile,{eid.name},sheet_name,'C2');
                method_name=method_names(weightlight,weightheavy,i);
                crn=['C',int2str(6*(j-1)+6-1)];
                ExcelFile.ExcelWorkbook=xlswrite_alex(ExcelFile,{method_name},sheet_name,crn);
            cr=['B',int2str(4+k)];
            A=cell(1,3);
            A{1,1}=''; %int2str(eid.no);
            %A{1,2}=['Exp_',int2str(eid.no)];
            A(1,2)=eid.name;
            %A(1,4:11)=eid.desc;
            ExcelFile.ExcelWorkbook=xlswrite_alex(ExcelFile,A,sheet_name,'A1');
        end
        
   end % if exp
       end %d1
      end %d2
     end %d3
    end %d4
   end %d5
  end %d6
 end %d7
end %d8

    Excel.DisplayAlerts = false;
    ExcelWorkbook.Save
    ExcelWorkbook.Close(false);
    Excel.Quit;
    
disp('All done.')