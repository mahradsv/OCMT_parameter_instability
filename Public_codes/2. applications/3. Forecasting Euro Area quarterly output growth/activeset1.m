function ind=activeset1(vcode, codes, includeh)

nv=size(codes,2);
ind=false(nv,1);

 for i=1:nv
% % first add lags dependent variable
%     if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),vcode(2,1)) && not(strcmp(codes(3,i),vcode(3,1)))
%         ind(i)=true;
%     end

    if strcmp(codes(2,i),{'v'} ) % first lag of dependent variable
        ind(i)=true;
    end    

 end
 
return