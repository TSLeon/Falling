% 改版提取目标函数，测试中
function [BG_IMG,BW_IMG,fgMask] = bodyFrame2(u_xy,I,alpha,W_self,img_num)
I = imfilter(I,W_self);
I = rgb2gray(I);
I = adapthisteq(I,'NumTiles',[8 8],'ClipLimit',0.005);  % CLAHE
I = medfilt2(I,[3,3]);
d_xy = abs(u_xy - int16(I));  % 背景差分
L = imbinarize(uint8(d_xy));  % 二值化，默认使用otsu
%imwrite(L,['test\L',num2str(img_num),'.jpg']);
% CLAHE增强对比度
%L = adapthisteq(uint8(L),'NumTiles',[8 8],'ClipLimit',0.005);  % 暗处更暗，光亮更亮效果
% 高斯滤波
H = fspecial('gaussian',3,1);  % 返回一个高斯低通滤波器
filteredRGB = imfilter(L,H);  % 通过将滤镜应用与原始图像以创建具有运动模糊的图像
% 边缘检测
uSobel = filteredRGB;
[X,Y] = size(filteredRGB);
F = double(filteredRGB);
for x=2:X-1
    for y=2:Y-1
        Gx = (F(x+1,y-1)+2*F(x+1,y)+F(x+1,y+1)) - (F(x-1,y-1)+2*F(x-1,y)+F(x-1,y+1));
        Gy = (F(x-1,y-1)+2*F(x,y-1)+F(x+1,y-1))-(F(x-1,y+1)+2*F(x,y+1)+F(x+1,y+1));
        uSobel(x,y) = sqrt(Gx^2+Gy^2);
    end
end
fgMask = uSobel;
% 二值化，将目标与背景分割
%T = graythresh(uSobel);  % 使用最大类间方差法找到图片的一个合适的阈值
%BW = im2bw(uSobel,T);  % im2bw是将灰度图像转化为二值图像，需要一个阈值
% BW = imbinarize(uSobel);
%imwrite(uSobel,['test\uSobel',num2str(img_num),'.jpg']);
% 小波去噪
[thr,sorh,keepapp] = ddencmp('den','wv',uSobel);  % 自动生成小波消噪或压缩的阈值选取方案
xd = wdencmp('gbl',uSobel,'sym4',2,thr,sorh,keepapp);  % 一维或二维信号的去噪或压缩
% 中值滤波
J = medfilt2(xd,[3,3]);
% 得到处理后的二值图像，接下来进行形态处理，通过结构元素将目标区域填充起来。
se = strel('disk',20);  % 创建一个半径为20的圆盘状结构元素。应该是框架,越小填充越不满。
closeBW = imclose(J,se);  % 形态学闭运算，填充目标区域
% 中值滤波去噪
J = medfilt2(closeBW,[15,15]);  % 原本为15,15
u_xy = alpha*int16(I) + (1-alpha)*u_xy;  % 更新背景
BG_IMG = u_xy;
BW_IMG = bwfill(J,'holes',8);
%imwrite(BW_IMG,['test\bw_img',num2str(img_num),'.jpg']);
% 二值化
%T = graythresh(J);
%img_BW = im2bw(J,T);
%img_BW = bwfill(img_BW,'holes',8);  % 填补
end