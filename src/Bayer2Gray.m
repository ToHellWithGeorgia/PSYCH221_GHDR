% Downsample Bayer raw frame to grayscale
function out = Bayer2Gray(in)
    temp = in;
    temp(1:2:end,:) = temp(1:2:end,:) + temp(2:2:end,:);
    temp(:,1:2:end) = temp(:,1:2:end) + temp(:,2:2:end);
    out = min(temp(1:2:end, 1:2:end) / 4, 1);
end