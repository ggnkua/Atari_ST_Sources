#include "stdio.h"
main()
{
FILE *point;
char others[35];
int indexer,count;

   strcpy(others,"Additional lines.");
   point = fopen("tenlines.txt","a"); /* open for appending */

   for (count = 1;count <= 10;count++) {
      for (indexer = 0;others[indexer];indexer++)
         putc(others[indexer],point);  /* output a single character */
      putc('\n',point);                /* output a linefeed */
   }
   fclose(point);
}