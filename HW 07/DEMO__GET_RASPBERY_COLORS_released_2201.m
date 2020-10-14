function DEMO__GET_RASPBERY_COLORS_released_2201( fn )
%
%  Look up the documentation of any functions you have not seen before.
%

%INTERACTIVE = 0;

    fprintf('%% Look up the documentation of any functions you have not seen before.\n');
    
    if nargin < 1
        % This is a default filename.
        % It works for me, in my directory, but won't work for you...
        fn = 'IMG_0190__RASPBERRIES__small.jpg';
    end
    % I DONT KNOW WHAT THIS IS FOR
 %   if  ( INTERACTIVE )
        % reading in the image file that has been passed by the driver
        % function
        im_rgb = imread( fn );

        % This displays the image to the user. It also allows the user to
        % increase and decrease the size of the image without changing its
        % orientation. This is for allowing the user to enter in the
        % necessary inputs for foreground and background
        figure('Position',[10 10 1024 768]);
        
        % I DONT KNOW WHAT THIS IS FOR
        %zoom_figure( [1200 800]);
        imagesc( im_rgb );
        axis image;

        % Asks input from the user for foreground values and waits for the
        % enter key to be pressed.
        fprintf('SELECT FOREGROUND OBJECT ... ');
        title('SELECT FOREGROUND OBJECT POINTS ... ', 'FontSize', 24 );
        fprintf('Click on points to capture positions:  Hit return to end...\n');
        [x_fg, y_fg] = ginput();

        % Asks input from the user for background values and waits for the
        % enter key to be pressed.
        fprintf('SELECT BACKGROUND OBJECT ... ');
        title('SELECT BACKGROUND OBJECT POINTS ... ', 'FontSize', 24 );
        fprintf('Click on points to capture positions:  Hit return to end...\n');
        [x_bg, y_bg] = ginput();

        % I DONT KNOW WHAT THIS IS FOR
        save my_temporary_data;
  %  else
   %     load my_temporary_data;
    %end
    
    % converts the RGB image to HSV image
    im_hsv      = rgb2hsv( im_rgb );
    
    % Separates the Hue channel from the HSV image
    im_hue      = im_hsv(:,:,1);
    
    % Separates the Value channel from the HSV image
    im_value    = im_hsv(:,:,3);
    
    % converting the matrix of the hue values to indices. This allows a
    % simpler way to identify the point on the image that was selected
    % previously. Here, the hue and the values are being found of the
    % foreground 
    fg_indices  = sub2ind( size(im_hue), round(y_fg), round(x_fg) );
    fg_hues     = im_hue( fg_indices );
    fg_values   = im_value( fg_indices );
    
    % converting the matrix of the hue values to indices. This allows a
    % simpler way to identify the point on the image that was selected
    % previously. Here, the hue and the values are being found of the
    % background 
    bg_indices  = sub2ind( size(im_hue), round(y_bg), round(x_bg) );
    bg_hues     = im_hue( bg_indices );
    bg_values   = im_value( bg_indices );
    
    % Plots the respective hue and value points
    figure('Position',[10 10 1024 768]);
    
    % all the hue points of the foreground and the background while the 
    % are plotted. They are marked with red squares
    plot( fg_hues, fg_values, 'rs', 'MarkerFaceColor', 'r', 'MarkerSize', 16  );
    hold on;
    
    % all the value points of the foreground and the background while the 
    % are plotted. They are marked with blue circles
    plot( bg_hues, bg_values, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 16  );
    xlabel( 'HUE ANGLE ', 'FontSize', 22 );
    ylabel( 'Value ', 'FontSize', 22 );
    title(' Foreground and Background Points in Hue Angle and Value ', 'FontSize', 24 );
    
%     
%     disp('paused.  Hit return to continue: ' );
%     pause( );
%    
    
    
    %
    %  REPEAT THE ANALYSIS FOR LAB SPACE
    % converts the rgb image to LAB format
    im_lab      = rgb2lab( im_rgb );
    
    % separates the A channel from the LAB image
    im_a        = im_lab(:,:,2);
    
    % separates the B channel from the LAB image
    im_b        = im_lab(:,:,3);
%     
%     Already have these values:
%     fg_indices  = sub2ind( size(im_lab), round(y_fg), round(x_fg) );
    % from the above 'indicized' [fg_indices] list representing the image,
    % it pulls out the specific x and y coordinates from the foreground,
    % but from the A and B channels
    fg_a        = im_a( fg_indices );
    fg_b        = im_b( fg_indices );
    
%     Already have these values:
%     bg_indices  = sub2ind( size(im_klab), round(y_bg), round(x_bg) );
    % from the above 'indicized' [fg_indices] list representing the image,
    % it pulls out the specific x and y coordinates from the background,
    % but from the A and B channels
    bg_a        = im_a( bg_indices );
    bg_b        = im_b( bg_indices );
    
    figure('Position',[10 10 1024 768]);
    
    % all the A and B channel points of the foreground and the 
    % background while the  are plotted. They are marked with red squares
    plot( fg_a, fg_b, 'rs', 'MarkerFaceColor', 'r', 'MarkerSize', 16 );
    
    % allows the current plot to remain as the ongoing figure, By doing
    % this, all the other details for creating more plots and any other
    % activity regarding plotting or statistics, will appear on the current
    % figure.
    hold on;                        % Why do I use this?  What does it do??

    % all the A and B channel points of the foreground and the 
    % background while the  are plotted. They are marked with blue circles
    plot( bg_a, bg_b, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 16  );
    
    xlabel( 'a* ', 'FontSize', 24, 'FontWeight', 'bold' );
    ylabel( 'b* ', 'FontSize', 24, 'FontWeight', 'bold' );
    title(' Foreground and Background Points in a* and b* ', 'FontSize', 32 );

    
    % COMPUTE COVARIANCE FOR FG POINTS IN ab SPACE:
    fg_ab       = [ fg_a fg_b ];                    % This forms a matrix of the two features of the 
                                                    % foreground object.
    mean_fg     = mean( fg_ab );                    % Their mean
    
    % returns the co-variance of the foreground matrix
    cov_fg      = cov( fg_ab );
    
    % this forms a matrix of the two features of the background object.
    bg_ab       = [ bg_a bg_b ];            % What does this do?
    
    % returns the mean of the background matrix
    mean_bg     = mean( bg_ab );            % What does this do?
    
    % returns the co-variance of the background matrix
     cov_bg      = cov( bg_ab );             % What does this do?
    
    im_ab_2 = [im_a im_b];
    im_ab       = [ im_a(:) im_b(:) ];
    
    %
    %  Look up the documentation of any functions you have not seen before.
    %
    mahal_fg    = ( mahal( im_ab, fg_ab ) ) .^ (1/2);
    mahal_bg    = ( mahal( im_ab, bg_ab ) ) .^ (1/2);
    
    %
    %  Classify as Class 0 (foreground object) if distance to FG is < distance to BG.
    %
    %  You will want to add a tolerance factor for your work to improve your accuracy.
    %  
    %  I AM NOT SURE IF WE ARE SUPPOSED TO BE ADDING MORE CODE HERE TO
    %  IMPROVE THE ACCURACY
    %  does classification between the oranges and the background. The
    %  foreground represent the oranges, which should be greater than the
    %  values that are in the background at those points. Thus, the
    %  resulting binarised matrix will have blacked out all but the oranges
    %  and they will appear white.
    class_0     = mahal_fg < mahal_bg;
    
    % resizes the array into the size of the original image. 
    class_im    = reshape( class_0, size(im_a,1), size(im_a,2) );
    
    figure('Position',[10 10 1024 768]);
    
    % position of the plot that will appear on the figure
    subplot(2,2,1);
    imagesc(im_rgb);
    axis image;
    title('Image in RGB ', 'FontSize', 20, 'FontWeight', 'bold' );
    
    % position of the plot that will appear on the figure
    subplot(2,2,2);
    imagesc( class_im );
    axis image;
    colormap(gray);
    title(' Classification using Mahalanobis Distance ', 'FontSize', 20, 'FontWeight', 'bold' );
    
    subplot(2,2,3);
    fg_dists        = mahal_fg;
    
    % stores all the data of the cells from the fg_dists where the 
    % corresponding class_0 values are 1.
    fg_dists_cls0   = fg_dists( class_0 );  
    mmax            = max( fg_dists_cls0 );
    mmin            = min( fg_dists_cls0 );
    
    % calculates edges from the min value to the max value with (
    % mmax-mmin)/100 as the difference between each corresponding value
    edges           = mmin : (mmax-mmin)/100 : mmax;
    
    % THE NAMING CONVENTION IS WRONG HERE. IT RETURNS IN A DIFFERENT ORDER
    % -> bins freqs
    % and not -> freqs bins
    % I AM MAKINGNTHIS CHANGE IN THE LINES OF CODE TO REFLECT THIS. I THINK
    % THAT THIS COULD BE MENTIONED IN THE REPORT AS WELL. BUT YOUR CALL IF
    % WE SHOULD MAKE THE NAMING CONVENTION NAME CHANGE OR NOT.
    % 
    % returns the frequency and the bins from the histc() function call.
    [bins freqs]    = histc( fg_dists, edges );
    
    % creates a bar graph
    bar( edges, bins );
    aa = axis();
    title('Foreground Distances ', 'FontSize', 20, 'FontWeight', 'bold' );
    
    %
    %  Form a model of the foreground Mahalanobis distance:
    %
    fg_dists        = mahal_fg;
    
    % stores all the data of the cells from the fg_dists where the 
    % corresponding class_0 values are 1.
    fg_dists_cls0   = fg_dists(class_0);
    
    % finds the mean of fg_dists_cls0 
    dist_mean       = mean( fg_dists_cls0 );
    
    % finds the standard deviation of fg_dists_cls0 
    dist_std_01     = std(  fg_dists_cls0 );
    

    %
    % OUTLIER REMOVAL:
    % Toss everything outside of one standard deviation, and re-adjust the mean value:
    %
    % this removes extra data from the fg_dists_cls0 to be displayed as
    % oranges by having a limit of one standard deviation. This extra data
    % can be thought of outliers. 
    b_inliers       = ( fg_dists_cls0 <= (dist_mean + dist_std_01) ) & ( fg_dists_cls0 >= (dist_mean - dist_std_01));
    the_inliers     = fg_dists_cls0( b_inliers );
    dist_mean       = mean( the_inliers );
    


    %
    %  Use a distance to target variable as rules for inclusion:
    %  We could do better than this by adding some additional tolerance.
    %
    threshold       = dist_mean;
    guess_cls0      = fg_dists < threshold;
    % Change the shape of the classification to look like an image:
    class_im        = reshape( guess_cls0, size(im_a,1), size(im_a,2) );
    subplot(2,2,4);
    imagesc( class_im );
    title('Refined Foreground Classification w/ Outlier Removal ', 'FontSize', 20, 'FontWeight', 'bold' );
    
end


