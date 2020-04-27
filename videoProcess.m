% ÊÓÆµÖ¡Í¼Ïñ»¯
videoFile = 'singleball.mp4';
file_path = 'source\singleball';
if exist(file_path)==0
    mkdir(file_path);
end
videObj = VideoReader(videoFile);
totalFrames = videObj.NumberOfFrames;
for frame = 1:totalFrames
	frameImg = read(videObj,frame);
	saveName = ['source\singleball\',num2str(frame),'.jpg'];
	imwrite(frameImg,saveName,'jpg');
end

