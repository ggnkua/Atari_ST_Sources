#include "stdio.h"

main()
{
FILE *fp1;
char oneword[100],filename[25];
char *c;

   printf("Enter filename -> ");
   scanf("%s",filename);         /* read the desired filename */
   fp1 = fopen(filename,"r");

   do {
      c = fgets(oneword,100,fp1); /* get one line from the file */
      if (c != NULL)
         printf("%s",oneword);    /* display it on the monitor  */
   } while (c != NULL);          /* repeat until NULL          */

   fclose(fp1);
}
