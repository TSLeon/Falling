clear
imgroot = 'source\test3\';
% M>30+inter
M = 60;
figure;
[x,y,z] = size(imread([imgroot,num2str(1),'.jpg']));
frame_all = zeros(x,y,z);
frame_all = rgb2gray(frame_all);
for i=1:M
    frame_temp = imread([imgroot,num2str(i),'.jpg']);
    frame_temp = rgb2gray(frame_temp);
    frame_all = frame_all + double(frame_temp);
end
frame_avg = frame_all/M; % double

%diff
F_t = zeros(x,y,z);
F_t = rgb2gray(F_t);
inter = 3;
for t=inter+1:M
    I1 = imread([imgroot,num2str(t),'.jpg']);
    I2 = imread([imgroot,num2str(t-inter),'.jpg']);
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
    f_t = abs(I1-I2);
    F_t = F_t + double(f_t);
end
u_diff = F_t/M;

% diff_std
Diff = zeros(x,y,z);
diff = zeros(x,y,z);
Diff = rgb2gray(Diff);
diff = rgb2gray(diff);
for t=inter+1:M
    I1 = imread([imgroot,num2str(t),'.jpg']);
    I2 = imread([imgroot,num2str(t-inter),'.jpg']);
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
    f_t = abs(I1-I2);
    f_t = double(f_t);
    diff = (f_t-u_diff).*(f_t-u_diff);
    Diff = Diff + diff;
end
diff_std_insqrt = Diff/M;
diff_std = sqrt(diff_std_insqrt);


% ---------------------------------------start loop------
for k=1:60
    % threshold
    threshold = u_diff + 2*diff_std;
    
    % frontground
    I = imread([imgroot,num2str(M+k),'.jpg']);
    I = rgb2gray(I);
    d = abs(double(I) - frame_avg);
    
    % update
    a = 0.65;  % 0-1
    frame_avg = (1-a)*frame_avg + a*double(I);
    for i=1:x  % ��֤����ֵ��0-255֮��
        for j=1:y
            if frame_avg(i,j) > 255
                frame_avg(i,j) = 255;
            end
        end
    end
    I1 = rgb2gray(imread([imgroot,num2str(M+k-inter),'.jpg']));
    f_x = double(abs(I-I1));
    u_diff = (1-a)*u_diff + a*f_x;
    diff_std = (1-a)*diff_std + a*abs(f_x - u_diff);
    
    
    
    % out
    out = d > threshold;
    temp = uint8(out);
    temp(temp==1) = 255;
    
    %sel_thred = zeros(x,y);
    %for i=1:x
    %    for j=1:y
    %        if d(i,j) > 75
    %            sel_thred(i,j) = 1;
    %        else
    %            sel_thred(i,j) = 0;
    %        end
    %    end
    %end
    
    sel_tem = zeros(x,y);
    for i=1:x
        for j=1:y
            if d(i,j) > threshold(i,j)
                sel_tem(i,j) = 255;
            else
                sel_tem(i,j) = 0;
            end
        end
    end
    
    %-------------------------ȥ��---------------------
    L = adapthisteq(sel_tem,'NumTiles',[8 8],'ClipLimit',0.005);
    
    H = fspecial('gaussian',3,1);  % ����һ����˹��ͨ�˲���
    filteredRGB = imfilter(L,H);  % ͨ�����˾�Ӧ����ԭʼͼ���Դ��������˶�ģ����ͼ��
    
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
    
    subplot(4,2,1);
    imshow(uint8(frame_avg));
    title('����');
    
    subplot(4,2,2);
    imshow(uint8(d));
    title('��');
    
    subplot(4,2,3);
    imshow(temp);
    title('Ŀ��');
    
    subplot(4,2,4);
    imshow(sel_tem);
    title('����Ӧ��ֵѭ��');
    
    subplot(4,2,5);
    imshow(L);
    title('��ǿ�Աȶ�');
    
    subplot(4,2,6);
    imshow(filteredRGB);
    title('��˹�˲�');
    
    subplot(4,2,7);
    imshow(uSobel);
    title('��Ե���');
    pause(0.1);
end
