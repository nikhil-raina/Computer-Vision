function FFT_DEMO__CAMERA_MAN_low_freq_FOR_STUDENTS( fn )
FS          = 90;    % Try different values.
FFT_RADIUS  = 80;    % Try different things.
    if ( nargin < 1 )
        fn = 'cameraman.tif';
    end
    im_space    = imread( fn );
    dims = size( im_space );
    if (length( dims ) > 2 )
        im_space = rgb2gray( im_space );
    end
    [dr, bn, ex] = fileparts( fn );
    fn_out_gray  = sprintf('%s_gray.%s', bn, ex );
    fn_out_low   = sprintf('%s_low_freq.%s', bn, ex );
    imwrite( im_space, fn_out_gray, 'JPEG', 'Quality', 98 );
    fig1 = figure('Position', [10 50 1768 768]);
    imagesc( im_space ); colormap(gray); colorbar;
    title( 'Original Image ', 'FontSize', FS );
    axis image;
    im_fft      = fftshift(    fft2( im_space ) );
    im_fft_mag  = abs( im_fft );
    im_fft_ang  = angle( im_fft );
    fig2 = figure('Position', [50 10 1224 900]);
    imagesc( log( im_fft_mag ) );
    colormap( gray(256) );
    title( 'Magnitude of Fourier Transform of Image ', 'FontSize', FS );
    dims             = size( im_fft_mag );
    [xs, ys]         = meshgrid( 1:dims(2), 1:dims(1) );
    cntr_xy          = round( dims / 2 );
    delta_x          = xs - cntr_xy(2);
    delta_y          = ys - cntr_xy(1);
    dists            = ( delta_x .^ 2 + delta_y .^ 2 ) .^ (1/2);
    b_high_freqs     = dists > FFT_RADIUS;
    im_fft(     b_high_freqs ) = 0;
    im_fft_mag( b_high_freqs ) = 0;
    fig3 = figure('Position', [10 200 1024 768]);
    imagesc( log( im_fft_mag ) );
    colormap( gray(256) );
    title( 'Low Frequencies that remain after removing high frequencies. ', 'FontSize', FS );
    axis image;
    new_im_space    = abs( ifft2( fftshift( im_fft ) ) );
    fig4 = figure( 'position', [10 10 1424 843] );
    imagesc( new_im_space );
    colormap( gray );
    title('Inverse Fourier Transform of Low Frequencies ', 'FontSize', FS );
    mmax = max( new_im_space(:) ); mmin = min( new_im_space(:) );
    new_im_space_uint8 = uint8( (new_im_space-mmin)*255/(mmax-mmin) );
    imwrite( new_im_space_uint8, fn_out_low );    
    figure();
    imshow( new_im_space_uint8 );
    colormap( gray(256) );
    figure( fig4 ); figure( fig3 ); figure( fig2 ); figure( fig1 );
end
