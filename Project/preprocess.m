function [words, boxes, im_cropped_puzzle, empty_blocks, centers, radii] = preprocess(im)
    %im = imread('PROJ_IMAGES/SCAN0126.jpg');
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
        % identifies all the text from the image
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
                text_location = locateText(all_text, 'Jumble');
                
                if(~isempty(text_location))
                    [row_number, c] = size(text_location);
                    if(row_number > 1)
                        % this is specifically being done for jumble as the OCR is
                        % not able to read the actual jumble heading and instead
                        % finds the other jumbles. This can cause some level of
                        % incoherence with the algorithm. Thus the image is being
                        % reduced more for it to see the correct jumble word
                        im_smaller_rotate = imresize(im_rotate, 0.3);
                        all_text = ocr(im_smaller_rotate);
                        text_location = locateText(all_text, 'Jumble');
                        if(~isempty(text_location))
                            % scaling back the text to the original 0.75 resized
                            % version by just simply revering the previous
                            % resizing. 
                            % additional addition of numbers has been done to
                            % reduce the error of scaling from small to big.
                            text_location = (text_location + [-2 0 3 0])/0.3;
                        end
                    end
                    
                    disp('Found Jumble identifier');
                    puzzle_adjustment = [-20 0 170 800];
                    break;
                end
            end
        end
    end
    
    % adds necessary adjustment to the cooordinates of the puzzle location
    % thereby getting the entire puzzle
    text_location = text_location + puzzle_adjustment;
    
    % cropping the puzzle from the original image.
    disp('Cropping out the puzzle');
    im_puzzle = imcrop(im_display, text_location);
    
    % binarinzing the image
    im_bw_puzzle = imbinarize(im_puzzle, 0.7);

    % removing the small letters by coloring small gaps in them black. This
    % is to avoid them showing up in the OCR.
    im_clean_puzzle = bwareaopen(im_bw_puzzle, 40);
    
    disp('Finding the jumbled words');
    % Runs the OCR of the formatted puzzle now. 
    [words, boxes, empty_boxes, centers, radii] = getOcr(im_clean_puzzle, im_puzzle);
    fprintf('Found %d jumbled words\n\n', length(words));
    empty_blocks = [];
    empty_boxes = remove_extra_blocks(empty_boxes);
    
    % final sorting to ensure that the letters are arraganged correctly for
    % each set of the jumble words
    for fix_sorting = 1:6:35
        temp = empty_boxes(fix_sorting:fix_sorting+5, :);
        temp = sortrows(temp, 1);
        empty_blocks = [empty_blocks; temp];
    end
    
    im_cropped_puzzle = im_puzzle;
    
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
    delta = 7;  % amt of pixels the starting word rectangles can be off by
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


% method to remove any extra block found form the image
function new_empty_blocks = remove_extra_blocks(empty_blocks)
    % maximum deviation of a box from its group
    delta = 4;
    col_value = empty_blocks(1,3);
    new_empty_blocks = [];
    for index = 1 : length(empty_blocks)
        if col_value - delta <= empty_blocks(index,3) && empty_blocks(index, 3) <= col_value + delta 
            new_empty_blocks = [new_empty_blocks; empty_blocks(index,:)];
        end
    end
end


function [centers, radii] = get_cirlces(im_one)
    SE_circle = strel('disk', 2, 4);
    % binarises the image to make the cicles clear
    bw = imbinarize(im_one,.6);
    % darkens the circles making it easier for the software to identify
    % them
    bright_circle = imerode(bw, SE_circle);
    % picks out the most bright circles of all, which are the correct
    % circles needed.
    lines = bright_circle < 1;
    % specifies the area under which the required circles should exist
    [centers, radii] = imfindcircles( lines, [20 30], 'ObjectPolarity', 'dark');    
end


function [words, boxes, empty_boxes, centers, radii] = getOcr(im, im_one)
    SE_diamond = strel('diamond', 1);
    % get the word rectangles
    [roi, empty_boxes] = getWordRectangles(im);
    [centers, radii] = get_cirlces(im_one);
    % show the word rectangles found
     for index = 1 : numel(roi)
       bb = roi(index).BoundingBox;
       rectangle('position',bb,'edgecolor','g','linewidth',2);
     end
     % get the bounding boxes of the word rectangles
    boxes = vertcat(roi(:).BoundingBox);
    
    % arranges the word boxes from top to bottom according to the puzzle 
    boxes = sortrows(boxes, 2);
    empty_boxes = vertcat(empty_boxes(:).BoundingBox);
    
    % arramges the jumble empty boxes so that the text can easily be able
    % to arrange itself while printing it out.
    empty_boxes = sortrows(empty_boxes, 2);
    % initialize the words array
    words = [];
    % delta offset array to remove outlines
    delta = [5 5 -10 -10];
    % this gets the word for each word rectangle
    for index = 1:numel(boxes(:,1))
        % get the location of word rectangle and use delta to remove edges
        bbox = boxes(index, :) + delta;
        % crop image to the word rectangle
        Icropped = imcrop(im_one, bbox);
        % binarizing the cropped image
        Icropped_bw = imbinarize(Icropped, 0.6);
        % darkens the text
        Icropped_darken = imerode(Icropped_bw, SE_diamond);
        % perform ocr on the cropped image
        results = ocr(Icropped_darken,'TextLayout','Block', 'CharacterSet', 'A':'Z');
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
