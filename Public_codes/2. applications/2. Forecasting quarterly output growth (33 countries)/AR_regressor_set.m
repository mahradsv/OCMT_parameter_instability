function Zind=AR_regressor_set(vcode, codes)


nv=size(codes,2);
Zind=false(nv,1);
for i=1:nv
    if strcmp(codes(2,i),'constant') && strcmp(codes(3,i),'lag1') % constant term
        Zind(i,1)=true;
    end
    
    if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),vcode(2,1)) && strcmp(codes(3,i),'lag1') % first lag of dependent variable
        Zind(i)=true;
    end    
end


return