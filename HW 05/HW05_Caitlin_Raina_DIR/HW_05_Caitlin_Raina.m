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
end

function edge_map = canny_edges(input_image, threshold1, threshold2, sigma_for_gaussian_filter)
    
end