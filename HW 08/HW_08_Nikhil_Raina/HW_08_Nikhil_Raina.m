function HW_08_Nikhil_Raina(imageName)
    %im = imread('Images__Hello_World/IMG_3987.jpg');
    im = imread(imageName);

    % convert the image to grayscale
    im_gray = rgb2gray(im); 
    imagesc(im);
    [x_fg, y_fg] = ginput();
    
    % binarize the image with a threshold of .6
    bw = imbinarize(im_gray,0.5);

    % create the strel object to use close on its a rectangle because paper is
    % rectangle
    SE = strel('rectangle',[50 50]) ;

    % perform close opertion on the binarized image to get rid of the test
    bw = imerode(bw, SE);
    
    bw = imfill(bw, 'holes');

    % detect the harrisfeatures of the new processed image
    %points = detectHarrisFeatures([x_fg, y_fg]);
    
    % get the strongest 1000 points
    %strongpoints = points.selectStrongest(10);
    fg_indices  = [ round(x_fg) round(y_fg) ];

    % transforms the previous coordinates to the specified coordinates to
    % show a correct and straight image
    tform = fitgeotrans(fg_indices,[0 0; 5152 0; 5152 3864; 0 3864], ...
                'projective');
            
    % wraps the image with the new transformation coordinates to match the
    % original size of the image. This rectifies the image
    im_wrap = imwarp(im_gray, tform,'OutputView', imref2d(size(im_gray)));
    figure
    image_to_save = strcat('rectified_', imageName(21:end-3), 'png');
    imshow(im_wrap);
    imwrite(im_wrap, image_to_save);

   % plot(strongpoints);
end