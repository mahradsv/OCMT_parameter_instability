function cpt=countryPTs(Av,Fv)

N=size(Av,2);
cpt=zeros(1,N);
for i=1:N
    y=Av(:,i);
    y_hat=Fv(:,i);
    cpt(1,i)=PT_test(y,y_hat);
end

return
