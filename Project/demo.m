function demo()
    im = imread('PROJ_IMAGES/SCAN0125.jpg');
    im_sizes = size(im);
    %im = imresize(im, [939 827]);
    
    % resizez the image to allow the cleaning and character recognition to
    % take place smoothly. This further improves the computation speed
    im_resize = imresize(im, [im_sizes(1)/3 im_sizes(2)/3]);
    im_double = im2double(im_resize);
    im_gray = rgb2gray(im_double);
    
    
    jumble_word_list = [0 0 0 0 0];
    % Loop that constantly rotates the image till it finds the word jumble
    % and returns it back to the caller.
    for degree = 0:2:360
        %break;
        % Cleans the image to ensure that the word JUMBLE is easily read
        clean_im = clear_for_jumble(im_gray);
        
        % constantly goes about rotating the image till the image is
        % roughly upright. This will later be used to identify the circles
        % and squares
        im_rotate_clean = imrotate(clean_im, degree);
        
        % Matches the rotation of the clean image to insert the image in
        % the InsertShape Method.
        im_rotate_gray = imrotate(rgb2gray(im_resize), degree);
        
        % Grabs all the recognizable characters from the cleaned iamge
        ocrText = ocr(im_rotate_clean);
        
        % shows the current image position
        %imshow(im_rotate_clean);
        %imshow(im_rotate_gray);
        
        % Locates the jumble words and returns the vector positions of it
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
            %figure; imshow(Iocr);
            
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
                jumble_words = jumble_word_list(3,:);
                
                % calls the crop image on the new cleaned image and the
                % jumble word that was chosen. The assumption here is that
                % the word chosen is the upright one for the image.
                im_cropped = crop_image(im_rotate_gray, jumble_words);
                coordinates = get_coordinates_to_scale(jumble_words);
                break;
            end

        end
        %pause(2);
    end
    % scaling up the coordinates for the original image
    imshow(im_cropped);
    coordinates = coordinates * 3;
    im_rotate_original = imrotate(im, jumble_words(5));
    cropped_image = im_rotate_original(coordinates(1):coordinates(2), ...
                                        coordinates(3):coordinates(4));
    figure()
    imshow(cropped_image);
    %figure();
    %im_cropped = resize_fltr_im(im_cropped);
    %im_cropped = clear_for_jumble(im_cropped);
    %imshow(im_cropped);
end

function cleaned_image = clear_for_jumble(im_gray)
    
    % binarises the image to remove any additional noise
    bw = imbinarize(im_gray, .7);
    
    % removes the small gaps of white spaces to remove the redundant words
    % away and additional jumble words.
    cleaned_image = bwareaopen(bw, 5);
end

function cropped_image = crop_image(im, jumble_word)
    top_left_x = jumble_word(1);
    top_left_y = jumble_word(2);
    cropped_image = im(top_left_x - 130:top_left_x + 260, top_left_y + 70:400);
end

% this is not working correctly yet. Still requires some work into it with
% the math of the coordinates.
function coordinates = get_coordinates_to_scale(jumble_word)
    top_left_x = jumble_word(1);
    top_left_y = jumble_word(2);
    coordinates = [top_left_x - 130 top_left_x + 260 top_left_y + 70 400];
end

function im_resized = resize_fltr_im(im_crop)
    crop_size = size(im_crop);
    im_crop = imresize(im_crop, [crop_size(1)*2 crop_size(2)*2]);
    fltr = fspecial('gauss', [15 15], 0.8);
    im_resized = imfilter(im_crop, fltr, 'same', 'repl');
    
end