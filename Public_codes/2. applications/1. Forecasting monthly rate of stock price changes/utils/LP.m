% This function generate lag of order p of a matrix x

% Input
    % x: a matrix to be lagged
    % p: lag order
    
% output
    % L: lag order p of vector x
    
function L=LP(x,p)
L=NaN(size(x,1),size(x,2));
L(p+1:end,:)=x(1:end-p,:);
end
