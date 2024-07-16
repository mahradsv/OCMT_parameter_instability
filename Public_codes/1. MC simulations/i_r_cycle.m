function [Re, rer]=i_r_cycle(R, NoEst)
rer.bmisc=NaN(10,1, 'single');
% bmisc is a vector containing the individual replication-specific results
% elements of bmisc:
% 1: forecast error
% 2: number of selected variables


Re1=repmat(rer,[R,1]);
Re=repmat(Re1,1,NoEst);
end