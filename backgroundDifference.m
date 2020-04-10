imgRoot = 'source\test4\';
rootFrame = imread([imgRoot,num2str(1),'.jpg']);
[x,y,z] = size(rootFrame);
frame_all = zeros(x,y,z);
frame_src = zeros(x,y,z);
frame_avg = zeros(x,y,z);
for i=1:50
    frame_src = imread([imgRoot,num2str(i),'.jpg']);
    frame_src = double(frame_src);
    frame_all = frame_all + frame_src;
    frame_avg = frame_all / i;
    subplot(2,2,1);
    frame_src = uint8(frame_src);
    imshow(frame_src);
    title('原始图像');
    subplot(2,2,2);
    frame_avg = uint8(frame_avg);
    imshow(frame_avg);
    title('背景');
    gray_one = rgb2gray(frame_src);
    gray_twe = rgb2gray(frame_avg);
    f = gray_one - gray_twe;
    subplot(2,2,3);
    imshow(f);
    title('目标');
    pause(0.1);
end