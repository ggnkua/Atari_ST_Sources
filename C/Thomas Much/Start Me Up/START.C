/***************************************
 * Start Me Up! '98                    *
 *              written by Thomas Much *
 ***************************************
 *   Dieses Programm ist Freeware!     *
 ***************************************
 *    Thomas Much, Gerwigstraže 46,    *
 * 76131 Karlsruhe, Fax (0721) 622821  *
 *         Thomas Much @ KA2           *
 *        thomas@snailshell.de         *
 ***************************************
 *    erstellt am:        16.02.1996   *
 *    letztes Update am:  02.10.1998   *
 ***************************************/

#define GERMAN
/*define SWEDISH*/
/*define NORWEGIAN*/
/*define FRENCH*/

#include "start.h"

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <vaproto.h>
#include <portab.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <stic_dev.h>
#include "sounds.h"

#define min(a,b)        ((a) < (b) ? (a) : (b))
#define max(a,b)        ((a) > (b) ? (a) : (b))
#define between(x,a,b)  ((x >= a) && (x <= b))

#define DHST_ADD 0xdadd
#define DHST_ACK 0xdade

#define BUBBLEGEM_REQUEST 0xbaba
#define BUBBLEGEM_SHOW    0xbabb

#define BGS7_2STRINGS     0x0008

#define GS_REQUEST  0x1350
#define GS_REPLY    0x1351
#define GS_COMMAND  0x1352
#define GS_ACK      0x1353
#define GS_QUIT     0x1354

#define GSM_COMMAND 0x0001

#define GSACK_OK      0
#define GSACK_UNKNOWN 1
#define GSACK_ERROR   2

#define DESK      0
#define INFVER    0x0002
#define GLOBAL    0x0020
#define ALLOCMODE 3|GLOBAL
#define WHITEBAK  0x0040
#define FL3DIND   0x0200
#define FL3DBAK   0x0400
#define FL3DACT   FL3DIND|FL3DBAK
#define AVMSG     0x0006  /* AV_STARTED, VA_START */
#define VAMSG     0x2421  /* AV_STARTED, AV_EXIT, AV_STARTPROG, AV_SENDKEY */

#define WM_BOTTOMED    33
#define WM_M_BDROPPED 100
#define SM_M_SPECIAL  101
#define SMC_SWITCH      2
#define SHW_CHAIN       1
#define SHW_LOAD_ACC    3
#define SHW_SHUTDOWN    4
#define SHW_BROADCAST   7
#define	SHW_PARALLEL  100
#define SHW_SINGLE    101
#define ME_ATTACH       1
#define ME_REMOVE       2
#define WINDOWSTYLE     0
#define SH_WDRAW       72
#define ACC_EXIT      0x0404
#define AV_STARTED    0x4738
#define AV_COPYFILE   0x4755
#define APPLINE_MSG   0x0935
#define CDROMEJECT    0x4309
#define DD_OK           0
#define DD_NAK          1
#define SE_FILE         0
#define SE_FOLDER       1
#define DF_NONE         0
#define DF_LEFT         1
#define DF_RIGHT        2
#define WF_WINX     22360
#define G_SHORTCUT     38

#define WHAT_NORMAL  0
#define WHAT_HISTORY 1
#define WHAT_DRIVES  2
#define WHAT_MENU    3

#define KsCAPS    0x10
#define KsALT     0x08
#define KsCONTROL 0x04
#define KsSHIFT   0x03
#define KsLSHIFT  0x02
#define KsRSHIFT  0x01
#define KsNORMAL  0x00

#define KbSCAN    0x8000
#define KbNUM     0x4000
#define KbALT     0x0800
#define KbCONTROL 0x0400
#define KbSHIFT   0x0300
#define KbLSHIFT  0x0200
#define KbRSHIFT  0x0100
#define KbNORMAL  0x0000

#define KbISO     0x37

#define KbF1      0x3b
#define KbF2      0x3c
#define KbF3      0x3d
#define KbF4      0x3e
#define KbF5      0x3f
#define KbF6      0x40
#define KbF7      0x41
#define KbF8      0x42
#define KbF9      0x43
#define KbF10     0x44
#define KbF11     0x54
#define KbF12     0x55
#define KbF13     0x56
#define KbF14     0x57
#define KbF15     0x58
#define KbF16     0x59
#define KbF17     0x5a
#define KbF18     0x5b
#define KbF19     0x5c
#define KbF20     0x5d

#define KbUNDO    0x61
#define KbHELP    0x62
#define KbINSERT  0x52
#define KbHOME    0x47
#define KbUP      0x48
#define KbDOWN    0x50
#define KbLEFT    0x4b
#define KbRIGHT   0x4d

#define KbAlt1    0x78
#define KbAlt2    0x79
#define KbAlt3    0x7a
#define KbAlt4    0x7b
#define KbAlt5    0x7c
#define KbAlt6    0x7d
#define KbAlt7    0x7e
#define KbAlt8    0x7f
#define KbAlt9    0x80
#define KbAlt0    0x81


typedef struct
{
	long id;
	long value;
} COOKIE;


typedef struct
{
	long len;
	int  version;
	int  msgs;
	long ext;
} GS_INFO;


typedef struct
{
	char *appname,
	     *apppath,
	     *docname,
	     *docpath;
} DHSTINFO;


typedef struct n_dhst
{
	struct n_dhst *next;
	DHSTINFO info;
} DHST;


typedef struct
{
	int version;
	int workxabs;
	int workyabs;
} STARTINF;


typedef struct n_alias
{
	struct n_alias *next;
	char old[128],new[256];
} ALIAS;


typedef struct
{
	char name[32],path[256];
} LINK;


typedef struct n_timer
{
	struct n_timer *next;
	char *file,*fcmd;
	long time;
} TIMER;


typedef struct s_entry
{
	char *name,*file,*fcmd;
	struct s_entry *next;
	int flags;
} STARTENTRY;


typedef struct s_menu
{
	OBJECT     *tree;
	STARTENTRY *entries;
	struct s_menu *children,
	              *next,
	              *parent;
} STARTMENU;


typedef struct
{
	long  magic;
	void *membot;
	void *aes_start;
	long  magic2;
	long  date;
	void (*chgres)(int res, int txt);
	long (**shel_vector)(void);
	char *aes_bootdrv;
	int  *vdi_device;
  void *reservd1;
  void *reservd2;
  void *reservd3;
  int   version;
  int   release;
} AESVARS;


typedef struct
{
	long    config_status;
	void    *dosvars;
	AESVARS *aesvars;
} MAGX_COOKIE;


#define  MSG_OPEN_MAIN        0
#define  MSG_AUTO_ERROR       1
#define  MSG_QUIT             2
#define  MSG_CNF_ERROR        3
#define  MSG_CNFMEM_ERROR     4
#define  MSG_NEST_ERROR       5
#define  MSG_ERROR_LINE       6
#define  MSG_MAGX_ERROR       7
#define  MSG_MAGX_VERSION     8
#define  MSG_XMEN_ERROR       9
#define  MSG_INIT_SHUTDOWN   10
#define  MSG_FINISH_SHUTDOWN 11
#define  MSG_THING_GROUP     12
#define  MSG_NOT_EXECUTABLE  13

#ifdef GERMAN
char    *message[] = {"[1][ |Das \"StartMeUp!\"-Fenster kann |nicht ge”ffnet werden. ][Abbruch]",
                      "\"StartMeUp!\" kann nicht im AUTO-Ordner gestartet werden.\n",
                      "[2][ |\"Start Me Up!\" beenden? ][  Ja  | Nein ]",
                      "[1][ |Die Datei \"Start.set\" ist |defekt (Zeile ",
                      "[1][\"Start.set\" konnte wegen Speicher- |mangel nicht geladen werden. ][Abbruch]",
                      "[1][ |Die Datei \"Start.set\" ist zu tief |verschachtelt (Zeile ",
                      "). ][Abbruch]",
                      "[1][StartMeUp! ben”tigt MagiC!4.|Wenn Sie wissen, was Sie tun,|k”nnen Sie alternativ auch die |Option /magxignore verwenden.][Abbruch]",
                      "[1][ |Ihre MagiC!-Version ist zu alt. |Sie ben”tigen mindestens MagiC!4. ][Abbruch]",
                      "[1][ |StartMeUp! ben”tigt XMEN_MGR.|Bitte installieren Sie das Programm |im MagiC-APPS-Ordner.][Abbruch]",
                      "[1][ |Shutdown konnte nicht |gestartet werden.][  OK  ]",
                      "[1][ |Shutdown konnte nicht |durchgefhrt werden.][  OK  ]",
                      "[1][ |Fehler beim Einlesen der THING- |Gruppendatei (Zeile ",
                      "[1][ |Die Datei ist kein aus- |fhrbares Programm. ][  OK  ]",};
#else
#ifdef NORWEGIAN
char    *message[] = {"[1][ |Kan ikke †pne \"StartMeUp!\"-vinduet. ][Avbryt]",
                      "\"StartMeUp!\" kan ikke kj³res fra AUTO-folderen.\n",
                      "[2][ |Avslutte \"Start Me Up!\"? ][ Ja |  Nei  ]",
                      "[1][ |Konfigurasjonsfil \"Start.set\" er ³delagt |(linje ",
                      "[1][ |Ikke nok minne til † laste \"Start.set\". ][Avbryt]",
                      "[1][ |Konfigurasjonsfil \"Start.set\" er for kompleks |(linje ",
                      "). ][Avbryt]",
                      "[1][StartMeUp! beh³ver MagiC!4.|Hvis du vet hva du gj³r kan |du bruke /magxignore.][Avbryt]",
                      "[1][ |Du har for gammel MagiC-versjon. |Du m† bruke MagiC!4 eller nyere. ][Cancel]",
                      "[1][ |StartMeUp! beh³ver XMEN_MGR. |Vennligst kopi‚r det til |MagiC-APPS folderen.][Avbryt]",
                      "[1][ |Kan ikke starte shutdown. ][  OK  ]",
                      "[1][ |Shutdown kunne ikke gjennomf³res. ][  OK  ]",
                      "[1][ |Feil ved lesing av THING|gruppefil (linje ",
                      "[1][ |Dette er ikke en kj³rbar fil. ][  OK  ]",};
#else
#ifdef SWEDISH
char    *message[] = {"[1][ |Kan inte ”ppna \"StartMeUp!\"-f”nstret][Avbryt]",
                      "\"StartMeUp!\" kan inte startas fr†n Auto-biblioteket.\n",
                      "[2][ |Skall \"Start Me Up!\" avslutas?][  Ja  | Nej ]",
                      "[1][ |Filen \"Start.set\" „r |felaktig (rad ",
                      "[1][F”r lite minne f”r |att ladda in \"Start.set\"|filen.][Avbryt]",
                      "[1][ |Filen \"Start.set\" „r f”r |komplicerad (rad ",
                      "). ][Avbryt]",
                      "[1][StartMeUp! beh”ver MagiC!4.|Om du vet exakt vad du g”r |s† kan du anv„nda /magxignore flaggan.][Avbryt]",
                      "[1][ |Din MagiC!-Version „r f”r gammal. |Du beh”ver minst Magic!4. ][Avbryt]",
                      "[1][ |StartMeUp! beh”ver XMEN_MGR.|var sn„ll och kopiera det till | MagiC-APPS-biblioteket.][Avbryt]",
                      "[1][ |Shutdown kunde inte startas.][  OK  ]",
                      "[1][ |Kunde inte avsluta Shutdown.][  OK  ]",
                      "[1][ |Fel vid l„sning av Thing grupp-|filen (rad ",
                      "[1][ |Detta „r inte en k”rbar fil. ][  OK  ]",};
#else
char    *message[] = {"[1][ |Can't open the \"StartMeUp!\" window. ][Cancel]",
                      "\"StartMeUp!\" must not be run from the AUTO folder.\n",
                      "[2][ |Quit \"Start Me Up!\"? ][ Yes |  No  ]",
                      "[1][ |File \"Start.set\" is corrupted |(line ",
                      "[1][ |Not enough memory to load \"Start.set\". ][Cancel]",
                      "[1][ |File \"Start.set\" is too complex |(line ",
                      "). ][Cancel]",
                      "[1][StartMeUp! requires MagiC!4.|If you know exactly what you are about |to do you can use /magxignore.][Cancel]",
                      "[1][ |Your MagiC version is too old. |You must use MagiC!4 or later. ][Cancel]",
                      "[1][ |StartMeUp! requires XMEN_MGR. |Please copy it to your |MagiC-APPS folder.][Cancel]",
                      "[1][ |Could not enter shutdown mode. ][  OK  ]",
                      "[1][ |Could not finish shutdown. ][  OK  ]",
                      "[1][ |Error while reading THING group |file (line ",
                      "[1][ |This is not an executable file. ][  OK  ]",};
#endif
#endif
#endif


int starticn[0x002c] =
{ 0x0030, 0x0000, 0x0078, 0x0000, 
  0x00FC, 0x0000, 0x01FE, 0x0000, 
  0x0030, 0x0000, 0x0030, 0x0000, 
  0x0030, 0x0000, 0x1030, 0x2000, 
  0x3000, 0x3000, 0x7048, 0x3800, 
  0xFF33, 0xFC00, 0xFF33, 0xFC00, 
  0x7048, 0x3800, 0x3000, 0x3000, 
  0x1030, 0x2000, 0x0030, 0x0000, 
  0x0030, 0x0000, 0x0030, 0x0000, 
  0x01FE, 0x0000, 0x00FC, 0x0000, 
  0x0078, 0x0000, 0x0030, 0x0000,
};

int smallicn[0x0010] =
{ 0x0000, 0x0100, 0x0380, 0x07C0, 
  0x0100, 0x1110, 0x3018, 0x7D7C, 
  0x3018, 0x1110, 0x0100, 0x07C0, 
  0x0380, 0x0100, 0x0000, 0x0000,
};

TEDINFO rs_tedinfo = {"START","","",SMALL,0,TE_CNTR,0x1100,0,-1,6,1};

BITBLK rs_bitblk = {(int*)starticn,4,22,0,0,LBLUE};
BITBLK rs_smallblk = {(int*)smallicn,2,16,0,0,LBLUE};

OBJECT bigbutton[] =
{
	{-1,1,2,G_BOX,FL3DBAK,NORMAL,(long)0x00001100L,0x0000, 0x0000, 0x000C, 0x0801},
	{2,-1,-1,G_IMAGE,TOUCHEXIT|FL3DBAK,NORMAL,(long)&rs_bitblk,0x0100, 0x0100, 0x0004, 0x0601},
	{0,-1,-1,G_BUTTON,LASTOB|SELECTABLE|DEFAULT|EXIT|FL3DACT,DISABLED,(long)"Start",0x0403, 0x0400, 0x0008, 0x0001}
};

OBJECT smallbutton[] =
{
	{-1,1,2,G_BOX,FL3DBAK,NORMAL,(long)0x00001100L,0x0000, 0x0000, 0x0608, 0x0001},
	{2,-1,-1,G_IMAGE,TOUCHEXIT|FL3DBAK,NORMAL,(long)&rs_smallblk,0x0000, 0x0000, 0x0002, 0x0001},
	{0,-1,-1,G_BOXTEXT,LASTOB|SELECTABLE|DEFAULT|EXIT|FL3DACT,DISABLED,(long)&rs_tedinfo,0x0102, 0x0100, 0x0406, 0x0e00}
};


#ifdef GERMAN
OBJECT startpopup[] =
{
	{-1,1,8,G_BOX,FL3DBAK,SHADOWED,(long)0x00ff1100L,0,0,17,8},
	{2,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Info...     ^I ",0,0,17,1},
	{3,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"-----------------",0,1,17,1},
	{4,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Starten...  ^O ",0,2,17,1},
	{5,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"-----------------",0,3,17,1},
	{6,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Beenden...     ",0,4,17,1},
	{7,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Ausschalten    ",0,5,17,1},
	{8,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"-----------------",0,6,17,1},
	{0,-1,-1,G_STRING,LASTOB|FL3DBAK|SELECTABLE,NORMAL,(long)"  Hilfe...  Help ",0,7,17,1},
};
#else
#ifdef NORWEGIAN
OBJECT startpopup[] =
{
	{-1,1,8,G_BOX,FL3DBAK,SHADOWED,(long)0x00ff1100L,0,0,16,8},
	{2,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Info...    ^I ",0,0,16,1},
	{3,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"----------------",0,1,16,1},
	{4,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Start...   ^O ",0,2,16,1},
	{5,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"----------------",0,3,16,1},
	{6,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Avslutt...       ",0,4,16,1},
	{7,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Shutdown      ",0,5,16,1},
	{8,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"----------------",0,6,16,1},
	{0,-1,-1,G_STRING,LASTOB|FL3DBAK|SELECTABLE,NORMAL,(long)"  Hjelp... Help ",0,7,16,1},
};
#else
#ifdef SWEDISH
OBJECT startpopup[] =
{
	{-1,1,8,G_BOX,FL3DBAK,SHADOWED,(long)0x00ff1100L,0,0,16,8},
	{2,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Info...    ^I",0,0,16,1},
	{3,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"----------------",0,1,16,1},
	{4,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Starta...  ^O",0,2,16,1},
	{5,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"----------------",0,3,16,1},
	{6,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Avsluta...   ",0,4,16,1},
	{7,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  St„ng av     ",0,5,16,1},
	{8,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"----------------",0,6,16,1},
	{0,-1,-1,G_STRING,LASTOB|FL3DBAK|SELECTABLE,NORMAL,(long)"  Hj„lp... Help",0,7,16,1},
};
#else
OBJECT startpopup[] =
{
	{-1,1,8,G_BOX,FL3DBAK,SHADOWED,(long)0x00ff1100L,0,0,15,8},
	{2,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Info...   ^I ",0,0,15,1},
	{3,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"---------------",0,1,15,1},
	{4,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Start...  ^O ",0,2,15,1},
	{5,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"---------------",0,3,15,1},
	{6,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Quit...      ",0,4,15,1},
	{7,-1,-1,G_STRING,FL3DBAK|SELECTABLE,NORMAL,(long)"  Shutdown     ",0,5,15,1},
	{8,-1,-1,G_STRING,FL3DBAK,DISABLED,(long)"---------------",0,6,15,1},
	{0,-1,-1,G_STRING,LASTOB|FL3DBAK|SELECTABLE,NORMAL,(long)"  Help... Help ",0,7,15,1},
};
#endif
#endif
#endif


BITBLK startimg = {(int*)starticn,4,22,0,0,LBLUE};
TEDINFO starttxt[] =
{
	{"VERSION 8.0.0 (02.10.98)",NULL,NULL,SMALL,0,TE_LEFT,0x0100,0,0,24,0},
	{"COPYRIGHT 1996-98 BY THOMAS MUCH",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,32,0},
	{"thomas@snailshell.de",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,20,0},
	{"Thomas Much @ KA2 (MausNet)",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,27,0},
	{"Fax +49 / (0)721 / 62 28 21",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,27,0},
#ifdef GERMAN
	{"FREEWARE! (siehe Hypertext)",NULL,NULL,SMALL,0,TE_CNTR,0x0200,0,0,27,0},
	{"GESCHRIEBEN MIT PURE C 1.1",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,26,0},
#else
#ifdef NORWEGIAN
	{"FREEWARE! (se hypertekst)",NULL,NULL,SMALL,0,TE_CNTR,0x0200,0,0,25,0},
	{"LAGET MED PURE C 1.1",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,24,0},
#else
#ifdef SWEDISH
	{"FREEWARE! (se Hypertext)",NULL,NULL,SMALL,0,TE_CNTR,0x0200,0,0,27,0},
	{"SKAPAD MED PURE C 1.1",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,26,0},
#else
	{"FREEWARE! (see hypertext)",NULL,NULL,SMALL,0,TE_CNTR,0x0200,0,0,25,0},
	{"CREATED USING PURE C 1.1",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,24,0},
#endif
#endif
#endif
	{"...YOU MAKE A GROWN MAN CRY",NULL,NULL,SMALL,0,TE_LEFT,0x0c00,0,0,27,0},
#ifdef GERMAN
	{"DOKUMENTATION VON G™TZ HOFFART",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,30,0},
#else
#ifdef NORWEGIAN
	{"DOKUMENTASJON AV G™TZ HOFFART",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,29,0},
#else
#ifdef SWEDISH
	{"DOKUMENTATION AV G™TZ HOFFART",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,30,0},
#else
	{"DOCUMENTATION BY G™TZ HOFFART",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,29,0},
#endif
#endif
#endif
	{"goetz@hoffart.de",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,16,0},
#ifdef GERMAN
	{"Goetz Hoffart @ FR (MausNet)",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,28,0},
	{" ",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,1,0}
#else
#ifdef NORWEGIAN
	{"Jo.Even.Skarstein@ifi.ntnu.no",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,29,0},
	{"OG JO EVEN SKARSTEIN",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,20,0}
#else
#ifdef SWEDISH
	{"faltrion@mail.kd.qd.se",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,22,0},
	{"OCH CHRISTIAN ANDERSSON",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,23,0}
#else
	{"jconnor@cix.compulink.co.uk",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,27,0},
	{"AND JOE CONNOR",NULL,NULL,SMALL,0,TE_CNTR,0x0100,0,0,14,0}
#endif
#endif
#endif
};

OBJECT startinfo[] =
{
	{-1,1,15,G_BOX,FL3DBAK,OUTLINED,(long)0x00021100L,0,0,30,19},
	{2,-1,-1,G_IMAGE,FL3DBAK,NORMAL,(long)&startimg,2,1,6,3},
	{3,-1,-1,G_STRING,FL3DBAK,NORMAL,(long)"Start Me Up! '98",7,1,16,1},
	{4,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[7],7,2,22,1},
	{5,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[0],7,3,22,1},
	{6,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[1],2,5,26,1},
	{7,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[8],2,6,26,1},
	{8,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[11],2,7,26,1},
	{9,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[2],2,8,26,1},
	{10,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[3],2,9,26,1},
	{11,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[4],2,10,26,1},
	{12,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[9],2,11,26,1},
	{13,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[10],2,12,26,1},
	{14,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[5],2,14,26,1},
	{15,-1,-1,G_TEXT,FL3DBAK,NORMAL,(long)&starttxt[6],2,15,26,1},
	{0,-1,-1,G_BUTTON,LASTOB|FL3DACT|EXIT|DEFAULT|SELECTABLE,WHITEBAK,(long)"OK",19,17,8,0x0201}
};

OBJECT startdesk[] =
{
	{-1,-1,-1,G_BOX,LASTOB,NORMAL,(long)0x0000004cL,0,0,20,10}
};

#define RM_START 6
OBJECT deskmenu[] =
{
	{-1,1,4,G_IBOX,NONE,NORMAL,(long)0x00000000L,0x0000,0x0000,0x0050,0x0019},
	{4,2,2,G_BOX,NONE,NORMAL,(long)0x00001100L,0x0000,0x0000,0x0050,0x0201},
	{1,3,3,G_IBOX,NONE,NORMAL,(long)0x00000000L,0x0002,0x0000,0x0007,0x0301},
	{2,-1,-1,G_TITLE,NONE,NORMAL,(long)" START",0x0000,0x0000,0x0007,0x0301},
	{0,5,5,G_IBOX,NONE,NORMAL,(long)0x00000000L,0x0000,0x0301,0x0050,0x0017},
	{4,RM_START,13,G_BOX,NONE,NORMAL,(long)0x00ff1100L,0x0002,0x0000,0x0013,0x0008},
#ifdef GERMAN
	{7,-1,-1,G_STRING,NONE,NORMAL,(long)"  Programm...      ",0x0000,0x0000,0x0013,0x0001},
#else
#ifdef NORWEGIAN
	{7,-1,-1,G_STRING,NONE,NORMAL,(long)"  Programm...      ",0x0000,0x0000,0x0013,0x0001},
#else
#ifdef SWEDISH
	{7,-1,-1,G_STRING,NONE,NORMAL,(long)"  Program...       ",0x0000,0x0000,0x0013,0x0001},
#else
	{7,-1,-1,G_STRING,NONE,NORMAL,(long)"  Program...       ",0x0000,0x0000,0x0013,0x0001},
#endif
#endif
#endif
	{8,-1,-1,G_STRING,NONE,DISABLED,(long)"-------------------",0x0000,0x0001,0x0013,0x0001},
	{9,-1,-1,G_STRING,NONE,NORMAL,(long)"  Desk Accessory 1 ",0x0000,0x0002,0x0013,0x0001},
	{10,-1,-1,G_STRING,NONE,NORMAL,(long)"  Desk Accessory 2 ",0x0000,0x0003,0x0013,0x0001},
	{11,-1,-1,G_STRING,NONE,NORMAL,(long)"  Desk Accessory 3 ",0x0000,0x0004,0x0013,0x0001},
	{12,-1,-1,G_STRING,NONE,NORMAL,(long)"  Desk Accessory 4 ",0x0000,0x0005,0x0013,0x0001},
	{13,-1,-1,G_STRING,NONE,NORMAL,(long)"  Desk Accessory 5 ",0x0000,0x0006,0x0013,0x0001},
	{5,-1,-1,G_STRING,LASTOB,NORMAL,(long)"  Desk Accessory 6 ",0x0000,0x0007,0x0013,0x0001}
};



extern int  _app;

extern long Dreadlabel(const char *path, char *label, int length);


char       *helpbuf = NULL,
           *accname = NULL,
           *xaccname = NULL,
           *gslongname = NULL,
           *avfile,
           *avextall,
           *avextusr = NULL,
           *defcmd,
           *cs_fname,
           *sampleboot = NULL,
           *sampleopen = NULL,
           *sampleclose = NULL,
           *samplestart = NULL,
           *sampleavfail = NULL,
           *sampletimer = NULL,
           *sampleterm = NULL,
           *bubblehelp = NULL,
            menuentry[] = "  Start Me Up! ",
#ifdef GERMAN
            drventry[]  = "  Laufwerke",
            docentry[] = "  Dokumente",
            appentry[] = "  Programme",
            fseltitle[] = "Programm starten",
            xaccusr[] = "1Win95 Startknopf",
            bubbleinfo[] = "Wenn Sie diesen Bereich des SMU-Buttons mit der linken Maustaste anklicken und diese gedrckt halten, k”nnen Sie den SMU-Button auf dem Desktop verschieben.",
/*            bubbleinfo2[] = "Verschiebt den Button bei gedrckter Maustaste", */
#else
#ifdef NORWEGIAN
            drventry[]  = "  Drev",
            docentry[] = "  Dokumenter",
            appentry[] = "  Applications",
            fseltitle[] = "Start applikasjon",
            xaccusr[] = "1Win95 start-knapp",
            bubbleinfo[] = "Hvis du klikker her med venstre musknapp og holder knappen nede, kan du flytte SMU-knappen rundt om p† desktopen.",
#else
#ifdef SWEDISH
            drventry[]  = "  Enheter",
            docentry[] = "  Dokument",
            appentry[] = "  Applications",
            fseltitle[] = "Starta program",
            xaccusr[] = "1Win95 Start knapp",
            bubbleinfo[] = "Om du trycker med v„sterknappen i denna area av SMU, och h†ller mus-knappen nedtryckt, s† kan du flytta SMU till n†gon annan plats p† skrivbordet.",
#else
            drventry[]  = "  Drives",
            docentry[] = "  Documents",
            appentry[] = "  Applications",
            fseltitle[] = "Start application",
            xaccusr[] = "1Win95 start button",
            bubbleinfo[] = "If you click in this area of the SMU button with the left mouse button and keep the mouse button pressed you can move the SMU button on the desktop.",
#endif
#endif
#endif
/*            startpath[128], */
            shutdown[128],
            logfile[128],
            nolabel[30],
            servername[16],
            home[128],
           *labels[26];
int         whandle = 0,
            menu_id = -1,
            v_handle,
            ap_id,
            colors = 0,
            extmagxmenu = 0,
            helpid = -1,
            avserver = -1,
            gsapp = -1,
            appline = -1,
            applinepos = 0,
            wmclosed = 0,
            btnidx = 2,
            extrsc = 0,
            avignore = 0,
            avnoacc = 0,
            avnotos = 0,
            tosmultistart = 0,
            vaprotostatus = 0,
            dobroadcast = 1,
            magxfadeout = 0,
            noquitalert = 0,
            shuttimeout = 2000,
            docmax = 15,
            docmaxperapp = 5,
            savelinks = 0,
            nowindow = 0,
            drives = 0,
            documents = 0,
            applications = 0,
            appmax = 10,
            desktop = 0,
            apterm = 0,
            untop = 0,
            quit = 0;
long        mxdate = 0;
GRECT       desk;
KEYTAB     *kt = NULL;
AESPB       aespb;
STARTINF    startinf;
STARTMENU  *menus = NULL;
OBJECT     *startbutton = bigbutton;
C_SOUNDS   *cs;
MN_SET      mnset;
ALIAS      *alias = NULL;
TIMER      *timer = NULL;
DHST       *dhst  = NULL;
STIC       *stic;
USERBLK     usrdef;
GS_INFO    *gsi = NULL;



char *_sccs_id(void);
int cdecl draw_menu_rect(PARMBLK *parmblock);
COOKIE *get_cookie_jar(void);
int  get_cookie(long id, long *value);
int  new_cookie(long id, long value);
int  remove_cookie(long id);
int  appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4);
int  is_top(int handle);
int  rc_intersect(GRECT *r1, GRECT *r2);
void call_aes(void);
int  form_xdo(OBJECT *tree, int startob, int *lastcrsr, void *tabs, void *flydial);
int  form_xdial(int flag, int ltx, int lty, int ltw, int lth, int bgx, int bgy, int bgw, int bgh, void **flydial);
void mouse_on(void);
void mouse_off(void);
WORD MapKey(WORD keystate, WORD key);
void fix_child(OBJECT *tree, int obj, int parent);
void fix_tree(OBJECT *tree);
int  dialog(OBJECT *tree);
long call_hsn(void);
void play_sound(char *fname);
void init_vdi(void);
void exit_vdi(void);

void create_links(void);
void store_links(void);
void cleanup(int broadcast);
void findstic(void);
void final_init(void);
int  find_avserver(int avprot);
void cdecl sig_handler(long sig);
int  Fgets(char *str,int n,int handle);
void get_alias(char **dummy);
int read_group(char *grpfile, STARTMENU *curr);
int  get_system_parameter(char *startset);
void cnf_error(int err, int line);
OBJECT *build_popup(STARTMENU *curr, int drv, int docs, int apps);
void attach_popups(STARTMENU *curr, int drv, int docs, int apps);
void free_dhst(DHST *d);
int add_dhst(DHSTINFO *dhstinfo);
void load_dhst(void);
void save_inf(int savedhst);
int  find_help(void);
void call_help(void);
void clip_startinf(void);
void open_main_window(void);
void about(void);
void start_app(int force, int how, char *file, char *cmd);
STARTMENU *find_menu(STARTMENU *curr, OBJECT *tree);
int  handle_keyboard(int kstate, int key);
void start_by_sel(void);
void folder_state(STARTMENU *curr, int drv, int docs, int apps, int enable);
void start_popup(char *dcmd, int dx, int dy, int dflags, int what, char *mname);
void init_shutdown(void);
void info_popup(int mx, int my);
void move_button(void);
void show_bubblehelp(int mx, int my);
void handle_button(int mx, int my, int bstate, int kstate, int clicks);
void redraw(int x, int y, int w, int h);
char *nextToken(char *pcmd);
int  doGSCommand(int pipe[8]);
void open_over_mouse(char *p, int what, char *mname);
int  handle_message(int pipe[8]);
int  print_two(int handle, int value);
void start_timer(TIMER *dtimer);
void event_loop(void);



char *_sccs_id(void)
{
	return "@(#)StartMeUp! 8.00 (02.10.1998) by Thomas Much."; /**/
}


int cdecl draw_menu_rect(PARMBLK *parmblock)
{
	int xy[4];
	
	xy[0] = parmblock->pb_x;
	xy[3] = parmblock->pb_y + (parmblock->pb_h >> 1);
	xy[2] = xy[0] + parmblock->pb_w - 1;
	
	if (extmagxmenu)
	{
		xy[1] = xy[3];
		v_pline(v_handle,2,xy);
	}
	else
	{
		xy[1] = xy[3] - 1;
		vr_recfl(v_handle,xy);
	}

	return(NORMAL);
}


COOKIE *get_cookie_jar(void)
{
	return (COOKIE *)Setexc(360,(void (*)())-1L);
}


int get_cookie(long id, long *value)
{
	COOKIE *cookiejar = get_cookie_jar();

	if (cookiejar)
	{
		while (cookiejar->id)
		{
			if (cookiejar->id == id)
			{
				if (value) *value = cookiejar->value;
				return(1);
			}
			
			cookiejar++;
		}
	}
	
	return(0);
}


int new_cookie(long id, long value)
{
	COOKIE *cookiejar = get_cookie_jar();
	
	if (cookiejar)
	{
		long maxc, anz = 1;
		
		while (cookiejar->id)
		{
			anz++;
			cookiejar++;
		}
		
		maxc = cookiejar->value;
		
		if (anz < maxc)
		{
			cookiejar->id    = id;
			cookiejar->value = value;
			
			cookiejar++;
			
			cookiejar->id    = 0L;
			cookiejar->value = maxc;
			
			return(1);
		}
	}
	
	return(0);
}


int remove_cookie(long id)
{
	COOKIE *cookiejar = get_cookie_jar();
	
	if (cookiejar)
	{
		while ((cookiejar->id) && (cookiejar->id != id)) cookiejar++;
		
		if (cookiejar->id)
		{
			COOKIE *cjo;
			
			do
			{
				cjo = cookiejar++;
			
				cjo->id    = cookiejar->id;
				cjo->value = cookiejar->value;

			} while(cookiejar->id);
			
			return(1);
		}
	}
	
	return(0);
}


int appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4)
{
	int dummy,has_agi = 0;

  has_agi = ((_GemParBlk.global[0] == 0x399 && get_cookie('MagX',NULL))
            || (_GemParBlk.global[0] >= 0x400)
            || (appl_find("?AGI") >= 0))
            || (wind_get(0,WF_WINX,&dummy,&dummy,&dummy,&dummy) == WF_WINX);

	if (has_agi) return(appl_getinfo(type,out1,out2,out3,out4));
	else
		return(0);
}


int is_top(int handle)
{
	int wid,i;
	
	wind_get(DESK,WF_TOP,&wid,&i,&i,&i);
	return((wid) && (wid == handle));
}


int rc_intersect(GRECT *r1, GRECT *r2)
{
  int x,y,w,h;

  x = max(r2->g_x,r1->g_x);
  y = max(r2->g_y,r1->g_y);
  w = min(r2->g_x+r2->g_w,r1->g_x+r1->g_w);
  h = min(r2->g_y+r2->g_h,r1->g_y+r1->g_h);

  r2->g_x = x;
  r2->g_y = y;
  r2->g_w = w-x;
  r2->g_h = h-y;

  return (((w>x)&&(h>y)));
}


void call_aes(void)
{
	aespb.contrl  = _GemParBlk.contrl;
	aespb.global  = _GemParBlk.global;
	aespb.intin   = _GemParBlk.intin;
	aespb.intout  = _GemParBlk.intout;
	aespb.addrin  = (int *)_GemParBlk.addrin;
	aespb.addrout = (int *)_GemParBlk.addrout;

	_crystal(&aespb);
}


int form_xdo(OBJECT *tree, int startob, int *lastcrsr, void *tabs, void *flydial)
{
	_GemParBlk.contrl[0] = 50;
	_GemParBlk.contrl[1] =  1;
	_GemParBlk.contrl[2] =  2;
	_GemParBlk.contrl[3] =  3;
	_GemParBlk.contrl[4] =  0;
	_GemParBlk.intin[0]  = startob;
	_GemParBlk.addrin[0] = tree;
	_GemParBlk.addrin[1] = tabs;
	_GemParBlk.addrin[2] = flydial;

	call_aes();
	*lastcrsr = _GemParBlk.intout[1];
	return(_GemParBlk.intout[0]);
}


int form_xdial(int flag, int ltx, int lty, int ltw, int lth, int bgx, int bgy, int bgw, int bgh, void **flydial)
{
	_GemParBlk.contrl[0] = 51;
	_GemParBlk.contrl[1] =  9;
	_GemParBlk.contrl[2] =  1;
	_GemParBlk.contrl[3] =  2;
	_GemParBlk.contrl[4] =  0;
	_GemParBlk.intin[0]  = flag;
	_GemParBlk.intin[1]  = ltx;
	_GemParBlk.intin[2]  = lty;
	_GemParBlk.intin[3]  = ltw;
	_GemParBlk.intin[4]  = lth;
	_GemParBlk.intin[5]  = bgx;
	_GemParBlk.intin[6]  = bgy;
	_GemParBlk.intin[7]  = bgw;
	_GemParBlk.intin[8]  = bgh;
	_GemParBlk.addrin[0] = flydial;
	_GemParBlk.addrin[1] = 0;

	call_aes();
	return(_GemParBlk.intout[0]);
}


void mouse_on(void)
{
  graf_mouse(M_ON,NULL);
}


void mouse_off(void)
{
  graf_mouse(M_OFF,NULL);
}


WORD MapKey(WORD keystate, WORD key)
{
	WORD scancode,ret;
	
	if (!kt) kt=(KEYTAB *)Keytbl((VOID *)-1L,(VOID *)-1L,(VOID *)-1L);
	
	scancode = (key >> 8) & 0xff;
	
	if ((keystate & KsALT) && (scancode >= 0x78) && (scancode <= 0x83)) scancode -= 0x76;
	
	if (keystate & KsCAPS) ret = kt->capslock[scancode];
	else
	{
		if (keystate & KsSHIFT) ret = kt->shift[((scancode>=KbF11) && (scancode<=KbF20))?scancode-0x19:scancode];
		else
			ret = kt->unshift[scancode];
	}

	if (!ret) ret = scancode|KbSCAN;
	else
		if ((scancode == 0x4a) || (scancode == 0x4e) || ((scancode >= 0x63) && (scancode <= 0x72))) ret |= KbNUM;

	return(ret|(keystate << 8));
}


void fix_child(OBJECT *tree, int obj, int parent)
{
	do
	{
		rsrc_obfix(tree,obj);
		
		if (tree[obj].ob_head>=0) fix_child(tree,tree[obj].ob_head,obj);
		
		obj = tree[obj].ob_next;
	}
	while (obj != parent);
}


void fix_tree(OBJECT *tree)
{
	fix_child(tree,ROOT,-1);
}


int dialog(OBJECT *tree)
{
	int   cx,cy,cw,ch,ret,dummy,x,y,w,h;
	void *flyinf;

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	if (whandle>0)
	{
		wind_get(whandle,WF_CURRXYWH,&x,&y,&w,&h);
	}
	else
	{
		x=y=w=h=0;
	}

	form_center(tree,&cx,&cy,&cw,&ch);
  graf_growbox(x,y,w,h,cx,cy,cw,ch);
  form_xdial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch,&flyinf);

  objc_draw(tree,ROOT,MAX_DEPTH,cx,cy,cw,ch);
  ret = form_xdo(tree,0,&dummy,NULL,flyinf) & 0x7fff;

	form_xdial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch,&flyinf);
	graf_shrinkbox(x,y,w,h,cx,cy,cw,ch);

  wind_update(END_MCTRL);
  wind_update(END_UPDATE);

	tree[ret].ob_state &= ~SELECTED;

	return(ret);
}


long call_hsn(void)
{
	if (cs->load_sound(cs_fname)) cs->play_it(&cs->lbuf,1,0);
	return(0);
}


void play_sound(char *fname)
{
	if (!fname) return;
	if (!strlen(fname)) return;

	if (!get_cookie('HSnd',(long *)&cs)) return;
	if (cs->version < VERSION) return;
	if (cs->ruhe) return;

	cs_fname = fname;
	Supexec(call_hsn);
}


void init_vdi(void)
{
	int i,work_in[12],work_out[57];
	
	v_handle = graf_handle(&i,&i,&i,&i);
	
	for (i=0; i<10; work_in[i++]=1);
	work_in[10]=2;
	
	v_opnvwk(work_in,&v_handle,work_out);

	if (v_handle)
	{
		colors = work_out[13];

		vsf_interior(v_handle,FIS_PATTERN);
		vsf_style(v_handle,4);
		vswr_mode(v_handle,MD_TRANS);
	}
}


void exit_vdi(void)
{
	if (v_handle) v_clsvwk(v_handle);
}



void main(int argc, const char *argv[])
{
	_GemParBlk.global[0]=0;
  ap_id = appl_init();
  if (!_GemParBlk.global[0])
  {
  	Cconws(message[MSG_AUTO_ERROR]);
	  exit(0);
  }
 
  if (ap_id>=0)
  {
		MAGX_COOKIE *cv;

  	int thisdhst = 0;
  	
		Psignal(SIGTERM,sig_handler);
		Psignal(SIGQUIT,sig_handler);
  	Pdomain(1);

    graf_mouse(BUSYBEE,NULL);

		shel_write(9,1,0,NULL,NULL);
		
		if (!get_cookie('DHST',NULL))
		{
			new_cookie('DHST',ap_id);
			thisdhst=1;
		}
		
		init_vdi();
		
		if (!get_system_parameter((argc==2)?(char *)argv[1]:NULL)) goto _raus;
		
    menu_id = menu_register(ap_id,menuentry);
    menu_register(-1,"START   ");

		if (thisdhst) load_dhst();
		if (savelinks) create_links();

		play_sound(sampleboot);
	
		fix_tree(bigbutton);
		fix_tree(smallbutton);
		fix_tree(startpopup);
		fix_tree(startinfo);
		fix_tree(startdesk);
		fix_tree(deskmenu);
		
		if (v_handle)
		{
			startpopup[2].ob_type = G_USERDEF;
			startpopup[2].ob_spec.userblk = &usrdef;

			startpopup[4].ob_type = G_USERDEF;
			startpopup[4].ob_spec.userblk = &usrdef;

			startpopup[7].ob_type = G_USERDEF;
			startpopup[7].ob_spec.userblk = &usrdef;
		}

		if (get_cookie('MagX',(long *)&cv))
		{
			if (cv->aesvars)
			{
				if ((cv->aesvars->version >= 0x0514) && (colors >= 9))
				{
					extmagxmenu = 1;
					vsl_color(v_handle,9);
				}

				mxdate = (cv->aesvars->date << 16) | (cv->aesvars->date >> 24) | ((cv->aesvars->date >> 8) & 0x0000ff00L);

				if (mxdate >= 0x19971030L)
				{
					startpopup[1].ob_type = G_SHORTCUT;
					startpopup[3].ob_type = G_SHORTCUT;
					startpopup[5].ob_type = G_SHORTCUT;
					startpopup[6].ob_type = G_SHORTCUT;
					startpopup[8].ob_type = G_SHORTCUT;
				}
			}
		}

    open_main_window();
    if (whandle>0) wind_set(whandle,WF_BOTTOM,0,0,0,0);

		final_init();
    graf_mouse(ARROW,NULL);

		if ((whandle>0) || (nowindow) || (!_app))
		{
	    event_loop();

	    save_inf(thisdhst);
			if (savelinks) store_links();
	    
	    play_sound(sampleterm);
		}

    cleanup(1);

		_raus:
		if (thisdhst) remove_cookie('DHST');
		exit_vdi();
    appl_exit();
  }
  exit(0);
}


void create_links(void)
{
	long ret;
	int  handle;
	LINK link;
	char inf[128];

	strcpy(inf,home);
	strcat(inf,"defaults\\Start.lnk");
	ret=Fopen(inf,FO_READ);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"Start.lnk");
		ret=Fopen(inf,FO_READ);
	}	
	
	if (ret>=0L)
	{
		int pipe[8];
		
		handle = (int)ret;
		
		while (Fread(handle,sizeof(LINK),&link) == sizeof(LINK)) Fsymlink(link.path,link.name);

		Fclose(handle);
		
		pipe[0] = SH_WDRAW;
		pipe[1] = ap_id;
		pipe[2] = 0;
		pipe[3] = 'U'-'A';
		pipe[4] = 0;
		pipe[5] = 0;
		pipe[6] = 0;
		pipe[7] = 0;
		
		appl_write(DESK,16,&pipe);
	}
}


void store_links(void)
{
	long  ret,handle;
	int   fhdl;
	LINK  link;
	XATTR attr;
	char  inf[128],name[36];

	strcpy(inf,home);
	strcat(inf,"defaults\\Start.lnk");
	ret=Fcreate(inf,0);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"Start.lnk");
		ret=Fcreate(inf,0);
	}

	if (ret>=0L)
	{
		fhdl = (int)ret;
		
		handle = Dopendir("U:\\",0);
		
		if ((handle & 0xff000000L) != 0xff000000L)
		{
			while (!Dreaddir(36,handle,name))
			{
				strcpy(link.name,"U:\\");
				strcat(link.name,&name[4]);
				
				if (!Fxattr(1,link.name,&attr))
				{
					if (((attr.mode >> 12) & 0x000f) == 14)
					{
						if (!Freadlink(256,link.path,link.name)) Fwrite(fhdl,sizeof(LINK),&link);
					}
				}
			}
			
			Dclosedir(handle);
		}

		Fclose(fhdl);
	}
}


void cleanup(int broadcast)
{
	int pipe[8];
	
	if (apterm) return;

	if (whandle>0)
	{
		wind_close(whandle);
		wind_delete(whandle);
		whandle=-1;
	}
	
	if ((!avignore) && (broadcast) && (dobroadcast))
	{
		pipe[0]=AV_EXIT;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=ap_id;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=0;
		pipe[7]=0;
	
		shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL);
	}

	if ((broadcast) && (dobroadcast))
	{
		pipe[0]=ACC_EXIT;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=0;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=0;
		pipe[7]=0;
	
		shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL);
	}
	
	if (desktop)
	{
		menu_bar(deskmenu,0);
		wind_set(DESK,WF_NEWDESK,0,0,0,0);
	}
	
	if (extrsc) rsrc_free();
}


void findstic(void)
{
	stic = NULL;

/*	if (get_cookie('StIc',(long *)&stic))
	{
		if (stic)
		{
			if ((stic->version<0x0110) || (stic->magic !='StIc')) stic=NULL;
		}
	} */
}


void final_init(void)
{
	int   pipe[8];
	
	usrdef.ub_code = draw_menu_rect;
	usrdef.ub_parm = 0L;

	if (stic) stic->menu_settings(1,&mnset);
	else
		menu_settings(1,&mnset);

	if (desktop)
	{
		startdesk[ROOT].ob_x = desk.g_x;
		startdesk[ROOT].ob_y = desk.g_y;
		startdesk[ROOT].ob_width = desk.g_w;
		startdesk[ROOT].ob_height = desk.g_h;

		wind_set(DESK,WF_NEWDESK,(int)(((long)&startdesk >> 16) & 0x0000ffffL),(int)((long)&startdesk & 0x0000ffffL),ROOT,0);
		form_dial(FMD_FINISH,desk.g_x,desk.g_y,desk.g_w,desk.g_h,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
		
		menu_bar(deskmenu,1);
	}

	xaccname = (char *)Mxalloc(96L,ALLOCMODE);
	if (xaccname)
	{
		strncpy(xaccname,"Start Me Up!",95);
		strcpy(xaccname+13,"XDSC");
		strcpy(xaccname+18,"2DT");
		strcpy(xaccname+22,"NSTART");
		strcpy(xaccname+29,xaccusr);
		
		gslongname = xaccname+64;
		strcpy(gslongname,"Start Me Up!");
	}

	if (dobroadcast)
	{
		pipe[0]=ACC_ID;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=0;
		pipe[4]=(int)(((long)xaccname >> 16) & 0x0000ffffL);
		pipe[5]=(int)((long)xaccname & 0x0000ffffL);
		pipe[6]=menu_id;
		pipe[7]=0;

		shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL);
	}

	if (!avignore)
	{
		accname = (char *)Mxalloc(16L,ALLOCMODE);
		if (accname) strcpy(accname,"START   ");

		if (dobroadcast)
		{
			pipe[0]=AV_PROTOKOLL;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=AVMSG;
			pipe[4]=0;
			pipe[5]=0;
			pipe[6]=(int)(((long)accname >> 16) & 0x0000ffffL);
			pipe[7]=(int)((long)accname & 0x0000ffffL);
	
			shel_write(SHW_BROADCAST,0,0,(char *)pipe,NULL);
		}

		find_avserver(0);
	}
}


int find_avserver(int avprot)
{
	char *dummy;
	int   pipe[8];

	if (avignore) return(0);

	if (avserver>=0)
	{
		if (avserver==appl_find(servername)) return(1);
	}

	dummy = getenv("AVSERVER");
	if (dummy)
	{
		int i;

		strncpy(servername,dummy,9);
		servername[8]=0;
		while (strlen(servername)<8) strcat(servername," ");
		for (i=0;i<8;i++) servername[i]=toupper(servername[i]);
		
		avserver=appl_find(servername);
		if (avserver>=0) goto _success;
	}

	avserver=appl_find("THING   ");
	if (avserver>=0)
	{
		strcpy(servername,"THING   ");
		goto _success;
	}

	avserver=appl_find("GEMINI  ");
	if (avserver>=0)
	{
		strcpy(servername,"GEMINI  ");
		goto _success;
	}

	avserver=appl_find("EASE    ");
	if (avserver>=0)
	{
		strcpy(servername,"EASE    ");
		goto _success;
	}

	avserver=appl_find("MAGXDESK");
	if (avserver>=0)
	{
		strcpy(servername,"MAGXDESK");
		goto _success;
	}

	avserver=appl_find("JINNEE  ");
	if (avserver>=0)
	{
		strcpy(servername,"JINNEE  ");
		goto _success;
	}
	
	return(0);
	
	_success:
	if (avprot)
	{
		pipe[0]=AV_PROTOKOLL;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=AVMSG;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=(int)(((long)accname >> 16) & 0x0000ffffL);
		pipe[7]=(int)((long)accname & 0x0000ffffL);
		
		appl_write(avserver,16,pipe);
	}

	if (whandle>0)
	{
		pipe[0]=AV_ACCWINDOPEN;
		pipe[1]=ap_id;
		pipe[2]=0;
		pipe[3]=whandle;
		pipe[4]=0;
		pipe[5]=0;
		pipe[6]=0;
		pipe[7]=0;

		appl_write(avserver,16,pipe);
	}

	return(1);
}


void cdecl sig_handler(long sig)
{
	if ((sig==SIGTERM) || (sig==SIGQUIT)) quit=1;
}


int Fgets(char *str,int n,int handle)
{
	int  count=0,succ=0;
	char c;

	while (Fread(handle,1,&c)==1)
	{
		if (c==13)
		{
			succ=1;
			break;
		}
		else
		{
			if (c!=10)
			{
				str[count++]=c;
				if (count>=n) break;
			}
		}
	}

	str[count]=0;

	return((count) || (succ));
}


void get_alias(char **dummy)
{
	ALIAS *dalias = alias;
	char  *env;

	if (*dummy[0] != '$') return;

	while (dalias)
	{
		if (!strcmp(dalias->old,*dummy))
		{
			*dummy=dalias->new;
			return;
		}

		dalias=dalias->next;
	}
	
	env=getenv((*dummy)+1L);
	if (env) *dummy=env;
}


int read_group(char *grpfile,STARTMENU *curr)
{
	char       *dummy,*tok,*wildcmd,*entryname,filename[256],buf[512];
	long        ret;
	int         handle;
	STARTENTRY *se     = curr->entries,*se2,
	           *selast = NULL,*selast2;
	STARTMENU  *sm     = curr->children,
	           *smlast = NULL;

	ret=Fopen(grpfile,FO_READ);
	if (ret<0L) return(0);

	handle  = (int)ret;

	while (se)
	{
		selast = se;
		se = se->next;
	}
	
	while (sm)
	{
		smlast = sm;
		sm = sm->next;
	}

	se = NULL;
	sm = NULL;
	
	_nextline:
	while (Fgets(buf,511,handle))
	{
		dummy=strrchr(buf,13);
		if (dummy) *dummy=0;
		dummy=strrchr(buf,10);
		if (dummy) *dummy=0;
		
		if (strlen(buf))
		{
			if (buf[0]=='#') goto _nextline;
			
			if (!strncmp(buf,"OFIL",4))
			{
				if ((!se) || (!sm)) return(0);

				entryname=strchr(buf,'"');
				if (!entryname) return(0);
				entryname++;
				
				tok=strchr(entryname,'"');
				if (!tok) return(0);
				*tok=0;
				do
				{
					tok++;
				} while (*tok==' ');
				
				wildcmd=strchr(tok,' ');
				if (!wildcmd) return(0);
				*wildcmd=0;
				do
				{
					wildcmd++;
				} while (*wildcmd!='"');
				wildcmd++;

				if ((*tok=='\\') || (*(tok+1L)==':')) strcpy(filename,tok);
				else
				{
					strcpy(filename,grpfile);
					dummy=strrchr(filename,'\\');
					
					if (!dummy) strcpy(filename,tok);
					else
						strcpy(dummy+1L,tok);
				}

				se2     = sm->entries;
				selast2 = NULL;

				while (se2)
				{
					selast2 = se2;
					se2 = se2->next;
				}

				se2 = (STARTENTRY *)malloc(sizeof(STARTENTRY));
				if (!se2)
				{
					form_alert(1,message[MSG_CNFMEM_ERROR]);
					return(0);
				}
									
				se2->name  = (char *)malloc(strlen(entryname)+1L);
				se2->file  = (char *)malloc(strlen(filename)+1L);
				se2->fcmd  = NULL;
				se2->next  = NULL;
				se2->flags = SE_FILE;
				
				if ((!se2->name) || (!se2->file))
				{
					form_alert(1,message[MSG_CNFMEM_ERROR]);
					return(0);
				}
				
				strcpy(se2->name,entryname);
				strcpy(se2->file,filename);
				
				if (*wildcmd!='"')
				{
					dummy=strchr(wildcmd,'"');
					if (dummy)
					{
						*dummy=0;

						se2->fcmd = (char *)Mxalloc(strlen(wildcmd)+2L,ALLOCMODE);

						if (se2->fcmd)
						{
							strcpy(&(se2->fcmd[1]),wildcmd);
							se2->fcmd[0]=min(strlen(wildcmd),125);
						}
					}
				}
				
				if (!selast2) sm->entries = se2;
				else
					selast2->next = se2;
			}
			else if (!strncmp(buf,"OFLD",4))
			{
				if ((!se) || (!sm)) return(0);

				entryname=strchr(buf,'"');
				if (!entryname) return(0);
				entryname++;
				
				tok=strchr(entryname,'"');
				if (!tok) return(0);
				*tok=0;
				do
				{
					tok++;
				} while (*tok==' ');

				wildcmd=strchr(tok,' ');
				if (!wildcmd) return(0);
				*wildcmd=0;
				do
				{
					wildcmd++;
				} while (*wildcmd!='"');
				wildcmd++;

				if ((*tok=='\\') || (*(tok+1L)==':')) strcpy(filename,tok);
				else
				{
					strcpy(filename,grpfile);
					dummy=strrchr(filename,'\\');
					
					if (!dummy) strcpy(filename,tok);
					else
						strcpy(dummy+1L,tok);
				}
				
				if (*wildcmd!='"')
				{
					dummy=strchr(wildcmd,'"');
					if (dummy)
					{
						*dummy=0;
						strcat(filename,wildcmd);
					}
				}
				
				se2     = sm->entries;
				selast2 = NULL;

				while (se2)
				{
					selast2 = se2;
					se2 = se2->next;
				}

				se2 = (STARTENTRY *)malloc(sizeof(STARTENTRY));
				if (!se2)
				{
					form_alert(1,message[MSG_CNFMEM_ERROR]);
					return(0);
				}
									
				se2->name  = (char *)malloc(strlen(entryname)+1L);
				se2->file  = (char *)malloc(strlen(filename)+1L);
				se2->fcmd  = NULL;
				se2->next  = NULL;
				se2->flags = SE_FOLDER;
				
				if ((!se2->name) || (!se2->file))
				{
					form_alert(1,message[MSG_CNFMEM_ERROR]);
					return(0);
				}
				
				strcpy(se2->name,entryname);
				strcpy(se2->file,filename);

				if (!selast2) sm->entries = se2;
				else
					selast2->next = se2;
			}
			else if (!strncmp(buf,"INFO",4))
			{
				if ((se) || (sm)) return(0);

				se = (STARTENTRY *)malloc(sizeof(STARTENTRY));
				sm = (STARTMENU *)malloc(sizeof(STARTMENU));
				
				if ((!se) || (!sm))
				{
					form_alert(1,message[MSG_CNFMEM_ERROR]);
					return(0);
				}
				
				dummy=strchr(buf,'"');
				if (!dummy) return(0);
				dummy++;
				
				tok=strchr(dummy,'"');
				if (!tok) return(0);
				*tok=0;

				se->name  = (char *)malloc(strlen(dummy)+1L);
				se->file  = NULL;
				se->fcmd  = NULL;
				se->next  = NULL;
				se->flags = 0;
				
				if (!se->name)
				{
					form_alert(1,message[MSG_CNFMEM_ERROR]);
					return(0);
				}
				
				strcpy(se->name,dummy);
				
				if (!selast) curr->entries = se;
				else
					selast->next = se;
				
				if (!smlast) curr->children = sm;
				else
					smlast->next = sm;
				
				sm->tree     = NULL;
				sm->entries  = NULL;
				sm->children = NULL;
				sm->next     = NULL;
				sm->parent   = curr;
			}
		}
	}
	
	Fclose(handle);
	
	return(1);
}


int get_system_parameter(char *startset)
{
	char       *dummy,inf[128],buf[512],entryname[40],smp[128],rsc[128];
	int         handle,state,level,cnfline,agi1,agi2,agi3,agi4,
	            rscobj = -1,magxignore = 0,i;
	long        ret,deskcol = 0x0000004cL;
	STARTINF    si;
	STARTMENU  *curr;
	STARTENTRY *lastfile;
	ALIAS      *dalias;

	wind_get(DESK,WF_WORKXYWH,&desk.g_x,&desk.g_y,&desk.g_w,&desk.g_h);

	findstic();
	if (stic) stic->menu_settings(0,&mnset);
	else
		menu_settings(0,&mnset);

	for (i=0;i<26;i++) labels[i]=NULL;

	avfile = (char *)Mxalloc(256L,ALLOCMODE);
	avextall = (char *)Mxalloc(128L,ALLOCMODE);

	if (avextall)
	{
		avextusr = avextall + 8L;
		strcpy(avextall,"*");
	}
	
	defcmd = (char *)Mxalloc(128L,ALLOCMODE);
	if (defcmd)
	{
		defcmd[0]=0;
		defcmd[1]=0;
	}

	shutdown[0] = 0;
	nolabel[0]  = 0;
	logfile[0]  = 0;

	dummy = getenv("HOME");
	if (dummy)
	{
		strcpy(home,dummy);
		if (strlen(home)>0)
		{
			if (home[strlen(home)-1] != '\\') strcat(home,"\\");
		}
	}
	else
		home[0]=0;

/*	strcpy(startpath,home);
	strcat(startpath,"Start\\"); */
	
	startinf.version  = INFVER;
	startinf.workxabs = -2000;
	startinf.workyabs = 30000;
	
	strcpy(inf,home);
	strcat(inf,"defaults\\Start.inf");
	ret=Fopen(inf,FO_READ);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"Start.inf");
		ret=Fopen(inf,FO_READ);
	}	
	
	if (ret>=0L)
	{
		handle = (int)ret;

		if (Fread(handle,sizeof(STARTINF),&si)==sizeof(STARTINF))
		{
			if (si.version==INFVER) startinf=si;
		}

		Fclose(handle);
	}

	if (startset)
	{
		strcpy(inf,startset);
		ret=Fopen(inf,FO_READ);
	}
	else
	{
		strcpy(inf,home);
		strcat(inf,"defaults\\Start.set");
		ret=Fopen(inf,FO_READ);
	
		if (ret<0L)
		{
			strcpy(inf,home);
			strcat(inf,"Start.set");
			ret=Fopen(inf,FO_READ);
		}	
	
		if (ret<0L)
		{
			strcpy(inf,"Start.set");
			ret=Fopen(inf,FO_READ);
		}
	}
	
	if (ret>=0L)
	{
		handle  = (int)ret;
		level   = 0;
		cnfline = 0;
		
		menus = (STARTMENU *)malloc(sizeof(STARTMENU));
		if (!menus)
		{
			form_alert(1,message[MSG_CNFMEM_ERROR]);
			return(0);
		}

		menus->tree     = NULL;
		menus->entries  = NULL;
		menus->children = NULL;
		menus->next     = NULL;
		menus->parent   = NULL;
		
		curr = menus;

		_nextline:
		while (Fgets(buf,511,handle))
		{
			cnfline++;
			
			dummy=strrchr(buf,13);
			if (dummy) *dummy=0;
			dummy=strrchr(buf,10);
			if (dummy) *dummy=0;
			
			if (strlen(buf))
			{
				state = 0;
				dummy = strtok(buf,"\x09");

				while (dummy)
				{
					if (strlen(dummy))
					{
						switch(state)
						{
							case 0:
								if (dummy[0]=='#') goto _nextline;
								else if (!stricmp(dummy,"/file")) state=10;
								else if (!stricmp(dummy,"/menu")) state=20;
								else if (!stricmp(dummy,"/end"))
								{
									level--;
									
									if (level<0)
									{
										cnf_error(MSG_CNF_ERROR,cnfline);
										return(0);
									}
									
									curr = curr->parent;

									goto _nextline;
								}
								else if (!stricmp(dummy,"/separator"))
								{
									STARTENTRY *se     = curr->entries,
									           *selast = NULL;
									           
									while (se)
									{
										selast = se;
										se = se->next;
									}
									
									se = (STARTENTRY *)malloc(sizeof(STARTENTRY));
									if (!se)
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}
									
									se->name  = NULL;
									se->file  = NULL;
									se->fcmd  = NULL;
									se->next  = NULL;
									se->flags = 0;

									if (!selast) curr->entries = se;
									else
										selast->next = se;

									goto _nextline;
								}
								else if (!stricmp(dummy,"/group")) state=25;
								else if (!stricmp(dummy,"/folder")) state=50;
								else if (!stricmp(dummy,"/alias")) state=100;
								else if (!stricmp(dummy,"/timer")) state=110;
								else if (!stricmp(dummy,"/label")) state=120;
								else if (!stricmp(dummy,"/shutdown")) state=30;
								else if (!stricmp(dummy,"/shutdown_timeout")) state=32;
								else if (!stricmp(dummy,"/documents_max")) state=33;
								else if (!stricmp(dummy,"/documents_maxperapp")) state=34;
								else if (!stricmp(dummy,"/logfile")) state=35;
								else if (!stricmp(dummy,"/applications_max")) state=36;
								else if (!stricmp(dummy,"/avignore"))
								{
									avignore=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/avnoacc"))
								{
									avnoacc=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/drives"))
								{
									drives=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/documents"))
								{
									documents=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/applications"))
								{
/*									applications=1; */
									goto _nextline;
								}
								else if (!stricmp(dummy,"/savelinks"))
								{
									savelinks=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/small"))
								{
									startbutton=smallbutton;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/desktop"))
								{
									desktop=1;
									state=80;
									break;
								}
								else if (!stricmp(dummy,"/avnotos"))
								{
									avnotos=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/tosmultistart"))
								{
									tosmultistart=1;
									goto _nextline;
								}
								else if (!strnicmp(dummy,"/sample_",8))
								{
									strcpy(smp,dummy+8);
									state=40;
									break;
								}
								else if (!strnicmp(dummy,"/pop_",5))
								{
									strcpy(smp,dummy+5);
									state=60;
									break;
								}
								else if (!stricmp(dummy,"/backwind"))
								{
									untop=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/resource")) state=70;
								else if (!stricmp(dummy,"/magxignore"))
								{
									magxignore=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/vaprotostatus"))
								{
									vaprotostatus=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/nolabel")) state=90;
								else if (!stricmp(dummy,"/magxfadeout"))
								{
									magxfadeout=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/noquitalert"))
								{
									noquitalert=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/appline"))
								{
									applinepos=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/wmclosed"))
								{
									wmclosed=1;
									goto _nextline;
								}
								else if (!stricmp(dummy,"/nowindow"))
								{
									nowindow=1;
									goto _nextline;
								}
								else
								{
									cnf_error(MSG_CNF_ERROR,cnfline);
									return(0);
								}
								break;
							
							case 10:
							case 50:
								strncpy(entryname,dummy,40);
								state++;
								break;
							
							case 11:
							case 51:
								{
									STARTENTRY *se     = curr->entries,
									           *selast = NULL;

									while (se)
									{
										selast = se;
										se = se->next;
									}
									
									se = (STARTENTRY *)malloc(sizeof(STARTENTRY));
									if (!se)
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}
									
									get_alias(&dummy);
									
									se->name  = (char *)malloc(strlen(entryname)+1L);
									se->file  = (char *)malloc(strlen(dummy)+1L);
									se->fcmd  = NULL;
									se->next  = NULL;
									se->flags = (state==11)?SE_FILE:SE_FOLDER;
									
									if ((!se->name) || (!se->file))
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}
									
									strcpy(se->name,entryname);
									strcpy(se->file,dummy);
									
									lastfile = se;

									if (!selast) curr->entries = se;
									else
										selast->next = se;
								}
								
								if (state==51) goto _nextline;
								state++;
								break;
							
							case 12:
								if (lastfile)
								{
									get_alias(&dummy);

									lastfile->fcmd = (char *)Mxalloc(strlen(dummy)+2L,ALLOCMODE);

									if (lastfile->fcmd)
									{
										strcpy(&(lastfile->fcmd[1]),dummy);
										lastfile->fcmd[0]=min(strlen(dummy),125);
									}
								}
								goto _nextline;
							
							case 20:
								{
									STARTENTRY *se     = curr->entries,
									           *selast = NULL;
									STARTMENU  *sm     = curr->children,
									           *smlast = NULL;

									while (se)
									{
										selast = se;
										se = se->next;
									}

									while (sm)
									{
										smlast = sm;
										sm = sm->next;
									}
									
									se = (STARTENTRY *)malloc(sizeof(STARTENTRY));
									sm = (STARTMENU *)malloc(sizeof(STARTMENU));
									
									if ((!se) || (!sm))
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}
									
									se->name  = (char *)malloc(strlen(dummy)+1L);
									se->file  = NULL;
									se->fcmd  = NULL;
									se->next  = NULL;
									se->flags = 0;
									
									if (!se->name)
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}
									
									strcpy(se->name,dummy);

									if (!selast) curr->entries = se;
									else
										selast->next = se;

									if (!smlast) curr->children = sm;
									else
										smlast->next = sm;
									
									sm->tree     = NULL;
									sm->entries  = NULL;
									sm->children = NULL;
									sm->next     = NULL;
									sm->parent   = curr;
									
									curr = sm;
									level++;
									
									if (level>3)
									{
										cnf_error(MSG_NEST_ERROR,cnfline);
										return(0);
									}
								}
								goto _nextline;
							
							case 25:
								if (level>=3)
								{
									cnf_error(MSG_NEST_ERROR,cnfline);
									return(0);
								}
								
								if (!(read_group(dummy,curr)))
								{
									cnf_error(MSG_THING_GROUP,cnfline);
									return(0);
								}
								goto _nextline;
							
							case 30:
								strncpy(shutdown,dummy,127);
								goto _nextline;
							
							case 32:
								shuttimeout=(int)atol(dummy);
								goto _nextline;

							case 33:
								docmax=max(3,(int)atol(dummy));
								goto _nextline;

							case 34:
								docmaxperapp=max(1,(int)atol(dummy));
								goto _nextline;

							case 35:
								strncpy(logfile,dummy,127);
								goto _nextline;
							
							case 36:
								appmax=max(3,(int)atol(dummy));
								goto _nextline;
							
							case 40:
								{
									char *fle;
									
									get_alias(&dummy);
									fle = (char *)malloc(strlen(dummy)+1);
									
									if (fle)
									{
										strcpy(fle,dummy);
										
										if (!stricmp(smp,"boot")) sampleboot=fle;
										else if (!stricmp(smp,"open")) sampleopen=fle;
										else if (!stricmp(smp,"start")) samplestart=fle;
										else if (!stricmp(smp,"avfail")) sampleavfail=fle;
										else if (!stricmp(smp,"term")) sampleterm=fle;
										else if (!stricmp(smp,"close")) sampleclose=fle;
										else if (!stricmp(smp,"timer")) sampletimer=fle;
									}
								}	
								goto _nextline;
							
							case 60:
								{
									long value = atol(dummy);
									
									if (!stricmp(smp,"display")) mnset.Display=value;
									else
									{
										if (!stricmp(smp,"drag")) mnset.Drag=value;
									}
								}
								goto _nextline;
							
							case 70:
								strcpy(rsc,dummy);
								state++;
								break;
							
							case 71:
								rscobj=(int)atol(dummy);
								goto _nextline;
							
							case 80:
								deskcol=atol(dummy);
								goto _nextline;
							
							case 90:
								strncpy(nolabel,dummy,27);
								goto _nextline;

							case 100:
								strncpy(smp,dummy,127);
								state++;
								break;
							
							case 101:
								{
									dalias = (ALIAS *)malloc(sizeof(ALIAS));
									
									if (dalias)
									{
										dalias->next = alias;
										alias = dalias;
									
										strcpy(dalias->old,"$");
										strcat(dalias->old,smp);
										strcpy(dalias->new,dummy);
									}
								}
								goto _nextline;
							
							case 110:
								strcpy(smp,dummy);
								state++;
								break;
							
							case 111:
								{
									int    h = -1,m = -1;
									char  *mc = strchr(smp,':');
									TIMER *ti;
									
									if (mc)
									{
										*mc=0;
										h = (int)atol(smp);
										m = (int)atol(++mc);
									}
									
									if (!between(h,0,23) || !between(m,0,59))
									{
										cnf_error(MSG_CNF_ERROR,cnfline);
										return(0);
									}

									ti = (TIMER *)malloc(sizeof(TIMER));
									if (!ti)
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}

									get_alias(&dummy);
									
									ti->file = (char *)malloc(strlen(dummy)+1L);
									ti->fcmd = NULL;
									ti->next = timer;
									ti->time = (((long)h << 11) | ((long)m << 5)) & 0x0000ffe0;
									
									if (!ti->file)
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}
									
									strcpy(ti->file,dummy);
									
									timer = ti;
								}
								state++;
								break;
							
							case 112:
								if (timer)
								{
									get_alias(&dummy);

									timer->fcmd = (char *)Mxalloc(strlen(dummy)+2L,ALLOCMODE);

									if (timer->fcmd)
									{
										strcpy(&(timer->fcmd[1]),dummy);
										timer->fcmd[0]=min(strlen(dummy),125);
									}
								}
								goto _nextline;
							
							case 120:
								{
									strcpy(smp,dummy);

									if ((strlen(smp)>1) || (smp[0]<'A') || (smp[0]>'Z'))
									{
										cnf_error(MSG_CNF_ERROR,cnfline);
										return(0);
									}
								}
								state++;
								break;
							
							case 121:
								{
									char *dname = (char *)malloc(strlen(dummy)+1L);

									if (!dname)
									{
										form_alert(1,message[MSG_CNFMEM_ERROR]);
										return(0);
									}
									
									strcpy(dname,dummy);
									labels[smp[0]-'A'] = dname;
								}
								goto _nextline;
						}
					}

					dummy = strtok(NULL,"\x09");
				}
			}
		}

		Fclose(handle);
	}

	if (!magxignore)
	{
		MAGX_COOKIE *cv;
		
		if (get_cookie('MagX',(long *)&cv))
		{
			if (cv->aesvars)
			{
				if (cv->aesvars->version<0x0400)
				{
					form_alert(1,message[MSG_MAGX_VERSION]);
					return(0);
				}
			}
			else
			{
				form_alert(1,message[MSG_MAGX_ERROR]);
				return(0);
			}
		}
		else
		{
			form_alert(1,message[MSG_MAGX_ERROR]);
			return(0);
		}
	}
	else
	{
		MAGX_COOKIE *cv;

		if (get_cookie('MagX',(long *)&cv))
		{
			if (cv->aesvars)
			{
				if (cv->aesvars->version<0x0400) dobroadcast=0;
			}
		}
	}
	
	if (appl_xgetinfo(9,&agi1,&agi2,&agi3,&agi4))
	{
		if ((!agi1) || (!agi2))
		{
			form_alert(1,message[MSG_XMEN_ERROR]);
			return(0);
		}
	}
	else
	{
		form_alert(1,message[MSG_XMEN_ERROR]);
		return(0);
	}
	
	if (rscobj>=0)
	{
		if (strlen(rsc)>0)
		{
			if (rsrc_load(rsc))
			{
				rsrc_gaddr(0,0,&startbutton);
				btnidx=rscobj;
				extrsc=1;
			}
		}
	}

	if (menus)
	{
		menus->tree = build_popup(menus,drives,documents,applications);

		if (menus->tree)
		{
			startbutton[btnidx].ob_state &= ~DISABLED;
			attach_popups(menus,drives,documents,applications);
		}
	}
	
	startdesk[ROOT].ob_spec.index = deskcol;

	while (alias)
	{
		dalias = alias->next;
		free(alias);
		alias=dalias;
	}

	return(1);
}


void cnf_error(int err,int line)
{
	char buf[112],num[16];
	
	strcpy(buf,message[err]);
	itoa(line,num,10);
	strcat(buf,num);
	strcat(buf,message[MSG_ERROR_LINE]);

	form_alert(1,buf);
}


OBJECT *build_popup(STARTMENU *curr, int drv, int docs, int apps)
{
	int         c,sticurr, count = drv+docs+apps, sticons = 0,
	            maxw = (drv)?((int)strlen(drventry)-2):0;

	STARTENTRY *ce = curr->entries;
	STARTMENU  *cm = curr->children;
	OBJECT     *pop = NULL, *sticob;

	if (docs)
	{
		if (((int)strlen(docentry)-2) > maxw) maxw = (int)strlen(docentry)-2;
	}
	
	if (apps)
	{
		if (((int)strlen(appentry)-2) > maxw) maxw = (int)strlen(appentry)-2;
	}

	while (ce)
	{
		count++;
		
		if (ce->name)
		{
			if ((int)strlen(ce->name)>maxw) maxw=(int)strlen(ce->name);
			
			if (stic)
			{
				if (ce->file)
				{
					if (stic->str_icon(ce->file,STIC_SMALL)) sticons++;
				}
			}
		}
		
		ce = ce->next;
	}
	
	if (count>0)
	{
		pop = (OBJECT *)malloc(sizeof(OBJECT)*(long)(count+sticons+1));
		sticurr = count+1;
		maxw   += 5;

		if (pop)
		{
			pop[ROOT].ob_next   = -1;
			pop[ROOT].ob_head   =  1;
			pop[ROOT].ob_tail   = count;
			pop[ROOT].ob_type   = G_BOX;
			pop[ROOT].ob_flags  = FL3DBAK;
			pop[ROOT].ob_state  = NORMAL;
			pop[ROOT].ob_spec.index = 0x00ff1100L;
			pop[ROOT].ob_x      =  0;
			pop[ROOT].ob_y      =  0;
			pop[ROOT].ob_width  = maxw;
			pop[ROOT].ob_height = count;

			c=0;
			
			if (drv)
			{
				c++;
				
				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|SELECTABLE;
				pop[c].ob_state  = NORMAL;
				pop[c].ob_spec.free_string = (char *)malloc((long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;
				
				if (pop[c].ob_spec.free_string)
				{
					strcpy(pop[c].ob_spec.free_string,drventry);
					while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
				}
			}
			
			if (docs)
			{
				c++;
				
				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|SELECTABLE;
				pop[c].ob_state  = NORMAL;
				pop[c].ob_spec.free_string = (char *)malloc((long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;
				
				if (pop[c].ob_spec.free_string)
				{
					strcpy(pop[c].ob_spec.free_string,docentry);
					while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
				}
			}
			
			if (apps)
			{
				c++;
				
				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|SELECTABLE;
				pop[c].ob_state  = NORMAL;
				pop[c].ob_spec.free_string = (char *)malloc((long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;
				
				if (pop[c].ob_spec.free_string)
				{
					strcpy(pop[c].ob_spec.free_string,appentry);
					while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
				}
			}
			
			ce = curr->entries;
			while (ce)
			{
				c++;

				pop[c].ob_next   = c+1;
				pop[c].ob_head   = -1;
				pop[c].ob_tail   = -1;
				pop[c].ob_type   = G_STRING;
				pop[c].ob_flags  = FL3DBAK|SELECTABLE;
				pop[c].ob_state  = NORMAL;
				pop[c].ob_spec.free_string = (char *)malloc((long)maxw+1L);
				pop[c].ob_x      =  0;
				pop[c].ob_y      = c-1;
				pop[c].ob_width  = maxw;
				pop[c].ob_height = 1;

				if (!pop[c].ob_spec.free_string) pop[c].ob_spec.free_string = ce->name;
				else
				{
					if (ce->name)
					{
						strcpy(pop[c].ob_spec.free_string,"  ");
						strcat(pop[c].ob_spec.free_string,ce->name);
						
						if (stic)
						{
							if (ce->file)
							{
								sticob = stic->str_icon(ce->file,STIC_SMALL);

								if (sticob)
								{
									pop[c].ob_head   = sticurr;
									pop[c].ob_tail   = sticurr;

									pop[sticurr].ob_next   =  c;
									pop[sticurr].ob_head   = -1;
									pop[sticurr].ob_tail   = -1;
									pop[sticurr].ob_type   = sticob->ob_type;
									pop[sticurr].ob_flags  = FL3DBAK|SELECTABLE;
									pop[sticurr].ob_state  = NORMAL;
									pop[sticurr].ob_spec   = sticob->ob_spec;
									pop[sticurr].ob_x      =  0;
									pop[sticurr].ob_y      =  0;
									pop[sticurr].ob_width  =  2;
									pop[sticurr].ob_height =  1;
									
									/* Text nicht zeichnen, Position korrekt */
									
									sticurr++;
								}
							}
						}
						
						while (strlen(pop[c].ob_spec.free_string)<maxw) strcat(pop[c].ob_spec.free_string," ");
					}
					else
					{
						if (v_handle)
						{
							free(pop[c].ob_spec.free_string);

							pop[c].ob_type = G_USERDEF;
							pop[c].ob_spec.userblk = &usrdef;
						}
						else
						{
							memset(pop[c].ob_spec.free_string,'-',maxw);
							pop[c].ob_spec.free_string[maxw] = 0;
						}

						pop[c].ob_state |= DISABLED;
					}
				}

				if ((!ce->file) && (ce->name))
				{
					cm->tree = build_popup(cm,0,0,0);
					if (!cm->tree)
					{
						pop[c].ob_state |= DISABLED;
						pop[c].ob_spec.free_string[strlen(pop[c].ob_spec.free_string)-2]=3;
					}
					
					cm = cm->next;
				}
				
				ce = ce->next;
			}

			pop[count].ob_next = 0;
			pop[count+sticons].ob_flags |= LASTOB;
			
			fix_tree(pop);
		}
	}
	
	return(pop);
}


void attach_popups(STARTMENU *curr, int drv, int docs, int apps)
{
	STARTENTRY *ce = curr->entries;
	STARTMENU  *cm = curr->children;
	MENU        menu;
	int         c = drv+docs+apps;

	while (ce)
	{
		c++;

		if ((!ce->file) && (ce->name))
		{
			if (cm->tree)
			{
				menu.mn_tree     = cm->tree;
				menu.mn_menu     = ROOT;
				menu.mn_item     = 1;
				menu.mn_scroll   = 0;
				menu.mn_keystate = 0;

				if (stic) stic->menu_attach(ME_ATTACH,curr->tree,c,&menu);
				else
					menu_attach(ME_ATTACH,curr->tree,c,&menu);
			}
			
			attach_popups(cm,0,0,0);
			
			cm = cm->next;
		}
		
		ce = ce->next;
	}
}


void free_dhst(DHST *d)
{
	if (d->info.appname) free(d->info.appname);
	if (d->info.apppath) free(d->info.apppath);
	if (d->info.docname) free(d->info.docname);
	if (d->info.docpath) Mfree(d->info.docpath);
	
	free(d);
}


int add_dhst(DHSTINFO *dhstinfo)
{
	DHST *newdhst;
	
	if (!dhstinfo) return(0);
	if (!dhstinfo->appname) return(0);
	if (!dhstinfo->apppath) return(0);
	if (!dhstinfo->docname) return(0);
	if (!dhstinfo->docpath) return(0);
	
	newdhst = (DHST *)malloc(sizeof(DHST));
	if (!newdhst) return(0);
	
	newdhst->next = NULL;
	
	newdhst->info.appname = (char *)malloc(strlen(dhstinfo->appname)+1L);
	if (newdhst->info.appname) strcpy(newdhst->info.appname,dhstinfo->appname);

	newdhst->info.apppath = (char *)malloc(strlen(dhstinfo->apppath)+1L);
	if (newdhst->info.apppath) strcpy(newdhst->info.apppath,dhstinfo->apppath);

	newdhst->info.docname = (char *)malloc(strlen(dhstinfo->docname)+1L);
	if (newdhst->info.docname) strcpy(newdhst->info.docname,dhstinfo->docname);

	newdhst->info.docpath = (char *)Mxalloc(strlen(dhstinfo->docpath)+2L,ALLOCMODE);
	if (newdhst->info.docpath)
	{
		strcpy(&(newdhst->info.docpath[1]),dhstinfo->docpath);
		newdhst->info.docpath[0]=min(strlen(dhstinfo->docpath),125);
	}
	
	if (!dhst) dhst=newdhst;
	else
	{
		DHST *d = dhst, *dold;
		int   dcnt = 0;
		
		newdhst->next = dhst;
		dhst = newdhst;
		
		dold = dhst;
		
		while (d)
		{
			if ((!strcmp(newdhst->info.appname,d->info.appname)) && (!strcmp(newdhst->info.docname,d->info.docname)))
			{
				dold->next = d->next;

				free_dhst(d);
				
				break;
			}
			
			dold = d;
			d = d->next;
		}
		
		d = dhst;
		dold = NULL;

		while (d)
		{
			if (!strcmp(newdhst->info.appname,d->info.appname))
			{
				dcnt++;
				
				if (dcnt > docmaxperapp)
				{
					dold->next = d->next;
					
					free_dhst(d);

					break;
				}
			}

			dold = d;
			d = d->next;
		}

		d = dhst;
		dold = NULL;
		dcnt = 0;
		
		while (d->next)
		{
			dold = d;
			d = d->next;
			dcnt++;
		}
		
		if (dcnt >= docmax)
		{
			dold->next = NULL;
			free_dhst(d);
		}
	}

	return(1);
}


void load_dhst(void)
{
	char inf[1024];
	long ret;
	int  handle;

	strcpy(inf,home);
	strcat(inf,"defaults\\Start.hst");
	ret=Fopen(inf,FO_READ);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"Start.hst");
		ret=Fopen(inf,FO_READ);
	}	
	
	if (ret>=0L)
	{
		int      danz;
		long     slen;
		DHSTINFO dinfo;
		
		handle = (int)ret;
		
		dinfo.appname = &(inf[0]);
		dinfo.docname = &(inf[100]);
		dinfo.apppath = &(inf[200]);
		dinfo.docpath = &(inf[600]);
		
		Fread(handle,2,&danz);
		
		while (danz)
		{
			Fread(handle,4,&slen);
			if (slen) Fread(handle,slen,dinfo.appname);
			else
				strcpy(dinfo.appname,"");

			Fread(handle,4,&slen);
			if (slen) Fread(handle,slen,dinfo.apppath);
			else
				strcpy(dinfo.apppath,"");

			Fread(handle,4,&slen);
			if (slen) Fread(handle,slen,dinfo.docname);
			else
				strcpy(dinfo.docname,"");

			Fread(handle,4,&slen);
			if (slen) Fread(handle,slen,dinfo.docpath);
			else
				strcpy(dinfo.docpath,"");
			
			add_dhst(&dinfo);
			
			danz--;
		}

		Fclose(handle);
	}
}


void save_inf(int savedhst)
{
	char inf[128];
	int  handle;
	long ret;
	
	if (savedhst)
	{
		strcpy(inf,home);
		strcat(inf,"defaults\\Start.hst");
		ret=Fcreate(inf,0);
	
		if (ret<0L)
		{
			strcpy(inf,home);
			strcat(inf,"Start.hst");
			ret=Fcreate(inf,0);
		}

		if (ret>=0L)
		{
			DHST *d = dhst;
			long  slen;
			int   danz = 0;
			
			handle = (int)ret;
			
			while (d)
			{
				danz++;
				d = d->next;
			}
			
			Fwrite(handle,2,&danz);
			
			while (danz)
			{
				int dd = danz-1;
				
				d = dhst;
				while (dd)
				{
					dd--;
					d = d->next;
				}
				
				slen = (d->info.appname) ? (strlen(d->info.appname) + 1L) : 0L;
				Fwrite(handle,4,&slen);
				if (slen) Fwrite(handle,slen,d->info.appname);

				slen = (d->info.apppath) ? (strlen(d->info.apppath) + 1L) : 0L;
				Fwrite(handle,4,&slen);
				if (slen) Fwrite(handle,slen,d->info.apppath);

				slen = (d->info.docname) ? (strlen(d->info.docname) + 1L) : 0L;
				Fwrite(handle,4,&slen);
				if (slen) Fwrite(handle,slen,d->info.docname);

				slen = (d->info.docpath) ? (strlen(&(d->info.docpath[1])) + 1L) : 0L;
				Fwrite(handle,4,&slen);
				if (slen) Fwrite(handle,slen,&(d->info.docpath[1]));
				
				danz--;
			}

			Fclose(handle);
		}
	}

	if (startinf.workxabs <= desk.g_x) startinf.workxabs = -2000;
	if (startinf.workxabs+startbutton[ROOT].ob_width >= desk.g_x+desk.g_w) startinf.workxabs = 30000;

	if (startinf.workyabs <= desk.g_y) startinf.workyabs = -2000;
	if (startinf.workyabs+startbutton[ROOT].ob_height >= desk.g_y+desk.g_h) startinf.workyabs = 30000;
	
	strcpy(inf,home);
	strcat(inf,"defaults\\Start.inf");
	ret=Fcreate(inf,0);

	if (ret<0L)
	{
		strcpy(inf,home);
		strcat(inf,"Start.inf");
		ret=Fcreate(inf,0);
	}

	if (ret<0L) return;

	handle = (int)ret;
	Fwrite(handle,sizeof(STARTINF),&startinf);
	Fclose(handle);
}


int find_help(void)
{
	helpid = appl_find("ST-GUIDE");
	
	if (helpid<0)
	{
		char *dummy = getenv("STGUIDE");

		if (dummy)
		{
			if (!helpbuf) helpbuf = (char *)Mxalloc(16L,ALLOCMODE);
			
			if (helpbuf)
			{
				strcpy(helpbuf,"*:\\Start.hyp");
	
				start_app(0,SHW_PARALLEL,dummy,helpbuf);
	
				helpid = appl_find("ST-GUIDE");
			}
		}
	}

	return(helpid>=0);
}


void call_help(void)
{
	int pipe[8];

	if (!helpbuf)
	{
		helpbuf = (char *)Mxalloc(16L,ALLOCMODE);
		if (!helpbuf) return;
	}

	strcpy(helpbuf,"*:\\Start.hyp");

	pipe[0] = VA_START;
	pipe[1] = ap_id;
	pipe[2] = 0;
	pipe[3] = (int)(((long)helpbuf >> 16) & 0x0000ffff);
	pipe[4] = (int)((long)helpbuf & 0x0000ffff);
	pipe[5] = 0;
	pipe[6] = 0;
	pipe[7] = 0;

	appl_write(helpid,16,pipe);
}


void clip_startinf(void)
{
	if (startinf.workxabs+startbutton[ROOT].ob_width > desk.g_x+desk.g_w) startinf.workxabs = desk.g_x+desk.g_w-startbutton[ROOT].ob_width;
	if (startinf.workxabs < desk.g_x) startinf.workxabs = desk.g_x;

	if (startinf.workyabs+startbutton[ROOT].ob_height > desk.g_y+desk.g_h) startinf.workyabs = desk.g_y+desk.g_h-startbutton[ROOT].ob_height;
	if (startinf.workyabs < desk.g_y) startinf.workyabs = desk.g_y;
	
	startbutton[ROOT].ob_x = startinf.workxabs;
	startbutton[ROOT].ob_y = startinf.workyabs;
}


void open_main_window(void)
{
	if (nowindow) return;

	if (whandle<=0)
	{
		int  x,y,w,h;

		whandle = wind_create(WINDOWSTYLE,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	
		if (whandle<=0)
		{
	   	form_alert(1,message[MSG_OPEN_MAIN]);
			return;
		}
		
		clip_startinf();
		
		wind_calc(WC_BORDER,WINDOWSTYLE,startbutton[ROOT].ob_x,startbutton[ROOT].ob_y,startbutton[ROOT].ob_width,startbutton[ROOT].ob_height,&x,&y,&w,&h);

		wind_open(whandle,x,y,w,h);
    wind_set(whandle,WF_BEVENT,1,0,0,0);
	}
 	else
 	{
 		if (!untop) wind_set(whandle,WF_TOP,0,0,0,0);
 	}
}


void about(void)
{
	dialog(startinfo);
}


STARTMENU *find_menu(STARTMENU *curr, OBJECT *tree)
{
	STARTMENU *child,*found;

	if (!curr) return(NULL);
	
	if (curr->tree == tree) return(curr);
	
	child = curr->children;
	while (child)
	{
		found = find_menu(child,tree);
		if (found) return(found);

		child = child->next;
	}

	return(NULL);
}


void start_app(int force, int how, char *file, char *cmd)
{
	char *dummy,name[128],path[128],tmp_cwd[128];
	int   i,aid,sid,tmp_drive,doex=1,gem=1,executable=1;
	long  dret;

	if (!file) return;

	dummy = strrchr(file,'\\');
	if (!dummy)
	{
		dummy=file;
		strcpy(path,"\\");
	}
	else
	{
		*dummy=0;
		strcpy(path,file);
		*dummy='\\';
		dummy++;
	}
	strcpy(name,dummy);
	
	dummy = strrchr(name,'.');
	if (!dummy) gem=0;
	else
	{
		if ((!stricmp(dummy,".ACC")) || (!stricmp(dummy,".ACX"))) doex=SHW_LOAD_ACC;
		else
		{
			if ((!stricmp(dummy,".TOS")) || (!stricmp(dummy,".TTP"))) gem=0;
		}
		
		*dummy=0;
		
		if ((!gem) && ((avnotos) || (!find_avserver(1)))) goto _vastart;
	}

	if (strlen(name)>8) name[8]=0;
	else
		while (strlen(name)<8) strcat(name," ");

	for (i=0;i<8;i++) name[i]=toupper(name[i]);

	if (!force)
	{
		if ((find_avserver(1)) && ((doex==1) || (!avnoacc)))
		{
			int pipe[8];
			
			strcpy(avfile,file);
			if (cmd) cmd++;
			
			pipe[0]=AV_STARTPROG;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
			pipe[4]=(int)((long)avfile & 0x0000ffffL);
			pipe[5]=(int)(((long)cmd >> 16) & 0x0000ffffL);
			pipe[6]=(int)((long)cmd & 0x0000ffffL);
			pipe[7]=0;
			
			appl_write(avserver,16,pipe);
			return;
		}
		
		_vastart:
		if ((!gem) && (tosmultistart)) goto _shelstart;
		
		aid = appl_find(name);
		if (aid>=0)
		{
			int pipe[8];
			
			pipe[0]=SM_M_SPECIAL;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=0;
			pipe[4]='MA';
			pipe[5]='GX';
			pipe[6]=SMC_SWITCH;
			pipe[7]=aid;
			
			appl_write(appl_find("SCRENMGR"),16,pipe);
			
			if (cmd) cmd++;
	
			pipe[0]=VA_START;
			pipe[3]=(int)(((long)cmd >> 16) & 0x0000ffffL);
			pipe[4]=(int)((long)cmd & 0x0000ffffL);
			pipe[5]=0;
			pipe[6]=0;
			pipe[7]=0;
			
			appl_write(aid,16,pipe);
			return;
		}
	}

	_shelstart:
	dret=Dpathconf(file,-1);

	if (dret>=0L)
	{
		int xbit = 0;
		
		if (dret>=7L)
		{
			dret=Dpathconf(file,7);

			if (dret>0L)
			{
				if ((dret >> 8) & 73L) xbit=1;
				goto _xbit;
			}
		}
		
		if (!get_cookie('MagX',NULL)) xbit=1;

		_xbit:
		if (xbit)
		{
			XATTR xattr;
			
			if (!Fxattr(0,file,&xattr))
			{
				if (!(xattr.mode & 73L)) executable=0;
			}
		}
	}

	if (!executable)
	{
		form_alert(1,message[MSG_NOT_EXECUTABLE]);
		return;
	}

	tmp_drive = Dgetdrv();
	Dgetpath(tmp_cwd,tmp_drive+1);
	
	if (strlen(file)>1)
	{
		if (file[1]==':') Dsetdrv(toupper(file[0])-65);
	}

	Dsetpath(path);

	sid = shel_write(doex,gem,how,file,(cmd)?cmd:defcmd);

	if (!sid)
	{
		Dsetdrv(tmp_drive);
		Dsetpath(tmp_cwd);
	}
	else
	{
		if (doex==SHW_LOAD_ACC)
		{
			int pipe[8];
			
			pipe[0]=VA_START;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=0;
			pipe[4]=0;
			pipe[5]=0;
			pipe[6]=0;
			pipe[7]=0;
			
			appl_write(sid,16,pipe);
		}
	}
}


int handle_keyboard(int kstate, int key)
{
	if (kstate & KbSCAN)
	{
		if ((kstate & ~KbSCAN)==KbNORMAL)
		{
			if (key==KbHELP)
			{
				if (find_help())
				{
					call_help();
					return(1);
				}
			}
		}
	}
	else
	{
		if (kstate==KbCONTROL)
		{
			switch(key)
			{
				case 'i':
					about();
					return(1);
				
				case 'o':
					start_by_sel();
					return(1);
			}
		}
		else if (kstate==(KbALT | KbLSHIFT))
		{
			if (key==62) open_over_mouse(NULL,WHAT_NORMAL,NULL);
		}
	}

	return(0);
}


void start_by_sel(void)
{
	int pipe[8];
	
	pipe[0]=MN_SELECTED;
	pipe[1]=ap_id;
	pipe[2]=0;
	pipe[3]=-1;
	pipe[4]=RM_START;
	
	handle_message(pipe);
}


void folder_state(STARTMENU *curr, int drv, int docs, int apps, int enable)
{
	STARTENTRY *ce = curr->entries;
	STARTMENU  *cm = curr->children;
	int         c = drv+docs+apps;

	while (ce)
	{
		c++;
		
		if (ce->flags & SE_FOLDER)
		{
			if (enable) curr->tree[c].ob_state &= ~DISABLED;
			else
				curr->tree[c].ob_state |= DISABLED;
		}
		else
		{
			if ((!ce->file) && (ce->name))
			{
				folder_state(cm,0,0,0,enable);
				cm = cm->next;
			}
		}
		
		ce = ce->next;
	}
}


void start_popup(char *dcmd, int dx, int dy, int dflags, int what, char *mname)
{
	MENU    menu,msel;
	OBJECT *drvpop = NULL, *docpop = NULL, *whatmenu = NULL, *apppop = NULL;
	int     ret,mnx,mny,playclose;

	if (startbutton[btnidx].ob_state & DISABLED) return;
	
	if (whandle>0) wind_set(whandle,WF_TOP,0,0,0,0);
	startbutton[btnidx].ob_state |= SELECTED;
	redraw(desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	
	findstic();
	
	if (drives)
	{
		long    b,drvmap = Dsetdrv(Dgetdrv()),lmax=0;
		int     c,drvanz=1;
		char    drv[4],labl[34];
		
		for (c=0,b=1;c<32;c++)
		{
			if (drvmap & b)
			{
				drvanz++;
				
				if (labels[c])
				{
					if (strlen(labels[c])>lmax) lmax=strlen(labels[c]);
				}
				else if (!strchr(nolabel,c+65))
				{
					strcpy(drv,"?:");
					drv[0]=c+65;
				
					if (!Dreadlabel(drv,labl,32))
					{
						if (strlen(labl)>lmax) lmax=strlen(labl);
					}
				}
			}

			b <<= 1;
		}
		
		drvpop = (OBJECT *)malloc(sizeof(OBJECT)*(long)drvanz);
		
		if (drvpop)
		{
			int cnt = 1;
			
			if (lmax) lmax += 3L;
			lmax += 6L;
			
			drvpop[ROOT].ob_next   = -1;
			drvpop[ROOT].ob_head   =  1;
			drvpop[ROOT].ob_tail   = drvanz-1;
			drvpop[ROOT].ob_type   = G_BOX;
			drvpop[ROOT].ob_flags  = FL3DBAK;
			drvpop[ROOT].ob_state  = NORMAL;
			drvpop[ROOT].ob_spec.index = 0x00ff1100L;
			drvpop[ROOT].ob_x      =  0;
			drvpop[ROOT].ob_y      =  0;
			drvpop[ROOT].ob_width  = (int)lmax-1;
			drvpop[ROOT].ob_height = drvanz-1;

			for (c=0,b=1;c<32;c++)
			{
				if (drvmap & b)
				{
					drvpop[cnt].ob_next   = cnt+1;
					drvpop[cnt].ob_head   = -1;
					drvpop[cnt].ob_tail   = -1;
					drvpop[cnt].ob_type   = G_STRING;
					drvpop[cnt].ob_flags  = FL3DBAK|SELECTABLE;
					drvpop[cnt].ob_state  = NORMAL;
					drvpop[cnt].ob_spec.free_string = (char *)malloc(lmax);
					drvpop[cnt].ob_x      =  0;
					drvpop[cnt].ob_y      = cnt-1;
					drvpop[cnt].ob_width  = (int)lmax-1;
					drvpop[cnt].ob_height =  1;
					
					if (drvpop[cnt].ob_spec.free_string)
					{
						strcpy(drvpop[cnt].ob_spec.free_string,"    ");
						drvpop[cnt].ob_spec.free_string[2]=c+65;
						
						if (labels[c])
						{
							strcat(drvpop[cnt].ob_spec.free_string,"(");
							strcat(drvpop[cnt].ob_spec.free_string,labels[c]);
							strcat(drvpop[cnt].ob_spec.free_string,")");
						}
						else if (!strchr(nolabel,c+65))
						{
							strcpy(drv,"?:");
							drv[0]=c+65;

							if (!Dreadlabel(drv,labl,32))
							{
								strcat(drvpop[cnt].ob_spec.free_string,"(");
								strcat(drvpop[cnt].ob_spec.free_string,labl);
								strcat(drvpop[cnt].ob_spec.free_string,")");
							}
						}
						
						while (strlen(drvpop[cnt].ob_spec.free_string)<lmax-1) strcat(drvpop[cnt].ob_spec.free_string," ");
					}

					cnt++;
				}
				
				b <<= 1;
			}
			
			drvpop[drvanz-1].ob_next = 0;
			drvpop[drvanz-1].ob_flags |= LASTOB;

			fix_tree(drvpop);
			
			menu.mn_tree     = drvpop;
			menu.mn_menu     = ROOT;
			menu.mn_item     = 1;
			menu.mn_scroll   = 0;
			menu.mn_keystate = 0;

			if (stic) stic->menu_attach(ME_ATTACH,menus->tree,1,&menu);
			else
				menu_attach(ME_ATTACH,menus->tree,1,&menu);
		}

		if ((!find_avserver(1)) || (!drvpop)) menus->tree[1].ob_state |= DISABLED;
		else
			menus->tree[1].ob_state &= ~DISABLED;
	}

	if (documents)
	{
		int docidx = 1+drives, docanz = 0;
		long lmax = 0, lcmp;
		DHST *d = dhst;
		
		while (d)
		{
			lcmp = (d->info.appname) ? strlen(d->info.appname) : 0L;
			if (d->info.docname) lcmp += strlen(d->info.docname);
			if (lcmp > lmax) lmax = lcmp;
			
			docanz++;
			d = d->next;
		}
		
		if (docanz)
		{
			docanz++;
			
			docpop = (OBJECT *)malloc(sizeof(OBJECT)*(long)docanz);
		
			if (docpop)
			{
				int cnt = 1;
				
				lmax += 7;
			
				docpop[ROOT].ob_next   = -1;
				docpop[ROOT].ob_head   =  1;
				docpop[ROOT].ob_tail   = docanz-1;
				docpop[ROOT].ob_type   = G_BOX;
				docpop[ROOT].ob_flags  = FL3DBAK;
				docpop[ROOT].ob_state  = NORMAL;
				docpop[ROOT].ob_spec.index = 0x00ff1100L;
				docpop[ROOT].ob_x      =  0;
				docpop[ROOT].ob_y      =  0;
				docpop[ROOT].ob_width  = (int)lmax-1;
				docpop[ROOT].ob_height = docanz-1;
				
				d = dhst;
				
				while (d)
				{
					docpop[cnt].ob_next   = cnt+1;
					docpop[cnt].ob_head   = -1;
					docpop[cnt].ob_tail   = -1;
					docpop[cnt].ob_type   = G_STRING;
					docpop[cnt].ob_flags  = FL3DBAK|SELECTABLE;
					docpop[cnt].ob_state  = NORMAL;
					docpop[cnt].ob_spec.free_string = (char *)malloc(lmax);
					docpop[cnt].ob_x      =  0;
					docpop[cnt].ob_y      = cnt-1;
					docpop[cnt].ob_width  = (int)lmax-1;
					docpop[cnt].ob_height =  1;

					if (docpop[cnt].ob_spec.free_string)
					{
						strcpy(docpop[cnt].ob_spec.free_string,"  [");
						if (d->info.appname) strcat(docpop[cnt].ob_spec.free_string,d->info.appname);
						strcat(docpop[cnt].ob_spec.free_string,"] ");
						if (d->info.docname) strcat(docpop[cnt].ob_spec.free_string,d->info.docname);

						while (strlen(docpop[cnt].ob_spec.free_string)<lmax-1) strcat(docpop[cnt].ob_spec.free_string," ");
					}
					
					cnt++;
					d = d->next;
				}

				docpop[docanz-1].ob_next = 0;
				docpop[docanz-1].ob_flags |= LASTOB;
	
				fix_tree(docpop);
				
				menu.mn_tree     = docpop;
				menu.mn_menu     = ROOT;
				menu.mn_item     = 1;
				menu.mn_scroll   = 0;
				menu.mn_keystate = 0;
	
				if (stic) stic->menu_attach(ME_ATTACH,menus->tree,docidx,&menu);
				else
					menu_attach(ME_ATTACH,menus->tree,docidx,&menu);
			}
		}
		
		if (!docpop) menus->tree[docidx].ob_state |= DISABLED;
		else
			menus->tree[docidx].ob_state &= ~DISABLED;
	}
	
	if (applications)
	{
		int appidx = 1+drives+documents;

		/**/

		if (!apppop) menus->tree[appidx].ob_state |= DISABLED;
		else
			menus->tree[appidx].ob_state &= ~DISABLED;
	}

	menu.mn_tree     = menus->tree;
	menu.mn_menu     = ROOT;
	menu.mn_item     = 1;
	menu.mn_scroll   = 0;
	menu.mn_keystate = 0;
	
	switch (what)
	{
	case WHAT_HISTORY:
		menu.mn_tree = docpop;
		break;
	case WHAT_DRIVES:
		menu.mn_tree = drvpop;
		break;
	case WHAT_MENU:
		{
			STARTENTRY *entr = menus->entries;
			STARTMENU  *mnu  = menus->children;
			
			while (entr)
			{
				if ((!entr->file) && (entr->name))
				{
					if (!strcmp(entr->name,mname))
					{
						whatmenu = mnu->tree;
						break;
					}
					
					mnu = mnu->next;
				}
				
				entr = entr->next;
			}
			
			if (whatmenu)
			{
				menu.mn_tree = whatmenu;
			}
			else
			{
				mname = NULL;
				what  = WHAT_NORMAL;
			}
		}
	}

	if (dflags==DF_NONE)
	{
		mnx = startbutton[ROOT].ob_x+startbutton[btnidx].ob_x-2;
		mny = startbutton[ROOT].ob_y-menus->tree[ROOT].ob_height-2;
	}
	else
	{
		mnx=dx;
		mny=dy;
		
		if (dflags == DF_LEFT)
		{
			switch(what)
			{
			case WHAT_HISTORY:
				mnx -= (docpop[ROOT].ob_width >> 1);
				mny -= (docpop[ROOT].ob_height >> 1);
				break;
			case WHAT_DRIVES:
				mnx -= (drvpop[ROOT].ob_width >> 1);
				mny -= (drvpop[ROOT].ob_height >> 1);
				break;
			case WHAT_MENU:
				mnx -= (whatmenu[ROOT].ob_width >> 1);
				mny -= (whatmenu[ROOT].ob_height >> 1);
				break;
			case WHAT_NORMAL:
				mnx -= (menus->tree[ROOT].ob_width >> 1);
				mny -= (menus->tree[ROOT].ob_height >> 1);
			}
		}
	}

	switch (what)
	{
	case WHAT_HISTORY:
		if (mnx+docpop[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-docpop[ROOT].ob_width;
		break;
	case WHAT_DRIVES:
		if (mnx+drvpop[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-drvpop[ROOT].ob_width;
		break;
	case WHAT_MENU:
		if (mnx+whatmenu[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-whatmenu[ROOT].ob_width;
		break;
	default:
		if (mnx+menus->tree[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-menus->tree[ROOT].ob_width;
	}

	if (mnx < desk.g_x) mnx = desk.g_x;
	
	folder_state(menus,drives,documents,applications,find_avserver(1));

	play_sound(sampleopen);
	playclose = 1;

	if (stic) ret=stic->menu_popup(&menu,mnx,mny,&msel);
	else
		ret=menu_popup(&menu,mnx,mny,&msel);

	if (ret)
	{
		STARTMENU *start;
		
		if (msel.mn_tree==drvpop)
		{
			int pipe[8];
			
			strcpy(avfile,"*:\\");
			avfile[0]=drvpop[msel.mn_item].ob_spec.free_string[2];

			if (Kbshift(-1) & 0x00000003L)
			{
				Dcntl(CDROMEJECT,avfile,0);
				goto _drvend;
			}
			
			if (dcmd)
			{
				char *ccmd = dcmd+1L;

				pipe[0]=AV_COPYFILE;
				pipe[1]=ap_id;
				pipe[2]=0;
				pipe[3]=(int)(((long)ccmd >> 16) & 0x0000ffffL);
				pipe[4]=(int)((long)ccmd & 0x0000ffffL);
				pipe[5]=(int)(((long)avfile >> 16) & 0x0000ffffL);
				pipe[6]=(int)((long)avfile & 0x0000ffffL);

				if (Kbshift(-1) & 0x00000004L) pipe[7] = 1;
				else
					pipe[7]=0;

				if (Kbshift(-1) & 0x00000008L) pipe[7] |= 2;
			}
			else
			{
				pipe[0]=AV_OPENWIND;
				pipe[1]=ap_id;
				pipe[2]=0;
				pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
				pipe[4]=(int)((long)avfile & 0x0000ffffL);
				pipe[5]=(int)(((long)avextall >> 16) & 0x0000ffffL);
				pipe[6]=(int)((long)avextall & 0x0000ffffL);
				pipe[7]=0;
			}
			
			appl_write(avserver,16,pipe);

			goto _drvend;
		}
		
		if (msel.mn_tree==docpop)
		{
			DHST *d = dhst, *dold = NULL;
			int dcnt = msel.mn_item-1;
			
			while ((d) && (dcnt))
			{
				dcnt--;

				dold = d;
				d    = d->next;
			}
			
			if ((d) && (!dcnt))
			{
				if (Kbshift(-1) & 0x00000004L)
				{
					if (!dold) dhst = d->next;
					else
						dold->next = d->next;
					
					free_dhst(d);
				}
				else
				{
					start_app(0,SHW_PARALLEL,d->info.apppath,d->info.docpath);
				}
			}
			
			goto _drvend;
		}

		start = find_menu(menus,msel.mn_tree);

		if (start)
		{
			STARTENTRY *se = start->entries;
			
			if (start==menus) msel.mn_item -= (drives+documents+applications);

			while (se)
			{
				msel.mn_item--;

				if (!msel.mn_item)
				{
					if (se->file)
					{
						if (se->flags & SE_FOLDER)
						{
							int   pipe[8];
							char *avext;
							
							strcpy(avfile,se->file);
							
							if ((strchr(avfile,'?')) || (strchr(avfile,'*')))
							{
								char *bsl = strrchr(avfile,'\\');
								
								if (bsl)
								{
									bsl++;
									strcpy(avextusr,bsl);
									*bsl = 0;
								}
								else
								{
									strcpy(avfile,"\\");
									strcpy(avextusr,se->file);
								}

								avext = avextusr;
							}
							else
							{
								if (avfile[strlen(avfile)-1] != '\\') strcat(avfile,"\\");
								avext = avextall;
							}

							if (dcmd)
							{
								char *ccmd = dcmd+1L;
				
								pipe[0]=AV_COPYFILE;
								pipe[1]=ap_id;
								pipe[2]=0;
								pipe[3]=(int)(((long)ccmd >> 16) & 0x0000ffffL);
								pipe[4]=(int)((long)ccmd & 0x0000ffffL);
								pipe[5]=(int)(((long)avfile >> 16) & 0x0000ffffL);
								pipe[6]=(int)((long)avfile & 0x0000ffffL);
				
								if (Kbshift(-1) & 0x00000004L) pipe[7] = 1;
								else
									pipe[7]=0;

								if (Kbshift(-1) & 0x00000008L) pipe[7] |= 2;
							}
							else
							{
								pipe[0]=AV_OPENWIND;
								pipe[1]=ap_id;
								pipe[2]=0;
								pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
								pipe[4]=(int)((long)avfile & 0x0000ffffL);
								pipe[5]=(int)(((long)avext >> 16) & 0x0000ffffL);
								pipe[6]=(int)((long)avext & 0x0000ffffL);
								pipe[7]=0;
							}
							
							appl_write(avserver,16,pipe);
							break;
						}
						
						if (Kbshift(-1) & 0x00000008L)
						{
							if (find_avserver(1))
							{
								int   pipe[8];
								char *dummy;
								
								strcpy(avfile,se->file);
								dummy=strrchr(avfile,'\\');
								if (dummy) *(++dummy)=0;

								if (dcmd)
								{
									char *ccmd = dcmd+1L;
					
									pipe[0]=AV_COPYFILE;
									pipe[1]=ap_id;
									pipe[2]=0;
									pipe[3]=(int)(((long)ccmd >> 16) & 0x0000ffffL);
									pipe[4]=(int)((long)ccmd & 0x0000ffffL);
									pipe[5]=(int)(((long)avfile >> 16) & 0x0000ffffL);
									pipe[6]=(int)((long)avfile & 0x0000ffffL);
					
									if (Kbshift(-1) & 0x00000004L) pipe[7] = 1;
									else
										pipe[7]=0;
								}
								else
								{
									pipe[0]=AV_OPENWIND;
									pipe[1]=ap_id;
									pipe[2]=0;
									pipe[3]=(int)(((long)avfile >> 16) & 0x0000ffffL);
									pipe[4]=(int)((long)avfile & 0x0000ffffL);
									pipe[5]=(int)(((long)avextall >> 16) & 0x0000ffffL);
									pipe[6]=(int)((long)avextall & 0x0000ffffL);
									pipe[7]=0;
								}
								
								appl_write(avserver,16,pipe);
							}
						}
						else
						{
							play_sound(samplestart);
							playclose = 0;

							if (dcmd)
							{
								char *scmd = dcmd;
								
								if (se->fcmd)
								{
									char *pbuf,buf[1024],*dummy=se->fcmd + 1L;
									int   chng = 0;

									pbuf = buf;
									
									while ((*dummy) && ((dummy - se->fcmd) <= se->fcmd[0]))
									{
										if (*dummy=='$')
										{
											if (*(dummy+1L)=='$')
											{
												*pbuf='$';
												pbuf++;
												dummy+=2L;
												chng=1;
											}
											else if (*(dummy+1L)=='1')
											{
												if (dcmd[0]!=0)
												{
													strncpy(pbuf,dcmd+1L,dcmd[0]);
													pbuf += dcmd[0];
												}
												dummy+=2L;
												chng=1;
											}
											else
											{
												*pbuf=*dummy;
												pbuf++;
												dummy++;
											}
										}
										else
										{
											*pbuf=*dummy;
											pbuf++;
											dummy++;
										}
									}
									
									*pbuf=0;
									
									if (chng)
									{
										char *ncmd = (char *)Mxalloc(strlen(buf)+2L,ALLOCMODE);
										
										if (ncmd)
										{
											scmd=ncmd;
											strcpy(scmd+1L,buf);
											scmd[0] = min(strlen(buf),125);
										}
									}
								}
								
								start_app(0,SHW_PARALLEL,se->file,scmd);
								
								if (scmd!=dcmd) Mfree(scmd);
							}
							else
								start_app(0,SHW_PARALLEL,se->file,se->fcmd);
						}
					}
					break;
				}
				
				se = se->next;
			}
		}
	}

	if (playclose) play_sound(sampleclose);

	_drvend:
	if (drvpop)
	{
		if (stic) stic->menu_attach(ME_REMOVE,menus->tree,1,NULL);
		else
			menu_attach(ME_REMOVE,menus->tree,1,NULL);
		free(drvpop);
	}
	
	if (docpop)
	{
		if (stic) stic->menu_attach(ME_REMOVE,menus->tree,1+drives,NULL);
		else
			menu_attach(ME_REMOVE,menus->tree,1+drives,NULL);
		free(docpop);
	}

	startbutton[btnidx].ob_state &= ~SELECTED;
	redraw(desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	
	if ((untop) && (whandle>0)) wind_set(whandle,WF_BOTTOM,0,0,0,0);
}


void init_shutdown(void)
{
	if (strlen(shutdown))
	{
		long ret = Fopen(shutdown,FO_READ), len=0;
		
		if (ret>=0L)
		{
			int hdl = (int)ret;
			
			len = Fseek(0,hdl,2);
			
			Fclose(hdl);
		}
		
		if (len>20000L) start_app(0,SHW_PARALLEL,shutdown,NULL);
		else
		{
			cleanup(0);
			apterm=1;
			quit=1;
			start_app(1,SHW_CHAIN,shutdown,NULL);
		}
	}
	else
	{
		if (!(shel_write(SHW_SHUTDOWN,1,0,NULL,NULL)))
			form_alert(1,message[MSG_INIT_SHUTDOWN]);
	}
}


void info_popup(int mx, int my)
{
	MENU menu,msel;
	int  ret,mnx = mx;

	if (mnx+startpopup[ROOT].ob_width > desk.g_x+desk.g_w) mnx = desk.g_x+desk.g_w-startpopup[ROOT].ob_width;

	menu.mn_tree     = startpopup;
	menu.mn_menu     = ROOT;
	menu.mn_item     = 1;
	menu.mn_scroll   = 0;
	menu.mn_keystate = 0;

	findstic();
	if (stic) ret=stic->menu_popup(&menu,mnx,my,&msel);
	else
		ret=menu_popup(&menu,mnx,my,&msel);

	if (ret)
	{
		switch(msel.mn_item)
		{
			case 1:
				about();
				break;

			case 3:
				start_by_sel();
				break;

			case 5:
				if (noquitalert) quit=1;
				else
				{
					if (form_alert(1,message[MSG_QUIT])==1) quit=1;
				}
				break;
			
			case 6:
				init_shutdown();
				break;

			case 8:
				if (find_help()) call_help();
				break;
		}
	}
}


void move_button(void)
{
	int dummy,bstate;
	
	evnt_timer(10,0);
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mkstate(&dummy,&dummy,&bstate,&dummy);
	
	if (bstate & 1)
	{
		int cx,cy,cw,ch,fx,fy;
		
		graf_mouse(FLAT_HAND,NULL);

		wind_get(whandle,WF_WORKXYWH,&cx,&cy,&cw,&ch);
		
		if (graf_dragbox(cw,ch,cx,cy,desk.g_x,desk.g_y,desk.g_w,desk.g_h,&fx,&fy))
		{
			int pipe[8];
			
			pipe[0]=WM_MOVED;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=whandle;

			wind_calc(WC_BORDER,WINDOWSTYLE,fx,fy,cw,ch,&pipe[4],&pipe[5],&pipe[6],&pipe[7]);

			handle_message(pipe);
		}
		
		graf_mouse(ARROW,NULL);
	}
	else
	{
		if (is_top(whandle)) wind_set(whandle,WF_BOTTOM,0,0,0,0);
		else
		{
			if (!untop) wind_set(whandle,WF_TOP,0,0,0,0);
		}
	}
	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}


void show_bubblehelp(int mx, int my)
{
	if (!bubblehelp) bubblehelp = (char *)Mxalloc(256L,ALLOCMODE);
	
	if (bubblehelp)
	{
		int bubblegem = appl_find("BUBBLE  ");
		
		if (bubblegem>=0)
		{
			int   pipe[8];

			strcpy(bubblehelp,bubbleinfo);
/*			strcpy(strchr(bubblehelp,0) + 1L,bubbleinfo2); */

			pipe[0]=BUBBLEGEM_SHOW;
			pipe[1]=ap_id;
			pipe[2]=0;
			pipe[3]=mx;
			pipe[4]=my;
			pipe[5]=(int)(((long)bubblehelp >> 16) & 0x0000ffffL);
			pipe[6]=(int)((long)bubblehelp & 0x0000ffffL);
			pipe[7]=0 /*BGS7_2STRINGS*/;

			appl_write(bubblegem,16,&pipe);
		}
	}
}


void handle_button(int mx, int my, int bstate, int kstate, int clicks)
{
	int x,y,w,h;
	
	if (clicks != 1) return;

	if (whandle<1) return;

	wind_get(whandle,WF_WORKXYWH,&x,&y,&w,&h);
	if ((!between(mx,x,x+w-1)) || (!between(my,y,y+h-1))) return;

	if (bstate == 1)
	{
		if (kstate & KsSHIFT) move_button();
		else
			if (objc_find(startbutton,ROOT,MAX_DEPTH,mx,my) == btnidx)
			{
				start_popup(NULL,0,0,DF_NONE,WHAT_NORMAL,NULL);
				/* "echter" Button */
			}
			else
				move_button();
	}
	else
	{
		if (objc_find(startbutton,ROOT,MAX_DEPTH,mx,my) == btnidx) info_popup(mx,my);
		else
			show_bubblehelp(mx,my);
	}
}


void redraw(int x, int y, int w, int h)
{
	GRECT work,dirty,box;

	if (whandle<1) return;
	
	wind_update(BEG_UPDATE);
	wind_get(whandle,WF_WORKXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);
	startbutton[ROOT].ob_x=work.g_x;
	startbutton[ROOT].ob_y=work.g_y;

	if (rc_intersect(&desk,&work))
	{
		dirty.g_x = x;
		dirty.g_y = y;
		dirty.g_w = w;
		dirty.g_h = h;

		if (rc_intersect(&dirty,&work))
		{
			mouse_off();

			wind_get(whandle,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);

			while ((box.g_w>0)&&(box.g_h>0))
      {
      	if (rc_intersect(&work,&box)) objc_draw(startbutton,ROOT,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h);

      	wind_get(whandle,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
      }
      
      mouse_on();
		}
	}

	wind_update(END_UPDATE);
}


char *nextToken(char *pcmd)
{
	if (!pcmd) return(NULL);

	pcmd += (strlen(pcmd) + 1);

	_again:

	switch(*pcmd)
	{
		case 0:
			return(NULL);

		case 1:
		case 2:
			/* Hex-Kommandos auswerten */
		case 3:
		case 4:
		case 5:
		case 6:
			pcmd += (strlen(pcmd) + 1);
			goto _again;

		default:
			return(pcmd);
	}
}


int doGSCommand(int pipe[8])
{
	int   answ[8], ret=0;
	char *cmd = *(char **)&pipe[3];

	answ[0]=GS_ACK;
	answ[1]=ap_id;
	answ[2]=0;
	answ[3]=pipe[3];
	answ[4]=pipe[4];
	answ[5]=0;
	answ[6]=0;
	answ[7]=GSACK_ERROR;
	
	if (cmd)
	{
		answ[7]=GSACK_UNKNOWN;

		if (!stricmp(cmd,"Quit"))
		{
			ret=1;
			answ[7]=GSACK_OK;
		}
		else if (!stricmp(cmd,"Open"))
		{
			cmd = nextToken(cmd);
			
			while (cmd)
			{
				start_app(0,SHW_PARALLEL,cmd,NULL);
				evnt_timer(500,0);
				cmd = nextToken(cmd);
			}

			answ[7]=GSACK_OK;
		}
		else if (!stricmp(cmd,"CheckApp"))
		{
			cmd = nextToken(cmd);

			if (cmd)
			{
				start_app(0,SHW_PARALLEL,cmd,NULL);
				evnt_timer(500,0);
				answ[7]=GSACK_OK;
			}
			else
			{
				answ[7]=GSACK_ERROR;
			}
		}
		else if (!stricmp(cmd,"AppGetLongName"))
		{
			if (gslongname)
			{
				answ[5]=(int)(((long)gslongname >> 16) & 0x0000ffffL);
				answ[6]=(int)((long)gslongname & 0x0000ffffL);
				answ[7]=GSACK_OK;
			}
			else
			{
				answ[7]=GSACK_ERROR;
			}
		}
		else if (!stricmp(cmd,"OpenDrives"))
		{
			open_over_mouse(NULL,WHAT_DRIVES,NULL);
			answ[7]=GSACK_OK;
		}
		else if (!stricmp(cmd,"OpenHistory"))
		{
			open_over_mouse(NULL,WHAT_HISTORY,NULL);
			answ[7]=GSACK_OK;
		}
		else if (!stricmp(cmd,"OpenApplications"))
		{
			/**/
			answ[7]=GSACK_UNKNOWN /*OK*/;
		}
		else if (!stricmp(cmd,"OpenMenu"))
		{
			cmd = nextToken(cmd);

			if (cmd) open_over_mouse(NULL,WHAT_MENU,cmd);
			else
				open_over_mouse(NULL,WHAT_NORMAL,NULL);

			answ[7]=GSACK_OK;
		}
	}

	appl_write(pipe[1],16,answ);

	return(ret);
}


void open_over_mouse(char *p, int what, char *mname)
{
	int mx,my,md;
	
	graf_mkstate(&mx,&my,&md,&md);
	
	start_popup(p,mx,my,DF_LEFT,what,mname);
}


int handle_message(int pipe[8])
{
	switch (pipe[0])
	{
		case MN_SELECTED:
			if (pipe[4]==RM_START)
			{
				char path[256],file[128],*c;
				int  btn;
				
				strcpy(path,"*.*");
				strcpy(file,"");

				if (fsel_exinput(path,file,&btn,fseltitle))
				{
					if (btn==1)
					{
						if (strlen(file))
						{
							c=strrchr(path,'\\');
							if (c) *(++c) = 0;
							
							strcat(path,file);
							play_sound(samplestart);
							start_app(0,SHW_PARALLEL,path,NULL);
						}
					}
				}
			}
			if (pipe[3] >= 0) menu_tnormal(deskmenu,pipe[3],1);
			break;
			
		case WM_REDRAW:
			if (pipe[3]==whandle) redraw(pipe[4],pipe[5],pipe[6],pipe[7]);
			break;

		case WM_ONTOP:
		case WM_NEWTOP:
			if ((pipe[3]==whandle) && (untop) && (appline<0)) wind_set(whandle,WF_BOTTOM,0,0,0,0);
			break;

		case WM_TOPPED:
			if ((pipe[3]==whandle) && (!untop) && (appline<0)) wind_set(whandle,WF_TOP,0,0,0,0);
			break;

		case WM_CLOSED:
			if (wmclosed)
			{
				if (pipe[3]==whandle)
				{
					wind_close(whandle);
					wind_delete(whandle);
					whandle = 0;
				}
	
				if (_app) return(1);
			}
			break;
		
		case WM_MOVED:
			if (pipe[3]==whandle)
			{
				int x,y,w,h;
				
				wind_calc(WC_WORK,WINDOWSTYLE,pipe[4],pipe[5],pipe[6],pipe[7],&x,&y,&w,&h);
				
				if (between(x,desk.g_x,desk.g_x+desk.g_w-1) && between(y,desk.g_y,desk.g_y+desk.g_h-1) || (magxfadeout))
				{
					startinf.workxabs = x;
					startinf.workyabs = y;
					
					clip_startinf();

					wind_calc(WC_BORDER,WINDOWSTYLE,startbutton[ROOT].ob_x,startbutton[ROOT].ob_y,startbutton[ROOT].ob_width,startbutton[ROOT].ob_height,&x,&y,&w,&h);

					wind_set(whandle,WF_CURRXYWH,x,y,w,h);
				}
			}
			break;

		case WM_BOTTOMED:
		case WM_M_BDROPPED:
			if (pipe[3]==whandle) wind_set(whandle,WF_BOTTOM,0,0,0,0);
			break;
		
		case AP_DRAGDROP:
			{
				char pname[] = "U:\\PIPE\\DRAGDROP.xx";
				long res;
				
				pname[17] = (pipe[7]>>8) & 0x00ff;
				pname[18] = pipe[7] & 0x00ff;
				
				res=Fopen(pname,FO_RW);
				if (res>=0L)
				{
					long dtype,dsize;
					int  hlen,success = 0,handle = (int)res;
					char c = DD_OK,ptypes[32],*pcmd = NULL;

					memset(ptypes,0,32);
					strcpy(ptypes,"ARGS");

	        if (Fwrite(handle,1,&c) != 1) goto _perror;
	        if (Fwrite(handle,32,ptypes) != 32) goto _perror;
	        if (Fread(handle,2,&hlen) != 2) goto _perror;
	        if (Fread(handle,4,&dtype) != 4) goto _perror;
	        if (Fread(handle,4,&dsize) != 4) goto _perror;
	        
	        if (dsize<1) goto _perror;
	        
	        hlen -= 8;
	        while (hlen>0)
	        {
	        	if (Fread(handle,min(hlen,32),ptypes) != min(hlen,32)) goto _perror;
	        	hlen -= 32;
	        }

	        if (Fwrite(handle,1,&c) != 1) goto _perror;
	        if (dtype=='ARGS')
	        {
						pcmd = (char *)Mxalloc(dsize+1L,ALLOCMODE);
						if (!pcmd) goto _perror;

	        	if (Fread(handle,dsize,pcmd+1) != dsize) goto _perror;
						success = 1;
	        }

					_perror:
					Fclose(handle);

					if (success)
					{
						pcmd[0] = min(dsize-1,125);
						start_popup(pcmd,0,0,DF_NONE,WHAT_NORMAL,NULL);
					}

					if (pcmd) Mfree(pcmd);
				}
			}
			break;
		
		case AP_TERM:
			cleanup(0);
			apterm=1;
			return(1);

		case AC_OPEN:
			if (pipe[4]==menu_id) open_main_window();
			break;

		case AC_CLOSE:
			if (pipe[3]==menu_id) whandle=0;
			break;
		
		case VA_DRAGACCWIND:
			if (whandle==pipe[3])
			{
				char *p = *(char **)&pipe[6];
				
				if (p)
				{
					char *pcmd = (char *)Mxalloc(strlen(p)+2L,ALLOCMODE);
					int   answ[8];

					if (pcmd)
					{
						strcpy(pcmd+1L,p);
						pcmd[0] = min(strlen(p),125);

						start_popup(pcmd,0,0,DF_NONE,WHAT_NORMAL,NULL);

						Mfree(pcmd);
					}
					
					answ[0]=AV_STARTED;
					answ[1]=ap_id;
					answ[2]=0;
					answ[3]=pipe[6];
					answ[4]=pipe[7];
					answ[5]=0;
					answ[6]=0;
					answ[7]=0;
					
					appl_write(pipe[1],16,answ);
				}
			}
			break;

		case VA_START:
			{
				int answ[8];
				
				open_main_window();

				if (pipe[7]==DF_RIGHT) info_popup(pipe[5],pipe[6]);
				else
				{
					char *pcmd, *p = *(char **)&pipe[3];
					
					if (p)
					{
						if (!strcmp(p,"/smu-open"))
						{
							open_over_mouse(NULL,WHAT_NORMAL,NULL);
							break;
						}
					}
				
					pcmd = (p) ? ((strlen(p)) ? (char *)Mxalloc(strlen(p)+2L,ALLOCMODE) : NULL) : NULL;

					if (pcmd)
					{
						strcpy(pcmd+1L,p);
						pcmd[0] = min(strlen(p),125);
					}

					if (pipe[7]==DF_LEFT)
						start_popup(pcmd,pipe[5],pipe[6],DF_LEFT,WHAT_NORMAL,NULL);
					else
						open_over_mouse(pcmd,WHAT_NORMAL,NULL);
						
					if (pcmd) Mfree(pcmd);
				}

				answ[0]=AV_STARTED;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=pipe[3];
				answ[4]=pipe[4];
				answ[5]=0;
				answ[6]=0;
				answ[7]=0;
				
				appl_write(pipe[1],16,answ);
			}
			break;

		case AV_EXIT:
			if (pipe[3]==avserver) avserver=-1;
			break;
		
		case AV_PROTOKOLL:
			{
				int answ[8];

				find_avserver(1);

				answ[0]=VA_PROTOSTATUS;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=VAMSG;
				answ[4]=0;
				answ[5]=0;
				answ[6]=(int)(((long)accname >> 16) & 0x0000ffffL);
				answ[7]=(int)((long)accname & 0x0000ffffL);
				
				appl_write(pipe[1],16,answ);
			}
			break;
		
		case VA_PROGSTART:
		case VA_WINDOPEN:
			if (!pipe[3]) play_sound(sampleavfail);
			break;

		case AV_STARTPROG:
			{
				int   answ[8];
				char *pcmd, *p = *(char **)&pipe[5];

				pcmd = (p)?(char *)Mxalloc(strlen(p)+2L,ALLOCMODE):NULL;

				if (pcmd)
				{
					strcpy(pcmd+1L,p);
					pcmd[0] = min(strlen(p),125);
				}
				
				start_app(1,SHW_PARALLEL,*(char **)&pipe[3],pcmd);

				if (pcmd) Mfree(pcmd);
				
				answ[0]=VA_PROGSTART;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=1;
				answ[4]=0;
				answ[5]=0;
				answ[6]=0;
				answ[7]=pipe[7];
				
				appl_write(pipe[1],16,answ);
			}
			break;
		
		case DHST_ADD:
			{
				int answ[8];
				
				answ[0]=DHST_ACK;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=pipe[3];
				answ[4]=pipe[4];
				answ[5]=0;
				answ[6]=0;
				answ[7]=add_dhst(*(DHSTINFO **)&pipe[3]);
				
				appl_write(pipe[1],16,answ);
			}
			break;
		
		case BUBBLEGEM_REQUEST:
			if (objc_find(startbutton,ROOT,MAX_DEPTH,pipe[4],pipe[5]) != btnidx) show_bubblehelp(pipe[4],pipe[5]);
			break;
		
		case GS_REQUEST:
			{
				int answ[8];
				
				answ[0]=GS_REPLY;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=0;
				answ[4]=0;
				answ[5]=0;
				answ[6]=1;
				answ[7]=pipe[7];

				if (!gsi) gsi = (GS_INFO *)Mxalloc(sizeof(GS_INFO),ALLOCMODE);
				
				if (gsi)
				{
					GS_INFO *sender = *(GS_INFO **)&pipe[3];

					gsi->len     = sizeof(GS_INFO);
					gsi->version = 0x0100;
					gsi->msgs    = GSM_COMMAND;
					gsi->ext     = 0L;
					
					answ[3]=(int)(((long)gsi >> 16) & 0x0000ffffL);
					answ[4]=(int)((long)gsi & 0x0000ffffL);
					
					if (sender)
					{
						if (sender->version >= 0x0070)
						{
							answ[6]=0;
							gsapp=pipe[1];
						}
					}
				}
				
				appl_write(gsapp,16,answ);
			}
			break;

		case GS_COMMAND:
			if (doGSCommand(pipe)) return(1);
			break;

		case GS_QUIT:
			if (pipe[1]==gsapp) gsapp = -1;
			break;

		case AV_SENDKEY:
			{
				int mkey = MapKey(pipe[3],pipe[4]);

				handle_keyboard(mkey & 0xff00,mkey & 0x00ff);
			}
			break;

		case VA_PROTOSTATUS:
			if (!find_avserver(1))
			{
				if ((pipe[3] & 16) && (pipe[3] & 32) && (vaprotostatus))
				{
					avserver=pipe[1];
					strcpy(servername,*(char **)&pipe[6]);
				}
			}
			break;
		
		case ACC_ID:
			{
				int answ[8];
				
				answ[0]=ACC_ACC;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=0;
				answ[4]=(int)(((long)xaccname >> 16) & 0x0000ffffL);
				answ[5]=(int)((long)xaccname & 0x0000ffffL);
				answ[6]=menu_id;
				answ[7]=0;
				
				appl_write(pipe[1],16,answ);
			}
			break;
		
		case APPLINE_MSG:
			if ((applinepos) && (whandle>0))
			{
				int nx,ny,nw,nh,answ[8];
				OBJECT *obj = *(OBJECT **)&pipe[4];

				wind_get(whandle,WF_CURRXYWH,&nx,&ny,&nw,&nh);
				
				if (pipe[6] == 0)
				{
					if (pipe[7] & 4)
					{
						nx = obj->ob_x - 1;
						ny = obj->ob_y+obj->ob_height + 2;

						if (ny+nh>desk.g_y+desk.g_h)
						{
							ny = desk.g_y+desk.g_h-nh;
							nx = obj->ob_x+obj->ob_width + 2;
						}
					}
					else
					{
						ny = obj->ob_y - 1;
						
						if (pipe[7] & 2)
						{
							nx = obj->ob_x - nw - 2;

							if (nx<0)
							{
								nx = 0;

								if (pipe[7] & 1) ny = obj->ob_y+obj->ob_height + 2;
								else
									ny = obj->ob_y - nh - 2;
							}
						}
						else
						{
							nx = obj->ob_x+obj->ob_width + 2;

							if (nx+nw>desk.g_x+desk.g_w)
							{
								nx = desk.g_x+desk.g_w-nw;

								if (pipe[7] & 1) ny = obj->ob_y+obj->ob_height + 2;
								else
									ny = obj->ob_y - nh - 2;
							}
						}
					}
				}
				else
				{
					nx = obj->ob_x - nw - 2;
					ny = obj->ob_y - 1;

					if (nx<0) nx = obj->ob_x+obj->ob_width + 2;
				}
				
				answ[0]=WM_MOVED;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=whandle;
				answ[4]=nx;
				answ[5]=ny;
				answ[6]=nw;
				answ[7]=nh;
				/* Resource aužerhalb des Bildschirms? */

				handle_message(answ);
			}
			break;
		
		case SHUT_COMPLETED:
			if ((!(pipe[3])) && (pipe[4] == -1))
			{
				evnt_timer(shuttimeout,0);
				shel_write(SHW_SHUTDOWN,1,0,NULL,NULL);
			}

			if ((pipe[3]) || (pipe[4] == -1))
			{
				cleanup(0);
				apterm=1;
				return(1);
			}

			shel_write(SHW_SHUTDOWN,0,0,NULL,NULL);
			form_alert(1,message[MSG_FINISH_SHUTDOWN]);
			break;
	}

	return(0);
}


int print_two(int handle, int value)
{
	char num[10];
	
	itoa(value,num,10);
	if (value<10)
	{
		if (Fwrite(handle,1L,"0") != 1L) return(1);
	}
	
	return(Fwrite(handle,strlen(num),num) != strlen(num));
}


void start_timer(TIMER *dtimer)
{
	if (strlen(logfile))
	{
		long ret;
		int  handle;

		ret=Fopen(logfile,FO_WRITE);
	
		if (ret<0L) ret=Fcreate(logfile,0);
		
		if (ret>=0L)
		{
			char         num[16];
			unsigned int t = Tgettime(),
			             d = Tgetdate();
			
			handle=(int)ret;
			if (Fseek(0,handle,2) < 0L) goto _error;
			
			if (print_two(handle,d & 0x001f)) goto _error;
			if (Fwrite(handle,1L,".") != 1L) goto _error;
			if (print_two(handle,(d >> 5) & 0x000f)) goto _error;
			if (Fwrite(handle,1L,".") != 1L) goto _error;
			itoa(((d >> 9) & 0x007f) + 1980,num,10);
			if (Fwrite(handle,strlen(num),num) != strlen(num)) goto _error;
			if (Fwrite(handle,1L," ") != 1L) goto _error;

			if (print_two(handle,(t >> 11) & 0x001f)) goto _error;
			if (Fwrite(handle,1L,":") != 1L) goto _error;
			if (print_two(handle,(t >> 5) & 0x003f)) goto _error;
			if (Fwrite(handle,1L,":") != 1L) goto _error;
			if (print_two(handle,(t & 0x001f) << 1)) goto _error;
			if (Fwrite(handle,2L,"\x0d\x0a") != 2L) goto _error;

			if (print_two(handle,(int)((dtimer->time >> 11) & 0x0000001f))) goto _error;
			if (Fwrite(handle,1L,":") != 1L) goto _error;
			if (print_two(handle,(int)((dtimer->time >> 5) & 0x0000003f))) goto _error;
			if (Fwrite(handle,2L,"  ") != 2L) goto _error;

			if (Fwrite(handle,strlen(dtimer->file),dtimer->file) != strlen(dtimer->file)) goto _error;

			if (dtimer->fcmd)
			{
				if (Fwrite(handle,2L," (") != 2L) goto _error;
				if (Fwrite(handle,strlen(dtimer->fcmd + 1L),dtimer->fcmd + 1L) != strlen(dtimer->fcmd + 1L)) goto _error;
				if (Fwrite(handle,1L,")") != 1L) goto _error;
			}
			
			Fwrite(handle,4L,"\x0d\x0a\x0d\x0a");
			_error:
			Fclose(handle);
		}
	}

	play_sound(sampletimer);

	if (!stricmp(dtimer->file,"shutdown")) init_shutdown();
	else
		start_app(0,SHW_PARALLEL,dtimer->file,dtimer->fcmd);
	
	evnt_timer(500,0);
}


void event_loop(void)
{
	int    mx,my,
	       kstate,
	       key,
	       mkey,
	       clicks,
	       event,
	       bstate,
	       alid,
	       pipe[8],
	       answ[8];
	long   tcurr,
	       told = Tgettime() & 0x0000ffe0;
	TIMER *dtimer;

	do
	{
		event = evnt_multi(MU_MESAG|MU_KEYBD|MU_BUTTON|MU_TIMER,
		                   258,3,0,0,0,0,0,0,0,0,0,0,0,pipe,2500,0,
		                   &mx,&my,&bstate,&kstate,&key,&clicks);

		alid = appl_find("APPLINE ");
		
		if (alid != appline)
		{
			appline = alid;
			
			if (appline>=0)
			{
				answ[0]=APPLINE_MSG;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=-1;
				answ[4]=0;
				answ[5]=0;
				answ[6]=0;
				answ[7]=0;
				
				appl_write(appline,16,answ);
			}
		}

		if (event & MU_MESAG) quit |= handle_message(pipe);

		if (event & MU_KEYBD)
		{
			mkey = MapKey(kstate,key);

			if (!handle_keyboard(mkey & 0xff00,mkey & 0x00ff))
			{
				answ[0]=AV_SENDKEY;
				answ[1]=ap_id;
				answ[2]=0;
				answ[3]=kstate;
				answ[4]=key;
				answ[5]=0;
				answ[6]=0;
				answ[7]=0;

				appl_write((find_avserver(1))?avserver:menu_bar(NULL,-1),16,answ);
			}
		}

		if (event & MU_BUTTON) handle_button(mx,my,bstate & 3,kstate,clicks);

		if (timer)
		{
			tcurr = Tgettime() & 0x0000ffe0;

			if (tcurr != told)
			{
				if ((told>47104L) && (tcurr<2048L))
				{
					dtimer = timer;
					
					while (dtimer)
					{
						if ((dtimer->time > told) || (dtimer->time <= tcurr)) start_timer(dtimer);
						dtimer=dtimer->next;
					}
					
					told = tcurr;
				}
				else if (tcurr>told)
				{
					dtimer = timer;
					
					while (dtimer)
					{
						if ((dtimer->time > told) && (dtimer->time <= tcurr)) start_timer(dtimer);
						dtimer=dtimer->next;
					}
					
					told = tcurr;
				}
			}
		}
	}
	while (!quit);

	if (appline >= 0)
	{
		answ[0]=APPLINE_MSG;
		answ[1]=ap_id;
		answ[2]=0;
		answ[3]=0;
		answ[4]=0;
		answ[5]=0;
		answ[6]=0;
		answ[7]=0;
		
		appl_write(appline,16,answ);
	}

	if (gsapp >= 0)
	{
		answ[0]=GS_QUIT;
		answ[1]=ap_id;
		answ[2]=0;
		answ[3]=0;
		answ[4]=0;
		answ[5]=0;
		answ[6]=0;
		answ[7]=0;
		
		appl_write(gsapp,16,answ);
	}
}