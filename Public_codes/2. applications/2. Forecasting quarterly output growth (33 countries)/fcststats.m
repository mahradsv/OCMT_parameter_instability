function g= fcststats(feq, npg,  fvg, avg, rsq, avgm)

% feg is nobs x 1 vector of forecast errors
% npg is nobs x 1 vector of the number of predictors

g.bias=mean(feq);
g.MSE=mean(feq.*feq);
g.MAE=mean(abs(feq));
g.npred.mean=mean(npg,1);
g.npred.median=median(npg,1);
g.npred.min=min(npg);
g.npred.max=max(npg);
g.rsquared=mean(rsq,1);
ye=avg-avgm;
g.rsquaredout=1-(feq'*feq)/(ye'*ye);


d=avg;
df=fvg;
g.mda=100*mean((d .* df > 0) + 0.5*(df==0) + 0.5*(d == 0));

y=avg; %reshape(avg, size(avg,1)*size(avg,2),1);
y_hat=fvg; %reshape(fvg, size(avg,1)*size(avg,2),1);
g.pt=PT_test(y,y_hat);

return
