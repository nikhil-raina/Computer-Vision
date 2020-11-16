function im_final_clean = preprocess(im)
    %im = imread(im);
    im = imread('PROJ_IMAGES/SCAN0124.jpg');
    im_gray = rgb2gray(im);
    im_straight = straighten(im_gray);
    im_straight = imresize(im_straight, [3424 1696]);
    [row, column, channel] = size(im_straight);

    % 3424, 1696
    im_double = im2double( im_straight );
    im_gray_resize = imresize(im_double, [row/3 column/3]);
    im_original_resize= imresize(im_straight, [row/3 column/3]);
    % [1920 1680]
    
    
    im_binarize = imbinarize(im_gray_resize, 0.72);
    im_clean = bwareaopen(im_binarize, 5);
    %im_resize = imresize(cleaned_image, [row/3 column/3]);
    %im_resize_original = imresize(im_straight, [row/3 column/3]);
    
    for degree = 0:90:360
        im_display = imrotate(im_original_resize, degree);
        im_rotate = imrotate(im_clean, degree);
        all_text = ocr(im_rotate);
        jumble_text = locateText(all_text, 'Jumble');
        if(~isempty(jumble_text))
            break;
        end
    end
    
    Iocr = insertShape(im_display, 'FilledRectangle', jumble_text);
    figure; imshow(Iocr);
    
    scale_jumble_text = jumble_text * 3;
    
    % Checking if the coordinates are relatively correct by scaling to the
    % original size of the image
    Iocr = insertShape(im_straight, 'FilledRectangle', scale_jumble_text);
    figure; imshow(Iocr);
    
    
    % shifting a little left
    column_start = scale_jumble_text(1)-20;
    
    % shifting to the right till it contains the entire puzzle and then a
    % little more
    column_end = scale_jumble_text(3)+180;
    
    % shifting to the bottom till the start of the puzzle
    row_start = scale_jumble_text(2)+170;
    
    % shifting all the way to the bottom till the puzzle limit
    row_end = scale_jumble_text(4)+800;
    
    % creating the puzzle by cropping from the original image.
    im_puzzle = imcrop(im_double, [column_start row_start ...
                                     column_end row_end]);

    imshow(im_puzzle);
    
    % binarinzing the image
    im_bw_puzzle = imbinarize(im_puzzle, 0.55);

    % removing the small letters by coloring small gaps in them black. This
    % is to avoid them showing up in the OCR.
    im_clean_puzzle = bwareaopen(im_bw_puzzle, 60);
    
    % Remove the entire section rows with the circles and squares. That
    % way, the program would only need to identify the text and nothing but
    % the text.
    
    
    % Runs the OCR of the formatted puzzle now. 
    puzzle_text = getOcr(im_clean_puzzle, im_puzzle);
    
    
end

function word_rectangles = getWordRectangles(im)
    % gets all the 'rectangles' in the image along with their perimeters and
    % areas. These will be sued as differentiating purposes from areas of
    % other unwanted rectangles.
    rectangles = regionprops(im,'boundingbox', 'Perimeter', 'Area','Orientation', 'MajorAxisLength', 'MinorAxisLength');
    roi = [];
    for index = 1 : numel(rectangles)
        if rectangles(index).MajorAxisLength > 1.5 * rectangles(index).MinorAxisLength && rectangles(index).Area > 4500 && rectangles(index).Area < 27000
            roi = [roi ; rectangles(index)];
        end
    end
    curated_roi = [];
    x_value = roi(1).BoundingBox(1);    % this is the x value in which all word rectangles should start at
    delta = 5;  % amt of pixels the starting word rectangles can be off by
    % this finds all the actual word rectangles on the page, they should
    % all be stacked near eachother in the same column
    for index = 1 : numel(roi)
        if roi(index).BoundingBox(1) < x_value + delta && roi(index).BoundingBox(1) > x_value - delta
            curated_roi = [curated_roi ; roi(index)];
        end
    end

    word_rectangles = curated_roi;
end

function [words, boxes] = getOcr(im, im_original)
    % get the word rectangles
    roi = getWordRectangles(im); 
    % show the word rectangles found
     for index = 1 : numel(roi)
       bb = roi(index).BoundingBox;
       rectangle('position',bb,'edgecolor','g','linewidth',1);
     end
     % get the bounding boxes of the word rectangles
    boxes = vertcat(roi(:).BoundingBox);
    % initialize the words array
    words = [];
    % delta offset array to remove outlines
    delta = [5 5 -10 -10]
    % this gets the word for each word rectangle
    for index = 1:numel(boxes(:,1))
        % get the location of word rectangle and use delta to remove edges
        bbox = boxes(index, :) + delta;
        % crop image to the word rectangle
        Icropped = imcrop(im,bbox);
        % perform ocr on the cropped image
        results = ocr(Icropped,'TextLayout','Block', 'CharacterSet', 'A':'Z');
        % turn the char array to a string
        text = convertCharsToStrings(deblank(results.Text))
        % if it cant find anything put a questionmark
        if numel(text) == 0
            text = '?';
        end
        % add new words to the word array
        words = [words ; text];
    end
    % label the words found
    Iname = insertObjectAnnotation(im_original,'rectangle',boxes,words);
    imshow(Iname);
end



function straight = straighten(im_gray)
    % preproces img
    bw = imbinarize(im_gray,.7);
    % detect edges / prewitt
    BW = edge(bw,'prewitt');
    % use hough transform.
    [angle, T, ~] = hough(BW,'Theta',-90:90-1);
    % get variance at angles 
    variances = var(angle);                      
    % assume right angles
    fold = floor(90);         % assume right angles 
    % fold data
    variances = variances(1:fold) + variances(end-fold+1:end); % fold data
    [row, col] = max(variances);          % get the column w max variances
    angle = -T(col);               % convert column to degrees 
    angle = mod(45+angle,90)-45; 
    straight = imrotate(im_gray, -angle);   % return the straightened image
end
