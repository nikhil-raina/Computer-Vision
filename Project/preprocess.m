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
    puzzle_text = ocr(im_clean_puzzle);
    
    
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
    straight = imrotate(im_gray, -angle);
    %imshow(straight)
    %pause(10);
%     lttrs = [ 'l', 't', 'T', 'L'];
%     location = locateText(ocrText, 'Jumble');
%     lttr_crop = imcrop(im,[location(1), location(2), location(3), location(4)]);
%     crop_BW = edge(lttr_crop,'canny');
%     imshow(crop_BW);
%     for index = 1:1:numel(lttrs)
%         disp(lttrs(index));
%         location = locateText(ocrText, 'l');
%         if(~isempty(location))
%             lttr_crop = imcrop(im,[location(1), location(2), location(3), location(4)]);
%             crop_BW = edge(lttr_crop,'canny');
%             imshow(crop_BW);
%         end
%         pause(10);
%     end
%     straight = im;
end
