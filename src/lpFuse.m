% Fuse the laplacian pyramid using the gaussian pyramid
function out = lpFuse(lp_a, gp_a, lp_b, gp_b)
    out = {};
    depth = length(lp_a);
    
    for num = 1:depth
        out{num} = lp_a{num} .* gp_a{num} + lp_b{num} .* gp_b{num};
    end
end