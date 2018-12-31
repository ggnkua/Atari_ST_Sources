/* --------------------------------------------------------------------
   Modul:      TICK.C
   Subject:    creates a tick file
   Author:     ho
   Started:    02.02.1991   23:52:02
   Modified:   19.07.1991   22:09:10
   --------------------------------------------------------------------
   09.02.1991  passwords are now required
   -------------------------------------------------------------------- */



/* --------------
      Includes
   -------------- */

#if defined(__TOS__)
   #include <ext.h>
#else
   #include <errno.h>
   #include <time.h>
   #include <sys/stat.h>
#endif

#include <string.h>

#include "global.h"
#include "ecudef.h"



/* --------------------------------------------------------------------
   CalcCRC

   computes the 32 bit CRC of a file.

   char *pFilename
      name of file that's CRC shall be computed

   long *crc
      address of the long were the computed CRC should be returned

   returns
      TRUE if CRC has been computed, FALSE otherwise, which will indi-
      cate a read error in most cases.
   -------------------------------------------------------------------- */
BOOL CalcCrc32(char *pFilename, long *crc)
{
   FILE     *fp;
   LONG     c;
   BYTE     buffer[2048];
   size_t   n;

   fp = fopen(pFilename, "rb");
   if (fp == NULL)
   {
      ShowError(pFilename, strerror(errno));
      return FALSE;
   }

   c = ~(LONG)0;
   while ((n = fread(buffer, sizeof(BYTE), sizeof(buffer), fp)) > 0)
   {
      c = bCalcCrc32(c, buffer, n);
   }

   if (ferror(fp))
   {
      ShowError(pFilename, strerror(errno));
      fclose(fp);
      return FALSE;
   }

   fclose(fp);
   *crc = c;
   return TRUE;
}



/* --------------------------------------------------------------------
   CopyCommand

   copies a tick command from the message to the tick file. The command
   must be prefixed with the tickprefix defined in the configuration
   file (or ').

   char *buffer
      the address of the message to extract the commands from

   FILE *fp
      the file to write the commands to

   char *keyword
      the command to look for in the message. A command line must start
      with the tick-prefix followed by the keyword and a space or a
      colon. Spaces between the prefix and the keyword are ignored. The
      keyword is not case sensitive.

   BOOL unique
      If TRUE, only the first occurence of the command is copied, then
      the function terminates immediately. If FALSE, all commandlines
      matching the keyword are copied.

   Returns
      TRUE if at least one occurence of the keyword has been found,
      FALSE otherwise.
   -------------------------------------------------------------------- */
BOOL CopyCommand(char *buffer, FILE *fp, char *keyword, BOOL unique)
{
   int   l;
   BOOL  f;

   l = (int) strlen(keyword);
   f = FALSE;
   while (*buffer)
   {
      if (*buffer == TickPrefix)
      {
         do ++buffer; while (*buffer == ' ');
         if (strnicmp(buffer, keyword, l) == 0 &&
             (buffer[l] == ':' || buffer[l] == ' '))
         {
            f = TRUE;
            while (*buffer && *buffer != '\x0A')
            {
               fputc(*buffer, fp);
               ++buffer;
            }
            fputc('\n', fp);
            if (unique) return TRUE;
         }
      }
      while (*buffer && *buffer != '\x0A') ++buffer;
      if (*buffer) ++buffer;
   }

   return f;
}



/* --------------------------------------------------------------------
   CopyUnknown
   -------------------------------------------------------------------- */
void CopyUnknown(char *p, FILE *fp)
{
   char  *q;
   int   l;

   while (*p)
   {
      if (*p == TickPrefix)
      {
         do ++p; while (*p == ' ');
         for (q = p; *q && *q != ' ' && *q != ':'; q++);
         l = (int) (q - p);
         if (strnicmp(p, "area",    l) != 0
         &&  strnicmp(p, "origin",  l) != 0
         &&  strnicmp(p, "from",    l) != 0
         &&  strnicmp(p, "file",    l) != 0
         &&  strnicmp(p, "size",    l) != 0
         &&  strnicmp(p, "date",    l) != 0
         &&  strnicmp(p, "desc",    l) != 0
         &&  strnicmp(p, "created", l) != 0
         &&  strnicmp(p, "path",    l) != 0
         &&  strnicmp(p, "seenby",  l) != 0
         &&  strnicmp(p, "crc",     l) != 0
         &&  strnicmp(p, "pw",      l) != 0)
         {
            while (*p && *p != '\x0A')
            {
               fputc(*p, fp);
               ++p;
            }
            fputc('\n', fp);
         }
      }
      while (*p && *p != '\x0A') ++p;
      if (*p) ++p;
   }
}



/* --------------------------------------------------------------------
   utc

   converts the date from TOS format into UNIX format.

   LONG tostime
      the date to convert in TOS format

   Returns
      number of seconds since 01-01-1970, 0:00
   -------------------------------------------------------------------- */
LONG utc(LONG tostime)
{
   WORD  days[] = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };
   WORD  year;
   WORD  month;
   WORD  day;
   WORD  hour;
   WORD  minute;
   WORD  second;
   LONG  utime;

   second = (tostime & 0x0000001F) <<  1;
   minute = (tostime & 0x000007E0) >>  5;
   hour   = (tostime & 0x0000F800) >> 11;
   day    = (tostime & 0x001F0000) >> 16;
   month  = (tostime & 0x01E00000) >> 21;
   year   = (tostime & 0xFE000000) >> 25;

   utime  = year * 365L + (year + 3) / 4
          + days[month - 1]
          + day - 1
          + 10 * 365 + 2;
   if (month > 2 && (year & 3) == 0) ++utime;

   return ((utime * 24 + hour) * 60 + minute) * 60 + second;
}



/* --------------------------------------------------------------------
   CreateTickFile

   creates a TICK file (what else?), stores it in the outbound directo-
   ry and appends it to the flow file.

   char *szFilename
      the address of the full filename as specified in the subject
      line, and as written to the F/Clow file.

   BOOL CrashMail
      if TRUE, the tick file and the file itself are directly sent to
      their destination (or to its bossnode, if the destination is a
      (4d addressed) point. In fact, CrashMail only selects the .CLO
      file (TRUE) vs. the .FLO file (FALSE). In both cases the message
      header already contains the destination address.

   HOSTPARAM *pHost
      the address of the destination's definition area. If CrashMail is
      TRUE this will allways be the address of the area's default host.

   AREAPARAM *pArea
      the address of the area's definition block.

   char *pText
      the address of the message text. All scrolls are removed from the
      message. Tick commands will be removed later.
   -------------------------------------------------------------------- */
BOOL CreateTickFile(char         *pFilename,
                    BOOL         CrashMail,
                    HOSTPARAM    *pHost,
                    AREAPARAM    *pArea,
                    MSG_HEADER   *pHeader,
                    char         *pText)
{
   struct stat fileinfo;
   char     nmTickFile[FILENAME_MAX];
   char     str[32];
   char     *p, *q;
   FILE     *fp;
   long     crc;
   time_t   tm;

   p = q = pFilename;
   while (*p)
   {
      if (*p == '\\' || *p == ':') q = p + 1;
      ++p;
   }

   if (stat(pFilename, &fileinfo) == -1)
   {
      ShowError(pFilename, strerror(errno));
      return FALSE;
   }
   if (!CalcCrc32(pFilename, &crc)) return FALSE;
   crc = ~crc;

   sprintf(nmTickFile + 1, "%sTK%.6lX.TIC",
                           szOutbound,
                           lFreeId++ & 0x00ffffffL);

   fp = fopen(nmTickFile + 1, "w");
   if (fp == NULL)
   {
      ShowError(nmTickFile + 1, strerror(errno));
      return FALSE;
   }

/*   AREA name          */
   if (!CopyCommand(pText ,fp, "area", TRUE))
   {
      if (pArea->Type & AT_TICKAREA)
      {
         fprintf(fp, "Area %s\n", pArea->pAreaname);
      }
      else
      {
         ShowError(pFilename, "no 'Area statement found");
         fclose(fp);
         return FALSE;
      }
   }

/*   ORIGIN address     */
/*   FROM address pw    */
   if (pHost->OldTick)
   {
      sprintf(str, "%u:%u/%u",
                   pHost->FakeZone,
                   pHost->FakeNet,
                   pHost->FakeNode);
   }
   else
   {
      sprintf(str, "%u:%u/%u.%u",
                   pHost->BossZone,
                   pHost->BossNet,
                   pHost->BossNode,
                   pHost->Point);
   }
   fprintf(fp, "Origin %s\n", str);
   fprintf(fp, "From %s\n", str);

/*   FILE name          */
   fprintf(fp, "File %s\n", q);

/*   SIZE count         */
   fprintf(fp, "Size %lu\n", fileinfo.st_size);

/*   DATE utc           */
   fprintf(fp, "Date %lu\n", utc(fileinfo.st_mtime));

/*   DESC comment       */
   if (!CopyCommand(pText ,fp, "desc", FALSE))
   {
      ShowError(pFilename, "no description for TICK file found");
      fclose(fp);
      return FALSE;
   }

/*   CREATED by         */
   fprintf(fp, "Created by %s\n", szTearline);

/*   PATH address ...   */
   time(&tm);
   fprintf(fp, "Path %s %lu %s", str, tm, ctime(&tm));

/*   SEENBY address ... */
   fprintf(fp, "Seenby %s\n", str);
   fprintf(fp, "Seenby %u:%u/%u\n",
               pHost->BossZone,
               pHost->BossNet,
               pHost->BossNode);

/*   CRC crc            */
   sprintf(str, CrcFormat, crc);
   fprintf(fp, "CRC %s\n", str);

/*   PW password       */
   if (!CopyCommand(pText ,fp, "pw", TRUE))
   {
      if (pArea->pPassword != NULL)
      {
         fprintf(fp, "Pw %s\n", pArea->pPassword);
      }
      else
      {
         ShowError(pFilename, "TICK: no password");
      }
   }

/*   RELEASE time       */
/*   REPLACES name      */
/*   APP comment        */

   CopyUnknown(pText, fp);

   fclose(fp);

   nmTickFile[0] = '^';
   if (CrashMail)
   {
      WriteFlowFileEntry(pHeader->wToZone,
                         pHeader->wToNet,
                         pHeader->wToNode,
                         pHeader->wToPoint,
                         NULL,
                         pFilename,
                         FF_CLO);
      WriteFlowFileEntry(pHeader->wToZone,
                         pHeader->wToNet,
                         pHeader->wToNode,
                         pHeader->wToPoint,
                         NULL,
                         nmTickFile,
                         FF_CLO);
   }
   else
   {
      WriteFlowFileEntry(pHost->BossZone,
                         pHost->BossNet,
                         pHost->BossNode,
                         0,
                         pHost->pDomain,
                         pFilename,
                         FF_FLO);
      WriteFlowFileEntry(pHost->BossZone,
                         pHost->BossNet,
                         pHost->BossNode,
                         0,
                         pHost->pDomain,
                         nmTickFile,
                         FF_FLO);
   }

   return TRUE;
}
