function your_average_camera_man = block_avg_cameraman()
    im_old = imread('cameraman.tif');
    im_old = im2double(im_old);
    im_new = im_old;
    dims = size(im_old);
    for row = 3:dims(1) - 2
        for column = 3 :dims(2)-2
            local_avg = 0;
            for delta_row = [-2,-1,0,1,2]
                for delta_col = [-2,-1,0,1,2]
                    local_avg = local_avg + ...
                        delta_row*delta_col*(im_old(row + delta_row,...
                        column + delta_col));
                       
                end
            end
            im_new(row, column) = local_avg;
        end
    end
    your_average_camera_man = im_new;
end