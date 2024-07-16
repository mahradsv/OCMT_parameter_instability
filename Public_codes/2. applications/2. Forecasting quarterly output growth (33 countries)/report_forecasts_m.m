function statsm= report_forecasts_m(D, Forecast_errors, Forecast_values,ind, samplef,i, Nopredictors, Rsq)

Fe=squeeze(Forecast_errors(samplef,ind,i)); % forecast errors
Fv=squeeze(Forecast_values(samplef,ind,i)); % forecast values
Av=squeeze(D.X(samplef,ind));               % actual values
Ava=squeeze(D.X(:,ind));               % actual values
Avm=NaN(size(Av));
for k=1:size(samplef,1)
   Te=samplef(k);
   Avm(k,:)=mean(Ava(1:Te-1,:));
end



Np=squeeze(Nopredictors(samplef,ind,i));    % no_predictors
Rs=squeeze(Rsq(samplef,ind,i));
% find subgroups
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

% compute statistics for individual groups
%   initialize results
    group.bias=NaN(1,a);
    
for k=1:a
    Feg=squeeze(Forecast_errors(samplef,indgroups(:,k),i));
    Fvg=squeeze(Forecast_values(samplef,indgroups(:,k),i));
    Avg=squeeze(D.X(samplef,indgroups(:,k)));
    Avga=squeeze(D.X(:,indgroups(:,k)));   
    Avgm=NaN(size(Avg));
    for kk=1:size(samplef,1)
        Te=samplef(kk);
        Avgm(kk,:)=mean(Avga(1:Te-1,:));
    end

    Npg=squeeze(Nopredictors(samplef,indgroups(:,k),i));
    Rsg=squeeze(Rsq(samplef,indgroups(:,k),i));
    feg=reshape(Feg,[],1);
    fvg=reshape(Fvg,[],1);
    avg=reshape(Avg,[],1);
    avgm=reshape(Avgm,[],1);
    npg=reshape(Npg,[],1);
    rsg=reshape(Rsg,[],1);
    
    g= fcststats(feg, npg, fvg, avg, rsg,avgm );
    group.bias(1,k)=g.bias;
    group.MSE(1,k)=g.MSE;
    group.MAE(1,k)=g.MAE;
    group.mda(1,k)=g.mda;
    group.pt(1,k)=g.pt;
    group.npred.mean(1,k)=g.npred.mean;
    group.npred.median(1,k)=g.npred.median;
    if isnan(g.npred.mean)
        group.npred.min(1,k)=NaN;
        group.npred.max(1,k)=NaN;   
    else 
        group.npred.min(1,k)=g.npred.min;
        group.npred.max(1,k)=g.npred.max;
    end
    group.rsquared(1,k)=g.rsquared;
    group.rsquaredout(1,k)=g.rsquaredout;
end

statsm.bias=[group.bias, mean(Fe,1)];
statsm.MSE=[group.MSE, mean(Fe.^2,1)];
statsm.MAE=[group.MAE, mean(abs(Fe),1)];
statsm.npred.mean=[group.npred.mean,mean(Np,1)];
statsm.npred.median=[group.npred.median,median(Np,1)];
statsm.npred.min=[group.npred.min,min(Np,[],1)];
statsm.npred.max=[group.npred.max,max(Np,[],1)];
statsm.rsquared=[group.rsquared,mean(Rs,1)];
rsquaredout=NaN(1,size(Fe,2));
for i=1:size(Fe,2)
    avs=Av(:,i); avsm=Avm(:,i); 
    ye=avs-avsm;
    fes=Fe(:,i); 
    rsquaredout(1,i)=1-(fes'*fes)/(ye'*ye);
end
statsm.rsquaredout=[group.rsquaredout,rsquaredout];



% MDA
% MDA1 on outcomes
d=squeeze(D.X(samplef,ind));
df=squeeze(Forecast_values(samplef,ind,i));
statsm.MDA=[group.mda, 100*mean((d .* df > 0) + 0.5*(df==0) + 0.5*(d == 0))];

cpt=countryPTs(Av,Fv);
statsm.pt=[group.pt, cpt];

% % MDA2 on change compared with last period
% lag_sample=samplef-1;
% d=sign( squeeze(D.X(samplef,ind))- squeeze(D.X(lag_sample,ind)) );
% df=squeeze(Forecast_values(samplef,ind,i)-squeeze(D.X(lag_sample,ind)) );
% statsm.MDA2=100*mean((d .* df > 0) + 0.5*(df==0) + 0.5*(d == 0));

% PT test


% DM statistics
%individual countries

% pooled


end