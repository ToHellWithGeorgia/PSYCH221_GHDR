% Reconstruct the image using the laplacian pyramid
function out = lpReconstruct(inpy)
    gauss_kernel_up = 2*[0.06136,0.24477,0.38774,0.24477,0.06136];
    depth = length(inpy);
    curimg = inpy{depth};
    
    for num = depth-1:-1:1
        tmp = zeros(size(inpy{num}));
        tmp(1:2:end,1:2:end,:) = curimg;
        tmp = convxy(tmp, gauss_kernel_up);
        tmp = tmp + inpy{num};
        curimg = tmp;
    end
    out = curimg;
end