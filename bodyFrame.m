% ��ȡĿ�꺯��ԭ��
function img_BW = bodyFrame(background,target_aim)
% �ҶȻ�
frame_pre = rgb2gray(background);
frame_now = rgb2gray(target_aim);

% Ŀ����ȡ
diff_one = abs(frame_pre - frame_now);
diff_twe = abs(frame_now - frame_pre);
L = diff_one + diff_twe;

% CLAHE��ǿ�Աȶ�
% L = adapthisteq(L,'NumTiles',[40 40],'ClipLimit',0.01);
L = adapthisteq(L,'NumTiles',[8 8],'ClipLimit',0.005);  % ������������������Ч��
% ʹ���ĵ��������ȵ��ڵ�ǰ���롣�����������١�

% ��˹�˲�
H = fspecial('gaussian',3,1);  % ����һ����˹��ͨ�˲���
filteredRGB = imfilter(L,H);  % ͨ�����˾�Ӧ����ԭʼͼ���Դ��������˶�ģ����ͼ��

% ��Ե���
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

% ��ֵ������Ŀ���뱳���ָ�
T = graythresh(uSobel);  % ʹ�������䷽��ҵ�ͼƬ��һ�����ʵ���ֵ
BW = im2bw(uSobel,T);  % im2bw�ǽ��Ҷ�ͼ��ת��Ϊ��ֵͼ����Ҫһ����ֵ

% С��ȥ��
[thr,sorh,keepapp] = ddencmp('den','wv',BW);  % �Զ�����С�������ѹ������ֵѡȡ����
% [THR,SORH,KEEPAPP,CRIT] = ddencmp(IN1,IN2,X)
% IN1=den��ʾȥ�룬cmp��ʾѹ����IN2=wv��ʾС����wp��ʾС������XΪ����һά���ά�ź�
% THR�Ƿ��ص���ֵ��SORH������ֵ��Ӳ��ֵ��ѡ�������KEEPAPP��ʾ�����Ƶ�źţ�CRIT������(ֻ��С����ʱѡ��)
xd = wdencmp('gbl',BW,'sym4',2,thr,sorh,keepapp);  % һά���ά�źŵ�ȥ���ѹ��
% [XC,CXC,LXC,PERF0,PERFL2] = wdencmp('gbl',X,wname,N,THR,SORH,KEEPAPP)
% 'gbl'��ʾÿ�������ͬ����ֵ����XΪ�����źţ�wname��ʾ���õ�С��������N��ʾС���ֽ����
% ������Ϊddencmp��������ֵ���ٷ��ĵ���ȫ��Ĭ����ֵȥ�����Ӿ����������䡣
% �ٷ��ĵ���https://ww2.mathworks.cn/help/wavelet/ref/wdencmp.html?s_tid=doc_ta
% ��ֵ�˲�
J = medfilt2(xd,[3,3]);
% J = medfilt2(I,[m,n])
% JΪ�˲����ͼ��I��ԭͼ��m,n�Ǵ���ģ���С��Ĭ��Ϊ3x3
% �õ������Ķ�ֵͼ�񣬽�����������̬����ͨ���ṹԪ�ؽ�Ŀ���������������

%+++++++++++++++++++����bwfill����ֵͼ��+++++++++++++++++++++++++
% BW2 = bwfill(J,'holes',8); % ���ĺܱ�����������ͨ����һ������ˡ����Է�����̬ѧ���������̬ѧ�ն����֡�
%---------------------------END----------------------------------

se = strel('disk',20);  % ����һ���뾶Ϊ20��Բ��״�ṹԪ�ء�Ӧ���ǿ��,ԽС���Խ������
% �鿴Ԫ����ʽ��
% figure
% imshow(se.Neighborhood)
closeBW = imclose(J,se);  % ��̬ѧ�����㣬���Ŀ������

% ��ֵ�˲�ȥ��
J = medfilt2(closeBW,[15,15]);  % ԭ��Ϊ15,15
% J = bwfill(J,'holes',8); % ���ȱ��ǰ������������ǳ��ã����򷴶�����������������Ӱ��ϴ�
% ��ֵ��
T = graythresh(J);
img_BW = im2bw(J,T);
img_BW = bwfill(img_BW,'holes',8);  % �
end