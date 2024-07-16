function [obj1,obj2,obj3] = FE(y,y_hat)

index = ~isnan(y);
y = y(index);
y_hat = y_hat(index);
e =  y-y_hat;
%obj1 = sqrt(mean(e.^2));
obj1 = mean(e.^2);
obj2 = mean(abs(e));
obj3 = mean(e);

end