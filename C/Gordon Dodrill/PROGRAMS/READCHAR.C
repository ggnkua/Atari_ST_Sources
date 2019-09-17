#include "stdio.h"

main()
{
FILE *funny;
int c;

   funny = fopen("TENLINES.TXT","r");

   if (funny == NULL) printf("File doesn't exist\n");
   else {
      do {
         c = getc(funny);    /* get one character from the file */
         putchar(c);         /* display it on the monitor       */
      } while (c != EOF);    /* repeat until EOF (end of file)  */
   }
   fclose(funny);
}
