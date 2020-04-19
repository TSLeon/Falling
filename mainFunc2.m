% 改版主函数，测试中
clear;
figure;
imgRoot = 'source\test3\';
M = 4; % 前N帧图像
start = 1; % 开始帧
alpha = 0.2; % between 0-1
img_num = M+1;
W_self = fspecial('gaussian',3,0.5); % 高斯模板
[x,y,z] = size(imread([imgRoot,num2str(1),'.jpg']));
u_xy = int16(zeros(x,y,z));
u_xy = rgb2gray(u_xy);
% 平均背景建模
for t=start:M
	u_temp = imread([imgRoot,num2str(t),'.jpg']);
	u_temp = imfilter(u_temp,W_self);
    u_temp = rgb2gray(u_temp);
    u_temp = adapthisteq(u_temp,'NumTiles',[8 8],'ClipLimit',0.005);
    u_temp = medfilt2(u_temp,[3,3]);
	u_xy = u_xy + int16(u_temp);
end
u_xy = u_xy/(M-start+1);
while(img_num <= 220)
    I = imread([imgRoot,num2str(img_num),'.jpg']);
    [u_xy,bw_pre] = bodyFrame2(u_xy,I,alpha,W_self,img_num);
    for i=1:x
        for j=1:y
            if u_xy(i,j) > 255
                u_xy(i,j) = 255;
            end
        end
    end
    labelStruct = callouts2(bw_pre);
    image(I);
    legend = text(labelStruct.x,labelStruct.y,['状态：','zheng']);
    set(legend,'Color','g','FontWeight','demi');
    rectangle('position',[labelStruct.x,labelStruct.y,labelStruct.width,labelStruct.heigth],'edgeColor','r');
    %imshow(bw_pre);
    %title(img_num);
    %pause(0.5);
    saveas(gcf,['result\test3\',num2str(img_num),'.jpg']);
    img_num = img_num + 1;
end