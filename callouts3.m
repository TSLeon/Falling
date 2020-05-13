% 改版目标标注函数2，测试中
function [labelStruct,target_type] = callouts3(BW,labelStruct)
[bw,n] = bwlabel(BW,8);
props = regionprops(bw);
target_type = 'single';
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
    threshold_area = 0;
    for i=1:n
        threshold_area = threshold_area + props(i).Area;
    end
    % threshold_area = double(int16(threshold_area / n));
    threshold_area = floor(threshold_area / n);
    bw2 = bwareaopen(BW,threshold_area,8);
    [m_bw,m_n] = bwlabel(bw2,8);
    if m_n == 1
        s_props = regionprops(m_bw);
        s_boundingbox = s_props.BoundingBox;
        labelStruct.x = s_boundingbox(1,1);
        labelStruct.y = s_boundingbox(1,2);
        labelStruct.width = s_boundingbox(1,3);
        labelStruct.heigth = s_boundingbox(1,4);
        centroid = s_props.Centroid;
        labelStruct.centroid_y = centroid(1,2);
        labelStruct.sum = bwarea(m_bw);
    else
        m_props = regionprops(m_bw);
        target_type = 'multiple';
        for i=1:m_n
            boundingbox = m_props(i).BoundingBox;
            labelStruct(i).x = boundingbox(1,1);
            labelStruct(i).y = boundingbox(1,2);
            labelStruct(i).width = boundingbox(1,3);
            labelStruct(i).heigth = boundingbox(1,4);
            centroid = m_props(i).Centroid;
            labelStruct(i).centroid_y = centroid(1,2);
        end
    end
end
end