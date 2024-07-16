function [ind, pos]=fvi(vcode, codes, ind_compare)

nv=size(codes,2);
ind=false(nv,1);
pos=[];
for j=1:nv
    
    if all(strcmp(codes(ind_compare,j),vcode(ind_compare,1)))
        ind(j)=true;
        pos=[pos;j];
    end
    
end

return