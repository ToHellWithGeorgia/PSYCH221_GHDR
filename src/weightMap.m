% Calculate the weight map of the image
% The weight consists of contrast, saturation and well-exposedness
%
function out = weightMap(in_gray, in_rgb)
    % Use the Laplacian filter to calculate the contrast   
    lap_kernel = [1, -2, 1];
    w_contrast = abs(convxy(in_gray, lap_kernel));
    
    % Calculate the standard deviation
    w_std = std(in_rgb, 0, 3);
    
    % Well-exposedness
    gaussCurve = @(i) exp(-((i - 0.5).^2 ./ (2 * 0.04)));
    temp = gaussCurve(in_rgb);
    w_expose = temp(:,:,1) .* temp(:,:,2) .* temp(:,:,3);
    
    out = w_contrast .* w_std .* w_expose;
end