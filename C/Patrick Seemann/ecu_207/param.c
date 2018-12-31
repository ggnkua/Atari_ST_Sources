/* --------------------------------------------------------------------
   Modul:      PARAM.C
   Subject:    Parameter and configuration file processing
               for ECU and LLEGADA
   Author:     ho
   Started:    08.08.1990  10:24:26
   --------------------------------------------------------------------
   94-04-03ps  HoldScreen,
               NoWait entfernt
   93-12-20ps  HostPrefix
   92-11-08ps  MsgLink
   92-10-18ps  2+Pakete, Username
               Unterscheidung zwischen lokalen und Fido-Areanamen
   92-10-17ps  GEM-AbhÑngigkeiten entfernt
   --------------------------------------------------------------------
   03.05.1992  ExportFlags
               Flags aus CENSOR.C nach PARAM.C
   23.03.1992  LastReadQBBS
   07.03.1992  DummyFLO 0..3
   06.02.1992  CrashToPoints
   15.01.1992  4dEchomail
   05.01.1992  domain in Get[4d]Address lîschen, wenn im Alias keine
               Domain definiert ist.
               DOMAIN
   08.12.1991  NoRestore
   28.11.1991  GetAddress, Get4dAddress: zusÑtzlicher Parameter fÅr
               Domainname, DomainunterstÅtzung allgemein
   27.11.1991  neu in AREAS.BBS: -CRUNCH, -FLAGS, -PASSWD, -SIGNATURE
               dayslocal in -DAYS
   16.11.1991  -ORIGIN -RANDOM in AREAS.BBS
   10.11.1991  MatchHost nach EXPORT.C verlegt
               pLimits nicht mehr global
   09.11.1991  MatchMin
   03.11.1991  Arced Crashmail
   03.11.1991  ~ in internen Areanamen in Blanks Åbersetzen
   02.11.1991  IOS-Flow-Files
   13.10.1991  interne énderungen (wordArg, longArg, nameArg)
   12.10.1991  Signature, LharcUnpack
   06.10.1991  kein Host fÅr NoOutput-Areas erforderlich
   28.09.1991  unterschiedliche Arcer fÅr verschiedene Hosts
               WhatArc
   19.09.1991  NewAreaDirectory
   18.09.1991  Cookies and Origins
   09.06.1991  ForceIntl
   04.05.1991  HighLimit
   01.05.1991  GoodUnpackReturn
   07.04.1991  CreateTB, UseZones, DefaultZone
   08.03.1991  QuickScan overrides Crunch
   25.02.1991  QuickScan
   17.02.1991  BadMsgArea, LogMsgArea
   05.02.1991  3dTickAddress
   29.01.1991  commands fpr tickfile handling
   27.01.1991  LLEGADA and ECU merged again
   20.01.1991  3dEchomail/3dNetmail
   13.01.1991  ArcMailName
   03.01.1991  INT_MAX instead of UINT_MAX as default deadline
               MatchHost modified
   18.12.1990  RouteEchos
   16.12.1990  command list moved to separate module
   16.12.1990  GetString now takes care of training spaces
   12.12.1990  NoNetmail
   03.12.1990  UseAreas
   02.12.1990  AddressPrefix
   06.11.1990  NoOutput in host definition
   04.11.1990  commandline switch to create flowfile dummy
   24.10.1990  new crunch options
   21.10.1990  Switch to append TB-flow files to BT-flow files
   30.09.1990  Logfile, LogLevel
   29.09.1990  NoOutput, Compress
   17.09.1990  new config file entrys: SoftReturns, NoWait
   --------------------------------------------------------------------
   Requirements

   To update LED's lastread pointers properly, the first entry in
   AREAS.BBS must be for the FidoNetmail area. This does not apply
   if LED 1.00 or later is used, where lastread pointers are stored
   in LED.NEW together with the areaname.
   -------------------------------------------------------------------- */



/* --------------
      Includes
   -------------- */

#include "clib.h"

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <errno.h>

#if defined(__TOS__)
   #include <ext.h>
#else
   #include <io.h>
   #include <fcntl.h>
   #include <dir.h>
#endif

#include "global.h"



/* -------------
      Defines
   ------------- */

#define  MAX_LINELENGTH    256
#define  max(x, y) (((x) > (y)) ? (x) : (y))



/* ---------------
      Variables
   --------------- */

static AREAPARAM AreaDefault;
static char szDefaultOrigin[] = "This line is not empty";
static char *pLimits = "\t ";


/* --------------------------------------------------------------------
   Flags
   -------------------------------------------------------------------- */
WORD Flags(char *p)
{
   int   i;
   
   static char *name[] =
      {
         "private",        /*  0 */
         "crash",          /*  1 */
         "received",       /*  2 */
         "sent",           /*  3 */
         "withfile",       /*  4 */
         "forward",        /*  5 */
         "orphen",         /*  6 */
         "killifsent",     /*  7 */
         "local",          /*  8 */
         "hold",           /*  9 */
         "signature",      /* 10 */
         NULL,             /* 11 */
         NULL,             /* 12 */
         NULL,             /* 13 */
         NULL,             /* 14 */
         "deleted",        /* 15 */
         NULL,             /* 16, saves another test */
      };

   p += strspn(p, pLimits);
   for (i = 0; i < 16 && (name[i] == NULL || stricmp(p, name[i])); i++);
   return (name[i] == NULL) ? 0 : (1 << i);
}



/* ---------------------------------------------------------------------
      FindHost
   --------------------------------------------------------------------- */
HOSTPARAM   *FindHost(unsigned zone, unsigned net, unsigned node)
{
   HOSTPARAM *p;

   p = pFirstHost;
   while (p != NULL && (p->BossZone != zone ||
                        p->BossNet  != net  ||
                        p->BossNode != node))
   {
      p = p->pNext;
   }

   return p;
}



/* ---------------------------------------------------------------------
      FindFidoArea
   --------------------------------------------------------------------- */
AREAPARAM   *FindFidoArea(char *pName)
{
   AREAPARAM *p;
   char *q;

   for (q = pName; *q; ++q) if (*q == '~') *q = ' ';

   p = pFirstArea;
   while (p != NULL && stricmp(p->pAreaname, pName))
   {
      p = p->pNext;
   }

   return p;
}



/* ---------------------------------------------------------------------
      FindLocalArea
   --------------------------------------------------------------------- */
AREAPARAM   *FindLocalArea(char *pName)
{
   AREAPARAM *p;
   char *q;

   for (q = pName; *q; ++q) if (*q == '~') *q = ' ';

   p = pFirstArea;
   while (p != NULL && stricmp(p->pLocalName, pName))
   {
      p = p->pNext;
   }

   return p;
}



/* ---------------------------------------------------------------------
      FindAlias
   --------------------------------------------------------------------- */
ALIAS *FindAlias(char *name)
{
   ALIAS *pAlias;

   pAlias = pAliasList;
   while (pAlias != NULL && stricmp(pAlias->szAlias, name) != 0)
   {
      pAlias = pAlias->pNext;
   }

   return pAlias;
}



/* --------------------------------------------------------------------
   FindDomain
   -------------------------------------------------------------------- */
DOMAIN *FindDomain(int zone)
{
   DOMAIN *p = pDomainList;
   while (p != NULL && p->zone != zone) p = p->pNext;
   return p;
}



/* ---------------------------------------------------------------------
      GetString
   --------------------------------------------------------------------- */
char  *GetString(char *s, int len)
{
   int   n;
   char  *p;

   n = (int) strlen(s) + 1;
   if (n > len) return NULL;

   s += n;
   while (isspace(*s)) s++;
   p = s + strlen(s) - 1;
   while (p >= s && isspace(*p)) p--;
   *(p + 1) = '\0';

   return s;
}



/* ---------------------------------------------------------------------
      GetAddress

      parses a string to extract the components of a fido address.

      Input:
         s        string to parse
         zone     variable for zone
         net      variable for net
         node     variable for nodenumber
         domain   buffer for domain name

      Returns:
         TRUE     iff legal node address found
   --------------------------------------------------------------------- */
BOOL  GetAddress(char *s, WORD *zone, WORD *net, WORD *node, char *domain)
{
   ALIAS *pAlias;
   WORD  x;

   *zone = *net = *node = 0;

   if (s == NULL) return FALSE;

   pAlias = FindAlias(s);
   if (pAlias != NULL)
   {
      *zone = pAlias->Zone;
      *node = pAlias->Node;
      *net  = pAlias->Net;
      if (domain != NULL)
         if (pAlias->pDomain != NULL)
            strcpy(domain, pAlias->pDomain);
         else
            *domain = 0;
      return TRUE;
   }

   x = 0;
   while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   if (*s == ':')
   {
      *zone = x;
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   }
   if (*s == '/')
   {
      *net = x;
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   }
   *node = x;
   if (*s == '@')
   {
      while (*(++s) && (*s == ' ' || *s == '\t'));
      if (domain != NULL)
      {
         while (*s && *s != ' ' && *s != '\t')
            *domain++ = *s++;
         *domain++ = '\0';
      }
   }
   else
      if (domain != NULL) *domain = '\0';

   if (*zone == 0) *zone = DefaultZone;

   return *s == 0 && *net != 0;
}



/* --------------------------------------------------------------------
      Get4dAddress

      parses a string representing a 4D address.

      Input:
      ------
      char *s
         address of string to parse. format is
            [[zone]:][[net]/][node][.[point]]

      WORD *zone, *net, *node, *point
         pointers to variables to hold components of address. Variables
         may be set to initial values. A non-zero value for any component
         of the address, however, sets default values of all following
         components to 0.

      char *domain
         Puffer fÅr Domainname. Der Name wird nicht kopiert, wenn NULL
         als Adresse angegeben wird.
   -------------------------------------------------------------------- */
void  Get4dAddress(char *s,
                   WORD *zone, WORD *net, WORD *node, WORD *point,
                   char *domain)
{
   ALIAS *pAlias;
   WORD  x;

   pAlias = FindAlias(s);
   if (pAlias != NULL)
   {
      *zone  = pAlias->Zone;
      *node  = pAlias->Node;
      *net   = pAlias->Net;
      *point = pAlias->Point;
      if (domain != NULL)
         if (pAlias->pDomain != NULL)
            strcpy(domain, pAlias->pDomain);
         else
            *domain = 0;
      return;
   }

                              /* --------------------------------------
                                 get first number
                                 -------------------------------------- */
   x = 0;
   while (isdigit(*s)) x = 10 * x + (*s++ - '0');

                              /* --------------------------------------
                                 zone (if next character is a colon)
                                 If zone is non-zero, defaults for net,
                                 node and point are cleared. If zone is
                                 0, its default value will be used.
                                 -------------------------------------- */
   if (*s == ':')
   {
      if (x)
      {
         *net = *node = *point = 0;
         *zone = x;
      }
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   }

                              /* --------------------------------------
                                 net (if next character is a slash)
                                 If net is non-zero, defaults for node
                                 and point are cleared. If zone is 0,
                                 its default value will be used.
                                 -------------------------------------- */
   if (*s == '/')
   {
      if (x)
      {
         *node = *point = 0;
         *net = x;
      }
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
   }

                              /* --------------------------------------
                                 node
                                 If node is non-zero, default for point
                                 is cleared. If node is 0, its default
                                 value will be used.
                                 -------------------------------------- */
   if (x)
   {
      *point = 0;
      *node = x;
   }

                              /* --------------------------------------
                                 point (starts with a period)
                                 -------------------------------------- */

   if (*s == '.')
   {
      x = 0;
      s++;
      while (isdigit(*s)) x = 10 * x + (*s++ - '0');
      *point = x;
   }

   if (*s == '@')
   {
      while (*(++s) && (*s == ' ' || *s == '\t'));
      if (domain != NULL)
      {
         while (*s && *s != ' ' && *s != '\t')
            *domain++ = *s++;
         *domain++ = '\0';
      }
   }
   else
      if (domain != NULL) *domain = '\0';

   if (*zone == 0) *zone = DefaultZone;
}



/* ---------------------------------------------------------------------
      TestHost
   --------------------------------------------------------------------- */
BOOL  TestHost(HOSTPARAM *pHost)
{
   char  szHost[32];
   BOOL  ok;

   ok = TRUE;
   sprintf(szHost, "%d:%d/%d", pHost->BossZone, pHost->BossNet,
                               pHost->BossNode);

   if (pHost->FakeZone == 0 && pHost->Point == 0)
   {
      ShowError(szHost, "no point address specified");
      ok = FALSE;
   }
   if ((pHost->OldOrigin || pHost->OldMsgId || pHost->OldPath ||
        pHost->OldSeenBy || pHost->OldAddress) && pHost->FakeZone == 0)
   {
      ShowError(szHost, "3d-address required");
      ok = FALSE;
   }
   if ((!pHost->OldOrigin || !pHost->OldMsgId || !pHost->OldPath ||
        !pHost->OldSeenBy || !pHost->OldAddress) && pHost->Point == 0)
   {
      ShowError(szHost, "point-id required");
      pHost->Point = pHost->FakeNode;
   }

   return ok;
}



/* ---------------------------------------------------------------------
      TestArea
   --------------------------------------------------------------------- */
BOOL  TestArea(AREAPARAM *pArea)
{
   char        szHost[32];
   BOOL        ok;

   ok = TRUE;
   sprintf(szHost, "%d:%d/%d", pArea->HostZone, pArea->HostNet,
                               pArea->HostNode);

   if (pArea->DaysLocal == INT_MAX) pArea->DaysLocal = pArea->Days;
   if (pArea->pAreaname == NULL) pArea->pAreaname = pArea->pLocalName;
   if (pArea->pAreaname == NULL)
   {
      ShowError("TestArea", "no areaname specified");
      ok = FALSE;
   }
   if (pArea->pLocalName == NULL) pArea->pLocalName = pArea->pAreaname;
   if (pArea->pFilename == NULL)
   {
      ShowError(pArea->pLocalName, "no filename specified");
      ok = FALSE;
   }
   pArea->pHost = FindHost(pArea->HostZone, pArea->HostNet, pArea->HostNode);
   if (pArea->pHost == NULL)
   {
      if (pArea->NoOutput)
      {
         if (pArea->pOrigin == NULL) pArea->pOrigin = szDefaultOrigin;
         pArea->pHost = pFirstHost;
      }
      else
      {
         ShowError(szHost, "undefined host");
         ok = FALSE;
      }
   }
   else
   {
      if (pArea->pSignature == NULL)
      {
         pArea->pSignature = pArea->pHost->pSignature;
      }
      if (pArea->pHost->NoOutput) pArea->NoOutput = TRUE;
      if (pArea->pOrigin == NULL) pArea->pOrigin = pArea->pHost->pOrigin;
      if (pArea->pOrigin == NULL && (pArea->Type & AT_ECHOMAIL))
      {
         ShowError(pArea->pLocalName, "no origin specified");
         ok = FALSE;
      }
   }
   if (pArea->pSignature == NULL) pArea->pSignature = &szSignature[0];
   if (pArea->pSignature[0])
   {
      int fd;
      fd = open(pArea->pSignature, O_RDONLY);
      if (fd != -1)
      {
         pArea->SignatureLength = max(filelength(fd), 0);
         close(fd);
      }
      else
      {
         ShowError(pArea->pSignature, strerror(errno));
      }
   }

   return ok;
}



/* ---------------------------------------------------------------------
      ReadStdArgs

      is the first path through the command tail. It is called before
      the configuration file is parsed. The main purpose of this func-
      tion is determining the configuration file.

      Input:
         argc  number of arguments
         argv  address of argument pointer table
   --------------------------------------------------------------------- */
void  ReadStdArgs(int argc, char **argv)
{
   while (--argc)
   {
      ++argv;
      if ((*argv)[0] == '/' || (*argv)[0] == '-')
      {
         switch (tolower((*argv)[1]))
         {
            case '?':
               usage();
               exit(2);
         }
      }
      else
      {
         if ((*argv)[0] == '?' && (*argv)[1] == '\0')
         {
            usage();
            exit(2);
         }
         pConfigFile = *argv;
      }
   }
}



/* ---------------------------------------------------------------------
      SetFlag
   --------------------------------------------------------------------- */
void  SetFlag(BOOL *flag, char *option, BOOL dfault)
{
   switch (tolower(option[2]))
   {
      case '\0':
         *flag = dfault;
         break;

      case '0':
      case 'n':
         *flag = FALSE;
         break;

      case '1':
      case 'y':
         *flag = TRUE;
         break;

      case 't':
         *flag = !*flag;
         break;

      default:
         ShowError(option, "bad option parameter");
         break;
   }
}



/* ---------------------------------------------------------------------
      AllocateArea
   --------------------------------------------------------------------- */
AREAPARAM *AllocateArea(char *pArg)
{
   AREAPARAM *pArea;

   pArea = calloc(1, sizeof(*pArea));
   if (pArea == NULL) return NULL;

   *pArea = AreaDefault;
   pArea->pNext = pFirstArea;
   pArea->Type  = AT_ECHOMAIL;
   if (pArea->DaysLocal == 0) pArea->DaysLocal = INT_MAX;
   if (pArea->Days      == 0) pArea->Days      = INT_MAX;
   pArea->pLocalName = strdup(pArg);
   if (pArea->pLocalName == NULL)
   {
      free(pArea);
      return NULL;
   }
   pFirstArea = pArea;

   return pArea;
}


WORD wordArg(void)
      /* --------------------------------------------------------------
         liefert den Wert des nÑchsten Wortes in der Zeile als WORD,
         0, wenn kein Parameter mehr vorhanden ist. Fehler werden ange-
         zeigt, wenn kein Argument vorhanden ist, oder wenn das Argu-
         ment nicht nur aus Ziffer besteht. In diesem Fall wird der
         Wert der initialen Ziffernfolge als Ergebnis geliefert.
         -------------------------------------------------------------- */
{
   WORD  val;
   char  *p;

   p = strtok(NULL, pLimits);
   if (p == NULL)
   {
      ShowError(p, szMissingArgument);
      return 0;
   }
   val = 0;
   while (isdigit(*p)) val = 10 * val + (*p++ - '0');
   if (*p)
   {
      ShowError(p, szBadNumber);
   }

   return val;
}



LONG longArg(void)
      /* --------------------------------------------------------------
         liefert den Wert des nÑchsten Wortes in der Zeile als LONG,
         sonst wie wordArg()
         -------------------------------------------------------------- */
{
   LONG  val;
   char  *p;

   p = strtok(NULL, pLimits);
   if (p == NULL)
   {
      ShowError(p, szMissingArgument);
      return 0;
   }
   val = 0;
   while (isdigit(*p)) val = 10 * val + (*p++ - '0');
   if (*p)
   {
      ShowError(p, szBadNumber);
   }

   return val;
}



char *nameArg(char **pArg, BOOL toUpper)
      /* --------------------------------------------------------------
         liefert ein Duplikat des nÑchsten Wortes in der Zeile im Para-
         meter *pArg. Wenn *pArg beim Aufruf nicht NULL ist, nimmt
         nameArg an, da· es sich um mit malloc() o.Ñ. belegten Speicher
         handelt, und gibt diesen frei. Wenn beim Duplizieren des
         Strings kein Platz mehr ist, wird das Programm abgebrochen.

         toUpper gibt an, ob der String in Gro·buchstaben umgewandelt
         werden soll (toUpper != 0) oder nicht (toUpper == 0)
         -------------------------------------------------------------- */
{
   char *p;

   p = strtok(NULL, pLimits);
   if (p != NULL)
   {
      p = strdup(p);
      if (p == NULL)
      {
         ShowError("strdup", szOutOfMemory);
         exit(5);
      }
      if (toUpper) p = strupr(p);
   }
   if (*pArg != NULL) free(*pArg);

   return *pArg = p;
}




/* ---------------------------------------------------------------------
      ReadConfig

      reads the configuration file
   --------------------------------------------------------------------- */
void  ReadConfig(void)
{
   HOSTPARAM   *pHost;
   AREAPARAM   *pArea;
   FILE        *fp;
   char        *pArg;
   CMDLIST     *pCmd;
   char        line[MAX_LINELENGTH];
   int         LineNo;
   int         LineLength;
   unsigned    status;
   BOOL        FirstDefault;
   BOOL        FlagValue;
   BOOL        FirstMatrixArea;
   BOOL        EmptyLine;

   FirstDefault = TRUE;
   FirstMatrixArea = TRUE;
   pNetmailArea = NULL;

   fp = fopen(pConfigFile, "r");
   if (fp == NULL)
   {
      ShowError(pConfigFile, strerror(errno));
      exit(4);
   }

   LineNo    = 0;
   status    = CMS_NONE;

   while (ReadLine(line, MAX_LINELENGTH, fp))
   {
      LineNo++;
      LineLength = (int) strlen(line);
      FlagValue = TRUE;
      pArg = strtok(line, pLimits);

      EmptyLine = TRUE;
      do
      {
         if (pArg == NULL) break;
         if (*pArg == ';') break;

         if (*pArg == 0)
         {
            pArg = strtok(NULL, pLimits);
            continue;
         }

         if (pArg[1] == ':')
         {
            if (toupper(pArg[0]) != ProgramPrefix) break;
            pArg += 2;
         }

         if (*pArg == '!')
         {
            ++pArg;
            FlagValue = !FlagValue;
            continue;
         }

         EmptyLine = FALSE;
      }
      while (EmptyLine);
      if (EmptyLine) continue;

      for (pCmd = CmdList; pCmd->type && stricmp(pArg, pCmd->text); pCmd++);

      if (!(pCmd->type & status))
      {
         char *p;
         p = pArg + strlen(pArg) + 1;
         sprintf(p, "%d: %s", LineNo, pArg);
         ShowError(p, (pCmd->type == 0)
                      ? "unknown command"
                      : "illegal statement in current mode");
      }
      else
      {
         switch (pCmd->type)
         {
            case CMD_HOST:    /* Host zone:net/node */
               {
                  WORD zone;
                  WORD net;
                  WORD node;
                  char domain[MAX_LINELENGTH];

                  pArg = strtok(NULL, pLimits);
                  if (!GetAddress(pArg, &zone, &net, &node, domain))
                  {
                     ShowError(pArg, szBadNodeAddress);
                     break;
                  }
                  pHost = FindHost(zone, net, node);
                  if (pHost != NULL)
                  {
                     ShowError(pArg, "host already defined");
                     break;
                  }
                  pHost = calloc(1, sizeof(*pHost));
                  if (pHost == NULL)
                  {
                     ShowError("calloc", szOutOfMemory);
                     exit(5);
                  }
                  pHost->pNext     = pFirstHost;
                  pHost->BossZone  = zone;
                  pHost->BossNet   = net;
                  pHost->BossNode  = node;
                  if (*domain)
                  {
                     pHost->pDomain   = strdup(domain);
                     if (pHost->pDomain == NULL)
                     {
                        ShowError(pArg, szOutOfMemory);
                        exit(5);
                     }
                  }
                  pFirstHost       = pHost;
                  status = CMS_HOST;
               }
               break;

            case CMD_DEFAULT:
               pArea = &AreaDefault;
               if (!FirstDefault)
               {
                  FirstDefault = FALSE;
                  memset(&AreaDefault, 0, sizeof(AreaDefault));
                  AreaDefault.DaysLocal = INT_MAX;
                  AreaDefault.Days      = INT_MAX;
               }
               status = CMS_AREA;
               break;

            case CMD_AREA:    /* Area   local_name */
            case CMD_MATRIX:  /* Matrix local_name */
               pArg  = GetString(pArg, LineLength - (pArg - line));
               pArea = FindLocalArea(pArg);
               if (pArea != NULL)
               {
                  ShowError(pArg, "area already defined");
                  break;
               }
               pArea = AllocateArea(pArg);
               if (pArea == NULL)
               {
                  ShowError("calloc", szOutOfMemory);
                  exit(5);
               }
               if (pCmd->type == CMD_MATRIX)
               {
                  pArea->Type = AT_NETMAIL;
                  if (pNetmailArea == NULL || FirstMatrixArea)
                  {
                     pNetmailArea = pArea;
                     FirstMatrixArea = FALSE;
                  }
               }
               else
               {
                  pArea->Type = AT_ECHOMAIL;
               }
               status = CMS_AREA;
               break;

            case CMD_END:
               status = CMS_NONE;
               break;

            case CMD_NODE:
               {
                  WORD zone;
                  WORD net;
                  WORD node;

                  pArg = strtok(NULL, pLimits);
                  if (!GetAddress(pArg, &zone, &net, &node, NULL))
                  {
                     ShowError(pArg, szBadNodeAddress);
                     break;
                  }
                  pHost->FakeZone   = zone;
                  pHost->FakeNet    = net;
                  pHost->FakeNode   = node;
               }
               break;

            case CMD_POINT:
               pHost->Point = wordArg();
               break;

            case CMD_STDPKT:
               pHost->HeaderType = HT_STANDARD;
               break;

            case CMD_FRODOPKT:
               pHost->HeaderType = HT_FRODO;
               break;

            case CMD_QMAILPKT:
               pHost->HeaderType = HT_QMAIL;
               break;

            case CMD_PRODID:
               pHost->ProductId = wordArg();
               break;

            case CMD_SERIAL:
               pHost->SerialNumber = longArg();
               break;

            case CMD_3DADDRESS:
               pHost->OldAddress = FlagValue;
               break;

            case CMD_3DECHOMAIL:
               pHost->OldEchomail = FlagValue;
               break;

            case CMD_3DNETMAIL:
               pHost->OldNetmail = FlagValue;
               break;

            case CMD_3DORIGIN:
               pHost->OldOrigin = FlagValue;
               break;

            case CMD_3DSEENBY:
               pHost->OldSeenBy = FlagValue;
               break;

            case CMD_3DPATH:
               pHost->OldPath   = FlagValue;
               break;

            case CMD_3DMSGID:
               pHost->OldMsgId  = FlagValue;
               break;

            case CMD_MSGLINK:
               MsgLink = FlagValue;
               break;
               
            case CMD_HOLDSCREEN:
               HoldScreen = FlagValue;
               break;
               
            case CMD_USEAREAS:
               UseAreas = FlagValue;
               break;

            case CMD_KILLLOCAL:
               pArea->KillLocal = FlagValue;
               break;

            case CMD_KILLHOLD:
               pArea->KillHold = FlagValue;
               break;

            case CMD_NONETMAIL:
               pArg = strtok(NULL, pLimits);
               pHost->MatchMinimum = (pArg != NULL)
                                     ? atoi(pArg)
                                     : FlagValue ? INT_MAX : 0;
               pHost->NoNetmail    = pHost->MatchMinimum == INT_MAX;
               break;

            case CMD_ORIGIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  pArg = strdup(pArg);
                  if (pArg == NULL)
                  {
                     ShowError("strdup", szOutOfMemory);
                     exit(5);
                  }
               }
               if (status == CMS_AREA)
               {
                  if (pArea->pOrigin != NULL) free(pArea->pOrigin);
                  pArea->pOrigin = pArg;
               }
               else if (status == CMS_HOST)
               {
                  if (pHost->pOrigin != NULL) free(pHost->pOrigin);
                  pHost->pOrigin = pArg;
               }
               else
               {
                  if (Origins.fp != NULL) CloseCookie(&Origins);
                  OpenCookie(pArg, &Origins);
                           /* -----------------------------------------
                              OpenCookie might return an error, but
                              either we should ignore it, or the pro-
                              gram has already been terminated, and
                              we never come here.
                              ----------------------------------------- */
                  free(pArg);
               }
               break;

            case CMD_ADRPREFIX:
               pArg = strtok(NULL, pLimits);
               AddressPrefix = (pArg == NULL) ? '@' : *pArg;
               break;

            case CMD_FMTPREFIX:
               pArg = strtok(NULL, pLimits);
               FormatPrefix = (pArg == NULL) ? '.' : *pArg;
               break;
            
            case CMD_HOSTPREFIX:
               pArg = strtok (NULL, pLimits);
               HostPrefix[0] = (pArg == NULL) ? '[' : *pArg;
               HostPrefix[1] = (pArg[1] == '\0') ? ']' : pArg[1];
               break;

            case CMD_TICKPREFIX:
               pArg = strtok(NULL, pLimits);
               TickPrefix = (pArg == NULL) ? '\'' : *pArg;
               break;

            case CMD_TICKINDICATOR:
               pArg = strtok(NULL, pLimits);
               TickIndicator = (pArg == NULL) ? '\'' : *pArg;
               break;

            case CMD_LOGFILE:
               pArg = strtok(NULL, pLimits);
               strcpy(szLogfile, (pArg == NULL) ? "" : pArg);
               break;

            case CMD_LOGLEVEL:
               LogLevel = wordArg();
               break;

            case CMD_AREANAME:
               nameArg(&pArea->pAreaname, TRUE);
               break;

            case CMD_FILENAME:
               nameArg(&pArea->pFilename, TRUE);
               break;

            case CMD_ARCMAIL:
               nameArg(&pHost->pArcMailName, TRUE);
               break;

            case CMD_PASSWORD:
               if (status == CMS_HOST)
                  nameArg (&pHost->pPassword, FALSE);
               else
                  nameArg(&pArea->pPassword, FALSE);
               break;
            
            case CMD_USERNAME:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  char *p;

                  p = malloc(strlen(pArg) + 1);
                  if (p == NULL)
                  {
                     ShowError("strdup", szOutOfMemory);
                     exit(5);
                  }
                  strcpy(p, pArg);
                  pArea->pUsername = p;
               }
               break;

            case CMD_BOSS:
               {
                  WORD zone;
                  WORD net;
                  WORD node;

                  pArg = strtok(NULL, pLimits);
                  if (!GetAddress(pArg, &zone, &net, &node, NULL))
                  {
                     ShowError(pArg, szBadNodeAddress);
                     break;
                  }
                  pArea->HostZone   = zone;
                  pArea->HostNet    = net;
                  pArea->HostNode   = node;
               }
               break;

            case CMD_NOCRUNCH:
               Crunch = !FlagValue;
               break;

            case CMD_CRUNCH:
               pArea->CrunchLimit = wordArg();
               break;

            case CMD_LOWLIMIT:
               pArea->LowMessageCount = wordArg();
               break;

            case CMD_DAYS:
               pArea->Days = wordArg();
               break;

            case CMD_LDAYS:
               pArea->DaysLocal = wordArg();
               pArea->KillLocal = TRUE;
               break;

            case CMD_NETMAIL:
               pArea->Type = AT_NETMAIL;
               if (pNetmailArea == NULL)
               {
                  pNetmailArea = pArea;
               }
               break;

            case CMD_TICKAREA:
               pArea->Type = AT_TICKAREA | AT_NETMAIL;
               break;

            case CMD_LASTREAD:
               pArg = strtok(NULL, pLimits);
               strcpy(szLastRead, pArg);
               break;

            case CMD_LASTREADQBBS:
               pArg = strtok(NULL, pLimits);
               strcpy(szLastReadQBBS, pArg);
               break;

            case CMD_ACHMED:
               AchmedMode = TRUE;
               break;
               
            case CMD_LEDNEW:
               pArg = strtok(NULL, pLimits);
               strcpy(szLedNew, pArg);
               break;

            case CMD_AREAS:
               pArg = strtok(NULL, pLimits);
               strcpy(szAreasBBS, pArg);
               break;

            case CMD_HOMEDIR:
               pArg = strtok(NULL, pLimits);
               if (!setcwd(pArg))
               {
                  ShowError(pArg, strerror(ENOTDIR));
                  exit(7);
               }
               getcwd (szHomeDir, (int) sizeof (szHomeDir));
               break;

            case CMD_OUTBOUND:
               pArg = strtok(NULL, pLimits);
               strcpy(szOutbound, pArg);
               if (szOutbound[0])
               {
                  if (szOutbound[strlen(szOutbound) - 1] != '\\')
                  {
                     strcat(szOutbound, "\\");
                  }
               }
               break;

            case CMD_INBOUND:
               pArg = strtok(NULL, pLimits);
               strcpy(szInbound, pArg);
               if (szInbound[0])
               {
                  if (szInbound[strlen(szInbound) - 1] != '\\')
                  {
                     strcat(szInbound, "\\");
                  }
               }
               break;

            case CMD_ARCOUT:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  if (status == CMS_HOST)
                  {
                     if (ProgramPrefix == 'E')
                     {
                        pArg = strdup(pArg);
                        if (pArg == NULL)
                           ShowError("ArcOutput", szOutOfMemory);
                        else
                           pHost->pArcCmd = pArg;
                     }
                  }
                  else
                     strcpy(szArcOut, pArg);
               }
               break;

            case CMD_DEFIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  strcpy(szDefaultIn, pArg);
               }
               break;

            case CMD_ARCIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  strcpy(szArcIn, pArg);
               }
               break;

            case CMD_ARJIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  strcpy(szArjIn, pArg);
               }
               break;

            case CMD_LZHIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  strcpy(szLharcIn, pArg);
               }
               break;

            case CMD_LHAIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  strcpy(szLhaIn, pArg);
               }
               break;

            case CMD_ZIPIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  strcpy(szZipIn, pArg);
               }
               break;

            case CMD_ZOOIN:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  strcpy(szZooIn, pArg);
               }
               break;

            case CMD_ARCDEL:
               DeletePkt = FlagValue;
               break;

            case CMD_ROUTEECHO:
               RouteEchos = FlagValue;
               break;

            case CMD_DUMMYFLOW:
               {
                  int   arg;

                  pArg = strtok(NULL, pLimits);
                  arg = (pArg == NULL) ? FlagValue : atoi(pArg);
                  if (arg < 0 || arg > 3)
                     ShowError("DUMMYFLOW", "illegal argument");
                  else
                  {
                     if (status == CMS_NONE)
                        CreateDummyFlo = arg;
                     else
                        pHost->DummyFlow = arg;
                  }
               }
               break;

            case CMD_SOFTRETURN:
               pArea->SoftReturns = FlagValue;
               break;

            case CMD_NOOUTPUT:
               if (status == CMS_AREA)
               {
                  pArea->NoOutput = FlagValue;
               }
               else
               {
                  pHost->NoOutput = FlagValue;
               }
               break;

            case CMD_COMPRESS:
               Compress = FlagValue;
               break;

            case CMD_DUPES:
               KillDupes = FlagValue;
               if (KillDupes) StoreCrc = TRUE;
               break;

            case CMD_STORECRC:
               StoreCrc = FlagValue;
               if (!StoreCrc) KillDupes = FALSE;
               break;

            case CMD_ALIAS:
               {
                  ALIAS *pAlias;
                  char  *pDefinition;
                  char  domain[MAX_LINELENGTH];
                  WORD  Zone, Net, Node, Point;

                  pArg = strtok(NULL, pLimits);
                  if (pArg == NULL) continue;
                  pDefinition = GetString(pArg, LineLength - (pArg - line));
                  if (pDefinition == NULL) continue;

                  Zone = DefaultZone;
                  Net = Node = Point = 0;
                  Get4dAddress(pDefinition, &Zone, &Net, &Node, &Point, domain);

                  pAlias = FindAlias(pArg);
                  if (pAlias == NULL)
                  {
                     pAlias = calloc(1, sizeof(*pAlias) + strlen(pArg));
                     if (pAlias == NULL)
                     {
                        ShowError("strdup", szOutOfMemory);
                        exit(5);
                     }
                     strcpy(pAlias->szAlias, pArg);
                     pAlias->pNext = pAliasList;
                     pAliasList    = pAlias;
                     if (*domain)
                     {
                        pAlias->pDomain = strdup(domain);
                        if (pAlias == NULL)
                        {
                           ShowError(pDefinition, szOutOfMemory);
                           exit(5);
                        }
                     }
                  }
                  pAlias->Zone  = Zone;
                  pAlias->Net   = Net;
                  pAlias->Node  = Node;
                  pAlias->Point = Point;
               }
               break;

            case CMD_APPENDTB:
               AppendTB = FlagValue;
               break;

            case CMD_SYSOP:
               pArg = GetString(pArg, LineLength - (pArg - line));
               if (pArg != NULL)
               {
                  SYSOPNAME *p;

                  p = malloc(sizeof(*p) + strlen(pArg) + 1);
                  if (p == NULL)
                  {
                     ShowError("strdup", szOutOfMemory);
                     exit(5);
                  }
                  strcpy((char *)(p + 1), pArg);
                  p->pName = (char *)(p + 1);
                  p->pNext = pSysopName;
                  pSysopName = p;
               }
               break;

            case CMD_DECCRC:
               CrcFormat = "%ld";
               break;

            case CMD_HEXCRC:
               CrcFormat = "%.8lx";
               break;

            case CMD_3DTICK:
               pHost->OldTick = FlagValue;
               break;

            case CMD_LOGAREA:
               if (pCommArea == NULL)
               {
                  pCommArea = pArea;
               }
               else
               {
                  ShowError(pArea->pLocalName, "multiple LogMsgArea ignored");
               }
               break;

            case CMD_BADMSGAREA:
               if (pBadMsgArea == NULL)
               {
                  pBadMsgArea = pArea;
               }
               else
               {
                  ShowError(pArea->pLocalName, "multiple BadMsgArea ignored");
               }
               break;

            case CMD_QUICK:
               QuickScan = FlagValue;
               break;

            case CMD_CREATETB:
               CreateTB  = FFF_THEBOX;
               break;

            case CMD_IOSFLOW:
               CreateTB  = FFF_IOS;
               break;

            case CMD_USEZONES:
               UseZones  = FlagValue;
               break;

            case CMD_DEFAULTZONE:
               DefaultZone = wordArg();
               break;

            case CMD_KEEPAREA:
               pArea->KeepArea = FlagValue;
               break;

            case CMD_GOODUNPACK:
               GoodUnpackReturn = wordArg();
               break;

            case CMD_HIGHLIMIT:
               pArea->HighMessageCount = wordArg();
               break;

            case CMD_FORCEINTL:
               if (status == CMS_HOST)
               {
                  pHost->ForceIntl = FlagValue;
               }
               else
               {
                  ForceIntl = FlagValue;
               }
               break;

            case CMD_COOKIE:
               pArg = strtok(NULL, pLimits);
               if (Cookies.fp != NULL) CloseCookie(&Cookies);
               OpenCookie(pArg, &Cookies);
                        /* -----------------------------------------
                           OpenCookie might return an error, but
                           either we should ignore it, or the pro-
                           gram has already been terminated, and
                           we never come here.
                           ----------------------------------------- */
               break;

            case CMD_RNDORIGIN:
               pArea->RandomOrigin = FlagValue;
               break;

            case CMD_NEWAREADIR:
               pArg = strtok(NULL, pLimits);
               strcpy(szNewAreaDir, (pArg == NULL) ? "MSGS\\" : pArg);
               break;

            case CMD_CENSOR:
               pArg = strtok(NULL, pLimits);
               strcpy(szRules, (pArg == NULL) ? "" : pArg);
               break;

            case CMD_SIGNATURE:
               switch (status)
               {
                  case CMS_NONE:
                     pArg = strtok(NULL, pLimits);
                     strcpy(szSignature, (pArg == NULL) ? "" : pArg);
                     break;

                  case CMS_HOST:
                     if (pHost->pSignature != NULL) free(pHost->pSignature);
                     pArg = strtok(NULL, pLimits);
                     if (pArg != NULL)
                     {
                        pArg = strdup(pArg);
                        if (pArg == NULL)
                           ShowError("Host/Signature", szOutOfMemory);
                     }
                     pHost->pSignature = pArg;
                     break;

                  case CMS_AREA:
                     if (pArea->pSignature != NULL) free(pArea->pSignature);
                     pArg = strtok(NULL, pLimits);
                     if (pArg != NULL)
                     {
                        pArg = strdup(pArg);
                        if (pArg == NULL)
                           ShowError("Area/Signature", szOutOfMemory);
                     }
                     pArea->pSignature = pArg;
                     break;
               }
               break;

            case CMD_ARCEDCRASH:
               ArcedCrashMail = FlagValue;
               break;

            case CMD_DOMAIN:  /* DOMAIN zone domain-name */
               pArg = strtok(NULL, pLimits);
               if (pArg != NULL)
               {
                  WORD zone;
                  zone = atoi(pArg);
                  pArg = strtok(NULL, pLimits);
                  if (zone != 0 && pArg != NULL)
                  {
                     DOMAIN *pDomain;
                     pDomain = FindDomain(zone);
                     if (pDomain == NULL)
                     {
                        pDomain = malloc(sizeof(DOMAIN) + strlen(pArg) + 1);
                        if (pDomain == NULL)
                           ShowError("DOMAIN", szOutOfMemory);
                        else
                        {
                           pDomain->pNext = pDomainList;
                           pDomain->zone = zone;
                           pDomain->pName = (char *) (pDomain + 1);
                           strcpy(pDomain->pName, pArg);
                           pDomainList = pDomain;
                        }
                     }
                  }
                  else
                     ShowError("DOMAIN", (pArg == NULL)
                                          ? "domain-name missing"
                                          : "bad zone number");
               }
               else
                  ShowError("DOMAIN", "zone missing");
               break;
               
            case CMD_4DECHOMAIL:
               pHost->NewEchomail = FlagValue;
               break;

            case CMD_ROUTETO:
               {
                  char  *pDefinition;
                  char  domain[MAX_LINELENGTH];

                  pDefinition = GetString(pArg, LineLength - (pArg - line));
                  if (pDefinition == NULL) continue;

                  pHost->Route      = TRUE;
                  pHost->RouteZone  = pHost->BossZone;
                  pHost->RouteNet   = pHost->BossNet;
                  pHost->RouteNode  = pHost->BossNode;
                  pHost->RoutePoint = 0;
                  Get4dAddress(pDefinition,
                               &pHost->RouteZone,
                               &pHost->RouteNet,
                               &pHost->RouteNode,
                               &pHost->RoutePoint,
                               domain);
                  pHost->RouteDomain = (*domain)
                                       ? strdup(domain)
                                       : NULL;
               }
               break;

            case CMD_CRASHPOINTS:
               CrashPoints = FlagValue;
               break;
               
            case CMD_EXFLAGS:
               while ((pArg = strtok(NULL, pLimits)) != NULL)
               {
                  if (*pArg == '!')
                     ExportFlags &= ~Flags(pArg + 1);
                  else
                     ExportFlags |= Flags(pArg);
               }
               break;
            
            case CMD_2PLUSPKT:
               pHost->HeaderType = HT_2PLUS;
               break;
         }
      }
   }

   fclose(fp);
   if (QuickScan) Compress = Crunch = FALSE;
}




/* ---------------------------------------------------------------------
      ReadTbConfigs
   --------------------------------------------------------------------- */
void  ReadTbConfigs(void)
{
   AREAPARAM   *pArea;
   FILE        *fp;
   char        *p;
   char        *pAreaname;
   char        *pFilename;
   char        *pHostname;
   char        *passwd;
   char        *sigfile;
   long        size;
   int         days;
   int         dayslocal;
   int         low;
   int         high;
   int         crunch;
   char        line[256];
   char        origin[256];
   char        system[256];
   int         RandomOrigin;
   int         KillHold;
   int         KillLocal;
   int         KeepArea;
   int         NoOutput;
   int         TickArea;
   int         n;

   if (!setcwd(szHomeDir))
   {
      ShowError(szHomeDir, strerror(errno));
      exit(7);
   }

   fp = fopen(szAreasBBS, "r");
   if (fp == NULL)
   {
      ShowError(szAreasBBS, strerror(errno));
      szAreasBBS[0] = 0;
      return;
   }

   system[0] = origin[0] = '\0';
   RandomOrigin = 0;
   KillHold = 0;
   KillLocal = 0;
   KeepArea = 0;
   NoOutput = 0;
   TickArea = 0;
   days = INT_MAX;
   dayslocal = INT_MAX;
   low = INT_MAX;
   high = INT_MAX;
   crunch = INT_MAX;
   sigfile = NULL;
   passwd = NULL;

   do
   {
      if (!ReadLine(line, (int) sizeof (line), fp))
      {
         ShowError(szAreasBBS, "no areas found in AREAS.BBS");
         szLastRead[0] = 0;
         return;
      }
      if (line[0] != '-' && line[0] != ';' && !system[0]) strcpy(system, line);
   }
   while (line[0] != '-');

   n = 1;
   do
   {
      if (line[0] == '-')
      {
         if (UseAreas)
         {
            if (strnicmp(line, "-ORIGIN ", 8) == 0)
            {
               p = line + 8;
               while (*p == ' ') ++p;
               if (strnicmp(p, "-RANDOM", 7) == 0)
               {
                  RandomOrigin = TRUE;
               }
               else
               {
                  RandomOrigin = FALSE;
                  strcpy(origin, p);
               }
               continue;
            }
            if (strnicmp(line, "-DAYS ", 6) == 0)
            {
               p = strtok(line + 6, " \t");
               if (p != NULL)
               {
                  days = atoi(p);
                  p = strtok(NULL, " \t");
                  if (p != NULL)
                  {
                     dayslocal = atoi(p);
                  }
               }
               continue;
            }
            if (strnicmp(line, "-PASSWD ", 8) == 0)
            {
               p = strtok(line + 8, " \t");
               if (p != NULL)
               {
                  passwd = strdup(p);
               }
               continue;
            }
            if (strnicmp(line, "-SIGNATURE ", 11) == 0)
            {
               p = strtok(line + 11, " \t");
               if (p != NULL)
               {
                  sigfile = strdup(p);
               }
               continue;
            }
            if (strnicmp(line, "-CRUNCH ", 8) == 0)
            {
               p = strtok(line + 8, " \t");
               if (p != NULL)
               {
                  high = atoi(p);
                  p = strtok(NULL, " \t");
                  if (p != NULL)
                  {
                     low = atoi(p);
                     p = strtok(NULL, " \t");
                     if (p != NULL)
                     {
                        crunch = atoi(p);
                     }
                  }
               }
            }
            if (strnicmp(line, "-FLAGS ", 7) == 0)
            {
               int status;
               p = strtok(line + 7, " \t");
               while (p != NULL)
               {
                  status = 1 + (*p != '!');
                  if (!status) ++p;
                  if (stricmp(p, "killhold") == 0)
                     KillHold = status;
                  else if (stricmp(p, "killlocal") == 0)
                     KillLocal = status;
                  else if (stricmp(p, "nooutput") == 0)
                     NoOutput = status;
                  else if (stricmp(p, "tickarea") == 0)
                     TickArea = status;
                  else if (stricmp(p, "keeparea") == 0)
                     KeepArea = status;
                  p = strtok(NULL, " \t");
               }
            }
         }
         continue;
      }

      if (line[0] && line[0] != ';')
      {
         pFilename = strtok(line, pLimits);
         if (pFilename == NULL)
         {
            ShowError(szAreasBBS, "bad file format");
            continue;
         }

         pAreaname = strtok(NULL, pLimits);
         if (pAreaname == NULL)
         {
            ShowError(szAreasBBS, "bad file format");
            continue;
         }

         pHostname = strtok(NULL, pLimits);
         if (pHostname == NULL)
         {
            ShowError(szAreasBBS, "bad file format");
            continue;
         }

         pArea = FindLocalArea(pAreaname);
         if (UseAreas)
         {
            if (pArea == NULL)
            {
               pArea = AllocateArea(pAreaname);
               if (pArea == NULL)
               {
                  ShowError("calloc", szOutOfMemory);
                  exit(5);
               }
            }

            if (RandomOrigin) pArea->RandomOrigin = TRUE;

            if ((system[0] || origin[0]) && pArea->pOrigin == NULL)
            {
               if ((pArea->pOrigin = strdup(origin[0] ? origin : system)) == NULL)
               {
                  ShowError("ReadTbParam", szOutOfMemory);
                  exit(5);
               }
            }

            if (pArea->pLocalName == NULL)
            {
               if ((pArea->pLocalName = strdup(pAreaname)) == NULL)
               {
                  ShowError("ReadTbParam", szOutOfMemory);
                  exit(5);
               }
            }

            if (pArea->pFilename != NULL) free(pArea->pFilename);
            if ((pArea->pFilename = strdup(pFilename)) == NULL)
            {
               ShowError("ReadTbParam", szOutOfMemory);
               exit(5);
            }

            if (!GetAddress(pHostname, &pArea->HostZone,
                                       &pArea->HostNet, &pArea->HostNode,
                                       NULL))
            {
               ShowError(pHostname, szBadNodeAddress);
            }

            if (days < INT_MAX) pArea->Days = days;
            if (dayslocal < INT_MAX) pArea->DaysLocal = dayslocal;
            if (low < INT_MAX) pArea->LowMessageCount = low;
            if (high < INT_MAX) pArea->HighMessageCount = high;
            if (crunch < INT_MAX) pArea->CrunchLimit = crunch;

            if (passwd != NULL)
            {
               if (pArea->pPassword != NULL) free(pArea->pPassword);
               pArea->pPassword = passwd;
            }
            if (sigfile != NULL)
            {
               if (pArea->pSignature != NULL) free(pArea->pSignature);
               pArea->pSignature = sigfile;
            }

            if (KillHold) pArea->KillHold = KillHold - 1;
            if (KillLocal) pArea->KillLocal = KillLocal - 1;
            if (NoOutput) pArea->NoOutput = NoOutput - 1;
            if (KeepArea) pArea->KeepArea = KeepArea - 1;
            if (TickArea) pArea->Type = (TickArea - 1)
                                        ? (AT_TICKAREA | AT_NETMAIL)
                                        : (pArea->Type & ~AT_TICKAREA);
         }
         else
         {
            if (pArea == NULL)
            {
               ShowError(pAreaname, "area not defined in config file");
               continue;
            }
         }
         pArea->AreaIndex = n++;
         RandomOrigin = FALSE;
         KillHold = FALSE;
         KillLocal = FALSE;
         KeepArea = FALSE;
         NoOutput = FALSE;
         TickArea = FALSE;
         days = INT_MAX;
         dayslocal = INT_MAX;
         low = INT_MAX;
         high = INT_MAX;
         crunch = INT_MAX;
         sigfile = NULL;
         passwd = NULL;
         origin[0] = '\0';
      }
   } while (ReadLine (line, (int) sizeof(line), fp));

   fclose(fp);

   if (szLastRead[0])
   {
      fp = fopen(szLastRead, "rb");
      if (fp == NULL)
      {
         ShowError(szLastRead, strerror(errno));
         szLastRead[0] = 0;
         return;
      }
      size = filelength(fileno(fp));
      if (size < n * sizeof(WORD))
      {
         ShowError(szLastRead, "file too short/long");
         szLastRead[0] = 0;
         fclose(fp);
         return;
      }
      p = calloc(n, sizeof(WORD));
      if (p == NULL)
      {
         ShowError("calloc", szOutOfMemory);
         exit(5);
      }
      fread(p, sizeof(WORD), n, fp);
      fclose(fp);

      for (pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext)
      {
         pArea->LastRead = ((WORD *) p)[pArea->AreaIndex];
      }
   }

   free(p);
}



/* ---------------------------------------------------------------------
      VerifyParams
   --------------------------------------------------------------------- */
void  VerifyParams(void)
{
   BOOL        error;
   HOSTPARAM   *pHost;
   AREAPARAM   *pArea;

   error = FALSE;
   for (pHost = pFirstHost; pHost != NULL; pHost = pHost->pNext)
   {
      error |= !TestHost(pHost);
   }

   for (pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext)
   {
      error |= !TestArea(pArea);
   }

   if (pBadMsgArea  == NULL)
   {
      pBadMsgArea = pNetmailArea;
   }

   if (pNetmailArea == NULL)
   {
      ShowError("VerifyParams", "no netmail area specified");
      error = TRUE;
   }

   if (error) exit(6);
}



/* ---------------------------------------------------------------------
      UpdateFiles
   --------------------------------------------------------------------- */
void  UpdateFiles(void)
{
   AREAPARAM   *pArea;
   FILE        *fp;
   WORD        *p;
   int         n;

   for (n = 0, pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext, n++);
   p = calloc(n + 1, sizeof(WORD));
   if (p == NULL)
   {
      ShowError("calloc", szOutOfMemory);
      exit(5);
   }
   for (pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext)
   {
      p[pArea->AreaIndex] = pArea->LastRead;
   }

   if (szLastRead[0])
   {
      fp = fopen(szLastRead, "wb");
      if (fp == NULL)
      {
         ShowError(szLastRead, strerror(errno));
         szLastRead[0] = 0;
         return;
      }
      fwrite(p, sizeof(WORD), n + 1, fp);
      fclose(fp);
   }
   free(p);
}
