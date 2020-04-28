% �İ���ȡĿ�꺯����������
function [BG_IMG,BW_IMG] = bodyFrame2(u_xy,I,alpha,W_self)
I = imfilter(I,W_self);  %  gausiian filter
I = rgb2gray(I);
I = adapthisteq(I,'NumTiles',[8 8],'ClipLimit',0.005);  % CLAHE
I = medfilt2(I,[3,3]);  % mediam filter
d_xy = abs(u_xy - int16(I));  % �������
L = imbinarize(uint8(d_xy));  % ��ֵ����Ĭ��ʹ��otsu
% CLAHE��ǿ�Աȶ�
%L = adapthisteq(uint8(L),'NumTiles',[8 8],'ClipLimit',0.005);  % ������������������Ч��
% ��˹�˲�
H = fspecial('gaussian',3,1);  % ����һ����˹��ͨ�˲���
filteredRGB = imfilter(L,H);  % ͨ�����˾�Ӧ����ԭʼͼ���Դ��������˶�ģ����ͼ��
% ��Ե���
uSobel = filteredRGB;
[X,Y] = size(filteredRGB);
F = double(filteredRGB);
for x=2:X-1
    for y=2:Y-1
        Gx = (F(x+1,y-1)+2*F(x+1,y)+F(x+1,y+1))...
            -(F(x-1,y-1)+2*F(x-1,y)+F(x-1,y+1));
        Gy = (F(x-1,y-1)+2*F(x,y-1)+F(x+1,y-1))...
            -(F(x-1,y+1)+2*F(x,y+1)+F(x+1,y+1));
        uSobel(x,y) = sqrt(Gx^2+Gy^2);
    end
end
% С��ȥ��
[thr,sorh,keepapp] = ddencmp('den','wv',uSobel);  % �Զ�����С�������ѹ������ֵѡȡ����
xd = wdencmp('gbl',uSobel,'sym4',2,thr,sorh,keepapp);  % һά���ά�źŵ�ȥ���ѹ��
% ��ֵ�˲�
J = medfilt2(xd,[3,3]);
% �õ������Ķ�ֵͼ�񣬽�����������̬����ͨ���ṹԪ�ؽ�Ŀ���������������
se = strel('disk',20);  % ����һ���뾶Ϊ20��Բ��״�ṹԪ�ء�Ӧ���ǿ��,ԽС���Խ������
closeBW = imclose(J,se);  % ��̬ѧ�����㣬���Ŀ������
% ��ֵ�˲�ȥ��
J = medfilt2(closeBW,[15,15]);  % ԭ��Ϊ15,15
u_xy = alpha*int16(I) + (1-alpha)*u_xy;  % ���±���
BG_IMG = u_xy;
BW_IMG = bwfill(J,'holes',8);
end
