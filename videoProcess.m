videoFile = 'test3.mp4';
videObj = VideoReader(videoFile);
totalFrames = videObj.NumberOfFrames;
for frame = 1:totalFrames
	frameImg = read(videObj,frame);
	saveName = ['source\test3\',num2str(frame),'.jpg'];
	imwrite(frameImg,saveName,'jpg');
end

