% 改版主函数，测试中
imgRoot = 'source\test3\';
figure;
%------------------------------------
videoPlayer = vision.VideoPlayer;  % 创建一个视频播放器
param = defaultParam();
adparam = defaultAdparam();
%-------------------------------------
M = 1; % 前N帧图像
start = 1; % 开始帧
alpha = 0.2; % between 0-1
shape = 'rectangle';
img_num = M+1;
W_self = 1/16*[1,2,1;2,4,2;1,2,1];%fspecial('gaussian',3,0.5); % 高斯模板
[x,y,z] = size(imread([imgRoot,num2str(1),'.jpg']));
u_xy = int16(zeros(x,y,z));
u_xy = rgb2gray(u_xy);
% 平均背景建模
for t=start:M
	u_temp = imread([imgRoot,num2str(t),'.jpg']);
	u_temp = imfilter(u_temp,W_self);
    u_temp = rgb2gray(u_temp);
    u_temp = adapthisteq(u_temp,'NumTiles',[8 8],'ClipLimit',0.005);
    u_temp = medfilt2(u_temp,[3,3]);
	u_xy = u_xy + int16(u_temp);
end
u_xy = u_xy/(M-start+1);
count = 1;
pre_label = 'Inital';
while(img_num <= 220)
    I = imread([imgRoot,num2str(img_num),'.jpg']);
    if count == 1 || count == 10
        [u_xy,bw_pre] = bodyFrame2(u_xy,I,alpha,W_self);
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
            region = labelInfo.trackedLocation;
            %combinedImage = insertObjectAnnotation(I, shape, region,...
            %    {labelInfo.label},'FontSize',50,'LineWidth',5);
            %imshow(combinedImage);
            %videoPlayer(combinedImage);
            %saveas(gcf,['result\test3\',num2str(img_num),'.jpg'])
        end
        if count == 1
            pre_centroid = labelStruct.centroid_y;
            pre_width = region(3);
            pre_height = region(4);
            count = count + 1;
        else
            body_scale = region(4)/region(3);
            centroid_diff = abs(labelStruct.centroid_y - pre_centroid);
            if body_scale <=1.5 && centroid_diff >=10
                if strcmp(pre_label,'Falled')
                    self_label = 'Stand up';
                else
                    self_label = 'Falled';
                end
            else
                if strcmp(pre_label,'Falled')
                    self_label = 'Falled';
                else
                    self_label = 'Normal';
                end
            end
            pre_label = self_label;
            %combinedImage = insertObjectAnnotation(I, shape, region,...
            %    {self_label},'FontSize',50,'LineWidth',5);
            imshow(I);
            title(img_num);
            pre_centroid = labelStruct.centroid_y;
            pre_width = region(3);
            pre_height = region(4);
            count = 2;
        end
    else
        %imshow(I);
        I = imfilter(I,W_self);
        I = rgb2gray(I);
        I = adapthisteq(I,'NumTiles',[8 8],'ClipLimit',0.005);
        I = medfilt2(I,[3,3]);
        u_xy = alpha*int16(I) + (1-alpha)*u_xy;
        count = count + 1;
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