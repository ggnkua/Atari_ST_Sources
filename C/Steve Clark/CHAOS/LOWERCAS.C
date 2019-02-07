/* Copyright 1990 by Antic Publishing, Inc. */
#include "easy.h"

lowercase(string) /****************** LOWERCASE *************************/
/*
** This routine converts the alphabetic characters in 'string' to lowercase.
*/
char string[];

{
   int i;

   for(i=0; string[i] NE NULL; ++i)
         if((string[i] GE 'A') AND (string[i] LE 'Z')) string[i]=string[i]+32;
}
