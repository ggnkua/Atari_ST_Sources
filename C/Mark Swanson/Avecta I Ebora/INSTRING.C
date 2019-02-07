/******************************************************************************/
/* This call inputs a string typed in on the keyboard, stores it at the addr  */
/* passed in string, and echoes the typed string to the screen at the cursor  */
/* position x,y.  It allows backspacing and erasing the string that way.  It  */
/* terminates on RET, or if the string has exceed the length of MAXIMUM,      */
/* and passes the length of the string in chars back.                         */
/* Flag disables capitalization if it is set.                                 */
/******************************************************************************/

#include "osbind.h"

extern int instring(x,y,string,max,flag)
char *string;
int x,y,max,flag;
{
extern int handle;
int k,i=0;
do {
   k = Bconin(2); /* pull character from keyboard */
   if(k == 0 || k == 13)   /* this is a dead key, like the cursors,undo, etc. */
     continue;
   k = (k < 96 && k > 64 && flag ? k+32 : k);
   *(string+i) = k;
   if(k == 8 ) { /* then struck the backspace key */
      --i;  /* back up along string */
      if(i < 0) { /* can't back up further than original y */
          i = 0;
          continue;
          }
      textsix(1,6*(y+i),8*(x-1),1,string+i);  /* XOR will snuff out image */
      *(string+i) = '';  /* wipe out char at position i */
      continue;          /* fall through to while */
      }
   textsix(1,6*(y+i),8*(x-1),1,string+i); /* echo to da screen */
   i++;
   } while (k != 13 && i-1 < max); /* 13 is the ascii code for return */
*(string+i) = '\0'; /* terminate the string with a null marker */
return(i-1); /* kick back the char length */
}








