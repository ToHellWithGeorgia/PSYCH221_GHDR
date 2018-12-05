addpath('../cpp_output')
grayimg0 = imread('../cpp_output/burst0.bmp');
grayimg0 = grayimg0(:,:,1);

grayimg1 = circshift(grayimg0,[-1,2]);
grayimg1 = grayimg1(:,:,1);

align_depth = 5;

gp0 = gpPyramid(grayimg0, align_depth);
gp1 = gpPyramid(grayimg1, align_depth);

tile = 16;
stride = 8;
search_radius = 8;
width = size(grayimg0, 2);
height = size(grayimg1, 1);
offset = align(gp0, gp1, width, height, align_depth, tile, stride, search_radius);

assert(offset(30,40,1) == -1, 'First test case wrong row offset!');
assert(offset(30,40,2) == 2, 'First test case wrong column offset!');
assert(offset(40,55,1) == -1, 'Second test case wrong row offset!');
assert(offset(40,55,2) == 2, 'Second test case wrong column offset!');
