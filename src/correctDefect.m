% Detect and correct static sensor defects in the image.
% M1 and M2 are thresholds of detection.
function out = correctDefect(in, M1, M2)
    [height,width] = size(in);
    % Mirror the edge with 2 extra row, col
    mirror_arr = padarray(in, [2,2], 'symmetric');
    % Counter for defect pixels
    cnt1 = 0; cnt2 = 0;
    % Calculate the bright difference first
    bright_diff = mirror_arr;
    for row = 3:height+2
        for col = 3:width+2
           bright_diff(row,col) = bright_diff(row,col) - ...
                                  mean(mean(mirror_arr(row-1:row+1,col-1:col+1)));
        end
    end
    bright_diff = abs(bright_diff(3:height+2,3:width+2));
    bright_diff = padarray(bright_diff, [2,2], 'symmetric');
    
    % We detect and correct pixel defects using this reference:
    % https://www.ingentaconnect.com/contentone/ist/ei/2017/00002017/00000015/
    % art00008?crawler=true&mimetype=application/pdf
    for row = 3:height+2
        for col = 3:width+2
            cur_pixel = mirror_arr(row,col);
            tile = mirror_arr(row-2:2:row+2,col-2:2:col+2);
            tile = sort(reshape(tile, [1 9]));
            tile = tile(2:8);
            avg = mean(tile);
            median = tile(4);
            
            cond1 = cur_pixel > (1 + M1) * avg;
            cond2 = cur_pixel < (1 - M1) * avg;
            cond3 = bright_diff(row, col) > M2 * ...
                    min(bright_diff(row, col-1), ...
                        bright_diff(row, col+1));
            cond4 = bright_diff(row, col) > M2 * ...
                    min(bright_diff(row-1, col), ...
                        bright_diff(row+1, col));
            cond5 = bright_diff(row, col) > M2 * ...
                    min([bright_diff(row-1, col-1), ...
                         bright_diff(row-1, col+1), ...
                         bright_diff(row+1, col-1), ...
                         bright_diff(row+1, col+1)]);
                     
            cond6 = bright_diff(row, col) < M2 * ...
                    max(bright_diff(row, col-1), ...
                        bright_diff(row, col+1));
            cond7 = bright_diff(row, col) < M2 * ...
                    max(bright_diff(row-1, col), ...
                        bright_diff(row+1, col));
            cond8 = bright_diff(row, col) < M2 * ...
                    max([bright_diff(row-1, col-1), ...
                         bright_diff(row-1, col+1), ...
                         bright_diff(row+1, col-1), ...
                         bright_diff(row+1, col+1)]);
            
            is_hot = cond1 && cond3 && cond4 && cond5;
            cnt1 = cnt1 + is_hot;
            is_cold = cond2 && cond6 && cond7 && cond8;
            cnt2 = cnt2 + is_cold;
            
            if is_hot || is_cold
                mirror_arr(row,col) = median;
            end
        end
    end
    out = mirror_arr(3:height+2,3:width+2);
end