function DM=DMtests(Forecast_errors,samplef, ind, scfe, D) 

No_methods=size(Forecast_errors,3);
DM.panel=NaN(No_methods,No_methods);
%DM.country=NaN(No_methods,No_methods,no_countries);
[a,nc]=size(D.groups);
nall=size(ind,1);
indgroups=false(nall,a);
for j=1:nall
   if ind(j,1)
       for k=1:a
            if is_in(D.codes(1,j), D.country_names(D.groups(k,:)))
                indgroups(j,k)=true;
            end
       end
   end
end
group.panel=NaN(No_methods,No_methods,a);

for i=1:No_methods
    for j=1:No_methods
        if not(i==j)
            Fea=squeeze(Forecast_errors(samplef,ind,i))'; % NxT
            Feb=squeeze(Forecast_errors(samplef,ind,j))'; % NxT
            [ DM1, DM2 ] = panelDM( Fea, Feb );
             if scfe
                 DM.panel(i,j)=DM2;
             else
                 DM.panel(i,j)=DM1;
             end
             
            
            % compute statistics for individual groups
            %   initialize results

            for k=1:a
                Fega=squeeze(Forecast_errors(samplef,indgroups(:,k),i));
                Fegb=squeeze(Forecast_errors(samplef,indgroups(:,k),j));
                [ DM1, DM2 ] = panelDM( Fea, Feb );
                if scfe
                    DM.country(i,j,k)=DM2;
                else
                    DM.country(i,j,k)=DM1;
                end
            end
           
            no_countries=size(Fea,1);
            for k=1:no_countries
                [dm1,dm2]=panelDM(Fea(k,:),Feb(k,:));
                if scfe
                    DM.country(i,j,k+a)=dm2;
                else
                    DM.country(i,j,k+a)=dm1;
                end
            end
            
        end
    end
end
        