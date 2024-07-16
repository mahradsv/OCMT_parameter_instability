function [obj1,obj2,obj3,obj4,obj5] = PT_test(y,y_hat,reg_approach) % a regression approach to compute PT test
if nargin < 3
    reg_approach = true;
end
index = ~isnan(y);
y = y(index);
y_hat = y_hat(index);
Tr = length(y);
y1 = y > 0;
y2 = y_hat > 0;

if reg_approach
    reg= y2 - mean(y2);%[y2,ones(Tr,1)];
    dy1 = y1 - mean(y1);
    b = reg'*dy1/(reg'*reg);%reg\y1;
    e=dy1-reg*b;
    kr=size(reg,2);
    ve=e'*e/(Tr-kr);
    App= 1/(reg'*reg);%inv(reg'*reg); %pinv(Xr'*Xr);
    seb=(App(1,1)*ve)^0.5;
    obj1 = b(1)/seb;
else
    y1_bar = mean(y1);
    y2_bar = mean(y2);
    
    %P1 = mean(sign(y)==sign(y_hat));
    P1 = mean(y .* y_hat > 0);
    P2 = y1_bar*y2_bar + (1-y1_bar)*(1-y2_bar);
    
    V_P1 = P2*(1-P2)/Tr;
    V_P2 = (2*y1_bar-1)^2*y2_bar*(1-y2_bar)/Tr + (2*y2_bar-1)^2*y1_bar*(1-y1_bar)/Tr + ...
        4*y1_bar*y2_bar*(1-y1_bar)*(1-y2_bar)/(Tr^2);
    obj1 = (P1 - P2)/sqrt(V_P1 - V_P2);
end
%obj2 = 100*mean((y .* y_hat > 0) + 0.5*(y_hat==0) + 0.5*(y == 0)); % Modified Mean Directional Accuracy (MDA) in Percent
obj2 = 100*mean(y .* y_hat > 0); % Mean Directional Accuracy (MDA)

y1_bar = mean(y1);
y2_bar = mean(y2);
obj3 = 100*(y1_bar*y2_bar + (1-y1_bar)*(1-y2_bar));
obj4 = 100*y1_bar;
obj5 = 100*y2_bar;
end