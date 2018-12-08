function out = finish(in)

%   Increase saturation
    HSV = rgb2hsv(in);
    HSV(:, :, 2) = HSV(:, :, 2) * 1.6;
    HSV(HSV > 1) = 1;
    RGB = hsv2rgb(HSV);

%   Sharpen the image
    sharpen = imsharpen(RGB, 'Amount', 0.8);
    
%   Reduce haze. Do not work well.
%   dehaze = imreducehaze(sharpen);

%   White balance. Do not work well.
%   x = 765;
%   y = 590;
%   gray_val = [sharpen(x,y,1), sharpen(x,y,2), sharpen(x,y,3)]
%   B = chromadapt(sharpen, gray_val);


%   Local contrast. Very weird
%   edgeThreshold = 0.3;
%   amount = 0.7;
%   B = localcontrast(sharpen, edgeThreshold, amount);
    out = sharpen;
end


