function rera=reportresults(D,olight, oheavy)

rer.bmisc=NaN(10,1);
% 1 for forecast error
% 2 for number of selected regressors 
% 3 for TPR
% 4 for FPR
% 5 for FDR
% 6 for FDR (6 to n)

n=size(D.x,2);
rera=repmat(rer,1,D.nmm);
kreg=D.kreg;

dimwl=size(D.weightlight,2); % dimension of the weight vector
dimwh=size(D.weightheavy,2); % dimension of the weight vector
yf=D.y(end,1);
tpr=NaN(dimwl,1); fpr=NaN(dimwl,1); fdr=NaN(dimwl,1); fdr6=NaN(dimwl,1);

for i=1:dimwl
    rera(i).bmisc(1,1)=olight.yf(1,i)-yf;
    rera(i).bmisc(2,1)=olight.nvars(1,i);
       
    tpr(i)=sum(olight.inds(1:kreg,i))/kreg;
    rera(i).bmisc(3,1)=tpr(i);
    fpr(i)=sum(olight.inds(kreg+1:end,i))/n;
    rera(i).bmisc(4,1)=fpr(i);
    fdr(i)=sum(olight.inds(kreg+1:end,i))/(sum(olight.inds(:,i))+1);
    rera(i).bmisc(5,1)=fdr(i);
    fdr6(i)=sum(olight.inds(6:end,i))/(sum(olight.inds(:,i))+1);
    rera(i).bmisc(6,1)=fdr6(i);
end

% now report for ave light
rera(dimwl+1).bmisc(1,1)=mean(olight.yf(1,:))-yf;
rera(dimwl+1).bmisc(2,1)=mean(olight.nvars(1,:));
rera(dimwl+1).bmisc(3,1)=mean(tpr);
rera(dimwl+1).bmisc(4,1)=mean(fpr);
rera(dimwl+1).bmisc(5,1)=mean(fdr);
rera(dimwl+1).bmisc(6,1)=mean(fdr6);

tpr=NaN(dimwh,1); fpr=NaN(dimwh,1); fdr=NaN(dimwh,1); fdr6=NaN(dimwh,1);
for i=1:dimwh
    rera(dimwl+1+i).bmisc(1,1)=oheavy.yf(1,i)-yf;
    rera(dimwl+1+i).bmisc(2,1)=oheavy.nvars(1,i);
    
    tpr(i)=sum(oheavy.inds(1:kreg,i))/kreg;
    rera(dimwl+1+i).bmisc(3,1)=tpr(i);
    fpr(i)=sum(oheavy.inds(kreg+1:end,i))/n;
    rera(dimwl+1+i).bmisc(4,1)=fpr(i);
    fdr(i)=sum(oheavy.inds(kreg+1:end,i))/(sum(oheavy.inds(:,i))+1);
    rera(dimwl+1+i).bmisc(5,1)=fdr(i);
    fdr6(i)=sum(oheavy.inds(6:end,i))/(sum(oheavy.inds(:,i))+1);
    rera(dimwl+1+i).bmisc(6,1)=fdr6(i);
end
rera(dimwl+dimwh+2).bmisc(1,1)=mean(oheavy.yf(1,:))-yf;
rera(dimwl+dimwh+2).bmisc(2,1)=mean(oheavy.nvars(1,:));
rera(dimwl+dimwh+2).bmisc(3,1)=mean(tpr);
rera(dimwl+dimwh+2).bmisc(4,1)=mean(fpr);
rera(dimwl+dimwh+2).bmisc(5,1)=mean(fdr);
rera(dimwl+dimwh+2).bmisc(6,1)=mean(fdr6);
end