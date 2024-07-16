function DM1 = panelDM( Fea, Feb)

% input: NxT forecast errors (model a and benchmark model b)
% output: DM1 - assuming serially uncorrelated errors
ind = ~isnan(Fea);
q=(Fea.^2)-(Feb.^2);
qbar = mean(q(ind),'omitnan');
qbar_i = mean(q,'omitnan');
dq = q - qbar_i;
sig = mean(dq.^2,'omitnan');
w = sum(ind)/sum(sum(ind));
v1= sum(sig.*w);

DM1=sqrt(sum(sum(ind)))*qbar/sqrt(v1);



end

