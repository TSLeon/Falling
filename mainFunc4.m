% �İ�������3�����Ե����ж�
imgRoot = 'source\vtest.avi\';
videoReader = VideoReader('vtest.avi');
figure;
%------------------------------------
%videoPlayer = vision.VideoPlayer;  % ����һ����Ƶ������
param = defaultParam();
adparam = defaultAdparam();
%-------------------------------------
M = 1; % ǰN֡ͼ��
start = 1; % ��ʼ֡
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
status_list = zeros(10,4);
firstFrame = true; % ��һ��10֡
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
        % �������
    else
        if back_count == 0
            u_xy = u_xy/(total);
            back_count = back_count - 1;
            % �󱳾�ƽ��ֵ
        end
        [u_xy,bw_pre] = bodyFrame3(u_xy,I,alpha,W_self,se);
        [labelStruct,target_type] = callouts3(bw_pre,labelStruct);
        %---------------------------------------------------
        if strcmp(target_type,'single') % ��Ŀ��
            if labelStruct.width == y && labelStruct.heigth == x
                adparam.isObjectDetected = false;
            else
                adparam.isObjectDetected = true;
            end
            adparam.detectedLocation = [labelStruct.x,labelStruct.y,...
                labelStruct.width,labelStruct.heigth];
            % �������˲�
            [adparam, labelInfo] = trackSingleObject(param,adparam);
            if ~isempty(labelInfo.trackedLocation)
                region = labelInfo.trackedLocation;
                if firstFrame
                    status_list(count,:) = region;
                else
                    status_list = move_list(status_list);
                    status_list(10,:) = region;
                end
                % ��¼10֡������
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
                            if centroid_diff > 0 % ��������
                                self_label = 'Falled';
                                %disp(1);
                                disp(old_data);
                                disp(present_data);
                                %disp(labelStruct.centroid_y);
                                %disp(status_list(1).centroid_y);
                            else % ��������
                                self_label = 'Stand up';
                                %disp(2);
                                disp(old_data);
                                disp(present_data);
                                %disp(labelStruct.centroid_y);
                                %disp(status_list(1).centroid_y);
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
                    imshow(combinedImage);
                else
                    combinedImage = insertObjectAnnotation(I, shape, region,...
                        {pre_label},'FontSize',50,'LineWidth',5);
                    imshow(combinedImage);
                    count = count + 1;
                end
                imwrite(combinedImage,['test3\',num2str(imName),'.jpg'],'jpg');
            else
                % û�и��ٵ�
                imshow(I);
                imwrite(I,['test3\',num2str(imName),'.jpg'],'jpg');
            end
            %---------------------------------------------------
        else % ��Ŀ��
            adparam.isObjectDetected = true;
            [~,lens] = size(labelStruct);
            for i=1:lens
                adparam.detectedLocation(i,:) = [labelStruct(i).x,...
                    labelStruct(i).y,labelStruct(i).width,...
                    labelStruct(i).heigth];
            end
            [adparam, labelInfo] = trackSingleObject(param,adparam);
        end
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