#include "stdio.h"
#define CR 13       /* this defines CR to be 13 */
#define LF 10       /* this defines LF to be 10 */

main()
{
char c;

   printf("Input any characters, hit X to stop.\n");

   do {
      c = getch();                    /* get a character */
      putchar(c);                     /* display the hit key */
      if (c == CR) putchar(LF);       /* if it is a carriage return
                                         put out a linefeed too */
   } while (c != 'X');

   printf("\nEnd of program.\n");
}
