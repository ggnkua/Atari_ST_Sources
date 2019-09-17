#include "stdio.h"    /* standard header for input/output */

main()
{
char c;

   printf("Enter any characters, X = halt program.\n");

   do {
      c = getchar();    /* get a single character from the kb */
      putchar(c);       /* display the character on the monitor */
   } while (c != 'X');  /* until an X is hit */

   printf("\nEnd of program.\n");
}
