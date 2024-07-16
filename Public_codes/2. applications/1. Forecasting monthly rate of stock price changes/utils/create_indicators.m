function result = create_indicators(price_close,price_low,price_high, realized_volatility,s1_set,s2_set,s3_set)

log_price_close = log(price_close);
num_s1_set = length(s1_set);
num_s2_set = size(s2_set,1);
num_s3_set = size(s3_set,1);

T = length(price_close);
rsi = zeros(T,num_s1_set);
willr = rsi; adx = rsi; pgap = rsi; madp = rsi; dpgap = rsi; rvgap = rsi;
marv = rsi;
ppo = zeros(T,num_s2_set);
dkama = zeros(T,num_s3_set);

rsi_name = cell(num_s1_set,1);
willr_name = rsi_name; adx_name = rsi_name; pgap_name = rsi_name; 
madp_name = rsi_name; dpgap_name = rsi_name; marv_name = rsi_name; 
rvgap_name = rsi_name;
ppo_name = cell(num_s2_set,1);
dkama_name = cell(num_s3_set,1);

rsi_full_name = cell(num_s1_set,1);
willr_full_name = rsi_full_name; adx_full_name = rsi_full_name; 
pgap_full_name = rsi_full_name; madp_full_name = rsi_full_name; 
dpgap_full_name = rsi_full_name; rvgap_full_name = rsi_full_name;
marv_full_name = rsi_full_name;
ppo_full_name = cell(num_s2_set,1);
dkama_full_name = cell(num_s3_set,1);

method = 'SMA'; % moving average method

for i = 1:num_s1_set
    s = s1_set(i);
    
    % Moving Average of Log Price Change
    dp = level2logchange(price_close);
    madp(:,i) = MA(dp,s,'SMA');
    madp_name{i} = sprintf('madp-m%d', s);
    madp_full_name{i} = sprintf('Moving Average of Log Price Change With s=%d', s);
    
    % Log Price Change Gap
    dpgap(:,i) = dp - madp(:,i);
    dpgap_name{i} = sprintf('dpgap-m%d', s);
    dpgap_full_name{i} = sprintf('Log Price Change Gap With s=%d', s);
    
    % Log Price Gap
    pgap(:,i) = 100*(log_price_close - MA(log_price_close,s,'SMA'));
    pgap_name{i} = sprintf('pgap-m%d', s);
    pgap_full_name{i} = sprintf('Log Price Gap With s=%d', s);
    
    % Moving Average of Realized Volatility
    marv(:,i) = MA(realized_volatility,s,'SMA');
    marv_name{i} = sprintf('marv-m%d', s);
    marv_full_name{i} = sprintf('Moving Average of Realized Volatility With s=%d', s);
    
    % Realized Volatility Gap
    rvgap(:,i) = realized_volatility - marv(:,i);
    rvgap_name{i} = sprintf('rvgap-m%d', s);
    rvgap_full_name{i} = sprintf('Realized Volatility Gap With s=%d', s);
    
    % Relative Strength Indicator
    rsi(:,i) = RSI(price_close,s,method);
    rsi_name{i} = sprintf('rsi-m%d', s);
    rsi_full_name{i} = sprintf('Relative Strength Indicator With s=%d', s);
    
    % Williams R Indicator
    willr(:,i) = WILLR(price_high,price_low,price_close,s);
    willr_name{i} = sprintf('willr-m%d', s);
    willr_full_name{i} = sprintf('Williams R Indicator With s=%d', s);
    
    % Average Directional Movement Index
    adx(:,i) = ADX(price_high,price_low,price_close,s,method);
    adx_name{i} = sprintf('adx-m%d', s);
    adx_full_name{i} = sprintf('Average Directional Movement Index With s=%d', s);
    
end

for i = 1:num_s2_set
    s1 = s2_set(i,1);
    s2 = s2_set(i,2);
    ppo(:,i) = PPO(price_close,s1,s2,method);
    ppo_name{i} = sprintf('ppo-m%d-m%d', s1,s2);
    ppo_full_name{i} = sprintf('Percent Price Oscillator index With s1=%d and s2=%d', s1, s2);
end

for i = 1:num_s3_set
    s1 = s3_set(i,1);
    s2 = s3_set(i,2);
    m = s3_set(i,3);
    kama = KAMA(price_close,m,s1,s2);
    dkama(:,i) = level2rate(kama);
    dkama_name{i} = sprintf('dkama-m%d-m%d-m%d', m,s1,s2);
    dkama_full_name{i} = sprintf('Percentage Change in Kaufman Adaptive Moving Average  With s1=%d, s2=%d and m=%m', s1, s2,m);
    
end

abbreviations = [madp_name; dpgap_name; pgap_name; marv_name; rvgap_name;...
    rsi_name; willr_name; adx_name; ppo_name; dkama_name];

full_name = [madp_full_name; dpgap_full_name; pgap_full_name; marv_full_name;...
    rvgap_full_name;rsi_full_name; willr_full_name; adx_full_name; ppo_full_name; dkama_full_name];

data = [madp, dpgap, pgap, marv, rvgap, rsi, willr, adx, ppo, dkama];

indicators_number = length(full_name);
result.abbreviations = abbreviations;
result.full_name = full_name;
result.data = data;
result.indicators_number = indicators_number;

end