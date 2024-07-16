function SVcell=report_selections(SV,codes, Coefs)

% first find set of forecasted variables

indf=sum(SV,2)>0;

% find set of all predictors
SVcell.sv=SV(indf,:);
SVcell.codesf=codes(:,indf);
SVcell.coefs=Coefs(indf,:);

return