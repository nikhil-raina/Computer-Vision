function find_board_status_v10( )
% 
% Here is some code to get you well on your way to analyzing the board...
% 
% Fri Sep  4 17:32:02 EDT 2020
%
% Dr. Thomas B. Kinsman, Ph.D. 
% 

    fprintf('Program to read in an image of an Othello board\n');
    fprintf('and compute which side is currently winning\n\n');

    im_uint8    = imread( 'IMG_3862__othello_in.jpg' );
    im_dbl      = im2double( im_uint8 );

    imshow( im_dbl );
    title('Original Image', 'FontSize', 24 );
    set( gcf(), 'Position',  [ 1550, -192, 1484, 896 ] );

    % Split out the colors:
    im_red_channel      = im_dbl(:,:,1);
    im_grn_channel      = im_dbl(:,:,2);
    im_blu_channel      = im_dbl(:,:,3);
    figure('Color', [1 1 1] * 0.5 );
    
    subplot( 2, 2, 2 );
    imagesc( im_red_channel );
    axis image;
    title('RED', 'FontSize', 30, 'Color', 'r' );
    colormap( gray );
    set( gcf(), 'Position',  [ 1550, -150, 1400, 900 ] );
    
    subplot( 2, 2, 3 );
    imagesc( im_grn_channel);
    axis image;
    title('GREEN', 'FontSize', 30, 'Color', [0 0.875 0]  );
    
    subplot( 2, 2, 4 );
    imagesc( im_blu_channel );
    axis image;
    title('BLUE', 'FontSize', 30, 'Color', [0.3 0.3 1] );
    
    % %%%%%%%%%%%%%%%%%%%%%%
    % Form a grayscale,
    % by finding the average amount of each color:
    im_gray             = ( im_red_channel + im_grn_channel + im_blu_channel ) / 3;

    % Show the grayscale image:
    subplot( 2, 2, 1 );
    imagesc( im_gray );
    axis image;
    title('Gray Scale', 'FontSize', 30 );
    
    fprintf('Which color is closest to Gray?\n');

    % Find the histogram:
    figure( 'Position', [ 1500, -200, 1200, 800 ] ); 
    imhist( im_gray );
    title('Histogram of Grayscale Pixel Values', 'FontSize', 30 );
    
    % Manually sub-divide the image, based on inspection of 
    % the histogram:
    im_white_pieces    = im_gray >= 0.65;  % THIS IS A BOOLEAN IMAGE.
    imshow( im_white_pieces );
    set( gcf(), 'Position',  [ 1600, -200, 1200, 800 ]  );
    title('White Disks.  White indicates white color.', 'FontSize', 24 );

    im_black_pieces    = im_gray < 0.155;       % AGAIN, A BOOLEAN.
    imshow( im_black_pieces );
    set( gcf(), 'Position',  [ 1620, -200, 1200, 800 ]  );
    title('Black Disks.  White indicates black color.', 'FontSize', 24 );

    im_dubious    = true( size(im_gray) );
    im_dubious    = im_dubious & ~im_white_pieces;
    im_dubious    = im_dubious & ~im_black_pieces;
    imshow( im_dubious );
    set( gcf(), 'Position',  [ 1680, -200, 1200, 800 ]  );
    title('Dubious.  White indicates Dubious Pixels.', 'FontSize', 24 );

    im_ed = edge( im_white_pieces );
    imshow( im_ed );
    set( gcf(), 'Position',  [ 1700, -200, 1200, 800 ]  );
    title('Edges Results of finding edges on white Pieces.', 'FontSize', 24 );

    %
    % Here we call a Matlab routine that we don't know how it works yet...
    %
    % You have to wonder how this works, because we will learn later.
    %
    [cntrs, radii] = imfindcircles( im_ed, [29, 41] );
    
    % show the results:
    for circle_index = 1 : length( cntrs )
        hold on;
        circle_drawing( cntrs(circle_index,:), radii(circle_index), 32 );
    end

    % Bring back the original image, and annotate it:
    figure( 'Color', 'k' );
    imagesc( im_dbl );
    axis image;
    set( gcf(), 'Position', [ 1450, -200, 1400, 900 ]  );
    set( gca(), 'Position', [0 0 1 1] );                    % CAUTION STUDENTS
    axis off;
    hold on;
    for circle_index = 1 : length( cntrs )
        circle_drawing( cntrs(circle_index,:), radii(circle_index), 32 );
    end
    beep;
    fprintf('What color are the white chips now?\n');
    beep;
    pause(3);
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Now work on the black circles:
    %
    im_ed = edge( im_black_pieces );
    figure();
    imshow( im_ed );
    set( gcf(), 'Position',  [ 1700, -200, 1200, 800 ]  );
    title('Edges Results of finding edges on black Pieces.', 'FontSize', 24 );

    [cntrs, radii] = imfindcircles( im_ed, [25, 65] );
    
    % show the results:
    for circle_index = 1 : length( cntrs )
        hold on;
        circle_drawing( cntrs(circle_index,:), radii(circle_index), 32, [1 0 0] );
    end

    % Bring back the original image, and annotate it:
    figure( 'Color', 'k' );
    imagesc( im_dbl );
    axis image;
    set( gcf(), 'Position', [ 1550, -200, 1400, 900 ]  );
    set( gca(), 'Position', [0 0 1 1] );                    % CAUTION STUDENTS - ORDER OF PARAMETERS CHANGE... 
    axis off;
    hold on;
    for circle_index = 1 : length( cntrs )
        circle_drawing( cntrs(circle_index,:), radii(circle_index), 32, [0 1 1] );
    end
    beep;
    fprintf('What color are the black chips now?\n');
    beep;
    pause(5);

end


