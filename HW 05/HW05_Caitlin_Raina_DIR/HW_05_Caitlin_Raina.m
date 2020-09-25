function HW_05_Caitlin_Raina()
    im = imread('ballet.jpg');
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
    fltr = fspecial('Gaussian', 7, 2);
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
    angle_im = floor(im_angle / angle_size) * angle_size; 
    
    imagesc(im_mag);
    axis image;
    colormap(gray(256))
    
    % finding threshold 1 (non-maximal suppression
    seedpoints = zeros( size( im_mag ) );    % set all points to 0 first
    threshold1 = max(max(im_mag))/2         % set threshold to max of im_mag 
    threshold2 = threshold1/6           % set threshold to threshold1/2
    for col = 2:1:size(im_mag,1) - 1
        for row = 2:1:size(im_mag,2)-1
            dir = im_angle(col,row);    % get direction of pixel
            if dir == 0     % vertical edge compare with west and east pixels
                pix1 = im_mag(col-1, row);
                pix2 = im_mag(col+1, row);
                pix = im_mag(col, row);
                if(pix > pix1 && pix > pix2 && pix >= threshold1)
                    seedpoints(row,col) = pix;  % maximal point
                end
            elseif dir == 45  % diagonal edge
                pix1 = im_mag(col-1, row-1);
                pix2 = im_mag(col+1, row+1);
                pix = im_mag(col, row);
                if(pix > pix1 && pix > pix2 && pix >= threshold1)
                    seedpoints(row,col) = pix;
                end
            elseif dir == 90        % horizontal edge
                pix1 = im_mag(col, row-1);
                pix2 = im_mag(col, row+1);
                pix = im_mag(col, row);
                if(pix > pix1 && pix > pix2 && pix >= threshold1)
                    seedpoints(row,col) = pix;
                end
            
            end
        end
    end
    edge_prop = edge_propogation(im_mag, threshold1, threshold2, seedpoints, im_angle);
    for num = 0:1:20
        edge_prop=edge_propogation(im_mag, threshold1, threshold2,edge_prop, im_angle);
    end
    
    imagesc(edge_prop);
    axis image;
    colormap(gray(256))
end

function edge_prop = edge_propogation(im_mag, threshold1, threshold2, seedpoints, im_angle)
    % edge propogation
    edge_prop = seedpoints;
    
    for col = 2:1:size(im_mag,1) - 1
        for row = 2:1:size(im_mag,2)-1
            seed = edge_prop(col,row);
            if seed >= threshold1
                dir = im_angle(col,row);    % get direction of pixel
                if dir == 0     % vertical edge compare with west and east pixels
                    pix1 = im_mag(col-1, row);
                    pix2 = im_mag(col+1, row);
                    if(pix1 >= threshold2)
                        edge_prop(col-1,row) = seed;  % maximal point
                    end
                    if(pix2 >= threshold2)
                        edge_prop(col+1,row) = seed;
                    end
                elseif dir == 45  % diagonal edge
                    pix1 = im_mag(col-1, row-1);
                    pix2 = im_mag(col+1, row+1);
                    if(pix1 >= threshold2)
                        edge_prop(col-1,row-1) = seed;  % maximal point
                    end
                    if(pix2 >= threshold2)
                        edge_prop(col+1,row+1) = seed;
                    end
                elseif dir == 90        % horizontal edge
                    pix1 = im_mag(col, row-1);
                    pix2 = im_mag(col, row+1);
                    if(pix1 >= threshold2)
                        edge_prop(col,row-1) = seed;  % maximal point
                    end
                    if(pix2 >= threshold2)
                        edge_prop(col,row+1) = seed;
                    end
                end
            end
        end
    end
end

function edge_map = canny_edges(input_image, threshold1, threshold2, sigma_for_gaussian_filter)
    
end