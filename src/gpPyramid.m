% Construct a Gaussian pyramid
function out = gpPyramid(in, depth)  
    out = {};
    gauss_kernel = [0.06136,0.24477,0.38774,0.24477,0.06136];
    curimg = in;
    
    for num = 1:depth
        tmp = curimg;
        tmp = convxy(tmp, gauss_kernel);

        nxtimg = tmp(1:2:end, 1:2:end, :);
        out{num} = curimg;
        curimg = nxtimg;
    end
end
