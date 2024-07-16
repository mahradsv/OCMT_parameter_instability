function obj = RSI(close,s,method)

addpath /Users/mahradvaghefi/git_repo/forecasting/utils

[T,~] = size(close);
obj = nan(T,1);
idx = ~isnan(close);
close = close(idx);

DC = close - LP(close,1);
pos = DC > 0;
neg = DC < 0;
G = DC.*pos;
L = abs(DC.*neg);
RS = MA(G,s,method)./MA(L,s,method);
obj(idx) = 100 * RS./(1+RS);

end