
/* --------------------------------------------------------------------
      ReadLine
      
      liest eine Zeile aus einer Datei. Die maximale L„nge der Zeile
      kann angegeben werden.
      
      Parameter:
      ----------
         pLine       Adresse des Arrays, in das die Zeile geschrieben
                     werden soll
         iMaxLength  max. Zeilenl„nge incl. NUL-Byte
         pFile       Filepointer
         
      Ergebnis:
      ---------
         TRUE        kein Fehler beim Lesen, nicht am Dateiende
         FALSE       Dateiende oder Fehler
   -------------------------------------------------------------------- */



#include "defines.h"
#include <stdio.h>



BOOL  ReadLine(char *pLine, int iMaxLength, FILE *pFile)
{
   int   i;
   int   ch;

   i = 0;
   do
   {
      ch = fgetc(pFile);
      if (ch == EOF) return i > 0;
      if (i < iMaxLength) pLine[i++] = ch;
   }
   while (ch != '\n');
   pLine[i - 1] = 0;

   return TRUE;
}
