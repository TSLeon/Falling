% ÊÓÆµÖ¡Í¼Ïñ»¯
videoFile = 'test7.mp4';
file_path = 'source\test7';
if exist(file_path)==0
    mkdir(file_path);
end
videObj = VideoReader(videoFile);
totalFrames = videObj.NumberOfFrames;
for frame = 1:totalFrames
	frameImg = read(videObj,frame);
	saveName = ['source\test7\',num2str(frame),'.jpg'];
	imwrite(frameImg,saveName,'jpg');
end

