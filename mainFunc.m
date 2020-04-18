% ������
clear;
figure;
imgRoot = 'source\test3\'; 
img_num = 61; % �ϴβ��Ե�81
M = 4; % ǰN֡ͼ��
start = 1; % ��ʼ֡
W_self = fspecial('gaussian',3,0.5); % ��˹ģ��
[x,y,z] = size(imread([imgroot,num2str(1),'.jpg']));
u_xy = int16(zeros(x,y,z));
u_xy = rgb2gray(u_xy);
% ƽ��������ģ
for t=start:M
	u_temp = imread([imgroot,num2str(t),'.jpg']);
	u_temp = imfilter(u_temp,W_self);
    u_temp = rgb2gray(u_temp);
    u_temp = medfilt2(u_temp,[3,3]);
	u_xy = u_xy + int16(u_temp);
end
while(img_num < 350)
    cmp_pre = imread([imgRoot,num2str(img_num),'.jpg']);
    cmp_now = imread([imgRoot,num2str(img_num + 2),'.jpg']);
    bw_pre = bodyFrame(cmp_pre,cmp_now);  % �õ��Ա�ͼ��Ǽ�
    hh = bodyFrame2(cmp_pre);
    
    target_pre = imread([imgRoot,num2str(img_num + 10),'.jpg']);
    target_now = imread([imgRoot,num2str(img_num + 12),'.jpg']);
    bw_now = bodyFrame(target_pre,target_now);  % �õ���ǰͼ��Ǽ�
    
    [x_p,y_p,width_p,heigth_p,centroid_y_p,sum_p] = callouts(bw_pre);
    [x,y,width,heigth,centroid_y,sum] = callouts(bw_now);
    % if(sum < 300000)
    body_scale = abs(heigth/width);
    if((body_scale<=1.5) && (abs(centroid_y-centroid_y_p)>=10))
        result = '����';
    else
        result = '����';
    end
    %image(cmp_now);
    %rectangle('position',[x_p,y_p,width_p,heigth_p,],'edgeColor','r');
    image(target_now);
    legend = text(x,y,['״̬��',result]);
    set(legend,'Color','g','FontWeight','demi');
    rectangle('position',[x,y,width,heigth],'edgeColor','r');
    % rectangle('position',[1 2  5 6]) �������½�λ�ڣ�1,2��λ�õľ��Σ��������Ϊ5���߶�����Ϊ6��
    saveas(gcf,['result\test3\',num2str(img_num),'.jpg']);
    %end
    img_num = img_num + 10;
end