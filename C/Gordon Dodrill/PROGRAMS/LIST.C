/* *************************************************************** */
/* This program will read in any text file and list it on the      */
/* monitor with line numbers and with page numbers.                */
/* *************************************************************** */

#include "stdio.h"                     /* standard I/O header file */
#define MAXCHARS 255                     /* maximum size of a line */
FILE *file_point;                    /* pointer to file to be read */
FILE *print_file_point;                      /* pointer to pronter */
char oneline[256];                     /* input string buffer area */

main(number,name)
int number;                 /* number of arguments on command line */
char *name[];               /* arguments on the command line       */
{
char *c;                       /* variable to indicate end of file */
char *point;

   point = name[1];
   open_file(number,point);     /* open the file to read and print */
   open_print_file();

   do {
      c = fgets(oneline,MAXCHARS,file_point);     /* read one line */
      if (c != NULL)
         print_a_line();                         /* print the line */
   } while (c != NULL);                      /* continue until EOF */

   top_of_page();                     /* move paper to top of page */
   close(file_point);                           /* close read file */
   close(print_file_point);                  /* close printer file */
}
