function project(file_name)
    im = imread(file_name);
    %im = imread('PROJ_IMAGES/SCAN0129.jpg');
    im_gray = rgb2gray(im2double( im ));
    SE_circle = strel('disk', 2, 4);

    %filter to smooth the image
    fltr = fspecial('gauss', [15 15], 1.4);
    im = imfilter(im_gray, fltr, 'same', 'repl');

    % binarizing the image by making the threshold at 0.6
    % this means that all the double values of the cells that are below 0.6
    % will be 0 or blacks and the noes above it will be 1 or white.
    bw = imbinarize(im,.6);
    
    % Removes all the white blob areas that are less than 1000. This is to
    % clear the image more so that only the Jumble Puzzle is visible. This
    % way, some random structures dont become shapes, when thats not
    % required
    cleaned_image = bwareaopen(bw, 1000);
    
    %Ifinal = logical(cleaned_image);
    % gets all the 'squares' in the image along with their perimeters and
    % areas. These will be sued as differentiating purposes from areas of
    % other unwanted squares.
    squares = regionprops(cleaned_image,'boundingbox', 'Perimeter', 'Area');
       
    % increases the blackness of the image. So here we are trying to amplify
    % the edges and circles by adding more pepper and thickening the lines.
    % This will allow the software to easily find the circles.
    bright_circle = imerode(bw, SE_circle);

    % highlights all the edges in the image and makes them all white. The rest
    % are turned to black. This shows black object surrounded with thick white
    % lines. I think this would make it easier for the software to identify the
    % circles.
    lines = bright_circle < 1;
    
    % finds all the edges in the image.
    %im_ed = edge( lines );

    % finds the circles from the image.
    [centers, radii] = imfindcircles( lines, [30, 40], 'ObjectPolarity', 'dark');
    imshow(bw)
    hold on;

    % prints the outlines of the circles on the image
    viscircles(centers, radii);
    
    % prints the outlines of the squares on the image
    for index = 1 : numel(squares)
        if squares(index).Area > 2000 && squares(index).Area < 4500
            bb = squares(index).BoundingBox;
            rectangle('position',bb,'edgecolor','b','linewidth',1);
        end
    end
end