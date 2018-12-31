/* --------------------------------------------------------------------
   Module:     NEWACHM.C
   Subject:    ACHMED.NEW handling compatible to ACHMED
   Author:     pse
   Started:    1993-07-31
   Modified:
   -------------------------------------------------------------------- */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "clib.h"
#include "global.h"



void ReadAchmedNew (void)
{
   FILE        *fp;
   char        line[128];
   char        *p;
   char        *pName;
   WORD        flags;
   WORD        last;
   AREAPARAM   *pArea;

   if (!AchmedMode) return;
   
   fp = fopen (szAchmedNew, "r");
   if (fp == NULL) {
      ShowError (szAchmedNew, strerror (errno));
      return;
   }
   
   while (ReadLine (line, (int) sizeof (line), fp)) {
      p = line;
      flags = atoi (p);
      while (*p && (*p != ',')) p++;
      if (*p) p++;
      last = atoi (p);
      while (*p && (*p != ',')) p++;
      if (*p) p++;
      while (isspace (*p)) p++;
      pName = p;
      p = p + strlen (p) - 1;
      while ((p >= pName) && isspace (*p)) p--;
      *(p + 1) = '\0';

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


void WriteAchmedNew (void)
{
   FILE      *fp;
   AREAPARAM *pArea;
   
   if (!AchmedMode) return;
   
   fp = fopen (szAchmedNew, "w");
   if (fp == NULL) {
      ShowError (szAchmedNew, strerror (errno));
      return;
   }
   
   for (pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext) {
      fprintf (fp, "%d, %d, %s\n", pArea->LedFlags, pArea->LastRead,
               pArea->pLocalName);
    }
}
