/* *************************************************************** */
/* This module contains the functions called by the list.c program */
/* program. If this were a program to be used for some specific    */
/* purpose, it would probablly not be wise to break it up into two */
/* separately compiled modules. It is only done here for purposes  */
/* of illustration. It is a useful program.                        */
/* *************************************************************** */

#define MAXLINES 54            /* maximum number of lines per page */
#include "stdio.h"                     /* standard I/O header file */
extern FILE *file_point;         /* pointer to the file to be read */
extern FILE *print_file_point;           /* pointer to the printer */
extern char oneline[];                 /* input string buffer area */
char filename[15];               /* filename from header or prompt */
int line_number = 0;             /* line number initialized to one */
int page_number = 1;             /* page number initialized to one */
int lines_this_page = 0;              /* lines on this page so far */


/* ***************************************************** open_file */
/* This function opens the input file named on the command line,   */
/* if there was one defined. Otherwise, it requests a file name to */
/* open and opens the requested file.                              */
/* *************************************************************** */
open_file(no,name)
int no;                     /* number of arguments on command line */
char *name;                    /* first argument from command line */
{

   strcpy(filename,name);         /* copy name for printing header */
   file_point = NULL;           /* if no name was given in command */
   if (no == 2) {              /* 2nd field in command is filename */
      file_point = fopen(name,"r");         /* open requested file */
      if (file_point == NULL)        /* NULL if file doesn't exist */
         printf("Filename on command line doesn't exist!\n");
   }

   do {
      if (file_point == NULL) {                 /* no filename yet */
         printf("Enter filename -> ");
         scanf("%s",filename);
         file_point = fopen(filename,"r");            /* open file */
         if (file_point == NULL)          /* NULL if file no exist */
            printf("Filename doesn't exist, try again.\n");
      }
   } while (file_point == NULL);   /* continue until good filename */
}


/* *********************************************** open_print_file */
/* This function opens the printer file to the standard printer.   */
/* *************************************************************** */  
open_print_file()
{
   print_file_point = fopen("PRN","w");       /* open printer file */
}


/* ************************************************** print_a_line */
/* This routine prints a line of text and checks to see if there   */
/* is room for another line on the page. If not, it starts a new   */
/* page with a new header. This routine calls several other local  */
/* routines.                                                       */
/* *************************************************************** */
print_a_line()
{
int index;

   header();
   printf("%5d %s",line_number,oneline);

                       /* This prints a line of less than 72 chars */
   if (strlen(oneline) < 72)
      fprintf(print_file_point,"%5d %s",line_number,oneline);

                          /* This prints a line of 72 to 143 chars */
   else if (strlen(oneline) < 144) {
      fprintf(print_file_point,"%5d ",line_number);
      for (index = 0;index < 72;index++)
         fprintf(print_file_point,"%c",oneline[index]);
      fprintf(print_file_point,"<\n      ");
      for (index = 72;index < strlen(oneline);index++)
         fprintf(print_file_point,"%c",oneline[index]);
      lines_this_page++;
   }

                          /* This prints a line of 144 to 235 chars */
   else if (strlen(oneline) < 235) {
      fprintf(print_file_point,"%5d ",line_number);
      for (index = 0;index < 72;index++)
         fprintf(print_file_point,"%c",oneline[index]);
      fprintf(print_file_point,"<\n      ");
      for (index = 72;index < 144;index++)
         fprintf(print_file_point,"%c",oneline[index]);
      fprintf(print_file_point,"<\n      ");
      for (index = 144;index < strlen(oneline);index++)
         fprintf(print_file_point,"%c",oneline[index]);
      lines_this_page += 2;
   }
         /* the following line outputs a newline if there is none
                                      at the end of the last line */
   if (oneline[strlen(oneline)-1] != '\n')
      fprintf(print_file_point,"%c",'\n');
   line_number++;
   lines_this_page++;
}


/* ******************************************************** header */
/* This routine checks to see if a header needs to be printed. It  */
/* also checks for the end of a page. and spaces the paper up.     */
/* *************************************************************** */
header()
{
int index;

                  /* first see if we are at the bottom of the page */
   if (lines_this_page > MAXLINES) {  /* space paper up for bottom */
   for (index = lines_this_page;index < 61;index++)
      fprintf(print_file_point,"\n");
   lines_this_page = 0;
   }

            /* put a monitor header out only at the very beginning */
   if (line_number == 0) {               /* display monitor header */
      printf("        Source file %s\n",filename);
      line_number = 1;
   }

         /* check to see if we are at the top of the page either   */ 
         /* through starting a file, or following a bottom of page */
   if (lines_this_page == 0) {        /* top of every printer page */
      fprintf(print_file_point,"\n\n\n        ");
      fprintf(print_file_point," Source file - %s        ",filename);
      fprintf(print_file_point,"          Page %d\n\n", page_number);
      page_number++;
   }
}


/* *************************************************** top_of_page */
/* This function spaces the paper to the top of the next page so   */
/* that another call to this function will start correctly. This   */
/* is used only at the end of a complete printout.                 */
/* *************************************************************** */
top_of_page()
{
int index;

   for (index = lines_this_page;index < 61;index++)
      fprintf(print_file_point,"\n");
}
