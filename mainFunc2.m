% �İ���������������
imgRoot = 'source\test3\';
figure;
%------------------------------------
videoPlayer = vision.VideoPlayer;  % ����һ����Ƶ������
param = defaultParam();
adparam = defaultAdparam();
%-------------------------------------
M = 1; % ǰN֡ͼ��
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
    u_temp = adapthisteq(u_temp,'NumTiles',[8 8],'ClipLimit',0.005);
    u_temp = medfilt2(u_temp,[3,3]);
	u_xy = u_xy + int16(u_temp);
end
u_xy = u_xy/(M-start+1);
while(img_num <= 220)
    I = imread([imgRoot,num2str(img_num),'.jpg']);
    [u_xy,bw_pre] = bodyFrame2(u_xy,I,alpha,W_self);
    for i=1:x
        for j=1:y
            if u_xy(i,j) > 255
                u_xy(i,j) = 255;
            end
        end
    end
    labelStruct = callouts2(bw_pre);
    %---------------------------------------------------
    if labelStruct.x == y && labelStruct.y == x
        adparam.isObjectDetected = false;
    else
        adparam.isObjectDetected = true;
    end
    adparam.detectedLocation = [labelStruct.x,labelStruct.y,...
        labelStruct.width,labelStruct.heigth];
    [adparam, labelInfo] = trackSingleObject(param,adparam);
    if ~isempty(labelInfo.trackedLocation)
        shape = 'rectangle';
        region = labelInfo.trackedLocation;
        combinedImage = insertObjectAnnotation(I, shape, region,...
            {labelInfo.label},'FontSize',50,'LineWidth',5);
        imshow(combinedImage);
        %videoPlayer(combinedImage);
        saveas(gcf,['result\test3\',num2str(img_num),'.jpg'])
    end
    %---------------------------------------------------
    img_num = img_num + 1;
end
release(videoPlayer);
function param = defaultParam
param.motionModel           = 'ConstantAcceleration';
param.initialLocation       = 'Same as first detection';
param.initialEstimateError  = 1E5 * ones(1, 3);
param.motionNoise           = [25, 10, 1];
param.measurementNoise      = 25;
param.segmentationThreshold = 0.05;
end
function adparam = defaultAdparam
adparam.isTrackInitialized = false;
adparam.isObjectDetected = true;
end