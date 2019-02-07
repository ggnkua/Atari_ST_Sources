/* Copyright 1990 by Antic Publishing, Inc. */
#include "easy.h"

uppercase(string) /********************** UPPERCASE ********************/
/*
** This routine converts alphabetic characters in string to uppercase.
*/

char string[];

{
   short i;

   i = -1;
   while(string[++i] NE NULL)
      if((string[i] GE 'a') AND (string[i] LE 'z')) string[i] = string[i] - 32;
}
