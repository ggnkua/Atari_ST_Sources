/************************************************/
/*             DEMO.C  von 15.10.1990           */
/*        (w) & (c) 1990 by Grischa Ekart       */
/*  erstellt mit Turbo C V1.0 von BORLAND GmbH  */
/************************************************/

#include <stdio.h>
#include <math.h>
#include "formula.h"

FUNC  func_tab[] = {
   "sin", sin,
   "cos", cos,
   "tan", tan,
   0, 0
};

char  *err_str[] = {
   "unbekanntes Zeichen",
   "unerwartetes Zeichen",
   "linke Klammer fehlt",
   "rechte Klammer fehlt",
   "unbekannte Funktion"
};

void  main(void);
void  error_msg(int message);

void
main(void)
{
   char  string[80];

   while(TRUE)
   {
      gets(string);
      if(parse(string) == TRUE)
      {
         printf("ergibt: %lf\n", value);
      }
      else
         break;
   }
}

void
error_msg(int message)
{
   printf("Fehler: %s an der Stelle: %d\n",
      err_str[message], position);
}

