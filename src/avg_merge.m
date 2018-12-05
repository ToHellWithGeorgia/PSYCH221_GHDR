function result = avg_merge(raw_frame, align_offsets, tile, stride)
    % This function does a simple merge considering the offsets but not
    % relative accuracy for each frequence.
    
    % inputs: a cell array of Bayer raw frame images.
    % align_offsets: a cell array of 3D tensors representing offset for each
    % tile
    assert(length(raw_frame) == length(align_offsets));
    height = size(raw_frame{1},1);
    width = size(raw_frame{1},2);
    result = zeros(height, width);
    for k = 1:length(raw_frame)
        for row = 1:stride:height/2-tile
            for col = 1:stride:width/2-tile
                row_offset = align_offsets{k}((row-1)/stride+1, (col-1)/stride+1, 1);
                col_offset = align_offsets{k}((row-1)/stride+1, (col-1)/stride+1, 2);
                result(row*2-1:row*2-1+tile*2, col*2-1:col*2-1+tile*2) = ...
                    0.5 * result(row*2-1:row*2-1+tile*2, col*2-1:col*2-1+tile*2) ...
                    + 0.5 * raw_frame{k}((row+row_offset)*2-1:(row+row_offset)*2-1+tile*2, ...
                    (col+col_offset)*2-1:(col+col_offset)*2-1+tile*2);
            end
        end
    end
    result = result/max(max(result));
end