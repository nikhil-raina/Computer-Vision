function dejumbled_word_list = dejumble(word_list)
    global dictionary;
    word_list = ["yabb"; "ijdnaab"];
    dictionary = create_dictionary();
    dejumbled_word_list = [];
    [row, column] = size(word_list);
    for jumble_word_index = 1:row
        dejumbled_word_list(jumble_word_index) = dejumbled_result('',word_list(jumble_word_index));
    end
end

function dictionary = create_dictionary()
    file = fopen('words_2171_sorted.txt');
    dictionary = textscan(file, '%s');
    dictionary = string(dictionary{:});
    fclose(file);
end


function dejumbled_word = dejumbled_result(first_char, jumbled_word)
    first_len = strlength(first_char);
    other_len = strlength(jumbled_word);
    if(first_len > 0)
        poss_word = check_for_word_staring_with(first_char);
        poss_len = strlength(poss_word);
        
        if(poss_len == 0)
            dejumbled_word = "";
            return;
        end
        
        if(poss_len == first_len && other_len == 0)
            dejumbled_word = poss_word;
            return;
        end
    end
    
    dejumbled_word = "";
    for index = 1:other_len
        other_str = char(jumbled_word);
        next_try = strcat(first_char, other_str(index:index+1));
        
        new_misc_chars = strcat(other_str(1:index), other_str(index+1:end));
        
        dejumbled_word = dejumbled_result(next_try, new_misc_chars);
        if(~isempty(dejumbled_word))
            return
        else
            dejumbled_word = "";
        end
        
    end
end


function default_return = check_for_word_staring_with(first_char)
    global dictionary;
    default_return = "";
    the_len = strlength(first_char);
    
    for word_index = 1:length(dictionary)
        word = char(dictionary(word_index));
        if(the_len <= length(word))
            sub_str_from_dict = word(1:the_len);
            if(startsWith(word, first_char))
                default_return = sub_str_from_dict;
                break;
            end
        end
    end
end
