/* *************************************************************** */
/* This program reads a series of words from the command line,     */
/* and displays all but the last on the monitor. The last is a     */
/* series of characters which are used as input comparisons. One   */
/* character is read from the keyboard. If it is one of the        */
/* characters in the comparison list, its number is returned to    */
/* DOS as the errorlevel command. If the character does not exist  */
/* in the list, a zero is returned. Example follows;               */
/*                                                                 */
/* WHATNEXT What model do you want? ALR%3T                         */
/*                                                                 */
/* What model do you want?      <---- displayed on monitor         */
/*    If key a or A is hit, errorlevel 1 is returned.              */
/*    If key l or L is hit, errorlevel 2 is returned.              */
/*    If key r or R is hit, errorlevel 3 is returned.              */
/*    If key % is hit, errorlevel 4 is returned.                   */
/*    If key 3 is hit, errorlevel 5 is returned.                   */
/*    If key t or T is hit, errorlevel 6 is returned.              */
/*    If any other key is hit, errorlevel 0 is returned.           */
/*                                                                 */
/*  The question must be on one line.                              */
/*  Up to nine different keys can be used.                         */
/*  The errorlevel can be interpreted in a batchfile.              */
/* *************************************************************** */

#include "stdio.h"
#include "ctype.h"

main(number,name)
int number;               /* total number of words on command line */
char *name[];
{
int index;                  /* a counter and incrementing variable */
int c;                     /* the character read in for comparison */
int code;                  /* the resulting errorlevel returned to */
char next_char;                    /* used for the comparison loop */
char *point;               /* a dummy pointer used for convenience */

                     /* At least one group must be used for this   */
                     /* filename, and one group used for the       */
                     /* required fields, so less than three allows */
                     /* for no question.                           */
   if (number < 3) {
      printf("No question given on command line\n");
      exit(0);
   }

                         /* print out words 2 to n-1, the question */
   number--;
   for(index = 1;index < number;index++) {
      printf("%s ",name[index]);
   }
  
                   /* get the users response and make it uppercase */
   c = getch();
   printf("%c\n",c);
   if (islower(c))
      c = toupper(c);
   point = name[number];/* point to the last pointer on the inputs */

   code = 0;
   index = 0;
   do {            /* search across allowed responses in last word */
      next_char = *(point + index);
      if (islower(next_char))
         next_char = toupper(next_char);      /* make it uppercase */
      if(next_char == c)                    /* if a match is found */
         code = index + 1;         /* save the number of the match */
      index++;
   } while (*(point + index));      /* until NULL terminator found */

   exit(code);               /* return the errorcode to the system */
}