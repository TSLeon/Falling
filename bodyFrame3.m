%优化bodyFrame2,测试中
function [BG_IMG,BW_IMG] = bodyFrame3(u_xy,I,alpha,W_self,se)
I = imfilter(I,W_self); % 高斯
I = rgb2gray(I);
I = adapthisteq(I,'NumTiles',[8 8],'ClipLimit',0.005);  % CLAHE
%I = medfilt2(I,[3,3]);
d_xy = abs(u_xy - int16(I));
L = imbinarize(uint8(d_xy));
%filteredRGB = imfilter(L,W_self);
uSobel = edge(L); % sobel
[thr,sorh,keepapp] = ddencmp('den','wv',uSobel);
xd = wdencmp('gbl',uSobel,'sym4',2,thr,sorh,keepapp); % 小波
%------------------------------------
%mask = imopen(xd, strel('rectangle',[3, 3]));
%------------------------------------
closeBW = imclose(xd,se);
%closeBW = imclose(mask, strel('rectangle',[15, 15]));
J = medfilt2(closeBW,[3,3]); % 中值
u_xy = alpha*int16(I) + (1-alpha)*u_xy;
BG_IMG = u_xy;
BW_IMG = bwfill(J,'holes',8);
end
