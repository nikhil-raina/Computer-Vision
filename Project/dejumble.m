% backtracking method that dejumbles the words in the word_list and sends
% it back to the caller method.
function dejumbled_word_list = dejumble(word_list)
    global dictionary;
    disp('Dejumbling words:');
    %word_list = ["yabb"; "ijdnAab"];
    dictionary = create_dictionary();
    
    % initialises space for the string array that will contain the
    % dejumbled words.
    dejumbled_word_list = string(cell(0,0));
    [row, column] = size(word_list);
    for jumble_word_index = 1:row
        fprintf('\tDejumbling %s...\n', word_list(jumble_word_index));
        result = dejumbled_result('',lower(word_list(jumble_word_index)));
        if(isempty(result))
            fprintf('\t\tFAIL\n');
        else
            fprintf('\t\tSUCCESS\n');
        end
        dejumbled_word_list(end+1,1) = result;
    end
end

% creates a case sensitive dictionary of all the words stored in
% words_2171_sorted.txt
function dictionary = create_dictionary()
    file = fopen('words_2171_sorted.txt');
    
    % scans all the words within file with a string format
    dictionary = textscan(file, '%s');
    
    % converts the cell array to a string array
    dictionary = string(dictionary{:});
    
    % closes the file for good practice
    fclose(file);
end


function dejumbled_word = dejumbled_result(first_char, jumbled_word)
    % finds the length of the entered strings
    first_len = strlength(first_char);
    other_len = strlength(jumbled_word);
    if(first_len > 0)
        % tries to get a possible word from the dictionary
        poss_word = check_for_word_staring_with(first_char);
        poss_len = strlength(poss_word);
        
        % returns if there was no word that was found and tries a new
        % permutation
        if(poss_len == 0)
            dejumbled_word = '';
            return;
        end
        
        % returns the word if its size mathches correctly and that there
        % are no other characters left.
        if(poss_len == first_len && other_len == 0)
            dejumbled_word = poss_word;
            return;
        end
    end
    
    dejumbled_word = '';
    for index = 1:other_len
        other_str = char(jumbled_word);
        
        % tries new starting permutations of the string
        next_try = strcat(first_char, other_str(index));
        
        % gets all the characters within this string excluding the current
        % character of the index being used.
        new_misc_chars = strcat(other_str(1:index-1), other_str(index+1:end));
        
        % makes a recursive call to the dejumbled_result with the new
        % permutations 
        dejumbled_word = dejumbled_result(next_try, new_misc_chars);
        
        % checks if the word is found and returns that word
        if(~isempty(dejumbled_word))
            return
        else
            dejumbled_word = '';
        end
        
    end
end


function default_return = check_for_word_staring_with(first_char)
    global dictionary;
    default_return = '';
    the_len = strlength(first_char);
    
    for word_index = 1:length(dictionary)
        % gets the word from the dictionary
        word = char(dictionary(word_index));
        if(the_len <= length(word))
            
            % checks if the pattern strings exists in the starting of the 
            % word
            if(startsWith(word, first_char))
                default_return = word;
                break;
            end
        end
    end
end
