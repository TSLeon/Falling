% 提取目标函数原版
function img_BW = bodyFrame(background,target_aim)
% 灰度化
frame_pre = rgb2gray(background);
frame_now = rgb2gray(target_aim);

% 目标提取
diff_one = abs(frame_pre - frame_now);
diff_twe = abs(frame_now - frame_pre);
L = diff_one + diff_twe;

% CLAHE增强对比度
% L = adapthisteq(L,'NumTiles',[40 40],'ClipLimit',0.01);
L = adapthisteq(L,'NumTiles',[8 8],'ClipLimit',0.005);  % 暗处更暗，光亮更亮效果
% 使用文档例子亮度低于当前代码。但噪音引入少。

% 高斯滤波
H = fspecial('gaussian',3,1);  % 返回一个高斯低通滤波器
filteredRGB = imfilter(L,H);  % 通过将滤镜应用与原始图像以创建具有运动模糊的图像

% 边缘检测
[high,width] = size(filteredRGB);
F2 = double(filteredRGB);
U = double(filteredRGB);
uSobel = filteredRGB;
for i = 2:high - 1
    for j = 2:width - 1
        Gx = (U(i+1, j-1) + 2*U(i+1, j) + F2(i+1, j+1)) - (U(i-1, j-1) + 2*U(i-1, j) + F2(i-1, j+1));
        Gy = (U(i-1, j+1) + 2*U(i, j+1) + F2(i+1, j+1)) - (U(i-1, j-1) + 2*U(i, j-1) + F2(i+1, j-1));
        uSobel(i, j) = sqrt(Gx^2 + Gy^2);
    end
end

% 二值化，将目标与背景分割
T = graythresh(uSobel);  % 使用最大类间方差法找到图片的一个合适的阈值
BW = im2bw(uSobel,T);  % im2bw是将灰度图像转化为二值图像，需要一个阈值

% 小波去噪
[thr,sorh,keepapp] = ddencmp('den','wv',BW);  % 自动生成小波消噪或压缩的阈值选取方案
% [THR,SORH,KEEPAPP,CRIT] = ddencmp(IN1,IN2,X)
% IN1=den表示去噪，cmp表示压缩。IN2=wv表示小波，wp表示小波包。X为输入一维或二维信号
% THR是返回的阈值，SORH是软阈值或硬阈值的选择参数，KEEPAPP表示保存低频信号，CRIT是熵名(只有小波包时选用)
xd = wdencmp('gbl',BW,'sym4',2,thr,sorh,keepapp);  % 一维或二维信号的去噪或压缩
% [XC,CXC,LXC,PERF0,PERFL2] = wdencmp('gbl',X,wname,N,THR,SORH,KEEPAPP)
% 'gbl'表示每层采用相同的阈值处理，X为输入信号，wname表示所用的小波函数，N表示小波分解层数
% 后三个为ddencmp函数返回值。官方文档用全局默认阈值去噪例子就是上面两句。
% 官方文档：https://ww2.mathworks.cn/help/wavelet/ref/wdencmp.html?s_tid=doc_ta
% 中值滤波
J = medfilt2(xd,[3,3]);
% J = medfilt2(I,[m,n])
% J为滤波后的图像，I是原图，m,n是处理模板大小，默认为3x3
% 得到处理后的二值图像，接下来进行形态处理，通过结构元素将目标区域填充起来。

%+++++++++++++++++++利用bwfill填充二值图像+++++++++++++++++++++++++
% BW2 = bwfill(J,'holes',8); % 填充的很饱满，但是连通噪声一起填充了。可以放在形态学后，用来填补形态学空洞部分。
%---------------------------END----------------------------------

se = strel('disk',20);  % 创建一个半径为20的圆盘状结构元素。应该是框架,越小填充越不满。
% 查看元素样式：
% figure
% imshow(se.Neighborhood)
closeBW = imclose(J,se);  % 形态学闭运算，填充目标区域

% 中值滤波去噪
J = medfilt2(closeBW,[15,15]);  % 原本为15,15
% J = bwfill(J,'holes',8); % 填补空缺，前提是噪声处理非常好，否则反而会把噪声填补出来，且影响较大。
% 二值化
T = graythresh(J);
img_BW = im2bw(J,T);
img_BW = bwfill(img_BW,'holes',8);  % 填补
end