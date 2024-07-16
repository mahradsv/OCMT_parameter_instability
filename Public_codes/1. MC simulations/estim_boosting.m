function rer = estim_boosting(D,use_ldv,v)

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

olight = predict_boosting(y,Z,X,Zf,Xf,v,D.weightlight);
oheavy = predict_boosting(y,Z,X,Zf,Xf,v,D.weightheavy);

rer(1:D.nmm)=reportresults(D,olight, oheavy);
end 
