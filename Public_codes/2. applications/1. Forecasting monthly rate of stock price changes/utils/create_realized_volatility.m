function obj = create_realized_volatility(daily_data, daily_date,omitnan, initial_date, end_date)

if nargin < 5
    end_date = daily_date(end);
end
if nargin < 4
    initial_date = daily_date(1);
end
if nargin < 3
    omitnan = true;
end

if omitnan
    idx = ~isnan(daily_data);
    daily_data = daily_data(idx);
    daily_date = daily_date(idx);
end

monthly_date = [initial_date:calmonths(1):end_date]';
monthly_date = datetime(monthly_date,'Format','MM/yyyy');
%d_data = level2rate(daily_data); 
obj = nan(size(monthly_date));

for i = 1:length(obj)
    index = month(daily_date) == month(monthly_date(i)) & year(daily_date) == year(monthly_date(i));
    if sum(index)>10 % a month should have at least 10 trading days
        d_data_temp = daily_data(index);
        d_data_temp = d_data_temp(~isnan(d_data_temp));
        dp_bar = mean(d_data_temp);
        obj(i) = sqrt(mean((d_data_temp - dp_bar).^2));
    end
end

end