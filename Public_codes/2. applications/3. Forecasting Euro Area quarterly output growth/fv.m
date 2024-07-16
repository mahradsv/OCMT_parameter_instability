function [ind, pos]=fv(vcode, codes)

nv=size(codes,2);
ind=false(nv,1);

for i=1:nv
% first add dependent variable
%     if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),vcode(2,1) && strcmp(codes(3,i),vcode(3,1))
%         ind(i)=true;
%     end
    
    if all(strcmp(codes(:,i),vcode(:,1)))
        ind(i)=true;
        pos=i;
    end
    
end

return