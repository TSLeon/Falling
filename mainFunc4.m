% 改版主函数3，测试跌倒判断
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
%se = strel('disk',20);
%-----------------------------------------
[x,y,z] = size(imread([imgRoot,num2str(1),'.jpg']));
u_xy = int16(zeros(x,y,z));
u_xy = rgb2gray(u_xy);
count = 1;
pre_label = 'Inital';
imName = 1;
status_list = zeros(10,4);
firstFrame = true; % 第一遍10帧
while hasFrame(videoReader)
    I = readFrame(videoReader);
    labelStruct = defaultLabel(y,x);
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
        [u_xy,bw_pre] = bodyFrame4(u_xy,I,alpha,W_self);
        [labelStruct,target_type] = callouts3(bw_pre,labelStruct);
        %---------------------------------------------------
        if strcmp(target_type,'single') % 单目标
            if labelStruct.width == y && labelStruct.heigth == x
                adparam.isObjectDetected = false;
            else
                adparam.isObjectDetected = true;
            end
            adparam.detectedLocation = [labelStruct.x,labelStruct.y,...
                labelStruct.width,labelStruct.heigth];
            % 卡尔曼滤波
            [adparam, labelInfo] = trackSingleObject(param,adparam);
            if ~isempty(labelInfo.trackedLocation)
                region = labelInfo.trackedLocation;
                if firstFrame
                    status_list(count,:) = region;
                else
                    status_list = move_list(status_list);
                    status_list(10,:) = region;
                end
                % 记录10帧的内容
                if count == 10
                    if firstFrame
                        firstFrame = false;
                    end
                    count = count + 1;
                end
                if ~firstFrame
                    body_scale = region(4)/region(3);
                    %centroid_diff = labelStruct.centroid_y -...
                    %    status_list(1).centroid_y;
                    present_data = region(2) + region(4)/2;
                    old_data = status_list(1,2) + status_list(1,4)/2;
                    centroid_diff = present_data - old_data;
                    %----------------------------
                    if region(1)~=status_list(9,1)||...
                            region(2)~=status_list(9,2)
                        self_label = 'Moving';
                        if body_scale<=1.5&&abs(centroid_diff)>10
                            if centroid_diff > 0 % 重心向上
                                self_label = 'Falled';
                            else % 重心向下
                                self_label = 'Stand up';
                            end
                        else
                            if strcmp(pre_label,'Falled')
                                self_label = 'Falled';
                            end
                            %disp(3);
                        end
                    else
                        self_label = 'Initial';
                        disp(4);
                    end
                    %----------------------------
                    pre_label = self_label;
                    combinedImage = insertObjectAnnotation(I, shape, region,...
                        {self_label},'FontSize',50,'LineWidth',5);
                    combin = insertObjectAnnotation(I,shape,[labelStruct.x,labelStruct.y,...
                        labelStruct.width,labelStruct.heigth],{self_label});
                    subplot(2,2,1);
                    imshow(combinedImage);
                    title('1');
                    subplot(2,2,2);
                    imshow(combin);
                else
                    combinedImage = insertObjectAnnotation(I, shape, region,...
                        {pre_label},'FontSize',50,'LineWidth',5);
                    combin = insertObjectAnnotation(I,shape,[labelStruct.x,labelStruct.y,...
                        labelStruct.width,labelStruct.heigth],{pre_label});
                    subplot(2,2,1);
                    imshow(combinedImage);
                    title('2');
                    subplot(2,2,2);
                    imshow(combin);
                    count = count + 1;
                end
                imwrite(combinedImage,['test4\',num2str(imName),'.jpg'],...
                    'jpg');
                imwrite(combin,['test4\l',num2str(imName),'.jpg'],'jpg');
                imwrite(bw_pre,['test4\r',num2str(imName),'.jpg'],'jpg');
            else
                % 没有跟踪到
                subplot(2,2,1);
                imshow(I);
                title('3');
                imwrite(I,['test4\',num2str(imName),'.jpg'],'jpg');
                imwrite(bw_pre,['test4\l',num2str(imName),'.jpg'],'jpg');
            end
            %---------------------------------------------------
        else % 多目标
            adparam.isObjectDetected = true;
            [~,lens] = size(labelStruct);
            for i=1:lens
                adparam.detectedLocation(i,:) = [labelStruct(i).x,...
                    labelStruct(i).y,labelStruct(i).width,...
                    labelStruct(i).heigth];
            end
%            [adparam, labelInfo] = trackSingleObject(param,adparam);
            disp('into multiple');
            disp(imName);
        end
        subplot(2,2,3);
        imshow(bw_pre);
    end
    imName = imName + 1;
    pause(0.001);
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
    lists(i,:) = lists(i+1,:);
end
status_list = lists;
end
function labelStruct = defaultLabel(width, heigth)
labelStruct.sum = 0;
labelStruct.x = 0;
labelStruct.y = 0;
labelStruct.width = width;
labelStruct.heigth = heigth;
end