function Othello_Counting()
    im = imread( 'IMG_3862__othello_in.jpg' );
    % to do some craaazyyyyy math
    im_double = im2double(im);
    im_gray = rgb2gray(im_double);
    %imhist(imgray);
    im_white = im_gray >= 0.70;
    im_black = im_gray <= 0.19;
    [white_circles, white_radii] = imfindcircles(im_white, [29, 41]);
    [black_circles, black_radii] = imfindcircles(im_black, [25, 65]);
    imshow(im);
    hold on;
    for circle_idx = 1 : length(white_circles)
        hold on;
        circle_drawing(white_circles(circle_idx, :), white_radii(circle_idx), 100 )
    end
    for circle_idx = 1 : length(black_circles)
        hold on;
        circle_drawing(black_circles(circle_idx, :), black_radii(circle_idx), 4 )
    end
    fprintf('The number of black circles %d \n', length(white_circles));
    fprintf('The number of white circles %d \n', length(black_circles));
end