/* --------------------------------------------------------------------
   Modul:      VAR.C
   Subject:    Global variables for ECU and LLEGADA
   Author:     ho
   Started:    27.01.1991  10:24:26
   --------------------------------------------------------------------
   94-04-03ps  HoldScreen
               NoWait entfernt
   93-12-20ps  HostPrefix
   93-08-01ps  pReply entfernt
   93-07-29ps  Support fÅr Achmed
   92-11-08ps  MsgLink
   92-10-17ps  GEM-AbhÑngigkeiten entfernt
   --------------------------------------------------------------------
   23.03.1992  LastReadQBBS
   14.03.1992  CreateDummyCmd
   27.02.1992  CreateDummyFlo int statt BOOL
   06.02.1992  CrashToPoints
   05.01.1992  Domain
   08.12.1991  RestoreTosScreen (NoRestore)
   10.11.1991  pLimits nicht mehr global
   03.11.1991  Arced Crashmail
   28.09.1991  WhichArc
   19.09.1991  NewAreaDirectory
   18.09.1991  Cookies and Origins
   01.05.1991  GoodUnpackReturn
   07.04.1991  UseZones
   05.04.1991  CreateTB
   -------------------------------------------------------------------- */



#include <stddef.h>
#include <stdio.h>

#include "global.h"



char     szTearline[32];
char     szVersion[32];
char     *pConfigFile       = "ECU.CFG";
char     AddressPrefix      = '@';
char     FormatPrefix       = '.';
char     HostPrefix[]       = "[]";
char     TickPrefix         = '\'';
char     TickIndicator      = '\'';

HOSTPARAM *pFirstHost        = NULL;
AREAPARAM *pFirstArea        = NULL;
AREAPARAM *pNetmailArea      = NULL;
AREAPARAM *pCommArea         = NULL;
AREAPARAM *pBadMsgArea       = NULL;
ALIAS     *pAliasList        = NULL;
SYSOPNAME *pSysopName        = NULL;
DOMAIN    *pDomainList       = NULL;
long      lFreeId;
int       CreateDummyFlo     = 0;
int       CreateDummyCmd     = -1;
      /*  0:   kein Dummy-Flowfile
          1:   nur Flow-File
          2:   Flow-File und Dummy-Paket
         -1:   nicht definiert (CreateDummyCmd)
       */

BOOL     DeletePkt         = FALSE;
BOOL     Compress          = FALSE;
BOOL     Crunch            = TRUE;
BOOL     AppendTB          = FALSE;
BOOL     KillDupes         = FALSE;
BOOL     StoreCrc          = FALSE;
BOOL     UseAreas          = FALSE;
BOOL     RouteEchos        = FALSE;
BOOL     WriteHeader       = FALSE;
BOOL     PackAreas         = FALSE;
BOOL     QuickScan         = FALSE;
BOOL     UseZones          = FALSE;
BOOL     ForceIntl         = FALSE;
BOOL     ArcedCrashMail    = FALSE;
BOOL     CrashPoints       = FALSE;
BOOL     MsgLink           = FALSE;
BOOL     AchmedMode        = FALSE;
BOOL     HoldScreen        = FALSE;
WORD     ExportFlags       = MF_LOCAL;

int      LogLevel          = 1;
int      CreateTB          = FFF_BINKLEY;
unsigned GoodUnpackReturn  = 0;
int      DefaultZone       = DEFAULT_ZONE;
FILE     *fpLogfile        = NULL;

char  szHomeDir[FILENAME_MAX]       = "";
char  szNewAreaDir[FILENAME_MAX]    = "";
char  szLastRead[FILENAME_MAX]      = "";
char  szLastReadQBBS[FILENAME_MAX]  = "";
char  szLedNew[FILENAME_MAX]        = "";
char  szAchmedNew[FILENAME_MAX]     = "ACHMED.NEW";
char  szAreasBBS[FILENAME_MAX]      = "AREAS.BBS";
char  szAreaSize[FILENAME_MAX]      = "";
char  szOutbound[FILENAME_MAX]      = "OUTBOUND\\";
char  szInbound[FILENAME_MAX]       = "NETF\\";
char  szDefaultIn[FILENAME_MAX]     = "arc.ttp x %n %d*.*";
char  szArcIn[FILENAME_MAX]         = "arc.ttp x %n %d*.*";
char  szArjIn[FILENAME_MAX]         = "%..\\unarj.ttp %p";
char  szLhaIn[FILENAME_MAX]         = "lharc.ttp x -m %n %d";
char  szLharcIn[FILENAME_MAX]       = "lha.ttp x -m %n %d";
char  szZipIn[FILENAME_MAX]         = "zip.ttp -x %d %n";
char  szZooIn[FILENAME_MAX]         = "%..\\zoo.ttp x %p";
char  szArcOut[FILENAME_MAX]        = "arc.ttp m ";
char  szLogfile[FILENAME_MAX]       = "BT.LOG";
char  szSignature[FILENAME_MAX]     = "";
char  szRules[FILENAME_MAX]         = "";
char  *CrcFormat                    = "%.8lx";

COOKIE   Origins               = { 0 };
COOKIE   Cookies               = { 0 };

/*    #  fatal error
      %  bad error, operation aborted
      !  light error, ignored
 */
char  szOutOfMemory[]      = "# out of heap space";
char  szBadNodeAddress[]   = "% bad node address";
char  szBadNumber[]        = "! illegal character in number";
char  szMissingArgument[]  = "% statement requires an argument";
char  szReadError[]        = "% disk read error";
char  szWriteError[]       = "% disk write error";

