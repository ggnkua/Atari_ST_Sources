/* Copyright 1990 by Antic Publishing, Inc. */
#include <stdio.h>
#include "easy.h"

fexists(filename)

char filename[];

/*
** This routine checks to see if the file specified by FILENAME (which should
** include the path as well) exists or not. If it exists, the function returns
** TRUE, otherwise it returns FALSE.
*/

{
   FILE *lunit, *fopen();
   
   lunit = fopen(filename, "rb");
   if(lunit EQ NULL) return(FALSE);
   fclose(lunit);
   return(TRUE);
}
