function project(file_name)
    %im = imread(file_name);
    im = imread('PROJ_IMAGES/SCAN0123.jpg');
    
    % 1: word list
    % 2: boxes list
    % 3: cropped puzzle image in gray
    % 4: empty boxes where the de-jumbled word shall go in.
    [word_list, box_list, im_puzzle, empty_boxes] = preprocess(im);
    dejumble_words = dejumble(word_list);
    %dejumble_words = ["gerbil"; "driver"; "digest"; "afloat"; "hungry"; "unload"];
    %Iname = insertObjectAnnotation(im_puzzle,'rectangle', box_list, dejumble_words);
    %imshow(Iname);
    
    word_limit = length(dejumble_words);
    character_index = 1;
    word_count = 1;
    letter_sequence = string(cell(0,0));
    coordinates = [];
    for empty_box_limit = 1:length(empty_boxes)
        coordinates = [coordinates; empty_boxes(empty_box_limit, [1 2]) + [0 -10]];
        word = char(dejumble_words(word_count));
        letter_sequence(end+1,1) = upper(word(character_index));
        word_count = word_count + 1;
        if word_count > word_limit
            character_index = character_index + 1;
            word_count = 1;
        end
    end
    
    de_jumbled_display = insertText(im_puzzle, coordinates, letter_sequence, ...
                        'FontSize', 36, 'TextColor', 'blue', 'BoxOpacity', 0.0);
    %set( gcf(), 'Position',  [ 155, -300, 1400, 900 ] );
    imshow(de_jumbled_display);
    title('\fontsize{20}De-Jumbled Puzzle');
    
    close all;
end
