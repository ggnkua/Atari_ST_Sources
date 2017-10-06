/******************************************************************************/
/*																										*/
/*          Eine handoptimierte Bibliothek fÅr Pure-C und GNU-C               */
/*																										*/
/* Die AES-Funktionen - Headerdatei															*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#ifndef __ACSAES__
#define __ACSAES__

#ifndef __ACSTYPE__
	#include <ACSTYPE.H>
#endif

#include <ACSVDI.H>
#include <TOS.H>

/******************************************************************************/
/*																										*/
/* Die diversen AES-Konstanten																*/
/*																										*/
/******************************************************************************/

/* Objekt-Nummer */
#define G_BOX           20
#define G_TEXT          21
#define G_BOXTEXT       22
#define G_IMAGE         23
#define G_USERDEF       24
#define G_IBOX          25
#define G_BUTTON        26
#define G_BOXCHAR       27
#define G_STRING        28
#define G_FTEXT         29
#define G_FBOXTEXT      30
#define G_ICON          31
#define G_TITLE         32
#define G_CICON         33

/******************************************************************************/

/* Object flags */
#define NONE            0x0000
#define SELECTABLE      0x0001
#define DEFAULT         0x0002
#define EXIT            0x0004
#define EDITABLE        0x0008
#define RBUTTON         0x0010
#define LASTOB          0x0020
#define TOUCHEXIT       0x0040
#define HIDETREE        0x0080
#define INDIRECT        0x0100
#define FL3DIND			0x0200
#define FL3DBAK			0x0400
#define FL3DACT			0x0600
#define SUBMENU			0x0800

/******************************************************************************/

/* Objektstatus (OBJECT.ob_state) */
#define NORMAL          0x00
#define SELECTED        0x01
#define CROSSED         0x02
#define CHECKED         0x04
#define DISABLED        0x08
#define OUTLINED        0x10
#define SHADOWED        0x20

/******************************************************************************/

/* Object colors */
#if !defined(__COLORS)
#define __COLORS			/* Using AES-colors and BGI-colors is not possible */
#define WHITE            0
#define BLACK            1
#define RED              2
#define GREEN            3
#define BLUE             4
#define CYAN             5
#define YELLOW           6
#define MAGENTA          7
#define LWHITE           8
#define LBLACK           9
#define LRED            10
#define LGREEN          11
#define LBLUE           12
#define LCYAN           13
#define LYELLOW         14
#define LMAGENTA        15

#endif

/******************************************************************************/

/* Mouse forms */
#define ARROW				0
#define TEXT_CRSR			1
#define BUSYBEE			2
#define POINT_HAND		3
#define FLAT_HAND			4
#define THIN_CROSS		5
#define THICK_CROSS		6
#define OUTLN_CROSS		7
#define USER_DEF			255
#define M_OFF				256
#define M_ON				257
#define M_SAVE				258
#define M_LAST				259
#define M_RESTORE			260

#define HOURGLASS			BUSYBEE
#define BUSY_BEE			BUSYBEE

/******************************************************************************/

/* Funktions-Codes fÅr menu_attach */
#define ME_INQUIRE		0
#define ME_ATTACH			1
#define ME_REMOVE			2

/******************************************************************************/

/* Scroll-Infos (fÅr Struktur MENU, menu_attach) */
#define SCROLL_NO		0
#define SCROLL_YES	1

/******************************************************************************/

/* Funktions-Codes fÅr menu_bar */
#define MENU_REMOVE		0
#define MENU_INSTALL		1
#define MENU_INQUIRE		2
#define MENU_GETMODE		3			/* MenÅleistenmodus abfragen */
#define MENU_SETMODE		4			/*  [MenÅleistenmodus setzen] */
#define MENU_UPDATE		5			/* Update des Systemteils d. MenÅleiste */

/******************************************************************************/

/* Bit-Struktur fÅr MENU_SETMODE */
#define  MENU_HIDDEN		0x0001	/* MenÅleiste nur bei Bedarf sichtbar */
#define  MENU_PULLDOWN	0x0002	/* Pulldown-MenÅs */
#define  MENU_SHADOWED	0x0004	/* MenÅleistenboxen mit Schatten */

/******************************************************************************/

/* Spezielle Ap-ID fÅr's Registrieren des Prozeûnamens */
#define REG_NEWNAME		-1

/******************************************************************************/

/* Tastatur-Status (fÅr appl_trecord, evnt_button, evnt_mouse, evnt_multi) */
#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_CTRL		0x0004
#define K_ALT		0x0008

/******************************************************************************/

/* Ereignis-Flags (fÅr evnt_multi, evnt_event) */
#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020

/******************************************************************************/

/* Funktionsauswahl fÅr objc_edit */
#define ED_START	0
#define ED_INIT	1
#define ED_CHAR	2
#define ED_END		3

/******************************************************************************/

/* Spezial-Position fÅr objc_order */
#define OO_LAST	-1
#define OO_FIRST	0

/******************************************************************************/

/* Flag fÅr das Objektbaum-Zeichnen (fÅr objc_draw) */
#define NO_DRAW		0
#define REDRAW			1

/******************************************************************************/

/* Funktions-Codes fÅr objc_sysvar */
#define LK3DIND		1
#define LK3DACT		2
#define INDBUTCOL		3
#define BACKGRCOL		4
#define AD3DVAL		5

/******************************************************************************/

/* Modus fÅr objc_sysvar */
#define SV_INQUIRE		0
#define SV_SET				1

/******************************************************************************/

/* Typen fÅr form_dial */
#define FMD_START		0
#define FMD_GROW		1
#define FMD_SHRINK	2
#define FMD_FINISH	3

/******************************************************************************/

/* Fehlernummern (fÅr form_error) */
#define FERR_FILENOTFOUND		2
#define FERR_PATHNOTFOUND		3
#define FERR_NOHANDLES			4
#define FERR_ACCESSDENIED		5
#define FERR_LOWMEM				8
#define FERR_BADENVIRON			10
#define FERR_BADFORMAT			11
#define FERR_BADDRIVE			15
#define FERR_DELETEDIR			16
#define FERR_NOFILES				18

/******************************************************************************/

/* Funktions-Codes fÅr shel_write */
#define SWM_LAUNCH		0
#define SWM_LAUNCHNOW	1
#define SWM_LAUNCHACC	3
#define SWM_SHUTDOWN		4
#define SWM_REZCHANGE	5
#define SHW_RESCHANGE	5
#define SWM_BROADCAST	7
#define SWM_ENVIRON		8
#define SWM_NEWMSG		9
#define SWM_AESMSG		10

/******************************************************************************/

/* Erweiterte Start-Flags fÅr die Modi SWM_LAUNCH, SWM_LAUNCHNOW */
/* und SWM_LAUNCHACC (fÅr shel_write)                            */
#define SW_PSETLIMIT		0x0100
#define SW_PRENICE		0x0200
#define SW_PDEFDIR		0x0400
#define SW_ENVIRON		0x0800

/******************************************************************************/

/* Werte fÅr Modus SWM_SHUTDOWN (fÅr shel_write) */
#define SD_ABORT		0
#define SD_PARTIAL	1
#define SD_COMPLETE	2

/******************************************************************************/

/* Werte fÅr Modus SWM_ENVIRON (fÅr shel_write) */
#define ENVIRON_SIZE		0
#define ENVIRON_CHANGE	1
#define ENVIRON_COPY		2

/******************************************************************************/

/* Werte fÅr Modus SWM_NEWMSG (fÅr shel_write) */
#define NM_APTERM		0x0001

/******************************************************************************/

/* Werte fÅr Modus SWM_AESMSG (fÅr shel_write) */
#define AP_AESTERM	52     /* Mode 10: N.AES komplett terminieren. */

/******************************************************************************/

/* Modus fÅr shel_help */
#define SHP_HELP	0

/******************************************************************************/

/* Fensterkomponenten (fÅr wind_create) */
#define NAME			0x0001
#define CLOSER			0x0002
#define FULLER			0x0004
#define MOVER			0x0008
#define INFO			0x0010
#define SIZER			0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE			0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE			0x0800
#define HOTCLOSEBOX	0x1000
#define BACKDROP		0x2000
#define ICONIFIER		0x4000

#define SMALLER		ICONIFIER

/******************************************************************************/

/* Die Infos fÅr wind_get und wind_set */
#define WF_KIND				  1
#define WF_NAME				  2
#define WF_INFO				  3
#define WF_WORKXYWH			  4
#define WF_CURRXYWH			  5
#define WF_PREVXYWH			  6
#define WF_FULLXYWH			  7
#define WF_HSLIDE				  8
#define WF_VSLIDE				  9
#define WF_TOP					 10
#define WF_FIRSTXYWH			 11
#define WF_NEXTXYWH			 12
#define WF_RESVD				 13
#define WF_NEWDESK			 14
#define WF_HSLSIZE			 15
#define WF_VSLSIZE			 16
#define WF_SCREEN				 17
#define WF_COLOR				 18
#define WF_DCOLOR				 19
#define WF_OWNER				 20
#define WF_BEVENT				 24
#define WF_BOTTOM				 25
#define WF_ICONIFY			 26
#define WF_UNICONIFY			 27
#define WF_UNICONIFYXYWH	 28
#define WF_TOOLBAR			 30
#define WF_FTOOLBAR			 31
#define WF_NTOOLBAR			 32
#define WF_WIDGETS			200		/* Positionen der V- und H-Sliderelemente. */

#define WF_WXYWH			WF_WORKXYWH
#define WF_CXYWH			WF_CURRXYWH
#define WF_PXYWH			WF_PREVXYWH
#define WF_FXYWH			WF_FULLXYWH

/******************************************************************************/

/* Die Fenster-Komponenten (fÅr wind_set, Modus WF_COLOR und WF_DCOLOR) */
#define W_BOX            0
#define W_TITLE          1
#define W_CLOSER         2
#define W_NAME           3
#define W_FULLER         4
#define W_INFO           5
#define W_DATA           6
#define W_WORK           7
#define W_SIZER          8
#define W_VBAR           9
#define W_UPARROW       10
#define W_DNARROW       11
#define W_VSLIDE        12
#define W_VELEV         13
#define W_HBAR          14
#define W_LFARROW       15
#define W_RTARROW       16
#define W_HSLIDE        17
#define W_HELEV         18
#define W_SMALLER       19
#define W_HIDER			30

/******************************************************************************/

/* Die Konstanten fÅr die Scroll-Nachrichten */
#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7

/******************************************************************************/

/* Flags fÅr wind_calc */
#define WC_BORDER	0
#define WC_WORK	1

/******************************************************************************/

/* Modi fÅr wind_update bzw. Awi_update */
#define BEG_UPDATE		0x0001
#define END_UPDATE		0x0000
#define BEG_MCTRL			0x0003
#define END_MCTRL			0x0002
#define RESET_UPDATE 	0x0010
#define RESTART_UPDATE  0x0020

/******************************************************************************/

/* Die Struktur-Typen (fÅr rsrc_gaddr) */
#define R_TREE				0
#define R_OBJECT			1
#define R_TEDINFO			2
#define R_ICONBLK			3
#define R_BITBLK			4
#define R_STRING			5
#define R_IMAGEDATA		6
#define R_OBSPEC			7
#define R_TEPTEXT			8
#define R_TEPTMPLT		9
#define R_TEPVALID		10
#define R_IBPMASK			11
#define R_IBPDATA			12
#define R_IPBTEXT			13
#define R_BIPDATA			14
#define R_FRSTR			15
#define R_FRIMG			16

/******************************************************************************/

#define ROOT             0
#define MAX_LEN         81              /* max string length */
#define MAX_DEPTH        8              /* max depth of search or draw */

/******************************************************************************/

#define IBM             3               /* font types */
#define SMALL           5

/******************************************************************************/

/* Ausrichtung eines editierbaren Textfeldes */
#define TE_LEFT	0
#define TE_RIGHT	1
#define TE_CNTR	2

/******************************************************************************/

/* Die Funktions-Codes fÅr appl_getinfo */
#define AES_LARGEFONT	0
#define AES_SMALLFONT	1
#define AES_SYSTEM		2
#define AES_LANGUAGE		3
#define AES_PROCESS		4
#define AES_PCGEM			5
#define AES_INQUIRE		6
#define AES_MOUSE			8
#define AES_MENU			9
#define AES_SHELL			10
#define AES_WINDOW		11
#define AES_MESSAGE		12
#define AES_OBJECT		13
#define AES_FORM			14

/******************************************************************************/

/* Die Sprachen fÅr AES_LANGUAGE, appl_getinfo */
#define AESLANG_GERMAN		1
#define AESLANG_FRENCH		2
#define AESLANG_SPANISH		4
#define AESLANG_ITALIAN		5
#define AESLANG_SWEDISH		6

/******************************************************************************/

/* Funktionscodes fÅr appl_search */
#define APP_FIRST		0
#define APP_NEXT		1

/******************************************************************************/

/* Prozeû-Typen (fÅr appl_search) */
#define APP_SYSTEM			0x01
#define APP_APPLICATION		0x02
#define APP_ACCESSORY		0x04
#define APP_SHELL				0x08

/******************************************************************************/

/* Event-Typen (fÅr appl_tplay und appl_trecord) */
#define APPEVNT_TIMER		0
#define APPEVNT_BUTTON		1
#define APPEVNT_MOUSE		2
#define APPEVNT_KEYBOARD	3

/******************************************************************************/

/* Konstanten fÅr ap_cwhat der Funktion appl_Control */
#define APC_HIDE		10
#define APC_SHOW		11
#define APC_TOP		12
#define APC_HIDENOT	13
#define APC_INFO		14
#define APC_MENU		15
#define APC_WIDGETS	16

/******************************************************************************/

/* Flags fÅr den Integer, auf den ap_cout bei APC_INFO zeigt (appl_control) */
#define APCI_HIDDEN	0x01
#define APCI_HASMBAR	0x02
#define APCI_HASDESK	0x04

/******************************************************************************/

/* Grîûe des Puffers in INT16 fÅr APC_WIDGETS (appl_control) */
#define MINWINOBJ		12

/******************************************************************************/

/* Flags fÅr die Maus-öberwachung (evnt_mouse, evnt_multi, evnt_event) */
#define MO_ENTER	0
#define MO_LEAVE	1

/******************************************************************************/

/* Die Messages des Screenmanagers */
#define MN_SELECTED			10
#define WM_REDRAW				20
#define WM_TOPPED				21
#define WM_CLOSED				22
#define WM_FULLED				23
#define WM_ARROWED			24
#define WM_HSLID				25
#define WM_VSLID				26
#define WM_SIZED				27
#define WM_MOVED				28
#define WM_NEWTOP				29
#define WM_UNTOPPED			30
#define WM_ONTOP				31
#define WM_OFFTOP				32
#define WM_BOTTOMED			33
#define WM_ICONIFY			34
#define WM_UNICONIFY			35
#define WM_ALLICONIFY		36
#define WM_TOOLBAR			37
#define AC_OPEN				40
#define AC_CLOSE				41
#define CT_UPDATE				50
#define CT_MOVE				51
#define CT_NEWTOP				52
#define CT_KEY					53
#define AP_TERM				50
#define AP_TFAIL				51
#define AP_RESCHG				57
#define SHUT_COMPLETED  	60
#define RESCHG_COMPLETED	61
#define AP_DRAGDROP			63
#define SH_WDRAW				72
#define CH_EXIT				80
#define SC_CHANGED			80
#define PRN_CHANGED			82
#define FNT_CHANGED			83
#define THR_EXIT				88
#define SM_M_SPECIAL			101
#define WM_SHADED				0x5758
#define WM_UNSHADED			0x5759

/* Sent by Wheel */
#define WM_MOUSEWHEEL 		0x0930

/* Only for MagiC 2 used (> MagiC 2: WM_BOTTOM) */
#define WM_M_BDROPPED		100

/******************************************************************************/

/* XACC-Messages */
#ifndef __xaccproto__
	#define __xaccproto__
	#define ACC_ID					0x400
	#define ACC_OPEN				0x401
	#define ACC_CLOSE				0x402
	#define ACC_ACC				0x403
	#define ACC_EXIT				0x404
	#define ACC_ACK				0x500
	#define ACC_TEXT				0x501
	#define ACC_KEY				0x502
	#define ACC_META				0x503
	#define ACC_IMG				0x504
#endif

/******************************************************************************/

/* AV-Messages */
#ifndef __vaproto__
	#define __vaproto__
	#define AV_PROTOKOLL			0x4700
	#define VA_PROTOSTATUS		0x4701
	#define AV_GETSTATUS			0x4703
	#define AV_STATUS				0x4704
	#define VA_SETSTATUS			0x4705
	#define AV_SENDCLICK       0x4709
	#define AV_SENDKEY			0x4710
	#define VA_START				0x4711
	#define AV_ASKFILEFONT		0x4712
	#define VA_FILEFONT			0x4713
	#define AV_ASKCONFONT		0x4714
	#define VA_CONFONT			0x4715
	#define AV_ASKOBJECT			0x4716
	#define VA_OBJECT				0x4717
	#define AV_OPENCONSOLE		0x4718
	#define VA_CONSOLEOPEN		0x4719
	#define AV_OPENWIND			0x4720
	#define VA_WINDOPEN			0x4721
	#define AV_STARTPROG			0x4722
	#define VA_PROGSTART			0x4723
	#define AV_ACCWINDOPEN		0x4724
	#define VA_DRAGACCWIND		0x4725
	#define AV_ACCWINDCLOSED	0x4726
	#define AV_COPY_DRAGGED		0x4728
	#define VA_COPY_COMPLETE	0x4729
	#define AV_PATH_UPDATE		0x4730
	#define AV_WHAT_IZIT			0x4732
	#define VA_THAT_IZIT			0x4733
	#define AV_DRAG_ON_WINDOW	0x4734
	#define VA_DRAG_COMPLETE	0x4735
	#define AV_EXIT				0x4736
	#define AV_STARTED			0x4738
	#define VA_OB_UNKNOWN		0		
	#define VA_OB_TRASHCAN  	1
	#define VA_OB_SHREDDER  	2
	#define VA_OB_CLIPBOARD 	3
	#define VA_OB_FILE      	4
	#define VA_OB_FOLDER			5
	#define VA_OB_DRIVE			6
	#define VA_OB_WINDOW    	7
#endif

/******************************************************************************/

/* GEMScript-Messages */
#ifndef __gemscript__
	#define __gemscript__
	
	typedef struct
	{
		long len;		/* LÑnge der Struktur in Bytes */
		INT16 version;	/* Versionsnummer des Protokolles beim Sender (z.Z. 0x0120 = 1.2) */
		INT16 msgs;		/* Bitmap der unterstÅtzten Nachrichten und FÑhigkeiten (GSM_xxx) */
		long ext;		/* benutzte Endung, etwa '.SIC'                     */
	} GS_INFO;
	
	/* Kennung fÅr den Empfang von GS_COMMAND */
	#define GSM_COMMAND		0x0001
	
	/* Kennung fÅr Empfang von GS_OPENMACRO, GS_WRITE */
	/* und GS_CLOSEMACRO und Senden von GS_MACRO      */
	#define GSM_MACRO			0x0002
	
	/* Kennung fÅr Versand von GS_OPENMACRO, GS_WRITE */
	/* und GS_CLOSEMACRO und Empfang von GS_MACRO     */
	#define GSM_WRITE			0x0004
	
	/* Hex-Codierung wird verstanden */
	#define GSM_HEXCODING	0x0008
	
	/* RÅckgabewerte der GEMScript-Funktionen (Anwendung & Fenster) */
	#define GSACK_OK			0
	#define GSACK_UNKNOWN	1
	#define GSACK_ERROR		2
	
#endif

/******************************************************************************/

/* OLGA-Messages */
#if !defined(OLGA_H) && !defined(__olga_c__)
	#define __olga_c__
	#define OLGA_H
	
	#define OLE_INIT                 0x4950
	#define OLE_EXIT                 0x4951
	#define OLE_NEW                  0x4952
	
	#define OLGA_INIT                0x1236
	#define OLGA_UPDATE              0x1238
	#define OLGA_ACK                 0x1239
	#define OLGA_RENAME              0x123a
	#define OLGA_OPENDOC             0x123b
	#define OLGA_CLOSEDOC            0x123c
	#define OLGA_LINK                0x123d
	#define OLGA_UNLINK              0x123e
	#define OLGA_UPDATED             0x123f
	#define OLGA_RENAMELINK          0x1240
	#define OLGA_LINKRENAMED         0x1241
	#define OLGA_GETOBJECTS          0x1242
	#define OLGA_OBJECTS             0x1243
	#define OLGA_BREAKLINK           0x1244
	#define OLGA_LINKBROKEN          0x1245
	#define OLGA_START               0x1246
	#define OLGA_GETINFO             0x1247
	#define OLGA_INFO                0x1248
	#define OLGA_IDLE                0x1249
	#define OLGA_ACTIVATE            0x124a
	#define OLGA_EMBED               0x124b
	#define OLGA_EMBEDDED            0x124c
	#define OLGA_UNEMBED             0x124d
	#define OLGA_GETSETTINGS         0x124e
	#define OLGA_SETTINGS            0x124f
	#define OLGA_REQUESTNOTIFICATION 0x1250
	#define OLGA_RELEASENOTIFICATION 0x1251
	#define OLGA_NOTIFY              0x1252
	#define OLGA_NOTIFIED            0x1253
	#define OLGA_SERVERTERMINATED    0x1254
	#define OLGA_CLIENTTERMINATED    0x1255
	#define OLGA_INPLACEUPDATE       0x1256
	
	#define OL_SERVER                0x0001
	#define OL_CLIENT                0x0002
	#define OL_PEER                  (OL_SERVER | OL_CLIENT)
	#define OL_IDLE                  0x0800
	#define OL_PIPES                 0x1000
	#define OL_START                 0x2000
	#define OL_MANAGER               0x4000
	#define OL_OEP                   0x0001
	
	#define OLS_TYPE                      1
	#define OLS_EXTENSION                 2
	#define OLS_NAME                      3
	
#endif

/******************************************************************************/

/* Daten-Strukturen im RSC-File */
#define R_TREE           0
#define R_OBJECT         1
#define R_TEDINFO        2
#define R_ICONBLK        3
#define R_BITBLK         4
#define R_STRING         5              /* gets pointer to free strings */
#define R_IMAGEDATA      6              /* gets pointer to free images */
#define R_OBSPEC         7
#define R_TEPTEXT        8              /* sub ptrs in TEDINFO */
#define R_TEPTMPLT       9
#define R_TEPVALID      10
#define R_IBPMASK       11              /* sub ptrs in ICONBLK */
#define R_IBPDATA       12
#define R_IPBTEXT       13
#define R_BIPDATA       14              /* sub ptrs in BITBLK */
#define R_FRSTR         15              /* gets addr of ptr to free strings */
#define R_FRIMG         16              /* gets addr of ptr to free images  */

/******************************************************************************/

/* Flags des File-Selector */
#define DOSMODE		1
#define NFOLLOWSLKS	2
#define GETMULTI		8

/******************************************************************************/

/* Sortierung beim File-Selector */
#define SORTBYNAME	0
#define SORTBYDATE	1
#define SORTBYSIZE	2
#define SORTBYTYPE	3
#define SORTBYNONE	4
#define SORTDEFAULT -1

/******************************************************************************/

/* Globale Flags des File-Selectors (fslx_set_flags) */
#define SHOW8P3	1

/******************************************************************************/

/* Globale Flags des Druck-Dialoges (pdlg_create) */
#define PDLG_3D	1

/******************************************************************************/

/* Flags fÅr das ôffnen des Druck-Dialoges (pdlg_open) */
#define PDLG_PREFS			0x0000	/* Einstell-Dialog            */
#define PDLG_PRINT			0x0001	/* Druck-Dialog               */

#define PDLG_ALWAYS_COPIES	0x0010	/* Immer Kopien anbieten      */
#define PDLG_ALWAYS_ORIENT	0x0020	/* Immer Querformat anbieten  */
#define PDLG_ALWAYS_SCALE	0x0040	/* Immer Skalierung anbieten  */

#define PDLG_EVENODD			0x0100	/* Option fÅr gerade/ungerade */
												/* Seiten anbieten            */

/******************************************************************************/

/* Die Buttons des Druck-Dialoges */
#define PDLG_CANCEL	1
#define PDLG_OK		2

/******************************************************************************/

/* Globale Flags des Font-Dialoges (fnts_create) */
#define FNTS_3D	1

/******************************************************************************/

/* Art der zugelassenen ZeichensÑtze (fnts_create) */
#define FNTS_BTMP		0x01	/* Bitmap-Fonts anzeigen */
#define FNTS_OUTL		0x02	/* Vektor-Fonts anzeigen */
#define FNTS_MONO		0x04	/* équidistante Fonts anzeigen */
#define FNTS_PROP		0x08	/* Proportionale Fonts anzeigen */

/******************************************************************************/

/* Anzeige der Buttons im Dialog (fnts_open, fnts_do) */
#define FNTS_SNAME		0x0001	/* Checkbox fÅr Name selektieren */
#define FNTS_SSTYLE		0x0002	/* Checkbox fÅr Stil selektieren */
#define FNTS_SSIZE		0x0004	/* Checkbox fÅr Grîûe selektieren */
#define FNTS_SRATIO		0x0008	/* Checkbox fÅr VerhÑltnis selektieren */
#define FNTS_CHNAME		0x0100	/* Checkbox fÅr Namen anzeigen */
#define FNTS_CHSTYLE		0x0200	/* Checkbox fÅr Stil anzeigen */
#define FNTS_CHSIZE		0x0400	/* Checkbox fÅr Grîûe anzeigen */
#define FNTS_CHRATIO		0x0800	/* Checkbox fÅr VerhÑltnis anzeigen */
#define FNTS_RATIO		0x1000	/* VerhÑltnis Breite/Hîhe einstellbar */
#define FNTS_BSET			0x2000	/* Button "Setzen" anwÑhlbar */
#define FNTS_BMARK		0x4000	/* Button "Setzen" anwÑhlbar */

/******************************************************************************/
/*																										*/
/* Die diversen AES-Strukturen																*/
/*																										*/
/******************************************************************************/

/* Der GEM-Parameterblock, wie in Pure-C kennt */
typedef struct
{
	INT16 contrl[15];
	INT16 global[80];
	INT16 intin[128];
	INT16 intout[45];
	INT16 ptsout[128];
	void *addrin[128];
	void *addrout[6];
	INT16 ptsin[128];
} GEMPARBLK;

/******************************************************************************/

/* Das GLOBAL-Array als Struktur */
typedef struct
{
	INT16 ap_version;
	INT16 ap_count;
	INT16 ap_id;
	INT32 ap_private;
	INT32 ap_ptree;
	INT32 ap_pmem;
	INT16 ap_lmem;
	INT16 ap_nplanes;
	INT32 ap_res;
	INT16 ap_bvdisk;
	INT16 ap_bvhard;
} GLOBAL;

/******************************************************************************/

/* EIn paar "forward"-Deklarationen der Strukturen */
struct __object;
struct __parmblk;

/******************************************************************************/

/* Die TEDINFO-Struktur */
typedef struct
{
	char	*te_ptext;         /* Zeiger auf einen String          */
	char	*te_ptmplt;        /* Zeiger auf die Stringmaske       */
	char	*te_pvalid;        /* Zeiger auf den GÅltigkeitsstring */
	INT16	te_font;           /* Zeichensatz                      */
	INT16	te_junk1;
	INT16	te_just;           /* Justierung des Texts             */
	INT16	te_color;          /* Farbe                            */
	INT16	te_junk2;
	INT16	te_thickness;      /* Rahmenbreite                     */
	INT16	te_txtlen;         /* Maximale LÑnge des Textes        */
	INT16	te_tmplen;         /* LÑnge der Stringmaske            */
} TEDINFO;

/******************************************************************************/

/* Die ICONBLK-Struktur */
typedef struct
{
	INT16	*ib_pmask;			/* Zeiger auf die Maske          */
	INT16	*ib_pdata;			/* Zeiger auf das Icon-Bild      */
	char	*ib_ptext;			/* Zeiger auf einen String       */
	INT16	ib_char;				/* In den unteren 8 Bit das dar- */
									/* zustellende Zeichen, in den   */
									/* oberen 8 Bit die Farbe des    */
									/* gesetzten (obere 4 Bit) und   */
									/* des gelîschten (untere 8 Bit) */
									/* Bits des Bitmuster IB_PDATA   */
	INT16	ib_xchar;			/* x-Koordinate des Buchstabens  */
	INT16	ib_ychar;			/* y-Koordinate des Buchstabens  */
	INT16	ib_xicon;			/* x-Koordinate des Icons        */
	INT16	ib_yicon;			/* y-Koordinate des Icons        */
	INT16	ib_wicon;			/* Breite des Icons              */
	INT16	ib_hicon;			/* Hîhe des Icons                */
	INT16	ib_xtext;			/* x-Koordinate des Textes       */
	INT16	ib_ytext;			/* y-Koordinate des Textes       */
	INT16	ib_wtext;			/* Breite des Textes             */
	INT16	ib_htext;			/* Hîhe des Textes               */
} ICONBLK;

/******************************************************************************/

typedef struct cicon_data
{
	INT16 num_planes;
	INT16 *col_data;
	INT16 *col_mask;
	INT16 *sel_data;
	INT16 *sel_mask;
	struct cicon_data  *next_res;
} CICON;

/******************************************************************************/

/* Die IconBlk-Struktur fÅr Farb- & Monochrom-Icons */
typedef struct cicon_blk
{
	ICONBLK	monoblk;
	CICON		*mainlist;
} CICONBLK;

/******************************************************************************/

/* Die BITBLK-Struktur */
typedef struct
{
	INT16	*bi_pdata;		/* Zeiger auf die Grafikdaten    */
	INT16	bi_wb;			/* Breite des Bildes in Bytes    */
	INT16	bi_hl;			/* Hîhe in Linien                */
	INT16		bi_x;				/* x-Position                    */
	INT16		bi_y;				/* y-Position                    */
	INT16		bi_color;		/* Vordergrundfarbe              */
} BITBLK;

/******************************************************************************/

/* Die USERBLK-Struktur (ACS verwendet stattdessen die AUSERBLK-Struktur!) */
typedef struct __userblk
{
	INT16 CDECL (*ub_code)(struct __parmblk *pb);	/* Zeiger auf die Zeichen-Funktion */
	INT32	ub_parm;												/* Optionaler Parameter            */
} USERBLK;

/******************************************************************************/

/* Die AUERBLK-Struktur (wird von ACS anstelle USERBLK verwendet) */
typedef struct __auserblk
{
	INT16 CDECL (*ub_code)(struct __parmblk *pb);	/* Zeichenroutine         */
	INT32	ub_parm;												/* Optionaler Parameter   */
	INT16 (*ub_serv)(struct __object *entry,			/* Service-Routine        */
					INT16 task, void *in_out);
	void	*ub_ptr1;											/* Userzeiger (Daten)     */
	void	*ub_ptr2;											/* Userzeiger (Fenster)   */
	void	*ub_ptr3;											/* Userzeiger (obnr)      */
	char	*bubble;												/* BubbleGEM-Hilfe-String */
	char	*context;											/* Context-Popup-String   */
} AUSERBLK;

/******************************************************************************/

/* Die Komponente ob_spec in OBJECT als Bitfeld */
typedef struct
{
	unsigned character	:	8;
	signed   framesize	:	8;
	unsigned framecol		:	4;
	unsigned textcol		:	4;
	unsigned textmode		:	1;
	unsigned fillpattern	:	3;
	unsigned interiorcol	:	4;
} bfobspec;

/******************************************************************************/

/* Die verschiedenen Mîglichkeiten der Komponente ob_spec in OBJECT */
typedef union obspecptr
{
	INT32		index;				/* fÅr das RSC-C-output      */
	union obspecptr *indirect;	/* Zeiger uaf ob_spec        */
	bfobspec	obspec;				/* Bitfield                  */
	TEDINFO	*tedinfo;			/* Zeiger auf TEDINFO        */
	ICONBLK	*iconblk;			/* Zeiger auf ICONBLK        */
	CICONBLK *ciconblk;
	BITBLK	*bitblk;				/* Zeiger auf BITBLK         */
#ifndef __STDC__
	USERBLK	*userblk;			/* Zeiger auf USERBLK        */
	AUSERBLK	*auserblk;			/* Zeiger auf AUSERBLK (ACS) */
#endif
	char		*free_string;		/* zeiger auf String         */
} OBSPEC;

/******************************************************************************/

/* Die OBJECT-Struktur fÅr die AES */
typedef struct __object
{
	INT16 ob_next;
	INT16 ob_head;
	INT16 ob_tail;
	UINT16 ob_type;
	UINT16 ob_flags;
	UINT16 ob_state;
	OBSPEC ob_spec;
	INT16 ob_x;
	INT16 ob_y;
	INT16 ob_width;
	INT16 ob_height;
} OBJECT;

/******************************************************************************/

/* Die PARMBLK-Struktur (fÅr UserDefs USERDEF & AUSERDEF wichtig!) */
typedef struct __parmblk
{
	OBJECT	*pb_tree;		/* Zeiger auf den Objektbaum       */
	INT16		pb_obj;			/* Nummer des Objekts              */
	INT16		pb_prevstate;	/* Vorheriger Objektstatus         */
	INT16		pb_currstate;	/* Neuer Objektstatus              */
	INT16		pb_x;				/* Objektkoordinaten               */
	INT16		pb_y;				/*      -"-                        */
	INT16		pb_w;				/*      -"-                        */
	INT16		pb_h;				/*      -"-                        */
	INT16		pb_xc;			/* Clipping-Koordinaten            */
	INT16		pb_yc;			/*      -"-                        */
	INT16		pb_wc;			/*      -"-                        */
	INT16		pb_hc;			/*      -"-                        */
	INT32		pb_parm;			/* Optionale Parameter aus USERBLK */
} PARMBLK;

/******************************************************************************/

/* Datentyp fÅr die Funktionszeiger der Klick- & Drag-Routinen */
typedef void (*Aaction)(void);

/******************************************************************************/

/* Die AOBJECT-Struktur fÅr die ACS */
typedef struct __aobject
{
	Aaction click;		/* Klick-Routine                      */
	Aaction drag;		/* Drag-Routine                       */
	INT16 ob_flags;	/* ob_flags wie im OBJECT zuvor       */
							/* ACHTUNG: muû an gleicher Position  */
							/*          sein, wird geprÅft!       */
	INT16 key;			/* TastenkÅrzel                       */
	void *userp1;		/* Userzeiger 1                       */
	void *userp2;		/* Userzeiger 2                       */
	INT16 mo_index;	/* Index der Mausform Åber diesem Obj */
	INT16 type;			/* ACS-Objekt-Typ                     */
} AOBJECT;

/******************************************************************************/

typedef union
{
	OBJECT obj;
	AOBJECT aobj;
} GEMObject;

/******************************************************************************/

typedef struct mfstr
{
	INT16 mf_xhot;
	INT16 mf_yhot;
	INT16 mf_nplanes;
	INT16 mf_fg;
	INT16 mf_bg;
	INT16 mf_mask[16];
	INT16 mf_data[16];
} MFORM;

/******************************************************************************/

#if !defined(OLGA_H) && !defined(__olga_t__)
	#define __olga_t__
	#define OLGA_H
	
	typedef struct
	{
		INT16 x;
		INT16 y;
		INT16 w;
		INT16 h;
		INT16 x1;
		INT16 y1;
		INT16 x2;
		INT16 y2;
	} OLGAGRECT;

	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct
	{
		INT32		magic;
		UINT16	version;
		UINT16	skip;
	} OLGAInfHeader;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
		
	typedef struct
	{
		INT32 id;
		INT32 length;
	} OLGABlockHeader;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	struct ObjectInfo;
	
	typedef void (*OlgaDraw)(struct ObjectInfo *objectinfo, int outScreen, int outHandle,
							int outDevID, OLGAGRECT *Size, OLGAGRECT *Clip);
	typedef void (*OlgaUnembed)(struct ObjectInfo *objectinfo);

	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct
	{
		INT16	*contrl;
		INT16	*global;
		INT16	*intin;
		INT16	*intout;
		INT16	*addrin;
		INT16	*addrout;
	} AESPB;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct ObjectInfo
	{
		char	*Filename;
		AESPB	*ClientGEMPB;
		INT32	ClientData;
		INT32	ServerData;
		INT16	CBLock;
		INT16	CBCount;
		OlgaDraw CBDraw;
		OlgaUnembed CBUnembed;
	} OLGAObjectInfo;

#endif

/******************************************************************************/

/* Struktur der Ereignisse (fÅr appl_tplay und appl_trecord) */
typedef struct
{
	INT32 type;
	INT32 what;
} APPLRECORD;

/******************************************************************************/

/* Input-Struktur fÅr evnt_event */
/* (ein evnt_multi-Binding ohne  */
/* groûes Parameter-Kopieren)    */
typedef struct
{
	INT16 ev_mflags;
	INT16 ev_mbclicks;
	INT16 ev_mbmask;
	INT16 ev_mbstate;
	INT16 ev_mm1flags;
	Axywh xywh1;
	INT16 ev_mm2flags;
	Axywh xywh2;
	INT16 reserved;
	UINT32 ev_mtcount;
	INT16 ev_mmgpbuff[8];
} MultiEventIn;

/******************************************************************************/

/* Output-Struktur fÅr evnt_event */
/* (ein evnt_multi-Binding ohne   */
/* groûes Parameter-Kopieren)     */
typedef struct
{
	INT16 reserved;
	INT16 ev_mmox;
	INT16 ev_mmoy;
	INT16 ev_mmbutton;
	INT16 ev_mmokstate;
	INT16 ev_mkreturn;
	INT16 ev_mbreturn;
} MultiEventOut;

/******************************************************************************/

typedef struct
{
	INT16 mwhich;         /* Art der Ereignisse */
	INT16 mx;             /* x-Koordinate des Mauszeigers */
	INT16 my;             /* y-Koordinate des Mauszeigers */
	INT16 mbutton;        /* gedrÅckte Maustaste */
	INT16 kstate;         /* Status der Sondertasten (kbshift) */
	INT16 key;            /* Scancode der gedrÅckten Taste */
	INT16 mclicks;        /* Anzahl der Mausklicks */
	INT16 reserved[9];    /* reserviert */
	INT16 msg[16];        /* Message-Buffer */
} EVNT;

/******************************************************************************/

/* Struktur fÅr menu_attach */
typedef struct
{
	OBJECT *mn_tree;
	INT16	mn_menu;
	INT16	mn_item;
	INT16	mn_scroll;
	INT16	mn_keystate;
} MENU;

/******************************************************************************/

/* MenÅ-Einstellungen (fÅr menu_settings) */
typedef struct
{
	INT32 display;
	INT32 drag;
	INT32 delay;
	INT32 speed;
	INT16 height;
} MN_SET;

/******************************************************************************/

/* Struktur fÅr erweiterte Start-Daten (fÅr shel_write) */
typedef struct
{
	char *newcmd;
	INT32 psetlimit;
	INT32 prenice;
	char *defdir;
	char *env;
} SHELW;

/******************************************************************************/

/* Header einer RSC-Datei */
typedef struct rshdr
{
	UINT16 rsh_vrsn;
	UINT16 rsh_object;
	UINT16 rsh_tedinfo;
	UINT16 rsh_iconblk;    /* list of ICONBLKS */
	UINT16 rsh_bitblk;
	UINT16 rsh_frstr;
	UINT16 rsh_string;
	UINT16 rsh_imdata;     /* image data */
	UINT16 rsh_frimg;
	UINT16 rsh_trindex;
	UINT16 rsh_nobs;       /* counts of various structs */
	UINT16 rsh_ntree;
	UINT16 rsh_nted;
	UINT16 rsh_nib;
	UINT16 rsh_nbb;
	UINT16 rsh_nstring;
	UINT16 rsh_nimages;
	UINT16 rsh_rssize;     /* total bytes in resource */
} RSHDR;

/******************************************************************************/

/* Die Filter-Funktion fÅr fslx_open */
typedef INT16 (cdecl XFSL_FILTER)(UCHAR *path, UCHAR *name, XATTR *xa);

/* Filter-Funktion fÅr fsel_boxinput */
typedef void cdecl (*FSEL_CALLBACK)( INT16 *msg );

/******************************************************************************/

/* FÅr die FNTS-Funktionen */
typedef void *FNT_DIALOG;

/* FÅr die LBOX-Funktionen */
typedef void *LIST_BOX;

typedef void *DIALOG;

typedef void *PRN_DIALOG;

/******************************************************************************/

typedef void (CDECL *UTXT_FN)(INT16 x, INT16 y, INT16 *clip_rect, 
							INT32 id, INT32 pt, INT32 ratio, CHAR *string);

/******************************************************************************/

typedef struct _fnts_item
{
	struct	_fnts_item  *next;	/* Zeiger auf den nÑchsten Font oder 0L */
	UTXT_FN	display;					/* Anzeige-Funktion fÅr eigene Fonts    */
	INT32		id;						/* ID des Fonts                         */
	INT16		index;					/* muû 0 sein, da kein VDI-Font         */
	CHAR		mono;						/* Flag fÅr Ñquidistante Fonts          */
	CHAR		outline;					/* Flag fÅr Vektorfont                  */
	INT16		npts;						/* Anzahl der vordefinierten Punkthîhen */
	CHAR		*full_name;				/* Zeiger auf den vollstÑndigen Namen   */
	CHAR		*family_name;			/* Zeiger auf den Familiennamen         */
	CHAR		*style_name;			/* Zeiger auf den Stilnamen             */
	CHAR		*pts;						/* Zeiger auf Feld mit Punkthîhen       */
	INT32		reserved[4];			/* reserviert, mÅssen 0 sein            */
} FNTS_ITEM;

/******************************************************************************/

typedef struct _lbox_item
{
    struct _lbox_item *next;  /* Zeiger auf den nÑchsten Eintrag */
                              /* in der Scroll-Liste             */
 
    INT16	selected;         /* Objekt selektiert?     */
    INT16	data1;            /* Daten fÅr das Programm */
    void		*data2;
    void		*data3;
 
} LBOX_ITEM;

/******************************************************************************/

typedef void (cdecl *SLCT_ITEM)( LIST_BOX *box, OBJECT *tree, 
                                 LBOX_ITEM *item, 
                                 void *user_data, INT16 obj_index,
                                 INT16 last_state );
/******************************************************************************/

typedef INT16 (cdecl *SET_ITEM)( LIST_BOX *box, OBJECT *tree, 
                                 LBOX_ITEM *item,
                                 INT16 obj_index, void *user_data,
                                 Axywh *rect, INT16 first );

/******************************************************************************/

/* "Forward-Deklarationen" fÅr die Druckdialoge */
struct _pdlg_sub;
struct _prn_entry;
struct _prn_settings;
struct _drv_entry;

/******************************************************************************/

/* Typen der Funktionszeiger fÅr die Druckdialoge */
typedef INT32 (cdecl *PRN_SWITCH)( struct _drv_entry *drivers,
                                   struct _prn_settings *settings,
                                   struct _prn_entry *old_printer,
                                   struct _prn_entry *new_printer );

typedef INT32 (cdecl *PDLG_INIT)( struct _prn_settings *settings,
                                  struct _pdlg_sub *sub );

typedef INT32 (cdecl *PDLG_HNDL)( struct _prn_settings *settings,
                                  struct _pdlg_sub *sub, 
                                  INT16 exit_obj );

typedef INT32 (cdecl *PDLG_RESET)( struct _prn_settings *settings,
                                   struct _pdlg_sub *sub );

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _prn_settings
{
	INT32	magic;				/* 'pset'                                 */
	INT32	length;				/* (+) StrukturlÑnge                      */
	INT32	format;				/* Strukturtyp                            */
	INT32	reserved;			/* reserviert                             */
	
	INT32	page_flags;			/* (+) Flags, u.a. gerade/ungerade Seiten */
									/* 0x0001 = nur Seiten mit gerader Nummer */
									/* 0x0002 = dto. mit ungeraden Nummern    */
	
	INT16	first_page;			/* (+) erste zu druckende Seite (min.1)   */
	INT16	last_page;			/* (+) dto. letzte Seite (max. 9999)      */
	INT16	no_copies;			/* (+) Anzahl der Kopien                  */
	
	INT16	orientation;		/* (+) Drehung                            */
									/* 0x0000 = Ausichtung unbekannt und      */
									/*          nicht verstellbar             */
									/* 0x0001 = Seite im Hochformat ausgeben  */
									/* 0x0002 = Seite im Querformat ausgeben  */
	
	INT32	scale;				/* (+) Skalierung: 0x10000L = 100%        */
	INT16	driver_id;			/* (+) VDI-GerÑtenummer                   */
	INT16	driver_type;		/* Typ des eingestellten Treibers         */
	INT32	driver_mode;		/* Flags, u.a. fÅr Hintergrunddruck       */
	INT32	reserved1;			/* reserviert                             */
	INT32	reserved2;			/* reserviert                             */
	
	INT32	printer_id;			/* Druckernummer                          */
	INT32	mode_id;				/* Modusnummer                            */
	INT16	mode_hdpi;			/* horizontale Auflîsung in dpi           */
	INT16	mode_vdpi;			/* vertikale Auflîsung in dpi             */
	INT32	quality_id;			/* Druckmodus (hardwÑremÑûige QualitÑt,   */
									/* z.B. Microweave oder Econofast)        */
	
	INT32	color_mode;			/* Farbmodus                              */
	INT32	plane_flags;		/* Flags fÅr auszugebende Farbebenen      */
									/* (z.B. nur cyan)                        */
	INT32	dither_mode;		/* Rasterverfahren                        */
	INT32	dither_value;		/* Parameter fÅr das Rasterverfahren      */
	
	INT32	size_id;				/* Papierformat                           */
	INT32	type_id;				/* Papiertyp (normal, glossy)             */
	INT32	input_id;			/* Papiereinzug                           */
	INT32	output_id;			/* Papierauswurf                          */
	
	INT32	contrast;			/* Kontrast:   0x10000L = normal          */
	INT32	brightness;			/* Helligkeit: 0x1000L  = normal          */
	INT32	reserved3;			/* reserviert                             */
	INT32	reserved4;			/* reserviert                             */
	INT32	reserved5;			/* reserviert                             */
	INT32	reserved6;			/* reserviert                             */
	INT32	reserved7;			/* reserviert                             */
	INT32	reserved8;			/* reserviert                             */
	CHAR	device[128];		/* Dateiname fÅr den Ausdruck             */
	
#ifdef __PRINTING__
	TPrint	mac_settings;	/* Einstellung des Mac-Druckertreibers    */
#else
	struct
	{
		UCHAR	inside[120];
	} mac_settings;
#endif
} PRN_SETTINGS;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _pdlg_sub 
{
	struct _pdlg_sub *next;			/* Zeiger auf Nachfolger           */
	INT32			length;				/* StrukturlÑnge                   */
	INT32			format;				/* Datenformat                     */
	INT32			reserved;			/* reserviert                      */
	
	void			*drivers;			/* nur fÅr interne Dialoge         */
	INT16			option_flags;		/* verschiedene Flags              */
	INT16			sub_id;				/* Kennung des Unterdialogs        */
	DIALOG		*dialog;				/* Zeiger auf die Struktur des     */
											/* Fensterdialogs oder 0L          */
	
	OBJECT		*tree;				/* Zeiger auf den Objektbaum       */
	INT16			index_offset;		/* Offset des Unterdialogs         */
	INT32			reserved1;			/* reserviert                      */
	INT32			reserved2;			/* reserviert                      */
	INT32			reserved3;			/* reserviert                      */
	INT32			reserved4;			/* reserviert                      */
	
	PDLG_INIT	init_dlg;			/* Initialisierungsfunktion        */
	PDLG_HNDL	do_dlg;				/* Behandlungsfunktion             */
	PDLG_RESET	reset_dlg;			/* ZurÅcksetzfunktion              */
	INT32			reserved5;			/* reserviert                      */
	
	OBJECT      *sub_icon;			/* Zeiger auf das Icon der Listbox */
	OBJECT      *sub_tree;			/* Objektbaum des Unterdialogs     */
	INT32			reserved6;			/* reserviert                      */
	INT32			reserved7;			/* reserviert                      */
	
	INT32			private1;			/* dialogeigene Informationen-1    */
	INT32			private2;			/* dialogeigene Informationen-2    */
	INT32			private3;			/* dialogeigene Informationen-3    */
	INT32			private4;			/* dialogeigene Informationen-4    */
} PDLG_SUB;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _media_type 
{
	struct _media_type   *next;	/* Zeiger auf Nachfolger     */
	INT32			type_id;				/* Kennung des Papierformats */
	CHAR			name[32];			/* Name des Papierformats    */
} MEDIA_TYPE;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _media_size 
{
	struct _media_size *next;		/* Zeiger auf Nachfolger     */
	INT32			size_id;				/* Kennung des Papierformats */
	CHAR			name[32];			/* Name des Papierformats    */
} MEDIA_SIZE;

/******************************************************************************/

/* Typen der Funktionszeiger fÅr die Druckdialoge */
typedef struct _drv_entry
{
	struct _drv_entry *next;
} DRV_ENTRY;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _prn_tray 
{
	struct _prn_tray  *next;		/* Zeiger auf Nachfolger       */
	INT32			tray_id;				/* Nummer des Einzugs/Auswurfs */
	CHAR			name[32];			/* Name des Schachts           */
} PRN_TRAY;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _prn_mode
{
	struct _prn_mode *next;				/* Zeiger auf Nachfolger             */
	INT32			mode_id;					/* Modus (Index innerhalb der Datei) */
	INT16			hdpi;						/* horizontale Auflîsung in dpi      */
	INT16			vdpi;						/* vertikale Auflîsung in dpi        */
	INT32			mode_capabilities;	/* Moduseigenschaften                */
	
	INT32			color_capabilities;	/* einstellbare Farbmodi             */
	INT32			dither_flags;			/* Flags, die angeben, ob der        */
												/* korrespondierende Farbmodus mit   */
												/* oder ohne Dithern ansprechbar ist */
	
	MEDIA_TYPE	*paper_types;			/* geeignete Papiertypen             */
	INT32			reserved;				/* reserviert                        */
	CHAR			name[32];				/* Modusname                         */
} PRN_MODE;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _prn_entry 
{
	struct _prn_entry *next;				/* Zeiger auf Nachfolger           */
	INT32			length;						/* StrukturlÑnge                   */
	INT32			format;						/* Datenformat                     */
	INT32			reserved;					/* reserviert                      */
	
	INT16			driver_id;					/* Treiberkennung                  */
	INT16			driver_type;				/* Treibertyp                      */
	INT32			printer_id;					/* Druckerkennung                  */
	INT32			printer_capabilities;	/* Druckereigenschaften            */
	INT32			reserved1;					/* reserviert                      */
	
	INT32			flags;						/* verschiedene Flags              */
	struct _pdlg_sub  *sub_dialogs;		/* Zeiger auf Unterdialoge         */
   PRN_SWITCH	setup_panel;				/* Unterdialog bei Druckerwechsel  */
   												/* initialisieren                  */
	PRN_SWITCH	close_panel;				/* Unterdialog bei Druckerwechsel  */
													/* schlieûen                       */
	
	PRN_MODE		*modes;						/* Liste vorhand. Auflîsungen      */
	MEDIA_SIZE	*papers;						/* Liste vorhand. Papierformate    */
	PRN_TRAY		*input_trays;				/* Liste der EinzÅge               */
	PRN_TRAY		*output_trays;				/* Liste der AuswÅrfe              */
	CHAR			name[32];					/* Name des Druckers               */
} PRN_ENTRY;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _dither_mode
{
	struct _dither_mode  *next;	/* Zeiger auf Nachfolger     */
	
	INT32			length;				/* StrukturlÑnge             */
	INT32			format;				/* Datenformat               */
	INT32			reserved;			/* reserviert                */
	INT32			dither_id;			/* Kennung                   */
	INT32			color_modes;		/* unterstÅtzte Farbtiefen   */
	INT32			reserved1;			/* reserviert                */
	INT32			reserved2;			/* reserviert                */
	CHAR			name[32];			/* Name des Rasterverfahrens */
 
} DITHER_MODE;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct
{
	INT32			magic;					/* 'pdnf'                           */
	INT32			length;					/* StrukturlÑnge                    */
	INT32			format;					/* Datenformat                      */
	INT32			reserved;				/* reserviert                       */
	
	INT16			driver_id;				/* Treibernummer fÅrs VDI           */
	INT16			driver_type;			/* Treibertyp                       */
	INT32			reserved1;				/* reserviert                       */
	INT32			reserved2;				/* reserviert                       */
	INT32			reserved3;				/* reserviert                       */
	
	PRN_ENTRY	*printers;				/* zum Treiber gehîrenden Drucker   */
	DITHER_MODE	*dither_modes;			/* unterstÅtzte Rasterverfahren     */
	INT32			reserved4;				/* reserviert                       */
	INT32			reserved5;				/* reserviert                       */
	INT32			reserved6;				/* reserviert                       */
	INT32			reserved7;				/* reserviert                       */
	INT32			reserved8;				/* reserviert                       */
	INT32			reserved9;				/* reserviert                       */
	CHAR			device[128];			/* Ausgabedatei des Druckertreibers */
} DRV_INFO;

/******************************************************************************/
/*																										*/
/* Die globalen Variablen																		*/
/*																										*/
/******************************************************************************/

/* Der GEM-Parameterblock (Pure-C-kompatibel ;-( */
extern GEMPARBLK _GemParBlk;

/* Zeiger auf GLOBAL-Struktur des Hauptthreads */
extern GLOBAL *_globl;

/* Flag, ob Anwendung als Application oder Accesory lÑuft */
extern INT16 _app;

/******************************************************************************/
/*																										*/
/* Prototyp der Assembler-Routine															*/
/*	Diese macht den AES-Aufruf und setzt den dazu nîtigen AES-Parameterblock	*/
/* auf dem Stack zusammen - das ist etwas multithreading freundlicher... ;-)	*/
/*																										*/
/******************************************************************************/

void CDECL aes( INT16 *contrl, GLOBAL *global, INT16 *intin, INT16 *intout,
          void *addrin, void *addrout );

/******************************************************************************/
/*																										*/
/* Die APPL-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 appl_init( void );
INT16 appl_read( INT16 rwid, INT16 length, void *pbuff );
INT16 appl_write( INT16 rwid, INT16 length, void *pbuff );
INT16 appl_find( char *pname );
INT16 appl_search( INT16 mode, char *fname, INT16 *type, INT16 *ap_id );
INT16 appl_tplay( APPLRECORD *tbuffer, INT16 tlength, INT16 tscale );
INT16 appl_trecord( APPLRECORD *tbuffer, INT16 tlength );
INT16 appl_yield( void );
INT16 appl_exit( void );
INT16 appl_getinfo( INT16 type, INT16 *out1, INT16 *out2, INT16 *out3, INT16 *out4 );
INT16 appl_control( INT16 ap_cid, INT16 ap_cwhat, void *ap_cout );

/******************************************************************************/
/*																										*/
/* Die EVNT-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 evnt_keybd( void );
INT16 evnt_button( INT16 ev_bclicks, UINT16 ev_bmask,
			UINT16 ev_bstate, INT16 *ev_bmx, INT16 *ev_bmy, INT16 *ev_bbutton,
			INT16 *ev_bkstate );
INT16 evnt_mouse( INT16 ev_moflags, INT16 ev_mox,
			INT16 ev_moy, INT16 ev_mowidth, INT16 ev_moheight,
			INT16 *ev_momx, INT16 *ev_momy, INT16 *ev_mobutton, INT16 *ev_mokstate );
INT16 evnt_mesag( INT16 *pbuff );
INT16 evnt_timer( INT16 ev_tlocount, INT16 ev_thicount );
INT16 evnt_event( MultiEventIn *input, MultiEventOut *output );
INT16 evnt_multi( INT16 ev_mflags, INT16 ev_mbclicks,
				INT16 ev_mbmask, INT16 ev_mbstate, INT16 ev_mm1flags,
				INT16 ev_mm1x, INT16 ev_mm1y, INT16 ev_mm1width,
				INT16 ev_mm1height, INT16 ev_mm2flags, INT16 ev_mm2x,
				INT16 ev_mm2y, INT16 ev_mm2width, INT16 ev_mm2height,
				INT16 *ev_mmgpbuff, INT16 ev_mtlocount, INT16 ev_mthicount,
				INT16 *ev_mmox, INT16 *ev_mmoy, INT16 *ev_mmbutton, INT16 *ev_mmokstate,
				INT16 *ev_mkreturn, INT16 *ev_mbreturn );
INT16 evnt_dclick( INT16 rate, INT16 setit );

/******************************************************************************/
/*																										*/
/* Die MENU-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 menu_bar( OBJECT *tree, INT16 show );
INT16 menu_icheck( OBJECT *tree, INT16 item, INT16 check );
INT16 menu_ienable( OBJECT *tree, INT16 item, INT16 enable );
INT16 menu_tnormal( OBJECT *tree, INT16 title, INT16 normal );
INT16 menu_text( OBJECT *tree, INT16 item, char *text );
INT16 menu_register( INT16 apid, char *string );
INT16 menu_unregister( INT16 apid );
INT16 menu_click( INT16 click, INT16 setit );
INT16 menu_attach( INT16 flag, OBJECT *tree, INT16 item, MENU *mdata );
INT16 menu_istart( INT16 flag, OBJECT *tree, INT16 imenu, INT16 item );
INT16 menu_popup( MENU *menu, INT16 xpos, INT16 ypos, MENU *mdata );
INT16 menu_settings( INT16 flag, MN_SET *set );

/******************************************************************************/
/*																										*/
/* Die OBJC-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 objc_add( OBJECT *tree, INT16 parent, INT16 child );
INT16 objc_delete( OBJECT *tree, INT16 objnr );
INT16 objc_draw( OBJECT *tree, INT16 start, INT16 depth,
				INT16 xclip, INT16 yclip, INT16 wclip, INT16 hclip );
INT16 objc_find( OBJECT *tree, INT16 start, INT16 depth,
				INT16 mx, INT16 my );
INT16 objc_offset( OBJECT *tree, INT16 objnr, INT16 *x, INT16 *y );
INT16 objc_order( OBJECT *tree, INT16 objnr, INT16 new_nr );
INT16 objc_edit( OBJECT *tree, INT16 objnr, INT16 inchar,
				INT16 *idx, INT16 kind );
INT16 objc_change( OBJECT *tree, INT16 objnr, INT16 reserved, 
				INT16 xclip, INT16 yclip, INT16 wclip, INT16 hclip,
				INT16 newstate, INT16 redraw );
INT16 objc_sysvar( INT16 mode, INT16 which, INT16 in1, INT16 in2, INT16 *out1, INT16 *out2 );

/******************************************************************************/
/*																										*/
/* Die FORM-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 form_do( OBJECT *tree, INT16 start );
INT16 form_dial( INT16 flag, INT16 xlittle,
				INT16 ylittle, INT16 wlittle, INT16 hlittle,
				INT16 xbig, INT16 ybig, INT16 wbig, INT16 hbig );
INT16 form_alert( INT16 defbutton, char *string );
INT16 form_error( INT16 errnum );
INT16 form_center( OBJECT *tree, INT16 *x, INT16 *y, INT16 *w, INT16 *h );
INT16 form_keybd( OBJECT *tree, INT16 obj, INT16 next,
				INT16 input_char, INT16 *next_obj, INT16 *pchar );
INT16 form_button( OBJECT *tree, INT16 obj,
				INT16 clicks, INT16 *next_obj );

/******************************************************************************/
/*																										*/
/* Die GRAF-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 graf_rubbox( INT16 x, INT16 y, INT16 w_min,
				INT16 h_min, INT16 *w_end, INT16 *h_end );
INT16 graf_rubberbox( INT16 x, INT16 y, INT16 w_min,
				INT16 h_min, INT16 *w_end, INT16 *h_end );
INT16 graf_dragbox( INT16 w, INT16 h, INT16 sx,
				INT16 sy, INT16 xc, INT16 yc, INT16 wc, INT16 hc,
				INT16 *x, INT16 *y );
INT16 graf_mbox( INT16 w, INT16 h, INT16 start_x,
				INT16 start_y, INT16 ende_x, INT16 ende_y );
INT16 graf_movebox( INT16 w, INT16 h, INT16 start_x,
				INT16 start_y, INT16 ende_x, INT16 ende_y );
INT16 graf_growbox( INT16 start_x, INT16 start_y,
				INT16 start_w, INT16 start_h, INT16 ende_x,
				INT16 ende_y, INT16 ende_w, INT16 ende_h );
INT16 graf_shrinkbox( INT16 start_x, INT16 start_y,
				INT16 start_w, INT16 start_h, INT16 ende_x,
				INT16 ende_y, INT16 ende_w, INT16 ende_h );
INT16 graf_watchbox( OBJECT *tree, INT16 obj_nr,
				INT16 instate, INT16 outstate );
INT16 graf_slidebox( OBJECT *tree, INT16 parent,
				INT16 obj_nr, INT16 isvert );
INT16 graf_handle( INT16 *wchar, INT16 *hchar, INT16 *wbox, INT16 *hbox );
INT16 graf_mouse( INT16 mouse_nr, MFORM *form );
INT16 graf_mkstate( INT16 *x, INT16 *y, INT16 *mstate, INT16 *kstate );
INT16 graf_multirubber( INT16 x, INT16 y, INT16 minw, INT16 minh, Axywh *rec,
				INT16 *outw, INT16 *outh );

/******************************************************************************/
/*																										*/
/* Die SCRP-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 scrp_read( char *pathname );
INT16 scrp_write( char *pathname );

/******************************************************************************/
/*																										*/
/* Die FSEL-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 fsel_input( char *path, char *name, INT16 *button );
INT16 fsel_exinput( char *path, char *name, INT16 *button, char *label );
INT16 fsel_boxinput( char *path, char *name, int *button,
			char *label, FSEL_CALLBACK callback );

/******************************************************************************/
/*																										*/
/* Die FSLX-Funktionen (MagiC)																*/
/*																										*/
/******************************************************************************/

void *fslx_open( char *title, INT16 x, INT16 y, INT16 *handle, char *path, INT16 pathlen,
				char *fname, INT16 fnamelen, char *patterns, XFSL_FILTER *filter, char *paths,
				INT16 sort_mode, INT16 flags);
INT16 fslx_close( void *fsd );
INT16 fslx_getnxtfile( void *fsd, char *fname );
INT16 fslx_evnt( void *fsd, EVNT *events, char *path, char *fname, INT16 *button,
			INT16 *nfiles, INT16 *sort_mode, char **pattern );
void *fslx_do( char *title, char *path, INT16 pathlen, char *fname, INT16 fnamelen,
				char *patterns, XFSL_FILTER *filter, char *paths, INT16 *sort_mode,
				INT16 flags, INT16 *button, INT16 *nfiles, char **pattern );
INT16 fslx_set_flags( INT16 flags, INT16 *oldval );

/******************************************************************************/
/*																										*/
/* Die WIND-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 wind_create( INT16 kind, INT16 max_x, INT16 max_y,
				INT16 max_w, INT16 max_h );
INT16 wind_open( INT16 handle, INT16 x, INT16 y,
				INT16 w, INT16 h );
INT16 wind_close( INT16 handle );
INT16 wind_delete( INT16 handle );
INT16 wind_get( INT16 handle, INT16 what, ... );
INT16 wind_getQSB( INT16 handle, void **buffer, INT32 *length );
INT16 wind_set( INT16 handle, INT16 what, ... );
INT16 wind_find( INT16 x, INT16 y );
INT16 wind_update( INT16 what );
INT16 wind_calc( INT16 wtype, INT16 kind,
				INT16 x, INT16 y, INT16 w, INT16 h,
				INT16 *px, INT16 *py, INT16 *pw, INT16 *ph );
INT16 wind_new( void );

/******************************************************************************/
/*																										*/
/* Die RSRC-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 rsrc_load( char *name );
INT16 rsrc_free( void );
INT16 rsrc_gaddr( INT16 type, INT16 id, void **addr );
INT16 rsrc_saddr( INT16 type, INT16 id, void *addr );
INT16 rsrc_obfix( OBJECT *tree, INT16 obj );
INT16 rsrc_rcfix( void *rc_header );

/******************************************************************************/
/*																										*/
/* Die SHEL-Funktionen																			*/
/*																										*/
/******************************************************************************/

INT16 shel_read( char *cmd, char *tail );
INT16 shel_write( INT16 do_execute, INT16 is_graph,
				INT16 is_overlay, char *cmd, char *tail );
INT16 shel_get( char *addr, INT16 len );
INT16 shel_put( char *addr, INT16 len );
INT16 shel_find( char *path );
INT16 shel_envrn( char *name, char **value );
INT16 shel_help( INT16 sh_hmode, char *sh_hfile, char *sh_hkey );

/******************************************************************************/
/*																										*/
/* Die FNTS-Funktionen (WDialog)																*/
/*																										*/
/******************************************************************************/

INT16 fnts_add( const FNT_DIALOG *fnt_dialog, const FNTS_ITEM *user_fonts );
INT16 fnts_close( const FNT_DIALOG *fnt_dialog, INT16 *x, INT16 *y );
FNT_DIALOG *fnts_create( const INT16 vdi_handle, const INT16 no_fonts,
					const INT16 font_flags, const INT16 dialog_flags,
					const CHAR *sample, const CHAR *opt_button );
INT16 fnts_delete( const FNT_DIALOG *fnt_dialog, const INT16 vdi_handle );
INT16 fnts_do( FNT_DIALOG *fnt_dialog, const INT16 button_flags, const INT32 id_in,
					const fix31 pt_in, const INT32 ratio_in, INT16 *check_boxes, 
					INT32 *id, fix31 *pt, fix31 *ratio );
INT16 fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, INT16 *button,
					INT16 *check_boxes, INT32 *id, fix31 *pt, fix31 *ratio );
INT16 fnts_get_info( FNT_DIALOG *fnt_dialog, const INT32 id, INT16 *mono,
					INT16  *outline );
INT16 fnts_get_name( FNT_DIALOG *fnt_dialog, const INT32 id, CHAR *full_name,
					CHAR *family_name, CHAR *style_name );
INT16 fnts_get_no_styles( FNT_DIALOG *fnt_dialog, const INT32 id );
INT32 fnts_get_style( FNT_DIALOG *fnt_dialog, const INT32 id, const INT16 index );
INT16 fnts_open( FNT_DIALOG *fnt_dialog, const INT16 button_flags, const INT16 x,
					const INT16 y, const INT32 id, const fix31 pt, const fix31 ratio );
void fnts_remove( FNT_DIALOG *fnt_dialog );
INT16 fnts_update( FNT_DIALOG *fnt_dialog, const INT16 button_flags,
					const INT32 id, const fix31 pt, const INT32 ratio );

/******************************************************************************/
/*																										*/
/* Die LBOX-Funktionen (WDialog)																*/
/*																										*/
/******************************************************************************/

void lbox_ascroll_to( LIST_BOX *box, const INT16 first,
					Axywh *box_rect, Axywh *slider_rect );
void lbox_scroll_to( LIST_BOX *box, const INT16 first,
					Axywh *box_rect, Axywh *slider_rect );
void lbox_bscroll_to( LIST_BOX *box, const INT16 first,
					Axywh *box_rect, Axywh *slider_rect );
INT16 lbox_cnt_items( LIST_BOX *box );
LIST_BOX *lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set,
					LBOX_ITEM *items, const INT16 visible_a, const INT16 first_a,
					const INT16 *ctrl_objs, const INT16 *objs, const INT16 flags, 
					const INT16 pause_a, void *user_data, DIALOG *dialog,
					const INT16 visible_b, const INT16 first_b, const INT16 entries_b, 
					const INT16 pause_b );
INT16 lbox_delete( LIST_BOX *box );
INT16 lbox_do( LIST_BOX *box, INT16 obj );
void lbox_free_items( LIST_BOX *box );
void lbox_free_list( LBOX_ITEM *items );
INT16 lbox_get_afirst( LIST_BOX *box );
INT16 lbox_get_first( LIST_BOX *box );
INT16 lbox_get_avis( LIST_BOX *box );
INT16 lbox_get_visible( LIST_BOX *box );
INT16 lbox_get_bentries( LIST_BOX *box );
INT16 lbox_get_bfirst( LIST_BOX *box );
INT16 lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search );
LBOX_ITEM *lbox_get_item( LIST_BOX *box, INT16 n );
LBOX_ITEM *lbox_get_items( LIST_BOX *box );
INT16 lbox_get_slct_idx( LIST_BOX *box );
LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box );
OBJECT *lbox_get_tree( LIST_BOX *box );
void *lbox_get_udata( LIST_BOX *box );
void lbox_set_asldr( LIST_BOX *box, INT16 first, Axywh *rect );
void lbox_set_slider( LIST_BOX *box, INT16 first, Axywh *rect );
void lbox_set_bentries( LIST_BOX *box, INT16 entries );
void lbox_set_bsldr( LIST_BOX *box, INT16 first, Axywh *rect );
void lbox_set_items( LIST_BOX *box, LBOX_ITEM *items );
void lbox_update( LIST_BOX *box, Axywh *rect );

/******************************************************************************/
/*																										*/
/* Die PDLG-Funktionen (WDialog)																*/
/*																										*/
/******************************************************************************/

INT16 pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info );
INT16 pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialog );
INT16 pdlg_close( PRN_DIALOG *prn_dialog, INT16 *x, INT16 *y );
PRN_DIALOG *pdlg_create ( INT16 dialog_flags );
INT16 pdlg_delete( PRN_DIALOG *prn_dialog );
INT16 pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings );
INT16 pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
					CHAR *document_name, const INT16 option_flags );
INT16 pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
					EVNT *events, INT16 *button );
INT16 pdlg_free_settings( PRN_SETTINGS *settings );
INT32 pdlg_get_setsize( void );
PRN_SETTINGS *pdlg_new_settings( PRN_DIALOG *prn_dialog );
INT16 pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
					CHAR *document_name, const INT16 option_flags,
					const INT16 x, const INT16 y );
INT16 pdlg_remove_printers( PRN_DIALOG *prn_dialog );
INT16 pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog );
INT16 pdlg_update( PRN_DIALOG *prn_dialog, CHAR *document_name );
INT16 pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings );
INT16 pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings );

/******************************************************************************/

#endif
