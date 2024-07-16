function Zind=conditioningset1(vcode, codes)

% first case - only constant is chosen
nv=size(codes,2);
Zind=false(nv,1);
for i=1:nv
    if strcmp(codes(2,i),'constant') && strcmp(codes(3,i),'lag0') % constant term
        Zind(i,1)=true;
    end
    
    % add cs ave
    if strcmp(codes(2,i),{'Csave'} ) % cs ave
        Zind(i)=true;
    end    

    
 
end


return