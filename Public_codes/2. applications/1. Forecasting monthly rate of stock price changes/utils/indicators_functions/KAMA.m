function obj = KAMA(close,m,s1,s2)

[T,~] = size(close);
obj = nan(T,1);
idx = ~isnan(close);

close = close(idx);
DC = close - LP(close,1);
DmC = close - LP(close,m);
T = size(close,1);
KAMA = NaN(T,1);
Vol = NaN(T,1);
for i = m:T
    Vol(i) = sum(abs(DC(i-m+1:i)));
end
ER = abs(DmC)./Vol;
SC = (ER*(2/(s1+1)-2/(s2+1))+2/(s2+1)).^2;

index = ~isnan(SC);
SC_adj = SC(index);
close_adj = close(index);
KAMA_adj = KAMA(index);

KAMA_adj(1) = mean(close(isnan(SC)));

for i = 2:sum(index)
    KAMA_adj(i) = KAMA_adj(i-1) + SC_adj(i)*(close_adj(i)- KAMA_adj(i-1));
end

KAMA(index) = KAMA_adj;
obj(idx) = KAMA;

end