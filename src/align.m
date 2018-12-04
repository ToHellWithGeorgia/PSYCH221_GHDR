function out = align(gp1, gp2, width, height, depth, tile, stride, radi)
% gp1, gp2: two gaussian pyramid output images.
% out: 3D tensor.
    up_kernel = [2 * 0.06136, 2 * 0.24477, 2 * 0.38774, 2 * 0.24477, 2 * 0.06136];
    for level = depth:-1:1
        average_diff = 0;
        cur_width = ceil(width / (2 ^ (level - 1)));
        cur_height = ceil(height / (2 ^ (level - 1)));
        offset_width = ceil((cur_width - tile) / stride) + 1;
        offset_height = ceil((cur_height - tile) / stride) + 1;
        offset = zeros(offset_height, offset_width, 2);
        
        % Upsample the offset from the last aligning results.
        if level ~= depth
            last_offset_width = (cur_width / 2 - tile) / stride + 1;
            last_offset_height = (cur_height / 2 - tile) / stride + 1;
            for row = 1:last_offset_height
                for col = 1:last_offset_width
                    offset(row * 2 - 1, col * 2 - 1) = last_offset(row, col);
                end
            end
        end
        
        % Convolve offset with up_kernel
        convxy(offset, up_kernel);
        % TODO: maybe round the offset to integer
        
        % For each tile in the image.
        for row = 1:stride:cur_height - tile
            for col = 1:stride:cur_width - tile
                min_dist = 1e10;
                row_offset = 0;
                col_offset = 0;
                
                % Offset from last aligning result.
                last_offset_row = 0;
                last_offset_col = 0;
                if level ~= depth
                    last_offset_amount = offset((row-1)/stride+1, (col-1)/stride+1, :);
                    last_offset_row = last_offset_amount(1);
                    last_offset_col = last_offset_amount(2);
                end
                
                % For each neighboring tile
                for tilerow = -radi:radi
                    for tilecol = -radi:radi
                        if ((row + tilerow + last_offset_row < 1) || ...
                            (row + tilerow + last_offset_row + tile > cur_height) || ...
                            (col + tilecol + last_offset_col < 1) || ...
                            (col + tilecol + last_offset_col + tile > cur_width))
                                continue;
                        end
                        
                        dist = gp1{level}(row+1:row+tile, col+1:col+tile) ...
                            - gp2{level}(row+last_offset_row+tilerow+1:row+last_offset_row+tilerow+tile, ...
                            col+last_offset_col+tilecol+1:col+last_offset_col+tilecol+tile); 
                        total_dist = sum(sum(abs(dist)));
                        % End of accumulation.
                        
                        % Update the min distance.
                        if total_dist < min_dist
                            min_dist = total_dist;
                            row_offset = tilerow + last_offset_row;
                            col_offset = tilecol + last_offset_col;
                        end
                    end
                end
                        
                offset((row-1)/stride+1, (col-1)/stride+1, 1) = row_offset;
                offset((row-1)/stride+1, (col-1)/stride+1, 2) = col_offset;
                offset((row-1)/stride+1, (col-1)/stride+1, 3) = min_dist;
                average_diff = average_diff + min_dist;
            end
        end
        % End of an image
        last_offset = offset;
        average_diff = average_diff / (offset_width * offset_height);
    end
    out = last_offset;
end