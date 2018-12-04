% Brighten a RGB image by scaling the Y in the YUV
function out = brighten(in, scale)
    out = RGB2YUV(in);
    out(:,:,1) = out(:,:,1) * scale;
    out = YUV2RGB(out);
end