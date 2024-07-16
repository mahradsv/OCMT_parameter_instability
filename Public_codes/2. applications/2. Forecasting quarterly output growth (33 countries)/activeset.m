function ind=activeset(vcode, codes)

nv=size(codes,2);
ind=false(nv,1);

 for i=1:nv
% % first add lags dependent variable
%     if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),vcode(2,1)) && not(strcmp(codes(3,i),vcode(3,1)))
%         ind(i)=true;
%     end

% higher lags of the dependent variable (not 0 and not 1)
    if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),vcode(2,1)) && not(strcmp(codes(3,i),vcode(3,1)) || strcmp(codes(3,i),{'lag1'})   )
        ind(i)=true;
    end
    
    
% next  add contemporaneous country-specific foreign variable
    if strcmp(codes{1,i},vcode{1,1}) && strcmp(codes{2,i},[vcode{2,1},'s']) && strcmp(codes{3,i},{'lag0'})
        ind(i)=true;
    end

% next add lags of all other domestic and  country-specific foreign variables
variable_types1={'y','Dp','r','eq', 'r-lr', 'ys','Dps','rs','eqs','eps', 'rs-lrs','poil','pmat', 'pmetal', 'constant'};
% if strcmp(vcode{2,1},'Dp')
%     'here'
% end
if isin(vcode{2,1},variable_types1)
    ind_compare=[true];
    indv=fvi(vcode(2,1), variable_types1, ind_compare);
    acst=variable_types1(not(indv));
end
if isin(vcode{2,1},{'lr','lrs'})
    variable_types2={'y','Dp','r','eq', 'lr', 'ys','Dps','rs','eqs', 'lrs','poil','pmat', 'pmetal', 'constant'};
    ind_compare=[true];
    indv=fvi(vcode(2,1), variable_types2, ind_compare);
    acst=variable_types2(not(indv));
end

    if strcmp(codes{1,i},vcode{1,1}) && isin(codes{2,i},acst) && not(strcmp(codes(3,i),vcode(3,1)))
        ind(i)=true;
    end    
    
% % next add lags of all foreign variables of the same type
%     if not(strcmp(codes{1,i},vcode{1,1})) && strcmp(codes{2,i},vcode{2,1}) && not(strcmp(codes(3,i),vcode(3,1)))
%         ind(i)=true;
%     end

end

return