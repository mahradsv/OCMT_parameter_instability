function is=is_in(code,codes) 
n=length(codes);
is=false;
for i=1:n
    if strcmp(code,codes(i))
        is=true;
    end
end

end