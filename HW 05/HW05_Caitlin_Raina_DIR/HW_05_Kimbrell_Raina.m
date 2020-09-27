function HW_05_Kimbrell_Raina()
    im = imread('TBK_relaxing_jaguar_wallpaper.jpg');
    dimensions = size(im);
    angle_size = 45;
    % checking if the image passed in is color or gray scale
    if length(dimensions) > 2
        % changing the color image to gray image
        im_gray = im2double(rgb2gray(im));
    else
        % already a gray image
        im_gray = im2double(im);
    end
    % creating a Gaussian filter
    fltr = fspecial('Gaussian', 1, 2);
    % applying the filter on the gray scale image
    im_gaus = imfilter(im_gray, fltr, 'same', 'repl');
    
    % sobel filter
    dx = [-1 0 1 ;
          -2 0 2 ;
          -1 0 1 ] / 8;
    dy = dx.';
    
    % integrating with respect to x
    didx = imfilter(im_gaus, dx, 'same', 'repl');
    
    % integrating with respect to y
    didy = imfilter(im_gaus, dy, 'same', 'repl');
    
    % computing the edge magnitude
    im_mag = (didx.^2 + didy.^2).^(0.4);
    
    % edge gradient direction
    im_angle = atan2(didy, didx) * 180 / pi;
    
    % fixing negative angles to 0
    bool_negative_angle = im_angle < 0;
    im_angle(bool_negative_angle) = im_angle(bool_negative_angle) + 180;
    im_angle(im_angle == 180) = 0;
    
    % Creating multiples of 45 degrees or quantizing the angle data 
    % thus making bins that are multiples of 45.
    im_angle = floor(im_angle / angle_size) * angle_size; 
    
    %imagesc(im_mag);
    %axis image;
    %colormap(gray(256))
    
    % finding threshold 1 (non-maximal suppression
    % set all points to 0 first
    seedpoints = zeros( size( im_mag ));
    
    % set threshold to max of im_mag/1.2 to get bright edges
    threshold1 = max(max(im_mag))/3;
    
    % set threshold to threshold1/6
    threshold2 = threshold1/1.2;
    
    % Identifies all the strongest points in the magnified image
    % and redraws them on the black screen (seedpoints)
    % this should show only the strongest edges and remove all the 
    % non-maximal values
    for column = 2:1:size(im_mag,1) - 1
        for row = 2:1:size(im_mag,2)-1
            % get direction of the current pixel
            direction = im_angle(column,row);
            
            % Checks if the direction is 0 then compare the current pixel 
            % with the the pixels on the east and west of it.
            if direction == 0
                west_pixel = im_mag(column-1, row);
                east_pixel = im_mag(column+1, row);
                current_pixel = im_mag(column, row);
                if(current_pixel > west_pixel && current_pixel > ...
                        east_pixel && current_pixel >= threshold1)
                    % Draws the pixel on the Black Screen (seedpoints)
                    seedpoints(column,row) = current_pixel;
                end
                
            % Checks if the direction is 45 degrees then it compares the 
            % north-east and the south-west edges from the current pixel.
            elseif direction == 45
                north_west_pixel = im_mag(column-1, row+1);
                south_east_pixel = im_mag(column+1, row-1);
                current_pixel = im_mag(column, row);
                if(current_pixel > north_west_pixel && current_pixel > ...
                        south_east_pixel && current_pixel >= threshold1)
                    % Draws the pixel on the Black Screen (seedpoints)
                    seedpoints(column,row) = current_pixel;
                end
            
            % Checks if the direction is 90 degrees then it compares the 
            % north and the south edges from the current pixel.    
            elseif direction == 90
                north_pixel = im_mag(column, row-1);
                south_pixel = im_mag(column, row+1);
                current_pixel = im_mag(column, row);
                if(current_pixel > north_pixel && current_pixel > ...
                        south_pixel && current_pixel >= threshold1)
                    % Draws the pixel on the Black Screen (seedpoints)
                    seedpoints(column,row) = current_pixel;
                end
                
            % Checks if the direction is 135 degrees then it compares the 
            % north-west and the south-east edges from the current pixel.        
            else
                north_west_pixel = im_mag(column+1, row-1);
                south_east_pixel = im_mag(column-1, row+1);
                current_pixel = im_mag(column, row);
                if(current_pixel > north_west_pixel && current_pixel > ...
                        south_east_pixel && current_pixel >= threshold1)
                    % Draws the pixel on the Black Screen (seedpoints)
                    seedpoints(column,row) = current_pixel;
                end
            end
        end
    end
    
    edge_map = canny_edges(im_mag, threshold1, threshold2, ...
                                seedpoints, im_angle);
    for num = 0:1:5
        edge_map = canny_edges(im_mag, threshold1, threshold2, ...
                                edge_map, im_angle);
    end
    
    imagesc(edge_map);
    axis image;
    colormap(gray(256));
    imwrite(edge_map, 'TBK_relaxing_jaguar_wallpaper_canny_edge.jpg');

end

function edge_map = canny_edges(input_image, threshold1, threshold2, seedpoints, im_angle)
    % edge propogation
    edge_map = seedpoints;
    
    for column = 2:1:size(input_image,1) - 1
        for row = 2:1:size(input_image,2)-1
            current_pixel = edge_map(column,row);
            if current_pixel >= threshold1
                % get direction of current pixel
                direction = im_angle(column,row);
        
                % Checks if the direction is 0 then compare the current pixel 
                % with the the pixels on the east and west of it.
                if direction == 0
                    west_pixel = input_image(column-1, row);
                    east_pixel = input_image(column+1, row);
                    
                    % extend the edge lines for the respective position for
                    % the pixel
                    if(west_pixel >= threshold2)
                        edge_map(column-1,row) = current_pixel;
                    end
                    if(east_pixel >= threshold2)
                        edge_map(column+1,row) = current_pixel;
                    end
                    
                % Checks if the direction is 45 degrees then it compares the
                % north-east and the south-west edges from the current pixel.
                elseif direction == 45
                    north_east_pixel = input_image(column-1, row+1);
                    south_west_pixel = input_image(column+1, row-1);
                    
                    % extend the edge lines for the respective position for
                    % the pixel
                    if(north_east_pixel >= threshold2)
                        edge_map(column-1,row+1) = current_pixel;
                    end
                    if(south_west_pixel >= threshold2)
                        edge_map(column+1,row-1) = current_pixel;
                    end
                    
                % Checks if the direction is 90 degrees then it compares the 
                % north and the south edges from the current pixel.    
                elseif direction == 90
                    north_pixel = input_image(column, row-1);
                    south_pixel = input_image(column, row+1);
                    
                    % extend the edge lines for the respective position for
                    % the pixel
                    if(north_pixel >= threshold2)
                        edge_map(column,row-1) = current_pixel;
                    end
                    if(south_pixel >= threshold2)
                        edge_map(column,row+1) = current_pixel;
                    end
                    
                % Checks if the direction is 135 degrees then it compares the 
                % north-west and the south-east edges from the current pixel.        
                else
                    north_west_pixel = input_image(column+1, row-1);
                    south_east_pixel = input_image(column-1, row+1);
                    
                    % extend the edge lines for the respective position for
                    % the pixel
                    if(north_west_pixel >= threshold2)
                        edge_map(column+1,row-1) = current_pixel;
                    end
                    if(south_east_pixel >= threshold2)
                        edge_map(column-1,row+1) = current_pixel;
                    end
                end
            end
        end
    end
end