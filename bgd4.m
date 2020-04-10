function img_BW = bgd4()
	% first prepar
	imgroot = 'source\test3';
	M = 60;
	figure;
	
	% get size of image,and background
	[x,y,z] = seze(imread([imgroot,num2str(1),'.jpg']));
	u_xy = zeros(x,y,z);
	u_xy = rgb2gray(u_xy);
	for t=1:M
		u_temp = imread([imgroot,num2str(t),'.jpg']);
		u_temp = rgb2gray(u_temp);
		u_xy = u_xy + double(u_temp);
	end
	u_xy = u_xy/M;
end

