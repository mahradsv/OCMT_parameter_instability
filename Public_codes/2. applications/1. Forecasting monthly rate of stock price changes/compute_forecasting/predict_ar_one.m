function obj = predict_ar_one(y,Ly,Lyf,weight) %ppp_weight is from equation 46, 47, and 48 of Pesaran, Pick and Pranovich(2013,JoE)

if nargin < 4
    weight = 1;
end

[T,~] = size(y);
Z_plus=[ones(T,1),Ly]; % add intercept
reg = Z_plus; %X(:,ind),ones(T,1)];
regf = [1,Lyf];

yf_hat = nan(1,length(weight));

for i = 1:length(weight)
    w = weight(i);
    w_reg = w.^([T-1:-1:0]').* reg;
    w_y = w.^([T-1:-1:0]').* y;
    b = w_reg\w_y;
    yf_hat(i) = regf*b;
end

obj.yf_hat = yf_hat;

end