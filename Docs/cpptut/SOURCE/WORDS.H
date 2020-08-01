// This class reads and parses the user input, checks that a valid
//  verb has been input, and checks for a valid noun.

#ifndef WORDS_H
#define WORDS_H

#include "flyaway.h"

class words {

   enum word verb;
   enum word noun;
   void read_a_line(word &wd1, word &wd2);
   int get_an_ASCII_word(char in_string[]);
   int find_in_dictionary(char in_string[]);
   int is_a_verb(enum word input_word);
   int is_a_noun(enum word input_word);
   int is_a_direction(enum word input_word);
   int is_an_operation(enum word input_word);

public:

   void get_command(void);
   enum word get_verb(void)  { return verb; };
   enum word get_noun(void)  { return noun; };
   int is_a_verb(void)       { return is_a_verb(verb); };
   int is_a_noun(void)       { return is_a_noun(noun); };
   int is_a_direction(void)  { return is_a_direction(verb); };
   int is_an_operation(void) { return is_an_operation(verb); };
   void stop_game(void)      { verb = quit; };

};

#endif
