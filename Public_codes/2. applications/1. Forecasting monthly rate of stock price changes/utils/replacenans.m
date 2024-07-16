function Tablef=replacenans(Table,all)
if nargin < 2
    all = false;
end
% this function takes 2-dimensional array and converts it into a cell array formatted for saving into xls

[a,b]=size(Table);
Tablef=cell(a,b);

for i=1:a
    for j=1:b
        if isnan(Table(i,j))
            if all
                Tablef{i,j}='-';
            else
                if sum(isnan(Table(i,:)))==b % whole row of NaNs
                    Tablef{i,j}='';
                else
                    if (sum(isnan(Table(:,j)))==a && j>1) % whole column of NaNs
                        Tablef{i,j}='';
                    else % not all row consists of NaNs
                        Tablef{i,j}='-';
                    end
                end
            end
        else % is a number
            Tablef{i,j}=Table(i,j);
        end
    end
end




return