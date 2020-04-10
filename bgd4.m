%function img_BW = bgd4()
	% first prepar
	imgroot = 'source\test3\';
	M = 60;
	figure;
	
	% get size of image,and background
	[x,y,z] = size(imread([imgroot,num2str(1),'.jpg']));
	u_xy = zeros(x,y,z);
	u_xy = rgb2gray(u_xy);
	for t=1:M
		u_temp = imread([imgroot,num2str(t),'.jpg']);
		u_temp = rgb2gray(u_temp);
		u_xy = u_xy + double(u_temp);
	end
	% check data
	%u_temp = u_xy;
	u_xy = u_xy/M;
	imshow(uint8(u_xy));	
	
	% diff between frame
	F_t = zeros(x,y,z);
	inter = 3;
	for i=inter+1:M
		I1 = imread([imgroot,num2str(t),'.jpg']);
		I2 = imread([imgroot,num2str(t-inter),'.jpg']);
		I1 = rgb2gray(I1);
		I2 = rgb2gray(I2);
		f_t = abs(I1-I2);
		F_t = F_t + double(f_t);
	end
	u_diff = F_t/M;

	% standard diff
	Diff = zeros(x,y,z);
	diff = zeros(x,y,z);
	Diff = rgb2gray(Diff);
	diff = rgb2gray(diff);
	for t=inter+1:M
		I1 = imread([imgroot,num2str(t),'.jpg']);
		I2 = imread([imgroot,num2str(t-inter),'.jpg']);
		I1 = rgb2gray(I1);
		I2 = rgb2gray(I2);
		f_t = abs(I1-I2);
		f_t = double(f_t);
		diff = (f_t-u_diff).*(f_t-u_diff);
		Diff = Diff + diff;
	end
	diff_std_insqrt = Diff/M;
	diff_std = sqrt(diff_std_insqrt);
	
	% compute threshold
	k = 1;
	peta = 2;
	threshold = u_diff + peta*diff_std;
	
	% get present image
	I = imread([imgroot,num2str(M+k),'.jpg']);	
	I = rgb2gray(I);

	% make diff to get moving target
	d_xy = abs(u_xy - double(I));
	
	% get outplay
	out_target = zeros(x,y,z);
	out_target = rgb2gray(out_target);
	for i=1:x
		for j=1:y
			if d_xy(i,j) > threshold(i,j)
				out_target(i,j) = 255;
			else
				out_target(i,j) = 0;
			end
		end
	end

	% update
	alpha = 0.65; % between 0-1
	% update background
	u_xy = alpha*double(I) + (1-alpha)*u_xy;
	for i=1:x
		for j=1:y
			if u_xy(i,j) > 255
				u_xy(i,j) = 255;
			end
		end
	end

	d_xy_updated = abs(u_xy - double(I));
	out_target_updated = zeros(x,y,z);
	out_target_updated = rgb2gray(out_target_updated);
	for i=1:x
		for j=1:y
			if d_xy_updated(i,j) > threshold(i,j)
				out_target_updated(i,j) = 255;
			else
				out_target_updated(i,j) = 0;
			end
		end
	end

	% update frame diff

	% update standard diff

	%------------------------------------
	%subplot(3,3,1);
	imshow(uint8(u_xy));
	title('average background');
	saveas(gcf,['test\','average_background.jpg']);

	%subplot(3,3,2);
	imshow(uint8(u_diff));
	title('frame diff');
	saveas(gcf,['test\','frame_diff.jpg']);

	%subplot(3,3,3);
	imshow(uint8(diff_std));
	title('standard diff');
	saveas(gcf,['test\','standard_diff.jpg']);

	%subplot(3,3,4);
	imshow(uint8(threshold));
	title('threshold');
	saveas(gcf,['test\','threshold.jpg']);

	imshow(uint8(d_xy));
	title('d_xy');
	saveas(gcf,['test\','d_xy.jpg']);

	imshow(uint8(out_target));
	title('out target');
	saveas(gcf,['test\','out_target.jpg']);

	imshow(uint8(d_xy_updated));
	title('d_xy updated');
	saveas(gcf,['test\','d_xy_updated.jpg']);

	imshow(uint8(out_target_updated));
	title('out_target updated');
	saveas(gcf,['test\','out_target_updated.jpg']);

	img_BW = u_xy;
%end

