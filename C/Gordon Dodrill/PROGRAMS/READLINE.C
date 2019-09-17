#include "stdio.h"

main()
{
FILE *fp1;
char oneword[100];
char *c;

   fp1 = fopen("TENLINES.TXT","r");

   do {
      c = fgets(oneword,100,fp1); /* get one line from the file */
      if (c != NULL)
         printf("%s",oneword);    /* display it on the monitor  */
   } while (c != NULL);          /* repeat until NULL          */

   fclose(fp1);
}
