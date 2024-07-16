function [rer]=estim_o(D,use_ldv)

if use_ldv
    T=size(D.x,1)-2;
    X=D.x(2:T+1,:);
    Xf=D.x(T+2,:);
    y=D.y(2:T+1,1);
    Z=[ones(T,1),D.y(1:T,1)];
    Zf=[1,D.y(T+1,1)];
else
    T=size(D.x,1)-1;
    X=D.x(1:T,:);
    Xf=D.x(T+1,:);
    y=D.y(1:T,1);
    Z=ones(T,1);
    Zf=1;
end


olight=predict_o(y,Z,X,Zf,Xf, D.weightlight);
oheavy=predict_o(y,Z,X,Zf,Xf, D.weightheavy);


rer(1:D.nmm)=reportresults(D,olight, oheavy);

end 
