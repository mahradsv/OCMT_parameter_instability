function [obj1,obj2] = PT_test(y,y_hat) % a regression approach to compute PT test

index = ~isnan(y);
y = y(index);
y_hat = y_hat(index);
Tr = length(y);
y1 = y > 0;
y2 = y_hat > 0;
reg=[y2,ones(Tr,1)];
warning('off');
b = reg\y1;
e=y1-reg*b;
kr=size(reg,2);
ve=e'*e/(Tr-kr);
App=inv(reg'*reg); %
seb=(App(1,1)*ve)^0.5;

obj1 = abs(b(1))/seb;
obj2 = 100*mean((y .* y_hat > 0) + 0.5*(y_hat==0) + 0.5*(y == 0)); % Mean Directional Accuracy (MDA) in Percent

end