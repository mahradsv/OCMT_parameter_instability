function ind=activeset2(vcode, codes, includeh)

nv=size(codes,2);
ind=false(nv,1);

 for i=1:nv
% % first add lags dependent variable
%     if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),vcode(2,1)) && not(strcmp(codes(3,i),vcode(3,1)))
%         ind(i)=true;
%     end

%     if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),vcode(2,1)) && strcmp(codes(3,i),'lag1') % first lag of dependent variable
%         ind(i)=true;
%     end 

% higher lags of the y variable (not 0 and not 1)
    if strcmp(codes(1,i),vcode(1,1)) && strcmp(codes(2,i),'y') && not(strcmp(codes(3,i),vcode(3,1)) || strcmp(codes(3,i),{'lag1'})   )
        ind(i)=true;
    end
    
    
% % next  add contemporaneous country-specific foreign variable
%     if strcmp(codes{1,i},vcode{1,1}) && strcmp(codes{2,i},[vcode{2,1},'s']) && strcmp(codes{3,i},{'lag0'})
%         ind(i)=true;
%     end

% next add lags of all other domestic variables
if includeh
    variable_types1={ 'dr-dpi'  ,'dlr-dr',  'deq-dpi',  ...
                     'ys','drs-dpis','dlrs-drs','deqs-dpis',};
%   variable_types1={'y', 'dr-dpi'  ,'dlr-dr',  'deq-dpi',  'a_y' ,'a_dr-dpi',  'a_dlr-dr',  'a_deq-dpi',...
%                      'ys','drs-dpis','dlrs-drs','deqs-dpis','a_ys','a_drs-dpi ','a_dlrs-drs','a_deqs-dpis'};
else
    variable_types1={ 'dr-dpi',  'dlr-dr',  'deq-dpi', ...
                     'ys','drs-dpis','dlrs-drs','deqs-dpis'  }; %'Dps','rs','eqs',
end

% if isin(vcode{2,1},variable_types1)
%     ind_compare=[true];
%     indv=fvi(vcode(2,1), variable_types1, ind_compare);
%     acst=variable_types1(not(indv));
% end
% 
%     if strcmp(codes{1,i},vcode{1,1}) && isin(codes{2,i},acst) && not(strcmp(codes(3,i),vcode(3,1)))
%         ind(i)=true;
%     end    
    
    if strcmp(codes{1,i},vcode{1,1}) && isin(codes{2,i},variable_types1) && not(strcmp(codes(3,i),vcode(3,1)))
        ind(i)=true;
    end  

end

return