function DM = DMtests(yf,y)

FE = yf - y;
No_methods = size(FE,3);
DM=NaN(No_methods,No_methods);
for i=1:No_methods
    for j=1:No_methods
        if not(i==j)
            Fea = squeeze(FE(:,:,i));
            Feb = squeeze(FE(:,:,j));
            DM1 = panelDM( Fea, Feb);
            DM(i,j)=DM1;
        end
    end
end