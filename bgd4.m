%function img_BW = bgd4()
% gray image function
	% first prepar
	imgroot = 'source\test3\';
	M = 60;
	start = 1;
	figure;	
	% get size of image,and background
	[x,y,z] = size(imread([imgroot,num2str(1),'.jpg']));
	u_xy = int16(zeros(x,y,z));
	u_xy = rgb2gray(u_xy);
	for t=start:M
		u_temp = imread([imgroot,num2str(t),'.jpg']);
		u_temp = rgb2gray(u_temp);
		u_xy = u_xy + int16(u_temp);
	end
	% check data
	%u_temp = u_xy;
	u_xy = u_xy/(M-start+1);
%	imshow(uint8(u_xy));
	% diff between frame
	F_t = int16(zeros(x,y,z));
	F_t = rgb2gray(F_t);
	inter = 3;
	for i=inter+start:M
		I1 = imread([imgroot,num2str(t),'.jpg']);
		I2 = imread([imgroot,num2str(t-inter),'.jpg']);
		I1 = rgb2gray(I1);
		I2 = rgb2gray(I2);
		f_t = abs(I1-I2);
		F_t = F_t + int16(f_t);
	end
	u_diff = F_t/(M-start+1);
	% standard diff
	Diff = int16(zeros(x,y,z));
	diff = int16(zeros(x,y,z));
	Diff = rgb2gray(Diff);
	diff = rgb2gray(diff);
	for t=inter+start:M
		I1 = imread([imgroot,num2str(t),'.jpg']);
		I2 = imread([imgroot,num2str(t-inter),'.jpg']);
		I1 = rgb2gray(I1);
		I2 = rgb2gray(I2);
		f_t = abs(I1-I2);
		f_t = int16(f_t);
		diff = (f_t-u_diff).*(f_t-u_diff);
		Diff = Diff + diff;
	end
	diff_std_insqrt = Diff/(M-start+1);
	diff_std = sqrt(double(diff_std_insqrt));	
	% compute threshold
	%k = 1;
	peta = 2;
	for k=1:60
	threshold = u_diff + peta*int16(diff_std);	
	% get present image
	I = imread([imgroot,num2str(M+k),'.jpg']);	
	I = rgb2gray(I);
	% make diff to get moving target
	d_xy = abs(u_xy - int16(I));  %--------------------------------------------------------outplay	
	% get outplay
	out_target = int16(zeros(x,y,z));
	out_target = rgb2gray(out_target);
	for i=1:x
		for j=1:y
			if d_xy(i,j) > 70 % threshold(i,j)
				out_target(i,j) = 255;
			else
				out_target(i,j) = 0;
			end
		end
	end
	% ---------------------------------------------------------------------------------------update
	alpha = 0.2; % between 0-1
	% update background
	u_xy = alpha*int16(I) + (1-alpha)*u_xy;
	for i=1:x
		for j=1:y
			if u_xy(i,j) > 255
				u_xy(i,j) = 255;
			end
		end
	end
	% update frame diff
	I_1 = rgb2gray(imread([imgroot,num2str(M+k-inter),'.jpg']));
	f_x = abs(int16(I)-int16(I_1));
	u_diff = (1-alpha)*u_diff + alpha*f_x;
	% update standard diff
	diff_std = (1-alpha)*int16(diff_std) + alpha*abs(f_x - u_diff);
	%---------------------------------------------------------------------------------------process
	% CLAHE
	L = adapthisteq(uint8(out_target),'NumTiles',[8,8],'ClipLimit',0.005);
	% gaussian
	H = fspecial('gaussian',3,1);
	filteredBW = imfilter(L,H);
	uSobel = filteredBW;
    [X,Y] = size(filteredBW);
    F = double(filteredBW);
    for x=2:X-1
        for y=2:Y-1
            Gx = (F(x+1,y-1)+2*F(x+1,y)+F(x+1,y+1)) - (F(x-1,y-1)+2*F(x-1,y)+F(x-1,y+1));
            Gy = (F(x-1,y-1)+2*F(x,y-1)+F(x+1,y-1))-(F(x-1,y+1)+2*F(x,y+1)+F(x+1,y+1));
            uSobel(x,y) = sqrt(Gx^2+Gy^2);
        end
    end
	%-----------------------------------------------------------------------------------------show2
	imshow(L);
	saveas(gcf,['test\L',num2str(k),'.jpg']);
	imshow(filteredBW);
	saveas(gcf,['test\filteredBW',num2str(k),'.jpg']);
	imshow(uSobel);
	saveas(gcf,['test\uSobel',num2str(k),'.jpg']);
	%------------------------------------------------------------------------------------------show
	%subplot(3,3,1);
	%imshow(uint8(u_xy));
	%title('average background');
	%saveas(gcf,['test\average_backround',num2str(k),'.jpg']);

	%subplot(3,3,2);
	%imshow(uint8(u_diff));
	%title('frame diff');
	%saveas(gcf,['test\u_diff',num2str(k),'.jpg']);

	%subplot(3,3,3);
	%imshow(uint8(diff_std));
	%title('standard diff');
	%saveas(gcf,['test\diff_std',num2str(k),'.jpg']);

	%subplot(3,3,4);
	%imshow(uint8(threshold));
	%title('threshold');
	%saveas(gcf,['test\threshold',num2str(k),'.jpg']);

	%imshow(uint8(d_xy));
	%title('d_xy');
	%saveas(gcf,['test\d_xy',num2str(k),'.jpg']);

	%imshow(uint8(out_target));
	%title('out target');
	%saveas(gcf,['test\out_target',num2str(k),'.jpg']);

	end
	img_BW = u_xy;
%end

