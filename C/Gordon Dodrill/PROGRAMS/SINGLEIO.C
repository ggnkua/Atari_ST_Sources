#include "stdio.h"

main()
{
char c;

   printf("Enter any characters, terminate program with X\n");

   do {
      c = getch();                     /* get a character */
      putchar(c);                  /* display the hit key */
   } while (c != 'X');

   printf("\nEnd of program.\n");
}
