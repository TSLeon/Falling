videoFile = 'vtest.avi';
file_path = 'source\vtest.avi';
if exist(file_path)==0
    mkdir(file_path);
end
videObj = VideoReader(videoFile);
totalFrames = videObj.NumberOfFrames;
for frame = 1:totalFrames
	frameImg = read(videObj,frame);
	saveName = ['source\vtest.avi\',num2str(frame),'.jpg'];
	imwrite(frameImg,saveName,'jpg');
end

