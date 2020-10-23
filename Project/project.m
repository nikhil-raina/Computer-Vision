function project(file_name)
    %im = imread(file_name);
    im = imread('PROJ_IMAGES/SCAN0124.jpg');
    im = orientimage(im);
    imshow(im);
    ocr = getOcr(im);
    im_gray = rgb2gray(im);
    SE_circle = strel('disk', 2, 4);

    %filter to smooth the image
    fltr = fspecial('gauss', [15 15], 1.4);
    im = imfilter(im_gray, fltr, 'same', 'repl');
    imshow(im)
    pause(2)

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
    
    % gets all the 'rectangles' in the image along with their perimeters and
    % areas. These will be sued as differentiating purposes from areas of
    % other unwanted rectangles.
    rectangles = regionprops(cleaned_image,'boundingbox', 'Perimeter', 'Area','Orientation', 'MajorAxisLength', 'MinorAxisLength');
    
    % prints the outlines of the rectangles on the image
    for index = 1 : numel(rectangles)
        if rectangles(index).MajorAxisLength > 1.5 * rectangles(index).MinorAxisLength && rectangles(index).Area > 4500 && rectangles(index).Area < 27000
            bb = rectangles(index).BoundingBox;
            rectangle('position',bb,'edgecolor','g','linewidth',1);
        end
    end
    
    
end

% function to orient and crop the image properly
% works only somethimes, maybe will include ocr to flip if it cant detect
% words
function oriented_im = orientimage(im)
    roi = getWordRectangles(im);
    angle = roi.Orientation;
    oriented_im = imrotate(im, -angle);
    roi = getWordRectangles(oriented_im);
    oriented_im = cropImage(oriented_im, roi);
end 

% finds and returns the word_rectangles in an image
% TODO create squares and circles separate method and look for them as a
% cohesive unit
% only wordrectangles with blueboxes underneath are valid etc
% maybe even update crop function
function word_rectangles = getWordRectangles(im)
    im_gray = rgb2gray(im2double( im ));

    %filter to smooth the image
    fltr = fspecial('gauss', [15 15], 1.4);
    im = imfilter(im_gray, fltr, 'same', 'repl');
    %figure;
    %imshow(im)
    %pause(2)

    % binarizing the image by making the threshold at 0.6
    % this means that all the double values of the cells that are below 0.6
    % will be 0 or blacks and the noes above it will be 1 or white.
    bw = imbinarize(im,.6);

    % Removes all the white blob areas that are less than 1000. This is to
    % clear the image more so that only the Jumble Puzzle is visible. This
    % way, some random structures dont become shapes, when thats not
    % required
    cleaned_image = bwareaopen(bw, 1000);

    % gets all the 'rectangles' in the image along with their perimeters and
    % areas. These will be sued as differentiating purposes from areas of
    % other unwanted rectangles.
    rectangles = regionprops(cleaned_image,'boundingbox', 'Perimeter', 'Area','Orientation', 'MajorAxisLength', 'MinorAxisLength');
    roi = [];
    for index = 1 : numel(rectangles)
        if rectangles(index).MajorAxisLength > 1.5 * rectangles(index).MinorAxisLength && rectangles(index).Area > 4500 && rectangles(index).Area < 27000
            roi = [roi ; rectangles(index)];
        end
    end
    %imshow(bw)
    % set minimum and maximum x' and y's to inital value
    minx = roi(1).BoundingBox(1);
    miny = roi(1).BoundingBox(2);
    maxx = roi(1).BoundingBox(1);
    maxy = roi(1).BoundingBox(2);
    %hold on;
    % draw boxes while finding the minimum and maximum of x's and y's
    for index = 1 : numel(roi)
       bb = roi(index).BoundingBox;
       if bb(1) < minx
           minx = bb(1);
       elseif bb(1)+bb(3) > maxx
           maxx = bb(1)+bb(3);
       end
       if bb(2) < miny
           miny = bb(2);
       elseif bb(2)+bb(4) > maxy
           maxy = bb(2)+bb(4);
       end
       %rectangle('position',bb,'edgecolor','g','linewidth',1);
    end
    word_rectangles = roi;
end

function cropped_image = cropImage(im, roi)
% set minimum and maximum x' and y's to inital value
    minx = roi(1).BoundingBox(1);
    miny = roi(1).BoundingBox(2);
    maxx = roi(1).BoundingBox(1);
    maxy = roi(1).BoundingBox(2);
    hold on;
    % draw boxes while finding the minimum and maximum of x's and y's
    for index = 1 : numel(roi)
       bb = roi(index).BoundingBox;
       if bb(1) < minx
           minx = bb(1);
       elseif bb(1)+bb(3) > maxx
           maxx = bb(1)+bb(3);
       end
       if bb(2) < miny
           miny = bb(2);
       elseif bb(2)+bb(4) > maxy
           maxy = bb(2)+bb(4);
       end
    end
    % crop image to just the area of interest
    cropped_image = imcrop(im, [minx-100 miny-100 maxx-minx+400 maxy-miny+400]);
end 

% pre processes the image
function preprocess_im = preprocess(im)
    im_gray = rgb2gray(im2double( im ));

    %filter to smooth the image
    fltr = fspecial('gauss', [15 15], 1.4);
    im = imfilter(im_gray, fltr, 'same', 'repl');
    figure;
    imshow(im)
    pause(2)

    % binarizing the image by making the threshold at 0.6
    % this means that all the double values of the cells that are below 0.6
    % will be 0 or blacks and the noes above it will be 1 or white.
    bw = imbinarize(im,.6);

    % Removes all the white blob areas that are less than 1000. This is to
    % clear the image more so that only the Jumble Puzzle is visible. This
    % way, some random structures dont become shapes, when thats not
    % required
    %cleaned_image = bwareaopen(bw, 1000);
    marker = imerode(im, strel('line',10,0));
    clean = imreconstruct(marker, im);

    bw2 = imbinarize(clean);
    preprocess_im = bw;
end
% doesnt work correctly, but finds some text
function ocrResults = getOcr(im)
    % prerocess the image
    bw = preprocess(im);
    imshow(bw);
    hold on;
    % get the word rectangles
    roi = getWordRectangles(im);    
     for index = 1 : numel(roi)
       bb = roi(index).BoundingBox;
       rectangle('position',bb,'edgecolor','g','linewidth',1);
     end
     % get the boudning boxes
    boxes = vertcat(roi(:).BoundingBox);
    
    % perform ocr on the preprocessed image using the found bounding boxes
    results = ocr(bw, boxes, 'TextLayout', 'Word', 'CharacterSet', 'A':'Z');
    figure;
    % remove whitespace in the results
    c = cell(1,numel(results));
    for i = 1:numel(results)
        c{i} = deblank(results(i).Text);
    end
    ocrResults = c;
    % display results on the iamge
    Iname = insertObjectAnnotation(im,'rectangle',boxes,c);
    imshow(Iname);
end

% returns false if any of the arrays in the array are empty
function anyEmpty = anyEmpty(arr)
    for index = 1 : numel(arr) 
        if size(arr(index)) == 0
            anyEmpty = true;
            return
        end
    end
    anyEmpty = false;
end