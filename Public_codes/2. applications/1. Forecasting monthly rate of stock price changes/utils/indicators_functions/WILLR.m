function obj = WILLR(high,low,close,s)

[T,~] = size(close);
obj = nan(T,1);
idx = logical(~isnan(high).*~isnan(low).*~isnan(close));
close = close(idx);
high = high(idx);
low = low(idx);

t = size(high,1);
MAX = NaN(t,1);
MIN = NaN(t,1);

for i = s:t
    MAX(i) = max(high(i-s+1:i));
    MIN(i) = min(low(i-s+1:i));
end

obj(idx) = -100 * (close - MAX)./(MAX - MIN);


end