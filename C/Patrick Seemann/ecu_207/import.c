/* --------------------------------------------------------------------
   Module:     IMPORT.C
   Subject:    the working module of Llegada
   Author:     ho
   Started:    18.12.1990  10:54:06
   --------------------------------------------------------------------
   94-04-18ps  Wenn beim Aufruf eines Packers (via Pexec()) ein Fehler
               auftritt (typischerweise -33 "File not found"), wird
               das Archiv nicht mehr gelîscht sondern nur eine Fehler-
               meldung ausgegeben.
   93-07-31ps  Leere/unbekannte Archive fÅhren nicht mehr zum Absturz.
   93-06-19ps  Beim Importieren werden die Msgs innerhalb eines PKTs
               gezÑhlt
   92-10-17ps  Beim Packeraufruf wird das Environment weitergereicht
               GEM-AbhÑngigkeiten entfernt
   92-06-18ps  Kommentarverkettung fÅr LED
   --------------------------------------------------------------------
   26.02.1992  Beim Lîschen von Bundles darauf achten, da· die Datei im
               aktuellen Verzeichnis gelîscht werden mu·, wenn zum Aus-
               packen ins Inbound-Verzeichnis gewechselt wurde. (tnx to
               Martin VorlÑnder)
   06.02.1992  Fehlermeldung, wenn Bundle nicht gelîscht werden kann
   28.11.1991  GetAddress, Get4dAddress: zusÑtzlicher Parameter fÅr
               Domainname
   27.11.1991  Pakete vor Umbenennen oder Lîschen schlie·en
   03.11.1991  Leerzeichen in AREA-Zeile zulassen (au·er das erste)
   28.09.1991  WhichArc
   19.09.1991  NewAreaDirectory
   19.09.1991  don't count messages to SYSOP in SysopMessages
   19.07.1991  set LED's sysop flag if mail to sysop received
   01.05.1991  don't keep CR/LF if AREA: is stripped
               delete ArcMail if Llegada runs in inbound folder
               optionally delete ArcMail even if unpack failed
   21.04.1991  take care of packets larger than memory
   14.04.1991  don't change to inbound directory if szArcIn contains %
   19.02.1991  AREA: must be first non-kludge line to be recognized
   -------------------------------------------------------------------- */

/*#define DEBUG*/

#include <assert.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <process.h>
#include <ctype.h>
#include <time.h>

#if defined(__TOS__)
   #include <tos.h>
   #include <ext.h>
#else
   #include <dir.h>
   #include <alloc.h>
   #include <io.h>
#endif

#include "clib.h"

#include "global.h"
#include "llegadef.h"


#if defined(__TOS__)
   #ifdef DEBUG
      #define  MEM_RESERVE    (128L * 1024)
      #define  MEM_REQUIRED   (8L   * 1024)
   #else
      #define  MEM_RESERVE    (64L   * 1024)
      #define  MEM_REQUIRED   (128L * 1024)
   #endif
#else
   #define MEM_RESERVE     (2L * 1024)
   #define MEM_REQUIRED    (8L * 1024)
#endif

#define  VALIDATE_MIN   (4L   * 1024)

#if defined(__TOS__)
   #define  swap(x) (((unsigned)(x) << 8) | ((unsigned)(x) >> 8))
#else
   #define  swap(x)     (x)
#endif
#define  GetWord(x) ((*(BYTE *)(x)) | ((WORD)(*(BYTE *)((x)+1)) << 8))


typedef
   struct
   {
      LONG  date;
      char  name[size_of(struct ffblk, ff_name)];
   }  PACKET;


static char *pArcCmds[] =
            {
               szDefaultIn,
               szArcIn,
               szZooIn,
               szZipIn,
               szLhaIn,
               szArjIn,
               szLharcIn,
            };
static char *pCurrentPacket;
static int  MessageCount = 0;
static int  SysopMessages = 0;

static   AREAPARAM   *pActiveArea = NULL;
static   FILE        *fpHeader = NULL;
static   FILE        *fpMessages = NULL;
static   char        szMessages[FILENAME_MAX];
static   char        szHeader[FILENAME_MAX];
static   PKTHDR      PktHeader;

size_t   BufferSize;
size_t   BytesInBuffer;
long     PacketSize;
FILE     *fpPacket;
BYTE     *BufferStart;
BYTE     *MessageStart;



void UnpackArchives(void)
{
   static char *pPatList[] =
      { "*.MO?", "*.TU?", "*.WE?", "*.TH?", "*.FR?", "*.SA?", "*.SU?", NULL };

   char cmdline[256];
   COMMAND CmdLine;
   char archiv[FILENAME_MAX];
   char *q;
   char **p;
   BOOL ChangeToInbound;
   int done;
   int type;
   long arcres;
   struct ffblk fileinfo;

   for (p = pPatList; *p != NULL; ++p)
   {
      q = strchr(strcpy(cmdline, szInbound), 0);
      if (szInbound[0] && *(q - 1) != '\\') *q++ = '\\';
      strcpy(q, *p);
      done = findfirst(cmdline, &fileinfo, 0);
      while (!done)
      {
         BuildFilename(archiv, -1, szInbound, fileinfo.ff_name, "");
         type = WhichArc(archiv);
         if ((type == -1) || (type == UNKNOWN)) {
            ShowError (archiv, "unknown archive type");
            
         } else {
            char *p;
            char *q;

            p = pArcCmds[type];
            q = cmdline;

#pragma warn -pia
            if (ChangeToInbound = (*p == '%'))
#pragma warn .pia
            {
               ++p;
               setcwd(szInbound);
            }
            do
            {
               if (*p == '%')
               {
                  switch (tolower(*(p + 1)))
                  {
                     case 'd':
                        q = strchr(strcpy(q, szInbound), 0);
                        p++;
                        break;

                     case 'p':
                        q = strchr(strcpy(q, fileinfo.ff_name), 0);
                        p++;
                        break;

                     case 'n':
                        q = strchr(strcpy(q, archiv), 0);
                        p++;
                        break;

                     case '%':
                        *q++ = *p++;
                        break;

                     default:
                        *q++ = '%';
                        break;
                  }
               }
               else
               {
                  *q++ = *p;
               }
            }
            while (*p++);
            WriteLogfile(cmdline);
         #if defined(__TOS__)
            q = strchr(cmdline, ' ');
            if (q != NULL) {
               strcpy (CmdLine.command_tail, q + 1);
               *q = '\0';
               CmdLine.length = (unsigned char) strlen (CmdLine.command_tail);
            } else {
               CmdLine.length = 0;
               CmdLine.command_tail[0] = '\0';
            }

            arcres = Pexec(0, cmdline, &CmdLine, NULL);

            if ((arcres > GoodUnpackReturn) || (arcres < 0)) {
               char error[64];
               if (q != NULL) *q = ' ';
               sprintf (error, "non-zero exit code: %ld", arcres);
               ShowError(cmdline, error);

            } else if (remove(ChangeToInbound ? fileinfo.ff_name : archiv) < 0) {
               ShowError(ChangeToInbound ? fileinfo.ff_name : archiv,
                         strerror(errno));
            }
         #else
            system(cmdline);
         #endif
            if (ChangeToInbound) setcwd(szHomeDir);

         }
         done = findnext(&fileinfo);
      }
   }
}



BOOL IsGoodMessage(void)
{
   int   i;
   BYTE  *pTime;
   BYTE  *pTo;
   BYTE  *pFrom;
   BYTE  *pSubj;
   BYTE  *pMsg;
   BYTE  *pNext;

   if (MessageStart + VALIDATE_MIN > BufferStart + BytesInBuffer)
   {
      long  n;
      assert(BytesInBuffer >= MessageStart - BufferStart);
      memcpy(BufferStart,
             MessageStart - 2,
             BytesInBuffer -= (MessageStart - 2 - BufferStart));
      MessageStart = BufferStart + 2;
      n = fread(BufferStart + BytesInBuffer,
                sizeof(BYTE),
                BufferSize - BytesInBuffer,
                fpPacket);
      BytesInBuffer += n;
      memset(BufferStart + BytesInBuffer, 0, 8);
   }

   if (GetWord(MessageStart) != 2) return FALSE;

   pTime = MessageStart + 14;
   pTo   = pTime + strlen(pTime) + 1;
   pFrom = pTo   + strlen(pTo)   + 1;
   pSubj = pFrom + strlen(pFrom) + 1;
   pMsg  = pSubj + strlen(pSubj) + 1;
   pNext = pMsg  + strlen(pMsg)  + 1;

   if ((i = GetWord(pNext)) == 2 || i == 0) return TRUE;

   if (strlen(pTime) > 20 ||
       strlen(pTo)   > 36 ||
       strlen(pFrom) > 36 ||
       strlen(pSubj) > 72) return FALSE;

   /* more tests may go here */

   return TRUE;
}


/* --------------------------------------------------------------------
   AREAPARAM *CreateArea(char *pAreatag)

   CreateArea erzeugt einen neuen Eintrag in der Arealiste. Die einzige
   Information, die dafÅr zur VerfÅgung steht ist das Area-Tag. Daraus
   wird auch der Name der Area-Datei abgeleitet. Den Eintrag in
   AREAS.BBS mu· der Sysop selbst vornehmen. Er bekommt nur eine ent-
   sprechende Meldung in seinem Logfile.
   -------------------------------------------------------------------- */
AREAPARAM *CreateArea(char *pAreatag)
{
   AREAPARAM   *pArea;
   FILE        *fp;
   char        *p;
   char        *q;
   char        buffer[256];
   int         i;

   ShowError(pAreatag, "don't know about this area");
   p = strchr(szNewAreaDir, 0);
   if (p == szNewAreaDir) return pBadMsgArea;
   if (*(p - 1) != '\\') *p++ = '\\';
   for (i = 0, q = pAreatag; i < 8 && *q; q++)
   {
      if (isalnum(*q)) *(p + i++) = *q;
   }
   if (i == 0) return pBadMsgArea;
   *(p + i) = '\0';

   {
      /* newareadir\xxxxxxxx                          */
      /*            p       p+i (i != 0)              */
      char start = p[i - 1];
      AREAPARAM *pArea;
      do
      {
         pArea = pFirstArea;
         while (pArea != NULL)
         {
            char *q = strchr(pArea->pFilename, 0);
            while (q > pArea->pFilename && *(q - 1) != ':' && *(q - 1) != '\\')
               --q;
            if (stricmp(p, q) == 0) break;
            pArea = pArea->pNext;
         }
         if (pArea == NULL) break;
         if (p[i - 1] == '9') p[i - 1] = 'A';
         else if (toupper(p[i - 1]) == 'Z') p[i - 1] = '0';
         else ++p[i - 1];
      }
      while (p[i - 1] != start);
      if (p[i - 1] == start && pArea != NULL) return pBadMsgArea;
   }

   q = strdup(szNewAreaDir);
   *p = '\0';
   if (q == NULL)
   {
      ShowError("CreateArea", szOutOfMemory);
      return pBadMsgArea;
   }

   pArea = AllocateArea(pAreatag);
   if (pArea == NULL)
   {
      free(q);
      ShowError("CreateArea", szOutOfMemory);
      return pBadMsgArea;
   }

   pArea->HostZone  = PktHeader.Xtra.FroDo.OrigZone
                      ? swap(PktHeader.Xtra.FroDo.OrigZone)
                      : PktHeader.Xtra.QM.QMOrigZone
                        ? swap(PktHeader.Xtra.QM.QMOrigZone)
                        : DefaultZone;
   pArea->HostNet   = swap(PktHeader.OrigNet);
   pArea->HostNode  = swap(PktHeader.OrigNode);
   pArea->pAreaname = pArea->pLocalName;
   pArea->pFilename = q;

   BuildFilename(buffer, -1, szHomeDir, szAreasBBS, "");
   fp = fopen(buffer, "a");

   sprintf(buffer, "%s %s %d:%d/%d", q, pAreatag,
                   pArea->HostZone, pArea->HostNet, pArea->HostNode);
   if (fp != NULL)
   {
      fprintf(fp, "%s\n", buffer);
      ShowError("Added to area-list", buffer);
      fclose(fp);
   }
   else
   {
      ShowError("Add to area-list", buffer);
   }

   *p = 0;
   return pArea;
}


BOOL WritePlainText(FILE *fpMessages, MSG_HEADER *pHeader,
                    char *pMessage, char *pAreaname)
{
   char *p;
   char *q;
   BOOL inHeader = TRUE;

   p = q = pMessage;
   while (*p)
   {
      if (*p != '\1')
      {
         if (inHeader)
         {
            if (strnicmp(p, "AREA:", 5) == 0 && !pActiveArea->KeepArea)
            {
               if (p != q) fwrite(q, sizeof(BYTE), p - q, fpMessages);
               while (*q && *q != 0x0A) ++q;
               if (*q) q++;
            }
            inHeader = FALSE;
         }
      }
      while (*p && *p != 0x0A) ++p;
      if (*p) ++p;
   }
   fwrite(q, sizeof(BYTE), p - q + 1, fpMessages);
   fflush(fpMessages);

   return TRUE;
/*
   PureC testet am Ende einer Funktion, ob auch alle Parameter innerhalb der
   Funktion benîtigt werden. Um eine entsprechende Warnung zu unterdrÅcken,
   muss diese daher am Funktionsende aus- und danach wieder eingeschaltet
   werden...
*/
#pragma warn -par
}
#pragma warn .par



/* --------------------------------------------------------------------
   WriteMessage -- îffnet (wenn nîtig) die Area-Dateien, schreibt die
   Message (mit der angegebenen Callback-Funktion) und schreibt danach
   den Header. Die Callback-Funktion kann den Message-Header Ñndern!
   Das ist nicht nur legal, sondern in einigen FÑllen auch notwendig.
   WriteMessage trÑgt nur den Offset und die LÑnge des Message-Textes
   in den Header ein. Die Callback-Funktion mu· den Text an die momen-
   tane Position schreiben, und nach dem letzten Byte des Textes stehen
   bleiben.
   -------------------------------------------------------------------- */
BOOL WriteMessage(BOOL (* callback)(FILE *, MSG_HEADER *, char *, char *),
                  MSG_HEADER *pHeader, BYTE *pData, char *pAreaname)
{
   BOOL  res = TRUE;
   long  n;

   if (pActiveArea != NULL && stricmp(pActiveArea->pAreaname, pAreaname) != 0)
   {
      fclose(fpHeader);
      fclose(fpMessages);
      pActiveArea = NULL;
   }

   if (pActiveArea == NULL)
   {
      pActiveArea = FindFidoArea(pAreaname);
      if (pActiveArea == NULL)
         pActiveArea = (*pAreaname) ? CreateArea(pAreaname) : pNetmailArea;

RetryOpen:
      BuildFilename(szMessages, -1, szHomeDir, pActiveArea->pFilename, "MSG");
      fpMessages = fopen(szMessages, "ab");
      if (fpMessages == NULL)
      {
         ShowError(szMessages, strerror(errno));
         if (pActiveArea != pBadMsgArea)
         {
            pActiveArea = pBadMsgArea;
            goto RetryOpen;
         }
         pActiveArea = NULL;
         return FALSE;
      }

      BuildFilename(szHeader, -1, szHomeDir, pActiveArea->pFilename, "HDR");
      fpHeader = fopen(szHeader, "rb+");
      if (fpHeader == NULL && errno == ENOENT)
         fpHeader = fopen(szHeader, "wb+");
      if (fpHeader == NULL)
      {
         ShowError(szHeader, strerror(errno));
         fclose(fpMessages);
         if (pActiveArea != pBadMsgArea)
         {
            pActiveArea = pBadMsgArea;
            goto RetryOpen;
         }
         pActiveArea = NULL;
         return FALSE;
      }

      n = filelength(fileno(fpHeader)) / sizeof *pHeader;
      fseek(fpHeader, n * sizeof *pHeader, SEEK_SET);
   }

   ++MessageCount;
   ++pActiveArea->NewMails;
   pActiveArea->LedFlags |= 3;

   {
      SYSOPNAME *p;

      for (p = pSysopName; p != NULL; p = p->pNext)
      {
         if (stricmp(pHeader->szTo, p->pName) == 0)
         {
            pActiveArea->LedFlags |= LED_SYSOP;
            ++pActiveArea->SysopMails;
            ++SysopMessages;
            break;
         }
      }
   }

   fseek(fpMessages, 0, SEEK_END);
   pHeader->lStart = ftell(fpMessages);

   callback(fpMessages, pHeader, pData, pAreaname);
   pHeader->wSize  = ftell(fpMessages) - pHeader->lStart;
   n = fwrite(pHeader, sizeof(MSG_HEADER), 1, fpHeader);
   if (n < 1)
   {
      ShowError(szHeader, strerror(EIO));
      res = FALSE;
   }

   return res;
}



BOOL ImportPacket(void)
{
   MSG_HEADER  MsgHeader;
   char        szArea[32];
   char        szMessage[80];
   char        idString[64];
   BYTE        *pData;
   BYTE        *pFrom;
   BYTE        *pTo;
   long        size;
   long        idlength;
   int         msg_count;
   BOOL        res;
   BOOL        IsEchomail;
   BOOL        NewBuffer;

   fseek(fpPacket, 0, SEEK_SET);
   BytesInBuffer = fread(BufferStart, 1, BufferSize, fpPacket);
   memset(BufferStart + BytesInBuffer, 0, 8);
   memcpy(&PktHeader, BufferStart, sizeof PktHeader);

   sprintf(szMessage, "%s from %d/%d",
                     pCurrentPacket,
                     swap(PktHeader.OrigNet),
                     swap(PktHeader.OrigNode));
   WriteLogfile(szMessage);
   sprintf(szMessage, "   assembled at %.2d-%.2d-%.2d, %.2d:%.2d:%.2d",
                      swap(PktHeader.Year) % 100,
                      swap(PktHeader.Month) + 1,
                      swap(PktHeader.Day),
                      swap(PktHeader.Hour),
                      swap(PktHeader.Minute),
                      swap(PktHeader.Second));
   WriteLogfile(szMessage);

   MessageStart  = BufferStart + sizeof(PKTHDR);
   size = PacketSize;
   if ((size -= sizeof(PKTHDR)) < 0)
   {
      ShowError(pCurrentPacket, "incomplete packet header");
      return FALSE;
   }

   res         = TRUE;
   pActiveArea = NULL;
   msg_count   = 0;

   while (size > (signed long) offsetof(MSGHDR, Data))
   {
      if (IsGoodMessage())
      {
         int n;

         msg_count++;
         pData = MessageStart;
         memset(&MsgHeader, 0, sizeof(MsgHeader));

         MsgHeader.wFromZone = DefaultZone;
         MsgHeader.wFromNode = GetWord(pData + offsetof(MSGHDR, OrigNode));
         MsgHeader.wFromNet  = GetWord(pData + offsetof(MSGHDR, OrigNet));
         MsgHeader.wToZone   = DefaultZone;
         MsgHeader.wToNode   = GetWord(pData + offsetof(MSGHDR, DestNode));
         MsgHeader.wToNet    = GetWord(pData + offsetof(MSGHDR, DestNet));
         MsgHeader.wFlags    = GetWord(pData + offsetof(MSGHDR, Attribute))
                             & ~(MF_DELETED | MF_KILLIFSENT);
         MsgHeader.lDate     = time(NULL);
         pData += offsetof(MSGHDR, Data);
         size  -= offsetof(MSGHDR, Data);

         strncpy(MsgHeader.szDate, pData, sizeof(MsgHeader.szDate) - 1);
         n = (int) strlen (pData) + 1;
         pData += n;
         size  -= n;

         strncpy(MsgHeader.szTo, pData, sizeof(MsgHeader.szTo) - 1);
         n = (int) strlen (pData) + 1;
         pData += n;
         size  -= n;

         strncpy(MsgHeader.szFrom, pData, sizeof(MsgHeader.szFrom) - 1);
         n = (int) strlen (pData) + 1;
         pData += n;
         size  -= n;

         strncpy(MsgHeader.szSubject, pData, sizeof(MsgHeader.szSubject) - 1);
         n = (int) strlen (pData) + 1;
         pData += n;
         size  -= n;

         szArea[0]   = '\0';
         pFrom = pTo = pData;
         IsEchomail  = TRUE;
         NewBuffer   = FALSE;

         while (*pFrom) {
            if (strnicmp(pFrom, "\1FMPT", 5) == 0) {
               BYTE *p;
               for (p = pFrom + 5; *p == ' '; ++p);
               MsgHeader.wFromPoint = atoi(p);
            
            } else if (strnicmp(pFrom, "\1TOPT", 5) == 0) {
               BYTE *p;
               for (p = pFrom + 5; *p == ' '; ++p);
               MsgHeader.wToPoint = atoi(p);
            
            } else if (strnicmp(pFrom, "\1INTL", 5) == 0) {
               BYTE *p;
               for (p = pFrom + 5; *p == ' '; ++p);
               GetAddress(p, &MsgHeader.wToZone,
                             &MsgHeader.wToNet,
                             &MsgHeader.wToNode,
                             NULL);
               while (*p && *p != ' ' && *p != 0x0D) ++p;
               while (*p == ' ') ++p;
               GetAddress(p, &MsgHeader.wFromZone,
                             &MsgHeader.wFromNet,
                             &MsgHeader.wFromNode,
                             NULL);

            } else if (strnicmp (pFrom, "\1MSGID:", 7) == 0) {
               BYTE *p;
               for (p = pFrom + 7; *p == ' '; ++p);
               for (idlength = 0;
                    (idlength < 63) && (*p >= ' ');
                    idString[idlength++] = *p++);
               idString[idlength] = '\0';
               while (*p >= ' ') p++;
               if (MsgLink)
                  MsgHeader.midcrc = Crc32Str (idString);

            } else if (strnicmp (pFrom, "\1REPLY:", 7) == 0) {
               BYTE *p;
               for (p = pFrom + 7; *p == ' '; ++p);
               for (idlength = 0;
                    (idlength < 63) && (*p >= ' ');
                    idString[idlength++] = *p++);
               idString[idlength] = '\0';
               while (*p >= ' ') p++;
               if (MsgLink)
                  MsgHeader.repcrc = Crc32Str (idString);

            } else if (IsEchomail && szArea[0] == 0
                       && strnicmp(pFrom, "AREA:", 5) == 0) {
               BYTE *p;
               int  n;

               for (p = pFrom + 5; *p == ' '; ++p);
               for (n = 0;
                    n < sizeof szArea - 1 && *p && *p != 0x0D && *p != 0x8D;
                    szArea[n++] = *p++);
               do { szArea[n] = 0; } while (n > 0 && szArea[--n] == ' ');

            } else if (*pFrom != '\1') {
               IsEchomail = szArea[0] != 0;
            }

         ContinueLine:
            while (*pFrom && *pFrom != 0x0D)
            {
               if (*pFrom != 0x8D && *pFrom != 0x0A) *pTo++ = *pFrom;
               ++pFrom;
            }

            if (pFrom >= BufferStart + BytesInBuffer)
            {
               if (NewBuffer)
               {
                  ShowError(pCurrentPacket, "message too long");
               }
               else
               {
                  BytesInBuffer = pTo - MessageStart;
                  memcpy(BufferStart, MessageStart, BytesInBuffer);
                  pData = BufferStart + (pData - MessageStart);
                  pFrom = pTo = BufferStart + (pTo - MessageStart);
                  MessageStart = BufferStart;

                  BytesInBuffer += fread(pTo,
                                       sizeof(BYTE),
                                       BufferSize - BytesInBuffer,
                                       fpPacket);
                  memset(BufferStart + BytesInBuffer, 0, 8);
                  NewBuffer = TRUE;
                  goto ContinueLine;
               }
            }

            if (*pFrom)
            {
               *pTo++ = 0x0A;
               do ++pFrom; while (*pFrom == 0x0A);
            }
            else
            {
               *pTo++ = 0;
            }
         }

         *pTo++ = 0;
         MessageStart = ++pFrom;
         size -= pFrom - pData;

         if (MsgHeader.szFrom[0]    == 0) strcpy(MsgHeader.szFrom,    "*UNKNOWN*");
         if (MsgHeader.szTo[0]      == 0) strcpy(MsgHeader.szTo,      "*UNKNOWN*");
         if (MsgHeader.szSubject[0] == 0) strcpy(MsgHeader.szSubject, "*UNKNOWN*");

         if (CensorMessage(&MsgHeader, pData, szArea))
            res &= WriteMessage(WritePlainText, &MsgHeader, pData, szArea);
      }
      else
      {
         sprintf(szArea, "bad message at %ld", PacketSize - size);
         ShowError(pCurrentPacket, szArea);
         size += 2;
         MessageStart -= 2;
         while (size > offsetof(MSGHDR, Data) && !IsGoodMessage())
         {
            ++MessageStart;
            --size;
         }
         sprintf(szArea, "restarting at %ld", PacketSize - size);
         ShowError(pCurrentPacket, szArea);
         res = FALSE;
      }
   }

   if (pActiveArea != NULL)
   {
      fclose(fpMessages);
      fclose(fpHeader);
   }

   sprintf (szMessage, "   %d message%sfound",
            msg_count, ((msg_count == 1)? " ": "s "));
   WriteLogfile (szMessage);

   return res;
}



static int procCompare(const void *pkt1, const void *pkt2)
{
   return ((PACKET *) pkt1)->date < ((PACKET *) pkt2)->date ? -1 :
          ((PACKET *) pkt1)->date > ((PACKET *) pkt2)->date ?  1 :
                                     0;
}



void UnpackMail(void)
{
   struct ffblk fileinfo;
   char szPath[FILENAME_MAX];
   char *pName;
   int nPackets;
   int i;
   PACKET *pPackets;
   FILE *fp;
   PKTHDR Header;

   nPackets = 0;
   strcpy(szPath, szInbound);
   pName = szPath + strlen(szPath);
   strcpy(pName, "*.PKT");

   if (findfirst(szPath, &fileinfo, 0) != 0) return;
   do { ++nPackets; } while (findnext(&fileinfo) == 0);

   pPackets = calloc(nPackets, sizeof(*pPackets));
   if (pPackets == NULL)
   {
      ShowError("packet list", szOutOfMemory);
      return;
   }
   findfirst(szPath, &fileinfo, 0); /* we just counted them and there was */
   i = 0;                           /* at least one file */
   do
   {
      strcpy(pPackets[i].name, fileinfo.ff_name);
      strcpy(pName, fileinfo.ff_name);
      fp = fopen(szPath, "rb");
      if (fp == NULL)
      {
         ShowError(fileinfo.ff_name, strerror(errno));
         nPackets--;
      }
      else
      {
         if (fread(&Header, sizeof(Header), 1, fp) < 1)
         {
            ShowError(pName, strerror(errno));
         }
         else
         {
            int sub;
            sub = swap(Header.Year) >= 1990 ? 1990 : 90;
            pPackets[i].date = ((long) (swap(Header.Year)   - sub) << 26)
                             | ((long)  swap(Header.Month)         << 22)
                             | ((long)  swap(Header.Day)           << 17)
                             | ((long)  swap(Header.Hour)          << 12)
                             | ((long)  swap(Header.Minute)        <<  6)
                             | ((long)  swap(Header.Second)        <<  0);
         }
         ++i;
         fclose(fp);
      }
   }
   while (findnext(&fileinfo) == 0);

   qsort(pPackets, nPackets, sizeof(*pPackets), procCompare);

                  /* --------------------------------------------------
                     allocate packet buffer
                     -------------------------------------------------- */
#ifdef DEBUG
   BufferSize = MEM_REQUIRED;
#else
   BufferSize = coreleft() - MEM_RESERVE;
#endif
   if (BufferSize < MEM_REQUIRED)
   {
      sprintf(szPath, "%ld required, %ld available",
                      (long) (MEM_REQUIRED + MEM_RESERVE),
                      (long) (BufferSize   + MEM_RESERVE));
      ShowError(szOutOfMemory, szPath);
      return;
   }
   BufferStart = calloc(BufferSize + 8, 1);
   if (BufferStart == NULL)
   {
      ShowError("couldn't alloc available memory",
                "re-boot and try again");
      return;
   }

   for (i = 0; i < nPackets; i++)
   {
      strcpy(pName, pCurrentPacket = pPackets[i].name);
      fpPacket = fopen(szPath, "rb");
      PacketSize = filelength(fileno(fpPacket));
      {
         if (ImportPacket())
         {
            fclose(fpPacket);
            remove(szPath);
         }
         else
         {
            char szTempName[FILENAME_MAX];
            fclose(fpPacket);
            strcpy(szTempName, szPath);
            szTempName[strlen(szTempName) - 3] = 'B';
            remove(szTempName);
            rename(szPath, szTempName);
         }
      }
   }

   CensorStats();
   
   free(BufferStart);
   free(pPackets);
}



/* --------------------------------------------------------------------
   WriteStatistics
   -------------------------------------------------------------------- */
void WriteStatistics(void)
{
   char line[128];
   AREAPARAM *pArea;

   if (MessageCount > 0)
   {
      WriteLogfile("     AREANAME     | MESSAGES | To Sysop");
      WriteLogfile("==================+==========+==========");
   }
   for (pArea = pFirstArea; pArea != NULL; pArea = pArea->pNext)
   {
      if (pArea->NewMails)
      {
         sprintf(line, " %-16.16s | %5d    |%5d",
                       pArea->pLocalName,
                       pArea->NewMails,
                       pArea->SysopMails);
         WriteLogfile(line);
      }
   }
}

