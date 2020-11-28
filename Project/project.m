function project(file_name)
    im = imread(file_name);
    %im = imread('PROJ_IMAGES/SCAN0124.jpg');
    BOX_LIMIT = 60;
    
    % 1: word list
    % 2: boxes list
    % 3: cropped puzzle image in gray
    % 4: empty boxes where the de-jumbled word shall go in.
    % 5: centers of the circles
    % 6: the radii of the circles
    [word_list, box_list, im_puzzle, empty_boxes, centers, radii] = preprocess(im);
    dejumble_words = dejumble(word_list);
    %dejumble_words = ["gerbil"; "driver"; "digest"; "afloat"; "hungry"; "unload"];
    
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
    imshow(de_jumbled_display);
    hold on;
    
    % makes the circles visible
    viscircles(centers, radii, 'Color', 'b', 'LineWidth', 4);
    
    % prints our all the Squares
    for index = 1:length(empty_boxes)
        rectangle('position',empty_boxes(index, :),'edgecolor','r','linewidth',4);
    end
    
    title('\fontsize{20}De-Jumbled Puzzle');
end
