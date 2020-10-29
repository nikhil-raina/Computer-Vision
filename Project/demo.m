function demo
    im = imread('PROJ_IMAGES/SCAN0109.jpg');
    im_sizes = size(im);
    im = imresize(im, [im_sizes(1)/3 im_sizes(2)/3]);
    im_double = im2double(im);
    im_gray = rgb2gray(im_double);
    
    % Loop that constantly rotates the image till it finds the word jumble
    % and returns it back to the caller.
    for degree = 0:10:360
        % Cleans the image to ensure that the word JUMBLE is easily read
        clean_im = clear_for_jumble(im_gray);
        
        % constantly goes about rotating the image till the image is
        % roughly upright. This will later be used to identify the circles
        % and squares
        im_rotate_clean = imrotate(clean_im, degree);
        
        % Matches the rotation of the clean image to insert the image in
        % the InsertShape Method.
        im_rotate_gray = imrotate(rgb2gray(im), degree);
        
        % Grabs all the recognizable characters from the cleaned iamge
        ocrText = ocr(im_rotate_clean);
        imshow(im_rotate_clean);
        %imshow(im_rotate_gray);
        
        % Locates the jumble words and returns the vector positions of it
        % with the height and width of the word.
        % [x_vector y_vector height width]
        jumble_words = locateText(ocrText, 'Jumble');
        
        disp(degree);
        
        % checks if the jumble_words is empty. If it is, then it rotates
        % the image and tries the previous steps again otherwise it gets
        % displays the positions of the words correctly
        if(~isempty(jumble_words))
            disp('fly');
            
            % inserts a yellow rectangle on the found jumble word
            Iocr = insertShape(im_rotate_gray, 'FilledRectangle', jumble_words);
            % shows the figure with the highlighted jumble word
            figure; imshow(Iocr);
            break;
        end
        %pause(2);
    end
end

function cleaned_image = clear_for_jumble(im_gray)
    
    % binarises the image to remove any additional noise
    bw = imbinarize(im_gray, .7);
    
    % removes the small gaps of white spaces to remove the redundant words
    % away and additional jumble words.
    cleaned_image = bwareaopen(bw, 5);
end

