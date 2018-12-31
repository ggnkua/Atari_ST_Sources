/* --------------------------------------------------------------------
   Module:     NEWLED.C
   Subject:    LED.NEW handling compatible to LED 1.00
   Author:     ho
   Started:    06.01.1991   22:09:28
   Modified:  07.04.1991   22:10:42
   -------------------------------------------------------------------- */
   


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "clib.h"
#include "global.h"



void ReadLedNew(void)
{
   FILE        *fp;
   char        line[128];
   char        *p;
   char        *pName;
   WORD        flags;
   WORD        last;
   AREAPARAM   *pArea;
   
   if (szLedNew[0] == 0) return;
   
   fp = fopen(szLedNew, "r");
   if (fp == NULL)
   {
      ShowError(szLedNew, strerror(errno));
      return;
   }
   
   while (ReadLine(line, (int) sizeof(line), fp))
   {
      p = line;
      while (*p == ' ') ++p;
      pName = p;
      while (*p && *p != ' ') ++p;
      if (*p) *p++ = 0;
      while (*p == ' ') ++p;
      last = atoi(p);
      while (*p && *p != ' ') ++p;
      while (*p == ' ') ++p;
      flags = atoi(p);
      
      pArea = FindLocalArea(pName);
      if (pArea != NULL)
      {
         pArea->LastRead = last;
         pArea->LedFlags = flags;
      }
      else
      {
         ShowError(pName, "area not defined in config file");
      }
   }
   
   fclose(fp);
}



void WriteLedNew(void)
{
   FILE        *fp;
   AREAPARAM   *pArea;
   
   if (szLedNew[0] == 0) return;
   
   fp = fopen(szLedNew, "w");
   if (fp == NULL)
   {
      ShowError(szLedNew, strerror(errno));
      return;
   }
   
   for (pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext)
   {
      fprintf(fp, "%s %d %d\n",
                  pArea->pLocalName, pArea->LastRead, pArea->LedFlags);
   }
}
