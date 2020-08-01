#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "words.h"
#include "clock.h"

extern clock time_of_day;

     // This function reads a line of text from the keyboard, parses
     //  it, and does some limited checking.  Only the first two
     //  words are considered.
void words::get_command(void)
{
enum word wd1, wd2;

   do {
      time_of_day.inc_and_print_time();
      verb = (enum word)0;
      noun = (enum word)0;
      read_a_line(wd1, wd2);              // Get a line from the player
      if (wd1) {                          // If there is a value for wd1
         if (is_a_verb(wd1)) verb = wd1;  //   it is a verb
         if (is_a_noun(wd1)) noun = wd1;  //   or a noun.
      }

      if (wd2) {                          // If there is a value for wd2
         if (is_a_verb(wd2)) {
            if (verb == 0)
               verb = wd2;                // it is a verb
            else {
               verb = noun = (enum word)0; // Two verbs, illegal
               printf("Two verbs are illegal, ignored!\n");
            }
         }
         if (is_a_noun(wd2)) {
            if (noun == 0)
               noun = wd2;                //  It is a noun.
            else {
               verb = noun = (enum word)0;
                  printf("Two nouns are illegal, ignored!\n");
            }
         }
      }

      if ((verb == 0) && (noun != 0)) {
         verb = noun = (enum word)0;
         printf("A verb is required, ignored!\n");
      }
   } while (verb == 0);
}




     // This function reads words in ASCII form from the keyboard
     //  ignoring any words after two have been read.  The words
     //  are checked to see if they are in the dictionary as de-
     //  fined by the enumeration variable named "word".

void words::read_a_line(word &wd1, word &wd2)
{
char string1[25], string2[25], string3[25];
char last_char;

   last_char = get_an_ASCII_word(string1);    // Get first word
   if (last_char != '\n') {
      last_char = get_an_ASCII_word(string2); // Get second word
      while (last_char != '\n') {    // Ignore all trailing words
         last_char = get_an_ASCII_word(string3);
      }
   } else {
      string2[0] = 0;                         // No second word
   }

   wd1 = (enum word)find_in_dictionary(string1);
   wd2 = (enum word)find_in_dictionary(string2);

}




     // This function reads a string, after ignoring the leading
     //  blanks.  The string is terminated when any character is
     //  read that is not alphabetic.  All characters are converted
     //  to lower case for internal use to allow typing flexibility.

int words::get_an_ASCII_word(char in_string[])
{
int char_count = 0;
int char_found = FALSE;
char c;

   for (int index = 0 ; index < 80 ; index++) {
      c = tolower(getchar());
      if (c == '\n') {                  // End of line found
         in_string[char_count] = 0;
         return c;
      }
      if (isalpha(c) && char_count < 25) {
         in_string[char_count++] = c;
         char_found = TRUE;
      } else {
         if (isspace(c) && !char_found)
            ;                           // Ignore leading blanks
         else {
            in_string[char_count] = 0;  // ASCIIZ terminator
            return c;
         }
      }
   }
}




     // This function uses the dictionary pairs to convert the
     //  ASCII input strings into the internal enumeration values.
     //  This list must be maintained along with the enumerated
     //  type "word".

struct dict_pair {
   char dict_string[10];
   word found_word;
};

dict_pair pair[] = {"north"    ,north,
                    "n"        ,north,
                    "east"     ,east,
                    "e"        ,east,
                    "south"    ,south,
                    "s"        ,south,
                    "west"     ,west,
                    "w"        ,west,
                    "drop"     ,drop,
                    "get"      ,get,
                    "look"     ,look,
                    "inventory",inventory,
                    "read"     ,read,
                    "buy"      ,buy,
                    "help"     ,help,
                    "quit"     ,quit,
                    "keys"     ,keys,
                    "candy"    ,candy,
                    "ticket"   ,ticket,
                    "money"    ,money,
                    "monitor"  ,monitor,
                    "paper"    ,paper,
		    ""         ,(enum word)0 };   // List terminator

int words::find_in_dictionary(char in_string[])
{
int wd;
dict_pair *pointer = &pair[0];

   if (in_string[0] == 0) return 0; // No string to look up
   do {
      if (strcmp(in_string, pointer->dict_string) == 0)
         return pointer->found_word;
      pointer = pointer + 1;        // Next word in list
   } while (pointer->found_word);   // End of word list
   printf("I don't know what \"%s\" is.\n",in_string);
   return 0;                        // Word not found in list
}



    // Is the input word a verb?
int words::is_a_verb(enum word input_word)
{
   return ((input_word >= north) && (input_word <= quit));
}



    // Is the input word a noun?
int words::is_a_noun(enum word input_word)
{
   return ((input_word >= keys) && (input_word <= paper));
}



    // Is the input word a direction?
int words::is_a_direction(enum word input_word)
{
   return ((input_word >= north) && (input_word <= west));
}



    // Is the input word a operation?
int words::is_an_operation(enum word input_word)
{
   return ((input_word >= drop) && (input_word <= quit));
}
