function inds=assign(Aind,ind)

%Ainds is nval x 1 boolean array with k x 1 true elements
% ind is k x 1 with ns true elements
% inds is nval x 1 with ns true elements based on ind
nval=size(Aind,1);
inds=false(nval,1);
inds(Aind)=ind;


return