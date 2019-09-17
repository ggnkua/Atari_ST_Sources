#include "STDIO.H"
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
         mix_up_the_chars(line);
      }
   } while (c != NULL);

   fclose(fp);
}

mix_up_the_line(line)   /* this function turns all upper case
                           characters into lower case, and all
                           lower case to upper case. It ignores
                           all other characters.               */ 
char line[];
{
int index;

   for (index = 0;line[index] != 0;index++) {
      if (isupper(line[index]))     /* 1 if upper case */
         line[index] = tolower(line[index]);
      else {
         if (islower(line[index]))  /* 1 if lower case */
            line[index] = toupper(line[index]);
      }
   }
   printf("%s",line);
}
