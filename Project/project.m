function project(file_name)
    im = imread(file_name);
    %im = imread('PROJ_IMAGES/SCAN0125.jpg');
    BOX_LIMIT = 60;
    
    % 1: word list
    % 2: boxes list
    % 3: cropped puzzle image in gray
    % 4: empty boxes where the de-jumbled word shall go in.
    [word_list, box_list, im_puzzle, empty_boxes] = preprocess(im);
    dejumble_words = dejumble(word_list);
    %dejumble_words = ["gerbil"; "??????"; "digest"; "afloat"; "hungry"; "unload"];
    %Iname = insertObjectAnnotation(im_puzzle,'rectangle', box_list, dejumble_words);
    %imshow(Iname);
    
    letter_sequence = string(cell(0,0));
    coordinates = [];
    
    % concats all the x and y coordinates to display the text
    for empty_box_limit = 1:length(empty_boxes)
        coordinates = [coordinates; empty_boxes(empty_box_limit, [1 2]) + [0 -10]];
    end
    
    % add all the characters in a list to be displayed
    for dejumble_index = 1:length(dejumble_words)
        dejumble_word = char(dejumble_words(dejumble_index));
        for character_count = 1: length(char(dejumble_words(dejumble_index)))
            letter_sequence(end+1, 1) = upper(dejumble_word(character_count));
        end
    end
    
    de_jumbled_display = insertText(im_puzzle, coordinates, letter_sequence, ...
                        'FontSize', 36, 'TextColor', 'blue', 'BoxOpacity', 0.0);
    %set( gcf(), 'Position',  [ 155, -300, 1400, 900 ] );
    imshow(de_jumbled_display);
    title('\fontsize{20}De-Jumbled Puzzle');
end
