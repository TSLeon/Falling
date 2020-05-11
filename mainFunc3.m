% 改版主函数2，测试中
imgRoot = 'source\test3\';
videoReader = VideoReader('test3.mp4');
figure;
%------------------------------------
%videoPlayer = vision.VideoPlayer;  % 创建一个视频播放器
param = defaultParam();
adparam = defaultAdparam();
%-------------------------------------
M = 1; % 前N帧图像
start = 1; % 开始帧
alpha = 0.2; % between 0-1
total = M-start+1;
back_count = total;
shape = 'rectangle';
W_self = 1/16*[1,2,1;2,4,2;1,2,1];
se = strel('disk',20);
%-----------------------------------------
[x,y,z] = size(imread([imgRoot,num2str(1),'.jpg']));
u_xy = int16(zeros(x,y,z));
u_xy = rgb2gray(u_xy);
count = 1;
pre_label = 'Inital';
imName = 1;
status_list = initial_status();
firstFrame = true; % 第一遍10帧
while hasFrame(videoReader)
    I = readFrame(videoReader);
    if back_count > 0
        I = imfilter(I,W_self);
        I = rgb2gray(I);
        I = adapthisteq(I,'NumTiles',[8 8],'ClipLimit',0.005);
        I = medfilt2(I,[3,3]);
        u_xy = u_xy + int16(I);
        back_count = back_count - 1;
    % 背景求和
    else
        if back_count == 0
            u_xy = u_xy/(total);
            back_count = back_count - 1;
        % 求背景平均值
        end
        [u_xy,bw_pre] = bodyFrame3(u_xy,I,alpha,W_self,se);
        labelStruct = callouts2(bw_pre);
        %---------------------------------------------------
        if labelStruct.width == y && labelStruct.heigth == x
            adparam.isObjectDetected = true;
        else
            adparam.isObjectDetected = true;
        end
        adparam.detectedLocation = [labelStruct.x,labelStruct.y,...
            labelStruct.width,labelStruct.heigth];
        [adparam, labelInfo] = trackSingleObject(param,adparam);
        if ~isempty(labelInfo.trackedLocation)
            region = labelInfo.trackedLocation;
            if firstFrame
                status_list(count) = labelStruct;
            else
                status_list = move_list(status_list);
                status_list(10) = labelStruct;
            end
            if count == 1
                pre_centroid = labelStruct.centroid_y;
                pre_width = region(3);
                pre_height = region(4);
                count = count + 1;
                combinedImage = insertObjectAnnotation(I, shape, region,...
                    {pre_label},'FontSize',50,'LineWidth',5);
                imshow(combinedImage);
            elseif count == 10
                if firstFrame
                    firstFrame = false;
                end
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
                combinedImage = insertObjectAnnotation(I, shape, region,...
                    {self_label},'FontSize',50,'LineWidth',5);
                imshow(combinedImage);
                pre_centroid = labelStruct.centroid_y;
                pre_width = region(3);
                pre_height = region(4);
                count = 1;
            else
                combinedImage = insertObjectAnnotation(I, shape, region,...
                    {pre_label},'FontSize',50,'LineWidth',5);
                imshow(combinedImage);
                count = count + 1;
            end
            imwrite(combinedImage,['test3\',num2str(imName),'.jpg'],'jpg');
        else
            % 没有跟踪到
            imshow(I);
            imwrite(I,['test3\',num2str(imName),'.jpg'],'jpg');
        end
        %---------------------------------------------------
    end
    imName = imName + 1;
end
%release(videoPlayer);
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
function status_list = move_list(lists)
for i=1:9
    lists(i) = lists(i+1);
end
status_list = lists;
end
function status_list = initial_status
status_list(1).x = 0;
status_list(1).y = 0;
status_list(1).width = 0;
status_list(1).heigth = 0;
status_list(1).centroid_y = 0;
status_list(1).sum = 0;
end