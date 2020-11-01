function FFT_DEMO__CAMERA_MAN_angle()
FS          = 24;
FFT_RADIUS  = 16;

    im_space    = im2double( imread( 'cameraman.tif' ) );
    
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
    imagesc( im_fft_ang  );
    title( 'Angle of Fourier Transform of Image ', 'FontSize', FS );
    

    %
    %   FIND ALL POINTS MORE THAN 10 AWAY FROM THE CENTER POINT.
    %
    dims        = size( im_fft_mag );
    
    [xs ys]     = meshgrid( 1:dims(2), 1:dims(1) );
    
    cntr_xy      = round( dims / 2 );
    
    delta_x         = xs - cntr_xy(1);
    delta_y         = ys - cntr_xy(2);
    
    dists           = ( delta_x .^ 2 + delta_y .^ 2 ) .^ (1/2);

    b_high_freqs      = dists > FFT_RADIUS;
    
    im_fft(     b_high_freqs ) = 0; 
    im_fft_mag( b_high_freqs ) = 0;
    
    
    fig3 = figure('Position', [10 200 1024 768]);
    imagesc( log( im_fft_mag ) );
    title( 'Low Frequencies that remain after removing high frequencies. ', 'FontSize', FS );
    axis image;
    
    
    
    new_im_space    = abs( ifft2( fftshift( im_fft ) ) );
    
    fig4 = figure( 'position', [10 10 1024 768] );
    imagesc( new_im_space );
    colormap( gray );
    title('Inverse Fourier Transform ', 'FontSize', FS );
    
    % Reverse the display order:
    figure( fig3 );
    figure( fig2 );
    figure( fig1 );
end
