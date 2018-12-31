/* --------------------------------------------------------------------
   Module:     MISC.C
   Subject:    Utilities for ECU and LLEGADA
   Author:     ho
   Started:    15.07.1990   22:04:40                  
   --------------------------------------------------------------------
   94-04-03ps  HoldScreen-Handling in FinishAll()
   92-10-17ps  GEM-Abh„ngigkeiten entfernt
   --------------------------------------------------------------------
   17.09.1990  optionally don't show errors in dialog box
   29.11.1990  extracted from ECU.C
   17.02.1991  write log-message
   -------------------------------------------------------------------- */



/* --------------
      Includes
   -------------- */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#if defined(__TOS__)
   #include <ext.h>
   #include <tos.h>
#else
   #include <time.h>
#endif

#include "defines.h"

#include "global.h"



/* ----------------
      Varaiables
   ---------------- */

char    *pScreen       = NULL;
BOOL    redraw         = FALSE;
FILE    *fpLogMessage  = NULL;
char    *pTempName     = "ECU.TMP";




/* --------------------------------------------------------------------
      FinishAll

      is called when the program terminates. It assumes that a resource
      has been loaded, and the main dialog is on the screen. All termi-
      nating action should be placed here.
   --------------------------------------------------------------------- */
void  FinishAll(void)
{
    if (HoldScreen) {
        printf ("\nPress any key to continue.\n");
        (void) getch();
    }
}



/* --------------------------------------------------------------------
   WriteLogMessage
   -------------------------------------------------------------------- */
void WriteLogMessage(void)
{
   MSG_HEADER  header;
   time_t      tm;
   FILE        *fp;
   FILE        *fpLog;
   char        filename[FILENAME_MAX];
   char        buffer[512];
   int         n;

   if (fpLogMessage == NULL) return;

   fpLog = fpLogfile;
   fpLogfile = NULL;
   CloseLogfile();
   fpLogfile = fpLog;

   fpLog = fpLogMessage;
   fpLogMessage = NULL;

   if (pCommArea != NULL)
   {
      tm = time(NULL);
      memset(&header, 0, sizeof(header));
      strcpy(header.szFrom, szTearline);
      strcpy(header.szTo, pSysopName->pName);
      strcpy(header.szSubject, "Status Report");
      strftime(header.szDate, 20, "%d %b %y  %H:%M:%S", localtime(&tm));
      header.lDate = tm;
      header.wFlags = 0;
      header.wFromZone  = header.wToZone  = pCommArea->pHost->BossZone;
      header.wFromNet   = header.wToNet   = pCommArea->pHost->BossNet;
      header.wFromNode  = header.wToNode  = pCommArea->pHost->BossNode;
      header.wFromPoint = header.wToPoint = pCommArea->pHost->Point;

      BuildFilename(filename, -1, szHomeDir, pCommArea->pFilename, "MSG");
      fp = fopen(filename, "ab");
      if (fp == NULL)
      {
         ShowError(filename, strerror(errno));
         goto fatal;
      }
      header.lStart = ftell(fp);
      fflush(fpLog);
      fseek(fpLog, 0, SEEK_SET);
      while ((n = (int) fread(buffer, sizeof(char), sizeof(buffer), fpLog)) > 0)
      {
         if (fwrite(buffer, sizeof(char), n, fp) < n)
         {
            ShowError(filename, strerror(errno));
            header.wSize += n;
            break;
         }
         header.wSize += n;
      }
      fwrite("", sizeof(char), 1, fp);
      fclose(fp);
      header.wSize++;

      BuildFilename(filename, -1, szHomeDir, pCommArea->pFilename, "HDR");
      fp = fopen(filename, "ab");
      if (fp == NULL)
      {
         ShowError(filename, strerror(errno));
         goto fatal;
      }
      fwrite(&header, sizeof(header), 1, fp);
      fclose(fp);
      pCommArea->LedFlags |= 3;
   }

fatal:
   fclose(fpLog);
   remove(pTempName);
}



/* --------------------------------------------------------------------
      WriteLogfile
   -------------------------------------------------------------------- */
void  WriteLogfile(char *msg)
{
   static BOOL FirstOpen = TRUE;
   static BOOL FirstCall = TRUE;
   time_t   tm;
   char     *ts;

   if (FirstCall)
   {
      FirstCall = FALSE;
      fpLogMessage = fopen(pTempName, "wb+");
   }

   if (FirstOpen)
   {
      FirstOpen = FALSE;
      OpenLogfile();
   }

   tm = time(NULL);
   ts = asctime(localtime(&tm));

   printf("%15.15s%4.4s  %s\n", ts + 4, szProgramId, msg);

   if (fpLogfile != NULL)
   {
      fprintf(fpLogfile, "= %15.15s%4.4s  %s\n", ts + 4, szProgramId, msg);
   }

   if (fpLogMessage != NULL)
   {
      fprintf(fpLogMessage, "  %15.15s%4.4s  %s\n", ts + 4, szProgramId, msg);
   }
}



/* --------------------------------------------------------------------
      OpenLogfile
   -------------------------------------------------------------------- */
void  OpenLogfile(void)
{
   static BOOL recurse = FALSE;
   BOOL  reopen;

   if (recurse) return;
   recurse = TRUE;

#pragma warn -pia
   if (reopen = fpLogfile != NULL) fclose(fpLogfile);
#pragma warn .pia

   if (LogLevel > 0 && szLogfile[0] != 0)
   {
      fpLogfile = fopen(szLogfile, "a");
      if (fpLogfile == NULL)
      {
         ShowError(szLogfile, strerror(errno));
         szLogfile[0] = 0;
      }
      else
      {
         if (!reopen)
         {
            fprintf(fpLogfile, "\n");
         }
      }
   }

   if (!reopen) WriteLogfile(szTearline);
   recurse = FALSE;
}



/* --------------------------------------------------------------------
      CloseLogfile
   -------------------------------------------------------------------- */
void  CloseLogfile(void)
{
   WriteLogfile("log closed");

   if (fpLogfile != NULL)
   {
      fclose(fpLogfile);
      fpLogfile = NULL;
   }
}



/* ---------------------------------------------------------------------
      usage

      displays a short description of the program's parameters
   --------------------------------------------------------------------- */

void  usage(void)
{
   printf ("Usage: ECU | LLEGADA [options] [config file]\n");
   printf ("Valid Options:\n");
   printf ("  -c[yes|no|toggle]  crunch [E]\n");
   printf ("  -d[yes|no|toggle]  dupe checking [EL]\n");
   printf ("  -f[mode]           create dummy flow file [E]\n");
   printf ("  -l[file]           use `file' as logfile [EL]\n");
   printf ("  -m[level]          set loglevel to `level' [EL]\n");
   printf ("  -p[yes|no|toggle]  pack areas [E]\n");
   printf ("  -q[yes|no|toggle]  quick scan [E]\n");
   printf ("\nPlease consult the manual for further information.\n");
}



/* --------------------------------------------------------------------
      ShowError

      outputs an error message in a dialog box. Program may be aborted
      with the exit button or continued.

      Input:
      ------
      char *caption
         first line in message box, normally the name of the calling
         function or a filename

      char *message
         second line in message box, normally an error message

      Returns:
      --------
         Only if continue has been selected. If abort has been selected
         the program terminates with errorlevel 3.
   --------------------------------------------------------------------- */

void  ShowError(char *caption, char *message)
{
   char     line[256];

   if (LogLevel > 0)
   {
      if (caption == NULL)
      {
         WriteLogfile(message);
      }
      else
      {
         strcpy(line, caption);
         strcat(line, ": ");
         strcat(line, message);
         WriteLogfile(line);
      }
   }
}



/* --------------------------------------------------------------------
      BuildFilename

      creates a filename with path, drive and extension from a given
      filename and default drive, path and extension.

      pFullName   address of buffer to hold complete filename
      drive       <0: no drive, 0: drive A etc., only used if neither
                  path nor name contain :
      pPath       default path, only used if name does not contain \
                  or :
      pName       initial filename
      pExtension  default extension, only used if filename does not
                  already contain an extension
   -------------------------------------------------------------------- */
char *BuildFilename(char *pFullName,
                   int drive, char *pPath, char *pName, char *pExtension)
{
   char *p;
   char *q;

   q = pFullName;
   if (strchr(pName, ':') == NULL)
   {
      if (*pName != '\\')
      {
         if (strchr(pPath, ':') == NULL)
         {
            if (drive >= 0)
            {
               *q++ = drive + 'A';
               *q++ = ':';
            }
         }
         q += strlen(strcpy(q, pPath));
         if (*pPath && *(q - 1) != '\\') *q++ = '\\';
      }
      else
      {
         if (drive >= 0)
         {
            *q++ = drive + 'A';
            *q++ = ':';
         }
      }
   }
   strcpy(q, pName);
   p = strchr(q, '\\');
   if (p == NULL) p = q;
   if (strchr(p, '.') == NULL)
   {
      strcat(strcat(q, "."), pExtension);
   }

   return pFullName;
}
