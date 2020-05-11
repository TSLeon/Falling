% 改版目标标注函数，测试中
function labelStruct = callouts2(BW,labelStruct)
[bw,n] = bwlabel(BW,8);
props = regionprops(bw);
if(n==1)
    boundingbox = props.BoundingBox;
    labelStruct.x = boundingbox(1,1);
    labelStruct.y = boundingbox(1,2);
    labelStruct.width = boundingbox(1,3);
    labelStruct.heigth = boundingbox(1,4);
    centroid = props.Centroid;
    labelStruct.centroid_y = centroid(1,2);  % 只判断重心变化所以只需要y值
    labelStruct.sum = bwarea(bw);
elseif n>=2
    if n~=2
        diff_area = sortArea(props,n);
        bw2 = bwareaopen(BW,diff_area,8);
        [bw,~] = bwlabel(bw2,8);
    end
    props = regionprops(bw);
    if(props(1).Area > props(2).Area)
        maxArea = props(1).Area;
        minArea = props(2).Area;
        flag = 1;
    else
        maxArea = props(2).Area;
        minArea = props(1).Area;
        flag = 2;
    end
    labelStruct.sum = bwarea(bw);
    if(maxArea/minArea > 10)
        boundingbox = props(flag).BoundingBox;
        labelStruct.x = boundingbox(1,1);
        labelStruct.y = boundingbox(1,2);
        labelStruct.width = boundingbox(1,3);
        labelStruct.heigth = boundingbox(1,4);
        centroid = props(flag).Centroid;
        labelStruct.centroid_y = centroid(1,2);
    else  % 两个连通域相差小于10倍，以下代码有待测试。
        centroid_1 = props(1).Centroid;
        centroid_2 = props(2).Centroid;
        x_1 = centroid_1(1,1);
        y_1 = centroid_1(1,2);
        x_2 = centroid_2(1,1);
        y_2 = centroid_2(1,2);
        old_page_x = abs(x_1-x_2)/4;
        old_page_y = abs(y_1-y_2)/4;
        labelStruct.centroid_y = (y_1+y_2)/2;
        if(x_2 < x_1)
            labelStruct.x = x_2 - old_page_x;
            labelStruct.y = y_1 - old_page_y;
        else
            labelStruct.x = x_1 - old_page_x;
            labelStruct.y = y_2 - old_page_y;
        end
        labelStruct.width = abs(x_1 - x_2)*1.5;
        labelStruct.heigth = abs(y_1 - y_2)*1.5;
    end
end
end