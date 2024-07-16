% This function generate up to order p lags of a vector x

% Input
    % x: a vector to be lagged
    % p: lag order
    
% output
    % CL: A Matrix of up to order p lags.
    
function CL=CLP(x,P)
if P==0
    CL=[];
else
    CL=NaN(size(x,1),P);
    for i=1:P
        CL(:,i)=LP(x,i);
    end
end