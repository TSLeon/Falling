%优化bodyFrame2,测试中
function [BG_IMG,BW_IMG] = bodyFrame4(u_xy,I,alpha,W_self)
I = imfilter(I,W_self); % 高斯
I = rgb2gray(I);
I = adapthisteq(I,'NumTiles',[8 8],'ClipLimit',0.005);  % CLAHE
d_xy = abs(u_xy - int16(I));
L = imbinarize(uint8(d_xy));


[thr,sorh,keepapp] = ddencmp('den','wv',L);
xd = wdencmp('gbl',L,'sym4',2,thr,sorh,keepapp); % 小波
mask = imopen(xd, strel('rectangle',[2 2]));
mask = imclose(mask, strel('rectangle',[35 35]));
J = medfilt2(mask,[3,3]); % 中值
u_xy = alpha*int16(I) + (1-alpha)*u_xy;
BG_IMG = u_xy;
BW_IMG = bwfill(J,'holes',8);
end
