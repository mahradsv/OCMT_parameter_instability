clc
clear

addpath("glmnet_matlab/")

y = randn(100,1);

x = randn(100,25);

options = glmnetSet;

result = cvglmnet(x,y,'gaussian',options,'deviance',10,[],[],true);

foldid =  result.foldid;

foldid

cvm_manual = mean((y - result.fit_preval).^2)';

diff_cvm = sum(abs(result.cvm - cvm_manual));

diff_cvm