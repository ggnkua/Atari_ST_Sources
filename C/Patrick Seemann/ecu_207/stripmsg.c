/* --------------------------------------------------------------------
   Module:     STRIPMSG.C
   Subject:    remove unwanted technical lines from a message
   Author:     ho
   Started:    27.01.1991   22:05:38                        
   Modified:    13.10.91     14:11:16                       
   -------------------------------------------------------------------- */



#include <string.h>
#include <ctype.h>
#include "defines.h"

#include "global.h"



/* --------------------------------------------------------------------
      RemoveOldScrolls

      strips existing tearline and following lines.

      Input:
      ------
      char *pStart
         address of nul-terminated message. On return the message body
         will be stored there.
   -------------------------------------------------------------------- */
long  RemoveOldScrolls(char *pStart)
{
   char  *pFrom;
   char  *pTo;
   char  *pLine;
   BOOL  body;
   BOOL  cr;
   long  switches;

   pFrom    = pStart;
   pLine    = pStart;
   body     = TRUE;
   cr       = TRUE;
   switches = 0;

   while (*pFrom && cr && body)
   {
      pTo = pLine;
      while (*pFrom && *pFrom != '\n') *pTo++ = *pFrom++;
      if (*pFrom) ++pFrom;
             else cr = FALSE;
      body &= pLine[0] != '-' || pLine[1] != '-' || pLine[2] != '-' ||
             (pLine[3] != ' ' && pLine[3] != '\n' && pLine[3] != '\0');

      if (strnicmp(pLine, "AREA:", 5) == 0)
      {
         continue;
      }

      if (strncmp (pLine, "\001MSGID", 6) == 0)
         continue;
      
      if (*pLine == FormatPrefix && isalpha(*(pLine + 1)))
      {
         switches |= 1L << (*(pLine + 1) & 0x1F);
      }

      if (body)
      {
         *pTo++ = '\n';
         pLine = pTo;
      }
   }

   while (pLine > pStart && *(pLine - 1) == '\n') --pLine;
   *pLine = '\0';

   return switches;
}
