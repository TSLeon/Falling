% gray imge, just update background, use gaussian before difference
imgroot = 'source\test3\';
M = 4;
start = 1;
W_self = fspecial('gaussian',3,0.5); % 1/16 * [1 2 1;2 4 2;1 2 1];
figure;	
% get size of image,and background
[x,y,z] = size(imread([imgroot,num2str(1),'.jpg']));
u_xy = int16(zeros(x,y,z));
u_xy = rgb2gray(u_xy);
for t=start:M
	u_temp = imread([imgroot,num2str(t),'.jpg']);
	u_temp = rgb2gray(u_temp);
	u_temp = imfilter(u_temp,W_self);
	u_xy = u_xy + int16(u_temp);
end
% check data
%u_temp = u_xy;
u_xy = u_xy/(M-start+1);
threshold = 70;
alpha = 0.2; % between 0-1
% -------------------------------------------------------------------------------------------------loop
for k=1:100
	I = imread([imgroot,num2str(M+k),'.jpg']);	
	I = rgb2gray(I);
	I = imfilter(I,W_self);
	% make diff to get moving target
	%u_xy = imfilter(uint8(u_xy),W_self);
	d_xy = abs(u_xy - int16(I));  %----------------------------------------------------------------outplay	
	% get outplay
	out_target = uint8(zeros(x,y,z));
	out_target = rgb2gray(out_target);
	for i=1:x
		for j=1:y
			if d_xy(i,j) > threshold % threshold(i,j)
				out_target(i,j) = 255;
			else
				out_target(i,j) = 0;
			end
		end
	end
	%----------------------------------------------------------------------------------------------gaussian
%	W_default = fspecial('gaussian');
%	W_auto = fspecial('gaussian',3,1);
%	W_self = 1/16 * [1 2 1;2 4 2;1 2 1];
%	imshow(uint8(u_xy));
%	saveas(gcf,['test\u_xy',num2str(k),'.jpg']);
%	u_xy_default = imfilter(uint8(u_xy),W_default);
%	imshow(u_xy_default);
%	saveas(gcf,['test\u_xy_default',num2str(k),'.jpg']);
%	u_xy_auto = imfilter(uint8(u_xy),W_auto);
%	imshow(u_xy_auto);
%	saveas(gcf,['test\u_xy_auto',num2str(k),'.jpg']);
%	u_xy_self = imfilter(uint8(u_xy),W_self);
%	imshow(u_xy_self);
%	saveas(gcf,['test\u_xy_self',num2str(k),'.jpg']);
%	d_xy_self = abs(u_xy_self - I);
%	out_self = uint8(zeros(x,y,z));
%	out_self = rgb2gray(out_self);
%	for i=1:x
%		for j=1:y
%			if d_xy_self(i,j) > threshold
%				out_self(i,j) = 255;
%			else
%				out_self(i,j) = 0;
%			end
%		end
%	end
	% ---------------------------------------------------------------------------------------------update
	% update background
	u_xy = alpha*int16(I) + (1-alpha)*u_xy;
	for i=1:x
		for j=1:y
			if u_xy(i,j) > 255
				u_xy(i,j) = 255;
			end
		end
	end
	% ---------------------------------------------------------------------------------------------show
	imshow(out_target);
	title(k);
	pause(0.1);
end

