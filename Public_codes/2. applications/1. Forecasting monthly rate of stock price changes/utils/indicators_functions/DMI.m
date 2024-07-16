function [obj1,obj2] = DMI(high,low,close,s,method)

addpath /Users/mahradvaghefi/git_repo/forecasting/utils

[T,~] = size(close);
obj1 = nan(T,1);
obj2 = nan(T,1);
idx = logical(~isnan(high).*~isnan(low).*~isnan(close));
close = close(idx);
high = high(idx);
low = low(idx);

DH = high - LP(high,1);
DL = LP(low,1) - low;
Logic1_H = DH > 0;
Logic1_L = DL > 0;
Logic2_H = DH > DL;
Logic2_L = DL > DH;
index_H = Logic1_H & Logic2_H;
index_L = Logic1_L & Logic2_L;

t = size(DH,1);
DM_plus = zeros(t,1);
DM_minus = zeros(t,1);
DM_plus(index_H) = DH(index_H);
DM_minus(index_L) = DL(index_L);

TR = max(high-low,max(abs(high - LP(close,1)),abs(low - LP(close,1)),'includenan'),'includenan');

SDM_plus = MA(DM_plus,s,method);
SDM_minus = MA(DM_minus,s,method);
STR = MA(TR,s,method);

ID_plus = 100 * SDM_plus./STR;
ID_munis = 100 * SDM_minus./STR;

obj1(idx) = ID_plus;
obj2(idx) = ID_munis;

end