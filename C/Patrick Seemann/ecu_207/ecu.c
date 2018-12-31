/* --------------------------------------------------------------------
   Module:     ECU.C
   Subject:    Export & Crunch Utility
   Author:     ho
   Started:    15.07.1990  23:47:48          
   --------------------------------------------------------------------
   94-04-03ps  NoWait & -w entfernt
               WriteStatistic[s] direkt nach jeder Area
   93-07-29ps  Support fÅr Achmed
   92-10-17ps  GEM-AbhÑngigkeiten entfernt
   92-06-18ps  Suffix bei SetVersion
   --------------------------------------------------------------------
   29.03.1992  Ecu 1.09 released
   23.03.1992  LastReadQBBS
   14.03.1992  /Fflag schaltet Dummy-Flow-File fÅr alle ein oder aus,
               ohne /F gelten Werte aus ECU.CFG
   07.03.1992  1.08f: Dummy-PKT komprimieren
   03.11.1991  Arced Crashmail
   03.11.1991  ~ in Areanamen
   28.10.1991  received flag exportieren
   13.10.1991  IncludeText
   12.10.1991  Signature
   08.10.1991  Tick-Zeilen nur in Tick-Msgs Åberspringen
   06.10.1991  kein Host fÅr NoOutput-Areas erforderlich
   28.09.1991  unterschiedliche Arcer fÅr verschiedene Hosts
   19.09.1991  cookies and random origins
   17.08.1991  4d originationg address in crash mail
   20.06.1991  append 0 to message, just in case someone (Hatch&Stick?)
               didn't count it [export.c]
   09.06.1991  ForceIntl
   06.05.1991  abort if ALT pressed on startup
   01.05.1991  3dMsgId now works
   07.04.1991  starting 1.06 (with 1.05 tearline)
   24.03.1991  assume that only GEMDOS version 0.19 handles the archive
               flag badly. That should help to solve some problems with
               TTs (hmmm, there are no problems with TTs)
   08.03.1991  disable crunch if quickscan is used
   25.02.1991  -Q (QuickScan)
   19.02.1991  write statistic record only if header has been
               written, or dupes have been detected
   10.02.1991  WriteStatistics()
   29.11.1990  some functions moved to MISC.C
   17.09.1990  optionally don't show errors in dialog box
   --------------------------------------------------------------------
   Usage:
      ECU   [-]?                    display help
      ECU   [options...] [config]   normal call
   --------------------------------------------------------------------
   Exit Codes
      0     ok, no error
      1     resource file not loaded (shouldn't happen)
      2     usage selected
      3     non-fatal error aborted by user
      4     config file not found
      5     out of heap space
      6     inconsitencies in config file detected
      7     any fatal system error
      8     ALT abort
   -------------------------------------------------------------------- */



/* --------------
      Includes
   -------------- */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>

#if defined (__TOS__)
   #include <ext.h>
   #include <tos.h>
#else
   #include <dir.h>
   #include <time.h>
#endif

#include "defines.h"

#include "version.h"
#include "global.h"
#include "ecudef.h"


/* ---------------
      Variables
   --------------- */

char  szProgramId[]  = "ECU";
char  ProgramPrefix  = 'E';
BOOL  NewTos;



/* ---------------------------------------------------------------------
      ReadExtArgs

      the seconf path through the command tail. Most arguments are
      processed after the config file hase been read. So options
      may override parameters from the config file.

      Input:
         argc  number of arguments
         argv  address of argument pointer table
   --------------------------------------------------------------------- */
void  ReadExtArgs(int argc, char **argv)
{
   while (--argc)
   {
      ++argv;
      if ((*argv)[0] == '-' || (*argv)[0] == '/')
      {
         switch (tolower((*argv)[1]))
         {
            case '?':
               break;

            case 'c':
               SetFlag(&Crunch, *argv, FALSE);
               Compress = Crunch;
               if (Crunch) QuickScan = FALSE;
               break;

            case 'd':
               SetFlag(&KillDupes, *argv, TRUE);
               break;

            case 'f':
#pragma warn -sus
               SetFlag (&CreateDummyCmd, *argv, TRUE);
#pragma warn .sus
               break;

            case 'l':
               strcpy(szLogfile, (*argv)[2] ? (*argv + 2) : "");
               break;

            case 'm':
               LogLevel = (*argv)[2] ? atoi(*argv + 2) : INT_MAX;
               break;

            case 'p':
               SetFlag(&PackAreas, *argv, TRUE);
               break;

            case 'q':
               SetFlag(&QuickScan, *argv, TRUE);
               if (QuickScan) Compress = Crunch = FALSE;
               break;

            default:
               ShowError(*argv, "illegal argument");
               break;
         }
      }
   }
}



/* --------------------------------------------------------------------
   WriteStatistic
   -------------------------------------------------------------------- */
void WriteStatistic (AREAPARAM *pArea) {

    static BOOL header_written = FALSE;
    char line[128];

    if (pArea->NewHeader || pArea->Dupes) {
        if (! header_written) {
            header_written = TRUE;
            WriteLogfile ("    Areaname       In  Out Sent  Old Dups  Del");
            WriteLogfile ("==============================================");
        }
        
        sprintf (line, "%-16.16s %4d %4d %4d %4d %4d %4d",
                 pArea->pLocalName,
                 pArea->ReadHeaders,
                 pArea->WrittenHeaders,
                 pArea->SentMails,
                 pArea->OldMails,
                 pArea->Dupes,
                 pArea->DeletedMails);
        WriteLogfile(line);
    }
}



/* --------------------------------------------------------------------
      main
   -------------------------------------------------------------------- */
void  main(int argc, char **argv)
{
   AREAPARAM   *pArea;

   SetVersion("ECU/ST", update, release, revision, suffix);
   #if defined(__TOS__)
      NewTos = (Sversion() != 0x1300);
   #else
      NewTos = TRUE;
   #endif

   atexit(FinishAll);

                              /* --------------------------------------
                                 Program inits - current drive and di-
                                 rectory, program arguments, reading
                                 config-files
                                 -------------------------------------- */
   getcwd(szHomeDir, (int) sizeof (szHomeDir));
   ReadStdArgs(argc, argv);
   ReadConfig();
   ReadExtArgs(argc, argv);
   if (!AchmedMode) ReadTbConfigs();
   VerifyParams();
   if (AchmedMode)
      /* ReadAchmedNew() */;
   else {
      ReadLedNew();
      qbbsReadLastRead();
   }
   OpenLogfile();

                              /* --------------------------------------
                                 Export and Crunch
                                 removes old and deleted messages from
                                 all areas, creates pakets.
                                 -------------------------------------- */
   lFreeId = time(NULL) << 8;
   for (pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext)
   {
      ExportArea (pArea);
      WriteStatistic (pArea);
   }

                              /* --------------------------------------
                                 Finish - appends EOF records to pakets
                                 creates arcmail etc.
                                 -------------------------------------- */
   if (AppendTB) AppendTbFlow();
   ClosePackets();
   UpdateFiles();
   if (!AchmedMode) qbbsSaveLastRead();
   WriteLogMessage();
   if (AchmedMode)
      /* WriteAchmedNew */;
   else
      WriteLedNew();

   exit(0);
}
