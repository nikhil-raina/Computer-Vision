function FFT_DEMO__CAMERA_MAN_high_freq_GAUSSIAN( fn )
FS          = 24;       % Font Size

    if nargin < 1
        fn = 'cameraman.tif';
    end
    
    im_space    = imread( fn );
    
    dims = size( im_space );
    if (length( dims ) > 2 )
        im_space = rgb2gray( im_space );
    end
    
    DC_LEVEL = mean( im_space(:) );
    
    
    [dr, bn, ex] = fileparts( fn );
    fn_out_gray = sprintf('%s_gray.%s', bn, ex );
    fn_out_low  = sprintf('%s_low_freq.%s', bn, ex );
    
    % Hack in quality for JPEG:
    imwrite( im_space, fn_out_gray, 'JPEG', 'Quality', 98 );
    
    %
    %  Display the image:
    %
    fig1 = figure('Position', [10 50 1024 768]);
    imagesc( im_space );
    colormap(gray);
    colorbar;
    title( 'Original Image ', 'FontSize', FS );
    axis image;
    
    
    
    %
    %  Take the FFT, shift it for visibility, and display it:
    %
    im_fft      = fftshift(    fft2( im_space ) );
    im_fft_mag  = abs( im_fft );
    im_fft_ang  = angle( im_fft );
    
    
    fig2 = figure('Position', [50 10 1024 768]);
    imagesc( log( im_fft_mag ) );
    colormap( gray(256) );
    title( 'Magnitude of Fourier Transform of Image ', 'FontSize', FS );
    

    %
    %   FIND ALL POINTS MORE THAN 10 AWAY FROM THE CENTER POINT.
    %
    dims            = size( im_fft_mag );
    
    % Create a large Gaussian, and normalize it so
    % that the maximum value is 1.0.
    big_gaussian    = fspecial('Gauss', [dims], 10 );
    big_gaussian    = big_gaussian / max( big_gaussian(:) );
    high_pass       = 1 - big_gaussian;
    
    im_fft          = im_fft     .* high_pass;
    im_fft_mag      = im_fft_mag .* high_pass;
    
    fig3 = figure('Position', [10 200 1024 768]);
    imagesc( log( im_fft_mag ) );
    colormap( gray(256) );
    title( 'High Frequencies that remain after High Pass in Freq. Domain ', 'FontSize', FS );
    axis image;
    
    
    
    new_im_space    = abs( ifft2( fftshift( im_fft ) ) );
    
    fig4 = figure( 'position', [10 10 1024 768] );
    imagesc( new_im_space );
    colormap( gray );
    title('Inverse Fourier Transform of High Frequencies ', 'FontSize', FS );
    
    
    % Add back in the DC level:
    % Re-scale for visibility using dynamic ranging:
    mmax = max( new_im_space(:) );
    mmin = min( new_im_space(:) );
    
    new_im_space_uint8 = uint8( (new_im_space-mmin)*255/(mmax-mmin) );
    
    % Hack in quality for JPEG:
    imwrite( new_im_space_uint8, fn_out_low ); % , 'Quality', 98 );
    
    figure();
    imshow( new_im_space_uint8 );
    colormap( gray(256) );

    % Reverse the display order:
    figure( fig3 );
    figure( fig2 );
    figure( fig1 );
end
