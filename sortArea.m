function threshold = sortArea(source,lim)
num = [];
for i = 1:lim
    num(i) = source(i).Area;
end
[threshold,tag] = max(num);
num(tag) = min(num);
threshold = max(num);
end