% Load three Taxi images
addpath('../scenes');
load('scenes/taxi_burst_raw.mat');
load('scenes/taxi_merged_raw.mat');

align_depth = 5;
tile = 16;
stride = 8;
search_radius = 8;
width = size(taxi_raw{1}, 2);
height = size(taxi_raw{1}, 1);
gp = cell(1,length(taxi_raw));
align_offsets = cell(1,length(taxi_raw));

for i = 1:length(taxi_raw)
    % Raw frame to grayscale, shrink size by 2.
    grayscale = Bayer2Gray(taxi_raw{i});
    
    % Gaussian Pyramid
    gp{i} = gpPyramid(grayscale, align_depth);
    % Align.
    align_offsets{i} = align(gp{1}, gp{i}, width/2, height/2, align_depth, tile, stride, search_radius);
end
%%
% Averaging is not good.
% result1 = avg_merge(taxi_raw, align_offsets, tile, stride);
% figure; subplot 121; imshow(demosaic(uint8(taxi_merged_raw.^0.44*255),'grbg'));
% subplot 122; imshow(demosaic(uint8(result1.^0.44*255),'grbg'));

%%
result3 = robust_merge(taxi_raw, align_offsets, tile, stride);
figure; subplot 121; imshow(demosaic(uint8(taxi_merged_raw.^0.44*255),'grbg'));
subplot 122; imshow(demosaic(uint8(result3.^0.44*255),'grbg')); 


