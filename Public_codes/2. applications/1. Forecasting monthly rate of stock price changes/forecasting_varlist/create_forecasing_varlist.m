clc
clear
addpath ../utils
addpath ../utils/indicators_functions

raw_data_path = '../matlab_data/monthly/monthly_raw_data_all.mat';
s1_set = [3,6,12];
s2_set = [3,6;6,12;3,12];
s3_set = [6,2,12];

initial_date = datetime(1980,01,01,'Format','MM/yyyy');
end_date = datetime(2017,12,31,'Format','MM/yyyy');
independent_variables = create_varlist(raw_data_path,s1_set,s2_set,s3_set,initial_date,end_date);
load(raw_data_path);
% dropping stocks for insufficient data and adjust sample period
inclusion_idx = inclusion_idx_close & inclusion_idx_high & inclusion_idx_low;
intial_idx = find(year(date) == year(initial_date) & month(date) == month(initial_date),1,'first');
end_idx = find(year(date) == year(end_date) & month(date) == month(end_date),1,'first');
date = date(intial_idx:end_idx);

log_price_change = level2logchange(price_close);
price_close = price_close(intial_idx:end_idx,inclusion_idx);
log_price_change = log_price_change(intial_idx:end_idx,inclusion_idx);
financial_stocks_names = financial_stocks_names(inclusion_idx);

clearvars -except independent_variables price_close date log_price_change financial_stocks_names
filename = '../matlab_data/monthly/forecasting_final_dataset.mat';
save(filename);
