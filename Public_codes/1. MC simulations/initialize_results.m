function [Rr]=initialize_results(idex,bNmax, bTmax )
% function that initializes results variables
pom.bmn=zeros(10,1, 'single');
% bmn is a vector containing the results aggregated across replications
% elements of bmn:
% 1 forecast error
% 2 number of selected regressors
% 3 TPR
% 4 FPR
% 5 FDR
% 6 for FDR (6 to n)


Rr=repmat(pom,[idex,bNmax,bTmax]);

end