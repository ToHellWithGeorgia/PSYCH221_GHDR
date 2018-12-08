%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main file to execute the whole Google HDR pipeline %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the burst images
%
burst_filename = "scenes/taxi_merged_raw.mat";
addpath('../scenes');
load(burst_filename);
% load('scenes/taxi_merged_raw.mat');

%% 1. Align the burst images using Gaussian Pyramid search.
% Hyperparameter for aligning
%
disp('Start aligning burst images');
tic;
align_depth = 5;
tile = 16;
stride = 8;
search_radius = 8;

width = size(burst_raw_bayer{1}, 2);
height = size(burst_raw_bayer{1}, 1);
gp = cell(1,length(burst_raw_bayer));
align_offsets = cell(1,length(burst_raw_bayer));

for i = 1:length(burst_raw_bayer)
    % Raw frame to grayscale, shrink size by 2.
    grayscale = Bayer2Gray(burst_raw_bayer{i});
    
    % Gaussian Pyramid
    gp{i} = gpPyramid(grayscale, align_depth);
    % Align.
    align_offsets{i} = align(gp{1}, gp{i}, width/2, height/2, align_depth, tile, stride, search_radius);
end
toc;
%% 2. Merge the burst images using the frequency domain merge
%
disp('Start merging burst images');
tic;
merge_out = robust_merge(burst_raw_bayer, align_offsets, tile, stride);
toc;
% figure; imshow(demosaic(uint8(result3.^0.44*255),'grbg')); 

%% 3. Correct sensor defects 
% Hyperparameter for sensor defect
disp('Start correcting sensor defects');
tic;
M1 = 0.4;
M2 = 6.0;
gamma = 0.44;
rgb_align = 'grbg';

% Detect and correct sensing defect
correct_out = correctDefect(merge_out, M1, M2);
% figure; imshow(uint8(correct_out.^gamma*255));
toc;
%% 4. Demosaic the bayer raw frame into RGB
% Demosaic
disp('Start demosaicing');
tic;
gray_uint8 = uint8(correct_out.^gamma * 255);
demos_uint8 = demosaic(gray_uint8, rgb_align);
demos_out = double(demos_uint8) / 255;
% figure; imshow(demos_out)
toc;
%% 5. Perform the Gaussian blur
% Gaussian blur
disp('Start gaussian blur');
tic;
is_gauss = true;
if (is_gauss)
    gauss_out = imgaussfilt(demos_out);
else
    gauss_out = demos_out;
end
% figure; imshow(gauss_out);
toc;
%% 6. Perform exposure fusion on the image.
% Create a brighten version of the image.
disp('Start performing exposure fusion');
tic;
rgb_dark = gauss_out;
rgb_brig = brighten(gauss_out, 1.3);
gray_dark = RGB2YUV(rgb_dark); gray_dark = gray_dark(:,:,1);
gray_brig = RGB2YUV(rgb_brig); gray_brig = gray_brig(:,:,1);
% figure; imshow(rgb_dark);
% figure; imshow(rgb_brig);

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
fusion_out = lpReconstruct(lpFuse(lp_brig,gp_brig,lp_dark,gp_dark));
% figure; imshow(fusion_out);
toc;
%% 7. Perform the finishing steps on the image
disp('Start performing finishing steps');
tic;
final = finish_process(fusion_out);
figure; imshow(final);
toc;