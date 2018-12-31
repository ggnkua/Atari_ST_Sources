/* --------------------------------------------------------------------
   Module:     LLEGADA.C
   Subject:    Fido Import Utility
   Author:     ho
   Started:    16.12.1990  23:46:16
   --------------------------------------------------------------------
   94-04-03ps  NoWait & -w entfernt
   93-07-29ps  Support fÅr Achmed
   92-10-17ps  GEM-AbhÑngigkeiten entfernt
   92-06-18ps  Suffix bei SetVersion
   --------------------------------------------------------------------
   29.03.1992  Llegada 1.04 released
   27.02.1992  KeepArea ist Area-Parameter
   03.11.1991  ~ in Areanamen
   12.10.1991  Lharc/Lha, Default-Entpacker
   28.09.1991  WhichArc
   19.09.1991  don't count messages to SYSOP in SysopMessages
   19.07.1991  prepare for LED 1.1 (Sysop flags)
   25.05.1991  prefix logfile messages with '=' so that LED finds them
   06.05.1991  Abort if ALT pressed on startup
   01.05.1991  remove CR/LF at end of area line, if AREA: is stripped
               wrong path to delete ArcMail if Llegada runs in Netf
               directory
               optionally delete ArcMail even if unpack failed
   22.04.1991  allow messages bigger than buffer
               optionally keep area line
   14.04.1991  started Llegada 1.01
   29.11.1990  some functions moved to MISC.C
   --------------------------------------------------------------------
   Usage:
      LLEGADA  [-]?                    display help
      LLEGADA  [options...] [config]   normal call
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

#include "defines.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>

#if defined(__TOS__)
   #include <ext.h>
   #include <tos.h>
#else
   #include <dir.h>
#endif

#include "version.h"
#include "global.h"
#include "llegadef.h"


/* ---------------
      Variables
   --------------- */

char  szProgramId[]  = "IMP";
char  ProgramPrefix  = 'I';



/* ---------------------------------------------------------------------
      ReadExtArgs

      the seconf pass through the command tail. Most arguments are
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

            case 'd':
               SetFlag(&KillDupes, *argv, TRUE);
               break;

            case 'l':
               strcpy(szLogfile, (*argv)[2] ? (*argv + 2) : "");
               break;

            case 'm':
               LogLevel = (*argv)[2] ? atoi(*argv + 2) : INT_MAX;
               break;

            default:
               ShowError(*argv, "illegal argument");
               break;
         }
      }
   }
}



/* --------------------------------------------------------------------
      main
   -------------------------------------------------------------------- */
void  main(int argc, char **argv)
{
   SetVersion("LLEGADA/ST", update, release, revision, suffix);
   atexit (FinishAll);

                              /* --------------------------------------
                                 Program inits - current drive and di-
                                 rectory, program arguments, reading
                                 config-files
                                 -------------------------------------- */
   getcwd (szHomeDir, (int) sizeof (szHomeDir));
   ReadStdArgs(argc, argv);
   ReadConfig();
   ReadExtArgs(argc, argv);
   if (!AchmedMode) ReadTbConfigs();
   VerifyParams();
   if (AchmedMode)
      ReadAchmedNew();
   else
      ReadLedNew();
   OpenLogfile();
   if (szRules[0]) ReadRules(szRules);

   UnpackArchives();
   UnpackMail();
   WriteStatistics();
   WriteLogMessage();
   if (AchmedMode)
      WriteAchmedNew();
   else
      WriteLedNew();

   exit(0);
}
