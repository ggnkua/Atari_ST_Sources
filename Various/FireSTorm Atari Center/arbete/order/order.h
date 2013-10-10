/**********************************************************************/
/* Definiering av structer, mm                                        */
/* 950213 + skapade denna header f”r structerna                       */
/*        + flyttade ”ver de structer som fanns i huvudprogrammet     */
/*        + structen vara ut”kades med antalet som finns/best„llts    */
/* 950214 + slog ihop vara och orderlista till enbart orderlista      */
/* 950310 + Slog ihop struct.h och order.h till order.h               */
/**********************************************************************/
/**********************************************************************/
/* Standard v„rden f”r lite standard saker                            */
/**********************************************************************/
#define FAIL    -1
#define OK       0
#define FIRST    0

/**********************************************************************/
/* olika max-v„rden oxh str„ng-storlekar                              */
/**********************************************************************/
#define TMP_S_S     255
#define MAX_LIST    10
#define MAX_ORDER   10
#define MAX_DESC    56
#define MAX_PATH    255
#define MAX_NAME    36
#define MAX_SUBJ    72
#define MAX_MESS    32000

/**********************************************************************/
/* Huvud Menu tangenter                                               */
/**********************************************************************/
#define YELL    'Y'
#define QUIT    'Q'
#define LIST    'L'
#define PLACE   'P'
#define CLEAR   'R'

/**********************************************************************/
/* Orderbest„llnings meny tangenter                                   */
/**********************************************************************/
#define MARK    'M'
#define DSEL    'D'
#define NEXT    'N'
#define PREV    'P'
#define SHOW    'S'

/**********************************************************************/
/* ™vriga sorters tangenter som inte h”r till en egen meny            */
/**********************************************************************/
#define EOL         (char)0
#define TAB		    (char)9
#define RETURN      (char)13
#define SPACE       (char)32
#define UP          (char)72
#define DOWN        80
#define LEFT        75
#define RIGHT       77
#define JA          'J'
#define NEJ         'N'

/**********************************************************************/
/* Koder f”r olika emulerings-l„gen                                   */
/**********************************************************************/
#define VT52        0
#define ANSI        1

/**********************************************************************/
/* Saker som beh”vs f”r att k„nna igen config-filen                   */
/**********************************************************************/
#define CONFIG     "ORDER.CFG"
#define MAILPATH    "MAILPATH"
#define DATAPATH    "DATAPATH"
#define MAILTO      "MAILTO"
#define SUBJECT     "SUBJECT"
#define ORDER       "ORDER"
#define ADRESS      "ADRESS"

/**********************************************************************/
/* Structen Orderlista                                                */
/*      first: Pekare till f”rsta varan i listan                      */
/*      prev: Pekare till f”reg†ende varan i listan                   */
/*      next: Pekare till n„sta vara i listan                         */
/*      antal: antal best„llda/som finns inne                         */
/*      pris: Priset p† varan (max 32000 :- )                         */
/*      desc: kort Beskrivning av varan (text, max 59 tecken)         */
/*      path: S”kv„g till en text-fil som beskriver varan (80 tecken) */
/**********************************************************************/
typedef struct orderlista
{
	struct orderlista *prev;
	struct orderlista *next;
	int    antal;
	int    pris;
	int    best_antal;
	char   desc[MAX_DESC];
	char   path[MAX_PATH];
}orderlista	;

/**********************************************************************/
/* Structen info:                                                     */
/*      remul: Emuleringen hos den som ringer hit                     */
/**********************************************************************/
typedef struct info
{
	int serialport
	int serial=FALSE;
	int serialforce=FALSE;
	int screen=FALSE;
	int emul;
	int screenheight;
	int timeout;
	char mailpath[MAX_PATH];
	char datapath[MAX_PATH];
	char mailto[MAX_NAME];
	char subject[MAX_SUBJ];
	char m_adress[MAX_NAME];
	char name[MAX_NAME];
	char street[MAX_NAME];
    char city[MAX_NAME];
    char p_home[MAX_NAME];
    char p_bbs[MAX_NAME];
    char p_fax[MAX_NAME];
    char kundnr[MAX_NAME];
}info;

/**********************************************************************/
/* Structer mm f”r att f† mail-skrivandet att fungera!                */
/**********************************************************************/
typedef   struct HEADERtag             
{
	char    sFrom[36];           /* User who created msg (0-terminated)  */
	char    sTo[36];             /* User who may read msg (0-terminated) */
	char    sSubject[72];        /* Subject (0-terminated)               */
	char    sDate[20];           /* Date/Time string of message          */
	ulong   lDate;               /* Date when msg was imported (UTC)     */
	ulong   lStart;              /* Start offset of message              */
	ulong   _reserved_1;         /* res. by AFSC (was QBBS reply link)   */
	uword   wFlags;              /* Message flags                        */

	ulong   lMsgidcrc;           /* LED comment ^MSGID crc               */
	ulong   lReplycrc;           /* LED comment ^REPLY crc               */
	uword   wMFlags;             /* Maus message flags (XF_MAUSMSG set)  */
	uword   wXFlags;             /* Extended message flags               */
	uword   _reserved_3;         /* wAddress: Origin address (1)         */
	uword   wProcessed;          /* bitfield used by JetMail             */
	uword   wSize;               /* Length of msg                        */
	
	ulong   _reserved_2;         /* res. by AFSC (was QBBS: Reads/Cost)  */

	uword   wFromZone;           /* Zone of sender                       */
	uword   wFromNet;            /* Net...                               */
	uword   wFromNode;           /* Node...                              */
	uword   wFromPoint;          /* Point...                             */
	uword   wToZone;             /* Zone of receiver                     */
	uword   wToNet;              /* Net...                               */
	uword   wToNode;             /* Node...                              */
	uword   wToPoint;            /* Point...                             */
} HDR_HEADER;

/*
** (1) Description of "wAddress"
**
** LED stores in the lower byte the number of the "Address"-line used
** for the origin address. e.g. (BINKLEY.CFG or LED.CFG)
**   Address   2:2446/110.6@fidonet.org
**   Address   51:601/7.6@atarinet.ftn
**   Address   90:400/410@nest.ftn
**   Address   90:400/404.6@nest.ftn
** Writing a mail with the origin address 90:400/410 sets "wAddress=3".
** "wAddress" is zero when LED could not find the correct address or the
** msg was not written on your own system (e.g. move msg, move msg with
** forward).
** WARNING: Do not change the addresses in your config before all mail
** was scanned. Otherwise a wrong address could be taken by the tosser.
** The upper byte of "wAddress" is reserved and should be zero.
*/

/*
** Flags: wProcessed
** Write to AFSC for others...
*/

#define PROC_JETMAIL            (1U << 0)
#define PROC_AU_MSGCHECK        (1U << 1)
#define PROC_AU_FILEMGR         (1U << 2)
#define PROC_CHARMODIFY         (1U << 3)
#define PROC_CONNECTR           (1U << 4)
#define PROC_DOORMAIL           (1U << 5)
#define PROC_ARCED              (1U << 6)
#define PROC_FIFO               (1U << 7)

/*
** Flags: wFlags
*/

#define F_PRIVATE               (1U << 0)
#define F_CRASH                 (1U << 1)
#define F_RECEIVED              (1U << 2)
#define F_SENT                  (1U << 3)
#define F_FILEATTACH            (1U << 4)
#define F_INTRANSIT             (1U << 5)
#define F_ORPHAN                (1U << 6)
#define F_KILLSENT              (1U << 7)
#define F_LOCAL                 (1U << 8)
#define F_HOLD                  (1U << 9)
#define F_RESERVED              (1U << 10)
#define F_FILEREQ               (1U << 11)
#define F_RETRECREQ             (1U << 12)
#define F_ISRETREC              (1U << 13)
#define F_AUDITREQ              (1U << 14)
#define F_DELETED               (1U << 15)

/*
** Flags: wXFlags
** Write to FTSC for others...
*/

#define XF_READ                 (1U << 0)
#define XF_ARCHIVSENT           (1U << 1)
#define XF_TRUNCFILESENT        (1U << 2)
#define XF_KILLFILESENT         (1U << 3)
#define XF_DIRECT               (1U << 4)
#define XF_ZONEGATE             (1U << 5)
#define XF_HOSTROUTE            (1U << 6)
#define XF_LOCK                 (1U << 7)
#define XF_MAUSMSG              (1U << 8)
#define XF_GATED                (1U << 9)
#define XF_CREATEFLOWFILE       (1U << 10)
#define XF_RESERVED11           (1U << 11)
#define XF_RESERVED12           (1U << 12)
#define XF_SIGNATURE            (1U << 13)
#define XF_IMMEDIATE            (1U << 14)
#define XF_FIXEDADDRESS         (1U << 15)

/*
** Flags: wMFlags
** Write to ATSC for others...
*/

#define MF_NICHTGELESEN         (1U << 0)
#define MF_NOTREAD              (1U << 0)
#define MF_ZURUECK              (1U << 1)
#define MF_RETURN               (1U << 1)
#define MF_BEANTWORTET          (1U << 2)
#define MF_ANSWERED             (1U << 2)
#define MF_GELESEN              (1U << 3)
#define MF_READ                 (1U << 3)
#define MF_WEITER               (1U << 4)
#define MF_CONTINUE             (1U << 4)
#define MF_MAUSNET              (1U << 5)
#define MF_ANGEKOMMEN           (1U << 6)
#define MF_RECEIVED             (1U << 6)
#define MF_GATEWAY              (1U << 7)
#define MF_KOPIERT              (1U << 8)
#define MF_COPIED               (1U << 8)
#define MF_MAUSTAUSCH           (1U << 9)
#define MF_UNBEKANNT            (1U << 10)
#define MF_UNKNOWN              (1U << 10)
#define MF_INTERESTING1         (1U << 11)
#define MF_INTERESTING2         (1U << 12)
#define MF_VERERBEN             (1U << 13)
#define MF_HEREDITARY           (1U << 13)

#define MONTHS {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
