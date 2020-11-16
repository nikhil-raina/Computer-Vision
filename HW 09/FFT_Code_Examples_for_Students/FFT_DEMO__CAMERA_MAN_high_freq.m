function FFT_DEMO__CAMERA_MAN_high_freq( fn )
FS          = 24;
FFT_RADIUS  = 16;

    if nargin < 1
        fn = 'cameraman.tif';
    end
    
    im_space    = imread( fn );
    
    dims = size( im_space );
    if (length( dims ) > 2 )
        im_space = rgb2gray( im_space );
    end
    
    DC_LEVEL = mean( im_space(:) );
    
    %
    %  Display the image:
    %
    fig1 = figure('Position', [10 50 1024 768]);
    imagesc( im_space );
    colormap(gray(256));
    colorbar;
    title( 'Original Image ', 'FontSize', FS );
    axis image;
    
    
    [dr, bn, ex] = fileparts( fn );
    fn_out_gray = sprintf('%s_gray.%s', bn, ex );
    fn_out_high = sprintf('%s_high_freq.%s', bn, ex );
    
    % Hack in quality for JPEG:
%     imwrite( im_space, fn_out_gray, 'Quality', 98 );
    
    
    
    %
    %  Take the FFT, shift it for visibility, and display it:
    %
    im_fft      = fftshift(    fft2( im_space ) );
    im_fft_mag  = abs( im_fft );
    im_fft_ang  = angle( im_fft );
    
    
    fig2 = figure('Position', [50 10 1024 768]);
    imagesc( log( im_fft_mag ) );
    colormap(gray(256));
    title( 'Magnitude of Fourier Transform of Image ', 'FontSize', FS );
    

    %
    %   FIND ALL POINTS MORE THAN 10 AWAY FROM THE CENTER POINT.
    %
    dims        = size( im_fft_mag );
    
    [xs ys]     = meshgrid( 1:dims(2), 1:dims(1) );
    
    cntr_xy      = round( dims / 2 );
    
    delta_x         = xs - cntr_xy(2);
    delta_y         = ys - cntr_xy(1);
    
    dists           = ( delta_x .^ 2 + delta_y .^ 2 ) .^ (1/2);

    b_low_freqs     = dists <= FFT_RADIUS;
    
    im_fft(     b_low_freqs ) = 0; 
    im_fft_mag( b_low_freqs ) = 0;
    
    
    fig3 = figure('Position', [10 200 1024 768]);
    imagesc( log( im_fft_mag ) );
    colormap(gray(256));
    title( 'Frequencies that remain after removing low frequencies. ', 'FontSize', FS );
    axis image;
    
    
    
    new_im_space    = abs( ifft2( fftshift( im_fft ) ) );
    
    fig4 = figure( 'position', [10 10 1024 768] );
    imagesc( new_im_space );
    colormap(gray(256));
    title('Inverse Fourier Transform of High Frequencies ', 'FontSize', FS );
    
    % Add back in the DC level:
    % Re-scale for visibility using dynamic ranging:
    mmax = max( new_im_space(:) );
    mmin = min( new_im_space(:) );
    
    new_im_space_uint8 = uint8( (new_im_space-mmin)*255/(mmax-mmin) );
    
    % Hack in quality for JPEG:
%     imwrite( new_im_space_uint8, fn_out_high, 'Quality', 98 );
    
    figure();
    imshow( new_im_space_uint8 );
    colormap(gray(256));
    
    % Reverse the display order:
    figure( fig3 );
    figure( fig2 );
    figure( fig1 );
end
