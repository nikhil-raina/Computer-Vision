function HW_09_Kimbrell_Raina
    im_zeros = zeros(512,512, 'double'); % initialize
    D = 64;
    RADIUS = 650;
    original_row = 1024;
    original_column = 1024;
    
    im_zeros(:, 1:256) = 1.0;      % set left half to 1.0 or white
    im_zeros(:, 257:end) = 0.0;    % set right half to 0.0 or black
    
    % calls the respective outside and inside FFT methods
    outside_fft(im_zeros, D);
    figure();
    inside_fft(im_zeros, D);
    
    % accepts the example-image and resizes it to 1024x1024
    im = double(imread('example-image.png'))/255;
    im_resize = imresize(im, [original_row original_column]);
    im_gray = rgb2gray(im_resize);
    
    % calls the convolution method
    convolution(im_gray, original_column, original_row);
    
    % call high pass filtering
    pass_filtering(im_gray, RADIUS, 1);
    
    % calls low pass filtering
    pass_filtering(im_gray, RADIUS, 0);
    
end


function convolution(im_gray, original_row, original_column)
    % the ear pattern in the gray image
    im_pattern = imcrop(im_gray, [470 280 45 50]);
    
    % resizing the pattern image to 64x64
    row = 64;
    column = 64;
    im_pattern = imresize(im_pattern, [row column]);
    
    % reverses the pattern from left to right and top to bottom
    left_to_right = flip(im_pattern, 2);
    im_reversed = flip(left_to_right, 1);
    
    % Pads the pattern with 0s on all 4 sides
    % finds the fourier frequency of the original image and then shifts 
    % it back for viewing purpose
    im_fft2 = fft2(im_gray);
    im_fft2_shift = fftshift(im_fft2);
    
    % finds the fourier frequency of the original image and then shifts 
    % it back for viewing purpose
    pattern_fft2 = fft2(im_reversed, original_row, original_column);
    pattern_fft2_shift = fftshift(pattern_fft2);
    
    % point-wise multiplication of the shifted patterns with the shifted
    % original image
    results_fft2 = im_fft2.* pattern_fft2;
    
    results_from_convolution = abs(ifft2(results_fft2));
    
    figure('Position', [10 200 1024 768]);
    imagesc(results_from_convolution);
    colormap('gray');
    imwrite(results_from_convolution, 'example-image-FFT-result.png');
end


function pass_filtering(im_gray, RADIUS, isHigh)
    im_fft2 = fft2(im_gray);
    im_fft2_mag_shift = fftshift(im_fft2);
    
    % finding and setting all the points out of RADIUS to 0
    im_fft2_mag = abs(im_fft2_mag_shift);
    
    % finds the dimensions of the passed image
    dims = size( im_fft2_mag );
    
    [xs ys] = meshgrid( 1:dims(2), 1:dims(1) );
    
    % gets the center of the image
    cntr_xy = round( dims / 2 );
    
    % calculats he coordinate distance of each axis point to the center.
    delta_x = xs - cntr_xy(2);
    delta_y = ys - cntr_xy(1);
    
    % gets all the distance values from the center to the end
    dists = ( delta_x .^ 2 + delta_y .^ 2 ) .^ (1/2);

    % decides which frequency to choose from
    if(isHigh)
        % high frequencies
        freqs = dists > RADIUS;
    else
        % low frequencies
        freqs = dists <= RADIUS;
    end
    
    % assigns all the required frequencies to 0
    im_fft2_mag( freqs ) = 0;
    im_fft2( freqs ) = 0;
    
    % finds the inverse transformations to display
    im_ifft2_mag = ifft2(fftshift(im_fft2_mag));
    im_ifft2 = ifft2(fftshift(im_fft2));
    
    % Stores the images for display
    im_ifft2_mag_to_show = log(abs(im_ifft2_mag)); 
    im_ifft2_to_show = log(abs(im_ifft2)); 
    
    % prints the frequency transformations
    figure('Position', [10 200 1024 768]);
    imagesc(im_ifft2_mag_to_show);
    colormap('gray');
    
    % prints the original images frequency transformation
    figure('Position', [10 200 1024 768]);
    imagesc(im_ifft2_to_show);
    colormap('gray');
    
    % Saves the file appropriately
    if(isHigh)
        imwrite(im_ifft2_mag_to_show, 'High_Frequency.jpg');
        imwrite(im_ifft2_to_show, 'High_Frequency_Original_Image.jpg');
    else
        imwrite(im_ifft2_mag_to_show, 'Low_Frequency.jpg');
        imwrite(im_ifft2_to_show, 'Low_Frequency_Original_Image.jpg');
    end
    
end

function inside_fft(im, D)
    % inside +/- D pixels
    im(:,D:end-D) = 0;
    
    % get the fourier transform of the matrix
    fourier_transformation = fft2(im);
    
    % use ffshift w/ fourier
    shift = fftshift(fourier_transformation);
    
    % get the matrix back from the frquency domain
    fourier_transformation = ifft2(shift); 
    imagesc(fourier_transformation);
    title('Inside +/- D Pixels');
    %fourier_transformation = fourier_transformation + 0.5;
end


function outside_fft(im, D)
    % outside +/- D pixels
    im(:,1:D) = 0;
    im(:, end-D: end) = 0;
    
    % get the fourier transform of the matrix
    fourier_transformation = fft2(im);
    
    % use ffshift w/ fourier
    shift = fftshift(fourier_transformation);
    
    % get the matrix back from the frquency domain
    fourier_transformation = ifft2(shift);
    imagesc(fourier_transformation);
    title('Outside +/- D Pixels')

end
