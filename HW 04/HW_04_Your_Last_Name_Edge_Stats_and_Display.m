function HW_04_Your_Last_Name_Edge_Stats_and_Display( fn_in, hw_part_number )
MARGIN          = 20;
CUTOFF_PERCENT  = 0.95;

    % reads in the image as a double
    % stories it into im_in
    %
    im_in  = im2double( imread( fn_in ) );
    
    % if the image matrix is 3d goes through a filter a rotationally 
    % symmetric Gaussian lowpass filter of size [5 5] with standard deviation 1
    % and removes last array dimension
    % other wise, img stays the same
    %
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
    
    % 
    % takes vt and flips the rows and columns setting the new array to hz
    %
    edge_detector_vt = [ 1  2  1 ; 
                         0  0  0 ;
                        -1 -2 -1 ]/8;
    edge_detector_hz    = edge_detector_vt.';

    % filters the image through the edge_detector array
    % vt show horizontal edgest that hz missed but misses vertical edges
    % hz shows vertical edges that vt missed but misses horizontal images
    edges_vt            = imfilter( im_grn, edge_detector_vt, 'same', 'repl' );
    edges_hz            = imfilter( im_grn, edge_detector_hz, 'same', 'repl' );
    
    % combines the found edges and puts it togetherin one picture
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
    % in steps of size edge_bin-inc
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
    
    %
    % calculating th pixel number to cut off at; should be the CUTOFF'th
    % percentile
    %
    ninty_five_pc_count = CUTOFF_PERCENT * n_pixels;
    
    %
    % finds first index of a value in bin_cumulatives thats is greater than
    % the 95th percentile of px count
    %
    stop_ind            = find( bin_cumulatives > ninty_five_pc_count, 1, 'first' );
    
    %
    %
    %
    over_ninty_five_val = bin_edges( stop_ind );

    %
    %
    %
    edge_mag( edge_mag <= over_ninty_five_val ) = 0;
    
    %
    %  
    %
    %
    %
    ss = get(0,'ScreenSize' );
    ss_fl  = floor( ss(3) * 0.95 );
    ss_ceil  = ceil(  ss(4) * 0.95 );
    
    fig1 = figure('Position', [4 4 ss_fl ss_ceil] );
    
    %
    %
    %
    stem( bin_edges(1:end-1), bin_counts, 'MarkerFaceColor', 'b');
    
    %
    %
    %
    set(gca(), 'Position', [0.05 0.05 0.9 0.9]);
    
    
    %
    %
    %
    new_axis        = axis();
    new_axis(1)     = 0;
    new_axis(2)     = 0.10;
    axis( new_axis );
    
    %
    %
    %
    hold on;
    
    %
    %  What is this doing or showing...
    %
    plot( [1 1]*(over_ninty_five_val+edge_bin_inc/2), [0 new_axis(4)], 'm-', 'LineWidth', 1.5 );
    
    %
    %
    %
    %  t and u are lousy variable names.  Please fix them.
    %
    t       = round( ss(3)*0.6 );
    u       = round( ss(4)*0.8 );
    w       = floor( ss(3)*0.4 );
    fig2_posit    = [ w 10 t u ];
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


