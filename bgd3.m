function out_img = bgd3(I)
% real image function
imgroot = 'source\test3\';
[x,y,z] = size(imread([imgroot,num2str(1),'.jpg']));
frame_all = zeros(x,y,z);
for i=1:60
	frame_temp = imread([imgroot,num2str(i),'.jpg']);
	frame_all = frame_all + double(frame_temp);
end
frame_avg = frame_all/60; % double

%diff
F_t = zeros(x,y,z);
inter = 3;
for t=inter+1:60
	I1 = imread([imgroot,num2str(t),'.jpg']);
	I2 = imread([imgroot,num2str(t-inter),'.jpg']);
	f_t = abs(I1-I2);
	F_t = F_t + double(f_t);
end
u_diff = F_t/60;

% diff_std
Diff = zeros(x,y,z);
for t=inter+2:60
	I1 = imread([imgroot,num2str(t),'.jpg']);
	I2 = imread([imgroot,num2str(t-inter),'.jpg']);
	f_t = abs(I1-I2);
	f_t = double(f_t);
	diff = (f_t-u_diff).*(f_t-u_diff);
	Diff = Diff + diff;
end
diff_std_insqrt = Diff/60;
diff_std = sqrt(diff_std_insqrt);

% threshold
threshold = u_diff + 2*diff_std;

% frontground
% I = imread([imgroot,num2str(61),'.jpg']);
d = abs(double(I) - frame_avg);

% out
out = d > threshold;

out_uint8 = uint8(out);
out_uint8(out_uint8==1)=255;
out_img = rgb2gray(out_uint8);
end
