function [words, boxes, im_cropped_puzzle, empty_boxes] = preprocess(im)
    %im = imread('PROJ_IMAGES/SCAN0123.jpg');
    im_gray = rgb2gray(im);
    disp('Straightening the image');
    im_straight = straighten(im_gray);
    im_straight_resize = imresize(im_straight, 0.75);
    im_double = im2double(im_straight_resize);
    
    im_clean = imbinarize(im_double, 0.7);
    
    % default puzzle adjustment segmentation depending on which text gets
    % located.
    puzzle_adjustment = [];
    
    for degree = 0:90:360
        im_display = imrotate(im_straight_resize, degree);
        im_rotate = imrotate(im_clean, degree);
        all_text = ocr(im_rotate);
        text_location = locateText(all_text, 'SCRAMBLED');
        if(~isempty(text_location))
            disp('Found Scrambled identifier');
            puzzle_adjustment = [-500 0 300 800];
            break;
        else 
            
            text_location = locateText(all_text, 'GAME');
            if(~isempty(text_location))
                disp('Found Game identifier');
                puzzle_adjustment = [-700 0 +350 +800];
                break;
            else 
                % this is specifically being done for jumble as the OCR is
                % not able to read the actual jumble heading and instead
                % finds the other jumbles. This can cause some level of
                % incoherence with the algorithm. Thus the image is being
                % reduced more for it to see the correct jumble word
                im_smaller_rotate = imresize(im_rotate, 0.3);
                all_text = ocr(im_smaller_rotate);
                text_location = locateText(all_text, 'Jumble');
                if(~isempty(text_location))
                    [row_number, c] = size(text_location);
                    if(row_number > 1)
                        text_location = greatest_jumble(text_location); 
                    end
                    
                    % scaling back the text to the original 0.75 resized
                    % version by just simply revering the previous
                    % resizing. 
                    % additional addition of numbers has been done to
                    % reduce the error of scaling from small to big.
                    text_location = (text_location + [-2 0 3 0])/0.3;
                    disp('Found Jumble identifier');
                    puzzle_adjustment = [-20 0 170 800];
                    break;
                end
            end
        end
    end
    
    %Iocr = insertShape(im_display, 'FilledRectangle', text_location);
    %figure; imshow(Iocr);
    
    text_location = text_location + puzzle_adjustment;
    
    % cropping the puzzle from the original image.
    disp('Cropping out the puzzle');
    im_puzzle = imcrop(im_display, text_location);

    %imshow(im_puzzle);
    
    % binarinzing the image
    im_bw_puzzle = imbinarize(im_puzzle, 0.7);

    % removing the small letters by coloring small gaps in them black. This
    % is to avoid them showing up in the OCR.
    im_clean_puzzle = bwareaopen(im_bw_puzzle, 40);
    
    disp('Finding the jumbled words');
    % Runs the OCR of the formatted puzzle now. 
    [words, boxes, empty_boxes] = getOcr(im_clean_puzzle);
    im_cropped_puzzle = im_puzzle;
    
end


function max_text = greatest_jumble(text_location)
    % takes the first row and assumes that it is the biggest one of all
    max_text = [];
    
    % returns the biggest jumble word available. Ideally, it should return
    % the heading Jumble.
    [row, column] = size(text_location);
    for jumble_word_row = 1:row
        if(isempty(max_text))
            max_text = text_location(jumble_word_row,:);
        elseif max_text(3) < text_location(jumble_word_row,3)
            max_text = text_location(jumble_word_row,:);
        end
    end
end


function [word_rectangles, empty_blocks] = getWordRectangles(im)
    % gets all the 'rectangles' in the image along with their perimeters and
    % areas. These will be used as differentiating purposes from areas of
    % other unwanted rectangles.
    rectangles = regionprops(im,'boundingbox', 'Perimeter', 'Area','Orientation', 'MajorAxisLength', 'MinorAxisLength');
    roi = [];
    small_roi = [];
    for index = 1 : numel(rectangles)
        % gets the small squares where the de-jumbled word will go into
        if rectangles(index).Area > 1680 && rectangles(index).Area < 2650
            small_roi = [small_roi; rectangles(index)];
            %rectangle('position',rectangles(index).BoundingBox,'edgecolor','g','linewidth',2);
        % gets the rectangle boxes that contain the jumbled words
        elseif rectangles(index).MajorAxisLength > 1.5 * rectangles(index).MinorAxisLength && rectangles(index).Area > 4500 && rectangles(index).Area < 27000
            roi = [roi ; rectangles(index)];
            %rectangle('position',rectangles(index).BoundingBox,'edgecolor','b','linewidth',2);
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
    empty_blocks = small_roi;
end


function [words, boxes, empty_boxes] = getOcr(im)
    % get the word rectangles
    [roi, empty_boxes] = getWordRectangles(im); 
    % show the word rectangles found
     for index = 1 : numel(roi)
       bb = roi(index).BoundingBox;
       rectangle('position',bb,'edgecolor','g','linewidth',2);
     end
     % get the bounding boxes of the word rectangles
    boxes = vertcat(roi(:).BoundingBox);
    empty_boxes = vertcat(empty_boxes(:).BoundingBox);
    % initialize the words array
    words = [];
    % delta offset array to remove outlines
    delta = [5 5 -10 -10];
    % this gets the word for each word rectangle
    for index = 1:numel(boxes(:,1))
        % get the location of word rectangle and use delta to remove edges
        bbox = boxes(index, :) + delta;
        % crop image to the word rectangle
        Icropped = imcrop(im,bbox);
        % perform ocr on the cropped image
        results = ocr(Icropped,'TextLayout','Block', 'CharacterSet', 'A':'Z');
        % turn the char array to a string
        text = convertCharsToStrings(deblank(results.Text));
        % removes spaces if there are any
        text = regexprep(text, '\s+', '');
        % if it cant find anything put a questionmark
        if numel(text) == 0
            text = '?';
        end
        % add new words to the word array
        words = [words ; text];
    end
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
