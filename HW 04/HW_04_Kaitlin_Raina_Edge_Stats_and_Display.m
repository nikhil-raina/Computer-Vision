function HW_04_Kaitlin_Raina_Edge_Stats_and_Display( fn_in, hw_part_number )
MARGIN          = 20;
CUTOFF_PERCENT  = 0.95;
    % Reads in the image when passed in to the function call.
    % Converts the image to a double to allow math to be done on it so that
    % the pixel values dont cause any hinderances.
    im_in  = im2double( imread( fn_in ) );
    % if the image matrix is 3d then its green pixels goes through a filter 
    % a rotationally symmetric Gaussian lowpass filter of size [5 5] 
    % with standard deviation 1 and gets stored otherwise the
    % entire image is stored
    if ( length( size( im_in) ) == 3 )
        im_grn = imfilter( im_in(:,:,2), fspecial('gaussian', [5 5], 1 ) );
    else
        im_grn = im_in;
    end
    % filters the image through fltr, output array is the same size as
    % input array and input array values outside bounds of the array is
    % assumed to be equal to the nearest border array value
    
    fltr            = [ 1 2 1 ;
                        2 4 2 ;
                        1 2 1 ] / 16;
    im_grn          = imfilter( im_grn, fltr, 'same', 'repl' );
    % Creates a Sobel Filter that is used to detect the horizontal and 
    % the vertical edges 
    %
    edge_detector_vt = [ 1  2  1 ; 
                         0  0  0 ;
                        -1 -2 -1 ]/8;
    edge_detector_hz    = edge_detector_vt.';

    % filters the image through the edge_detector array
    % the vertical edges and the horizontal edges are recorded
    % separately.
    edges_vt            = imfilter( im_grn, edge_detector_vt, 'same', 'repl' );
    edges_hz            = imfilter( im_grn, edge_detector_hz, 'same', 'repl' );
    
    % combines the found edges and puts it together in one picture
    % edges are enhanced using contrast so we can see what the edges are
    %
    edge_mag            = ( edges_vt.^2 + edges_hz.^2 ).^(1/2);
    %
    % establishing the border margin and making the values = 0
    %
    edge_mag( 1:MARGIN,         : )                = 0;
    edge_mag( end-MARGIN-1:end, : )                = 0;
    edge_mag( :,                1:MARGIN )         = 0;
    edge_mag( :,                end-MARGIN-1:end ) = 0;
    %
    % n_pixels is set to the number of elements in aray im_grn
    %
    n_pixels            = numel( im_grn );
    
    %
    % edge_mmax set to the highest value in edge_mag
    % edge_bin_inc is set to the highest value in edge_mag divided by 256
    %
    edge_mmax           = max( edge_mag(:) );
    edge_bin_inc        = edge_mmax / 256;          % Arrange for 256 bins.
    
    %
    % if this is a hw part greater than 1, edge_bin_inc is set to .0001
    %
    if hw_part_number > 1
        edge_bin_inc  	= 0.0001;
    end
    
    %
    % bin_edges is an array of all the values from 0 to the max edge value
    % in increments of size edge_bin-inc
    %
    bin_edges           = 0 : edge_bin_inc : edge_mmax; 

    %
    % partitions the edge_mag into bins specified by bin_edges
    %
    [bin_counts, ~]     = histcounts( edge_mag(:), bin_edges );
    
    %
    % gets the cumulative sum of the value of bin_counts starting at the
    % beginning of bin_counts
    %
    bin_cumulatives     = cumsum( bin_counts );
    
    % Calculates the cut off value from the n_pixels using the 
    % CUTOFF_PERCENT;
    ninty_five_pc_count = CUTOFF_PERCENT * n_pixels;
    
    %
    % finds first index of a value in bin_cumulatives thats is greater than
    % the 95th percentile of px count
    %
    stop_ind            = find( bin_cumulatives > ninty_five_pc_count, 1, 'first' );
    
    %
    % Returns the bin number from the array of bins that contains the 95th
    % percentile value.
    %
    over_ninty_five_val = bin_edges( stop_ind );

    % Sets all the values that are not above the 95th percentile as 0.
    % This will be removing all the weak edge magnitudes from the list and
    % contain the more prominent or 'bright' ones
    edge_mag( edge_mag <= over_ninty_five_val ) = 0;
    
    % Here, the function gets the screen size of the screen and calculates 
    % the floor and ceil value with the percentile. It sets a default
    % position for the figure that will be displayed on it.
    ss = get(0,'ScreenSize' );
    ss_fl  = floor( ss(3) * 0.95 );
    ss_ceil  = ceil(  ss(4) * 0.95 );
    
    fig1 = figure('Position', [1 4 ss_fl ss_ceil] );
    
    % Plots the data sequence within bin_counts at the values specified
    % form the bin edges. It leaves a blue mark on the top most stem.
    stem( bin_edges(1:end-1), bin_counts, 'MarkerFaceColor', 'b');
    
    % It gets the handle to the current axis and then re-adjusts the axis
    % of the plot by expanding the plots area to fit the desired fihure
    % size
    set(gca(), 'Position', [0.05 0.05 0.9 0.9]);
    
    
    % Explicitly creates a new axis for the figure so that the stem plot is
    % shown clearly in a comprehensive manner.
    new_axis        = axis();
    new_axis(1)     = 0;
    new_axis(2)     = 0.10;
    axis( new_axis );
    
    % Pauses the current figure so that there can be additional drawings or
    % marks that would appear on the current figure and not on a new
    % figure.
    hold on;
    
    % This plots a magenta line where the 95th percentile exists.
    plot( [1 1]*(over_ninty_five_val+edge_bin_inc/2), [0 new_axis(4)], 'm-', 'LineWidth', 1.5 );
    
    % it position the starting coordinate of the figure and then decides
    % the length and height of the figur in the form of x_coor and y_coor
    x_coor          = round( ss(3)*0.6 );
    y_coor          = round( ss(4)*0.8 );
    starting_coor   = floor( ss(3)*0.4 );
    fig2_posit    = [ starting_coor 10 x_coor y_coor ];
    fig2          = figure('Position', fig2_posit );
    imagesc( edge_mag );
    set(gca(), 'Position', [0.05 0.05 0.9 0.9]);
    axis image;
    colormap( 'default' );
    colorbar;
    ttl =  [ fn_in ' '];
    ttl( ttl == '_' ) = ' ';
    title( ttl , 'FontSize', 20 );
    
    set(fig2, 'Position', fig2_posit );
    
end


