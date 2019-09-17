#include "stdio.h"

main()
{
FILE *funny,*printer;
int c;

   funny = fopen("TENLINES.TXT","r"); /* open input file     */
   printer = fopen("PRN","w");        /* open printer file   */

   do {
      c = getc(funny);    /* got one character from the file */
      if (c != EOF) {
         putchar(c);      /* display it on the monitor       */
         putc(c,printer); /* print the character             */  
      }
   } while (c != EOF);    /* repeat until EOF (end of file)  */

   fclose(funny);
   fclose(printer);
}
