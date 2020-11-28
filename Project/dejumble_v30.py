#
#  An example of the back-tracking algorithm.
#
#  Essentially, teaching a computer to find a word in a dictionary matching
#  a given string of characters.
#
#  This demonstrates the simple algorithm of backtracking using
#  a one dimensional example -- matching letters from the Word Jumble
#  to letters in the dictionary.
#
#  Constraints of the game:
#  1.  The word cannot be a proper noun.
#  2.  The Word Jumble requires that the word be in the dictionary of common words.
#  3.  The letters cannot form two different words.
#
#  The goal is not to be efficient, the goal is to teach students what happens
#  to the stack during the back-tracking operation.
#
#  Thomas Kinsman
#  Sun Aug 16 23:19:57 EDT 2020
#
__author__ = "Thomas B. Kinsman, Mon Aug 17 19:58:22 EDT 2020"

import sys 				# For passing in parameters from command line.
import os			        # Operating System, for directory listing.
import csv 				# CSV file reader.  Used to read in a list of words


# GLOBAL VARIABLES:
all_english_words = []			# The dictionary of possible words to match
call_depth        = 0			# Call depth for the algorithm

#
#  Load the dictionary into the global variable 'all_english_words'
#
def load_english_dictionary() :
    global all_english_words
    # Open The DICTIONARY File:
    all_english_words = []
    with open( "C:/Users/nikhi/OneDrive/RIT/7th Semester/Computer Vision/Computer Vision/Computer-Vision/Project/words_2171_sorted.txt", mode='r') as file:
        csvFile = csv.reader( file )
        for lines in csvFile :
            all_english_words.append( lines[0] )

    print( 'The dictionary contains ', len(all_english_words), ' words' );

#
#  IS there ANY word in the dictionary that 
#  starts with the given characters:
#
#  Returns : The word, if there is one.
#            An empty string if there is no word.
#
#
#  def Check for a word that starts with the search_chars.
#      If there is such a word, then
#         return the first word found.
#      else
#         return an empty string
#
def check_for_word_starting_with( starting_chars ) :
    global all_english_words

    the_len = len(starting_chars)
    rc = ''  # No match by default.

    # Set the string to match against:
    othr_str   = starting_chars

    # Try all possible words in the dictionary:
    for word in all_english_words :
        # Get the first N chars from each word, in turn: 
        sub_str_from_dict    = word[0:the_len]

        if ( sub_str_from_dict == othr_str ) :
           # Found the word.  Return it.
           rc = word
           break		# Time to return...

    return rc;



#def search_using_backtracking( search_chars, other_chars ) :
#
#   Essence:
#
#   Check for a word that starts with the search_chars.
#       If there is such a word, then
#           return the word found.
#       else
#           return an empty string
#
def search_using_backtracking( first_chars, other_chars ) :
    global all_english_words
    global call_depth

    first_len       = len(first_chars)
    other_len 	    = len(other_chars)

    #
    #   Debugging showing the call depth:
    #
    for idx in range(0,call_depth) :
        print('| ', end='')			# INDENTATION
    print('[' +str(call_depth) + '] search_using_backtracking( ' + first_chars + ' , ' + other_chars + ' )', end='' )

    if ( len(first_chars) > 0 ) :		# If string not empty.
        #           Check if there are ANY word that starts with these letters:
        poss_word   = check_for_word_starting_with( first_chars )
        poss_len    = len(poss_word)
        #
        #           Check for total failure:
        #           1.  There is NO word starting with these letters.
        if ( poss_len == 0 ) :
            print( '  NO.     backtrack to a diff choice.' );
            return ''

        #
        #           Check for meeting all termination conditions:
        #           1.  There is a word starting with these letters.
        #           2.  There are no other characters.
        if ( (poss_len == first_len) and (other_len == 0) ) :
            print( '  FOUND IT!  Done.' )
            return poss_word;

    print( '  maybe,  try other permutations' )

    # In this situation, there is at least one word that starts with the first_chars,
    # BUT there are also other characters that need to be considered.
    #
    # So, we need to figure out how to accommodate the other_chars
    #
    # These recursive calls create all the permutations:
    the_ans         = ''		                # Empty string;
    for idx in range( 0, len(other_chars) ) :
        # Try adding another character, each one in sequence
        next_try        = first_chars + other_chars[ idx : idx+ 1 ]

        # Remaining chars to check are these:
        new_misc_chars  = other_chars[0:idx] + other_chars[idx+1:]

        call_depth      = call_depth + 1
        the_ans         = search_using_backtracking( next_try, new_misc_chars )
        call_depth      = call_depth - 1

        if ( len( the_ans ) > 0 ) :
            return the_ans;
        else :
            the_ans = '';

    return the_ans;


def main( ) :
    global all_english_words

    # Set a default word to find:
    if ( len(sys.argv) > 1 ) :
        input_chars = sys.argv[1]
    else :
        input_chars = 'ijdnAab'	# Wind

    # Sets the globla variable all_english_words:
    load_english_dictionary()

    print('Jumbled Letters = ', input_chars )

    ans_word  = search_using_backtracking( '', input_chars )
    if ( len(ans_word) == len( input_chars ) ) :
        print("FOUND AN EXACT ANSWER --> " + ans_word )
    else :
        print('NO EXACT ANSWER FOUND ');

if __name__ == '__main__' :
    main()

