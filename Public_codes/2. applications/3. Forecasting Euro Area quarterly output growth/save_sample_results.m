function save_sample_results(savefile,savesheet, D, Forecast_errors, Forecast_values, variables_to_save, Nopredictors, samplef, No_methods, Rsq, SVs, Method_names, horizon)




 NoGroups=size(D.groups,1);
 Te=size(samplef,1);
 nvs=size(D.codes,2);
 
 
 report_variable_selection=strcmp(savesheet,'full_sample');
 
 if report_variable_selection 
   % now report variable selection resultsresults
   
   % first open file
    % if file does not exists, create it
    Excel = actxserver('Excel.Application');
    
    fileNotCreated = ~exist(savefile.selvars,'file');
    if fileNotCreated
            ExcelWorkbook = Excel.workbooks.Add;
            xlFormat = 51;
            ExcelWorkbook.SaveAs([pwd,'\',savefile.selvars], xlFormat);
            ExcelWorkbook.Close(false);
     end
        
   
   readOnly = false;
   ExcelWorkbook   =   Excel.workbooks.Open([pwd,'\',savefile.selvars],0,readOnly); 
   if ExcelWorkbook.ReadOnly ~= 0
            %This means the file is probably open in another process.
      error(message('MATLAB:xlswrite:LockedFile', [pwd,'\',savefile.selvars]));
   end
 
   ExcelFile.ExcelWorkbook=ExcelWorkbook;
   ExcelFile.Excel=Excel;
   ExcelFile.file=[pwd,'\',savefile.selvars];
    
   
   
   
   selected_methods_to_report=false(size(SVs,1),1);
   selected_methods_to_report([1,5],1)=true; % CS, 
   selected_methods_to_report(8,1)=true; % OCMT,
   %selected_methods_to_report(15:20,1)=true; % OCMTb - sel downweighting, all lambdas
   selected_methods_to_report(64,1)=true; % Lasso, all lambdas
   %selected_methods_to_report(141,1)=true; % ALasso, all lambdas
   
   smnames=Method_names(selected_methods_to_report,1);
   
   SVsel=SVs(selected_methods_to_report, samplef);
 for i=1:size(variables_to_save,2) 
     vf=variables_to_save{i};
     
     vcode=[{' '};{vf}; {'lag0'}];
     ind_compare=[false,true,true];
     ind=fvi(vcode, D.codes, ind_compare);
     %no_countr=sum(ind);
    
%      nv=size(D.codes,1);
%      pom=[1:nv];
      fcodes=D.codes(:,ind);
      countries=fcodes(1,:);

      for j=1:sum(ind)
          vfsheet=[variables_to_save{i},'_',countries{j}];
          %find forecasting var
          vcode=[countries{j};{vf}; {'lag0'}]; ind_compare=[true,true,true];
          [~,fvp]=fvi(vcode, fcodes, ind_compare);
          pos=1;
          for k=1:sum(selected_methods_to_report)
              
              % find the set of selected covariates (all time periods)
              sel_vars=false(1,nvs);
              for t=1:Te
                  svs=SVsel{k,t};
                  sel_vars=sel_vars | svs.sv(fvp,:);
                  
              end
              codes_selected=D.codes(:,sel_vars);
              no_cs=size(codes_selected,2);
              SelV=cell(no_cs+2,Te+3);
              % heading
            %  ['saving method',smnames{k,1}]
              SelV(1,1)={['Variables used in the forecasting regression for method ',smnames{k,1}]}; 
              % evaluating time sample
              SelV(2,4:Te+3)=num2cell(D.time_periods_names(samplef,1)');
              % set of variables
              SelV(2,1)={'country'}; SelV(2,2)={'variable type'}; SelV(2,3)={'lag'};
              SelV(3:end,1:3)=codes_selected';
              % individual coefficients
              for t=1:Te
%                   if t==12
%                       'here'
%                   end
                  svs=SVsel{k,t};
                  sel_vars=D.codes(:,svs.sv(fvp,:));
                  sel_coefs=svs.coefs(fvp,svs.sv(fvp,:));
                  nv=size(sel_vars,2);
                  for jj=1:nv
                     code_find= sel_vars(:,jj);
                     ind_compare=[true,true,true];
                     [~,fvj]=fvi(code_find, codes_selected, ind_compare);
                     if pos==[]
                         'error'
                         dbstop
                     end
                    SelV(2+fvj,3+t)={sel_coefs(jj)};
                  end
                  
              end
              
              
              col_report='B';
              cr=[col_report,int2str(pos)];
              ExcelFile.ExcelWorkbook=xlswrite_alex(ExcelFile,SelV,vfsheet, cr );
              pos=pos+1+size(SelV,1);
          end
      end
 end
    % close the file
    ExcelWorkbook.Save
    ExcelWorkbook.Close(false);
    Excel.Quit;
 
 end % report_variable_selection
 
 
 
 
 
 
 
 for i=1:size(variables_to_save,2) 
     vf=variables_to_save{i};
     vfsheet=savesheet; %[variables_to_save{i},' ',savesheet];
    vcode=[{' '};{vf}; {'lag0'}];
    ind_compare=[false,true,true];
    ind=fvi(vcode, D.codes, ind_compare);
%     if horizon>1
        scfe=true; % allow for serial correlation in the computation of panel DM test
%     else
%         scfe=false;
%     end
    [Stats, DM]=report_forecasts(D, Forecast_errors, Forecast_values, ind, samplef, Nopredictors, Rsq, scfe, report_variable_selection, savefile);
    
   % savestats(Stats, savefile, vf)

   cn=D.country_names; % country names - contains all countries even if data is missing
   no_ac=sum(ind); % number of available countries
   cna=D.codes(1,ind);
   Abias=NaN(No_methods, size(cn,2));
   Amsfe=NaN(No_methods, size(cn,2));
   Amae=NaN(No_methods, size(cn,2));
   Amda=NaN(No_methods, size(cn,2));
   %Amda2=NaN(No_methods, size(cn,2));


   for m=1:No_methods
       for j=1:NoGroups
           cp=j;
            Abias(m,cp)=Stats{m}.bias(1,j);
            Amsfe(m,cp)=Stats{m}.MSE(1,j);
            Amae(m,cp)=Stats{m}.MAE(1,j);
            Amda(m,cp)=Stats{m}.MDA(1,j);
            Anpred_mean(m,cp)=Stats{m}.npred.mean(1,j);
            Anpred_median(m,cp)=Stats{m}.npred.median(1,j);
            Anpred_max(m,cp)=Stats{m}.npred.max(1,j);
            Anpred_min(m,cp)=Stats{m}.npred.min(1,j);
            Arsq(m,cp)=Stats{m}.rsquared(1,j);
            Arsqout(m,cp)=Stats{m}.rsquaredout(1,j);
            % group PDM
            
            %DMpom=DMtests(Forecast_errors,samplef, ind, scfe) ;
            
       end
       for j=1:no_ac
           [~,cp]=fv(cna(j),cn);
           cp=cp+NoGroups;
            Abias(m,cp)=Stats{m}.bias(1,j+NoGroups);
            Amsfe(m,cp)=Stats{m}.MSE(1,j+NoGroups);
            Amae(m,cp)=Stats{m}.MAE(1,j+NoGroups);
            Amda(m,cp)=Stats{m}.MDA(1,j+NoGroups);
            Anpred_mean(m,cp)=Stats{m}.npred.mean(1,j+NoGroups);
            Anpred_median(m,cp)=Stats{m}.npred.median(1,j+NoGroups);
            Anpred_max(m,cp)=Stats{m}.npred.max(1,j+NoGroups);
            Anpred_min(m,cp)=Stats{m}.npred.min(1,j+NoGroups);
            Arsq(m,cp)=Stats{m}.rsquared(1,j+NoGroups);
            Arsqout(m,cp)=Stats{m}.rsquaredout(1,j+NoGroups);

            
       end
   end
   ['saving results for variable ',vfsheet, ' to ', savefile.main]    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   cr='E5';
   xlswrite(savefile.main,Abias*100,vfsheet,cr);
   cr='E160';
   xlswrite(savefile.main,Amsfe*10000,vfsheet,cr);
   cr='E315';
   xlswrite(savefile.main,Amae*100,vfsheet,cr);
   cr='E470';
   xlswrite(savefile.main,Amda,vfsheet,cr);
   cr='E625';
   xlswrite(savefile.main,Arsq,vfsheet,cr);
   cr='E1714';
   xlswrite(savefile.main,Arsqout,vfsheet,cr);
   
   benchmark=1; % for country-speific DM tests
   cr='E780';
   xlswrite(savefile.main,squeeze(DM.country(:,benchmark,:)),vfsheet,cr);
   cr='E939';
   xlswrite(savefile.main,DM.panel,vfsheet,cr);



   cr='E1091'; % to save number of predictors
   xlswrite(savefile.main,Anpred_mean,vfsheet,cr);
   cr='E1247'; % to save number of predictors
   xlswrite(savefile.main,Anpred_median,vfsheet,cr);
   cr='E1403'; % to save number of predictors
   xlswrite(savefile.main,Anpred_min,vfsheet,cr);   
   cr='E1559'; % to save number of predictors
   xlswrite(savefile.main,Anpred_max,vfsheet,cr);    
   
  

 end










return