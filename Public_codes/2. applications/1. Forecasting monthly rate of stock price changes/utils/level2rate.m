function obj = level2rate(X)

obj = 100*(X./LP(X,1) - 1);

end