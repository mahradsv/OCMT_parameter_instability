function [rer]=estim_ocmt(D,sel_weight,use_ldv )

if use_ldv
    T=size(D.x,1)-2;
    X=D.x(2:T+1,:);
    Xf=D.x(T+2,:);
    Z=D.y(1:T,1); % constant is automatically included
    Zf=D.y(T+1,1);
    y=D.y(2:T+1,1);
else    
    T=size(D.x,1)-1;
    X=D.x(1:T,:);
    Xf=D.x(T+1,:);
    Z=ones(T,0); % constant is automatically included
    Zf=[];
    y=D.y(1:T,1);
end

est_weight=true;
p_val=0.01; delta=1; deltastar=2;
olight=predict_ocmt(y,Z,X,Zf,Xf, p_val,delta,deltastar,D.weightlight,sel_weight,est_weight);
oheavy=predict_ocmt(y,Z,X,Zf,Xf, p_val,delta,deltastar,D.weightheavy,sel_weight,est_weight);


rer(1:D.nmm)=reportresults(D,olight, oheavy);

end 
