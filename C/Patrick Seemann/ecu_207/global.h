/* --------------------------------------------------------------------
   Modul:      GLOBAL.H
   Subject:    common definitions fÅr Ecu and Llegada
   Author:     ho
   Started:    27.01.1991  10:24:26
   --------------------------------------------------------------------
   94-06-21ps  pkt.h (PKTHDR) integriert
   94-04-03ps  HoldScreen
               NoWait entfernt
   93-12-20ps  HostPrefix
   93-08-01ps  pReply entfernt
   93-07-29ps  Support fÅr Achmed
   92-11-08ps  MsgLink
   92-10-18ps  Support fÅr 2+-Packete, Username in Areas
   92-06-18ps  neuer Parameter fÅr SetVersion,
               Kommentarverkettung fÅr LED
   --------------------------------------------------------------------
   03.05.1992  ExportFlags
   23.03.1992  LastReadQBBS
   14.03.1992  CreateDummyCmd
   27.02.1992  KeepArea ist Area-Parameter, nicht global
               Dummy-Flowfile mit und ohne Dummy-Paket
   06.02.1992  RouteTo, CrashToPoints
   05.01.1992  Domain-Statement
   28.11.1991  Domain-UnterstÅtzung
   10.11.1991  pLimits nicht mehr global
               Censor-Liste
   09.11.1991  Match-Minimum fÅr normale Netmail
   03.11.1991  Arced Crashmail
   02.11.1991  DummyFLO auch bei Host-Definitionen
               IOS-Flow-File Namen
   12.10.1991  Signature, LharcUnpack
   28.09.1991  unterschiedliche Arcer fÅr verschiedene Hosts
               WhichArc
   19.09.1991  NewAreaDirectory
   18.09.1991  Cookies and Origins
   19.07.1991  LED_* flags defined
   09.06.1991  Force INTL
   04.05.1991  HighLimit
   01.05.1991  GoodUnpackReturn, CMD_GOODUNPACK
   07.04.1991  CMD_DEFAULTZONE
   07.04.1991  CMD_USEZONES, UseZones
   05.04.1991  CMD_CREATETB, CreateTB
   -------------------------------------------------------------------- */

#ifndef __GLOBAL
#define __GLOBAL

#include <stdio.h>
#include "defines.h"


/* -------------
      Defines
   ------------- */

#define  DEFAULT_ZONE      2

#define  FFF_BINKLEY       0
#define  FFF_THEBOX        1
#define  FFF_IOS           2

#define  LED_NEWMSG        (1 << 0)
#define  LED_UNREAD        (1 << 1)
#define  LED_SYSOP         (1 << 2)

#define  AT_ECHOMAIL       (1 << 0)
#define  AT_NETMAIL        (1 << 1)
#define  AT_TICKAREA       (1 << 2)

#define  HT_STANDARD       (1 << 0)
#define  HT_FRODO          (1 << 1)
#define  HT_QMAIL          (1 << 2)
#define  HT_2PLUS          (1 << 3)

#define  MSW_INCLUDE       (1L << ('I' & 0x1F))
#define  MSW_HARDRETURN    (1L << ('H' & 0x1F))
#define  MSW_NOSIGNATURE   (1L << ('P' & 0x1F))
#define  MSW_SOFTRETURN    (1L << ('S' & 0x1F))
#define  MSW_TEARLINE      (1L << ('T' & 0x1F))

/* for MSG_HEADERtag->wFlags */
#define  MF_PRIVATE        (1U << 0)
#define  MF_CRASH          (1U << 1)
#define  MF_RECEIVED       (1U << 2)
#define  MF_SENT           (1U << 3)
#define  MF_WITHFILE       (1U << 4)
#define  MF_FORWARDED      (1U << 5)
#define  MF_ORPHEN         (1U << 6)
#define  MF_KILLIFSENT     (1U << 7)
#define  MF_LOCAL          (1U << 8)
#define  MF_HOLD           (1U << 9)
#define  MF_SIGNATURE      (1U << 10)
#define  MF_FILEREQ        (1U << 11)
#define  MF_RETRECREQ      (1U << 12)
#define  MF_ISRETREC       (1U << 13)
#define  MF_AUDITREQ       (1U << 14)
#define  MF_DELETED        (1U << 15)

/* for MSG_HEADERtag->wXFlags */
#define  XF_READ           (1U << 0)
#define  XF_ARCHIVESENT    (1U << 1)
#define  XF_TRUNCFILESENT  (1U << 2)
#define  XF_KILLFILESENT   (1U << 3)
#define  XF_DIRECT         (1U << 4)
#define  XF_ZONEGATE       (1U << 5)
#define  XF_HOSTROUTE      (1U << 6)
#define  XF_LOCK           (1U << 7)
#define  XF_IMMEDIATE      (1U << 8)
#define  XF_GATED          (1U << 9)
#define  XF_CREATEFLOWFILE (1U << 10)

#define  CMS_NONE          (1U << 15)
#define  CMS_HOST          (1U << 14)
#define  CMS_AREA          (1U << 13)
#define  CMD_HOST          (CMS_NONE | 1)
#define  CMD_AREA          (CMS_NONE | 2)
#define  CMD_MATRIX        (CMS_NONE | 3)
#define  CMD_END           (CMS_HOST | CMS_AREA | 4)
#define  CMD_NODE          (CMS_HOST | 5)
#define  CMD_POINT         (CMS_HOST | 6)
#define  CMD_STDPKT        (CMS_HOST | 7)
#define  CMD_FRODOPKT      (CMS_HOST | 8)
#define  CMD_QMAILPKT      (CMS_HOST | 9)
#define  CMD_PRODID        (CMS_HOST | 10)
#define  CMD_SERIAL        (CMS_HOST | 11)
#define  CMD_3DORIGIN      (CMS_HOST | 12)
#define  CMD_3DSEENBY      (CMS_HOST | 13)
#define  CMD_3DPATH        (CMS_HOST | 14)
#define  CMD_ORIGIN        (CMS_HOST | CMS_AREA | CMS_NONE | 15)
#define  CMD_AREANAME      (CMS_AREA | 16)
#define  CMD_FILENAME      (CMS_AREA | 17)
#define  CMD_BOSS          (CMS_AREA | 18)
#define  CMD_NETMAIL       (CMS_AREA | 19)
#define  CMD_DAYS          (CMS_AREA | 20)
#define  CMD_3DMSGID       (CMS_HOST | 21)
#define  CMD_3DADDRESS     (CMS_HOST | 22)
#define  CMD_LASTREAD      (CMS_NONE | 23)
#define  CMD_AREAS         (CMS_NONE | 24)
#define  CMD_AREASIZE      (CMS_NONE | 25)
#define  CMD_HOMEDIR       (CMS_NONE | 26)
#define  CMD_OUTBOUND      (CMS_NONE | 27)
#define  CMD_INBOUND       (CMS_NONE | 28)
#define  CMD_ARCOUT        (CMS_NONE | CMS_HOST | 29)
#define  CMD_ARCIN         (CMS_NONE | 30)
#define  CMD_ARCDEL        (CMS_NONE | 31)
#define  CMD_DUMMYFLOW     (CMS_NONE | CMS_HOST | 32)
#define  CMD_SOFTRETURN    (CMS_AREA | 33)
#define  CMD_HOLDSCREEN    (CMS_NONE | 34)
#define  CMD_NOOUTPUT      (CMS_AREA | CMS_HOST | 35)
#define  CMD_COMPRESS      (CMS_NONE | 36)
#define  CMD_LOGFILE       (CMS_NONE | 37)
#define  CMD_LOGLEVEL      (CMS_NONE | 38)
#define  CMD_ALIAS         (CMS_NONE | 39)
#define  CMD_KILLLOCAL     (CMS_AREA | 40)
#define  CMD_KILLHOLD      (CMS_AREA | 41)
#define  CMD_APPENDTB      (CMS_NONE | 42)
#define  CMD_LDAYS         (CMS_AREA | 43)
#define  CMD_CRUNCH        (CMS_AREA | 44)
#define  CMD_DUPES         (CMS_NONE | 45)
#define  CMD_ADRPREFIX     (CMS_NONE | 46)
#define  CMD_USEAREAS      (CMS_NONE | 47)
#define  CMD_DEFAULT       (CMS_NONE | 48)
#define  CMD_NONETMAIL     (CMS_HOST | 49)
#define  CMD_ROUTEECHO     (CMS_NONE | 50)
#define  CMD_LEDNEW        (CMS_NONE | 51)
#define  CMD_ARCMAIL       (CMS_HOST | 52)
#define  CMD_3DECHOMAIL    (CMS_HOST | 53)
#define  CMD_3DNETMAIL     (CMS_HOST | 54)
#define  CMD_SYSOP         (CMS_NONE | 55)
#define  CMD_STORECRC      (CMS_NONE | 56)
#define  CMD_DECCRC        (CMS_NONE | 57)
#define  CMD_HEXCRC        (CMS_NONE | 58)
#define  CMD_FMTPREFIX     (CMS_NONE | 59)
#define  CMD_PASSWORD      (CMS_AREA | CMS_HOST | 60)
#define  CMD_TICKAREA      (CMS_AREA | 61)
#define  CMD_TICKINDICATOR (CMS_NONE | 62)
#define  CMD_TICKPREFIX    (CMS_NONE | 63)
#define  CMD_NOCRUNCH      (CMS_NONE | 64)
#define  CMD_LOWLIMIT      (CMS_AREA | 65)
#define  CMD_3DTICK        (CMS_HOST | 66)
#define  CMD_LOGAREA       (CMS_AREA | 67)
#define  CMD_BADMSGAREA    (CMS_AREA | 68)
#define  CMD_QUICK         (CMS_NONE | 69)
#define  CMD_CREATETB      (CMS_NONE | 70)
#define  CMD_USEZONES      (CMS_NONE | 71)
#define  CMD_DEFAULTZONE   (CMS_NONE | 72)
#define  CMD_KEEPAREA      (CMS_AREA | 73)
#define  CMD_GOODUNPACK    (CMS_NONE | 74)
#define  CMD_HIGHLIMIT     (CMS_AREA | 75)
#define  CMD_FORCEINTL     (CMS_NONE | CMS_HOST | 76)
#define  CMD_COOKIE        (CMS_NONE | 77)
#define  CMD_RNDORIGIN     (CMS_AREA | 78)
#define  CMD_NEWAREADIR    (CMS_NONE | 79)
#define  CMD_ARJIN         (CMS_NONE | 80)
#define  CMD_LZHIN         (CMS_NONE | 81)
#define  CMD_ZIPIN         (CMS_NONE | 82)
#define  CMD_ZOOIN         (CMS_NONE | 83)
#define  CMD_LHAIN         (CMS_NONE | 84)
#define  CMD_DEFIN         (CMS_NONE | 85)
#define  CMD_SIGNATURE     (CMS_NONE | CMS_HOST | CMS_AREA | 86)
#define  CMD_IOSFLOW       (CMS_NONE | 87)
#define  CMD_ARCEDCRASH    (CMS_NONE | 88)
#define  CMD_CENSOR        (CMS_NONE | 89)
#define  CMD_NORESTORE     (CMS_NONE | 90)
#define  CMD_DOMAIN        (CMS_NONE | 91)
#define  CMD_4DECHOMAIL    (CMS_HOST | 92)
#define  CMD_ROUTETO       (CMS_HOST | 93)
#define  CMD_CRASHPOINTS   (CMS_NONE | 94)
#define  CMD_LASTREADQBBS  (CMS_NONE | 95)
#define  CMD_EXFLAGS       (CMS_NONE | 96)
#define  CMD_2PLUSPKT      (CMS_HOST | 97)
#define  CMD_USERNAME      (CMS_AREA | 98)
#define  CMD_MSGLINK       (CMS_NONE | 99)
#define  CMD_ACHMED        (CMS_NONE | 100)
#define  CMD_HOSTPREFIX    (CMS_NONE | 101)

/* -----------
      Types
   ----------- */

typedef struct DOMAIN {
    struct DOMAIN *pNext;
    int           zone;
    char          *pName;
} DOMAIN;

typedef struct SYSOPNAMEtag {
    struct SYSOPNAMEtag *pNext;
    char                *pName;
} SYSOPNAME;

typedef struct {
    FILE  *fp;
    int   cnt;
    long  *offset;
} COOKIE;

typedef struct {
    char  *text;
    WORD  type;
} CMDLIST;

typedef struct {
    WORD OrigNode,       /* of packet */
         DestNode,
         Year, Month, Day,
         Hour, Minute, Second,
         Baud,
         PacketVersion,  /* always 0x0200 */
         OrigNet,        /* of packet */
         DestNet;

    WORD ProdInfo;       /* 1st Byte (ProdCode):
                                determines actual structure
                            2nd Byte (ProdRevision) */

    union {
        BYTE     Fill[32];

        struct {
            BYTE  Password[8];
            WORD  QMOrigZone, QMDestZone;
            BYTE  Fill[16];
            LONG  SerNo;
        } QM; /* QMail/ZMailQ */

        struct {
            BYTE  Password[8];
            WORD  QMOrigZone, QMDestZone;
            BYTE  Fill[8];
            WORD  OrigZone, DestZone, OrigPoint, DestPoint;
            LONG  SerNo;
        } FroDo; /* FroDo/TS/TCOMMail/XRS/TrapDoor/DBridge/AirMail */

        struct {
            BYTE  Password[8];
            WORD  QMOrigZone;
            WORD  QMDestZone;
            WORD  AuxNet;
            WORD  CWCopy;         /* Copy of Capability Word */
            WORD  ProdInfo2;      /* ProdInfo */
            WORD  CapWord;
            WORD  OrigZone;
            WORD  DestZone;
            WORD  OrigPoint;
            WORD  DestPoint;
            LONG  SerNo;
        } TwoPlus; /* 2+-Packets */
    } Xtra;
} PKTHDR;

typedef struct {
    char  szFrom[36];    /* Name of sender (NUL terminated) */
    char  szTo[36];      /* Name of receiver (NUL terminated) */
    char  szSubject[72]; /* Subject (NUL terminated) */
    char  szDate[20];    /* Date of message */
    long  lDate;         /* Import date (UTC) */
    long  lStart;        /* Msg offset in MSG file */

    LONG  midcrc;        /* CRC of MsgID (was wUp/wReply) */
    
    WORD  wFlags;        /* Message flags MF_* */
    
    WORD  wMagic;        /* (wUnused[0]) */
    WORD  wCrc;          /* CRC for dupe checking (wUnused[1]) */
    WORD  wUnused2;
    WORD  wUnused3;
    WORD  wUnused4;
    WORD  wXFlags;       /* Extended flags XF_* (wUnused[5]) */
    WORD  wUnused6;
    WORD  wUnused7;
    
    WORD  wSize;         /* Msg size in MSG file */

    LONG  repcrc;        /* CRC of Reply (was wReadCount/wCost) */

    WORD  wFromZone;     /* Address of sender */
    WORD  wFromNet;
    WORD  wFromNode;
    WORD  wFromPoint;
    WORD  wToZone;       /* Address of receiver */
    WORD  wToNet;
    WORD  wToNode;
    WORD  wToPoint;
} MSG_HEADER;

typedef struct HOSTPARAMtag {
    struct HOSTPARAMtag  *pNext;
    WORD                 BossZone;
    WORD                 BossNet;
    WORD                 BossNode;
    WORD                 FakeZone;
    WORD                 FakeNet;
    WORD                 FakeNode;
    WORD                 Point;
    WORD                 RouteZone;
    WORD                 RouteNet;
    WORD                 RouteNode;
    WORD                 RoutePoint;
    char                 *RouteDomain;
    WORD                 MatchMinimum;
    char                 *pOrigin;
    char                 *pArcMailName;
    char                 *pPassword;
    WORD                 HeaderType;
    WORD                 ProductId;
    LONG                 SerialNumber;
    unsigned             OldOrigin:1;
    unsigned             OldMsgId:1;
    unsigned             OldPath:1;
    unsigned             OldSeenBy:1;
    unsigned             OldAddress:1;
    unsigned             OldNetmail:1;
    unsigned             OldEchomail:1;
    unsigned             NewEchomail:1; /* FMPT, TOPT, INTL in Echomails */
    unsigned             OldTick:1;
    unsigned             NoOutput:1;
    unsigned             NoNetmail:1;
    unsigned             ForceIntl:1;
    unsigned             Route:1;
         /* ich kann mich nicht mehr erinnern, wofÅr es dieses Flag je
            gegeben hat. Es wird jedenfalls nirgendwo in Ecu/Llegada
            benutzt. Also kann ich es wohl dafÅr benutzen, anzuzeigen,
            da· fÅr einen Host RouteTo definiert wurde. (06.02.1992) */
    unsigned             DummyFlow:2;
    char                 *nmPkt;
    char                 *pArcCmd;
    char                 *pSignature;
    char                 *pDomain;
    FILE                 *fpPkt;
} HOSTPARAM;

typedef struct AREAPARAMtag {
    struct AREAPARAMtag  *pNext;
    struct HOSTPARAMtag  *pHost;
    WORD                 Type;
    WORD                 HostZone;
    WORD                 HostNet;
    WORD                 HostNode;
    char                 *pOrigin;
    char                 *pFilename;
    char                 *pAreaname;
    char                 *pLocalName;
    char                 *pUsername;
    char                 *pPassword;
    char                 *pSignature;
    WORD                 Days;
    WORD                 DaysLocal;
    WORD                 AreaIndex;
    WORD                 LastRead;
    WORD                 LedFlags;
    WORD                 CrunchLimit;
    WORD                 LowMessageCount;
    WORD                 HighMessageCount;
    WORD                 NewMails;
    WORD                 SysopMails;
    WORD                 DeletedMails;
    WORD                 OldMails;
    WORD                 Dupes;
    WORD                 SentMails;
    WORD                 WrittenHeaders;
    WORD                 ReadHeaders;
    WORD                 SignatureLength;
    unsigned             SoftReturns:1;
    unsigned             NoOutput:1;
    unsigned             KillLocal:1;
    unsigned             KillHold:1;
    unsigned             NewHeader:1;
    unsigned             KeepArea:1;
    unsigned             RandomOrigin:1;
} AREAPARAM;

typedef struct ALIAStag {
    struct ALIAStag   *pNext;
    WORD              Zone;
    WORD              Net;
    WORD              Node;
    WORD              Point;
    char              *pDomain;
    char              szAlias[1];
} ALIAS;

typedef struct {
    WORD     magic;      /* allways 02 00 */
    WORD     OrigNode;
    WORD     DestNode;
    WORD     OrigNet;
    WORD     DestNet;
    WORD     Attribute;
    WORD     Cost;
    BYTE     Data[512];  /* just a fixed piece of memory, hopefully large
                            enough for allinformation appended to the
                            message text. Let's see what goes here:
                            data & time                     20
                            to user name                    36
                            from user name                  36
                            subject                         72
                            TOPT                            16
                            FMPT                            16
                            AREA                            32
                            MSGID                           32
                            Tearline                        32
                            Origin                         128
                            Seen-By                         32
                            Path                            32
                                                           ---
                                                           484
                            close, isn't it?
                         */
} MSGHDR;



/* ---------------
      Variables
   --------------- */

extern   char        szVersion[];
extern   char        nmResource[];
extern   char        szNoResource[];
extern   char        szProgramId[];
extern   char        szSignature[];
extern   char        szRules[];
extern   char        ProgramPrefix;

extern   char        *pConfigFile;
extern   char        AddressPrefix;
extern   char        FormatPrefix;
extern   char        HostPrefix[];
extern   char        TickPrefix;
extern   char        TickIndicator;
extern   HOSTPARAM   *pFirstHost;
extern   AREAPARAM   *pFirstArea;
extern   AREAPARAM   *pNetmailArea;
extern   AREAPARAM   *pCommArea;
extern   AREAPARAM   *pBadMsgArea;
extern   ALIAS       *pAliasList;
extern   SYSOPNAME   *pSysopName;
extern   long        lFreeId;

extern   AREAPARAM   *pActiveArea;
extern   HOSTPARAM   *pActiveHost;
extern   DOMAIN      *pDomainList;

extern   int         CreateDummyFlo;
extern   int         CreateDummyCmd;
extern   BOOL        MsgLink;
extern   BOOL        AchmedMode;
extern   BOOL        HoldScreen;
extern   BOOL        DeletePkt;
extern   BOOL        Compress;
extern   BOOL        Crunch;
extern   BOOL        AppendTB;
extern   int         CreateTB;
extern   BOOL        UseAreas;
extern   BOOL        RouteEchos;
extern   BOOL        PackAreas;
extern   BOOL        QuickScan;
extern   BOOL        UseZones;
extern   BOOL        ForceIntl;
extern   BOOL        ArcedCrashMail;
extern   int         LogLevel;
extern   int         DefaultZone;
extern   unsigned    GoodUnpackReturn;
extern   FILE        *fpLogfile;
extern   BOOL        CrashPoints;
extern   WORD        ExportFlags;

extern   char  szHomeDir[FILENAME_MAX];
extern   char  szNewAreaDir[FILENAME_MAX];
extern   char  szTearline[];
extern   char  szLastRead[];
extern   char  szLastReadQBBS[];
extern   char  szLedNew[];
extern   char  szAchmedNew[];
extern   char  szAreasBBS[];
extern   char  szAreaSize[];
extern   char  szOutbound[];
extern   char  szInbound[];
extern   char  szArcOut[];
extern   char  szLogfile[];
extern   char  szDefaultIn[];
extern   char  szArcIn[];
extern   char  szArjIn[];
extern   char  szLhaIn[];
extern   char  szLharcIn[];
extern   char  szZipIn[];
extern   char  szZooIn[];

extern   char  szOutOfMemory[];
extern   char  szBadNodeAddress[];
extern   char  szBadNumber[];
extern   char  szMissingArgument[];
extern   char  szReadError[];
extern   char  szWriteError[];

extern   int         nHeader;
extern   MSG_HEADER  *pHeader;
extern   char        nmMessages[];
extern   FILE        *fpMessages;
extern   BOOL        KillDupes;
extern   BOOL        StoreCrc;
extern   BOOL        WriteHeader;
extern   CMDLIST     CmdList[];

extern   char        *CrcFormat;

extern   COOKIE      Origins;
extern   COOKIE      Cookies;



/* ----------------
      Prototypes
   ---------------- */
/*
  TODO: this should be declared in the corresponding header files
        instead of here.
*/

/*--- CRC.C ---*/
WORD  sCalcCrc(void *msg);
WORD  bCalcCrc(void *msg, WORD size);

/*--- CRC32.C ---*/
LONG  bCalcCrc32(LONG crc, void *msg, size_t size);

/*--- CRCLED.C ---*/
LONG Crc32Str (char * string);

/*--- DUPES.C ---*/
void  strfill(char *str, size_t len);
void  NewCrc(MSG_HEADER *pHdr);
void  CompareHeaders(MSG_HEADER *pHdr);
void  MarkDupes(void);

/*--- MISC.C ---*/
void  FinishAll(void);
void  WriteLogMessage(void);
void  WriteLogfile(char *msg);
void  OpenLogfile(void);
void  CloseLogfile(void);
void  usage(void);
void  ShowError(char *caption, char *message);
char  *BuildFilename(char *pFullName,
                     int drive, char *pPath, char *pName, char *pExtension);

/*--- NEWLED.C ---*/
void ReadLedNew(void);
void WriteLedNew(void);

/*--- NEWACHM.C ---*/
void ReadAchmedNew(void);
void WriteAchmedNew(void);

/*--- PARAM.C ---*/
HOSTPARAM   *FindHost(unsigned zone, unsigned net, unsigned node);
HOSTPARAM   *MatchHost(unsigned zone, unsigned net, unsigned node);
AREAPARAM   *FindFidoArea(char *pName);
AREAPARAM   *FindLocalArea(char *pName);
ALIAS *FindAlias(char *name);
DOMAIN *FindDomain(int zone);
char  *GetString(char *s, int len);
BOOL  GetAddress(char *s, WORD *zone, WORD *net, WORD *node, char *domain);
void  Get4dAddress(char *s, WORD *zone, WORD *net, WORD *node, WORD *point,
                   char *domain);
BOOL  TestHost(HOSTPARAM *pHost);
BOOL  TestArea(AREAPARAM *pArea);
void  ReadStdArgs(int argc, char **argv);
void  SetFlag(BOOL *flag, char *option, BOOL dfault);
AREAPARAM *AllocateArea(char *pArg);
void  ReadConfig(void);
void  ReadTbConfigs(void);
void  VerifyParams(void);
void  UpdateFiles(void);
WORD  Flags(char *p);

/*--- STRIPMSG.C ---*/
long  RemoveOldScrolls(char *pStart);

/*--- TICK.C ---*/
BOOL  CreateTickFile(char        *pFilename,
                     BOOL        CrashMail,
                     HOSTPARAM   *pHost,
                     AREAPARAM   *pActiveArea,
                     MSG_HEADER  *pHeader,
                     char        *p);

/*--- main.C ---*/
void  ReadExtArgs(int argc, char **argv);

/*--- COOKIE.C ---*/
BOOL OpenCookie(char *pName, COOKIE *pCookie);
BOOL GetCookie(COOKIE *pCookie, char *pBuffer);
void CloseCookie(COOKIE *pCookie);
size_t IncludeText(FILE *fpOutput, char *pName);

/*--- SETVER.C ---*/
void SetVersion(char *, int, int, int, char *);

#endif
