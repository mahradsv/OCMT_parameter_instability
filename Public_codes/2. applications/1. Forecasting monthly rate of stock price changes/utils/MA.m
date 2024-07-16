function obj = MA(X,s,method)

if strcmp(method,'SMA')
    obj = SMA(X,s);
elseif strcmp(method,'EMA')
    w = 2/(s+1); % Regular Exponantial Moving Average
    obj = EMA(X,w,s);
elseif strcmp(method,'WWMA')
    w = 1/s; % William Wilder Exponantial Moving Average
    obj = EMA(X,w,s);
end

end