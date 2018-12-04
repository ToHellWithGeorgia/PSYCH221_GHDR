% Construct a laplacian pyramid
function out = lpPyramid(in, depth)
    gauss_kernel_up = 2*[0.06136,0.24477,0.38774,0.24477,0.06136];
    gp = gpPyramid(in, depth);
    out = {};
    
    for num = 1 : depth-1
        tmp = zeros(size(gp{num}));
        tmp(1:2:end, 1:2:end,:) = gp{num+1};
        tmp = convxy(tmp, gauss_kernel_up);
        
        out{num} = gp{num} - tmp;
    end
    out{depth} = gp{depth};
end