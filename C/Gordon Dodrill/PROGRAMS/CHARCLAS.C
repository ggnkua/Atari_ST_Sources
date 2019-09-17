#include "stdio.h"
#include "ctype.h"  /* Note - your compiler may not need this */

main()
{
FILE *fp;
char line[80], filename[24];
char *c;

   printf("Enter filename -> ");
   scanf("%s",filename);
   fp = fopen(filename,"r");

   do {
      c = fgets(line,80,fp);   /* get a line of text */
      if (c != NULL) {
         count_the_data(line);
      }
   } while (c != NULL);

   fclose(fp);
}

count_the_data(line)
char line[];
{
int whites, chars, digits;
int index;

   whites = chars = digits = 0; 

   for (index = 0;line[index] != 0;index++) {
      if (isalpha(line[index]))   /* 1 if line[] is alphabetic  */
          chars++;
      if (isdigit(line[index]))   /* 1 if line[] is a digit     */
          digits++;
      if (isspace(line[index]))   /* 1 if line[] is blank, tab, */
          whites++;               /*           or newline       */ 
   }   /* end of counting loop */

   printf("%3d%3d%3d %s",whites,chars,digits,line);
}