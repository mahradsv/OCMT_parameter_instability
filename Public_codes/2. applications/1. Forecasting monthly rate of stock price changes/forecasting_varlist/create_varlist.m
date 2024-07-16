function obj = create_varlist(raw_data_path,s1_set,s2_set,s3_set,initial_date,end_date)
load(raw_data_path)
date = date;
intial_idx = find(year(date) == year(initial_date) & month(date) == month(initial_date),1,'first');
end_idx = find(year(date) == year(end_date) & month(date) == month(end_date),1,'first');

% dropping stocks for insufficient data
inclusion_idx = inclusion_idx_close & inclusion_idx_high & inclusion_idx_low;
price_close = price_close(:,inclusion_idx);
price_high = price_high(:,inclusion_idx);
price_low = price_low(:,inclusion_idx);
realized_volatility_price = realized_volatility_price(:,inclusion_idx);
close_mdate = close_mdate(:,inclusion_idx);
financial_stocks_names = financial_stocks_names(inclusion_idx);
sup_sec_class = sup_sec_class(inclusion_idx);

[~,n] = size(price_close);
s = struct;
data_all = repmat(s,[n,1]); 

for i = 1:n
    
    z = 1;
    data(:,z) = level2logchange(price_close(:,i));
    data_all(i).name{z} = 'Change in Log of adjusted close price';
    z = z+1;
    
    dp_all = level2logchange(price_close);
    stock_class = sup_sec_class(i);
    idx = strcmp(stock_class,sup_sec_class);
    data(:,z) = mean(dp_all(:,idx),2,'omitnan');
    data_all(i).name{z} = strcat("Average Percent Rate of Price Change for ", financial_stocks_names(i));
    z = z+1;
    
    data(:,z) = level2logchange(price_close_sp500);
    data_all(i).name{z} = 'Change in Log of adjusted close price S&P 500';
    z = z+1;
    
    data(:,z) = realized_volatility_price(:,i);
    data_all(i).name{z} = strcat("Realized Volatility of ", financial_stocks_names(i));
    z = z+1;
    
    data(:,z) = sqrt(mean(realized_volatility_price(:,idx).^2,2,'omitnan'));
    data_all(i).name{z} = strcat("Group Realized Volatility for ", financial_stocks_names(i));
    z = z+1;
    
    data(:,z) = realized_volatility_sp500;
    data_all(i).name{z} = strcat('Realized Volatility of S&P 500');
    z = z+1;
    
    data(:,z) = SMB;
    data_all(i).name{z} = strcat('Small Minus Big Factor');
    z = z+1;
    
    data(:,z) = HML;
    data_all(i).name{z} = strcat('High Minus Low Factor');
    z = z+1;
    
    data(:,z) = level2logchange(price_oil);
    data_all(i).name{z} = 'Change in Log of Oil Price';
    z = z+1;
    
    data(:,z) = level2change(ir_long - ir_short);
    data_all(i).name{z} = 'Change in Spread between LTIR and STIR';
    z = z+1;
    
    data(:,z) = level2change(ir_medium - ir_short);
    data_all(i).name{z} = 'Change in Spread between MTIR and STIR';
    z = z+1;
    
    data(:,z) = level2change(ir_long - ir_medium);
    data_all(i).name{z} = 'Change in Spread between LTIR and MTIR';
    z = z+1;
    
    obj_1 = create_indicators(price_close(:,i),price_low(:,i),price_high(:,i), realized_volatility_price(:,i),s1_set,s2_set,s3_set);
     
    data(:,z:z-1+obj_1.indicators_number) = obj_1.data;
    data_all(i).name(z:z-1+obj_1.indicators_number) = obj_1.full_name;
    
    data_all(i).data = data(intial_idx:end_idx,:);
    data_all(i).num_var_list = z-1+obj_1.indicators_number; 
end

obj = data_all;

end