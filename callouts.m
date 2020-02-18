function [x,y,width,heigth,centroid_y,sum] = callouts(BW)
[bw,n] = bwlabel(BW,8);  % 寻找所有连通域并标注，按8连通寻找，bw为标记后图片，n为连通域个数
props = regionprops(bw);
% 得到Area，Centroid，BoundingBox三个属性
% BoundingBox-包含相应区域的最小矩阵
% Centroid-每个区域的质心（重心）
% Area-图像各个区域中像素的总个数

% 单连通
if(n==1)
    boundingbox = props.BoundingBox;
    x = boundingbox(1,1);
    y = boundingbox(1,2);
    width = boundingbox(1,3);
    heigth = boundingbox(1,4);
    centroid = props.Centroid;
    centroid_y = centroid(1,2);  % 只判断重心变化所以只需要y值
    sum = bwarea(bw);  % 判断目标区域面积，近似于on像素的总数。
% 多连通
else
    if n~=2 % 只留两个大连通域，可能出现两个连通域值特别相近的情况，导致死循环，需要优化。
        diff_area = sortArea(props,n);
        bw2 = bwareaopen(BW,diff_area,8);
        % BW2 = bwareaopen(BW,P,conn)
        % 删除二值图像BW中面积小于P的对象，默认情况下conn使用8领域
        [bw,n] = bwlabel(bw2,8);
    end
    props = regionprops(bw);  % 获得属性，Area，BoundingBox，Centroid
    if(props(1).Area > props(2).Area)  % 判断剩下的两个区域哪个像素点多
        maxArea = props(1).Area;
        minArea = props(2).Area;
        flag = 1;
    else
        maxArea = props(2).Area;
        minArea = props(1).Area;
        flag = 2;
    end
    sum = bwarea(bw);  % 计算二值图像中对象的总面积
    
    % 去除干扰点，即最大最小区域之间超过10倍关系
    if((maxArea/minArea) > 10)
        boundingbox = props(flag).BoundingBox;
        x = boundingbox(1,1);
        y = boundingbox(1,2);
        width = boundingbox(1,3);
        heigth = boundingbox(1,4);
        centroid = props(flag).Centroid;
        centroid_y = centroid(1,2);
    else  % 两个连通域相差小于10倍，以下代码有待测试。
        centroid_1 = props(1).Centroid;
        centroid_2 = props(2).Centroid;
        x_1 = centroid_1(1,1);
        y_1 = centroid_1(1,2);
        x_2 = centroid_2(1,1);
        y_2 = centroid_2(1,2);
        old_page_x = abs(x_1-x_2)/4;
        old_page_y = abs(y_1-y_2)/4;
        centroid_y = (y_1+y_2)/2;
        if(x_2 < x_1)
            x = x_2 - old_page_x;
            y = y_1 - old_page_y;
        else
            x = x_1 - old_page_x;
            y = y_2 - old_page_y;
        end
        width = abs(x_1 - x_2)*1.5;
        heigth = abs(y_1 - y_2)*1.5;
    end
end
end