function result = robust_merge(raw_frame, align_offsets, tile, stride)
    % This function does a simple merge considering the offsets but not
    % relative accuracy for each frequence.
    
    % inputs: a cell array of Bayer raw frame images.
    % align_offsets: a cell array of 3D tensors representing offset for each
    % tile
    assert(length(raw_frame) == length(align_offsets));
    height = size(raw_frame{1},1);
    width = size(raw_frame{1},2);
    result = zeros(height, width);
    
    noise_variance = std2(raw_frame{1})^2;
    
    cos_1d = zeros(1,16);
    for x = 1:16
        cos_1d(x) = 1/2 - 1/2*cos(2*pi*(x+1/2)/16);
    end
    cos_2d = cos_1d' * cos_1d;

    for cr = 1:2  % color channel row
        for cc = 1:2
            channel = zeros(height/2, width/2);
            for k = 1:length(raw_frame)
                for row = 1:stride:height/2-tile
                    for col = 1:stride:width/2-tile
                        row_offset = align_offsets{k}((row-1)/stride+1, (col-1)/stride+1, 1);
                        col_offset = align_offsets{k}((row-1)/stride+1, (col-1)/stride+1, 2);
                        current_tile = raw_frame{1}(row*2-1+cr-1:2:row*2-1+cr-1+tile*2-1, col*2-1+cc-1:2:col*2-1+cc-1+tile*2-1);
                        comming_tile = raw_frame{k}((row+row_offset)*2-1+cr-1:2:(row+row_offset)*2-1+cr-1+tile*2-1, ...
                            (col+col_offset)*2-1+cc-1:2:(col+col_offset)*2-1+cc-1+tile*2-1);
                        T0 = fft2(current_tile);
                        Tz = fft2(comming_tile);
                        Dz = abs(T0 - Tz);
                        Az = Dz.^2 ./ (Dz.^2 + 8 * noise_variance);

                        channel(row:row+tile-1, col:col+tile-1) = ...
                            channel(row:row+tile-1, col:col+tile-1) ...
                            + abs(ifft2(Tz + Az.*(T0 - Tz))).*cos_2d;
                    end
                end
            end
            result(cr:2:end, cc:2:end) = channel/length(raw_frame);
        end
    end
    result(:,1:tile/2*2) = raw_frame{1}(:,1:tile/2*2);
    result(:, floor((width/2 - tile) / stride) * stride * 2:end) = ...
        raw_frame{1}(:, floor((width/2 - tile) / stride) * stride * 2:end);
    result(1:tile/2*2,:) = raw_frame{1}(1:tile/2*2, :);
    result(floor((height/2 - tile) / stride) * stride * 2:end,:) = ...
        raw_frame{1}(floor((height/2 - tile) / stride) * stride * 2:end,:);
    
    result = result/max(max(result));
end