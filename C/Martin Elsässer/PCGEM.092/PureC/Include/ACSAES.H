/******************************************************************************/
/*																										*/
/*          Eine handoptimierte Bibliothek fÅr Pure-C und GNU-C               */
/*																										*/
/* Die AES-Funktionen - Headerdatei															*/
/*																										*/
/*	(c) 1999-2006 by Martin ElsÑsser									1 Tab = 3 Spaces	*/
/******************************************************************************/

#ifndef __ACSAES__
#define __ACSAES__

/******************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************/

#ifndef __ACSTYPE__
	#include <ACSTYPE.H>
#endif

#include <TOS.H>

/******************************************************************************/
/*																										*/
/* Die diversen AES-Konstanten																*/
/*																										*/
/******************************************************************************/

/* Objekt-Nummer */
#define G_BOX						20
#define G_TEXT						21
#define G_BOXTEXT					22
#define G_IMAGE					23
#define G_USERDEF					24
#define G_IBOX						25
#define G_BUTTON					26
#define G_BOXCHAR					27
#define G_STRING					28
#define G_FTEXT					29
#define G_FBOXTEXT				30
#define G_ICON						31
#define G_TITLE					32
#define G_CICON					33
#define G_SWBUTTON				34		/* MAG!X                				*/
#define G_POPUP					35		/* MAG!X                				*/
#define G_RESVD1					36		/* MagiC 3.1	 							*/
#define G_EDIT						37		/* MagiC 5.20, Åber Shared Library	*/
#define G_SHORTCUT				38		/* MagiC 6 									*/

/* Div. Aliase */
#define G_PROGDEF					G_USERDEF
/******************************************************************************/

/* Object flags */
#define NONE						0x0000
#define SELECTABLE				0x0001
#define DEFAULT					0x0002
#define EXIT						0x0004
#define EDITABLE					0x0008
#define RBUTTON					0x0010
#define LASTOB						0x0020
#define TOUCHEXIT					0x0040
#define HIDETREE					0x0080
#define INDIRECT					0x0100
#define FL3DIND					0x0200	/* 3D Indicator	AES 4.0 */
#define FL3DBAK					0x0400	/* 3D Background	AES 4.0 */
#define FL3DACT					0x0600	/* 3D Activator	AES 4.0 */
#define SUBMENU					0x0800

/* Konstantennamen aus der GEMLIB */
#define OF_NONE					NONE
#define OF_SELECTABLE			SELECTABLE
#define OF_DEFAULT				DEFAULT
#define OF_EXIT					EXIT
#define OF_EDITABLE				EDITABLE
#define OF_RBUTTON				RBUTTON
#define OF_LASTOB					LASTOB
#define OF_TOUCHEXIT				TOUCHEXIT
#define OF_HIDETREE				HIDETREE
#define OF_INDIRECT				INDIRECT
#define OF_FL3DIND				FL3DIND
#define OF_FL3DBAK				FL3DBAK
#define OF_FL3DACT				FL3DACT
#define OF_SUBMENU				SUMBENU
#define OF_FLAG12					0x1000#define OF_FLAG13					0x2000#define OF_FLAG14					0x4000#define OF_FLAG15					0x8000
/******************************************************************************/

/* Objektstatus (OBJECT.ob_state) */
#define NORMAL						0x0000
#define SELECTED					0x0001
#define CROSSED					0x0002
#define CHECKED					0x0004
#define DISABLED					0x0008
#define OUTLINED					0x0010
#define SHADOWED					0x0020
#define WHITEBAK					0x0040		/* TOS         */
#define DRAW3D						0x0080		/* GEM 2.x     */

/* Konstantennamen aus der GEMLIB */
#define OS_NORMAL					NORMAL
#define OS_SELECTED				SELECTED
#define OS_CROSSED				CROSSED
#define OS_CHECKED				CHECKED
#define OS_DISABLED				DISABLED
#define OS_OUTLINED				OUTLINED
#define OS_SHADOWED				SHADOWED
#define OS_WHITEBAK				WHITEBAK
#define OS_DRAW3D					DRAW3D
#define OS_STATE08				0x0100#define OS_STATE09				0x0200#define OS_STATE10				0x0400#define OS_STATE11				0x0800#define OS_STATE12				0x1000#define OS_STATE13				0x2000#define OS_STATE14				0x4000#define OS_STATE15				0x8000
/******************************************************************************/

/* Object colors */
#if !defined(__COLORS)
#define __COLORS			/* Using AES-colors and BGI-colors is not possible */

#define WHITE						 0
#define BLACK						 1
#define RED							 2
#define GREEN						 3
#define BLUE						 4
#define CYAN						 5
#define YELLOW						 6
#define MAGENTA					 7
#define LWHITE						 8
#define LBLACK						 9
#define LRED						10
#define LGREEN						11
#define LBLUE						12
#define LCYAN						13
#define LYELLOW					14
#define LMAGENTA					15

/* Aus PC-GEM Åbernommen */
#define DWHITE						LWHITE
#define DBLACK						LBLACK 
#define DRED						LREAD
#define DGREEN						LGREEN
#define DBLUE						LBLUE
#define DCYAN						LCYAN
#define DYELLOW					LYELLOW
#define DMAGENTA					LMAGENTA

/* Konstantennamen aus der GEMLIB */
#define G_WHITE					WHITE#define G_BLACK					BLACK#define G_RED						RED#define G_GREEN					GREEN#define G_BLUE						BLUE#define G_CYAN						CYAN#define G_YELLOW					YELLOW#define G_MAGENTA					MAGENTA#define G_LWHITE					LWHITE#define G_LBLACK					LBLACK#define G_LRED						LRED#define G_LGREEN					LGREEN#define G_LBLUE					LBLUE#define G_LCYAN					LCYAN#define G_LYELLOW					LYELLOW#define G_LMAGENTA				LMAGENTA
#endif

/******************************************************************************/

/* Maus-Formen */
#define ARROW						  0
#define TEXT_CRSR					  1
#define BUSYBEE					  2
#define POINT_HAND				  3
#define FLAT_HAND					  4
#define THIN_CROSS				  5
#define THICK_CROSS				  6
#define OUTLN_CROSS				  7
#define USER_DEF					255
#define M_OFF						256
#define M_ON						257
#define M_SAVE						258
#define M_LAST						259
#define M_RESTORE					260
#define M_FORCE					0x8000
/* Div. Aliase */
#define HOURGLASS					BUSYBEE
#define BUSY_BEE					BUSYBEE
#define BEE							BUSYBEE

/******************************************************************************/

/* Funktions-Codes fÅr menu_attach */
#define ME_INQUIRE				0
#define ME_ATTACH					1
#define ME_REMOVE					2

/******************************************************************************/

/* Scroll-Infos (fÅr Struktur MENU, menu_attach) */
#define SCROLL_NO					0
#define SCROLL_YES				1

/******************************************************************************/

/* Funktions-Codes fÅr menu_bar */
#define MENU_INQUIRE				 -1#define MENU_REMOVE				  0
#define MENU_INSTALL				  1
#define MENU_GETMODE				  3			/* MenÅleistenmodus abfragen             */
#define MENU_SETMODE				  4			/* MenÅleistenmodus setzen               */
#define MENU_UPDATE				  5			/* Update des Systemteils der MenÅleiste */
#define MENU_INSTL      		100		/* MAG!X */

/******************************************************************************/

/* Bit-Struktur fÅr MENU_SETMODE */
#define  MENU_HIDDEN				0x0001	/* MenÅleiste nur bei Bedarf sichtbar */
#define  MENU_PULLDOWN			0x0002	/* Pulldown-MenÅs                     */
#define  MENU_SHADOWED			0x0004	/* MenÅleistenboxen mit Schatten      */

/******************************************************************************/

/* Modus fÅr menu_icheck */#define UNCHECK					0#define CHECK						1
/******************************************************************************/

/* Modus fÅr menu_ienable */#define DISABLE					0#define ENABLE 					1
/******************************************************************************/

/* Modus fÅr menu_istart */#define MIS_GETALIGN 			0#define MIS_SETALIGN 			1
/******************************************************************************/
/* Modus fÅr menu_popup  */#define SCROLL_LISTBOX			-1/******************************************************************************/

/* Spezielle Ap-ID fÅr's Registrieren des Prozeûnamens */
#define REG_NEWNAME				-1

/******************************************************************************/

/* Modus fÅr menu_tnormal */#define HIGHLIGHT					0#define UNHIGHLIGHT				1/******************************************************************************/

/* Tastatur-Status (fÅr appl_trecord, evnt_button, evnt_mouse, evnt_multi) */
#define K_RSHIFT					0x0001
#define K_LSHIFT					0x0002
#define K_CTRL						0x0004
#define K_ALT						0x0008

/******************************************************************************/

/* Ereignis-Flags (fÅr evnt_multi, evnt_event) */
#define MU_KEYBD					0x0001
#define MU_BUTTON					0x0002
#define MU_M1						0x0004
#define MU_M2						0x0008
#define MU_MESAG					0x0010
#define MU_TIMER					0x0020
#define MU_WHEEL					0x0040		/* XaAES */#define MU_MX						0x0080		/* XaAES */#define MU_NORM_KEYBD			0x0100		/* XaAES */#define MU_DYNAMIC_KEYBD		0x0200		/* XaAES */
/******************************************************************************/

/* Button-Masken fÅr evnt_button und evnt_multi */
#define LEFT_BUTTON				0x0001#define RIGHT_BUTTON 			0x0002#define MIDDLE_BUTTON			0x0004
/******************************************************************************/

/* Flag fÅr evnt_dclick */#define EDC_INQUIRE				0#define EDC_SET					1
/******************************************************************************/

/* Funktionsauswahl fÅr objc_edit */
#define ED_START					  0
#define ED_INIT					  1
#define ED_CHAR					  2
#define ED_END						  3
#define ED_CRSR					100	/* MAG!X       */
#define ED_DRAW					103	/* MAG!X 2.00  */

/* Div. Aliase */
#define EDSTART					ED_START#define EDINIT 					ED_INIT#define EDCHAR 					ED_CHAR#define EDEND						ED_END
/******************************************************************************/

/* Spezial-Position fÅr objc_order */
#define OO_LAST					-1
#define OO_FIRST					0

/******************************************************************************/

/* Flag fÅr das Objektbaum-Zeichnen (fÅr objc_draw) */
#define NO_DRAW					0
#define REDRAW						1

/******************************************************************************/

/* Funktions-Codes fÅr objc_sysvar */
#define LK3DIND					 1			/* AES 4.0    */
#define LK3DACT					 2			/* AES 4.0    */
#define INDBUTCOL					 3			/* AES 4.0    */
#define BACKGRCOL					 4			/* AES 4.0    */
#define AD3DVAL					 5			/* AES 4.0    */
#define AD3DVALUE					 6			/* AES 4.0    */
#define MX_ENABLE3D				10			/* MagiC 3.0  */
#define MENUCOL					11			/* MagiC 6.0  */

/******************************************************************************/

/* Modus fÅr objc_sysvar */
#define SV_INQUIRE				0
#define SV_SET						1

/******************************************************************************/

/* Typen fÅr form_dial */
#define FMD_START					0
#define FMD_GROW					1
#define FMD_SHRINK				2
#define FMD_FINISH				3

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

/* RÅckgabewerte fÅr fsel_input und fsel_exinput */#define FSEL_CANCEL		 		0#define FSEL_OK			 		1/******************************************************************************/

/* Modus fÅr shel_get */#define SHEL_BUFSIZE 			(-1)
/******************************************************************************/
/* shel_write modes for parameter "doex" */
#define SHW_NOEXEC				  0
#define SHW_EXEC					  1
#define SHW_EXEC_ACC				  3		/* AES 3.3	*/
#define SHW_SHUTDOWN				  4		/* AES 3.3     */
#define SHW_RESCHNG				  5		/* AES 3.3     */
#define SHW_BROADCAST			  7		/* AES 4.0     */
#define SHW_INFRECGN				  9		/* AES 4.0     */
#define SHW_AESSEND				  10    /* AES 4.0     */
#define SHW_THR_CREATE			  20		/* MagiC 4.5	*/
#define SHW_THR_EXIT				  21		/* MagiC */
#define SHW_THR_KILL				  22		/* MagiC */
#define SHW_XMDLIMIT				 256
#define SHW_XMDNICE				 512
#define SHW_XMDDEFDIR			1024
#define SHW_XMDENV				2048

/* Konstantennamen aus der GEMLIB */
#define SWM_LAUNCH				SHW_NOEXEC
#define SWM_LAUNCHNOW			SHW_EXEC
#define SWM_LAUNCHACC			SHW_EXEC_ACC
#define SWM_SHUTDOWN				SHW_SHUTDOWN
#define SWM_REZCHANGE			SHW_RESCHNG
#define SWW_BROADCAST			SHW_BROADCAST
#define SWM_ENVIRON				8#define SWM_NEWMSG				SHW_INFRECGN
#define SWM_AESMSG				SHW_AESSEND
#define SWM_THRCREATE			SHW_THR_CREATE
#define SWM_THRTERMINATE		SHW_THR_EXIT
#define SWM_THRSCHEDULE			SHW_THR_KILL

/******************************************************************************/

/* shel_write modes for parameter "isover" */
#define SHW_IMMED						0                                  /* PC-GEM 2.x  */
#define SHW_CHAIN						1                                  /* TOS         */
#define SHW_DOS						2                                  /* PC-GEM 2.x  */
#define SHW_RESCHANGE				5
#define SHW_PARALLEL				 100                                /* MAG!X       */
#define SHW_SINGLE				 101                                /* MAG!X       */
#define SHW_XMDFLAGS				4096

/******************************************************************************/

/* Erweiterte Start-Flags fÅr die Modi SWM_LAUNCH, SWM_LAUNCHNOW */
/* und SWM_LAUNCHACC (fÅr shel_write)                            */
#define SW_PSETLIMIT				0x0100
#define SW_PRENICE				0x0200
#define SW_PDEFDIR				0x0400
#define SW_ENVIRON				0x0800

/******************************************************************************/

/*  */
#define CL_NORMAL					0
#define CL_PARSE					1

/******************************************************************************/

/* Werte fÅr Modus SHW_SHUTDOWN bzw. SWM_SHUTDOWN (fÅr shel_write) */
#define SD_ABORT					0
#define SD_PARTIAL				1
#define SD_COMPLETE				2

/******************************************************************************/

/* Werte fÅr Modus SWM_ENVIRON (fÅr shel_write) */
#define ENVIRON_SIZE				0
#define ENVIRON_CHANGE			1
#define ENVIRON_COPY				2

/******************************************************************************/

/* Werte fÅr Modus SHW_INFRECGN bzw. SWM_NEWMSG (fÅr shel_write) */
#define NM_APTERM					0x0001
#define NM_INHIBIT_HIDE			0x0002

/******************************************************************************/

/* Werte fÅr Modus SHW_AESSEND bzw. SWM_AESMSG (fÅr shel_write) */
#define AP_AESTERM				52     /* Mode 10: N.AES komplett terminieren. */

/******************************************************************************/

/* Modus fÅr shel_help */
#define SHP_HELP					0

/******************************************************************************/

/* Fensterkomponenten (fÅr wind_create) */
#define NAME						0x0001
#define CLOSER						0x0002
#define FULLER						0x0004
#define MOVER						0x0008
#define INFO						0x0010
#define SIZER						0x0020
#define UPARROW					0x0040
#define DNARROW					0x0080
#define VSLIDE						0x0100
#define LFARROW					0x0200
#define RTARROW					0x0400
#define HSLIDE						0x0800
#define HOTCLOSEBOX				0x1000		/* KaOS, MagiC */
#define MENUBAR					0x1000		/* XaAES */#define BACKDROP					0x2000
#define ICONIFIER					0x4000

#define SMALLER					ICONIFIER

/******************************************************************************/

/* Die Infos fÅr wind_get und wind_set */
#define WF_KIND					    1
#define WF_NAME					    2
#define WF_INFO					    3
#define WF_WORKXYWH				    4
#define WF_CURRXYWH				    5
#define WF_PREVXYWH				    6
#define WF_FULLXYWH				    7
#define WF_HSLIDE					    8
#define WF_VSLIDE					    9
#define WF_TOP						   10
#define WF_FIRSTXYWH				   11
#define WF_NEXTXYWH				   12
#define WF_RESVD					   13
#define WF_NEWDESK				   14
#define WF_HSLSIZE				   15
#define WF_VSLSIZE				   16
#define WF_SCREEN					   17
#define WF_COLOR					   18
#define WF_DCOLOR					   19
#define WF_OWNER					   20
#define WF_BEVENT					   24
#define WF_BOTTOM					   25
#define WF_ICONIFY				   26
#define WF_UNICONIFY				   27
#define WF_UNICONIFYXYWH		   28
#define WF_TOOLBAR				   30
#define WF_FTOOLBAR				   31
#define WF_NTOOLBAR				   32
#define WF_MENU						33		/* XaAES */#define WF_WHEEL						40		/* XaAES: Mausrad-Konfiguration */#define WF_OPTS						41		/* XaAES: Konfiguration der AES-.reaktion bei Mausrad-Events */
#define WF_M_BACKDROP    		  100		/* KAOS 1.4	*/
#define WF_M_OWNER       		  101		/* KAOS 1.4	*/
#define WF_M_WINDLIST    		  102		/* KAOS 1.4	*/
#define WF_MINXYWH		   	  103		/* MagiC 6	*/
#define WF_INFOXYWH				  104		/* MagiC 6.10  */
#define WF_WIDGETS				  200		/* Positionen der V- und H-Sliderelemente. */
#define WF_WINX					22360		/* WINX		*/
#define WF_WINXCFG				22361		/* WINX		*/		
#define WF_DDELAY					22362		/* WINX		*/
#define WF_SHADE		  			22365		/* WINX 2.3	*/
#define WF_STACK		  			22366		/* WINX 2.3	*/
#define WF_TOPALL		  			22367		/* WINX 2.3	*/
#define WF_BOTTOMALL				22368		/* WINX 2.3	*/
#define WF_XAAES					0x5841	/* XaAES: 'XA' */
#define WF_WXYWH					WF_WORKXYWH
#define WF_CXYWH					WF_CURRXYWH
#define WF_PXYWH					WF_PREVXYWH
#define WF_FXYWH					WF_FULLXYWH

/******************************************************************************/

/* wind_set(WF_BEVENT) */
#define BEVENT_WORK     		0x0001    /* AES 4.0  */
#define BEVENT_INFO     		0x0002    /* MagiC 6  */

/******************************************************************************/

/* Die Fenster-Komponenten (fÅr wind_set, Modus WF_COLOR und WF_DCOLOR) */
#define W_BOX						 0
#define W_TITLE					 1
#define W_CLOSER					 2
#define W_NAME						 3
#define W_FULLER					 4
#define W_INFO						 5
#define W_DATA						 6
#define W_WORK						 7
#define W_SIZER					 8
#define W_VBAR						 9
#define W_UPARROW					10
#define W_DNARROW					11
#define W_VSLIDE					12
#define W_VELEV					13
#define W_HBAR						14
#define W_LFARROW					15
#define W_RTARROW					16
#define W_HSLIDE					17
#define W_HELEV					18
#define W_SMALLER					19
#define W_BOTTOMER				20					/* MagiC 3     */
#define W_HIDER					30

/******************************************************************************/

/* Die Einstellungen (fÅr wind_set, Modus WF_OPTS) */
#define WO0_WHEEL					0x0001
#define WO0_FULLREDRAW			0x0002
#define WO0_NOBLITW				0x0004
#define WO0_NOBLITH				0x0008
#define WO0_SENDREPOS			0x0010

/******************************************************************************/

/* Die Einstellungen fÅr das MausRad (fÅr wind_set, Modus WF_WHEEL) */
#define WHL_REALWHEEL			0
#define WHL_AROWWHEEL			1
#define WHL_SLDRWHEEL			2

/******************************************************************************/

/* Die Konstanten fÅr die Scroll-Nachrichten */
#define WA_UPPAGE 				0
#define WA_DNPAGE 				1
#define WA_UPLINE 				2
#define WA_DNLINE 				3
#define WA_LFPAGE 				4
#define WA_RTPAGE 				5
#define WA_LFLINE 				6
#define WA_RTLINE 				7
#define WA_WHEEL					8	/* XaAES */
/******************************************************************************/

/* Flags fÅr wind_calc */
#define WC_BORDER					0
#define WC_WORK					1

/******************************************************************************/

/* Modi fÅr wind_update bzw. Awi_update */
#define BEG_UPDATE				0x0001
#define END_UPDATE				0x0000
#define BEG_MCTRL					0x0003
#define END_MCTRL					0x0002

/* ErgÑnzungen von ACS */
#define RESET_UPDATE 			0x0010
#define RESTART_UPDATE  		0x0020

/* Bisherige Konstanten von ACS */
#define BEGIN_UPDATE				BEG_UPDATE
#define BEGIN_MCTR				BEG_MCTRL
#define END_MCTR					END_MCTRL

/******************************************************************************/

/* Daten-Strukturen im RSC-File (fÅr rsrc_gaddr) */
#define R_TREE						 0
#define R_OBJECT					 1
#define R_TEDINFO					 2
#define R_ICONBLK					 3
#define R_BITBLK					 4
#define R_STRING					 5              /* gets pointer to free strings */
#define R_IMAGEDATA				 6              /* gets pointer to free images */
#define R_OBSPEC					 7
#define R_TEPTEXT					 8              /* sub ptrs in TEDINFO */
#define R_TEPTMPLT				 9
#define R_TEPVALID				10
#define R_IBPMASK					11              /* sub ptrs in ICONBLK */
#define R_IBPDATA					12
#define R_IBPTEXT					13
#define R_IPBTEXT					R_IBPTEXT
#define R_BIPDATA					14              /* sub ptrs in BITBLK */
#define R_FRSTR					15              /* gets addr of ptr to free strings */
#define R_FRIMG					16              /* gets addr of ptr to free images  */

#define R_IPBTEXT					R_IBPTEXT

/******************************************************************************/

#define ROOT            		 0					/* the root object of a tree   */
#define NIL             		-1					/* nil object index            */
#define MAX_LEN         		81					/* max string length           */
#define MAX_DEPTH       		 8					/* max depth of search or draw */

/******************************************************************************/

/* Zeichensatz-Typen */
#define GDOS_PROP					0#define GDOS_MONO					1#define GDOS_BITM					2#define IBM             		3
#define SMALL           		5

/******************************************************************************/

/* Ausrichtung eines editierbaren Textfeldes */
#define TE_LEFT					0
#define TE_RIGHT					1
#define TE_CNTR					2

/******************************************************************************/

/* Die Funktions-Codes fÅr appl_getinfo */
#define AES_LARGEFONT			 0
#define AES_SMALLFONT			 1
#define AES_SYSTEM				 2
#define AES_LANGUAGE				 3
#define AES_PROCESS				 4
#define AES_PCGEM					 5
#define AES_INQUIRE				 6
#define AES_MOUSE					 8
#define AES_MENU					 9
#define AES_SHELL					10
#define AES_WINDOW				11
#define AES_MESSAGE				12
#define AES_OBJECT				13
#define AES_FORM					14
#define AES_EXTENDED				64
#define AES_NAES					65
#define AES_VERSION				96
#define AES_WOPTS					97		/* XaAES */
#define AES_FUNCTIONS			98		/* XaAES */
#define AES_AOPTS					99		/* XaAES: Available application options */

/******************************************************************************/

/* Die Font-Typ fÅr AES_LARGEFONT und AES_SMALLFONT, appl_getinfo */#define SYSTEM_FONT				0#define OUTLINE_FONT 			1
/******************************************************************************/
/* Die Sprachen fÅr AES_LANGUAGE, appl_getinfo */
#define AESLANG_ENGLISH			0#define AESLANG_GERMAN			1
#define AESLANG_FRENCH			2
#define AESLANG_SPANISH			4
#define AESLANG_ITALIAN			5
#define AESLANG_SWEDISH			6

/******************************************************************************/

/* Die Flags in AES_FUNCTIONS, appl_getinfo */
#define AGI_WFORM					0x0001
#define AGI_AOPTS					0x0002
#define AGI_OBJCDATA				0x0004

/******************************************************************************/

/* Die Flags in AES_WINDOW, appl_getinfo */
#define AGI_WF_WHEEL				0x0200
#define AGI_WF_FIRSTAREAXYWH	0x0400
#define AGI_WF_OPTS				0x0800
#define AGI_WF_MENU				0x1000

/******************************************************************************/

/* Die Flags in AES_MESSAGE, appl_getinfo */
#define AGI_WM_REPOSED			0x0400		/* XaAES */

/******************************************************************************/

/* Die Flags in AES_VERSION, appl_getinfo */
#define AES_ARCH_M68K			0

#define AES_DEVSTATUS_ALPHA	0
#define AES_DEVSTATUS_BETA		1
#define AES_DEVSTATUS_RELEASE	2

#define AES_FDEVSTATUS_STABLE	0x0100

/******************************************************************************/

/* Funktionscodes fÅr appl_search */
#define APP_FIRST					0
#define APP_NEXT					1

/******************************************************************************/

/* Prozeû-Typen (fÅr appl_search) */
#define APP_SYSTEM				0x01
#define APP_APPLICATION			0x02
#define APP_ACCESSORY			0x04
#define APP_SHELL					0x08

/******************************************************************************/

/* Event-Typen (fÅr appl_tplay und appl_trecord) */
#define APPEVNT_TIMER			0
#define APPEVNT_BUTTON			1
#define APPEVNT_MOUSE			2
#define APPEVNT_KEYBOARD		3

/******************************************************************************/

/* Keine Daten vorhanden (appl_read) - MagiC & MultiTOS */#define APR_NOWAIT				-1/******************************************************************************/

/* Konstanten fÅr ap_cwhat der Funktion appl_control */
#define APC_HIDE					10
#define APC_SHOW					11
#define APC_TOP					12
#define APC_HIDENOT				13
#define APC_INFO					14
#define APC_MENU					15
#define APC_WIDGETS				16

/******************************************************************************/

/* Flags fÅr den Integer, auf den ap_cout bei APC_INFO zeigt (appl_control) */
#define APCI_HIDDEN				0x01
#define APCI_HASMBAR				0x02
#define APCI_HASDESK				0x04

/******************************************************************************/

/* Grîûe des Puffers in int16 fÅr APC_WIDGETS (appl_control) */
#define MINWINOBJ					12

/******************************************************************************/

/* Flags fÅr die Maus-öberwachung (evnt_mouse, evnt_multi, evnt_event) */
#define MO_ENTER					0
#define MO_LEAVE					1

/******************************************************************************/

/* Die Messages des Screenmanagers */
#define MN_SELECTED				 10
#define WM_REDRAW					 20
#define WM_TOPPED					 21
#define WM_CLOSED					 22
#define WM_FULLED					 23
#define WM_ARROWED				 24
#define WM_HSLID					 25
#define WM_VSLID					 26
#define WM_SIZED					 27
#define WM_MOVED					 28
#define WM_NEWTOP					 29
#define WM_UNTOPPED				 30
#define WM_ONTOP					 31
#define WM_OFFTOP					 32
#define WM_BOTTOMED				 33
#define WM_ICONIFY				 34
#define WM_UNICONIFY				 35
#define WM_ALLICONIFY			 36
#define WM_TOOLBAR				 37
#define WM_REPOSED				 38#define AC_OPEN					 40
#define AC_CLOSE					 41
#define AP_TERM					 50
#define CT_UPDATE					 50					/* XControl */
#define AP_TFAIL					 51
#define CT_MOVE					 51					/* XControl */
#define CT_NEWTOP					 52					/* XControl */
#define CT_KEY						 53					/* XControl */
#define AP_RESCHG					 57
#define SHUT_COMPLETED  		 60
#define RESCH_COMPLETED			 61
#define AP_DRAGDROP				 63
#define SH_WDRAW					 72
#define SC_CHANGED				 80					/* In Dokus fÑlschlich als CH_EXIT benannt */
#define PRN_CHANGED				 82
#define FNT_CHANGED				 83
#define COLORS_CHANGED			 84
#define THR_EXIT					 88
#define PA_EXIT					 89					/* MagiC 3     */
#define CH_EXIT					 90					/* MultiTOS    */
#define WM_M_BDROPPED			100					/* KAOS 1.4, MaciC <=2 (MagiC > 2=> WM_BOTTOM) */
#define SM_M_SPECIAL				101
#define SM_M_RES2					102					/* MAG!X       */
#define SM_M_RES3					103					/* MAG!X       */
#define SM_M_RES4					104					/* MAG!X       */
#define SM_M_RES5					105					/* MAG!X       */
#define SM_M_RES6					106					/* MAG!X       */
#define SM_M_RES7					107					/* MAG!X       */
#define SM_M_RES8					108					/* MAG!X       */
#define SM_M_RES9					109					/* MAG!X       */
#define WM_SHADED					0x5758				/* [WM_SHADED apid 0 win 0 0 0 0]   */
#define WM_UNSHADED				0x5759				/* [WM_UNSHADED apid 0 win 0 0 0 0] */
#define WM_MOUSEWHEEL 			0x0930				/* Sent by Wheel */
#define FONT_CHANGED				0x7A18				/* Font Protocol */
#define FONT_SELECT				0x7A19				/* Font Protocol */
#define FONT_ACK					0x7A1A				/* Font Protocol */
#define XFONT_CHANGED			0x7A1B				/* Font Protocol */

/******************************************************************************/

/* Die SM_M_SPECIAL Codes */
#define SMC_TIDY_UP     		0                    /* MagiC 2  */
#define SMC_TERMINATE   		1                    /* MagiC 2  */
#define SMC_SWITCH      		2                    /* MagiC 2  */
#define SMC_FREEZE      		3                    /* MagiC 2  */
#define SMC_UNFREEZE    		4                    /* MagiC 2  */
#define SMC_RES5        		5                    /* MagiC 2  */
#define SMC_UNHIDEALL   		6                    /* MagiC 3.1   */
#define SMC_HIDEOTHERS  		7                    /* MagiC 3.1   */
#define SMC_HIDEACT     		8                    /* MagiC 3.1   */

/******************************************************************************/

/* menu_bar modes */
#define MENU_HIDE					  0							/* TOS         */
#define MENU_SHOW					  1							/* TOS         */
#define MENU_INSTL				100							/* MAG!X       */

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

/* Messages des D&D-Protokolles */

#define DD_OK         			0    /* Ok, - weitermachen                */
#define DD_NAK        			1    /* Drag&Drop abbrechen               */
#define DD_EXT        			2    /* Datenformat wird nicht akzeptiert */
#define DD_LEN        			3    /* Wunsch nach weniger Daten         */
#define DD_TRASH      			4    /* Ziel ist ein Papierkorb-Icon      */
#define DD_PRINTER    			5    /* Ziel ist ein Drucker-Icon         */
#define DD_CLIPBOARD  			6    /* Ziel ist ein Klemmbrett-Icon      */

/******************************************************************************/

/* GEMScript-Messages */
#ifndef __gemscript__
	#define __gemscript__
	
	/* GEMScript-Nachrichten */
	#define GS_REQUEST      	0x1350
	#define GS_REPLY        	0x1351
	#define GS_COMMAND      	0x1352
	#define GS_ACK          	0x1353
	#define GS_QUIT         	0x1354
	#define GS_OPENMACRO    	0x1355
	#define GS_MACRO        	0x1356
	#define GS_WRITE        	0x1357
	#define GS_CLOSEMACRO   	0x1358
	
	typedef struct
	{
		long len;		/* LÑnge der Struktur in Bytes */
		int16 version;	/* Versionsnummer des Protokolles beim Sender (z.Z. 0x0120 = 1.2) */
		int16 msgs;		/* Bitmap der unterstÅtzten Nachrichten und FÑhigkeiten (GSM_xxx) */
		long ext;		/* benutzte Endung, etwa '.SIC'                     */
	} GS_INFO;
	
	/* Kennung fÅr den Empfang von GS_COMMAND */
	#define GSM_COMMAND			0x0001
	
	/* Kennung fÅr Empfang von GS_OPENMACRO, GS_WRITE */
	/* und GS_CLOSEMACRO und Senden von GS_MACRO      */
	#define GSM_MACRO				0x0002
	
	/* Kennung fÅr Versand von GS_OPENMACRO, GS_WRITE */
	/* und GS_CLOSEMACRO und Empfang von GS_MACRO     */
	#define GSM_WRITE				0x0004
	
	/* Hex-Codierung wird verstanden */
	#define GSM_HEXCODING		0x0008
	
	/* RÅckgabewerte der GEMScript-Funktionen (Anwendung & Fenster) */
	#define GSACK_OK				0
	#define GSACK_UNKNOWN		1
	#define GSACK_ERROR			2
	
#endif

/******************************************************************************/

/* OLGA-Messages */
#if !defined(OLGA_H) && !defined(__olga_c__)
	#define __olga_c__
	#define OLGA_H
	#define _ACS_OLGA_

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
	#define OLGA_ID4UPDATE           0x1257
	#define OLGA_GETEXTENSION        0x1258
	#define OLGA_EXTENSION           0x1259
	#define OLGA_GETSERVERPATH       0x125a
	#define OLGA_SERVERPATH          0x125b
	#define OLGA_IE_BUTTON           0x125c
	#define OLGA_IE_KEY              0x125d
	
	#define OL_SERVER                0x0001
	#define OL_CLIENT                0x0002
	#define OL_PEER                  (OL_SERVER | OL_CLIENT)
	#define OL_CONF                  0x0400
	#define OL_IDLE                  0x0800
	#define OL_PIPES                 0x1000
	#define OL_START                 0x2000
	#define OL_MANAGER               0x4000
	#define OL_OEP                   0x0001
	
	#define OLS_TYPE                      1
	#define OLS_EXTENSION                 2
	#define OLS_NAME                      3
	
	#define OL_SRV_ID4               0x0001
	
#endif

/******************************************************************************/

/* DHST-Messages */
#if !defined(DHST)
	#define DHST
	
	#define DHST_ADD				0xDADD
	#define DHST_ACK				0xDADE
	
	/* Datenstruktur */
	typedef struct
	{
		char *appname;
		char *apppath;
		char *docname;
		char *docpath;
	} DHSTINFO;
	
#endif

/******************************************************************************/

/* SSP-Messages */
#if !defined(SSP)
	#define SSP
	
	/* Messages des SSP-Protokolls */
	#define SSP_SRASSR				0x126F
	#define SSP_SSIR					0x1270
	#define SSP_SPASI					0x1271
	#define SSP_SSUR					0x1272
	#define SSP_SPASA					0x1273
	#define SSP_SSA					0x1274
	
	/* Services zur Server-Registration */
	#define SSP_PSENDFILE			0x0001
	#define SSP_PSTATUSDISPLAY		0x0002
	#define SSP_PDISPLAYMESSAGE	0x0004
	#define SSP_PSENDMESSAGE		0x0008
	#define SSP_PUPLOADFILE			0x0010
	#define SSP_PCOMPRESSFILE		0x0020
	#define SSP_PCONTEXTPOPUP		0x0040
	#define SSP_PDISPLAYINFO		0x0080
	
	/* Services for Service Requesting Application Service Request */
	#define SSP_SENDFILE				0x0001
	#define SSP_STATUSDISPLAY		0x0002
	#define SSP_DISPLAYMESSAGE		0x0004
	#define SSP_SENDMESSAGE			0x0008
	#define SSP_UPLOADFILE			0x0010
	#define SSP_COMPRESSFILE		0x0020
	#define SSP_CONTEXTPOPUP		0x0040
	#define SSP_DISPLAYINFO			0x0080
	
	/* Data identification for Service Requesting Application Service Request */
	#define SSP_TEXT					0x0001
	#define SSP_FILENAME				0x0002
	#define SSP_STATUSICON			0x0004
	#define SSP_INFOBUF				0x0008
	#define SSP_CONTEXTREQUEST		0x0010
	
#endif

/******************************************************************************/

#if !defined(__XMESSAGE__)
	#define __XMESSAGE__
	
	#define XMESSAGE					0xFFF0
	#define XMSG_ASK					0xFFF1
	#define XMSG_OK					0xFFF2
#endif

/******************************************************************************/

/* Flags des File-Selector */
#define DOSMODE					1
#define NFOLLOWSLKS				2
#define GETMULTI					8

/******************************************************************************/

/* Sortierung beim File-Selector */
#define SORTBYNAME				 0
#define SORTBYDATE				 1
#define SORTBYSIZE				 2
#define SORTBYTYPE				 3
#define SORTBYNONE				 4
#define SORTDEFAULT				-1

/******************************************************************************/

/* Globale Flags des File-Selectors (fslx_set_flags) */
#define SHOW8P3					1

/******************************************************************************/

/* Globale Flags des Druck-Dialoges (pdlg_create) */
#define PDLG_3D					1

/******************************************************************************/

/* Flags fÅr das ôffnen des Druck-Dialoges (pdlg_open) */
#define PDLG_PREFS				0x0000	/* Einstell-Dialog            */
#define PDLG_PRINT				0x0001	/* Druck-Dialog               */

#define PDLG_ALWAYS_COPIES		0x0010	/* Immer Kopien anbieten      */
#define PDLG_ALWAYS_ORIENT		0x0020	/* Immer Querformat anbieten  */
#define PDLG_ALWAYS_SCALE		0x0040	/* Immer Skalierung anbieten  */

#define PDLG_EVENODD				0x0100	/* Option fÅr gerade/ungerade */
													/* Seiten anbieten            */

/******************************************************************************/

/* Flags fÅr die Struktur PRN_SETTINGS */

/* <driver_mode>*/
#define	DM_BG_PRINTING			0x0001					/* Flag fÅr Hintergrunddruck */

/* <page_flags> */
#define	PG_EVEN_PAGES			0x0001					/* nur Seiten mit gerader Seitennummer ausgeben */
#define	PG_ODD_PAGES			0x0002					/* nur Seiten mit ungerader Seitennummer ausgeben */

/* <first_page/last_page> */
#define	PG_MIN_PAGE				1
#define	PG_MAX_PAGE				9999

/* <orientation> */
#define	PG_UNKNOWN				0x0000					/* Ausrichtung unbekannt und nicht verstellbar */
#define	PG_PORTRAIT				0x0001					/* Seite im Hochformat ausgeben */
#define	PG_LANDSCAPE			0x0002					/* Seite im Querformat ausgeben */

/******************************************************************************/

/* Die Buttons des Druck-Dialoges */
#define PDLG_CANCEL				1
#define PDLG_OK					2

/******************************************************************************/

#define PDLG_CHG_SUB				0x80000000L
#define PDLG_IS_BUTTON			0x40000000L

/******************************************************************************/

#define PDLG_PREBUTTON			0x20000000L
#define PDLG_PB_OK				1
#define PDLG_PB_CANCEL			2
#define PDLG_PB_DEVICE			3

/******************************************************************************/

#define PDLG_BUT_OK				( PDLG_PREBUTTON + PDLG_PB_OK )
#define PDLG_BUT_CNCL			( PDLG_PREBUTTON + PDLG_PB_CANCEL )
#define PDLG_BUT_DEV				( PDLG_PREBUTTON + PDLG_PB_DEVICE )

/******************************************************************************/

/* Flags fÅr die Unterdialog des Druck-Dialoges */#define PRN_STD_SUBS				0x0001			/* Standard-Unterdialoge fÅr NVDI-Drucker */#define PRN_FSM_SUBS				0x0002			/* Standard-Unterdialoge fÅr FSM-Drucker */#define PRN_QD_SUBS				0x0004			/* Standard-Unterdialoge fÅr QuickDraw-Drucker */
/******************************************************************************/

/* Globale Flags des Font-Dialoges (fnts_create) */
#define FNTS_3D					1

/******************************************************************************/

/* Art der zugelassenen ZeichensÑtze (fnts_create) */
#define FNTS_BTMP					0x01	/* Bitmap-Fonts anzeigen */
#define FNTS_OUTL					0x02	/* Vektor-Fonts anzeigen */
#define FNTS_MONO					0x04	/* équidistante Fonts anzeigen */
#define FNTS_PROP					0x08	/* Proportionale Fonts anzeigen */

/******************************************************************************/

/* Anzeige der Buttons im Dialog (fnts_open, fnts_do) */
#define FNTS_SNAME				0x0001	/* Checkbox fÅr Name selektieren */
#define FNTS_SSTYLE				0x0002	/* Checkbox fÅr Stil selektieren */
#define FNTS_SSIZE				0x0004	/* Checkbox fÅr Grîûe selektieren */
#define FNTS_SRATIO				0x0008	/* Checkbox fÅr VerhÑltnis selektieren */
#define FNTS_CHNAME				0x0100	/* Checkbox fÅr Namen anzeigen */
#define FNTS_CHSTYLE				0x0200	/* Checkbox fÅr Stil anzeigen */
#define FNTS_CHSIZE				0x0400	/* Checkbox fÅr Grîûe anzeigen */
#define FNTS_CHRATIO				0x0800	/* Checkbox fÅr VerhÑltnis anzeigen */
#define FNTS_RATIO				0x1000	/* VerhÑltnis Breite/Hîhe einstellbar */
#define FNTS_BSET					0x2000	/* Button "Setzen" anwÑhlbar */
#define FNTS_BMARK				0x4000	/* Button "Markieren" anwÑhlbar */

/******************************************************************************/

/* Konstanten fÅr die Buttons im fnts-Dialog */
#define FNTS_CANCEL				1
#define FNTS_OK					2
#define FNTS_SET					3
#define FNTS_MARK					4
#define FNTS_OPTION				5

/* Konstante aus GEMLIB */
#define FNTS_OPT					FNTS_OPTION

/******************************************************************************/

/* Konstanten fÅr die Listboxen (lbox_...) */
#define LBOX_VERT					  1			/* Listbox mit vertikalem Slider								*/
#define LBOX_AUTO					  2			/* Auto-Scrolling													*/
#define LBOX_AUTOSLCT			  4			/* automatische Darstellung beim Auto-Scrolling			*/
#define LBOX_REAL					  8			/* Real-Time-Slider												*/
#define LBOX_SNGL					 16			/* nur ein anwÑhlbarer Eintrag								*/
#define LBOX_SHFT					 32			/* Mehrfachselektionen mit Shift								*/
#define LBOX_TOGGLE				 64			/* Status eines Eintrags bei Selektion wechseln			*/
#define LBOX_2SLDRS				128			/* Listbox hat einen hor. und einen vertikalen Slider	*/

/******************************************************************************/

/* Einstellbare Farbmodi eines Druckermodus */
#define	CC_MONO					0x0001					/* 2 Grautîne */
#define	CC_4_GREY				0x0002					/* 4 Grautîne */
#define	CC_8_GREY				0x0004					/* 8 Grautîne */
#define	CC_16_GREY				0x0008					/* 16 Grautîne */
#define	CC_256_GREY				0x0010					/* 256 Grautîne */
#define	CC_32K_GREY				0x0020					/* 32768 Farben in Grautîne wandeln */
#define	CC_65K_GREY				0x0040					/* 65536 Farben in Grautîne wandeln */
#define	CC_16M_GREY				0x0080					/* 16777216 Farben in Grautîne wandeln */
	
#define	CC_2_COLOR				0x0100					/* 2 Farben */
#define	CC_4_COLOR				0x0200					/* 4 Farben */
#define	CC_8_COLOR				0x0400					/* 8 Farben */
#define	CC_16_COLOR				0x0800					/* 16 Farben */
#define	CC_256_COLOR			0x1000					/* 256 Farben */
#define	CC_32K_COLOR			0x2000					/* 32768 Farben */
#define	CC_65K_COLOR			0x4000					/* 65536 Farben */
#define	CC_16M_COLOR			0x8000					/* 16777216 Farben */

#define	NO_CC_BITS				16

/******************************************************************************/

/* Einstellbare Rasterverfahren */
#define	DC_NONE					0							/* keine Rasterverfahren */
#define	DC_FLOYD					1							/* einfacher Floyd-Steinberg */

#define	NO_DC_BITS				1

/******************************************************************************/

/* Druckereigenschaften */
#define	PC_FILE					0x0001					/* Drucker kann Åber GEMDOS-Dateien angesprochen werden */
#define	PC_SERIAL				0x0002					/* Drucker kann auf der seriellen Schnittstelle angesteuert werden */
#define	PC_PARALLEL				0x0004					/* Drucker kann auf der parallelen Schnittstelle angesteuert werden */
#define	PC_ACSI					0x0008					/* Drucker kann auf der ACSI-Schnittstelle ausgeben */
#define	PC_SCSI					0x0010					/* Drucker kann auf der SCSI-Schnittstelle ausgeben */

#define	PC_BACKGROUND			0x0080					/* Treiber kann im Hintergrund ausdrucken */

#define	PC_SCALING				0x0100					/* Treiber kann Seite skalieren */
#define	PC_COPIES				0x0200					/* Treiber kann Kopien einer Seite erstellen */

/******************************************************************************/

/* Moduseigenschaften */
#define	MC_PORTRAIT				0x0001					/* Seite kann im Hochformat ausgegeben werden */
#define	MC_LANDSCAPE			0x0002					/* Seite kann im Querformat ausgegeben werden */
#define	MC_REV_PTRT				0x0004					/* Seite kann um 180 Grad gedreht im Hochformat ausgegeben werden */
#define	MC_REV_LNDSCP			0x0008					/* Seite kann um 180 Grad gedreht im Querformat ausgegeben werden */
#define	MC_ORIENTATION			0x000F

#define	MC_SLCT_CMYK			0x0400					/* Treiber kann bestimmte Farbebenen ausgeben */
#define	MC_CTRST_BRGHT			0x0800					/* Treiber kann Kontrast und Helligkeit verÑndern */

/******************************************************************************/

/* Flags fÅr plane_flags in PRN_SETTINGS */
#define	PLANE_BLACK				0x0001
#define	PLANE_YELLOW			0x0002
#define	PLANE_MAGENTA			0x0004
#define	PLANE_CYAN				0x0008

/******************************************************************************/

/* Definitionen fÅr <flags> fÅr wdlg_create */#define  WDLG_BKGD   			1           /* Permit background operation *//******************************************************************************/

/* Funktionsnummern fÅr <obj> in handle_exit(...) bei wdlg_create */#define  HNDL_INIT				 -1			/* Initialise dialog */#define  HNDL_MESG				 -2			/* Initialise dialog */#define  HNDL_CLSD				 -3			/* Dialog window was closed */#define  HNDL_OPEN				 -5			/* End of dialog initialisation (second  call at end of wdlg_init) */#define  HNDL_EDIT   			 -6         /* Test characters for an edit-field */#define  HNDL_EDDN   			 -7         /* Character was entered in edit-field */#define  HNDL_EDCH   			 -8         /* Edit-field was changed */#define  HNDL_MOVE   			 -9			/* Dialog was moved */#define  HNDL_TOPW   			-10			/* Dialog-window has been topped */#define  HNDL_UNTP   			-11			/* Dialog-window is not active */
/******************************************************************************/
/*																										*/
/* Die diversen AES-Strukturen																*/
/*																										*/
/******************************************************************************/

/* Der GEM-Parameterblock, wie in Pure-C kennt */
typedef struct
{
	int16 contrl[15];
	int16 global[80];
	int16 intin[128];
	int16 intout[45];
	int16 ptsout[128];
	void *addrin[128];
	void *addrout[6];
	int16 ptsin[128];
} GEMPARBLK;

/******************************************************************************/

/* Das global-Array als Struktur */
typedef struct
{
	int16 ap_version;
	int16 ap_count;
	int16 ap_id;
	int32 ap_private;
	int32 ap_ptree;
	int32 ap_pmem;
	int16 ap_lmem;
	int16 ap_nplanes;
	int32 ap_res;
	int16 ap_bvdisk;
	int16 ap_bvhard;
} GlobalArray;

/******************************************************************************/

typedef struct
{
	int16	*contrl;
	int16	*global;
	int16	*intin;
	int16	*intout;
	int16	*addrin;
	int16	*addrout;
} AESPB;

/******************************************************************************/

/* Mausrechteck fÅr EVNT_multi() */
typedef struct
{
	int16 m_out;
	int16 m_x;
	int16 m_y;
	int16 m_w;
	int16 m_h;
} MOBLK;

/******************************************************************************/

/* Ein paar "forward"-Deklarationen der Strukturen */
struct object;
struct parm_block;

/******************************************************************************/

/* Die TEDINFO-Struktur */
typedef struct text_edinfo
{
	char	*te_ptext;         /* Zeiger auf einen String          */
	char	*te_ptmplt;        /* Zeiger auf die Stringmaske       */
	char	*te_pvalid;        /* Zeiger auf den GÅltigkeitsstring */
	int16	te_font;           /* Zeichensatz                      */
	int16	te_fontid;
	int16	te_just;           /* Justierung des Texts             */
	int16	te_color;          /* Farbe                            */
	int16	te_fontsize;
	int16	te_thickness;      /* Rahmenbreite                     */
	int16	te_txtlen;         /* Maximale LÑnge des Textes        */
	int16	te_tmplen;         /* LÑnge der Stringmaske            */
} TEDINFO;

/* Zugriff fÅr die PureC-Komponenten te_junk1 und te_junk2 */
#define te_junk1	te_fontid
#define te_junk2	te_fontsize

/******************************************************************************/

/* Die ICONBLK-Struktur */
typedef struct icon_block
{
	int16	*ib_pmask;			/* Zeiger auf die Maske          */
	int16	*ib_pdata;			/* Zeiger auf das Icon-Bild      */
	char	*ib_ptext;			/* Zeiger auf einen String       */
	int16	ib_char;				/* In den unteren 8 Bit das dar- */
									/* zustellende Zeichen, in den   */
									/* oberen 8 Bit die Farbe des    */
									/* gesetzten (obere 4 Bit) und   */
									/* des gelîschten (untere 4 Bit) */
									/* Bits des Bitmuster IB_PDATA   */
	int16	ib_xchar;			/* x-Koordinate des Buchstabens  */
	int16	ib_ychar;			/* y-Koordinate des Buchstabens  */
	int16	ib_xicon;			/* x-Koordinate des Icons        */
	int16	ib_yicon;			/* y-Koordinate des Icons        */
	int16	ib_wicon;			/* Breite des Icons              */
	int16	ib_hicon;			/* Hîhe des Icons                */
	int16	ib_xtext;			/* x-Koordinate des Textes       */
	int16	ib_ytext;			/* y-Koordinate des Textes       */
	int16	ib_wtext;			/* Breite des Textes             */
	int16	ib_htext;			/* Hîhe des Textes               */
} ICONBLK;

/******************************************************************************/

/* Farb-Icon-Struktur */
typedef struct cicon_data
{
	int16 num_planes;
	int16 *col_data;
	int16 *col_mask;
	int16 *sel_data;
	int16 *sel_mask;
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
typedef struct bit_block
{
	int16	*bi_pdata;		/* Zeiger auf die Grafikdaten    */
	int16	bi_wb;			/* Breite des Bildes in Bytes    */
	int16	bi_hl;			/* Hîhe in Linien                */
	int16	bi_x;				/* x-Position                    */
	int16	bi_y;				/* y-Position                    */
	int16	bi_color;		/* Vordergrundfarbe              */
} BITBLK;

/******************************************************************************/

/* Die USERBLK-Struktur (ACS verwendet stattdessen die AUSERBLK-Struktur!) */
#ifndef __STDC__	/* Struktur nicht unter ANSI-C */
	typedef struct user_block
	{
		int16 CDECL (*ub_code)(struct parm_block *pb);	/* Zeiger auf die Zeichen-Funktion */
		int32	ub_parm;												/* Optionaler Parameter            */
	} USERBLK;
#endif

/******************************************************************************/

/* Die AUSERBLK-Struktur (wird von ACS anstelle USERBLK verwendet) */
#ifndef __STDC__	/* Struktur nicht unter ANSI-C */
	typedef struct auser_block
	{
		int16 CDECL (*ub_code)(struct parm_block *pb);	/* Zeichenroutine         */
		int32	ub_parm;												/* Optionaler Parameter   */
		int16 (*ub_serv)(struct object *entry,				/* Service-Routine des    */
						int16 task, void *in_out);				/* Userdefs               */
		void	*ub_ptr1;											/* Userzeiger (Daten)     */
		void	*ub_ptr2;											/* Userzeiger (Fenster)   */
		void	*ub_ptr3;											/* Userzeiger (obnr)      */
		char	*bubble;												/* BubbleGEM-Hilfe-String */
		char	*context;											/* Context-Popup-String   */
	} AUSERBLK;
#endif

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

/* Alias-Name der Struktur */
#define BFOBSPEC	bfobspec

/******************************************************************************/

/* Die verschiedenen Mîglichkeiten der Komponente ob_spec in OBJECT */
typedef union obspecptr
{
	int32		index;				/* fÅr das RSC-C-output      */
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
typedef struct object
{
	int16 ob_next;
	int16 ob_head;
	int16 ob_tail;
	uint16 ob_type;
	uint16 ob_flags;
	uint16 ob_state;
	OBSPEC ob_spec;
	int16 ob_x;
	int16 ob_y;
	int16 ob_width;
	int16 ob_height;
} OBJECT;

/******************************************************************************/

/* Die PARMBLK-Struktur (fÅr UserDefs USERDEF & AUSERDEF wichtig!) */
typedef struct parm_block
{
	OBJECT	*pb_tree;		/* Zeiger auf den Objektbaum       */
	int16		pb_obj;			/* Nummer des Objekts              */
	int16		pb_prevstate;	/* Vorheriger Objektstatus         */
	int16		pb_currstate;	/* Neuer Objektstatus              */
	int16		pb_x;				/* Objektkoordinaten               */
	int16		pb_y;				/*      -"-                        */
	int16		pb_w;				/*      -"-                        */
	int16		pb_h;				/*      -"-                        */
	int16		pb_xc;			/* Clipping-Koordinaten            */
	int16		pb_yc;			/*      -"-                        */
	int16		pb_wc;			/*      -"-                        */
	int16		pb_hc;			/*      -"-                        */
	int32		pb_parm;			/* Optionale Parameter aus USERBLK */
} PARMBLK;

/******************************************************************************/

/* Datentyp fÅr die Funktionszeiger der Klick- & Drag-Routinen in ACS */
typedef void (*Aaction)(void);

/******************************************************************************/

/* Die AOBJECT-Struktur fÅr die ACS-Erweiterungen */
typedef struct __aobject
{
	Aaction click;		/* Klick-Routine                      */
	Aaction drag;		/* Drag-Routine                       */
	int16 ob_flags;	/* ob_flags wie im OBJECT zuvor       */
							/* ACHTUNG: muû an gleicher Position  */
							/*          sein, wird geprÅft!       */
	int16 key;			/* TastenkÅrzel                       */
	void *userp1;		/* Userzeiger 1                       */
	void *userp2;		/* Userzeiger 2                       */
	int16 mo_index;	/* Index der Mausform Åber diesem Obj */
	int16 type;			/* ACS-Objekt-Typ                     */
} AOBJECT;

/******************************************************************************/

/* Zusammenfassung OBJECT und AOBJECT */
typedef union
{
	OBJECT obj;
	AOBJECT aobj;
} GEMObject;

/******************************************************************************/

/* Struktur fÅr de Mausform */
typedef struct mfstr
{
	int16 mf_xhot;
	int16 mf_yhot;
	int16 mf_nplanes;
	int16 mf_fg;
	int16 mf_bg;
	int16 mf_mask[16];
	int16 mf_data[16];
} MFORM;

/******************************************************************************/

#if defined(_ACS_OLGA_) || (!defined(OLGA_H) && !defined(__olga_t__))
	#define OLGA_H
	#define __olga_t__
	#define _ACS_OLGA_
	
	typedef struct
	{
		int16 x;
		int16 y;
		int16 w;
		int16 h;
		int16 x1;
		int16 y1;
		int16 x2;
		int16 y2;
	} OLGARect;

	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct
	{
		int32		magic;
		uint16	version;
		uint16	skip;
	} OLGAInfHeader;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
		
	typedef struct
	{
		int32 id;
		int32 length;
	} OLGABlockHeader;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct
	{
		int16 Red;
		int16 Green;
		int16 Blue;
	} OLGARGB;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct
	{
		int     Count;
		OLGARGB Colors[];
	} OLGAColorTable;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	struct _OLGAObjectInfo;
	
	typedef void cdecl (*OlgaDraw)(struct _OLGAObjectInfo *objectinfo, int16 outScreen,
							int16 outHandle, int16 outDevID, OLGARect *Size, OLGARect *Clip);
	typedef void cdecl (*OlgaUnembed)(struct _OLGAObjectInfo *objectinfo);
	typedef void cdecl (*OlgaXDraw)(struct _OLGAObjectInfo *objectinfo, int16 outScreen,
							int16 outHandle, int16 outDevID, OLGARect *Size, OLGARect *Clip,
							int32 Width_mm1000, int32 Height_mm1000, int32 Scale);

	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct _OLGAObjectInfo
	{
		char				*Filename;
		AESPB				*ClientGEMPB;
		int32				ClientData;
		int32				ServerData;
		int16				CBLock;
		int16				CBCount;
		OlgaDraw			CBDraw;
		OlgaUnembed		CBUnembed;
		OlgaXDraw		CBXDraw;
		OLGAColorTable	*cbColorTable;
		int16				cbClientID;
		int16				cbServerID;
		/* IE */
	} OLGAObjectInfo;
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	typedef struct
	{
		int32				len;
		int16				wHandle;
		int16				kShift;
		OLGARect			*Size;
		OLGAObjectInfo	*objectinfo;
	} OLGAIEInfo;
	
#endif

/******************************************************************************/

/* Struktur der Ereignisse (fÅr appl_tplay und appl_trecord) */
typedef struct
{
	int32 type;
	int32 what;
} APPLRECORD;

/******************************************************************************/

/* Input-Struktur fÅr evnt_event */
/* (ein evnt_multi-Binding ohne  */
/* groûes Parameter-Kopieren)    */
typedef struct
{
	int16 ev_mflags;
	int16 ev_mbclicks;
	int16 ev_mbmask;
	int16 ev_mbstate;
	int16 ev_mm1flags;
	GRECT xywh1;
	int16 ev_mm2flags;
	GRECT xywh2;
	int16 reserved;
	uint32 ev_mtcount;
	int16 ev_mmgpbuff[8];
	int16 ev_mwhlpbuff[16];
} MultiEventIn;

/******************************************************************************/

/* Output-Struktur fÅr evnt_event */
/* (ein evnt_multi-Binding ohne   */
/* groûes Parameter-Kopieren)     */
typedef struct
{
	int16 reserved;
	int16 ev_mmox;
	int16 ev_mmoy;
	int16 ev_mmbutton;
	int16 ev_mmokstate;
	int16 ev_mkreturn;
	int16 ev_mbreturn;
} MultiEventOut;

/******************************************************************************/

typedef struct
{
	int16 mwhich;         /* Art der Ereignisse */
	int16 mx;             /* x-Koordinate des Mauszeigers */
	int16 my;             /* y-Koordinate des Mauszeigers */
	int16 mbutton;        /* gedrÅckte Maustaste */
	int16 kstate;         /* Status der Sondertasten (kbshift) */
	int16 key;            /* Scancode der gedrÅckten Taste */
	int16 mclicks;        /* Anzahl der Mausklicks */
	int16 reserved[9];    /* reserviert */
	int16 msg[16];        /* Message-Buffer */
} EVNT;

/******************************************************************************/

/* FÅr den optimierten Aufruf EventMulti von evnt_multi von Pure-C */
typedef struct
{
	/* Input-Parameter */
	int16 ev_mflags;
	int16 ev_mbclicks;
	int16 ev_bmask;
	int16 ev_mbstate;
	int16 ev_mm1flags;
	int16 ev_mm1x;
	int16 ev_mm1y;
	int16 ev_mm1width;
	int16 ev_mm1height;
	int16 ev_mm2flags;
	int16 ev_mm2x;
	int16 ev_mm2y;
	int16 ev_mm2width;
	int16 ev_mm2height;
	int16 ev_mtlocount;
	int16 ev_mthicount;
	
	/* Output-Parameter */
	int16	ev_mwich;
	int16 ev_mmox;
	int16 ev_mmoy;
	int16 ev_mmobutton;
	int16 ev_mmokstate;
	int16 ev_mkreturn;
	int16 ev_mbreturn;
	
	/* Der Message-Puffer */
	int16 ev_mmgpbuf[8];
} EVENT;

/******************************************************************************/

/* Struktur fÅr menu_attach */
typedef struct
{
	OBJECT *mn_tree;
	int16	mn_menu;
	int16	mn_item;
	int16	mn_scroll;
	int16	mn_keystate;
} MENU;

/******************************************************************************/

/* MenÅ-Einstellungen (fÅr menu_settings) */
typedef struct
{
	int32 display;
	int32 drag;
	int32 delay;
	int32 speed;
	int16 height;
} MN_SET;

/******************************************************************************/

typedef struct
{
	char *string;				/* etwa "TOS|KAOS|MAG!X"          */
	int16 num;					/* Nr. der aktuellen Zeichenkette */
	int16 maxnum;				/* maximal erlaubtes <num>        */
} SWINFO;

/******************************************************************************/

typedef struct
{
	OBJECT *tree;				/* Popup- MenÅ                    */
	int16 obnum;				/* aktuelles Objekt von <tree>    */
} POPINFO;

/******************************************************************************/

/* Struktur fÅr erweiterte Start-Daten (fÅr shel_write) */
typedef struct
{
	char *newcmd;
	int32 psetlimit;
	int32 prenice;
	char *defdir;
	char *env;
} SHELW;

/* Andere Definition dafÅr (aus MagiC-Doku) */
typedef struct
{
	char	*command;
	int32	limit;
	int32	nice;
	char	*defdir;
	char	*env;
} XSHW_COMMAND;

/******************************************************************************/

typedef struct
{
	int32	CDECL (*proc)(void *par);
	void		*user_stack;
	uint32	stacksize;
	int16		mode;		/* immer auf 0 setzen! */
	int32		res1;		/* immer auf 0L setzen! */
} THREADINFO;

/******************************************************************************/

/* Header einer RSC-Datei */
typedef struct rshdr
{
	uint16 rsh_vrsn;
	uint16 rsh_object;
	uint16 rsh_tedinfo;
	uint16 rsh_iconblk;    /* list of ICONBLKS */
	uint16 rsh_bitblk;
	uint16 rsh_frstr;
	uint16 rsh_string;
	uint16 rsh_imdata;     /* image data */
	uint16 rsh_frimg;
	uint16 rsh_trindex;
	uint16 rsh_nobs;       /* counts of various structs */
	uint16 rsh_ntree;
	uint16 rsh_nted;
	uint16 rsh_nib;
	uint16 rsh_nbb;
	uint16 rsh_nstring;
	uint16 rsh_nimages;
	uint16 rsh_rssize;     /* total bytes in resource */
} RSHDR;

/******************************************************************************/

#ifndef GEMLIB_XATTR
	#if defined(__TOS) || defined(_file_h_) || defined (_filesys_h_)
		#define GEMLIB_XATTR XATTR
	#else
		#define GEMLIB_XATTR void
	#endif
#endif

/******************************************************************************/

/* Die Filter-Funktion fÅr fslx_open */
typedef int16 (cdecl XFSL_FILTER)(UCHAR *path, UCHAR *name, GEMLIB_XATTR *xa);

/* Filter-Funktion fÅr fsel_boxinput */
typedef void cdecl (*FSEL_CALLBACK)( int16 *msg );

/******************************************************************************/

/* FÅr die FNTS-Funktionen */
typedef void *FNT_DIALOG;

/* FÅr die LBOX-Funktionen */
typedef void *LIST_BOX;

typedef void *DIALOG;

typedef void *PRN_DIALOG;

typedef void *XEDITINFO;

/******************************************************************************/

/* FÅr die WDLG-Funktionen */
typedef short CDECL (*HNDL_OBJ)(DIALOG *dialog, EVNT *events, int16 obj,
										int16 clicks, void *data);
/******************************************************************************/

typedef void (CDECL *UTXT_FN)(int16 x, int16 y, int16 *clip_rect, 
							int32 id, int32 pt, int32 ratio, CHAR *string);

/******************************************************************************/

typedef struct _fnts_item
{
	struct	_fnts_item  *next;	/* Zeiger auf den nÑchsten Font oder 0L */
	UTXT_FN	display;					/* Anzeige-Funktion fÅr eigene Fonts    */
	int32		id;						/* ID des Fonts                         */
	int16		index;					/* muû 0 sein, da kein VDI-Font         */
	CHAR		mono;						/* Flag fÅr Ñquidistante Fonts          */
	CHAR		outline;					/* Flag fÅr Vektorfont                  */
	int16		npts;						/* Anzahl der vordefinierten Punkthîhen */
	CHAR		*full_name;				/* Zeiger auf den vollstÑndigen Namen   */
	CHAR		*family_name;			/* Zeiger auf den Familiennamen         */
	CHAR		*style_name;			/* Zeiger auf den Stilnamen             */
	CHAR		*pts;						/* Zeiger auf Feld mit Punkthîhen       */
	int32		reserved[4];			/* reserviert, mÅssen 0 sein            */
} FNTS_ITEM;

/******************************************************************************/

typedef struct _lbox_item
{
    struct _lbox_item *next;  /* Zeiger auf den nÑchsten Eintrag */
                              /* in der Scroll-Liste             */
 
    int16	selected;         /* Objekt selektiert?     */
    int16	data1;            /* Daten fÅr das Programm */
    void		*data2;
    void		*data3;
 
} LBOX_ITEM;

/******************************************************************************/

typedef void (cdecl *SLCT_ITEM)( LIST_BOX *box, OBJECT *tree, 
                                 LBOX_ITEM *item, 
                                 void *user_data, int16 obj_index,
                                 int16 last_state );
/******************************************************************************/

typedef int16 (cdecl *SET_ITEM)( LIST_BOX *box, OBJECT *tree, 
                                 LBOX_ITEM *item,
                                 int16 obj_index, void *user_data,
                                 GRECT *rect, int16 first );

/******************************************************************************/

/* "Forward-Deklarationen" fÅr die Druckdialoge */
struct _pdlg_sub;
struct _prn_entry;
struct _prn_settings;
struct _drv_entry;

/******************************************************************************/

/* Typen der Funktionszeiger fÅr die Druckdialoge */
typedef int32 (cdecl *PRN_SWITCH)( struct _drv_entry *drivers,
                                   struct _prn_settings *settings,
                                   struct _prn_entry *old_printer,
                                   struct _prn_entry *new_printer );

typedef int32 (cdecl *PDLG_INIT)( struct _prn_settings *settings,
                                  struct _pdlg_sub *sub );

typedef int32 (cdecl *PDLG_HNDL)( struct _prn_settings *settings,
                                  struct _pdlg_sub *sub, 
                                  int16 exit_obj );

typedef int32 (cdecl *PDLG_RESET)( struct _prn_settings *settings,
                                   struct _pdlg_sub *sub );

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _prn_settings
{
	int32	magic;				/* 'pset'                                 */
	int32	length;				/* (+) StrukturlÑnge                      */
	int32	format;				/* Strukturtyp                            */
	int32	reserved;			/* reserviert                             */
	
	int32	page_flags;			/* (+) Flags, u.a. gerade/ungerade Seiten */
									/* 0x0001 = nur Seiten mit gerader Nummer */
									/* 0x0002 = dto. mit ungeraden Nummern    */
	
	int16	first_page;			/* (+) erste zu druckende Seite (min.1)   */
	int16	last_page;			/* (+) dto. letzte Seite (max. 9999)      */
	int16	no_copies;			/* (+) Anzahl der Kopien                  */
	
	int16	orientation;		/* (+) Drehung                            */
									/* 0x0000 = Ausichtung unbekannt und      */
									/*          nicht verstellbar             */
									/* 0x0001 = Seite im Hochformat ausgeben  */
									/* 0x0002 = Seite im Querformat ausgeben  */
	
	int32	scale;				/* (+) Skalierung: 0x10000L = 100%        */
	int16	driver_id;			/* (+) VDI-GerÑtenummer                   */
	int16	driver_type;		/* Typ des eingestellten Treibers         */
	int32	driver_mode;		/* Flags, u.a. fÅr Hintergrunddruck       */
	int32	reserved1;			/* reserviert                             */
	int32	reserved2;			/* reserviert                             */
	
	int32	printer_id;			/* Druckernummer                          */
	int32	mode_id;				/* Modusnummer                            */
	int16	mode_hdpi;			/* horizontale Auflîsung in dpi           */
	int16	mode_vdpi;			/* vertikale Auflîsung in dpi             */
	int32	quality_id;			/* Druckmodus (hardwÑremÑûige QualitÑt,   */
									/* z.B. Microweave oder Econofast)        */
	
	int32	color_mode;			/* Farbmodus                              */
	int32	plane_flags;		/* Flags fÅr auszugebende Farbebenen      */
									/* (z.B. nur cyan)                        */
	int32	dither_mode;		/* Rasterverfahren                        */
	int32	dither_value;		/* Parameter fÅr das Rasterverfahren      */
	
	int32	size_id;				/* Papierformat                           */
	int32	type_id;				/* Papiertyp (normal, glossy)             */
	int32	input_id;			/* Papiereinzug                           */
	int32	output_id;			/* Papierauswurf                          */
	
	int32	contrast;			/* Kontrast:   0x10000L = normal          */
	int32	brightness;			/* Helligkeit: 0x1000L  = normal          */
	int32	reserved3;			/* reserviert                             */
	int32	reserved4;			/* reserviert                             */
	int32	reserved5;			/* reserviert                             */
	int32	reserved6;			/* reserviert                             */
	int32	reserved7;			/* reserviert                             */
	int32	reserved8;			/* reserviert                             */
	int8	device[128];		/* Dateiname fÅr den Ausdruck             */
	
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
	int32			length;				/* StrukturlÑnge                   */
	int32			format;				/* Datenformat                     */
	int32			reserved;			/* reserviert                      */
	
	void			*drivers;			/* nur fÅr interne Dialoge         */
	int16			option_flags;		/* verschiedene Flags              */
	int16			sub_id;				/* Kennung des Unterdialogs        */
	DIALOG		*dialog;				/* Zeiger auf die Struktur des     */
											/* Fensterdialogs oder 0L          */
	
	OBJECT		*tree;				/* Zeiger auf den Objektbaum       */
	int16			index_offset;		/* Offset des Unterdialogs         */
	int16			reserved1;			/* reserviert                      */
	int32			reserved2;			/* reserviert                      */
	int32			reserved3;			/* reserviert                      */
	int32			reserved4;			/* reserviert                      */
	
	PDLG_INIT	init_dlg;			/* Initialisierungsfunktion        */
	PDLG_HNDL	do_dlg;				/* Behandlungsfunktion             */
	PDLG_RESET	reset_dlg;			/* ZurÅcksetzfunktion              */
	int32			reserved5;			/* reserviert                      */
	
	OBJECT      *sub_icon;			/* Zeiger auf das Icon der Listbox */
	OBJECT      *sub_tree;			/* Objektbaum des Unterdialogs     */
	int32			reserved6;			/* reserviert                      */
	int32			reserved7;			/* reserviert                      */
	
	int32			private1;			/* dialogeigene Informationen-1    */
	int32			private2;			/* dialogeigene Informationen-2    */
	int32			private3;			/* dialogeigene Informationen-3    */
	int32			private4;			/* dialogeigene Informationen-4    */
} PDLG_SUB;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _media_type 
{
	struct _media_type   *next;	/* Zeiger auf Nachfolger     */
	int32			type_id;				/* Kennung des Papierformats */
	CHAR			name[32];			/* Name des Papierformats    */
} MEDIA_TYPE;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _media_size 
{
	struct _media_size *next;		/* Zeiger auf Nachfolger     */
	int32			size_id;				/* Kennung des Papierformats */
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
	int32			tray_id;				/* Nummer des Einzugs/Auswurfs */
	CHAR			name[32];			/* Name des Schachts           */
} PRN_TRAY;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _prn_mode
{
	struct _prn_mode *next;				/* Zeiger auf Nachfolger             */
	int32			mode_id;					/* Modus (Index innerhalb der Datei) */
	int16			hdpi;						/* horizontale Auflîsung in dpi      */
	int16			vdpi;						/* vertikale Auflîsung in dpi        */
	int32			mode_capabilities;	/* Moduseigenschaften                */
	
	int32			color_capabilities;	/* einstellbare Farbmodi             */
	int32			dither_flags;			/* Flags, die angeben, ob der        */
												/* korrespondierende Farbmodus mit   */
												/* oder ohne Dithern ansprechbar ist */
	
	MEDIA_TYPE	*paper_types;			/* geeignete Papiertypen             */
	int32			reserved;				/* reserviert                        */
	CHAR			name[32];				/* Modusname                         */
} PRN_MODE;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct _prn_entry 
{
	struct _prn_entry *next;				/* Zeiger auf Nachfolger           */
	int32			length;						/* StrukturlÑnge                   */
	int32			format;						/* Datenformat                     */
	int32			reserved;					/* reserviert                      */
	
	int16			driver_id;					/* Treiberkennung                  */
	int16			driver_type;				/* Treibertyp                      */
	int32			printer_id;					/* Druckerkennung                  */
	int32			printer_capabilities;	/* Druckereigenschaften            */
	int32			reserved1;					/* reserviert                      */
	
	int32			flags;						/* verschiedene Flags              */
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
	
	int32			length;				/* StrukturlÑnge             */
	int32			format;				/* Datenformat               */
	int32			reserved;			/* reserviert                */
	int32			dither_id;			/* Kennung                   */
	int32			color_modes;		/* unterstÅtzte Farbtiefen   */
	int32			reserved1;			/* reserviert                */
	int32			reserved2;			/* reserviert                */
	CHAR			name[32];			/* Name des Rasterverfahrens */
 
} DITHER_MODE;

/******************************************************************************/

/* Wird fÅr die Druckdialoge von WDialog benîtigt */
typedef struct
{
	int32			magic;					/* 'pdnf'                           */
	int32			length;					/* StrukturlÑnge                    */
	int32			format;					/* Datenformat                      */
	int32			reserved;				/* reserviert                       */
	
	int16			driver_id;				/* Treibernummer fÅrs VDI           */
	int16			driver_type;			/* Treibertyp                       */
	int32			reserved1;				/* reserviert                       */
	int32			reserved2;				/* reserviert                       */
	int32			reserved3;				/* reserviert                       */
	
	PRN_ENTRY	*printers;				/* zum Treiber gehîrenden Drucker   */
	DITHER_MODE	*dither_modes;			/* unterstÅtzte Rasterverfahren     */
	int32			reserved4;				/* reserviert                       */
	int32			reserved5;				/* reserviert                       */
	int32			reserved6;				/* reserviert                       */
	int32			reserved7;				/* reserviert                       */
	int32			reserved8;				/* reserviert                       */
	int32			reserved9;				/* reserviert                       */
	CHAR			device[128];			/* Ausgabedatei des Druckertreibers */
} DRV_INFO;

/******************************************************************************/

/* tail for default shell */
typedef struct
{
	int16	dummy;                   /* ein Nullwort               */
	int32	magic;                   /* 'SHEL', wenn ist Shell     */
	int16	isfirst;                 /* erster Aufruf der Shell    */
	int32	lasterr;                 /* letzter Fehler             */
	int16	wasgr;                   /* Programm war Grafikapp.    */
} SHELTAIL;

/******************************************************************************/

/* Zuordnung Scancode -> Objektnummer mit Anzahl Klicks der FlyDials unter MagiC */
typedef struct
{
	int8	scancode;
	int8	nclicks;
	int16	objnr;
} SCANX;

/******************************************************************************/

/* Scancode-Tabellen der FlyDials unter MagiC */
typedef struct
{
	SCANX *unsh;	/* Tabellen fÅr UnShift-Kombinationen   */
	SCANX *shift;	/* Tabellen fÅr Shift-Kombinationen     */
	SCANX *ctrl;	/* Tabellen fÅr Control-Kombinationen   */
	SCANX *alt;		/* Tabellen fÅr Alternate-Kombinationen */
	void  *resvd;	/* reserviert */
} XDO_INF;

/******************************************************************************/

/* Scrollable textedit objects */
typedef struct _xted
{
	char	*xte_ptmplt;
	char	*xte_pvalid;
	WORD	xte_vislen;
	WORD	xte_scroll;
} XTED;

/******************************************************************************/
/*																										*/
/* Die VDI-Include-Datei wird nun benîtigt												*/
/*	Diese kann erst hier eingelesen werden, da dort auf vorstehende Strukturen	*/
/* verwiesen wird!																				*/
/*																										*/
/******************************************************************************/

#include <ACSVDI.H>

/******************************************************************************/
/*																										*/
/* Prototyp der Assembler-Routine															*/
/*	Diese macht den AES-Aufruf und setzt den dazu nîtigen AES-Parameterblock	*/
/* auf dem Stack zusammen - das ist etwas multithreading freundlicher... ;-)	*/
/*																										*/
/******************************************************************************/

void CDECL aes( int16 *contrl, GlobalArray *global, int16 *intin, int16 *intout,
          void *addrin, void *addrout );

/******************************************************************************/

/* Die Routine aus Pure-C ist natÅrlich auch vorhanden */
void _crystal( AESPB *pb );

/******************************************************************************/
/*																										*/
/* Die APPL-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_init( GlobalArray *globl );
int16 mt_appl_read( const int16 rwid, const int16 length, void *pbuff, GlobalArray *globl );
int16 mt_appl_write( const int16 rwid, const int16 length, void *pbuff, GlobalArray *globl );
int16 mt_appl_find( char *pname, GlobalArray *globl );
int16 mt_appl_search( const int16 mode, char *fname, int16 *type, int16 *ap_id,
				GlobalArray *globl );
int16 mt_appl_tplay( APPLRECORD *tbuffer, const int16 tlength, const int16 tscale,
				GlobalArray *globl );
int16 mt_appl_trecord( APPLRECORD *tbuffer, const int16 tlength, GlobalArray *globl );
int16 mt_appl_bvset( const uint16 bvdisk, const uint16 bvhard, GlobalArray *globl );
int16 mt_appl_yield( GlobalArray *globl );
int16 mt_appl_exit( GlobalArray *globl );
int16 mt_appl_getinfo( const int16 type, int16 *out1, int16 *out2, int16 *out3, int16 *out4,
				GlobalArray *globl );
int16 mt_appl_getinfo_str( const int16 mode, char *str1, char *str2, char *str3, char *str4,
				GlobalArray *globl );
int16 mt_appl_control( const int16 ap_cid, const int16 ap_cwhat, void *ap_cout,
				GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die EVNT-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_keybd( GlobalArray *globl );
int16 mt_evnt_button( const int16 ev_bclicks, const uint16 ev_bmask,
				const uint16 ev_bstate, int16 *ev_bmx, int16 *ev_bmy, int16 *ev_bbutton,
				int16 *ev_bkstate, GlobalArray *globl );
int16 mt_evnt_xbutton( const int16 ev_bclicks, const uint16 ev_bmask,
				const uint16 ev_bstate, int16 *ev_bmx, int16 *ev_bmy, int16 *ev_bbutton,
				int16 *ev_bkstate, int16 *ev_bwhlpbuff, GlobalArray *globl );
int16 mt_evnt_mouse( const int16 ev_moflags, const int16 ev_mox,
				const int16 ev_moy, const int16 ev_mowidth, const int16 ev_moheight,
				int16 *ev_momx, int16 *ev_momy, int16 *ev_mobutton, int16 *ev_mokstate,
				GlobalArray *globl );
int16 mt_evnt_mesag( int16 *pbuff, GlobalArray *globl );
int16 mt_evnt_timer( const uint32 count, GlobalArray *globl );
int16 mt_evnt_multi( const int16 ev_mflags, const int16 ev_mbclicks, const int16 ev_mbmask,
				const int16 ev_mbstate, const int16 ev_mm1flags, const int16 ev_mm1x,
				const int16 ev_mm1y, const int16 ev_mm1width, const int16 ev_mm1height,
				const int16 ev_mm2flags, const int16 ev_mm2x, const int16 ev_mm2y,
				const int16 ev_mm2width, const int16 ev_mm2height, int16 *ev_mmgpbuff,
				const int32 ev_mtimer, int16 *ev_mmox, int16 *ev_mmoy, int16 *ev_mmbutton,
				int16 *ev_mmokstate, int16 *ev_mkreturn, int16 *ev_mbreturn, GlobalArray *globl );
int16 mt_evnt_xmulti( const int16 ev_mflags, const int16 ev_mbclicks, const int16 ev_mbmask,
				const int16 ev_mbstate, const int16 ev_mm1flags, const int16 ev_mm1x,
				const int16 ev_mm1y, const int16 ev_mm1width, const int16 ev_mm1height,
				const int16 ev_mm2flags, const int16 ev_mm2x, const int16 ev_mm2y,
				const int16 ev_mm2width, const int16 ev_mm2height, int16 *ev_mmgpbuff,
				const int32 ev_mtimer, int16 *ev_mmox, int16 *ev_mmoy, int16 *ev_mmbutton,
				int16 *ev_mmokstate, int16 *ev_mkreturn, int16 *ev_mbreturn, int16 *ev_mwhlpbuff,
				GlobalArray *globl );
int16 mt_evnt_dclick( const int16 rate, const int16 setit, GlobalArray *globl );

/* Eigener optimierter Aufruf */
int16 mt_evnt_event( MultiEventIn *input, MultiEventOut *output, GlobalArray *globl );

/* Optimierter, Pure-C kompatibler Aufruf */
int16 mt_EvntMulti( EVENT *evnt_data, GlobalArray *globl);

/******************************************************************************/
/*																										*/
/* Die MENU-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_menu_bar( OBJECT *tree, const int16 show, GlobalArray *globl );
int16 mt_menu_icheck( OBJECT *tree, const int16 item, const int16 check, GlobalArray *globl );
int16 mt_menu_ienable( OBJECT *tree, const int16 item, const int16 enable,
				GlobalArray *globl );
int16 mt_menu_tnormal( OBJECT *tree, const int16 title, const int16 normal,
				GlobalArray *globl );
int16 mt_menu_text( OBJECT *tree, const int16 item, char *text, GlobalArray *globl );
int16 mt_menu_register( const int16 apid, char *string, GlobalArray *globl );
int16 mt_menu_unregister( const int16 apid, GlobalArray *globl );
int16 mt_menu_click( const int16 click, const int16 setit, GlobalArray *globl );
int16 mt_menu_attach( const int16 flag, OBJECT *tree, const int16 item, MENU *mdata,
				GlobalArray *globl );
int16 mt_menu_istart( const int16 flag, OBJECT *tree, const int16 imenu, const int16 item,
			GlobalArray *globl );
int16 mt_menu_popup( MENU *menu, const int16 xpos, const int16 ypos, MENU *mdata,
			GlobalArray *globl );
int16 mt_menu_settings( const int16 flag, MN_SET *set, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die OBJC-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_add( OBJECT *tree, const int16 parent, const int16 child,
				GlobalArray *globl );
int16 mt_objc_delete( OBJECT *tree, const int16 objnr, GlobalArray *globl );
int16 mt_objc_draw( OBJECT *tree, const int16 start, const int16 depth,
				const int16 xclip, const int16 yclip, const int16 wclip, const int16 hclip,
				GlobalArray *globl );
int16 mt_objc_find( OBJECT *tree, const int16 start, const int16 depth,
				const int16 mx, const int16 my, GlobalArray *globl );
int16 mt_objc_offset( OBJECT *tree, const int16 objnr, int16 *x, int16 *y,
				GlobalArray *globl );
int16 mt_objc_order( OBJECT *tree, const int16 objnr, const int16 new_nr,
				GlobalArray *globl );
int16 mt_objc_edit( OBJECT *tree, const int16 objnr, const int16 inchar,
				int16 *idx, const int16 kind, GlobalArray *globl );
int16 mt_objc_xedit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				int16 kind, GRECT *r, GlobalArray *globl );
int16 mt_objc_change( OBJECT *tree, const int16 objnr, const int16 reserved, 
				const int16 xclip, const int16 yclip, const int16 wclip, const int16 hclip,
				const int16 newstate, const int16 redraw, GlobalArray *globl );
int16 mt_objc_sysvar( const int16 mode, const int16 which, const int16 in1, const int16 in2,
				int16 *out1, int16 *out2, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* OBJC-Erweiterungen von MagiC																*/
/*																										*/
/******************************************************************************/

/* Zuerst die "richtige" Multithreading-Variante */
void mt_objc_wdraw( OBJECT *tree, const int16 start, const int16 depth, GRECT *clip,
				const int16 whandle, GlobalArray *globl );
int16 mt_objc_wedit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				const int16 kind, const int16 whandle, GlobalArray *globl );
void mt_objc_wchange( OBJECT *tree, const int16 objnr, const int16 newstate,
				GRECT *clip, const int16 whandle, GlobalArray *globl );
int16 mt_objc_xfind( OBJECT *obj, const int16 start, const int16 depth,
				const int16 x, const int16 y, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die FORM-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_do( OBJECT *tree, const int16 start, GlobalArray *globl );
int16 mt_form_dial( const int16 flag, const int16 xlittle,
				const int16 ylittle, const int16 wlittle, const int16 hlittle,
				const int16 xbig, const int16 ybig, const int16 wbig, const int16 hbig,
				GlobalArray *globl );
int16 mt_form_alert( const int16 defbutton, char *string, GlobalArray *globl );
int16 mt_form_error( const int16 errnum, GlobalArray *globl );
int16 mt_form_center( OBJECT *tree, int16 *x, int16 *y, int16 *w, int16 *h,
				GlobalArray *globl );
int16 mt_form_keybd( OBJECT *tree, const int16 obj, const int16 next,
				const int16 input_char, int16 *next_obj, int16 *pchar, GlobalArray *globl );
int16 mt_form_button( OBJECT *tree, const int16 obj, const int16 clicks, int16 *next_obj,
				GlobalArray *globl );
int16 mt_form_popup( OBJECT *tree, const int16 x, const int16 y, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die FlyDials-Funktionen aus MagiC														*/
/*																										*/
/******************************************************************************/

int16 mt_form_wbutton( const OBJECT *fo_btree, const int16 fo_bobject,
				const int16 fo_bclicks, int16 *fo_bnxtobj, const int16 whandle,
				GlobalArray *globl );
int16 mt_form_xdial( const int16 fo_diflag, const int16 fo_dilittlx, const int16 fo_dilittly, 
				const int16 fo_dilittlw, const int16 fo_dilittlh, const int16 fo_dibigx,
				const int16 fo_dibigy, const int16 fo_dibigw, const int16 fo_dibigh, 
				void **flydial, GlobalArray *globl );
int16 mt_form_xdo( const OBJECT *tree, const int16 startob, int16 *lastcrsr,
				const XDO_INF *tabs, void *flydial, GlobalArray *globl );
int16 mt_form_xerr( const int32 errcode, int8 *errfile, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die GRAF-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_graf_rubbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end, GlobalArray *globl );
int16 mt_graf_dragbox( const int16 w, const int16 h, const int16 sx, const int16 sy,
				const int16 xc, const int16 yc, const int16 wc, const int16 hc,
				int16 *x, int16 *y, GlobalArray *globl );
int16 mt_graf_mbox( const int16 w, const int16 h, int16 const start_x,	const int16 start_y,
				const int16 ende_x, const int16 ende_y, GlobalArray *globl );
int16 mt_graf_movebox( const int16 w, const int16 h, const int16 start_x, const int16 start_y,
				int16 const ende_x, int16 const ende_y, GlobalArray *globl );
int16 mt_graf_growbox( const int16 start_x, const int16 start_y,	const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h, GlobalArray *globl );
int16 mt_graf_shrinkbox( const int16 start_x, const int16 start_y, const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h, GlobalArray *globl );
int16 mt_graf_watchbox( OBJECT *tree, const int16 obj_nr, const int16 instate,
				const int16 outstate, GlobalArray *globl );
int16 mt_graf_slidebox( OBJECT *tree, const int16 parent, const int16 obj_nr,
				const int16 isvert, GlobalArray *globl );
int16 mt_graf_handle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox,
				GlobalArray *globl );
int16 mt_graf_mouse( const int16 mouse_nr, MFORM *form, GlobalArray *globl );
int16 mt_graf_mkstate( int16 *x, int16 *y, int16 *mstate, int16 *kstate, GlobalArray *globl );
int16 mt_graf_multirubber( const int16 x, const int16 y, const int16 minw, const int16 minh,
				GRECT *rec, int16 *outw, int16 *outh, GlobalArray *globl );

/* Andere Namen von graf_rubbox */
#ifndef __COMPATIBLE_FKT__
	#define mt_graf_rubbbox(x, y, w_min, h_min, w_end, h_end, globl) \
																mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, globl)
	#define mt_graf_rubberbox(x, y, w_min, h_min, w_end, h_end, globl) \
																mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, globl)
#else
	int16 mt_graf_rubbbox( const int16 x, const int16 y, const int16 w_min,
					const int16 h_min, int16 *w_end, int16 *h_end, GlobalArray *globl );
	int16 mt_graf_rubberbox( const int16 x, const int16 y, const int16 w_min,
					const int16 h_min, int16 *w_end, int16 *h_end, GlobalArray *globl );
#endif

/******************************************************************************/
/*																										*/
/* GRAF-Erweiterungen von MagiC																*/
/*																										*/
/******************************************************************************/

int16 mt_graf_wwatchbox( const OBJECT *gr_wptree, const int16 gr_wobject,
				const int16 gr_winstate, const int16 gr_woutstate, const int16 whandle,
				GlobalArray *globl );
int16 mt_graf_xhandle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox, int16 *device,
				GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die SCRP-Funktionen																			*/
/*																										*/
/******************************************************************************/

/* Zuerst die "richtige" Multithreading-Variante */
int16 mt_scrp_read( char *pathname, GlobalArray *globl );
int16 mt_scrp_write( char *pathname, GlobalArray *globl );
int16 mt_scrp_clear( GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die FSEL-Funktionen																			*/
/*																										*/
/******************************************************************************/

/* Zuerst die "richtige" Multithreading-Variante */
int16 mt_fsel_input( char *path, char *name, int16 *button, GlobalArray *globl );
int16 mt_fsel_exinput( char *path, char *name, int16 *button, const char *label,
				GlobalArray *globl );
int16 mt_fsel_boxinput( char *path, char *name, int *button,
				const char *label, FSEL_CALLBACK callback, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die FSLX-Funktionen (MagiC)																*/
/*																										*/
/******************************************************************************/

void *mt_fslx_open( char *title, const int16 x, const int16 y, int16 *handle, char *path,
				const int16 pathlen, char *fname, const int16 fnamelen, char *patterns,
				XFSL_FILTER *filter, char *paths, const int16 sort_mode, const int16 flags,
				GlobalArray *globl );
int16 mt_fslx_close( void *fsd, GlobalArray *globl );
int16 mt_fslx_getnxtfile( void *fsd, char *fname, GlobalArray *globl );
int16 mt_fslx_evnt( void *fsd, EVNT *events, char *path, char *fname, int16 *button,
			int16 *nfiles, int16 *sort_mode, char **pattern, GlobalArray *globl );
void *mt_fslx_do( char *title, char *path, const int16 pathlen, char *fname,
				const int16 fnamelen, char *patterns, XFSL_FILTER *filter, char *paths,
				int16 *sort_mode, const int16 flags, int16 *button, int16 *nfiles, char **pattern,
				GlobalArray *globl );
int16 mt_fslx_set_flags( const int16 flags, int16 *oldval, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die WIND-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_wind_create( const int16 kind, const int16 max_x, const int16 max_y,
				const int16 max_w, const int16 max_h, GlobalArray *globl );
int16 mt_wind_open( const int16 handle, const int16 x, const int16 y,
				const int16 w, const int16 h, GlobalArray *globl );
int16 mt_wind_close( const int16 handle, GlobalArray *globl );
int16 mt_wind_delete( const int16 handle, GlobalArray *globl );
int16 mt_wind_get( const int16 handle, const int16 what, int16 *out1, int16 *out2,
				int16 *out3, int16 *out4, GlobalArray *globl );
int16 mt_wind_get_grect( const int16 handle, int16 what, GRECT *r, GlobalArray *globl );int16 mt_wind_getQSB( const int16 handle, void **buffer, int32 *length, GlobalArray *globl );
int16 mt_wind_xget_grect( const int16 handle, int16 what, const GRECT *clip, GRECT *r, GlobalArray *globl );
int16 mt_wind_set( const int16 handle, const int16 what, const int16 val1, const int16 val2,
				const int16 val3, const int16 val4, GlobalArray *globl );
int16 mt_wind_setGRECT( const int16 handle, const int16 what, const GRECT *xywh,
				GlobalArray *globl );
int16 mt_wind_find( const int16 x, const int16 y, GlobalArray *globl );
int16 mt_wind_update( const int16 what, GlobalArray *globl );
int16 mt_wind_calc( const int16 wtype, const int16 kind, const int16 x, const int16 y,
				const int16 w, const int16 h, int16 *px, int16 *py, int16 *pw, int16 *ph,
				GlobalArray *globl );
int16 mt_wind_calcGRECT( const int16 wtype, const int16 kind, const GRECT *input,
				GRECT *output, GlobalArray *globl );
int16 mt_wind_new( GlobalArray *globl );
int16 mt_wind_draw( const int16 handle, const int16 startob, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die RSRC-Funktionen																			*/
/*																										*/
/******************************************************************************/

/* Zuerst die "richtige" Multithreading-Variante */
int16 mt_rsrc_load( char *name, GlobalArray *globl );
int16 mt_rsrc_free( GlobalArray *globl );
int16 mt_rsrc_gaddr( const int16 type, const int16 id, void *addr, GlobalArray *globl );
int16 mt_rsrc_saddr( const int16 type, const int16 id, void *addr, GlobalArray *globl );
int16 mt_rsrc_obfix( OBJECT *tree, const int16 obj, GlobalArray *globl );
int16 mt_rsrc_rcfix( void *rc_header, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die SHEL-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_read( char *cmd, char *tail, GlobalArray *globl );
int16 mt_shel_write( const int16 do_execute, const int16 is_graph, const int16 is_overlay,
				char *cmd, char *tail, GlobalArray *globl );
int16 mt_shel_get( char *addr, const int16 len, GlobalArray *globl );
int16 mt_shel_put( char *addr, const int16 len, GlobalArray *globl );
int16 mt_shel_find( char *path, GlobalArray *globl );
int16 mt_shel_envrn( char **value, char *name, GlobalArray *globl );
int16 mt_shel_rdef( char *cmd, char *dir, GlobalArray *globl );
int16 mt_shel_wdef( char *cmd, char *dir, GlobalArray *globl );
int16 mt_shel_help( const int16 sh_hmode, char *sh_hfile, char *sh_hkey,
				GlobalArray *globl );

/* Andere Schreibweise */
#define mt_shel_environ(value, name, globl)	mt_shel_envrn(value, name, globl)

/******************************************************************************/
/*																										*/
/* Die FNTS-Funktionen (WDialog)																*/
/*																										*/
/******************************************************************************/

int16 mt_fnts_add( const FNT_DIALOG *fnt_dialog, const FNTS_ITEM *user_fonts,
				GlobalArray *globl );
int16 mt_fnts_close( const FNT_DIALOG *fnt_dialog, int16 *x, int16 *y,
				GlobalArray *globl );
FNT_DIALOG *mt_fnts_create( const int16 vdi_handle, const int16 no_fonts,
				const int16 font_flags, const int16 dialog_flags,
				const char *sample, const char *opt_button, GlobalArray *globl );
int16 mt_fnts_delete( const FNT_DIALOG *fnt_dialog, const int16 vdi_handle,
				GlobalArray *globl );
int16 mt_fnts_do( FNT_DIALOG *fnt_dialog, const int16 button_flags, const int32 id_in,
				const fix31 pt_in, const int32 ratio_in, int16 *check_boxes, 
				int32 *id, fix31 *pt, fix31 *ratio, GlobalArray *globl );
int16 mt_fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, int16 *button,
				int16 *check_boxes, int32 *id, fix31 *pt, fix31 *ratio, GlobalArray *globl );
int16 mt_fnts_get_info( FNT_DIALOG *fnt_dialog, const int32 id, int16 *mono,
				int16 *outline, GlobalArray *globl );
int16 mt_fnts_get_name( FNT_DIALOG *fnt_dialog, const int32 id, CHAR *full_name,
				char *family_name, char *style_name, GlobalArray *globl );
int16 mt_fnts_get_no_styles( FNT_DIALOG *fnt_dialog, const int32 id, GlobalArray *globl );
int32 mt_fnts_get_style( FNT_DIALOG *fnt_dialog, const int32 id, const int16 index,
				GlobalArray *globl );
int16 mt_fnts_open( FNT_DIALOG *fnt_dialog, const int16 button_flags, const int16 x,
				const int16 y, const int32 id, const fix31 pt, const fix31 ratio,
				GlobalArray *globl );
void mt_fnts_remove( FNT_DIALOG *fnt_dialog, GlobalArray *globl );
int16 mt_fnts_update( FNT_DIALOG *fnt_dialog, const int16 button_flags, const int32 id,
				const fix31 pt, const int32 ratio, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die LBOX-Funktionen (WDialog)																*/
/*																										*/
/******************************************************************************/

void mt_lbox_ascroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect, 
				GRECT *slider_rect, GlobalArray *globl );
void mt_lbox_scroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect,
				GRECT *slider_rect, GlobalArray *globl );
void mt_lbox_bscroll_to( LIST_BOX *box, const int16 first, GRECT *box_rect,
				GRECT *slider_rect, GlobalArray *globl );
int16 mt_lbox_cnt_items( LIST_BOX *box, GlobalArray *globl );
LIST_BOX *mt_lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set,
					LBOX_ITEM *items, const int16 visible_a, const int16 first_a,
					const int16 *ctrl_objs, const int16 *objs, const int16 flags, 
					const int16 pause_a, void *user_data, DIALOG *dialog,
					const int16 visible_b, const int16 first_b, const int16 entries_b, 
					const int16 pause_b, GlobalArray *globl );
int16 mt_lbox_delete( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_do( LIST_BOX *box, const int16 obj, GlobalArray *globl );
void mt_lbox_free_items( LIST_BOX *box, GlobalArray *globl );
void mt_lbox_free_list( LBOX_ITEM *items, GlobalArray *globl );
int16 mt_lbox_get_afirst( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_first( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_avis( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_visible( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_bentries( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_bfirst( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_bvis( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search,GlobalArray *globl );
LBOX_ITEM *mt_lbox_get_item( LIST_BOX *box, const int16 n, GlobalArray *globl );
LBOX_ITEM *mt_lbox_get_items( LIST_BOX *box, GlobalArray *globl );
int16 mt_lbox_get_slct_idx( LIST_BOX *box, GlobalArray *globl );
LBOX_ITEM *mt_lbox_get_slct_item( LIST_BOX *box, GlobalArray *globl );
OBJECT *mt_lbox_get_tree( LIST_BOX *box, GlobalArray *globl );
void *mt_lbox_get_udata( LIST_BOX *box, GlobalArray *globl );
void mt_lbox_set_asldr( LIST_BOX *box, const int16 first, GRECT *rect, GlobalArray *globl );
void mt_lbox_set_slider( LIST_BOX *box, const int16 first, GRECT *rect, GlobalArray *globl );
void mt_lbox_set_bentries( LIST_BOX *box, const int16 entries, GlobalArray *globl );
void mt_lbox_set_bsldr( LIST_BOX *box, const int16 first, GRECT *rect, GlobalArray *globl );
void mt_lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, GlobalArray *globl );
void mt_lbox_update( LIST_BOX *box, GRECT *rect, GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die PDLG-Funktionen (WDialog)																*/
/*																										*/
/******************************************************************************/

int16 mt_pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info, GlobalArray *globl );
int16 mt_pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialog,
				GlobalArray *globl );
int16 mt_pdlg_close( PRN_DIALOG *prn_dialog, int16 *x, int16 *y, GlobalArray *globl );
PRN_DIALOG *mt_pdlg_create( const int16 dialog_flags, GlobalArray *globl );
int16 mt_pdlg_delete( PRN_DIALOG *prn_dialog, GlobalArray *globl );
int16 mt_pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				GlobalArray *globl );
int16 mt_pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags, GlobalArray *globl );
int16 mt_pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events,
				int16 *button, GlobalArray *globl );
int16 mt_pdlg_free_settings( PRN_SETTINGS *settings, GlobalArray *globl );
int32 mt_pdlg_get_setsize( GlobalArray *globl );
PRN_SETTINGS *mt_pdlg_new_settings( PRN_DIALOG *prn_dialog, GlobalArray *globl );
int16 mt_pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name,
				const int16 option_flags, const int16 x, const int16 y, GlobalArray *globl );
int16 mt_pdlg_remove_printers( PRN_DIALOG *prn_dialog, GlobalArray *globl );
int16 mt_pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog, GlobalArray *globl );
int16 mt_pdlg_update( PRN_DIALOG *prn_dialog, char *document_name, GlobalArray *globl );
int16 mt_pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				GlobalArray *globl );
int16 mt_pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die WDLG-Funktionen (WDialog)																*/
/*																										*/
/******************************************************************************/

DIALOG *mt_wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, const int16 code,
				void *data, const int16 flags, GlobalArray *globl );
int16	mt_wdlg_open( DIALOG *dialog, char *title, const int16 kind, const int16 x,
				const int16 y, const int16 code, void *data, GlobalArray *globl );
int16 mt_wdlg_close( DIALOG *dialog, int16 *x, int16 *y, GlobalArray *globl );
int16 mt_wdlg_delete( DIALOG *dialog, GlobalArray *globl );
int16 mt_wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r, GlobalArray *globl );
int16 mt_wdlg_get_edit( DIALOG *dialog, int16 *cursor, GlobalArray *globl );
void *mt_wdlg_get_udata( DIALOG *dialog, GlobalArray *globl );
int16 mt_wdlg_get_handle( DIALOG *dialog, GlobalArray *globl );
int16 mt_wdlg_set_edit( DIALOG *dialog, const int16 obj, GlobalArray *globl );
int16 mt_wdlg_set_tree( DIALOG *dialog, OBJECT *new_tree, GlobalArray *globl );
int16 mt_wdlg_set_size( DIALOG *dialog, GRECT *new_size, GlobalArray *globl );
int16 mt_wdlg_set_iconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree,
				const int16 obj, GlobalArray *globl );
int16 mt_wdlg_set_uniconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree,
				GlobalArray *globl );
int16 mt_wdlg_evnt( DIALOG *dialog, EVNT *events, GlobalArray *globl );
void mt_wdlg_redraw( DIALOG *dialog, GRECT *rect, const int16 obj, const int16 depth,
				GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* Die EDIT-Funktionen (Scrollbare Edit-Felder ab MagiC 5.2)						*/
/*																										*/
/******************************************************************************/

XEDITINFO *mt_edit_create( GlobalArray *globl );
void mt_edit_set_buf( OBJECT *tree, const int16 obj, char *buffer, const int32 buflen,
				GlobalArray *globl );
int16 mt_edit_open( OBJECT *tree, const int16 obj, GlobalArray *globl );
void mt_edit_close( OBJECT *tree, const int16 obj, GlobalArray *globl );
void mt_edit_delete( XEDITINFO *editinfo, GlobalArray *globl );
int16 mt_edit_cursor( OBJECT *tree, const int16 obj, const int16 whdl, const int16 show,
				GlobalArray *globl );
int16 mt_edit_evnt( OBJECT *tree, const int16 obj, const int16 whdl, EVNT *events,
				int32 *errcode, GlobalArray *globl );
int16 mt_edit_get_buf( OBJECT *tree, const int16 obj, char **buffer, int32 *buflen,
				int32 *txtlen, GlobalArray *globl );
int16 mt_edit_get_format( OBJECT *tree, const int16 obj, int16 *tabwidth, int16 *autowrap,
				GlobalArray *globl );
int16 mt_edit_get_colour( OBJECT *tree, const int16 obj, int16 *tcolour, int16 *bcolour,
				GlobalArray *globl );
int16 mt_edit_get_font( OBJECT *tree, const int16 obj, int16 *fontID, int16 *fontH,
				boolean *fontPix, boolean *mono, GlobalArray *globl );
int16 mt_edit_get_cursor( OBJECT *tree, const int16 obj, char **cursorpos,
				GlobalArray *globl );
void mt_edit_get_pos( OBJECT *tree, const int16 obj, int16 *xscroll, int32 *yscroll,
				char **cyscroll, char **cursorpos, int16 *cx, int16 *cy, GlobalArray *globl );
boolean mt_edit_get_dirty( OBJECT *tree, const int16 obj, GlobalArray *globl );
void mt_edit_get_sel( OBJECT *tree, const int16 obj, char **bsel, char **esel,
				GlobalArray *globl );
void mt_edit_get_scrollinfo( OBJECT *tree, const int16 obj, int32 *nlines, int32 *yscroll,
				int16 *yvis, int16 *yval, int16 *ncols, int16 *xscroll, int16 *xvis,
				GlobalArray *globl );
void mt_edit_set_format( OBJECT *tree, const int16 obj, const int16 tabwidth,
				const int16 autowrap, GlobalArray *globl );
void mt_edit_set_colour( OBJECT *tree, const int16 obj, const int16 tcolour,
				const int16 bcolour, GlobalArray *globl );
void mt_edit_set_font( OBJECT *tree, const int16 obj, const int16 fontID, const int16 fontH,
				const boolean fontPix, const boolean mono, GlobalArray *globl );
void mt_edit_set_cursor( OBJECT *tree, const int16 obj, char *cursorpos, GlobalArray *globl );
void mt_edit_set_pos( OBJECT *tree, const int16 obj, const int16 xscroll,
				const int32 yscroll, char *cyscroll, char *cursorpos, const int16 cx,
				const int16 cy, GlobalArray *globl );
int16 mt_edit_resized( OBJECT *tree, const int16 obj, int16 *oldrh, int16 *newrh,
				GlobalArray *globl );
void mt_edit_set_dirty( OBJECT *tree, const int16 obj, const boolean dirty,
				GlobalArray *globl );
int16 mt_edit_scroll( OBJECT *tree, const int16 obj, const int16 whdl, const int32 yscroll,
				const int16 xscroll, GlobalArray *globl );

/* edit_get_colour = edit_get_color? Ein Schreibfeher in der MagiC-Dokumentation? */
int16 mt_edit_get_color( OBJECT *tree, const int16 obj, int16 *tcolor, int16 *bcolor,
				GlobalArray *globl );

/* edit_set_colour = edit_set_color? Ein Schreibfeher in der MagiC-Dokumentation? */
void mt_edit_set_color( OBJECT *tree, const int16 obj, const int16 tcolor, const int16 bcolor,
				GlobalArray *globl );

/******************************************************************************/
/*																										*/
/* NÅtzliche Erweiterungen																		*/
/*																										*/
/******************************************************************************/

int16 mt_wind_calc_grect( const int16 type, int16 parts, const GRECT *In, GRECT *Out, GlobalArray *globl );int16 mt_wind_create_grect( const int16 parts, const GRECT *r, short *global_aes);int16 mt_wind_open_grect( const int16 handle, const GRECT *r, GlobalArray *globl );int16 mt_wind_set_grect( const int16 handle, const int16 what, const GRECT *r, GlobalArray *globl );int16 mt_wind_xset_grect( const int16 handle, const int16 what, const GRECT *s, GRECT *r, GlobalArray *globl );int16 mt_wind_set_str( const int16 handle, const int16 what, const char *str, GlobalArray *globl );
/******************************************************************************/

#ifdef __cplusplus
}
#endif

/******************************************************************************/

#endif
