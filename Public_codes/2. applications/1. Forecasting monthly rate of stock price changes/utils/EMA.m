function obj = EMA(X,w,s)

t = size(X,1);
n = size(X,2);
obj = NaN(t,n);
index = ~isnan(X);
X_adj = X(index);
obj_adj = obj(index);
obj_adj(s,:) = mean(X_adj(1:s,:));
%obj_adj(s,:) = w * ((1-w).^(s:-1:1)) * X_adj(1:s,:);
for i = s+1:sum(index)
    obj_adj(i,:) = w * X_adj(i,:) + (1 - w)* obj_adj(i-1,:);
end
obj(index)= obj_adj;

end