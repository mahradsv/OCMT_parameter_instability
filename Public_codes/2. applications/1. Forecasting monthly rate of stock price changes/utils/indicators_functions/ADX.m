function obj = ADX(high,low,close,s,method)

addpath /Users/mahradvaghefi/git_repo/forecasting/utils

[T,~] = size(close);
obj = nan(T,1);
idx = logical(~isnan(high).*~isnan(low).*~isnan(close));
close = close(idx);
high = high(idx);
low = low(idx);

[ID_munis,ID_plus] = DMI(high,low,close,s,method);
DX = 100*abs(ID_plus - ID_munis)./(ID_plus + ID_munis);
obj(idx) =  MA(DX,s,method);

end