#include <stdio.h>

/* Function: patmat
   Purpose : Regular Expression Pattern Matching
   Author  : Sreenath Chary
   Notice  : Quite brilliantly optimized by Arjen G. Lentz
             (according to Mr. Lentz himself)
   Usage   : Pass two string pointers as parameters.  The first being a raw
             string & the second a pattern the raw string is to be matched
             against.  If the raw string matches the pattern,then the function
             returns 1, else it returns 0.

             e.g.  patmat("abcdefghi","*ghi")    returns a 1.
                   patmat("abcdefghi","??c??f*") returns a 1.
                   patmat("abcdefghi","*dh*")    returns a 0.
                   patmat("abcdefghi","*def")    returns a 0.

             The asterisk is a wild card to allow any characters from its first
             appearance to the next specific character.  The character ? is a
             wild card for only one character in the position it appears.
             Combinations such as "*?" or "?*" or "**" are illegal for obvious
             reasons & the functions may goof, though I think it will still
             work.

   Logic   : The only simple way I could devise is to use recursion.  Each
             character in the pattern is taken & compared with the character in
             the raw string.  If it matches then the remaining amount of the
             string & the remaining amount of the pattern are passed as
             parameters to patmat again until the end of the pattern.  If at
             any stage the pattern does not match,then we go back one level &
             at this level if the previous character was a asterisk in the
             pattern, we hunt again from where we left off, otherwise we return
             back one more level with a not found & the process goes on till
             the first level call.

             Only one character at a time is considered, except when the
             character is an asterisk. You'll get the logic as the program
             unfolds.
*/

int patmat(char *raw, char *pat)      /* regular expression pattern matching */
{
        if (!*pat)                /* end of both is ok, only pat is mismatch */
           return (!*raw);

        if (*pat == '*') {                                   /* wildcard '*' */
           if (!*++pat)                                 /* last pat char? ok */
              return (1);
           do if ((*raw == *pat || *pat == '?') &&           /* match/wild ? */
                  patmat(raw + 1,pat + 1))              /* match rest of pat */
                 return (1);
           while (*raw++);
        }
        else if (*raw && (*pat == '?' || *pat == *raw))      /* match/wild ? */
           return (patmat(++raw,++pat));            /* try & match rest of it*/

        return (0);                                        /* no match found */
}/*patmat()*/


/* end of patmat.c */
