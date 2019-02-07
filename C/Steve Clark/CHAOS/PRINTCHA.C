/* Copyright 1990 by Antic Publishing, Inc. */
#include "easy.h"

printcha(array, larray, flag) /************** PRINTCHA **********************/
/*
** function to send a character array of length larray to the printer. The work
   is done by the function GEMDOS(0x5,i) which sends one character (type long)
   to the printer. If flag = 1, a <CR><LF> is sent after the array. */

char array[];
short larray, flag;

{
   short i, ival;

   i = 0;
   while(i LT larray) DO
      ival = array[i++];
      gemdos(0x5,ival);
   ENDDO
   if(flag EQ 1) THEN   /* Send a <CR><LF> to the printer */
      gemdos(0x5, '\r');
      gemdos(0x5, '\n');
   ENDIF
}
