% clear all; 
close all;

load('scenes/taxi_burst_raw.mat');
load('scenes/taxi_merged_raw.mat');

M1 = 0.4;
M2 = 10.0;
gamma = 0.44;
rgb_align = 'grbg';
% Detect and correct sensing defect
% correct_out = correctDefect(taxi_merged_raw, M1, M2);
% figure; imshow(uint8(correct_out.^gamma*255));

% Demosaic
gray_uint8 = uint8(correct_out.^gamma * 255);
demos_uint8 = demosaic(gray_uint8, rgb_align);
demos_out = double(demos_uint8) / 255;
% figure; imshow(demos_out)

% Gaussian blur
gauss_kernel = [0.06136,0.24477,0.38774,0.24477,0.06136];
% gauss_out1 = convxy(demos_out, gauss_kernel);
gauss_out = imgaussfilt(demos_out);
% figure; imshow(gauss_out1);
% figure; imshow(gauss_out);

% Create a brighten version of the image.
rgb_dark = gauss_out;
rgb_brig = brighten(gauss_out, 1.3);
gray_dark = RGB2YUV(rgb_dark); gray_dark = gray_dark(:,:,1);
gray_brig = RGB2YUV(rgb_brig); gray_brig = gray_brig(:,:,1);
figure; imshow(rgb_dark);
figure; imshow(rgb_brig);

% Calculate the weight map for fusing
wm_brig = weightMap(gray_brig, rgb_brig);
wm_dark = weightMap(gray_dark, rgb_dark);
wm_brig = min(wm_brig ./ (wm_brig + wm_dark + 1e-10),1);
wm_dark = 1 - wm_brig;
% figure; imshow(wm_brig);
% figure; imshow(wm_dark);

depth = 5;
gp_brig = gpPyramid(wm_brig, depth);
gp_dark = gpPyramid(wm_dark, depth);
lp_brig = lpPyramid(rgb_brig, depth);
lp_dark = lpPyramid(rgb_dark, depth);
final = lpReconstruct(lpFuse(lp_brig,gp_brig,lp_dark,gp_dark));
figure; imshow(final);

