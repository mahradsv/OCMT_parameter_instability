function obj = PPO(close,s1,s2,method)

addpath /Users/mahradvaghefi/git_repo/forecasting/utils

[T,~] = size(close);
obj = nan(T,1);
idx = ~isnan(close);
close = close(idx);

obj(idx) = 100* (MA(close,s1,method)./MA(close,s2,method) - 1);

end