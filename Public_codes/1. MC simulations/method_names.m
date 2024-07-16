function method_name=method_names(weightlight,weightheavy,i)

dimwl=size(weightlight,2); 
dimwh=size(weightheavy,2);
nms=dimwl+1+dimwh+1;

all_methods_names=cell(9*nms,1);

for j=1:11
    if j==1
       s1='Oracle';
    end
    if j==2
       s1='OCMT, downweighting only in the estimation stage';
    end
    if j==3
       s1='OCMT, downweigting both in the selection and estimation stages';
    end
    if j==4
       s1='LASSO';
    end
    if j==5
       s1='A-LASSO';
    end
    if j==6
       s1='Boosting \nu = 0.1';
    end
    if j==7
       s1='Boosting \nu = 1';
    end
    if j==8
       s1='LASSO, downweighting only in the estimation stage';
    end
    if j==9
       s1='A-LASSO, downweighting only in the estimation stage';
    end
    if j==10
       s1='Boosting \nu = 0.1, downweighting only in the estimation stage';
    end
    if j==11
       s1='Boosting \nu = 1, downweighting only in the estimation stage';
    end
    for ii=1:dimwl
        w=weightlight(1,ii);
        wstr=num2str(w);
        all_methods_names{ii+nms*(j-1),1}=[s1,', downweighting weight =',wstr];
    end
    all_methods_names{dimwl+1+nms*(j-1),1}=[s1,', forecast average across light downweighting weights'];
    for ii=1:dimwh
        w=weightheavy(1,ii);
        wstr=num2str(w);
        all_methods_names{dimwl+1+ii+nms*(j-1),1}=[s1,', downweighting weight =',wstr];
    end
    all_methods_names{dimwl+1+dimwh+1+nms*(j-1),1}=[s1,', forecast average across Heavy downweighting weights'];
end
method_name=all_methods_names{i};

end