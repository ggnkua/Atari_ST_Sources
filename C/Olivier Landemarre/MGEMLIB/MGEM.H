/*
 * gem.h - main header file for new gem-lib
 TAB = 4
 */
#ifndef _GEMLIB_H_
#define _GEMLIB_H_
#ifndef __PUREC__
#include <compiler.h>
#endif
#include <portab.h>
#ifndef INT16
#define INT16 short
#endif
#define GEMLIB 39
#ifdef __GEMLIB_OLDBIND				/* Backward-compatibility */
#undef _GEMLIB_H_					/* For old bindings, these header had to be multi-included. */
#ifndef __GEMLIB_HAVE_DEFS			/* first include via aesbind/vdibind/gemfast */
#define __GEMLIB_HAVE_DEFS
#else
#undef __GEMLIB_DEFS
#endif
#else								/* New include scheme: one header defines all */
#define __GEMLIB_DEFS
#define __GEMLIB_AES
#define __GEMLIB_VDI
#endif
#ifdef __cplusplus
extern "C" {
#endif

#ifndef __CDECL
#define __CDECL cdecl
#endif

/*******************************************************************************
 * The version of the gem-lib
 */
#define GEMLIB_PATCHLEVEL	"39"
#ifdef __GEMLIB_DEFS
/*******************************************************************************
 * The AES specific stuff from old gemfast.h
 */
#define NIL 				0
#define DESKTOP_HANDLE	0
#define DESK			  	DESKTOP_HANDLE

		/* appl_getinfo modes */
#define AES_LARGEFONT	0
#define AES_SMALLFONT	1
#define AES_SYSTEM		2
#define AES_LANGUAGE 	3
#define AES_PROCESS		4
#define AES_PCGEM 		5
#define AES_INQUIRE		6
#define AES_MOUSE 		8
#define AES_MENU			9
#define AES_SHELL 	  10
#define AES_WINDOW	  11

		/* appl_getinfo return values */
#define SYSTEM_FONT		0
#define OUTLINE_FONT 	1
#define AESLANG_ENGLISH 0
#define AESLANG_GERMAN	1
#define AESLANG_FRENCH	2
#define AESLANG_SPANISH 4
#define AESLANG_ITALIAN 5
#define AESLANG_SWEDISH 6

		/* appl_read modes */
#define APR_NOWAIT	  -1

		/* appl_search modes */
#define APP_FIRST 		0
#define APP_NEXT			1

		/* appl_search return values*/
#define APP_SYSTEM		0x01
#define APP_APPLICATION 0x02
#define APP_ACCESSORY	0x04
#define APP_SHELL 		0x08

		/* appl_trecord types */
#define APPEVNT_TIMER	 0
#define APPEVNT_BUTTON	 1
#define APPEVNT_MOUSE	 2
#define APPEVNT_KEYBOARD 3
		/* struct used by appl_trecord and appl_tplay */
typedef struct pEvntrec {
	long ap_event;
	long ap_value;
}EVNTREC;

		/* evnt_button flags */
#define LEFT_BUTTON		0x0001
#define RIGHT_BUTTON 	0x0002
#define MIDDLE_BUTTON	0x0004
#define K_RSHIFT		0x0001
#define K_LSHIFT		0x0002
#define K_CTRL 			0x0004
#define K_ALT			0x0008

		/* evnt_dclick flags */
#define EDC_INQUIRE		0
#define EDC_SET			1

		/* event message values */
#define MN_SELECTED	  10
#define WM_REDRAW 	  20
#define WM_TOPPED 	  21
#define WM_CLOSED 	  22
#define WM_FULLED 	  23
#define WM_ARROWED	  24
#define WM_HSLID	  25
#define WM_VSLID	  26
#define WM_SIZED	  27
#define WM_MOVED	  28
#define WM_NEWTOP 	  29
#define WM_UNTOPPED	  30		/* GEM  2.x */
#define WM_ONTOP	  31		/* AES 4.0  */
#define WM_BOTTOM	  33		/* AES 4.1  */
#define WM_BOTTOMED	  33		/* AES 4.1  */
#define WM_ICONIFY	  34		/* AES 4.1  */
#define WM_UNICONIFY  35		/* AES 4.1  */
#define WM_ALLICONIFY 36		/* AES 4.1  */
#define WM_TOOLBAR	  37
#define AC_OPEN		  40
#define AC_CLOSE	  41
#define AP_TERM		  50		/* AES 4.0  */
#define AP_TFAIL	  51		/* AES 4.0  */
#define AP_RESCHG 	  57		/* AES 4.0  */

		/* Xcontrol messages */
#define CT_UPDATE 	 50
#define CT_MOVE		 51
#define CT_NEWTOP 	 52
#define CT_KEY 		 53
#define SHUT_COMPLETED	 60		/* AES 4.0  */
#define RESCHG_COMPLETED 61		/* AES 4.0  */
#define RESCH_COMPLETED  61		/* AES 4.0  */
#define AP_DRAGDROP		 63		/* AES 4.0  */
#define SH_WDRAW		 72		/* MultiTOS  */
#define SC_CHANGED		80			/* */
#define PRN_CHANGED		82
#define FNT_CHANGED		83
#define THR_EXIT		88		/* MagiC 4.5 */
#define PA_EXIT		89			/* MagiC 3   */
#define CH_EXIT			 90		/* MultiTOS  */
#define WM_M_BDROPPED	100		/* KAOS 1.4  */
#define SM_M_SPECIAL	101		/* MAG!X     */
#define SM_M_RES2		102		/* MAG!X     */
#define SM_M_RES3		103		/* MAG!X     */
#define SM_M_RES4		104		/* MAG!X     */
#define SM_M_RES5		105		/* MAG!X     */
#define SM_M_RES6		106		/* MAG!X     */
#define SM_M_RES7		107		/* MAG!X     */
#define SM_M_RES8		108		/* MAG!X     */
#define SM_M_RES9		109		/* MAG!X     */
#define WM_SHADED	   	22360	/* [WM_SHADED apid 0 win 0 0 0 0] */
#define WM_UNSHADED	   	22361	/* [WM_UNSHADED apid 0 win 0 0 0 0] */


/* subcodes for SM_M_SPECIAL message for the SCREENMGR 
	used:
	INT16 msg[8];

	msg[0] = SM_M_SPECIAL;	 101 
	msg[1] = ap_id;	 ap_id, with SMC_TIDY_UP and SMC_UNHIDEALL own 
	msg[2] = 0;		 No overrun 
	msg[3] = 0;
	msg[4] = 'MA';
	msg[5] = 'GX';
	msg[6] = ..subcode..;
	msg[7] = 0;
	appl_write(msg, 16, 1);		 apid #1 is the SCREENMGR 
*/


#define SMC_TIDY_UP		0			/* MagiC 2  */
#define SMC_TERMINATE	1			/* MagiC 2  */
#define SMC_SWITCH		2			/* MagiC 2  */
#define SMC_FREEZE		3			/* MagiC 2  */
#define SMC_UNFREEZE	4			/* MagiC 2  */
#define SMC_RES5		5			/* MagiC 2  */
#define SMC_UNHIDEALL	6			/* MagiC 3.1   */
#define SMC_HIDEOTHERS	7			/* MagiC 3.1   */
#define SMC_HIDEACT		8			/* MagiC 3.1   */

		/* evnt_mouse modes */
#define MO_ENTER 0
#define MO_LEAVE 1

		/* evnt_multi flags */
#define MU_KEYBD	0x0001
#define MU_BUTTON 	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020

		/* form_dial opcodes */
#define FMD_START 		0
#define FMD_GROW		1
#define FMD_SHRINK		2
#define FMD_FINISH		3

		/* form_error modes */
#define FERR_FILENOTFOUND	 2
#define FERR_PATHNOTFOUND	 3
#define FERR_NOHANDLES		 4
#define FERR_ACCESSDENIED	 5
#define FERR_LOWMEM			 8
#define FERR_BADENVIRON 	10
#define FERR_BADFORMAT		11
#define FERR_BADDRIVE		15
#define FERR_DELETEDIR		16
#define FERR_NOFILES 		18

		/* fsel_(ex)input return values*/
#define FSEL_CANCEL			 0
#define FSEL_OK				 1

		/* menu_attach modes */
#define ME_INQUIRE		0
#define ME_ATTACH 		1
#define ME_REMOVE 		2

		/* menu_attach attributes */
#define SCROLL_NO 		0
#define SCROLL_YES		1

		/* menu_bar modes */
#define MENU_REMOVE		0
#define MENU_INSTALL 	1
#define MENU_INQUIRE   -1

		/* menu_icheck modes */
#define UNCHECK			0
#define CHECK			1

		/* menu_ienable modes */
#define DISABLE			0
#define ENABLE 			1

		/* menu_istart modes */
#define MIS_GETALIGN 	0
#define MIS_SETALIGN 	1

		/* menu_popup modes */
#define SCROLL_LISTBOX -1

		/* menu_register modes */
#define REG_NEWNAME	  -1

/* menu_tnormal modes */
#define HIGHLIGHT   0
#define UNHIGHLIGHT 1
/* menu_settings uses a new structure for setting and inquiring the submenu
 * delay values and the menu scroll height.	The delay values are measured in
 * milliseconds and the height is based upon the number of menu items.
 */
typedef struct _mn_set 
{
	long  display;		/*  the submenu display delay 	  */
	long  drag;			/*  the submenu drag delay 		  */
	long  delay;		/*  the single-click scroll delay */
	long  speed;		/*  the continuous scroll delay	  */
	INT16 height; 		/*  the menu scroll height 		  */
} MN_SET;

/* shel_get modes */
#define SHEL_BUFSIZE (-1)
		/* shel_write modes */
#define SWM_LAUNCH	   0
#define SWM_LAUNCHNOW  1
#define SWM_LAUNCHACC  3
#define SWM_SHUTDOWN   4
#define SWM_REZCHANGE  5
#define SWM_BROADCAST  7
#define SWM_ENVIRON	   8
#define SWM_NEWMSG	   9
#define SWM_AESMSG	  10

		/* shel_write flags */
#define SW_PSETLIMIT 0x0100
#define SW_PRENICE	 0x0200
#define SW_DEFDIR 	 0x0400
#define SW_ENVIRON	 0x0800
#define SD_ABORT	  0
#define SD_PARTIAL    1
#define SD_COMPLETE   2

		/* rsrc_gaddr structure types */
#define R_TREE 		0
#define R_OBJECT	1
#define R_TEDINFO 	2
#define R_ICONBLK 	3
#define R_BITBLK	4
#define R_STRING	5
#define R_IMAGEDATA	6
#define R_OBSPEC	7
#define R_TEPTEXT 	8
#define R_TEPTMPLT	9
#define R_TEPVALID  10
#define R_IBPMASK   11
#define R_IBPDATA   12
#define R_IBPTEXT   13
#define R_BIPDATA   14
#define R_FRSTR	   15
#define R_FRIMG	   16

		/* Window Attributes */
#define NAME		0x0001
#define CLOSER 		0x0002
#define FULLER 		0x0004
#define MOVER		0x0008
#define INFO		0x0010
#define SIZER		0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE 		0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE 		0x0800
#define HOTCLOSEBOX 0x1000      /* GEM 2.x     */
#define BACKDROP	0x2000		/* KAOS 1.4    */
#define SMALLER		0x4000		/* AES 4.1     */
#define ICONIFIER SMALLER

		/* wind_create flags */
#define WC_BORDER 	 0
#define WC_WORK		 1

		/* wind_get flags */
#define WF_KIND			  1
#define WF_NAME			  2
#define WF_INFO			  3
#define WF_WORKXYWH		  4
#define WF_CURRXYWH		  5
#define WF_PREVXYWH		  6
#define WF_FULLXYWH		  7
#define WF_HSLIDE 		  8
#define WF_VSLIDE 		  9
#define WF_TOP 			 10
#define WF_FIRSTXYWH 	 11
#define WF_NEXTXYWH		 12
#define WF_RESVD		 13
#define WF_NEWDESK		 14
#define WF_HSLSIZE		 15
#define WF_VSLSIZE		 16
#define WF_SCREEN 		 17
#define WF_COLOR		 18
#define WF_DCOLOR 		 19
#define WF_OWNER		 20
#define WF_BEVENT 		 24
#define WF_BOTTOM 		 25
#define WF_ICONIFY		 26		/* AES 4.1     */
#define WF_UNICONIFY 	 27		/* AES 4.1     */
#define WF_UNICONIFYXYWH 28		/* AES 4.1     */
#define WF_TOOLBAR		 30
#define WF_FTOOLBAR		 31
#define WF_NTOOLBAR		 32
#define WF_M_BACKDROP	100      /* KAOS 1.4    */
#define WF_M_OWNER		101      /* KAOS 1.4    */
#define WF_M_WINDLIST	102      /* KAOS 1.4    */
#define WF_MINXYWH		103      /* MagiC 6     */
#define WF_INFOXYWH		104      /* MagiC 6.10  */
#define WF_WINX		  22360
#define WF_WINXCFG	  22361
#define WF_SHADE      22365      /* WINX 2.3 */
#define WF_STACK	  22366      /* WINX 2.3 */
#define WF_TOPALL	  22367      /* WINX 2.3 */
#define WF_BOTTOMALL  22368		 /* WINX 2.3 */

		/* window elements	*/
#define W_BOX		0
#define W_TITLE		1
#define W_CLOSER	2
#define W_NAME 		3
#define W_FULLER	4
#define W_INFO 		5
#define W_DATA 		6
#define W_WORK 		7
#define W_SIZER		8
#define W_VBAR 		9
#define W_UPARROW   10
#define W_DNARROW   11
#define W_VSLIDE	12
#define W_VELEV	    13
#define W_HBAR 	    14
#define W_LFARROW   15
#define W_RTARROW   16
#define W_HSLIDE	17
#define W_HELEV	    18
#define W_SMALLER   19		/* AES 4.1     */
#define W_BOTTOMER  20      /* MagiC 3     */

/* wind_set(WF_BEVENT) */

#define BEVENT_WORK     0x0001    /* AES 4.0  */
#define BEVENT_INFO     0x0002    /* MagiC 6  */

		/* arrow message	*/
#define WA_UPPAGE 	0
#define WA_DNPAGE 	1
#define WA_UPLINE 	2
#define WA_DNLINE 	3
#define WA_LFPAGE 	4
#define WA_RTPAGE 	5
#define WA_LFLINE 	6
#define WA_RTLINE 	7

		/* Wind calc flags */
#define WC_BORDER	0
#define WC_WORK		1

		/* wind_update flags */
#define END_UPDATE 0
#define BEG_UPDATE 1
#define END_MCTRL  2
#define BEG_MCTRL  3

/* graf_mouse mouse types*/
#define ARROW			 0
#define TEXT_CRSR 		 1
#define BEE 			 2
#define BUSY_BEE		 BEE 	/* alias */
#define BUSYBEE		  	 BEE 	/* alias */
#define HOURGLASS 		 2
#define POINT_HAND		 3
#define FLAT_HAND 		 4
#define THIN_CROSS		 5
#define THICK_CROSS		 6
#define OUTLN_CROSS		 7
#define USER_DEF		 255
#define M_OFF			 256
#define M_ON			 257
#define M_SAVE 		  	 258
#define M_LAST 		  	 259
#define M_RESTORE 	  	 260
#define M_FORCE	  		 0x8000
/* objects - general */
#define ROOT		0 	 /* index of ROOT */
#define MAX_LEN		81 	 /* max string length */
#define MAX_DEPTH  	8 	 /* max depth of search or draw */

/* inside fill patterns */
#define IP_HOLLOW 	0
#define IP_1PATT	1
#define IP_2PATT	2
#define IP_3PATT	3
#define IP_4PATT	4
#define IP_5PATT	5
#define IP_6PATT	6
#define IP_SOLID	7

/* normal graphics drawing modes */
#define MD_REPLACE 		1
#define MD_TRANS	 	2
#define MD_XOR 	 		3
#define MD_ERASE	 	4

		/* bit blt rules */
#define ALL_WHITE   0
#define S_AND_D	  	1
#define S_AND_NOTD  2
#define S_ONLY 	  	3
#define NOTS_AND_D  4
#define D_ONLY 	  	5
#define S_XOR_D	  	6
#define S_OR_D 	  	7
#define NOT_SORD	8
#define NOT_SXORD  	9
#define D_INVERT	10
#define NOT_D		10
#define S_OR_NOTD  	11
#define NOT_S		12
#define NOTS_OR_D  	13
#define NOT_SANDD  	14
#define ALL_BLACK  	15

		/* font types */
#define GDOS_PROP   0
#define GDOS_MONO   1
#define GDOS_BITM   2
#define IBM 		3
#define SMALL		5

		/* object types */
#define G_BOX		20
#define G_TEXT 	 	21
#define G_BOXTEXT  	22
#define G_IMAGE	 	23
#define G_USERDEF  	24
#define G_PROGDEF  G_USERDEF
#define G_IBOX 	 	25
#define G_BUTTON	26
#define G_BOXCHAR  	27
#define G_STRING	28
#define G_FTEXT	 	29
#define G_FBOXTEXT 	30
#define G_ICON 	 	31
#define G_TITLE	 	32
#define G_CICON	 	33
#define G_SWBUTTON  34     /* MAG!X       */
#define G_POPUP     35     /* MAG!X       */
#define G_RESVD1    36     /* MagiC 3.1   */
#define G_SHORTCUT  38     /* MagiC 6  */

/* object flags */
#define NONE		0x0000
#define SELECTABLE 	0x0001
#define DEFAULT	 	0x0002
#define EXIT		0x0004
#define EDITABLE	0x0008
#define RBUTTON	 	0x0010
#define LASTOB 	 	0x0020
#define TOUCHEXIT  	0x0040
#define HIDETREE	0x0080
#define INDIRECT	0x0100
#define FL3DIND	 	0x0200	/* 3D Indicator      AES 4.0      */
#define FL3DBAK	 	0x0400	/* 3D Background     AES 4.0      */
#define FL3DACT	 	0x0600  /* 3D Activator      AES 4.0      */
#define SUBMENU	 	0x0800	/* bit 11 */
#define FLAG11		SUBMENU
#define FLAG12		0x1000
#define FLAG13		0x2000
#define FLAG14		0x4000
#define FLAG15		0x8000

/* Object states */
#define NORMAL 	 	0x0000
#define SELECTED	0x0001
#define CROSSED	 	0x0002
#define CHECKED	 	0x0004
#define DISABLED	0x0008
#define OUTLINED	0x0010
#define SHADOWED	0x0020
#define WHITEBAK	0x0040
#define DRAW3D		0x0080   /* GEM 2.x     */
#define STATE08    	0x0100
#define STATE09	 	0x0200
#define STATE10    	0x0400
#define STATE11    	0x0800
#define STATE12	 	0x1000
#define STATE13	 	0x2000
#define STATE14	 	0x4000
#define STATE15	 	0x8000

/* Object colors - default pall. */
#define WHITE	  	0
#define BLACK	  	1
#define RED 	  	2
#define GREEN	  	3
#define BLUE	  	4
#define CYAN	  	5
#define YELLOW   	6
#define MAGENTA  	7
#define LWHITE   	8
#define LBLACK   	9
#define LRED	  	10
#define LGREEN   	11
#define LBLUE	  	12
#define LCYAN	  	13
#define LYELLOW  	14
#define LMAGENTA 	15

/* editable text field definitions */
#define EDSTART		0
#define EDINIT 		1
#define EDCHAR 		2
#define EDEND		3
#define ED_START	EDSTART
#define ED_INIT		EDINIT
#define ED_CHAR		EDCHAR
#define ED_END 		EDEND
#define ED_CRSR     100            /* MAG!X       */
#define ED_DRAW     103            /* MagiC 2.00  */

/* editable text justification */
#define TE_LEFT		0
#define TE_RIGHT	1
#define TE_CNTR		2

/* objc_change modes */
#define NO_DRAW		0
#define REDRAW 		1
/* objc_order modes */
#define OO_LAST	  	-1
#define OO_FIRST	 0
/* objc_sysvar modes */
#define SV_INQUIRE	0
#define SV_SET 		1

/* objc_sysvar values */
#define LK3DIND		1		/* AES 4.0     */
#define LK3DACT		2		/* AES 4.0     */
#define INDBUTCOL 	3		/* AES 4.0     */
#define ACTBUTCOL 	4		/* AES 4.0     */
#define BACKGRCOL 	5		/* AES 4.0     */
#define AD3DVAL		6		/* AES 4.0     */
#define MX_ENABLE3D 10      /* MagiC 3.0   */

		/* Mouse Form Definition Block */
typedef struct mouse_form {
	INT16 mf_xhot;
	INT16 mf_yhot;
	INT16 mf_nplanes;
	INT16 mf_bg;
	INT16 mf_fg;
	INT16 mf_mask[16];
	INT16 mf_data[16];
}MFORM;

typedef struct graphic_rectangle
{
	INT16 	g_x;
	INT16 	g_y;
	INT16 	g_w;
	INT16 	g_h;
} GRECT;

typedef struct objc_colorword 
{
	unsigned borderc : 4;
	unsigned textc   : 4;
	unsigned opaque  : 1;
	unsigned pattern : 3;
	unsigned fillc   : 4;
}OBJC_COLORWORD;

typedef struct text_edinfo
{
	char *te_ptext;		/* ptr to text */
	char *te_ptmplt;	/* ptr to template */
	char *te_pvalid;	/* ptr to validation chrs. */
	INT16 te_font; 		/* font */
	INT16 te_fontid;	/* font id */
	INT16 te_just; 		/* justification */
	INT16 te_color;		/* color information word */
	INT16 te_fontsize;	/* font size */
	INT16 te_thickness;	/* border thickness */
	INT16 te_txtlen;	/* length of text string */
	INT16 te_tmplen;	/* length of template string */
} TEDINFO;

typedef struct icon_block {
	INT16 *ib_pmask;
	INT16 *ib_pdata;
	char	*ib_ptext;
	INT16 ib_char;
	INT16 ib_xchar;
	INT16 ib_ychar;
	INT16 ib_xicon;
	INT16 ib_yicon;
	INT16 ib_wicon;
	INT16 ib_hicon;
	INT16 ib_xtext;
	INT16 ib_ytext;
	INT16 ib_wtext;
	INT16 ib_htext;
}ICONBLK;

typedef struct bit_block {
	INT16 *bi_pdata;	/* ptr to bit forms data  */
	INT16 bi_wb;		/* width of form in bytes */
	INT16 bi_hl;		/* height in lines */
	INT16 bi_x; 		/* source x in bit form */
	INT16 bi_y; 		/* source y in bit form */
	INT16 bi_color;		/* fg color of blt */
}BITBLK;

typedef struct cicon_data {
	INT16 				num_planes;
	INT16 				*col_data;
	INT16 				*col_mask;
	INT16 				*sel_data;
	INT16 				*sel_mask;
	struct cicon_data *next_res;
}CICON;

typedef struct cicon_blk {
	ICONBLK monoblk;
	CICON   *mainlist;
}CICONBLK;

typedef struct {
	 unsigned int character   :  8;
	 signed	  int framesize   :  8;
	 unsigned int framecol	  :  4;
	 unsigned int textcol	  :  4;
	 unsigned int textmode	  :  1;
	 unsigned int fillpattern :  3;
	 unsigned int interiorcol :  4;
} BFOBSPEC;

struct user_block;	/* forward declaration */

typedef union obspecptr
{
	long					index;
	union obspecptr 	*indirect;
	BFOBSPEC 			obspec;
	TEDINFO				*tedinfo;
	BITBLK				*bitblk;
	ICONBLK				*iconblk;
	CICONBLK 			*ciconblk;
	struct user_block	*userblk;
	char				*free_string;
} OBSPEC;

typedef struct object
{
	INT16 			ob_next; 	/* -> object's next sibling		  */
	INT16 			ob_head; 	/* -> head of object's children	  */
	INT16 			ob_tail; 	/* -> tail of object's children	  */
	unsigned INT16 	ob_type; 	/* type of object 		  */
	unsigned INT16 	ob_flags;	/* flags 			  */
	unsigned INT16 	ob_state;	/* state 			  */
	OBSPEC			ob_spec; 	/* object-specific data 		  */
	INT16 			ob_x; 		/* upper left corner of object		  */
	INT16 			ob_y; 		/* upper left corner of object		  */
	INT16 			ob_width;	/* width of obj				  */
	INT16 			ob_height;	/* height of obj			  */
} OBJECT;

typedef struct parm_block
{
	OBJECT *pb_tree;
	INT16  	pb_obj;
	INT16  	pb_prevstate;
	INT16  	pb_currstate;
	INT16 	pb_x, pb_y, pb_w, pb_h;
	INT16  	pb_xc, pb_yc, pb_wc, pb_hc;
	long	pb_parm;
} PARMBLK;

typedef struct user_block
{   int __CDECL (*ub_code)(PARMBLK *parmblock);
	long ub_parm;
} USERBLK;

typedef struct rshdr
{
	INT16 			rsh_vrsn;
	unsigned INT16 	rsh_object;
	unsigned INT16 	rsh_tedinfo;
	unsigned INT16 	rsh_iconblk;	/* list of ICONBLKS		*/
	unsigned INT16 	rsh_bitblk;
	unsigned INT16 	rsh_frstr;
	unsigned INT16 	rsh_string;
	unsigned INT16 	rsh_imdata; /* image data			*/
	unsigned INT16 	rsh_frimg;
	unsigned INT16 	rsh_trindex;
	INT16 			rsh_nobs;	/* counts of various structs	*/
	INT16 			rsh_ntree;
	INT16 			rsh_nted;
	INT16 			rsh_nib;
	INT16 			rsh_nbb;
	INT16 			rsh_nstring;
	INT16 			rsh_nimages;
	unsigned INT16 	rsh_rssize; /* total bytes in resource */
} RSHDR;

typedef struct _menu
{
	OBJECT		*mn_tree;
	INT16		 mn_menu;
	INT16		 mn_item;
	INT16		 mn_scroll;
	INT16		 mn_keystate;
} MENU;

typedef struct
{
	int 	m_out;
	int 	m_x;
	int 	m_y;
	int 	m_w;
	int		m_h;
} MOBLK;


#endif 
#ifdef __GEMLIB_AES
/*******************************************************************************
 * The AES bindings from old aesbind.h
 */
 
extern int	mt_appl_bvset 		(int bvdisk, int bvhard,INT16 *global_aes);
extern int	mt_appl_control		(int ap_cid, int ap_cwhat, void *ap_cout,INT16 *global_aes);
extern int	mt_appl_exit 		(INT16 *global_aes);
extern int	mt_appl_find 		(char *Name,INT16 *global_aes);
extern int	mt_appl_getinfo 	(int type, INT16 *out1, INT16 *out2, INT16 *out3, INT16 *out4,INT16 *global_aes);
extern int	mt_appl_init 		(INT16 *global_aes);
extern int	mt_appl_read 		(int ApId, int Length, void *ApPbuff,INT16 *global_aes);
extern int	mt_appl_search 		(int mode, char *fname, INT16 *type, INT16 *ap_id,INT16 *global_aes);
extern int	mt_appl_tplay 		(void *Mem, int Num, int Scale,INT16 *global_aes);
extern int	mt_appl_trecord 	(void *Mem, int Count,INT16 *global_aes);
extern int	mt_appl_write 		(int ApId, int Length, void *ApPbuff,INT16 *global_aes);
extern int	mt_appl_yield 		(INT16 *global_aes); 
#define appl_bvset(a,b) mt_appl_bvset(a,b,aes_global)
#define appl_control(a,b,c) mt_appl_control(a,b,c,aes_global)
#define appl_exit() mt_appl_exit(aes_global)
#define appl_find(a) mt_appl_find(a,aes_global)
#define appl_getinfo(a,b,c,d,e) mt_appl_getinfo(a,b,c,d,e,aes_global)
#define appl_init() mt_appl_init(aes_global)
#define appl_read(a,b,c) mt_appl_read(a,b,c,aes_global)
#define appl_search(a,b,c,d) mt_appl_search(a,b,c,d,aes_global)
#define appl_tplay(a,b,c) mt_appl_tplay(a,b,c,aes_global)
#define appl_trecord(a,b) mt_appl_trecord(a,b,aes_global)
#define appl_write(a,b,c) mt_appl_write(a,b,c,aes_global)
#define appl_yield() mt_appl_yield(aes_global)  

extern int	mt_evnt_button 		(int Clicks, int WhichButton,	int WhichState, INT16 *Mx, INT16 *My, INT16 *ButtonState, INT16 *KeyState,INT16 *global_aes); 
extern int	mt_evnt_dclick 		(int ToSet, int SetGet,INT16 *global_aes);
extern int	mt_evnt_keybd 		(INT16 *global_aes);
extern int	mt_evnt_mesag 		(INT16 MesagBuf[],INT16 *global_aes);
extern int	mt_evnt_mouse 		(int EnterExit, int InX, int InY, int InW, int InH, INT16 *OutX, INT16 *OutY, INT16 *ButtonState, INT16 *KeyState,INT16 *global_aes); 
extern int	mt_evnt_multi 		(int Type, 	int Clicks, int WhichButton, int WhichState, 
											int EnterExit1, int In1X, int In1Y, int In1W, int In1H, 
											int EnterExit2, int In2X, int In2Y, int In2W, int In2H,
											INT16 MesagBuf[], unsigned long Interval, INT16 *OutX, INT16 *OutY,
											INT16 *ButtonState, INT16 *KeyState, INT16 *Key, INT16 *ReturnCount,INT16 *global_aes);
extern int	mt_evnt_timer 		(unsigned long Interval,INT16 *global_aes);
#define evnt_button(a,b,c,d,e,f,g) mt_evnt_button(a,b,c,d,e,f,g,aes_global)
#define evnt_dclick(a,b) mt_evnt_dclick(a,b,aes_global)
#define evnt_keybd() mt_evnt_keybd(aes_global)
#define evnt_mesag(a) mt_evnt_mesag(a,aes_global)
#define evnt_mouse(a,b,c,d,e,f,g,h,i) mt_evnt_mouse(a,b,c,d,e,f,g,h,i,aes_global)
#define evnt_multi(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v) mt_evnt_multi(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,aes_global)
#define evnt_timer(a) mt_evnt_timer(a,aes_global)

extern int 	mt_form_alert 		(int DefButton, char *Str,INT16 *global_aes);
extern int 	mt_form_button 		(void *Btree, int Bobject, int Bclicks, INT16 *Bnxtobj,INT16 *global_aes);
extern int 	mt_form_center 		(void *Tree, INT16 *Cx, INT16 *Cy, INT16 *Cw, INT16 *Ch,INT16 *global_aes);
extern int 	mt_form_dial 		(int Flag, int Sx, int Sy, int Sw, int Sh, int Bx, int By, int Bw, int Bh,INT16 *global_aes);
extern int 	mt_form_do 			(void *Tree, int StartObj,INT16 *global_aes);
extern int 	mt_form_error 		(int ErrorCode,INT16 *global_aes);
extern int 	mt_form_keybd 		(void *Ktree, int Kobject, int Kobnext, int Kchar, INT16 *Knxtobject, INT16 *Knxtchar,INT16 *global_aes);
#define form_alert(a,b) mt_form_alert(a,b,aes_global)
#define form_button(a,b,c,d) mt_form_button(a,b,c,d,aes_global)
#define form_center(a,b,c,d,e) mt_form_center(a,b,c,d,e,aes_global)
#define form_dial(a,b,c,d,e,f,g,h,i) mt_form_dial(a,b,c,d,e,f,g,h,i,aes_global)
#define form_do(a,b) mt_form_do(a,b,aes_global)
#define form_error(a) mt_form_error(a,aes_global)
#define form_keybd(a,b,c,d,e,f) mt_form_keybd(a,b,c,d,e,f,aes_global)

extern int 	mt_fsel_exinput 	(char *Path, char *File, INT16 *ExitButton, char *title,INT16 *global_aes);
extern int 	mt_fsel_input 		(char *Path, char *File, INT16 *ExitButton,INT16 *global_aes);
#define fsel_exinput(a,b,c,d) mt_fsel_exinput(a,b,c,d,aes_global)
#define fsel_input(a,b,c) mt_fsel_input(a,b,c,aes_global)

extern int 	mt_graf_dragbox 	(int Sw, int Sh, int Sx, int Sy, int Bx, int By, int Bw, int Bh, INT16 *Fw, INT16 *Fh,INT16 *global_aes); 
extern int 	mt_graf_growbox 	(int Sx, int Sy, int Sw, int Sh, int Fx, int Fy, int Fw, int Fh,INT16 *global_aes); 
extern int 	mt_graf_handle	 	(INT16 *Wchar, INT16 *Hchar, INT16 *Wbox, INT16 *Hbox,INT16 *global_aes);
extern int 	mt_graf_mbox 		(int Sw, int Sh, int Sx, int Sy, int Dx, int Dy,INT16 *global_aes);
extern int 	mt_graf_mkstate 	(INT16 *Mx, INT16 *My, INT16 *ButtonState, INT16 *KeyState,INT16 *global_aes); 
extern int 	mt_graf_mouse 		(int Form, void *FormAddress,INT16 *global_aes);
extern int 	mt_graf_rubberbox	(int Ix, int Iy, int Iw, int Ih, INT16 *Fw, INT16 *Fh,INT16 *global_aes);
extern int 	mt_graf_shrinkbox 	(int Fx, int Fy, int Fw, int Fh, int Sx, int Sy, int Sw, int Sh,INT16 *global_aes); 
extern int 	mt_graf_slidebox 	(void *Tree, int Parent, int Object, int Direction,INT16 *global_aes); 
extern int 	mt_graf_watchbox 	(void *Tree, int Object, int InState, int OutState,INT16 *global_aes);
#define graf_dragbox(a,b,c,d,e,f,g,h,i,j) mt_graf_dragbox(a,b,c,d,e,f,g,h,i,j,aes_global)
#define graf_growbox(a,b,c,d,e,f,g,h) mt_graf_growbox(a,b,c,d,e,f,g,h,aes_global)
#define graf_handle(a,b,c,d) mt_graf_handle(a,b,c,d,aes_global)
#define graf_mbox(a,b,c,d,e,f) mt_graf_mbox(a,b,c,d,e,f,aes_global)
#define graf_mkstate(a,b,c,d) mt_graf_mkstate(a,b,c,d,aes_global)
#define graf_mouse(a,b) mt_graf_mouse(a,b,aes_global)
#define graf_rubberbox(a,b,c,d,e,f) mt_graf_rubberbox(a,b,c,d,e,f,aes_global)
#define graf_shrinkbox(a,b,c,d,e,f,g,h) mt_graf_shrinkbox(a,b,c,d,e,f,g,h,aes_global)
#define graf_slidebox(a,b,c,d) mt_graf_slidebox(a,b,c,d,aes_global)
#define graf_watchbox(a,b,c,d) mt_graf_watchbox(a,b,c,d,aes_global)

extern int	mt_menu_attach 		(int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata,INT16 *global_aes);
extern int	mt_menu_bar 		(void *Tree, int ShowFlag,INT16 *global_aes);
extern int	mt_menu_click		(int click, int setit,INT16 *global_aes);
extern int	mt_menu_icheck 		(void *Tree, int Item, int CheckFlag,INT16 *global_aes);
extern int	mt_menu_ienable		(void *Tree, int Item, int EnableFlag,INT16 *global_aes);
extern int	mt_menu_istart 		(int me_flag, OBJECT *me_tree, int me_imenu, int me_item,INT16 *global_aes);
extern int	mt_menu_popup 		(MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata,INT16 *global_aes);
extern int	mt_menu_register 	(int ApId, char *MenuText,INT16 *global_aes);
extern int	mt_menu_settings 	(int me_flag, MN_SET *me_values,INT16 *global_aes);
extern int	mt_menu_text 		(void *Tree, int Item, char *Text,INT16 *global_aes);
extern int	mt_menu_tnormal 	(void *Tree, int Item, int NormalFlag,INT16 *global_aes);
extern int	mt_menu_unregister	(int id,INT16 *global_aes);
#define menu_attach(a,b,c,d) mt_menu_attach(a,b,c,d,aes_global)
#define menu_bar(a,b) mt_menu_bar(a,b,aes_global)
#define menu_click(a,b) mt_menu_click(a,b,aes_global)
#define menu_icheck(a,b,c) mt_menu_icheck(a,b,c,aes_global)
#define menu_ienable(a,b,c) mt_menu_ienable(a,b,c,aes_global)
#define menu_istart(a,b,c,d) mt_menu_istart(a,b,c,d,aes_global)
#define menu_popup(a,b,c,d) mt_menu_popup(a,b,c,d,aes_global)
#define menu_register(a,b) mt_menu_register(a,b,aes_global)
#define menu_settings(a,b) mt_menu_settings(a,b,aes_global)
#define menu_text(a,b,c) mt_menu_text(a,b,c,aes_global)
#define menu_tnormal(a,b,c) mt_menu_tnormal(a,b,c,aes_global)
#define menu_unregister(a) mt_menu_unregister(a,aes_global)

extern int	mt_objc_add 	(void *Tree, int Parent, int Child,INT16 *global_aes);
extern int	mt_objc_change 	(void *Tree, int Object, int Res, int Cx, int Cy, int Cw, int Ch, int NewState,int Redraw,INT16 *global_aes);
extern int	mt_objc_delete 	(void *Tree, int Object,INT16 *global_aes);
extern int	mt_objc_draw 	(void *Tree, int Start, int Depth, int Cx,int Cy, int Cw, int Ch,INT16 *global_aes);
extern int	mt_objc_edit 	(void *Tree, int Object, int Char, INT16 *Index, int Kind,INT16 *global_aes); 
extern int	mt_objc_find 	(void *Tree, int Start, int Depth, int Mx, int My,INT16 *global_aes);
extern int	mt_objc_offset 	(void *Tree, int Object, INT16 *X, INT16 *Y,INT16 *global_aes);
extern int	mt_objc_order 	(void *Tree, int Object, int NewPos,INT16 *global_aes);
extern int	mt_objc_sysvar 	(int mode, int which, int in1, int in2, INT16 *out1, INT16 *out2,INT16 *global_aes);
#define objc_add(a,b,c) mt_objc_add(a,b,c,aes_global)
#define objc_change(a,b,c,d,e,f,g,h,i) mt_objc_change(a,b,c,d,e,f,g,h,i,aes_global)
#define objc_delete(a,b) mt_objc_delete(a,b,aes_global)
#define objc_draw(a,b,c,d,e,f,g) mt_objc_draw(a,b,c,d,e,f,g,aes_global)
#define objc_edit(a,b,c,d,e) mt_objc_edit(a,b,c,d,e,aes_global)
#define objc_find(a,b,c,d,e) mt_objc_find(a,b,c,d,e,aes_global)
#define objc_offset(a,b,c,d) mt_objc_offset(a,b,c,d,aes_global)
#define objc_order(a,b,c) mt_objc_order(a,b,c,aes_global)
#define objc_sysvar(a,b,c,d,e,f) mt_objc_sysvar(a,b,c,d,e,f,aes_global)

extern int	mt_rsrc_free 	(INT16 *global_aes);
extern int	mt_rsrc_gaddr 	(int Type, int Index, void *Address,INT16 *global_aes);
extern int	mt_rsrc_load 	(char *Name,INT16 *global_aes);
extern int	mt_rsrc_obfix 	(void *Tree, int Index,INT16 *global_aes);
extern int	mt_rsrc_rcfix 	(void *rc_header,INT16 *global_aes);
extern int	mt_rsrc_saddr 	(int Type, int Index, void *Address,INT16 *global_aes);
#define rsrc_free() mt_rsrc_free(aes_global)
#define rsrc_gaddr(a,b,c) mt_rsrc_gaddr(a,b,c,aes_global)
#define rsrc_load(a) mt_rsrc_load(a,aes_global)
#define rsrc_obfix(a,b) mt_rsrc_obfix(a,b,aes_global)
#define rsrc_rcfix(a) mt_rsrc_rcfix(a,aes_global)
#define rsrc_saddr(a,b,c) mt_rsrc_saddr(a,b,c,aes_global)

extern int	mt_scrp_clear 	(INT16 *global_aes);
extern int	mt_scrp_read 	(char *Scrappath,INT16 *global_aes);
extern int	mt_scrp_write 	(char *Scrappath,INT16 *global_aes);
#define scrp_clear() mt_scrp_clear(aes_global)
#define scrp_read(a) mt_scrp_read(a,aes_global)
#define scrp_write(a) mt_scrp_write(a,aes_global)

extern int	mt_shel_envrn 	(char **result, char *param,INT16 *global_aes);
extern int	mt_shel_find 	(char *buf,INT16 *global_aes);
extern int	mt_shel_get 	(char *Buf, int Len,INT16 *global_aes);
extern int	mt_shel_help	(int sh_hmode, char *sh_hfile, char *sh_hkey,INT16 *global_aes);
extern int	mt_shel_put	 	(char *Buf, int Len,INT16 *global_aes);
extern int	mt_shel_rdef	(char *lpcmd, char *lpdir,INT16 *global_aes);
extern int	mt_shel_read 	(char *Command, char *Tail,INT16 *global_aes);
extern int	mt_shel_wdef	(char *lpcmd, char *lpdir,INT16 *global_aes);
extern int	mt_shel_write	(int Exit, int Graphic, int Aes, void *Command, char *Tail,INT16 *global_aes);
#define shel_envrn(a,b) mt_shel_envrn(a,b,aes_global)
#define shel_find(a) mt_shel_find(a,aes_global)
#define shel_get(a,b) mt_shel_get(a,b,aes_global)
#define shel_help(a,b,c) mt_shel_help(a,b,c,aes_global)
#define shel_put(a,b) mt_shel_put(a,b,aes_global)
#define shel_rdef(a,b) mt_shel_rdef(a,b,aes_global)
#define shel_read(a,b) mt_shel_read(a,b,aes_global)
#define shel_wdef(a,b) mt_shel_wdef(a,b,aes_global)
#define shel_write(a,b,c,d,e) mt_shel_write(a,b,c,d,e,aes_global)

extern int	mt_wind_calc 	(int Type, int Parts, int InX, int InY, int InW, int InH, INT16 *OutX, INT16 *OutY, INT16 *OutW, INT16 *OutH,INT16 *global_aes);	
extern int	mt_wind_close 	(int WindowHandle,INT16 *global_aes);
extern int	mt_wind_create 	(int Parts, int Wx, int Wy, int Ww, int Wh,INT16 *global_aes); 
extern int	mt_wind_delete 	(int WindowHandle,INT16 *global_aes);
extern int	mt_wind_find 	(int X, int Y,INT16 *global_aes);
extern int	mt_wind_get 	(int WindowHandle, int What, INT16 *W1, INT16 *W2, INT16 *W3, INT16 *W4,INT16 *global_aes); 
extern int	mt_wind_new 	(INT16 *global_aes);
extern int	mt_wind_open 	(int WindowHandle, int Wx, int Wy, int Ww, int Wh,INT16 *global_aes);
extern int	mt_wind_set 	(int WindowHandle, int What, int W1, int W2, int W3, int W4,INT16 *global_aes);
extern int	mt_wind_update 	(int Code,INT16 *global_aes);
#define wind_calc(a,b,c,d,e,f,g,h,i,j) mt_wind_calc(a,b,c,d,e,f,g,h,i,j,aes_global)	
#define wind_close(a) mt_wind_close(a,aes_global)
#define wind_create(a,b,c,d,e) mt_wind_create(a,b,c,d,e,aes_global) 
#define wind_delete(a) mt_wind_delete(a,aes_global)
#define wind_find(a,b) mt_wind_find(a,b,aes_global)
#define wind_get(a,b,c,d,e,f) mt_wind_get(a,b,c,d,e,f,aes_global) 
#define wind_new() mt_wind_new(aes_global)
#define wind_open(a,b,c,d,e) mt_wind_open(a,b,c,d,e,aes_global)
#define wind_set(a,b,c,d,e,f) mt_wind_set(a,b,c,d,e,f,aes_global)
#define wind_update(a) mt_wind_update(a,aes_global)
/*
 * Some usefull extensions.
 */
extern int mt_wind_calc_grect		(int Type, int Parts, GRECT *In, GRECT *Out,INT16 *global_aes);  
extern int mt_wind_create_grect	(int Parts, GRECT *r,INT16 *global_aes); 
extern int mt_wind_get_grect		(int WindowHandle, int What, GRECT *r,INT16 *global_aes);
extern int mt_wind_open_grect 		(int WindowHandle, GRECT *r,INT16 *global_aes);
extern int mt_wind_set_grect		(int WindowHandle, int What, GRECT *r,INT16 *global_aes);
extern int mt_wind_set_str			(int WindowHandle, int What, char *str,INT16 *global_aes);
#define wind_calc_grect(a,b,c,d) mt_wind_calc_grect(a,b,c,d,aes_global)  
#define wind_create_grect(a,b) mt_wind_create_grect(a,b,aes_global) 
#define wind_get_grect(a,b,c) mt_wind_get_grect(a,b,c,aes_global)
#define wind_open_grect(a,b) mt_wind_open_grect(a,b,aes_global)
#define wind_set_grect(a,b,c) mt_wind_set_grect(a,b,c,aes_global)
#define wind_set_str(a,b,c) mt_wind_set_str(a,b,c,aes_global)

extern int	rc_copy 			(GRECT *src, GRECT *dst);
extern int	rc_equal 			(GRECT *src, GRECT *dst);
extern int 	rc_intersect 		(GRECT *r1, GRECT *r2);
extern INT16 	*grect_to_array (GRECT *area, INT16 *array);
extern void	array_to_grect		(INT16 *array, GRECT *area);
/*
 * aes trap interface
*/
/* Array sizes in aes control block */
#define AES_CTRLMAX		5
#define AES_GLOBMAX		16
#define AES_INTINMAX 	16
#define AES_INTOUTMAX	16
#define AES_ADDRINMAX	16
#define AES_ADDROUTMAX	16
/*#define AES_CTRLMAX		5+5*2
#define AES_GLOBMAX		14+14*2
#define AES_INTINMAX 	16+16*2
#define AES_INTOUTMAX	7+7*2
#define AES_ADDRINMAX	3+3*4
#define AES_ADDROUTMAX	1+1*4
*/
typedef struct
{
	INT16 	*control;
	INT16 	*global;
	INT16 	*intin;
	INT16 	*intout;
	long	*addrin;
	long	*addrout;
} AESPB;

extern INT16	aes_global[];/*, aes_control[], aes_intin[], aes_intout[];
extern long 	aes_addrin[], aes_addrout[];
extern AESPB	aes_params; define now in local vars ! */
extern int		gl_apid, gl_ap_version;			/* initialized in appl_init */
extern void aes(AESPB *pb);
extern void asm_aes(AESPB *pb);

#define	_AESversion   (aes_global[0])
#define	_AESnumapps   (aes_global[1])
#define	_AESapid 	  (aes_global[2])
#define	_AESappglobal (*((long *)&aes_global[3]))
#define	_AESrscfile   ((OBJECT **)(*((long *)&aes_global[5])))
#define	_AESmaxchar   (aes_global[13])
#define	_AESminchar   (aes_global[14])
#endif /* AES */

#ifdef __GEMLIB_DEFS
/*******************************************************************************
 * The VDI specific stuff from old gemfast.h
 */
/* v_bez modes */
#define BEZ_BEZIER		0x01
#define BEZ_POLYLINE 	0x00
#define BEZ_NODRAW		0x02

/* v_bit_image modes */
#define IMAGE_LEFT		0
#define IMAGE_CENTER 	1
#define IMAGE_RIGHT		2
#define IMAGE_TOP 		0
#define IMAGE_BOTTOM 	2

/* v_justified modes */
#define NOJUSTIFY 	0
#define JUSTIFY		1

/* vq_color modes */
#define COLOR_REQUESTED 0
#define COLOR_ACTUAL 	1

/* return values for vq_vgdos() inquiry */
#define GDOS_NONE 	(-2L) 		 /* no GDOS installed */
#define GDOS_FSM	0x5F46534DL /* '_FSM' */
#define GDOS_FNT	0x5F464E54L /* '_FNT' */

/* vqin_mode & vsin_mode modes */
#define LOCATOR  1
#define VALUATOR 2
#define CHOICE   3
#define STRING   4

/* vqt_cachesize modes */
#define CACHE_CHAR 0
#define CACHE_MISC 1

/* vqt_devinfo return values */
#define DEV_MISSING	 	0
#define DEV_INSTALLED 	1

/* vqt_name return values */
#define BITMAP_FONT 0

/* vsf_interior modes */
#define FIS_HOLLOW  0
#define FIS_SOLID   1
#define FIS_PATTERN 2
#define FIS_HATCH   3
#define FIS_USER	4

/* vsf_perimeter modes */
#define PERIMETER_OFF 0
#define PERIMETER_ON  1

/* vsl_ends modes */
#define SQUARE  	0
#define ARROWED 	1
#define ROUND	 	2

/* vsl_type modes */
#define SOLID		1
#define LDASHED	 	2
#define DOTTED 	 	3
#define DASHDOT	 	4
#define DASH		5
#define DASHDOTDOT 	6
#define USERLINE	7

/* vsm_type modes */
#define MRKR_DOT		1
#define MRKR_PLUS 	 	2
#define MRKR_ASTERISK 	3
#define MRKR_BOX		4
#define MRKR_CROSS	 	5
#define MRKR_DIAMOND  	6

/* vst_alignment modes */
#define TA_LEFT         0 /* horizontal */
#define TA_CENTER       1
#define TA_RIGHT        2
#define TA_BASE         0 /* vertical */
#define TA_HALF         1
#define TA_ASCENT       2
#define TA_BOTTOM       3
#define TA_DESCENT      4
#define TA_TOP          5

/* vst_charmap modes */
#define MAP_BITSTREAM 	0
#define MAP_ATARI 	 	1

/* vst_effects modes */
#define TXT_NORMAL       0x0000
#define TXT_THICKENED    0x0001
#define TXT_LIGHT        0x0002
#define TXT_SKEWED       0x0004
#define TXT_UNDERLINED   0x0008
#define TXT_OUTLINED     0x0010
#define TXT_SHADOWED     0x0020

/* vst_error modes */
#define APP_ERROR 		0
#define SCREEN_ERROR 	1

/* vst_error return values */
#define NO_ERROR			0
#define CHAR_NOT_FOUND		1
#define FILE_READERR 		8
#define FILE_OPENERR 		9
#define BAD_FORMAT	  		10
#define CACHE_FULL	  		11
#define MISC_ERROR	  		(-1)

/* vst_kern modes */
#define TRACK_NONE		0
#define TRACK_NORMAL 	1
#define TRACK_TIGHT		2
#define TRACK_VERYTIGHT 3

/* vst_scratch modes */
#define SCRATCH_BOTH   0
#define SCRATCH_BITMAP 1
#define SCRATCH_NONE   2

/* v_updwk return values */
#define SLM_OK 	  	0x00
#define SLM_ERROR   0x02
#define SLM_NOTONER 0x03
#define SLM_NOPAPER 0x04

		/* VDI Memory Form Definition Block */
typedef struct
{
	void	*fd_addr;
	INT16 	 fd_w; 		 	/* Form Width in Pixels					  */
	INT16 	 fd_h; 			/* Form Height in Pixels					 */
	INT16 	 fd_wdwidth; 	/* Form Width in shorts(fd_w/sizeof(int)*/
	INT16 	 fd_stand;		/* Form format 0= device spec 1=standard*/
	INT16 	 fd_nplanes; 	/* Number of memory planes 				 */
	INT16 	 fd_r1;			/* Reserved 									 */
	INT16 	 fd_r2;			/* Reserved 									 */
	INT16 	 fd_r3;			/* Reserved 									 */
} MFDB;

#endif 

#ifdef __GEMLIB_VDI
/*******************************************************************************
 * The VDI bindings from old vdibind.h
 */
/*
 * attribute functions 
*/
extern void	vs_color			(int handle, int index, INT16 rgb[]);
extern int 	vswr_mode			(int handle, int mode);
extern int 	vsf_color 			(int handle, int index);
extern int 	vsf_interior 		(int handle, int style);
extern int 	vsf_perimeter 		(int handle, int vis);
extern int 	vsf_style 			(int handle, int style);
extern void	vsf_udpat 			(int handle, INT16 pat[], int planes);
extern int 	vsl_color 			(int handle, int index);
extern void vsl_ends 			(int handle, int begstyle, int endstyle);
extern int 	vsl_type 			(int handle, int style);
extern void vsl_udsty 			(int handle, int pat);
extern int 	vsl_width 			(int handle, int width);
extern int 	vsm_color 			(int handle, int index);
extern int 	vsm_height 			(int handle, int height);
extern int 	vsm_type 			(int handle, int symbol);
extern void vst_alignment 		(int handle, int hin, int vin, INT16 *hout, INT16 *vout);
extern int 	vst_color	 		(int handle, int index);
extern int 	vst_effects			(int handle, int effects);
extern void vst_error 			(int handle, int mode, INT16 *errorvar);
extern int 	vst_font 			(int handle, int font);
extern int	vst_height 			(int handle, int height, INT16 *charw, INT16 *charh, INT16 *cellw, INT16 *cellh);
extern int vst_point 			(int handle, int point, INT16 *charw, INT16 *charh, INT16 *cellw, INT16 *cellh);
extern int 	vst_rotation 		(int handle, int ang);
extern void vst_scratch 		(int handle, int mode);
/*
 * control functions
*/
extern void	v_clrwk				(int handle);
extern void	v_clsvwk			(int handle);
extern void	v_clswk				(int handle);
extern int	v_flushcache		(int handle);
extern int	v_loadcache			(int handle, char *filename, int mode);
extern void	v_opnvwk			(INT16 work_in[], INT16 *handle, INT16 work_out[]);
extern void	v_opnwk				(INT16 work_in[], INT16 *handle, INT16 work_out[]);
extern int	v_savecache			(int handle, char *filename);
extern void	v_set_app_buff		(int handle, void *buf_p, int size);
extern void	v_updwk				(int handle);
extern void	vs_clip				(int handle, int clip_flag, INT16 pxyarray[]);
extern int	vst_load_fonts		(int handle, int select);
extern void	vst_unload_fonts	(int handle, int select);
/*
 * escape functions
*/
extern void	v_bit_image			(int handle, char *filename, int aspect, int x_scale, int y_scale, int h_align, int v_align, INT16 *pxyarray);
extern void	v_clear_disp_list	(int handle);
extern int	v_copies			(int handle, int count);
extern void	v_dspcur			(int handle, int x, int y);
extern void	v_form_adv			(int handle);
extern void	v_hardcopy			(int handle);
extern int	v_orient			(int handle, int orientation);
extern void	v_output_window		(int handle, INT16 *pxyarray);
extern int	v_page_size			(int handle, int page_id);
extern void	v_rmcur				(int handle);
extern void	v_trays				(int handle, int input, int output, INT16 *set_input, INT16 *set_output);
extern int	vq_calibrate		(int handle, INT16 *flag);
extern int	vq_page_name		(int handle, int page_id, char *page_name, long *page_width, long *page_height);
extern void	vq_scan				(int handle, INT16 *g_slice, INT16 *g_page, INT16 *a_slice, INT16 *a_page, INT16 *div_fac);
extern int	vq_tabstatus		(int handle);
extern void	vq_tray_names		(int handle, char *input_name, char *output_name, INT16 *input, INT16 *output);
extern int	vs_calibrate		(int handle, int flag, INT16 *rgb);
extern int	vs_palette			(int handle, int palette);
extern void	vq_tdimensions		(int handle, INT16 *xdimension, INT16 *ydimension);
extern void	vt_alignment		(int handle, int dx, int dy);
extern void	vt_axis				(int handle, int xres, int yres, INT16 *xset, INT16 *yset);
extern void	vt_origin			(int handle, int xorigin, int yorigin);
extern void	vt_resolution		(int handle, int xres, int yres, INT16 *xset, INT16 *yset);
extern void	v_meta_extents		(int handle, int min_x, int min_y, int max_x, int max_y);
extern void	v_write_meta		(int handle, int numvdi_intin, INT16 *avdi_intin, int num_ptsin, INT16 *a_ptsin);
extern void	vm_coords			(int handle, int llx, int lly, int urx, int ury);
extern void	vm_filename			(int handle, char *filename);
extern void	vm_pagesize			(int handle, int pgwidth, int pgheight);
extern void	vsc_expose			(int handle, int state);
extern void	vsp_film			(int handle, int index, int lightness);
extern void	v_escape2000		(int handle, int times);
extern void	v_alpha_text		(int handle, char *str);
extern void	v_curdown			(int handle);
extern void	v_curhome			(int handle);
extern void	v_curleft			(int handle);
extern void	v_curright			(int handle);
extern void	v_curtext			(int handle, char *str);
extern void	v_curup				(int handle);
extern void	v_eeol				(int handle);
extern void	v_eeos				(int handle);
extern void	v_enter_cur			(int handle);
extern void	v_exit_cur			(int handle);
extern void	v_rvoff				(int handle);
extern void	v_rvon				(int handle);
extern void	vq_chcells			(int handle, INT16 *n_rows, INT16 *n_cols);
extern void	vq_curaddress		(int handle, INT16 *cur_row, INT16 *cur_col);
extern void	vs_curaddress		(int handle, int row, int col);
	
/*
 * inquiry functions
*/
extern void	vq_cellarray		(int handle, INT16 pxyarray[], int row_len, int nrows, INT16 *el_used, INT16 *rows_used, INT16 *status, INT16 color[]);
extern int	vq_color			(int handle, int index, int flag, INT16 rgb[]);
extern void	vq_extnd			(int handle, int flag, INT16 work_out[]);
extern void	vqf_attributes		(int handle, INT16 atrib[]);
extern void	vqin_mode			(int handle, int dev, INT16 *mode);
extern void	vql_attributes		(int handle, INT16 atrib[]);
extern void	vqm_attributes		(int handle, INT16 atrib[]);
extern void	vqt_attributes		(int handle, INT16 atrib[]);
extern void	vqt_cachesize		(int handle, int which_cache, long *size);
extern void	vqt_extent			(int handle, char *str, INT16 extent[]);
extern void	vqt_fontinfo		(int handle, INT16 *minade, INT16 *maxade, INT16 distances[], INT16 *maxwidth, INT16 effects[]);
extern void	vqt_get_table		(int handle, INT16 **map);
extern int	vqt_name			(int handle, int element, char *name);
extern int	vqt_width			(int handle, int chr, INT16 *cw, INT16 *ldelta, INT16 *rdelta);
extern int	vq_gdos 			(void);
extern long vq_vgdos 			(void);
/*
 * input function
*/
extern void	v_hide_c		(int handle);
extern void	v_show_c		(int handle, int reset);
extern void	vex_butv		(int handle, void *pusrcode, void **psavcode);
extern void	vex_curv		(int handle, void *pusrcode, void **psavcode);
extern void	vex_motv		(int handle, void *pusrcode, void **psavcode);
extern void	vex_timv		(int handle, void *time_addr, void **otime_addr, INT16 *time_conv);
extern void	vq_key_s		(int handle, INT16 *state);
extern void	vq_mouse		(int handle, INT16 *pstatus, INT16 *x, INT16 *y);
extern void	vrq_choice		(int handle, int cin, INT16 *cout);
extern void	vrq_locator		(int handle, int x, int y, INT16 *xout, INT16 *yout, INT16 *term);
extern void	vrq_string		(int handle, int len, int echo, INT16 echoxy[], char *str);
extern void	vrq_valuator	(int handle, int in, INT16 *out, INT16 *term);
extern void	vsc_form		(int handle, INT16 form[]);
extern int	vsin_mode		(int handle, int dev, int mode);
extern int	vsm_choice		(int handle, INT16 *choice);
extern int	vsm_locator		(int handle, int x, int y, INT16 *xout, INT16 *yout, INT16 *term);
extern int	vsm_string		(int handle, int len, int echo, INT16 echoxy[], char *str);
extern void	vsm_valuator	(int handle, int in, INT16 *out, INT16 *term, INT16 *status);
/*
 * output functions
*/
extern void	v_arc				(int handle, int x, int y, int radius, int begang, int endang);
extern void	v_bar				(int handle, INT16 pxyarray[]);
extern void	v_cellarray			(int handle, INT16 pxyarray[], int row_length, int elements, int nrows, int write_mode, INT16 colarray[]);
extern void	v_circle			(int handle, int x, int y, int radius);
extern void	v_contourfill		(int handle, int x, int y, int index);
extern void	v_ellarc			(int handle, int x, int y, int xrad, int yrad, int begang, int endang);
extern void	v_ellipse			(int handle, int x, int y, int xrad, int yrad);
extern void	v_ellpie			(int handle, int x, int y, int xrad, int yrad, int begang, int endang);
extern void	v_fillarea			(int handle, int count, INT16 pxyarray[]);
extern void	v_gtext				(int handle, int x, int y, char *str) ;
extern void	v_gtext16			(int handle, int x, int y, INT16 *wstr, int wstrlen) ;
extern void	v_justified			(int handle, int x, int y, char *str, int len, int word_space, int char_space);
extern void	v_pieslice			(int handle, int x, int y, int radius, int begang, int endang);
extern void	v_pline				(int handle, int count, INT16 pxyarray[]);
extern void	v_pmarker			(int handle, int count, INT16 pxyarray[]);
extern void	v_rbox				(int handle, INT16 pxyarray[]);
extern void	v_rfbox				(int handle, INT16 pxyarray[]);
extern void	vr_recfl			(int handle, INT16 pxyarray[]);
/*
 * raster functions
*/
extern void	v_get_pixel			(int handle, int x, int y, INT16 *pel, INT16 *index);
extern void	vr_trnfm			(int handle, MFDB *src, MFDB *dst);
extern void	vro_cpyfm			(int handle, int mode, INT16 pxyarray[], MFDB *src, MFDB *dst);
extern void	vrt_cpyfm			(int handle, int mode, INT16 pxyarray[], MFDB *src, MFDB *dst, INT16 color[]);
/*
 * Some usefull extensions.
*/
extern void	vdi_array2str		(INT16 *src, char *des, int len);
extern int	vdi_str2array		(char *src, INT16 *des);
/*
 * vdi trap interface
*/
/* Array sizes in vdi control block */
#define VDI_CNTRLMAX   15
#define VDI_INTINMAX   1024
#define VDI_INTOUTMAX  256
#define VDI_PTSINMAX   256
#define VDI_PTSOUTMAX  256

typedef struct
{
	INT16 *control;
	INT16 *intin;
	INT16 *ptsin;
	INT16 *intout;
	INT16 *ptsout;
} VDIPB;

extern INT16	vdi_intin[], vdi_intout[],	vdi_ptsin[], vdi_ptsout[];
extern INT16	vdi_control[];
extern VDIPB	vdi_params;
extern void vdi(VDIPB *pb);

#endif /* VDI */

#ifdef __cplusplus
}
#endif
#endif
