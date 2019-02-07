/* Copyright 1990 by Antic Publishing, Inc. */
locate(substr, string, istart)

char substr[], string[];

short istart;
/*
** This function searches dfor 'substr' within 'string', starting at 'istart'.
** If 'istart' is negative, the search is towards the beginning of 'string',
** starting at -istart. Otherwise the search is in the forward direction. The
** function is equated to the position of the first character of 'substr'
** within 'string'. If no match is found, locate is equated to -1.
*/

{
#include "easy.h"

   short i, j, lsubstr, lstring, number;

   lsubstr = strlen(substr);
   lstring = strlen(string);
   number = lstring - lsubstr;

   if(istart GE 0) THEN /* Search through 'string' in forward direction */
      for (i=istart; i LE number; ++i) DO
         for (j=0; j LT lsubstr; ++j) DO
            if(string[i+j] NE substr[j]) break;
            if(j EQ lsubstr-1) return(i);
         ENDDO
      ENDDO
   ELSE THEN      /* Search backwards */
      if(-istart GT number) istart = -number;
         for (i=-istart; i GE 0; --i) DO
            for (j=0; j LT lsubstr; ++j) DO
               if(string[i+j] NE substr[j]) break;
               if(j EQ lsubstr-1) return (i);
            ENDDO
         ENDDO
   ENDIF
      
   return(-1);    /* No match found */
}
