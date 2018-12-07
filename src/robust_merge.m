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

    for cr = 1:2  % color channel row
        for cc = 1:2
            overlap_count = zeros(height/2, width/2);
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
                            + abs(ifft2(Tz + Az.*(T0 - Tz)));
                        overlap_count(row:row+tile-1, col:col+tile-1) = ...
                            overlap_count(row:row+tile-1, col:col+tile-1) + ...
                            ones(tile);
                    end
                end
                
                % Bottom edge
                row = floor((height/2-tile)/stride)*stride;
                for col = 1:floor((width/2-tile)/stride)*stride-tile
                    current_tile = raw_frame{1}(row*2-1+cr-1:2:end, col*2-1+cc-1:2:col*2-1+cc-1+tile*2-1);
                    comming_tile = raw_frame{k}(row*2-1+cr-1:2:end, col*2-1+cc-1:2:col*2-1+cc-1+tile*2-1);

                    T0 = fft2(current_tile);
                    Tz = fft2(comming_tile);
                    Dz = abs(T0 - Tz);
                    Az = Dz.^2 ./ (Dz.^2 + 8 * noise_variance);

                    channel(row:end, col:col+tile-1) = ...
                        channel(row:end, col:col+tile-1) + abs(ifft2(Tz + Az.*(T0 - Tz)));
                    overlap_count(row:end, col:col+tile-1) = ...
                        overlap_count(row:end, col:col+tile-1) + ones(size(overlap_count(row:end, col:col+tile-1)));
                end
                
                % Right edge
                col = floor((width/2-tile)/stride)*stride;
                for row = 1:floor((height/2-tile)/stride)*stride-tile
                    current_tile = raw_frame{1}(row*2-1+cr-1:2:row*2-1+cr-1+tile*2-1, col*2-1+cc-1:2:end);
                    comming_tile = raw_frame{k}(row*2-1+cr-1:2:row*2-1+cr-1+tile*2-1, col*2-1+cc-1:2:end);

                    T0 = fft2(current_tile);
                    Tz = fft2(comming_tile);
                    Dz = abs(T0 - Tz);
                    Az = Dz.^2 ./ (Dz.^2 + 8 * noise_variance);

                    channel(row:row+tile-1, col:end) = ...
                        channel(row:row+tile-1, col:end) + abs(ifft2(Tz + Az.*(T0 - Tz)));
                    overlap_count(row:row+tile-1, col:end) = ...
                        overlap_count(row:row+tile-1, col:end) + ones(size(overlap_count(row:row+tile-1, col:end)));
                end
                
                % Bottom-right corner
                row = floor((height/2-tile)/stride)*stride;
                col = floor((width/2-tile)/stride)*stride;
                current_tile = raw_frame{1}(row*2-1+cr-1:2:end, col*2-1+cc-1:2:end);
                comming_tile = raw_frame{k}(row*2-1+cr-1:2:end, col*2-1+cc-1:2:end);
                
                T0 = fft2(current_tile);
                Tz = fft2(comming_tile);
                Dz = abs(T0 - Tz);
                Az = Dz.^2 ./ (Dz.^2 + 8 * noise_variance);

                channel(row:end, col:end) = ...
                    channel(row:end, col:end) + abs(ifft2(Tz + Az.*(T0 - Tz)));
                overlap_count(row:end, col:end) = ...
                    overlap_count(row:end, col:end) + ones(size(overlap_count(row:end, col:end)));
            end
            result(cr:2:end, cc:2:end) = channel./overlap_count;
        end
    end
    
    result = min(result,1);
end