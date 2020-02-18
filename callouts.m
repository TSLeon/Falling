function [x,y,width,heigth,centroid_y,sum] = callouts(BW)
[bw,n] = bwlabel(BW,8);  % Ѱ��������ͨ�򲢱�ע����8��ͨѰ�ң�bwΪ��Ǻ�ͼƬ��nΪ��ͨ�����
props = regionprops(bw);
% �õ�Area��Centroid��BoundingBox��������
% BoundingBox-������Ӧ�������С����
% Centroid-ÿ����������ģ����ģ�
% Area-ͼ��������������ص��ܸ���

% ����ͨ
if(n==1)
    boundingbox = props.BoundingBox;
    x = boundingbox(1,1);
    y = boundingbox(1,2);
    width = boundingbox(1,3);
    heigth = boundingbox(1,4);
    centroid = props.Centroid;
    centroid_y = centroid(1,2);  % ֻ�ж����ı仯����ֻ��Ҫyֵ
    sum = bwarea(bw);  % �ж�Ŀ�����������������on���ص�������
% ����ͨ
else
    if n~=2 % ֻ����������ͨ�򣬿��ܳ���������ͨ��ֵ�ر�����������������ѭ������Ҫ�Ż���
        diff_area = sortArea(props,n);
        bw2 = bwareaopen(BW,diff_area,8);
        % BW2 = bwareaopen(BW,P,conn)
        % ɾ����ֵͼ��BW�����С��P�Ķ���Ĭ�������connʹ��8����
        [bw,n] = bwlabel(bw2,8);
    end
    props = regionprops(bw);  % ������ԣ�Area��BoundingBox��Centroid
    if(props(1).Area > props(2).Area)  % �ж�ʣ�µ����������ĸ����ص��
        maxArea = props(1).Area;
        minArea = props(2).Area;
        flag = 1;
    else
        maxArea = props(2).Area;
        minArea = props(1).Area;
        flag = 2;
    end
    sum = bwarea(bw);  % �����ֵͼ���ж���������
    
    % ȥ�����ŵ㣬�������С����֮�䳬��10����ϵ
    if((maxArea/minArea) > 10)
        boundingbox = props(flag).BoundingBox;
        x = boundingbox(1,1);
        y = boundingbox(1,2);
        width = boundingbox(1,3);
        heigth = boundingbox(1,4);
        centroid = props(flag).Centroid;
        centroid_y = centroid(1,2);
    else  % ������ͨ�����С��10�������´����д����ԡ�
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