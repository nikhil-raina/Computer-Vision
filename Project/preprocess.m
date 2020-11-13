function im_final_clean = preprocess(im)
    %im = imread(im);
    im = imread('PROJ_IMAGES/SCAN0125.jpg');
    [row, column, channel] = size(im);
    flag_more_jumble_words = 0;
    % resizez the image to allow the cleaning and character recognition to
    % take place smoothly. This further improves the computation speed
    im_resize = imresize(im, [row/3 column/3]);
    im_gray = rgb2gray(im_resize);
    im_gray_double = rgb2gray(im2double(im_resize));
    
    
    jumble_word_list = [0 0 0 0 0];
    % Loop that constantly rotates the image till it finds the word jumble
    % and returns it back to the caller.
    for degree = 0:15:360
        %break;
        % Cleans the image to ensure that the word JUMBLE is easily read
        im_clean = clear_for_jumble(im_gray_double);
        
        % constantly goes about rotating the image till the image is
        % roughly upright. This will later be used to identify the circles
        % and squares
        im_rotate_clean = imrotate(im_clean, degree);
        
        % Matches the rotation of the clean image to insert the image in
        % the InsertShape Method.
        im_rotate_gray = imrotate(im_gray, degree);
        
        % Grabs all the recognizable characters from the cleaned iamge
        ocrText = ocr(im_rotate_clean);
        
        % shows the current image position
        %imshow(im_rotate_clean);
        %imshow(im_rotate_gray);
        
        % Locates the jumble words and returns the coordinates of it
        % with the height and width of the word.
        % [x y height width]
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
            figure; imshow(Iocr); figure;
            
            % stores the degree value along with the located texts in order
            % to be able to create a new image to crop out the required
            % jumble puzzle
            jumble_words(5) = degree;
            
            % stores the captured jumble word details and the degree in the
            % list
            jumble_words = jumble_words(1,:);
            jumble_word_list = cat(1, jumble_word_list, jumble_words);
            
            % somehow, I could try to reduce the time for this.
            
            % temporary size of the jumble word list
            temp_size = size(jumble_word_list);
            % assuming that there are 3 mathces a minimum, 
            if(temp_size(1) >= 4)
                flag_more_jumble_words = 1;
                jumble_words = jumble_word_list(3,:);
                
                % calls the crop image on the new cleaned image and the
                % jumble word that was chosen. The assumption here is that
                % the word chosen is the upright one for the image.
                im_small_coordinates = get_coordinates(im_rotate_gray, jumble_words);
                break;
            end
        end
        %pause(2);
    end
    
    if(~flag_more_jumble_words)
        if(size(jumble_word_list) >= 2)
            jumble_words = jumble_word_list(2,:);
            im_rotate_gray = imrotate(im_gray, jumble_words(5));
            im_small_coordinates = get_coordinates(im_rotate_gray, jumble_words);
        else
            disp('There is no Jumble Puzzle');
        end
    end
    
    % resizing to the original points in the image
    im_coordinates = (im_small_coordinates * 3);
    % rotating the original image to match the orientation of the small
    % cropped image
    im_rotate_original = imrotate(im, jumble_words(5)+2);
    
    im_rotate_original = straighten(im);
    % cropping the jumble puzzle from the image
    im_crop_small = imcrop(im_rotate_gray, im_small_coordinates);
    im_crop_original = rgb2gray(imcrop(im_rotate_original, im_coordinates));
    
    imshow(im_crop_small);
    figure();
    imshow(im_crop_original);
    im_final_clean = clear_for_jumble(im_crop_original);
    figure();
    imshow(im_final_clean);
    
    textStuff = ocr(im_final_clean);
    %text(600, 150, textStuff.Text, [1 1 1]);
    
    %close all;
    
end

function cleaned_image = clear_for_jumble(im_gray)
    
    % binarises the image to remove any additional noise
    bw = imbinarize(im_gray, .7);
    
    % removes the small gaps of white spaces to remove the redundant words
    % away and additional jumble words.
    cleaned_image = bwareaopen(bw, 5);
end

function coordinates = get_coordinates(im, jumble_word)
    top_left_x = jumble_word(1);
    top_left_y = jumble_word(2);
    length = jumble_word(3);
    width = jumble_word(4);
    
    % this is not working correctly yet. Still requires some work into it with
    % the math of the coordinates.
    coordinates = [top_left_x-(width*2) top_left_y+round(width*2.7) length+round(width*3.5) round(length*3.1)];
end

function straight = straighten(im)
    % preproces img
    im_gray = rgb2gray(im2double( im ));
    bw = imbinarize(im_gray,.6);
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
    straight = imrotate(im, -angle);
    imshow(straight)
    pause(20);
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
function add_pepper(im)

end

function im_resized = resize_fltr_im(im_crop)
    fltr = fspecial('gauss', [15 15], 0.8);
    im_resized = imfilter(im_crop, fltr, 'same', 'repl');
    
end