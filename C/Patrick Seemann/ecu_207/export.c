/* --------------------------------------------------------------------
   Modul:      EXPORT.C
   Subject:    the working part of Export & Crunch
   Author:     ho
   Started:    11.08.1990  10:13:44
   --------------------------------------------------------------------
   Direct mail to points is disabled. To enable this feature, compile
   with DIRECT_POINT_MAIL #define'd. However, as long as Binkley has
   no 4d nodelist, there is no reason to try.
   --------------------------------------------------------------------
   93-12-20ps  HostPrefix
   93-08-01ps  Nur noch MsgId wird neu generiert (da der Absender von
               Ecu evtl. ge„ndert wird), die restlichen Kludges werden
               vom Editor bernommen
   92-11-08ps  MsgLink konfigurierbar
   92-10-18ps  2+Pakete, Username
   92-10-17ps  Beim Packeraufruf wird das Environment weitergereicht
               GEM-Abh„ngigkeiten entfernt
   92-06-21ps  Beim Nachtragen der MsgId wird LEDvw6-Bug gefixt
               (repcrc steht in msgcrc)
   92-06-19ps  ECU-MsgId wird in HDR nachgetragen (fr Verkettung)
   --------------------------------------------------------------------
   14.03.1992  /F0 verbietet Dummy-Flow-Files, /F1 schaltet Dummy-Flow-
               Files fr alle Hosts an
   07.03.1992  Dummy-Paket packen (optional)
   05.03.1992  Wenn als Template zum Packen nur '%' angegeben wird,
               wird fr diesen Host kein Bundle erzeugt, sondern das
               PKT-File wird direkt versendet. Fr IOS kann man das
               evtl. noch dahingehend „ndern, daá das PKT in das ent-
               sprechende IOS-File umbenannr wird.
   27.02.1992  Dummy-Flowfile mit und ohne Dummy-Paket
   06.02.1992  RouteTo, CrashToPoints
   05.01.1992  Domain
   06.12.1991  ž --> á Umwandlung
   28.11.1991  GetAddress, Get4dAddress: zus„tzlicher Parameter fr
               Domainname, MSGID mit Domain, Domain-Directory fr BT
   12.11.1991  ungelesene Mails nicht l”schen
   10.11.1991  MatchHost aus PARAM.C nach EXPORT.C
   03.11.1991  Arced Crashmail
   02.11.1991  DummyFlow fr einzelne Hosts
               Absender nur „ndern, wenn Aka der eigenen Adresse
   29.10.1991  Zone von TB bernehmen, wenn AppendTB
               %d (directory) und %n (packetname) in ArcCommand
   28.10.1991  received flag exportieren
   12.10.1991  Signature
   08.10.1991  Tick-Zeilen nur in Tick-Msgs berspringen
   28.09.1991  unterschiedliche Arcer fr verschiedene Hosts
   17.08.1991  4d originating address in crashmail
   20.06.1991  append 0 to message, just in case someone (Hatch&Stick?)
               didn't count it
   09.06.1991  ForceIntl
   04.05.1991  HighMessageCount
   10.04.1991  don't crunch if no messages deleted (unless packing is
               required)
               allways send crashmail 4d
   07.04.1991  UseZones
   05.04.1991  CreateTB
   25.02.1991  QuickScan
   20.02.1991  allways output a hard return on Ctrl-A lines
   16.02.1991  write TOPT/FMPT/INTL into message base
               skip leading spaces in subject line
   10.02.1991  stores statistics data in area block, no log-file
   27.01.1991  RemoveOldScrolls extracted
   20.01.1991  3dEchomail/3dNetmail
   09.01.1991  keep ^REPLY from original message
   06.01.1991  use host address for arcmail file
   05.01.1991  use fake address in StandardPkt header
   19.12.1990  bug in RemoveOldScrolls if msg didn't end with \n
   18.12.1990  RouteEchos
   24.11.1990  force hard returns in quotes (all lines with a '>'
               are assumed to be quoted)
   10.11.1990  compute CRC and store in message header, to be used
               by a dupe checker
   09.11.1990  no path in msgs with file
   06.11.1990  don't create dummy pkt for NoOutput hosts
   04.11.1990  handle crashmail with file attach properly
   02.11.1990  make sure there are no empty strings in a message
               header. (this is only a patch to fool LED when it
               feels like stopping if the from field starts with
               a zero)
   30.09.1990  remove empty lines at the end of a message
   17.09.1990  extension for sunday's paket is SU0, not SO0
               initial value for soft returns from area entry
   16.09.1990  INTL for inter-zone netmails
   14.09.1990  insert CR/LFs before tearline
               default return type is hard return
   --------------------------------------------------------------------- */



/* --------------
      Includes
   -------------- */

#include "clib.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>

#if defined(__TOS__)
   #include <tos.h>
   #include <ext.h>
#else
   #include <io.h>
   #include <time.h>
   #include <alloc.h>
   #include <dir.h>
   #include <dos.h>
#endif

#include "global.h"
#include "ecudef.h"



/* -------------
      Defines
   ------------- */

#define  swap(x)           (((unsigned)(x) << 8) | ((unsigned)(x) >> 8))
#define  FIDO_FLAGS        (MF_RECEIVED | MF_PRIVATE | MF_WITHFILE)
#define  ST_ESSZET         '\x9E'
#define  PC_ESSZET         '\xE1'



/* ---------------
      Variables
   --------------- */

static char *szExtension[] = { "SU0","MO0","TU0","WE0","TH0","FR0","SA0" };

char  szHost[20];
char  nmHeader[FILENAME_MAX];
char  nmMessages[FILENAME_MAX];
char  nmTempHdr[FILENAME_MAX];
char  nmTempMsg[FILENAME_MAX];
char  nmCrashPkt[FILENAME_MAX];

AREAPARAM   *pActiveArea;
HOSTPARAM   *pActiveHost;
MSG_HEADER  *pHeader;
int         nHeader;
int         nExported = 0;
FILE        *fpMessages;
BOOL        WriteMessages;
BOOL        CrunchHeader;
BOOL        NewHeader;
BOOL        NewMessages;

#if defined(__TOS__)
   int  access(char *, int);
#endif

void PackCrashMail(WORD zone, WORD net, WORD node, WORD point,
                   char *pPacketName, HOSTPARAM *pHost);


char  TB_DIGIT(WORD x)
{
   x %= 36;
   return x >= 10 ? x - 10 + 'A' : x + '0';
}



/* ---------------------------------------------------------------------
      MatchHost
   --------------------------------------------------------------------- */
HOSTPARAM   *MatchHost(unsigned zone, unsigned net, unsigned node)
{
   HOSTPARAM *p;
   HOSTPARAM *pBestMatch;
   BOOL      f;
   int       Cval;
   int       Mval;

   pBestMatch = pActiveHost;
   p          = pFirstHost;
   f          = FALSE;

   if (pBestMatch->BossZone != zone) Mval = 0; else
   if (pBestMatch->BossNet  != net)  Mval = 1; else
   if (pBestMatch->BossNode != node) Mval = 2; else
                                     Mval = 3;

/* it'd be faster if the loop would stop as soon a complete match is found,
   but this way it is easier to predict, which host will be selected. and
   i don't have to explain to the user that internally hosts are stored in
   reverse order.
 */
   while (p != NULL /* && Mval < 3 */)
   {
      if (!p->NoNetmail)
      {
         if (p->BossZone != zone) Cval = 0; else
         if (p->BossNet  != net)  Cval = 1; else
         if (p->BossNode != node) Cval = 2; else
                                  Cval = 3;
         if (Cval >= p->MatchMinimum && (Cval > Mval || Cval == Mval && f))
         {
            pBestMatch = p;
            Mval       = Cval;
            f          = TRUE;
         }
      }
      p = p->pNext;
   }

   return Mval ? pBestMatch : NULL;
}



/* --------------------------------------------------------------------
   OutboundFolder
   -------------------------------------------------------------------- */
char *OutboundFolder(WORD zone, char *domain)
{
   static char tmp[FILENAME_MAX];
   char  *p;

   p = strchr(strcpy(tmp, szOutbound), 0);

   if (UseZones && zone != DefaultZone)
   {
      if (p > tmp && *(p - 1) == '\\') --p;
      if (domain == NULL)
      {
         DOMAIN *d = FindDomain(zone);
         if (d != NULL) domain = d->pName;
      }
      if (domain != NULL)
      {
         while (p > tmp && *(p - 1) != '\\' && *(p - 1) != ':') --p;
         strcpy(p, domain);
         p = strchr(p, '.');
         if (p != NULL)
            *p = 0;
         else
            p = strchr(tmp, 0);
      }
      sprintf(p, ".%.3x\\", zone);
      p = strchr(p, 0);
   }
   else
   {
      if (p > tmp && *(p - 1) != '\\')
      {
         *p++ = '\\';
         *p   = 0;
      }
   }

   return tmp;
}



/* --------------------------------------------------------------------
   MakeIosName
   -------------------------------------------------------------------- */
void MakeIosName(char *name,
                 WORD zone, WORD net, WORD node, WORD point,
                 char *domain)
{
   char *p;

   {
      HOSTPARAM *p;
      while (point == 0 && (p = FindHost(zone, net, node)) != NULL && p->Route)
      {
         zone   = p->RouteZone;
         net    = p->RouteNet;
         node   = p->RouteNode;
         point  = p->RoutePoint;
         domain = p->RouteDomain;
      }
   }
   
   p = strchr(strcpy(name, OutboundFolder(zone, domain)), 0);

   *p++ = TB_DIGIT(net / (36 * 36));
   *p++ = TB_DIGIT(net / 36);
   *p++ = TB_DIGIT(net);
   *p++ = TB_DIGIT(node / (36 * 36));
   *p++ = TB_DIGIT(node / 36);
   *p++ = TB_DIGIT(node);
   *p++ = TB_DIGIT(point / 36);
   *p++ = TB_DIGIT(point);
   *p++ = '.';
   *p++ = 0;
}



/* --------------------------------------------------------------------
   MakeFlowFileName
   -------------------------------------------------------------------- */
void MakeFlowFileName(char *name,
                      WORD zone, WORD net, WORD node, WORD point,
                      char *domain,
                      WORD type)
{
   static char *IOSextension[] = { "OFT", "CFT", "HFT" };
   static char *BTextension[]  = { "FLO", "CLO", "HLO" };
   static char *TBextension[]  = { "AF",  "IF",  "WF"  };
   char   *p;
   
   {
      HOSTPARAM *p;
      while (point == 0 && (p = FindHost(zone, net, node)) != NULL && p->Route)
      {
         zone   = p->RouteZone;
         net    = p->RouteNet;
         node   = p->RouteNode;
         point  = p->RoutePoint;
         domain = p->RouteDomain;
      }
   }

   p = strchr(strcpy(name, szOutbound), 0);

   switch (CreateTB)
   {
      case FFF_BINKLEY:
         p = strchr(strcpy(name, OutboundFolder(zone, domain)), 0);
         sprintf(p, "%.4x%.4x.%s", net, node, BTextension[type]);
         break;

      case FFF_THEBOX:
         p = strchr(strcpy(name, szOutbound), 0);
         *p++ = TB_DIGIT(zone / 36);
         *p++ = TB_DIGIT(zone);
         *p++ = TB_DIGIT(net / (36 * 36));
         *p++ = TB_DIGIT(net / 36);
         *p++ = TB_DIGIT(net);
         *p++ = TB_DIGIT(node / (36 * 36));
         *p++ = TB_DIGIT(node / 36);
         *p++ = TB_DIGIT(node);
         *p++ = '.';
         strcpy(p, TBextension[type]);
         break;

      case FFF_IOS:
         MakeIosName(name, zone, net, node, point, domain);
         strcat(name, IOSextension[type]);
         break;

      default:
         break;
   }
}



/* --------------------------------------------------------------------
      WriteFlowFileEntry

      appends a new entry to a FLO file. Creates file if neccessary.
      Entry is not written, if it is already in the file.

      Input:
      ------
      HOSTPARAM *pHost
         address of host's parameter record

      char *pEntry
         address to string to append to flow file. End of line should
         not be part of this string.

      char *pExtension
         the extension of the flow file or NULL for "FLO"
   -------------------------------------------------------------------- */
void  WriteFlowFileEntry(WORD zone, WORD net, WORD node, WORD point,
                         char *pDomain, char *pEntry, int ext)
{
   char  szFlowFile[FILENAME_MAX];
   FILE  *fp;

   if (!CrashPoints) point = 0;

   sprintf(szFlowFile, "%s to %d:%d/%d.%d", *pEntry ? pEntry : "DummyFLO",
           zone, net, node, point);
   WriteLogfile(szFlowFile);

   MakeFlowFileName(szFlowFile, zone, net, node, point, pDomain, ext);
   fp = fopen(szFlowFile, "a+");
   if (fp == NULL)
   {
      ShowError(szFlowFile, strerror(errno));
      return;
   }

   if (*pEntry)
   {
      rewind(fp);
      while (ReadLine(szFlowFile, (int) sizeof(szFlowFile), fp))
      {
         if (stricmp(szFlowFile, pEntry) == 0)
         {
            fclose(fp);
            return;
         }
      }

      fseek(fp, 0, SEEK_END);
      fprintf(fp, "%s\n", pEntry);
   }

   fclose(fp);
}



/* --------------------------------------------------------------------
      LoadHeader

      loads the header file of a message area. Uses global variables
      nmHeader, nHeader and pHeader.

      char nmHeader[]
         name of header file, must be set up before calling LoadHeader.

      int nHeader
         returns number of headers read from disk.

      MSG_HEADER *pHeader
         returns address of array with all headers loaded.

      Returns:
      --------
         TRUE  if headers have been loaded successfully.
         FALSE on error, nHeader and pHeader are undefined.
   -------------------------------------------------------------------- */
BOOL  LoadHeader(void)
{
   FILE  *fp;

                              /* --------------------------------------
                                 open header file
                                 -------------------------------------- */
   if ((fp = fopen(nmHeader, "rb")) == NULL)
   {
      ShowError(nmHeader, strerror(errno));
      return FALSE;
   }

                              /* --------------------------------------
                                 get number of entrys, allocate memory
                                 -------------------------------------- */
   nHeader = (int) (filelength(fileno(fp)) / sizeof(*pHeader));
   if ((pHeader = calloc(nHeader, sizeof(*pHeader))) == NULL)
   {
      ShowError("LoadHeader", szOutOfMemory);
      fclose(fp);
      return FALSE;
   }

                              /* --------------------------------------
                                 read headers
                                 -------------------------------------- */
   rewind(fp);
   if (fread(pHeader, sizeof(*pHeader), nHeader, fp) < nHeader)
   {
      ShowError("LoadHeader", szReadError);
      fclose(fp);
      free(pHeader);
      return FALSE;
   }

                              /* --------------------------------------
                                 close header file, update dialog
                                 -------------------------------------- */
   fclose(fp);
   return TRUE;
}



/* --------------------------------------------------------------------
      CreatePkt

      creates a new paket and writes the paket header. Has no effect,
      if a paket has allready been created for this host.

      Input:
      ------
      HOSTPARAM *pHost
         address of host's parameter record
   -------------------------------------------------------------------- */
void  CreatePkt(HOSTPARAM *pHost)
{
   struct tm   *tm;
   long        lt;
   char        *out;
   char        *domain;
   PKTHDR      header;
   unsigned    Onode, Ozone, Onet, Opoint;
   unsigned    Dnode, Dzone, Dnet, Dpoint;
   HOSTPARAM   *p;

   if (pHost->nmPkt != NULL) return;

   Dzone  = pHost->BossZone;
   Dnet   = pHost->BossNet;
   Dnode  = pHost->BossNode;
   Dpoint = 0;
   domain = NULL;
   for (p = pHost; Dpoint == 0 && p != NULL && p->Route; )
   {
      Dzone  = pHost->RouteZone;
      Dnet   = pHost->RouteNet;
      Dnode  = pHost->RouteNode;
      Dpoint = pHost->RoutePoint;
      domain = pHost->RouteDomain;
      p = FindHost(Dzone, Dnet, Dnode);
   }
                              /* --------------------------------------
                                 get memory for paket name, create name
                                 -------------------------------------- */
   out = OutboundFolder(Dzone, domain);
   if ((pHost->nmPkt = malloc(strlen(out) + 13)) == NULL)
   {
      ShowError("CreatePkt", szOutOfMemory);
      exit(5);
   }
   sprintf(pHost->nmPkt, "%s%.8lX.PKT", out, lFreeId++);

                              /* --------------------------------------
                                 create & open paket file
                                 -------------------------------------- */
   if ((pHost->fpPkt = fopen(pHost->nmPkt, "wb")) == NULL)
   {
      ShowError(pHost->nmPkt, strerror(errno));
      exit(7);
   }

                              /* --------------------------------------
                                 get date/time and 3d or 4d origin
                                 -------------------------------------- */
   time(&lt);
   tm = gmtime(&lt);

   if (pHost->OldAddress)
   {
      /* 3d origin address */
      Ozone  = pHost->FakeZone;
      Onet   = pHost->FakeNet;
      Onode  = pHost->FakeNode;
      Opoint = 0;
   }
   else
   {
      /* 4d origin address */
      Ozone  = pHost->BossZone;
      Onet   = pHost->BossNet;
      Onode  = pHost->BossNode;
      Opoint = pHost->Point;
   }

                              /* --------------------------------------
                                 create paket header
                                 -------------------------------------- */
   memset(&header, 0, sizeof(header));
   header.OrigNode      = swap(Onode);
   header.DestNode      = swap(Dnode);
   header.Year          = swap(tm->tm_year + 1900);
   header.Month         = swap(tm->tm_mon);
   header.Day           = swap(tm->tm_mday);
   header.Hour          = swap(tm->tm_hour);
   header.Minute        = swap(tm->tm_min);
   header.Second        = swap(tm->tm_sec);
   header.PacketVersion = swap(2);
   header.OrigNet       = swap(Onet);
   header.DestNet       = swap(Dnet);
   header.ProdInfo      = swap(pHost->ProductId);
   switch (pHost->HeaderType)
   {
      case HT_STANDARD:
         header.OrigNode = swap(pHost->FakeNode);
         header.OrigNet  = swap(pHost->FakeNet);
         break;

      case HT_FRODO:
         if (pHost->pPassword)
            strcpy (header.Xtra.FroDo.Password, pHost->pPassword);
         header.Xtra.FroDo.QMOrigZone = swap(Ozone);
         header.Xtra.FroDo.QMDestZone = swap(Dzone);
         header.Xtra.FroDo.OrigZone   = swap(Ozone);
         header.Xtra.FroDo.DestZone   = swap(Dzone);
         header.Xtra.FroDo.OrigPoint  = swap(Opoint);
         header.Xtra.FroDo.DestPoint  = swap(Dpoint);
         header.Xtra.FroDo.SerNo      = pHost->SerialNumber;
         break;

      case HT_QMAIL:
         if (pHost->pPassword)
            strcpy (header.Xtra.QM.Password, pHost->pPassword);
         header.Xtra.QM.QMOrigZone = swap(Ozone);
         header.Xtra.QM.QMDestZone = swap(Dzone);
         header.Xtra.QM.SerNo      = pHost->SerialNumber;
         break;
      
      case HT_2PLUS:
         if (pHost->pPassword)
            strcpy (header.Xtra.TwoPlus.Password, pHost->pPassword);
         header.Xtra.TwoPlus.QMOrigZone = swap(Ozone);
         header.Xtra.TwoPlus.QMDestZone = swap(Dzone);
         header.Xtra.TwoPlus.AuxNet     = header.OrigNet;
         header.OrigNet                 = -1;
         header.Xtra.TwoPlus.CWCopy     = 1;
         header.Xtra.TwoPlus.CapWord    = swap(1);
         header.Xtra.TwoPlus.OrigZone   = swap(Ozone);
         header.Xtra.TwoPlus.DestZone   = swap(Dzone);
         header.Xtra.TwoPlus.OrigPoint  = swap(Opoint);
         header.Xtra.TwoPlus.DestPoint  = swap(Dpoint);
         header.Xtra.TwoPlus.SerNo      = pHost->SerialNumber;
         break;
   }

                              /* --------------------------------------
                                 write paket header
                                 -------------------------------------- */
   if (fwrite(&header, 1, sizeof(header), pHost->fpPkt) < sizeof(header))
   {
      ShowError(pHost->nmPkt, szWriteError);
      exit(7);
   }
}



/* --------------------------------------------------------------------
      CreateCrashPkt

      creates a new paket and writes the paket header for a single
      crashmail.

      Input:
      ------
      HOSTPARAM *pHost
         the address of a host definietion structure (required for the
         origin etc.)
      WORD  net, node
         destinations 2d Fido address
   -------------------------------------------------------------------- */
FILE *CreateCrashPkt(HOSTPARAM *pHost,
      WORD zone, WORD net, WORD node, WORD point)
{
   struct tm   *tm;
   FILE        *fp;
   long        lt;
   PKTHDR      header;
   unsigned    Onode, Ozone, Onet, Opoint;

   nmCrashPkt[0] = '^';
   sprintf(nmCrashPkt + 1, "%s%.8lX.PKT", OutboundFolder(zone, NULL), lFreeId++);

                              /* --------------------------------------
                                 create & open paket file
                                 -------------------------------------- */
   if ((fp = fopen(nmCrashPkt + 1, "wb")) == NULL) return NULL;

                              /* --------------------------------------
                                 get date/time and 3d or 4d origin
                                 -------------------------------------- */
   time(&lt);
   tm = gmtime(&lt);

   if (pHost->OldAddress)
   {
      /* 3d origin address */
      Ozone  = pHost->FakeZone;
      Onet   = pHost->FakeNet;
      Onode  = pHost->FakeNode;
      Opoint = 0;
   }
   else
   {
      /* 4d origin address */
      Ozone  = pHost->BossZone;
      Onet   = pHost->BossNet;
      Onode  = pHost->BossNode;
      Opoint = pHost->Point;
   }

                              /* --------------------------------------
                                 create paket header
                                 -------------------------------------- */
   memset(&header, 0, sizeof(header));
   header.OrigNode      = swap(Onode);
   header.DestNode      = swap(node);
   header.Year          = swap(tm->tm_year + 1900);
   header.Month         = swap(tm->tm_mon);
   header.Day           = swap(tm->tm_mday);
   header.Hour          = swap(tm->tm_hour);
   header.Minute        = swap(tm->tm_min);
   header.Second        = swap(tm->tm_sec);
   header.PacketVersion = swap(2);
   header.OrigNet       = swap(Onet);
   header.DestNet       = swap(net);
   header.ProdInfo      = swap(pHost->ProductId);
   switch (pHost->HeaderType)
   {
      case HT_STANDARD:
         header.OrigNode = swap(pHost->FakeNode);
         header.OrigNet  = swap(pHost->FakeNet);
         break;

      case HT_FRODO:
         if (pHost->pPassword)
            strcpy (header.Xtra.FroDo.Password, pHost->pPassword);
         header.Xtra.FroDo.QMOrigZone = swap(Ozone);
         /*header.Xtra.FroDo.QMDestZone = swap(pHost->BossZone);*/
         header.Xtra.FroDo.QMDestZone = swap(zone);
         header.Xtra.FroDo.OrigZone   = swap(Ozone);
         header.Xtra.FroDo.DestZone   = swap(pHost->BossZone);
         header.Xtra.FroDo.OrigPoint  = swap(Opoint);
         header.Xtra.FroDo.DestPoint  = CrashPoints ? swap(point) : 0;
         header.Xtra.FroDo.SerNo      = pHost->SerialNumber;
         break;

      case HT_QMAIL:
         if (pHost->pPassword)
            strcpy (header.Xtra.QM.Password, pHost->pPassword);
         header.Xtra.QM.QMOrigZone = swap(Ozone);
         header.Xtra.QM.QMDestZone = swap(zone);
         header.Xtra.QM.SerNo      = pHost->SerialNumber;
         break;

      case HT_2PLUS:
         if (pHost->pPassword)
            strcpy (header.Xtra.TwoPlus.Password, pHost->pPassword);
         header.Xtra.TwoPlus.QMOrigZone = swap(Ozone);
         header.Xtra.TwoPlus.QMDestZone = swap(zone);
         header.Xtra.TwoPlus.AuxNet     = header.OrigNet;
         header.OrigNet                 = -1;
         header.Xtra.TwoPlus.CWCopy     = 1;
         header.Xtra.TwoPlus.CapWord    = swap(1);
         header.Xtra.TwoPlus.OrigZone   = swap(Ozone);
         header.Xtra.TwoPlus.DestZone   = swap(zone);
         header.Xtra.TwoPlus.OrigPoint  = swap(Opoint);
         header.Xtra.TwoPlus.DestPoint  = swap(point);
         header.Xtra.TwoPlus.SerNo      = pHost->SerialNumber;
         break;
   }

                              /* --------------------------------------
                                 write paket header
                                 -------------------------------------- */
   if (fwrite(&header, 1, sizeof(header), fp) < sizeof(header))
   {
      fclose(fp);
      remove(nmCrashPkt + 1);
      return NULL;
   }

   return fp;
}



/* --------------------------------------------------------------------
      PutString

      copies a delimited string and modifys the destination pointer.
      Copying stops at one of the following conditions:
      -  end of string ('\0') reached,
      -  delimiter (limit) reached,
      -  maximum number of bytes copied.
      Delimiting characters (0 and limit) are NOT copied.

      Input:
      ------
      char **d
         address of destination pointer. String is copied to the loca-
         tion pointed to by this variable (not to the variable itself).
         On return, *d points to first byte beyond copy.

      char *s
         string to copy.

      int len
         maximum number of bytes to copy

      int limit
         additional delimiter (besides 0)
   -------------------------------------------------------------------- */
void  PutString(char **d, char *s, int len, int limit)
{
   while (len-- && *s && *s != limit) *(*d)++ = *s++;
}



/* --------------------------------------------------------------------
      ExportMessage

      writes a message with all required addons into a paket file and
      updates the message base.

      Input:
      ------
      MSG_HEADER *pHeader
         address of header of message to send
   -------------------------------------------------------------------- */
BOOL  ExportMessage(MSG_HEADER *pHeader)
{
   HOSTPARAM   *pHost;
   MSGHDR      *pMessage;
   FILE        *fp;
   char        *p;
   char        *pBody;
   long        BodySize;
   long        MsgStart;
   long        nWritten;
   long        Switches;
   BOOL        SoftReturn;
   char        szSubject[72];
   char        szFilename[72];
   char        idString[64];
   WORD        zone, net, node;
   WORD        OldFlags;
   BOOL        CrashMail;
   BOOL        TickNotice;
   int         EolType;
   int         NextEol;

   if (!pActiveArea->NoOutput)
   {
      ++nExported;
   }

                              /* --------------------------------------
                                 allocate memory for message
                                 -------------------------------------- */
   pMessage = malloc(pHeader->wSize + sizeof(*pMessage)
                                    + pActiveArea->SignatureLength + 2);
   if (pMessage == NULL)
   {
      ShowError("ExportMessage", szOutOfMemory);
      exit(5);
   }

                              /* --------------------------------------
                                 Get destination address from To-Line
                                 -------------------------------------- */
   if ((p = strchr(pHeader->szTo, AddressPrefix)) != NULL)
   {
      Get4dAddress(p + 1, &pHeader->wToZone, &pHeader->wToNet,
                          &pHeader->wToNode, &pHeader->wToPoint,
                          NULL);
   }

                              /* --------------------------------------
                                 Get host from subject line. If subject
                                 starts with an '[' the following chars
                                 up to the next '] are taken as the
                                 host name. The message is placed in
                                 this host's packet file instead of the
                                 default host's file.
                                 -------------------------------------- */
   zone = pHeader->wToZone;
   net  = pHeader->wToNet;
   node = pHeader->wToNode;

   for (p = pHeader->szSubject; *p == ' '; ++p);
   if (*strcpy(szSubject, p) == HostPrefix[0])
   {
      if ((p = strchr(szSubject, HostPrefix[1])) != NULL)
      {
         *p++ = '\0';
         GetAddress(szSubject + 1, &zone, &net, &node, NULL);
         while (*p == ' ') p++;
         strcpy(szSubject, p);
      }
   }

                              /* --------------------------------------
                                 Set default destination in message
                                 header (point's address for netmail -
                                 return to sender, boss's address for
                                 echomail). Private-flag is set in
                                 netmails.
                                 -------------------------------------- */
   CrashMail  = FALSE;
   TickNotice = (pActiveArea->Type & AT_TICKAREA) != 0;
   OldFlags   = pHeader->wFlags;
   if (pHeader->wFlags & MF_WITHFILE)
   {
      p = strchr(szSubject, TickIndicator);
      if (p != NULL)
      {
         TickNotice = TRUE;
         do ++p; while (*p == ' ');
         strcpy(szFilename, strcpy(szSubject, p));
      }
      if (TickNotice) pHeader->wFlags &= ~MF_WITHFILE;
   }

   if (pActiveArea->Type & AT_NETMAIL)
   {
      CrashMail = (pHeader->wFlags & MF_CRASH) != 0;
      if (CrashMail || (pHost = MatchHost(zone, net, node)) == NULL)
      {
         pHost = pActiveHost;
      }
      pHeader->wFlags |= MF_PRIVATE;
   }
   else
   {
      if (RouteEchos)
      {
         if ((pHost = MatchHost(zone, net, node)) == NULL)
         {
            pHost = pActiveHost;
         }
      }
      else
      {
         pHost = pActiveHost;
      }
   }

                              /* --------------------------------------
                                 Set default origin address in message
                                 header.
                                 -------------------------------------- */
   {
      WORD  zone, net, node, point;
      HOSTPARAM *p;

      zone  = pHeader->wFromZone;
      net   = pHeader->wFromNet;
      node  = pHeader->wFromNode;
      point = pHeader->wFromPoint;
      for (p = pFirstHost; p != NULL; p = p->pNext)
      {
         if ((zone == p->FakeZone && net == p->FakeNet && node == p->FakeNode)
         ||  (zone == p->BossZone && net == p->BossNet && node == p->BossNode
                                  && point == p->Point))
         {
            if ((pActiveArea->Type & AT_NETMAIL)
                     ? (pHost->OldNetmail && !CrashMail)
                     : pHost->OldEchomail)
            {
               pHeader->wFromZone  = pHost->FakeZone;
               pHeader->wFromNet   = pHost->FakeNet;
               pHeader->wFromNode  = pHost->FakeNode;
               pHeader->wFromPoint = 0;
            }
            else
            {
               pHeader->wFromZone  = pHost->BossZone;
               pHeader->wFromNet   = pHost->BossNet;
               pHeader->wFromNode  = pHost->BossNode;
               pHeader->wFromPoint = pHost->Point;
            }
            break;
         }
      }
   }

                              /* --------------------------------------
                                 Get origin address from From-Line
                                 -------------------------------------- */
   if ((p = strchr(pHeader->szFrom, AddressPrefix)) != NULL)
   {
      Get4dAddress(p + 1, &pHeader->wFromZone, &pHeader->wFromNet,
                          &pHeader->wFromNode, &pHeader->wFromPoint,
                          NULL);
   }

   if (!UseZones)
   {
      CrashMail &= pHeader->wToZone == pHeader->wFromZone;
   }

                              /* --------------------------------------
                                 File-Attache - append filename to
                                 flow-file. This is always done in a
                                 tick-area.
                                 -------------------------------------- */
   if (pHeader->wFlags & MF_WITHFILE || TickNotice)
   {
      char *p;
      char *q;

      strcpy(szFilename, p = q = szSubject);
      while (*p)
      {
         if (*p == '\\' || *p == ':') q = p + 1;
         ++p;
      }
      strcpy(szSubject, q);

      if (!TickNotice)
      {
         if (CrashMail)
         {
            WriteFlowFileEntry(pHeader->wToZone,
                               pHeader->wToNet,
                               pHeader->wToNode,
                               pHeader->wToPoint,
                               NULL,
                               szFilename,
                               FF_CLO);
         }
         else
         {
            WriteFlowFileEntry(pHost->BossZone,
                               pHost->BossNet,
                               pHost->BossNode,
                               0,
                               pHost->pDomain,
                               szFilename,
                               FF_FLO);
         }
      }
   }

                              /* --------------------------------------
                                 Create message-header
                                 -------------------------------------- */
   p = pMessage->Data;
   pMessage->magic         = swap(2);
   pMessage->OrigNode      = swap(pHeader->wFromNode);
   pMessage->DestNode      = swap(pHeader->wToNode);
   pMessage->OrigNet       = swap(pHeader->wFromNet);
   pMessage->DestNet       = swap(pHeader->wToNet);
   pMessage->Attribute     = swap(pHeader->wFlags) & swap(FIDO_FLAGS);
   pMessage->Cost          = swap(0);
   PutString(&p, pHeader->szDate,    19, '\0');             *p++ = '\0';
   PutString(&p, pHeader->szTo,      35, AddressPrefix);    *p++ = '\0';
   if (pActiveArea->pUsername) {
      PutString (&p, pActiveArea->pUsername, 35, '\0');     *p++ = '\0';

   } else {
      PutString(&p, pHeader->szFrom,    35, AddressPrefix); *p++ = '\0';
   }
   PutString(&p, szSubject,          71, '\0');             *p++ = '\0';

                              /* --------------------------------------
                                 Initial scrolls
                                 LFs are not replaced with CR/LF here.
                                 So CR must be written explicitly.
                                 -------------------------------------- */
   if (!(pActiveArea->Type & AT_NETMAIL))
   {
                              /* --------------------------------------
                                 echomail: areaname
                                 ------------------------------------- */
      sprintf(p, "AREA:%s\r\n", pActiveArea->pAreaname);
      p += strlen(strupr(p));
      pBody = p;
   }

   if ((pActiveArea->Type & AT_NETMAIL) || pHost->NewEchomail)
   {
                              /* --------------------------------------
                                 netmail:  FMPT and TOPT if point
                                           number specified. INTL if
                                           mail to another zone.
                                 -------------------------------------- */
      pBody = p;
      if (pHeader->wToPoint)
      {
         sprintf(p, "\1TOPT %d\n", pHeader->wToPoint);
         p += strlen(p);
      }
      if (pHeader->wFromPoint)
      {
         sprintf(p, "\1FMPT %d\n", pHeader->wFromPoint);
         p += strlen(p);
      }
      if (pHeader->wToZone != pHost->BossZone || pHost->ForceIntl || ForceIntl)
      {
         sprintf(p, "\1INTL %d:%d/%d %d:%d/%d\n",
               pHeader->wToZone, pHeader->wToNet, pHeader->wToNode,
               pHost->BossZone, pHost->BossNet,
               pHost->BossNode);
         p += strlen(p);
      }
   }
   
                              /* --------------------------------------
                                 Message-Id
                                 -------------------------------------- */
   if (pHost->OldMsgId)
      sprintf (idString, "%d:%d/%d %.8lx", 
                         pHost->FakeZone,
                         pHost->FakeNet,
                         pHost->FakeNode,
                         lFreeId++);
   else if (pHost->pDomain != NULL)
      sprintf (idString, "%d:%d/%d.%d@%s %.8lx",
                         pHost->BossZone,
                         pHost->BossNet,
                         pHost->BossNode,
                         pHost->Point,
                         pHost->pDomain,
                         lFreeId++);
   else
      sprintf (idString, "%d:%d/%d.%d %.8lx",
                         pHost->BossZone,
                         pHost->BossNet,
                         pHost->BossNode,
                         pHost->Point,
                         lFreeId++);
   sprintf (p, "\1MSGID: %s\n", idString);
   p = strchr (p, 0);
   
   if (MsgLink)
      pHeader->midcrc = Crc32Str (idString);

   fp = fpMessages;
   fseek(fp, pHeader->lStart, SEEK_SET);
   if (fread(p, 1, pHeader->wSize, fp) < pHeader->wSize)
   {
      ShowError(nmMessages, szReadError);
      free(pMessage);
      pHeader->wFlags = OldFlags;
      return FALSE;
   }
   *(p + pHeader->wSize) = 0; /* just in case someone didn't count the
                                 final 0-byte */

                              /* --------------------------------------
                                 Remove old cludges
                                 -------------------------------------- */
   Switches = RemoveOldScrolls(p);
   if (TickNotice)
   {
      BOOL  fault;

      fault = !CreateTickFile(szFilename,CrashMail,pHost,pActiveArea,pHeader,p);
      if (fault)
      {
         free(pMessage);
         pHeader->wFlags = OldFlags;
         return FALSE;
      }
   }
   p += strlen(p);

                              /* --------------------------------------
                                 Signatur einfgen
                                 -------------------------------------- */
   if (pActiveArea->SignatureLength > 0
      && !(pHeader->wFlags & MF_SIGNATURE)
      && !(Switches & MSW_NOSIGNATURE))
   {
      FILE *fp;

      fp = fopen(pActiveArea->pSignature, "r");
      if (fp != NULL)
      {
         *p++ = '\n';
         p += fread(p, sizeof(BYTE), pActiveArea->SignatureLength, fp);
         *p = 0;
         fclose(fp);
         pHeader->wFlags |= MF_SIGNATURE;
      }
   }

   if (pActiveArea->Type & AT_ECHOMAIL)
   {
                              /* --------------------------------------
                                 Echomail only:
                                 -  tearline
                                 -  origin line
                                 -  seen-by
                                 -  path
                                 -------------------------------------- */
      char szOrigin[80];

      sprintf(p, "\n\n--- %s\n * Origin: %s ",
              szTearline,
              pActiveArea->RandomOrigin && GetCookie(&Origins, szOrigin)
              ?   szOrigin
              :   pActiveArea->pOrigin);
      p += strlen(p);
      if (pHost->OldOrigin)
      {
         sprintf(p, "(%d:%d/%d)\n",
                    pHost->FakeZone,
                    pHost->FakeNet,
                    pHost->FakeNode);
      }
      else
      {
         sprintf(p, "(%d:%d/%d.%d)\n",
                    pHost->BossZone,
                    pHost->BossNet,
                    pHost->BossNode,
                    pHost->Point);
      }
      p += strlen(p);

      sprintf(p, "SEEN-BY: %d/%d", pHost->BossNet, pHost->BossNode);
      p += strlen(p);
                              /* --------------------------------------
                                 don't know how to write a 4d seen-by
                                 entry. so there are only 3d seen-by's
                                 -------------------------------------- */
      if (pHost->OldSeenBy)
      {
         sprintf(p, " %d/%d", pHost->FakeNet, pHost->FakeNode);
         p += strlen(p);
      }
      *p++ = '\n';

      if (pHost->OldPath)
      {
         sprintf(p, "\1PATH: %d/%d\n",
                    pHost->FakeNet,
                    pHost->FakeNode);
         p += strlen(p);
      }
   }

                              /* --------------------------------------
                                 end of message
                                 -------------------------------------- */
   *p++ = '\0';

                              /* --------------------------------------
                                 Append new message body and cludges to
                                 message base, update header to contain
                                 new size and new start.
                                 -------------------------------------- */
   fseek(fp, 0, SEEK_END);
   MsgStart = ftell(fp);
   BodySize = p - pBody;
   if (fwrite(pBody, 1, BodySize, fp) < BodySize)
   {
      ShowError(nmMessages, szWriteError);
   }
   else
   {
      fflush(fp);
      pHeader->wSize   = BodySize;
      pHeader->lStart  = MsgStart;
      WriteHeader      = TRUE;
   }

   if (!pActiveArea->NoOutput)
   {                          /* --------------------------------------
                                 create and open paket file
                                 -------------------------------------- */
      if (CrashMail || pHeader->wFlags & MF_WITHFILE)
      {
         fp = CreateCrashPkt(pHost, pHeader->wToZone, pHeader->wToNet,
                                    pHeader->wToNode, pHeader->wToPoint);
         if (fp == NULL)
         {
            ShowError(nmCrashPkt + 1, strerror(errno));
            pHeader->wFlags = OldFlags;
            return FALSE;
         }
      }
      else
      {
         if (pHost->nmPkt == NULL) CreatePkt(pHost);
         if (pHost->fpPkt == NULL)
         {
            if ((pHost->fpPkt = fopen(pHost->nmPkt, "ab")) == NULL)
            {
               ShowError(pHost->nmPkt, strerror(errno));
               exit(7);
            }
         }
         fp = pHost->fpPkt;
      }

                           /* --------------------------------------
                              Write message to paket file. Replace
                              LF with CR/LF. Initially allow soft
                              returns.
                              -------------------------------------- */
      fseek(fp, 0, SEEK_END);
      MsgStart = ftell(fp);
      nWritten = pBody - (char *) pMessage;
      fwrite(pMessage, 1, nWritten, fp);
      p = pBody;
      SoftReturn = pActiveArea->SoftReturns;
      EolType    = 0;

      while (*pBody)
      {
         if (*p == FormatPrefix || (*p == TickPrefix && TickNotice))
         {
            if (*p == FormatPrefix)
            {                 /* --------------------------------------
                                 Internal command lines. These lines
                                 are not sent, but interpreted locally
                                 -------------------------------------- */
               ++p;
               switch (tolower(*p))
               {
                  case 'h':   /* --------------------------------------
                                 .H - disables soft returns
                                 -------------------------------------- */
                     SoftReturn = FALSE;
                     break;

                  case 'i':   /* --------------------------------------
                                 .I - include file
                                 -------------------------------------- */
                     fwrite("\r\n", 1, 2, fp) ;
                     nWritten += IncludeText(fp, p + 1) + 2;
                     break;

                  case 's':   /* --------------------------------------
                                 .S - enables soft returns
                                 -------------------------------------- */
                     SoftReturn = TRUE;
                     break;

                  case 't':   /* --------------------------------------
                                 .T - inserts a tearline. Only there to
                                 allow a tearline in AreaFix mails
                                 -------------------------------------- */
                     nWritten += 6;
                     fwrite("\r\n--- ", 1, 6, fp);
                     EolType = 2;
                     break;
               }
            }
                              /* --------------------------------------
                                 Skip command line
                                 -------------------------------------- */
            while (*p && *p != '\n') ++p;
            if (*p) ++p;
            pBody = p;
         }
         else
         {
                              /* --------------------------------------
                                 Regular line - find its end and write
                                 the line.
                                 -------------------------------------- */
            NextEol = 2; /* in LED 1.0 sind keine Soft-Returns mehr! */
            while (*p && *p != '\n')
            {
               if (*p == '>' || *p == '\1') NextEol = 2;
               if (*p == ST_ESSZET) *p = PC_ESSZET;
               ++p;
            }
            if (*(p - 1) != '-' && *(p - 1) != ' ') NextEol = 2;

            switch (EolType)
            {
               case 0:     /* no previous line */
                  break;

               case 1:     /* soft return */
                  fwrite("\x8D\x0A", 2, 1, fp);
                  nWritten += 2;
                  break;

               case 2:     /* hard return */
                  fwrite("\x0D\x0A", 2, 1, fp);
                  nWritten += 2;
                  break;
            }

            EolType = SoftReturn ? NextEol : 2;
            nWritten += (BodySize = p - pBody);
            fwrite(pBody, 1, BodySize, fp);
            if (*p) ++p;
            pBody = p;
         }
      }

                           /* -----------------------------------------
                              Write End-Of-Message, make sure that the
                              correct number of characters has been
                              written.
                              ----------------------------------------- */
      nWritten += 3;
      fwrite("\x0D\x0A", 1, 3, fp);
      if (ftell(fp) != MsgStart + nWritten)
      {
         ShowError(pHost->nmPkt, szWriteError);
         exit(7);
      }

      if (CrashMail || pHeader->wFlags & MF_WITHFILE)
      {
         fwrite("\0\0", 2, 1, fp);
         fclose(fp);
         if (pHeader->wFlags & MF_WITHFILE)
         {
            if (CrashMail)
            {
               WriteFlowFileEntry(pHeader->wToZone,
                                 pHeader->wToNet,
                                 pHeader->wToNode,
                                 pHeader->wToPoint,
                                 NULL,
                                 nmCrashPkt,
                                 FF_CLO);
            }
            else
            {
               WriteFlowFileEntry(pHost->BossZone,
                                 pHost->BossNet,
                                 pHost->BossNode,
                                 0,
                                 pHost->pDomain,
                                 nmCrashPkt,
                                 FF_FLO);
            }
         }
         else
         {
            PackCrashMail(pHeader->wToZone, pHeader->wToNet,
                          pHeader->wToNode, pHeader->wToPoint,
                          nmCrashPkt, pHost);
         }
      }
      else
      {
         if (pHost != pActiveHost)
         {
            fclose(pHost->fpPkt);
            pHost->fpPkt = NULL;
         }
      }
   }
                           /* -----------------------------------------
                              release memory, mark message sent, make
                              sure to write headers.
                              ----------------------------------------- */
   free(pMessage);
   pHeader->wFlags |= MF_SENT;
   WriteHeader = TRUE;

   return TRUE;
}



/* --------------------------------------------------------------------
      ProcessHeader

      runs through message headers and exports, deletes or otherwise
      marks them.
   -------------------------------------------------------------------- */
void  ProcessHeader(void)
{
   MSG_HEADER     *pIn;
   int            nSent;
   int            nWritten;
   int            nDeleted;
   int            nOld;
   int            n;
   long           gDeadline;
   long           lDeadline;
   unsigned long  u;
   BOOL           ShowWritten;
   /* char           log[80]; */

   ShowWritten = TRUE;
   gDeadline   = time(NULL);
   gDeadline   = gDeadline - gDeadline % 86400;

   u = 86400UL * pActiveArea->DaysLocal;
   lDeadline = (u > gDeadline) ? 0 : gDeadline - u;
   u = 86400UL * pActiveArea->Days;
   gDeadline = (u > gDeadline) ? 0 : gDeadline - u;

   nSent       = 0;
   nWritten    = 0;
   nOld        = 0;
   nDeleted    = 0;

   for (n = nHeader, pIn = pHeader; n--; pIn++)
   {
      if (pIn->szFrom[0] == 0)
      {
         pIn->szFrom[0] = '?';
         WriteHeader = TRUE;
      }
                              /* --------------------------------------
                                 Delete old messages unless they are
                                 marked local or hold.
                                 -------------------------------------- */
      if (Crunch && nHeader - n <= pActiveArea->LastRead
      &&  pIn->lDate < ((pIn->wFlags & MF_LOCAL) ? lDeadline : gDeadline))
      {
         if ((pActiveArea->KillHold  || (pIn->wFlags & MF_HOLD)  == 0)
         &&  (pActiveArea->KillLocal || (pIn->wFlags & MF_LOCAL) == 0))
         {
            if ((pIn->wFlags & MF_DELETED) == 0)
            {
               pIn->wFlags |= MF_DELETED;
               WriteHeader   = TRUE;
            }
            ++nOld;
            if (ShowWritten)
            {
               ShowWritten = FALSE;
            }
         }
      }

                              /* --------------------------------------
                                 Delete temporary messages after they
                                 have been sent.
                                 -------------------------------------- */
      if ((pIn->wFlags & (MF_SENT | MF_KILLIFSENT)) == (MF_SENT | MF_KILLIFSENT))
      {
         if ((pIn->wFlags & MF_DELETED) == 0)
         {
            pIn->wFlags |= MF_DELETED;
            WriteHeader   = TRUE;
         }
      }

                              /* --------------------------------------
                                 Export local messages unless they are
                                 deleted, marked for hold, or allready
                                 sent.
                                 -------------------------------------- */
      if ((pIn->wFlags & (MF_SENT | MF_DELETED | MF_HOLD)) == 0)
         if (pIn->wFlags & ExportFlags)
            if (ExportMessage(pIn))
               nSent++;

      if (pIn->wFlags & MF_DELETED)
      {
                              /* -------------------------------------
                                 deleted message - update last read
                                 pointer for LED.
                                 ------------------------------------- */
         ++nDeleted;
         if (ShowWritten)
         {
            ShowWritten = FALSE;
         }
      }
      else
      {
                              /* --------------------------------------
                                 keep message - if a previous message
                                 has been deleted, this msg moves down
                                 in the header array. Both headers and
                                 msgs must be updated on disk, then.
                                 -------------------------------------- */
         ShowWritten = TRUE;
         nWritten++;
      }
   }

   if (nWritten < pActiveArea->LowMessageCount && !PackAreas)
   {
      for (n = nHeader, pIn = pHeader + n;
           pIn--, n-- && nWritten < pActiveArea->LowMessageCount; )
      {
         if (pIn->wFlags & MF_DELETED)
         {
            pIn->wFlags &= ~(MF_DELETED | MF_LOCAL);
            WriteHeader = TRUE;
            ++nWritten;
            --nDeleted;
         }
      }
   }

   if (pActiveArea->HighMessageCount > 0 &&
       pActiveArea->HighMessageCount < nWritten)
   {
      WORD  cnt;

      cnt = nWritten - pActiveArea->HighMessageCount;
      for (n = nHeader, pIn = pHeader; n-- && cnt; pIn++)
      {
         if (!(pIn->wFlags & MF_DELETED))
         {
            if (!(pIn->wFlags & MF_HOLD))
            {
               pIn->wFlags |= MF_DELETED;
               WriteHeader  = TRUE;
               --nWritten;
               ++nDeleted;
            }
            --cnt;
         }
      }
   }

   CrunchHeader  = nDeleted > 0
         && (Crunch && nDeleted >= pActiveArea->CrunchLimit || PackAreas);
   WriteMessages = (Compress && nSent > 0) || CrunchHeader;

                              /* -------------------------------------
                                 close paket file
                                 ------------------------------------- */
   if (pActiveHost->fpPkt != NULL)
   {
      fclose(pActiveHost->fpPkt);
      pActiveHost->fpPkt = NULL;
   }

   pActiveArea->ReadHeaders    = nHeader;
   pActiveArea->WrittenHeaders = nWritten;
   pActiveArea->SentMails      = nSent;
   pActiveArea->OldMails       = nOld;
   pActiveArea->DeletedMails   = nDeleted;
}



/* --------------------------------------------------------------------
      CopyMessages

      copies the message file removing all gaps in the file, updates
      pointers in header file.
   -------------------------------------------------------------------- */
void  CopyMessages(void)
{
   MSG_HEADER  *p;
   FILE        *fpInput;
   FILE        *fpOutput;
   long        MemSize;
   long        StartInput;
   long        SizeInput;
   long        SizeOutput;
   long        n;
   int         m;
   char        *pBuffer;

   if (PackAreas)
   {
      for (p = pHeader, m = nHeader, n = 0; m--; p++)
      {
         if (n != p->lStart)
         {
            WriteMessages = TRUE;
            break;
         }
         n += p->wSize;
      }
   }
   if (!WriteMessages) return;

                              /* -------------------------------------
                                 open old message file
                                 ------------------------------------- */
   if ((fpInput = fopen(nmMessages, "rb")) == NULL)
   {
      ShowError(nmMessages, strerror(errno));
      return;
   }

                              /* --------------------------------------
                                 create temporary message file
                                 -------------------------------------- */
   if ((fpOutput = fopen(nmTempMsg, "wb")) == NULL)
   {
      ShowError(nmTempMsg, strerror(errno));
      fclose(fpInput);
      return;
   }

                              /* -------------------------------------
                                 Try to get all the memory available.
                                 We need at least 1024 bytes.
                                 ------------------------------------- */
   MemSize = coreleft() - 1024;
   if (MemSize < 1024)
   {
      ShowError("CopyMessages", szOutOfMemory);
      fclose(fpInput);
      fclose(fpOutput);
      return;
   }
   pBuffer = malloc(MemSize);
   if (pBuffer == NULL)
   {
      ShowError("CopyMessages", szOutOfMemory);
      fclose(fpInput);
      fclose(fpOutput);
      return;
   }

                              /* --------------------------------------
                                 Copy message file.
                                 Examines headers and tries to read
                                 and write chunks as big as possible.
                                 Copying could be done easier, but this
                                 should be faster.
                                 -------------------------------------- */
   StartInput  = 0;
   SizeInput   = 0;
   SizeOutput  = 0;
   for (m = nHeader, p = pHeader; m--; p++)
   {
      if ((p->wFlags & MF_DELETED) == 0 || !CrunchHeader)
      {
         if (StartInput + SizeInput != p->lStart)
         {
            fseek(fpInput, StartInput, SEEK_SET);
            while (SizeInput > 0)
            {
               n = (SizeInput > MemSize - SizeOutput)
                   ? MemSize - SizeOutput
                   : SizeInput;
               if (fread(pBuffer + SizeOutput, 1, n, fpInput) < n)
               {
                  ShowError(nmMessages, szReadError);
                  goto fault;
               }
               SizeInput  -= n;
               SizeOutput += n;
               if (SizeOutput >= MemSize)
               {
                  if (fwrite(pBuffer, 1, SizeOutput, fpOutput) < SizeOutput)
                  {
                     ShowError(nmTempMsg, szWriteError);
                     goto fault;
                  }
                  SizeOutput = 0;
               }
            }
            StartInput = p->lStart;
            SizeInput  = 0;
         }
         SizeInput   += p->wSize;
      }
   }

                              /* -------------------------------------
                                 Flush buffer
                                 ------------------------------------- */
   if (SizeInput)
   {
      fseek(fpInput, StartInput, SEEK_SET);
      while (SizeInput > 0)
      {
         n = (SizeInput > MemSize - SizeOutput)
             ? MemSize - SizeOutput
             : SizeInput;
         if (fread(pBuffer + SizeOutput, 1, n, fpInput) < n)
         {
            ShowError(nmMessages, szReadError);
            goto fault;
         }
         SizeInput  -= n;
         SizeOutput += n;
         if (fwrite(pBuffer, 1, SizeOutput, fpOutput) < SizeOutput)
         {
            ShowError(nmTempMsg, szWriteError);
            goto fault;
         }
         SizeOutput = 0;
      }
   }

   if (SizeOutput)
   {
      if (fwrite(pBuffer, 1, SizeOutput, fpOutput) < SizeOutput)
      {
         ShowError(nmTempMsg, szWriteError);
         goto fault;
      }
   }

   NewMessages = TRUE;

fault:
                              /* --------------------------------------
                                 Close files and free buffer.
                                 -------------------------------------- */
   fclose(fpInput);
   fclose(fpOutput);
   free(pBuffer);
}



/* -------------------------------------------------------------------
      SaveHeader

      resets all update flags and writes a temporary header file.

      Returns:
      --------
         TRUE  iff header has been written successfully.
   ------------------------------------------------------------------- */
BOOL  SaveHeader(void)
{
   MSG_HEADER  *pIn;
   MSG_HEADER  *pOut;
   FILE        *fp;
   int         i;
   long        pos;
   int         AreaNo;

   {
      char *s;
      char *c;
      
      s = strrchr(pActiveArea->pFilename, '\\');
      if (s == NULL) s = pActiveArea->pFilename;
      c = strchr(s, ':');
      c = ((c == NULL) ? s : c) + 1;
      AreaNo = atoi(c) - 1;
   }

   if (CrunchHeader)
   {
      for (pIn = pOut = pHeader, i = nHeader; i; i--, pIn++)
      {
         if ((pIn->wFlags & MF_DELETED) == 0)
         {
            *pOut++ = *pIn;
         }
         else
         {
            int MsgNo = (int) (pOut - pHeader);
            --nHeader;
            qbbsUpdateLastRead(AreaNo, MsgNo);
            if (pActiveArea->LastRead > MsgNo)
            {
               --pActiveArea->LastRead;
            }
         }
      }
   }

   if (NewMessages)
   {
      pos = 0;
      for (pIn = pHeader, i = nHeader; i; i--, pIn++)
      {
         pIn->lStart = pos;
         pos += pIn->wSize;
      }
   }

   if ((fp = fopen(nmTempHdr, "wb")) == NULL)
   {
      ShowError(nmTempHdr, strerror(errno));
      NewMessages = FALSE;
      return FALSE;
   }

   if (fwrite(pHeader, sizeof(*pHeader), nHeader, fp) < nHeader)
   {
      ShowError("SaveHeader", szWriteError);
      fclose(fp);
      NewMessages = FALSE;
      return FALSE;
   }

   NewHeader = TRUE;
   fclose(fp);
   return TRUE;
}



/* --------------------------------------------------------------------
   ClearAttribute

   resets (or sets on older TOSs) the archive bit of the specified file.
   --------------------------------------------------------------------- */
void ClearAttribute(char *name)
{
   #if !defined(__TOS__)
      #define Fattrib   _chmod
   #endif
   int old;
   extern BOOL NewTos;

   old = Fattrib(name, 0, 0);

   if (NewTos)
      old &= ~FA_ARCH;
   else
      old |= FA_ARCH;

   Fattrib(name, 1, old);
}



/* --------------------------------------------------------------------
      UpdateMessageBase

      removes old header and/or message file and renames temporary
      files.
   -------------------------------------------------------------------- */
void  UpdateMessageBase(void)
{
   if (NewMessages)
   {
      if (remove(nmMessages) < 0)
      {
         ShowError(nmMessages, strerror(errno));
         return;
      }
      if (rename(nmTempMsg, nmMessages) < 0)
      {
         ShowError(nmTempMsg, strerror(errno));
         return;
      }
   }

   if (NewHeader)
   {
      if (remove(nmHeader) < 0)
      {
         ShowError(nmHeader, strerror(errno));
         return;
      }
      if (rename(nmTempHdr, nmHeader) < 0)
      {
         ShowError(nmTempHdr, strerror(errno));
         return;
      }
   }

   ClearAttribute(nmHeader);
   ClearAttribute(nmMessages);
   pActiveArea->NewHeader = NewHeader || NewMessages;
}



/* --------------------------------------------------------------------
      ExportArea

      exports and updates the specified area.

      Input:
      ------
      AREAPARAM *pArea
         address of area's parameter record.
   -------------------------------------------------------------------- */
void  ExportArea(AREAPARAM *pArea)
{
                              /* --------------------------------------
                                 Create filenames of header and message
                                 files and the temporary files.
                                 -------------------------------------- */
   strcat(strcpy(nmMessages, pArea->pFilename), ".MSG");
   strcat(strcpy(nmHeader,   pArea->pFilename), ".HDR");
   strcat(strcpy(nmTempHdr,  pArea->pFilename), ".H$$");
   strcat(strcpy(nmTempMsg,  pArea->pFilename), ".M$$");

   if (QuickScan && !Crunch)
   {
      int ath;
      struct ffblk fileinfo;
      extern BOOL NewTos;

      if (findfirst(nmHeader, &fileinfo, 0) != 0)
      {
         ShowError(nmHeader, strerror(errno));
         return;
      }
      ath = fileinfo.ff_attrib;

      if (findfirst(nmMessages, &fileinfo, 0) != 0)
      {
         ShowError(nmMessages, strerror(errno));
         return;
      }
      ath = NewTos ? (ath | fileinfo.ff_attrib)
                   : (ath & fileinfo.ff_attrib) ^ FA_ARCH;

      if ((ath & FA_ARCH) == 0) return;
   }

   pActiveArea    = pArea;
   pActiveHost    = pArea->pHost;
   WriteHeader    = FALSE;
   WriteMessages  = FALSE;
   NewHeader      = FALSE;
   NewMessages    = FALSE;
   CrunchHeader   = FALSE;

                              /* --------------------------------------
                                 Load and process header file. Save
                                 and rename if required.
                                 -------------------------------------- */
   if (LoadHeader())
   {
      if ((fpMessages = fopen(nmMessages, "rb+")) == NULL)
      {
         ShowError(nmMessages, strerror(errno));
      }
      else
      {
         if (StoreCrc)
         {
            MarkDupes();
         }
         ProcessHeader();
         fclose(fpMessages);
         if (WriteMessages || PackAreas) CopyMessages();
         if (WriteHeader || CrunchHeader || NewMessages) SaveHeader();
         UpdateMessageBase();
      }
      free(pHeader);
   }

   remove(nmTempHdr);
   remove(nmTempMsg);
}



/* --------------------------------------------------------------------
   CreateBundleName
   -------------------------------------------------------------------- */
void CreateBundleName(char *pName, HOSTPARAM *pHost,
   WORD zone, WORD net, WORD node, WORD point,
   WORD type)
{
   char  CrcInput[33];
   long        lt;
   struct tm   *tm;

   time(&lt);
   tm = gmtime(&lt);

   if (!CrashPoints) point = 0;

   if (CreateTB == FFF_IOS)
   {
      MakeIosName(pName, zone, net, node, point, NULL);
      strcat(pName, (type == FF_FLO) ? "OAT" : "CAT");
   }
   else
   {
      sprintf(CrcInput, "%.4X%.4X%.4X%.4X%.4X%.4X%.4X%.4X",
                     zone, net, node, point,
                     pHost->FakeZone,
                     pHost->FakeNet,
                     pHost->FakeNode,
                     pHost->Point);
      sprintf(pName, "%s%.4X%.2X%.2X.%s",
                     OutboundFolder(zone, NULL),
                     sCalcCrc(CrcInput),
                     net  & 0x00FF,
                     node & 0x00FF,
                     szExtension[tm->tm_wday]);
   }
}



/* --------------------------------------------------------------------
   AddToArchive
   -------------------------------------------------------------------- */
BOOL AddToArchive(WORD zone, char *pTemplate, char *pBundle, char *pPacket)
{
   char    ArcCmd[256];
   COMMAND CmdLine;
   char    *p;
   char    *q;
   long    arcres;

   for (q = pTemplate, p = ArcCmd; *q; ++q)
   {
      if (*q == '%')
         switch (*(++q))
         {
            case 'd':
               p = strchr(strcpy(p, OutboundFolder(zone, NULL)), 0);
               break;

            case 'n':
               p = strchr(strcpy(p, pBundle), 0);
               break;

            case 'p':
               p = strchr(strcpy(p, pPacket), 0);
               break;

            case '%':
               *p++ = '%';
               break;
         }
      else
         *p++ = *q;
   }
   *p++ = ' ';
   *p   = '\0';

   #if defined(__TOS__)
      p = strchr(ArcCmd, ' ');
      strcpy (CmdLine.command_tail, p + 1);
      *p = (char) 0;
      CmdLine.length = (unsigned char) strlen (CmdLine.command_tail);

                        /* --------------------------------------
                           Create Arcmail
                           -------------------------------------- */
      arcres = Pexec (0, ArcCmd, &CmdLine, NULL);

      if (arcres != 0) {
         char ErrMsg[32];
         *p = ' ';
         sprintf(ErrMsg, "non-zero exit code: %d", arcres);
         ShowError(ArcCmd, ErrMsg);
         return FALSE;
      } else {
         if (DeletePkt) {
               remove(pPacket);
         }
      }
   #else
      system(ArcCmd);
   #endif

   return TRUE;
}



/* --------------------------------------------------------------------
      ClosePakets

      appends end-of-file records to all paket files, creates arcmail
      and writes flow files.
   -------------------------------------------------------------------- */
void  ClosePackets(void)
{
   HOSTPARAM   *pHost;
   char        szOutDir[FILENAME_MAX];
   char        szName[33];
   char        *pName;
   char        *pTemplate;
   FILE        *fp;
   long        lt;
   struct tm   *tm;

   time(&lt);
   tm = gmtime(&lt);

                              /* --------------------------------------
                                 Create templates for flow file entry
                                 and arc's command line
                                 -------------------------------------- */
   szOutDir[0] = '^';
   getcwd(szOutDir + 1, (int) sizeof(szOutDir) - 1);
   pName = szOutDir + strlen(szOutDir);
   if (*(pName - 1) != '\\') *pName++ = '\\';

   for (pHost = pFirstHost; pHost != NULL; pHost = pHost->pNext)
   {
      BOOL DontPack = FALSE;
      if (CreateDummyCmd != 0)
      {
         if ((CreateDummyCmd > 0 || CreateDummyFlo || pHost->DummyFlow)
            && !pHost->NoOutput
            && pHost->nmPkt == NULL)
         {

            FILE *fp;
            if (pHost->DummyFlow >= 2
            ||  pHost->DummyFlow == 0 && CreateDummyFlo >= 2)
            {
               fp = CreateCrashPkt(pHost,
                     pHost->BossZone, pHost->BossNet, pHost->BossNode, 0);
               DontPack = pHost->DummyFlow == 2
                     || pHost->DummyFlow == 0 && CreateDummyFlo == 2;
            }
            else
               fp = NULL;
            if (fp != NULL)
            {
               fwrite("\0", 2, 1, fp);
               fclose(fp);
               pHost->nmPkt = nmCrashPkt + 1;
            }
            else 
               WriteFlowFileEntry(pHost->BossZone,
                                 pHost->BossNet,
                                 pHost->BossNode,
                                 0,
                                 pHost->pDomain,
                                 "",
                                 FF_FLO);
         }
      }

      if (pHost->nmPkt != NULL)
      {
         WORD  zone, net, node, point;
         char  *domain;
         HOSTPARAM *p;
         
         zone   = pHost->BossZone;
         net    = pHost->BossNet;
         node   = pHost->BossNode;
         point  = 0;
         domain = pHost->pDomain;
         while (point == 0
            &&  (p = FindHost(zone, net, node)) != NULL
            &&  p->Route)
         {
            zone   = p->RouteZone;
            net    = p->RouteNet;
            node   = p->RouteNode;
            point  = p->RoutePoint;
            domain = p->RouteDomain;
         }
         if (point != 0) p = NULL;
         
         pTemplate = (p == NULL || p->pArcCmd == NULL)
                     ? szArcOut
                     : p->pArcCmd;

         if ((fp = pHost->fpPkt) == NULL)
         {
                              /* --------------------------------------
                                 Open paket file
                                 -------------------------------------- */
            if ((fp = fopen(pHost->nmPkt, "ab")) == NULL)
            {
               ShowError(pHost->nmPkt, strerror(errno));
               continue;
            }
         }

                              /* --------------------------------------
                                 Write end-of-file record
                                 -------------------------------------- */
         if (fwrite("\0", 1, 2, fp) < 2)
         {
            ShowError(pHost->nmPkt, szWriteError);
            fclose(fp);
            continue;
         }

                              /* -------------------------------------
                                 Close paket file
                                 ------------------------------------- */
         fclose(fp);

                              /* --------------------------------------
                                 don't create packet if host is read-
                                 only
                                 -------------------------------------- */
         if (pHost->NoOutput)
         {
            remove(pHost->nmPkt);
            continue;
         }
                              /* --------------------------------------
                                 Create command line for arcmail
                                 -------------------------------------- */
         if (pHost->pArcMailName == NULL)
         {
            CreateBundleName(szName, pHost, zone, net, node, point, FF_FLO);
         }
         else
         {
            sprintf(szName, "%s%s.%s",
                           OutboundFolder(zone, domain),
                           pHost->pArcMailName,
                           szExtension[tm->tm_wday]);
         }

         {
            char  *pBundle;
            BOOL  ok;

            if (pTemplate[0] == '%' && pTemplate[1] == '\0' || DontPack)
            {
               ok = TRUE;
               pBundle = pHost->nmPkt;
            }
            else
            {
               ok = AddToArchive(zone, pTemplate, szName, pHost->nmPkt);
               pBundle = szName;
            }

            if (ok)
            {
                                 /* --------------------------------------
                                    Write flow file entry
                                    -------------------------------------- */
               if (pBundle[0] == '\\' || pBundle[1] == ':' && pBundle[0] != '\0')
               {
                  char *p;
                  *pName = '^';
                  p = strchr(strcpy(pName + 1, pBundle), ' ');
                  if (p != NULL) *p = '\0';
                  if (CreateTB != FFF_IOS || pHost->pArcMailName != NULL)
                     WriteFlowFileEntry(zone, net, node, point, domain,
                                       pName, FF_FLO);
               }
               else
               {
                  char *p = strchr(strcpy(pName, pBundle), ' ');
                  if (p != NULL) *p = 0;
                  if (CreateTB != FFF_IOS)
                     WriteFlowFileEntry(zone, net, node, point, domain,
                                       szOutDir, FF_FLO);
               }
            }
         }
      }
   }
}



/* --------------------------------------------------------------------
   PackCrashMail
   -------------------------------------------------------------------- */
void PackCrashMail(WORD zone, WORD net, WORD node, WORD point,
                   char *pPacketName, HOSTPARAM *pHost)
{
   char  nmBundle[FILENAME_MAX];
   BOOL  NewBundle;

   if (ArcedCrashMail)
   {
      nmBundle[0] = '^';
      CreateBundleName(nmBundle + 1, pHost, zone, net, node, point, FF_CLO);
      NewBundle = access(nmBundle + 1, 0) != 0;
      if (AddToArchive(zone, szArcOut, nmBundle + 1, pPacketName + 1))
      {
         remove(pPacketName + 1);
         if (NewBundle && CreateTB != FFF_IOS)
            WriteFlowFileEntry(zone, net, node, point, NULL, nmBundle, FF_CLO);
      }
      return;
   }

   WriteFlowFileEntry(zone, net, node, point, NULL, pPacketName, FF_CLO);
}



/* ---------------------------------------------------------------------
      AppendTbFlow

      reads TB style flow files and appends them to the corresponding
      Binkley flow files
   --------------------------------------------------------------------- */
void  AppendTbFlow(void)
{
   static char *TBextension[]  = { "*.AF", "*.IF", "*.WF", NULL };
            /* die Reihenfolge FLO, CLO, HLO muž unbedingt eingehalten werden */
   struct ffblk   fileinfo;
   char  nmTBflow[FILENAME_MAX];
   char  nmBTflow[FILENAME_MAX];
   char  *pName;
   int   type;
   int   done;
   int   i;
   int   net;
   int   node;
   int   zone;
   FILE  *fpTheBox;
   FILE  *fpBinkley;

   if (CreateTB == FFF_THEBOX) return;

   for (type = 0; TBextension[type] != NULL; type++)
   {
      strcpy(nmTBflow, szOutbound);
      pName = nmTBflow + strlen(nmTBflow);
      strcpy(pName, TBextension[type]);

      done = findfirst(nmBTflow, &fileinfo, 0);
      while (!done)
      {
         strcpy(pName, fileinfo.ff_name);
         fpTheBox = fopen(nmTBflow, "r");
         if (fpTheBox != NULL)
         {
            #define digval(x) ((x) - (((x) >= 'A') ? 'A' - 10 : '0'))
            WriteLogfile(nmBTflow);
            for (i = 0, net = node = 0; i < 3; i++)
            {
               net =  36 * net  + digval(pName[i + 2]);
               node = 36 * node + digval(pName[i + 5]);
            }
            zone = 36 * digval(pName[0]) + digval(pName[1]);
            #undef digval;
            MakeFlowFileName(nmBTflow, zone, net, node, 0, NULL, type);
            fpBinkley = fopen(nmBTflow, "a");
            if (fpBinkley != NULL)
            {
               while (ReadLine(nmBTflow, (int) sizeof(nmBTflow), fpTheBox))
               {
                  fprintf(fpBinkley, "%s\n", nmBTflow);
               }
               fclose(fpBinkley);
               fclose(fpTheBox);
               remove(nmTBflow);
            }
            else
            {
               ShowError(nmBTflow, strerror(errno));
               fclose(fpTheBox);
            }
            *(pName - 1) = '\\';
         }
         else
         {
            ShowError(nmBTflow, strerror(errno));
         }
         done = findnext(&fileinfo);
      }
   }
}
