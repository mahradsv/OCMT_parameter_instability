function obj = SMA(X,s)

t = size(X,1);
n = size(X,2);
obj = NaN(t,n);
index = ~isnan(X);
X_adj = X(index);
obj_adj = obj(index);
for i = s:sum(index)
    obj_adj(i,:) = mean(X_adj(i-s+1:i,:));
end
obj(index)= obj_adj;

end