% �İ���������������
clear;
figure;
imgRoot = 'source\test3\';
M = 4; % ǰN֡ͼ��
start = 1; % ��ʼ֡
alpha = 0.2; % between 0-1
img_num = M+1;
W_self = fspecial('gaussian',3,0.5); % ��˹ģ��
[x,y,z] = size(imread([imgRoot,num2str(1),'.jpg']));
u_xy = int16(zeros(x,y,z));
u_xy = rgb2gray(u_xy);
% ƽ��������ģ
for t=start:M
	u_temp = imread([imgRoot,num2str(t),'.jpg']);
	u_temp = imfilter(u_temp,W_self);
    u_temp = rgb2gray(u_temp);
    u_temp = medfilt2(u_temp,[3,3]);
	u_xy = u_xy + int16(u_temp);
end
u_xy = u_xy/(M-start+1);
while(img_num < 161)
    I = imread([imgRoot,num2str(img_num),'.jpg']);
    [u_xy,bw_pre] = bodyFrame2(u_xy,I,alpha,W_self,img_num);
    for i=1:x
        for j=1:y
            if u_xy(i,j) > 255
                u_xy(i,j) = 255;
            end
        end
    end
    %imshow(bw_pre);
    %title(img_num);
    %pause(0.5);
    img_num = img_num + 1;
end