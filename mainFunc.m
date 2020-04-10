clear;
figure;
img_num = 61; % 上次测试点81
while(img_num < 350)
    imgRoot = 'source\test3\';
    cmp_pre = imread([imgRoot,num2str(img_num),'.jpg']);
    cmp_now = imread([imgRoot,num2str(img_num + 2),'.jpg']);
    bw_pre = bodyFrame(cmp_pre,cmp_now);  % 得到对比图像骨架
    hh = bodyFrame2(cmp_pre);
    
    target_pre = imread([imgRoot,num2str(img_num + 10),'.jpg']);
    target_now = imread([imgRoot,num2str(img_num + 12),'.jpg']);
    bw_now = bodyFrame(target_pre,target_now);  % 得到当前图像骨架
    
    [x_p,y_p,width_p,heigth_p,centroid_y_p,sum_p] = callouts(bw_pre);
    [x,y,width,heigth,centroid_y,sum] = callouts(bw_now);
    % if(sum < 300000)
    body_scale = abs(heigth/width);
    if((body_scale<=1.5) && (abs(centroid_y-centroid_y_p)>=10))
        result = '跌倒';
    else
        result = '正常';
    end
    %image(cmp_now);
    %rectangle('position',[x_p,y_p,width_p,heigth_p,],'edgeColor','r');
    image(target_now);
    legend = text(x,y,['状态：',result]);
    set(legend,'Color','g','FontWeight','demi');
    rectangle('position',[x,y,width,heigth],'edgeColor','r');
    % rectangle('position',[1 2  5 6]) 绘制左下角位于（1,2）位置的矩形，宽度设置为5，高度设置为6。
    saveas(gcf,['result\test3\',num2str(img_num),'.jpg']);
    %end
    img_num = img_num + 10;
end