% Perform a convolution on both x and y direction using the kernel provided
%
function out = convxy(in, kernel)
    numpad = (length(kernel) - 1)/2;
    pad = padarray(in, [numpad numpad], 'symmetric');
    pad = convn(pad, kernel, 'valid');
    pad = permute(pad, [2,1,3]);
    pad = convn(pad, kernel, 'valid');
    out = permute(pad, [2,1,3]);
end