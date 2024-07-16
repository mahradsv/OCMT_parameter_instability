function dd=einv(no, idex)
dd=[];

for d8=1:idex(8)
 for d7=1:idex(7)
  for d6=1:idex(6)
   for d5=1:idex(5)
    for d4=1:idex(4)
     for d3=1:idex(3)   
      for d2=1:idex(2)  
       for d1=1:idex(1)
            d=[d1,d2,d3,d4,d5,d6,d7,d8];
            eid=d(1) +(d(2)-1)*idex(1)+(d(3)-1)*prod(idex(1:2))+ ...
                    (d(4)-1)*prod(idex(1:3))+(d(5)-1)*prod(idex(1:4))+...
                    (d(6)-1)*prod(idex(1:5))+(d(7)-1)*prod(idex(1:6))+...
                    (d(8)-1)*prod(idex(1:7));
            if eid==no
                dd=d;
            end
               
       end %d1
      end %d2
     end %d3
    end %d4
   end %d5
  end %d6
 end %d7
end %d8

end