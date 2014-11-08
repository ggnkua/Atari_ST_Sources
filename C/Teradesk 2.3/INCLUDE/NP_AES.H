/*	AES.H
	
	GEM AES Definitions
	
	Copyright (c) Borland International 1990
	All Rights Reserved.
	
	mrt 1992 H. Robbers Amsterdam:
	
	space --> tabs.
	prefixes in structs removed.
	lists of #defines replaced by enums.
	types in aggregates amalgamated.
	VRECT (x,y,jx,jy); juxtapositioned coordinates (x1,y1,x2,y2)

	12-07-93  PC 1.1
	12-04-99  Multi Threading AES and further modernization
				and paramaterize 16 bit types.
	18-04-99  Reinstate prefixes; now under condition.
	13-12-02  Introduced independant usage of RECT{x,y,w,h}

	As you will notice, I use a different name for int in the prototypes.
	These are used program internally only.
	If your compiler thinks 32 bits are better, then USE that, or
	get yourself another compiler.
	And if that is not of convenience you should rethink the whole idee
	of promoting int to 32,
	Of course for the other compiler you must recompile the package.
	
	The integral item's that are passed directly to the OS are parameterized.
	These are G_i, G_u, G_l & G_ul.
	The sizes of pointers are not paramaterized.
*/

/* define G_NOPREFIX=1 or G_PRFXS=0 in the prj if you do not want to have
   structure local prefixes */

#if  !defined __AES__
#define __AES__

#ifndef PRELUDE_H
#include <prelude.h>
#endif

/****** GEMparams *******************************************************/

#ifdef G_NOPREFIX
	#ifndef G_PRFXS
	#define G_PRFXS 0
	#endif
#else
	#ifndef G_PRFXS
	#define G_PRFXS 1		/* want to use #if */
	#endif
#endif

#include <gempb.h>		/* These hold the basics used in the lib itself */

/****** Event definitions ***********************************************/

typedef enum
{
	MN_SELECTED		=10,
	WM_REDRAW		=20,
	WM_TOPPED,
	WM_CLOSED,
	WM_FULLED,
	WM_ARROWED,
	WM_HSLID,
	WM_VSLID,
	WM_SIZED,
	WM_MOVED,
	WM_NEWTOP,
	WM_UNTOPPED		=30,	/* GEM  2.x	*/
	WM_ONTOP,    			/* AES 4.0	*/
	WM_UNKNOWN,				/* AES 4.1	*/
	WM_BACK,				/* WINX 	*/
	WM_BOTTOMED = WM_BACK,	/* AES 4.1	*/
	WM_ICONIFY,				/* AES 4.1 	*/
	WM_UNICONIFY,			/* AES 4.1	*/
	WM_ALLICONIFY,			/* AES 4.1	*/
	WM_TOOLBAR,				/* AES 4.1	*/
	AC_OPEN			=40,
	AC_CLOSE,
	CT_UPDATE		=50,
	CT_MOVE,
	CT_NEWTOP,
	CT_KEY,
	AP_TERM			=50,
	AP_TFAIL,
	AP_AESTERM,				/* AES 4.1  */
	AP_RESCHG		=57,
	SHUT_COMPLETED	=60,
	RESCH_COMPLETED,
	AP_DRAGDROP		=63,
	SH_WDRAW		=72,	/* MultiTOS    */
	SC_CHANGED		=80,	/* MultiTOS    */
	PRN_CHANGED		=82,
	FNT_CHANGED,
	THR_EXIT		=88,	/* MagiC 4.5	*/
	PA_EXIT,				/* MagiC 3     */
	CH_EXIT			=90,	/* MultiTOS    */
	WM_M_BDROPPED	=100,	/* KAOS 1.4    */
	SM_M_SPECIAL,			/* MAG!X       */
	SM_M_RES2,				/* MAG!X       */
	SM_M_RES3,				/* MAG!X       */
	SM_M_RES4,				/* MAG!X       */
	SM_M_RES5,				/* MAG!X       */
	SM_M_RES6,				/* MAG!X       */
	SM_M_RES7,				/* MAG!X       */
	SM_M_RES8,				/* MAG!X       */
	SM_M_RES9,				/* MAG!X       */
/*	XA_M_CNF = 200,			/* XaAES  scl  */
	XA_M_SCL,
	XA_M_OPT,
	XA_M_GETSYM,
	XA_M_DESK,
	XA_M_EXEC = 250,
	XA_M_OK = 300,
*/	WM_SHADED		=22360,	/* [WM_SHADED apid 0 win 0 0 0 0] */
	WM_UNSHADED		=22361	/* [WM_UNSHADED apid 0 win 0 0 0 0] */
} MESAG_TY;

typedef enum
{
	GAI_WDLG = 0x0001,		/* wdlg_xx()-Funktionen vorhanden */
	GAI_LBOX = 0x0002,		/* lbox_xx()-Funktionen vorhanden */
	GAI_FNTS = 0x0004,		/* fnts_xx()-Funktionen vorhanden */
	GAI_FSEL = 0x0008,		/* neue Dateiauswahl vorhanden */

	GAI_MAGIC= 0x0100,		/* MagiC-AES vorhanden */
	GAI_INFO = 0x0200,		/* appl_getinfo() vorhanden */
	GAI_3D   = 0x0400,		/* 3D-Look vorhanden */
	GAI_CICN = 0x0800,		/* Color-Icons vorhanden */
	GAI_APTERM = 0x1000,	/* AP_TERM wird unterstÅtzt */
	GAI_GSHORTCUT = 0x2000,	/* Objekttyp G_SHORTCUT wird unterstÅtzt */
	GAI_WHITEBAK = 0x4000	/* WHITEBAK objects */
} GAI;

typedef struct
{
	G_l	magic;							/* muû $87654321 sein */
	void *membot;						/* Ende der AES-Variablen */
	void *aes_start;					/* Startadresse */

	G_l	magic2;							/* ist 'MAGX' */
	G_l	date;							/* Erstelldatum: ttmmjjjj */
	void (*chgres)( G_i res, G_i txt );	/* Auflîsung Ñndern */
	G_l	(**shel_vector)(void);			/* ROM-Desktop */
	G_b *aes_bootdrv;					/* Hierhin kommt DESKTOP.INF */
	G_i	*vdi_device;					/* vom AES benutzter Treiber */
	void *reservd1;
	void *reservd2;
	void *reservd3;

	G_i version,						/* Versionsnummer */
	    release;						/* Release-Status */

} AESVARS;

typedef	void *DOSVARS;						/* wird in diesem Source nicht benutzt */

typedef struct
{
	G_l		config_status;
	DOSVARS	*dosvars;
	AESVARS	*aesvars;
} MAGX_COOKIE;

/* MultiTOS Drag&Drop definitions */

typedef enum
{
	DD_OK,
	DD_NAK,
	DD_EXT,
	DD_LEN,
	DD_TRASH,
	DD_PRINTER,
	DD_CLIPBOARD,
	
	DD_TIMEOUT = 2000,			/* Timeout in ms */
	DD_EXTSIZE = 32,			/* LÑnge des Formatfelds */
	DD_NAMEMAX = 128,			/* maximale LÑnge eines Formatnamens */

	DD_NUMEXTS = 8,				/* Anzahl der Formate */
	DD_HDRMIN  = 9,				/* minimale LÑnge des Drag&Drop-Headers */

	DD_HDRMAX  = ( 8 + DD_NAMEMAX )	/* maximale LÑnge */
} DD_S;

#define DD_FNAME	"U:\\PIPE\\DRAGDROP.AA"

/****** Application definitions *****************************************/

typedef struct
{
	G_i	 dst_apid;
	G_i	 unique_flg;
	void *attached_mem;
	G_i	 *msgbuf;
} XAESMSG;

/* SM_M_SPECIAL codes */

#define SMC_TIDY_UP		0							/* MagiC 2	*/
#define SMC_TERMINATE	1							/* MagiC 2	*/
#define SMC_SWITCH		2							/* MagiC 2	*/
#define SMC_FREEZE		3							/* MagiC 2	*/
#define SMC_UNFREEZE	4							/* MagiC 2	*/
#define SMC_RES5		5							/* MagiC 2	*/
#define SMC_UNHIDEALL	6							/* MagiC 3.1	*/
#define SMC_HIDEOTHERS	7							/* MagiC 3.1	*/
#define SMC_HIDEACT		8							/* MagiC 3.1	*/
/* Keybord states */

typedef enum
{
	K_RSHIFT=0x0001,
	K_LSHIFT=0x0002,
	K_CTRL  =0x0004,
	K_ALT   =0x0008
} K_STATE;

/* this is our special invention to increase evnt_multi performance */

typedef struct /* Special type for EventMulti */
{
	/* input parameters */
	G_i     flags, bclicks, bmask, bstate, m1flags;
	        m1x, m1y,
	        m1width, m1height, m2flags,
	        m2x, m2y,
	        m2width, m2height,
	        tlocount, thicount;
	/* output parameters */
	G_i     wich,
			mox, moy,
			mobutton, mokstate,
	        kreturn, breturn;
	/* message buffer */
	G_i     mgpbuf[8];
} EVENT;

G_w G_decl G_n(EvntMulti)( EVENT *evnt_struct dglob);


/****** Object definitions **********************************************/
typedef enum
{
	G_BOX		= 20,
	G_TEXT,
	G_BOXTEXT,
	G_IMAGE,
	G_USERDEF,
	G_PROGDEF	= G_USERDEF,
	G_IBOX,
	G_BUTTON,
	G_BOXCHAR,
	G_STRING,
	G_FTEXT,
	G_FBOXTEXT,
	G_ICON,
	G_TITLE,
	G_CICON,

/* HR: for completeness */

	G_SWBUTTON,		/* MAG!X       */
	G_POPUP,		/* MAG!X       */
	G_WINTITLE,		/* MagiC 3.1	*/
	G_EDIT,
	G_SHORTCUT,		/* MagiC 6 */
	G_SLIST,		/* XaAES extended object - scrolling list */
	G_UNKNOWN,
	G_MAX			/* Maximum number of object types */
} OBJECT_TY;

/* Object flags */

typedef enum
{
	NONE	  = 0x0000,
	SELECTABLE= 0x0001,
	DEFAULT	  = 0x0002,
	EXIT      = 0x0004,
	EDITABLE  = 0x0008,
	RBUTTON	  = 0x0010,
	LASTOB    = 0x0020,
	TOUCHEXIT = 0x0040,
	HIDETREE  = 0x0080,
	INDIRECT  = 0x0100,
	FLD3DIND  = 0x0200,	/* 3D Indicator			  AES 4.0		*/
	FLD3DBAK  = 0x0400,	/* 3D Background		  AES 4.0		*/
	FLD3DACT  = 0x0600,	/* 3D Activator			  AES 4.0		*/
	FLD3DMASK = 0x0600,
	FLD3DANY  = 0x0600,
	SUBMENU   = 0x0800
} OB_FLAG;

/* Object states */

typedef enum
{
	NORMAL   = 0x00,
	SELECTED = 0x01,
	CROSSED  = 0x02,
	CHECKED  = 0x04,
	DISABLED = 0x08,
	OUTLINED = 0x10,
	SHADOWED = 0x20,
	WHITEBAK = 0x40,	/* TOS     & MagiC */
	DRAW3D   = 0x80		/* GEM 2.x         */
} OB_STATE;

/* objc_sysvar */

typedef enum
{
	SV_INQUIRE,
	SV_SET,
	LK3DIND     = 1,	/* AES 4.0     */
	LK3DACT,		/* AES 4.0     */
	INDBUTCOL,		/* AES 4.0     */
	ACTBUTCOL,		/* AES 4.0     */
	BACKGRCOL,		/* AES 4.0     */
	AD3DVAL,		/* AES 4.0     */
	MX_ENABLE3D = 10	/* MagiC 3.0   */
} OB_SYSVAR;

/* Object colors */
#if !defined __COLORS
#define __COLORS		/*	using AES-colors and BGI-colors
							is not possible	*/
typedef enum
{
	WHITE,		/* Object colors */
	BLACK,
	RED,
	GREEN,
	BLUE,
	CYAN,
	YELLOW,
	MAGENTA,
	LWHITE,
	LBLACK,
	LRED,
	LGREEN,
	LBLUE,
	LCYAN,
	LYELLOW,
	LMAGENTA
} OB_COLOURS;

#endif

#define ROOT             0
#define MAX_LEN         81              /* max string length */
#define MAX_DEPTH       32              /* max depth of search or draw */


#define IBM             3               /* font types */
#define SMALL           5

typedef enum
{
/* Form library definitions */
	ED_START,			/* Editable text field definitions */
	EDSTART = ED_START,
	ED_INIT,
	EDINIT	= ED_INIT,
	ED_CHAR,
	EDCHAR	= ED_CHAR,
	ED_END,
	EDEND	= ED_END
} ED_MODE;

typedef enum
{
	TE_LEFT,							/* editable text justification */
	TE_RIGHT,
	TE_CNTR
} TE_JUST;

typedef struct orect
{
#if G_PRFXS
	struct	orect   *o_link;
	G_i		o_x,o_y,o_w,o_h;
#else
	struct	orect   *link;
	G_i		x,y,w,h;
#endif
} ORECT;

typedef struct {G_i x, y, w, h; } RECT;

typedef struct
{
	G_i x,y,
		jx,jy;		/* VDI rectangle */
} VRECT;

/* Object structures */

/* From Atari Compendium - not sure if the bitfield stuff works properly with
   GNU or Pure C, but it's fine with Lattice */
/* HR: its perfectly good for Pure C. (But it *must* be 'int'
       so I parameterized this mode using bits & ubits */
typedef struct objc_coloours
{
	ubits borderc	:4;
	ubits textc		:4;
	ubits opaque	:1;
	ubits pattern	:3;
	ubits fillc		:4;
} OBJC_COLOURS;

#if XAAES
typedef struct
{
	char	*te_ptext,     
			*te_ptmplt,
			*te_pvalid;
	G_i		te_font,
			te_fontid,		/* AES 4.1 extension */
			te_just;
	OBJC_COLOURS te_color;
	G_i		te_fontsize,		/* AES 4.1 extension */
			te_thickness,
			te_txtlen,
			te_tmplen;
} TEDINFO;

#elif G_PRFXS
typedef struct
{
	char	*te_ptext,     
			*te_ptmplt,
			*te_pvalid;
	G_i		te_font,
			te_fontid,		/* AES 4.1 extension */
			te_just,
			te_color,
	 		te_fontsize,		/* AES 4.1 extension */
			te_thickness,
			te_txtlen,
			te_tmplen;
} TEDINFO;
#else
typedef struct
{
	char	*text,       /* ptr to text (must be 1st)    */
			*tmplt,      /* ptr to template              */
			*valid;      /* ptr to validation            */
	G_i		font,        /* font                         */
			fontid,		 /* AES 4.1 extension            */
			just;        /* justification: left, right...*/
	OBJC_COLOURS color;  /* color information            */
	G_i		fontsize,	 /* AES 4.1 extension            */
			thickness,   /* border thickness             */
			txtlen,      /* text string length           */
			tmplen;      /* template string length       */
} TEDINFO;
#endif

#if G_PRFXS
typedef struct
{
	G_i		*ib_pmask,
			*ib_pdata;
	char	*ib_ptext;
	G_i		ib_char,
			ib_xchar,
			ib_ychar;
#if AES_RECT
	RECT    ic,tx;
#else
	G_i		ib_xicon,
			ib_yicon,
			ib_wicon,
			ib_hicon,
			ib_xtext,
			ib_ytext,
			ib_wtext,
			ib_htext;
#endif
} ICONBLK;
#else
typedef struct
{
	G_i		*mask,
			*data;
	char	*text;
	G_i		ch,
			xchar,
			ychar;
#if AES_RECT
	RECT    ic,tx;
#else
	G_i		xicon,
			yicon,
			wicon,
			hicon,
			xtext,
			ytext,
			wtext,
			htext;
#endif
} ICONBLK;
#endif

typedef struct cicon_data
{
        G_i         num_planes;		/* Number of planes in the following data          */
        G_i         *col_data;		/* Pointer to color bitmap in standard form        */
        G_i         *col_mask;		/* Pointer to single plane mask of col_data        */
        G_i         *sel_data;		/* Pointer to color bitmap of selected icon        */
        G_i         *sel_mask;		/* Pointer to single plane mask of selected icon   */
        struct
        cicon_data  *next_res;		/* Pointer to next icon for a different resolution */
} CICON;


typedef struct cicon_blk
{
        ICONBLK            monoblk;
        CICON              *mainlist;
} CICONBLK;

typedef struct
{
#if G_PRFXS || XAAES
	G_i	*bi_pdata,
		bi_wb,
		bi_hl,
		bi_x,
		bi_y,
		bi_color;
#else
	G_i	*data,               /* ptr to bit forms data        */
		wb,                  /* width of form in bytes       */
		hl,                  /* height in lines              */
		x,                   /* source x in bit form         */
		y,                   /* source y in bit form         */
		color;               /* foreground color             */
#endif
} BITBLK;

#if XAAES
typedef struct parmblk
{
	struct object *pb_tree;
	G_i   pb_obj,
	      pb_prevstate;
	      pb_currstate;
	RECT r,c;
	G_l pb_parm;
} PARMBLK;
#elif G_PRFXS
typedef struct parmblk
{
	struct object *pb_tree;
	G_i		pb_obj,
			pb_prevstate,
			pb_currstate;
#if AES_RECT
	RECT 	r,c;
#else
	G_i     pb_x, pb_y, pb_w, pb_h;
	G_i     pb_xc, pb_yc, pb_wc, pb_hc;
#endif
	G_ul    pb_parm;
} PARMBLK;
#else
typedef struct parmblk
{
	struct object *tree;
	G_i		obj,
			prevstate,
			currstate;
	RECT	size,
			clip;
	union
	{
		G_l  parm;
		char *text;
	} P;
} PARMBLK;
#endif


#if !((defined  __STDC__) && CDECL)  || XAAES
/*	   using this structure is not possible
 *      if ANSI keywords only is ON, and __Cdecl is non empty
 */
typedef struct __parmblk
{
	int __Cdecl (*ub_code)(PARMBLK *parmblock);
	long ub_parm;
} USERBLK;

/* common used different naming */
typedef struct parm_blk
{
	int __Cdecl (*ab_code)(PARMBLK *parmblock);
	long ab_parm;
} APPLBLK;						/* is this the USERBLK ? */
#endif

typedef struct
{
	unsigned char
		character,
		framesize;
	OBJC_COLOURS
		colours;
} SPEC;

typedef struct
{
	unsigned character   :  8;
	signed   framesize   :  8;
	unsigned framecol    :  4,
			 textcol     :  4,
			 textmode    :  1,
			 fillpattern :  3,
			 interiorcol :  4;
} bfobspec;

typedef union obspecptr
{
	long      index;
	long      lspec;
	union obspecptr
	         *indirect;
	bfobspec  obspec;
	SPEC      this;
	TEDINFO	 *tedinfo;
	ICONBLK	 *iconblk;
	CICONBLK *ciconblk;
	BITBLK	 *bitblk;
#if !((defined  __STDC__) && CDECL) || XAAES
/*	   using this structure is not possible
 *      if ANSI keywords only is ON, and __Cdecl is non empty
 */
	USERBLK  *userblk;
	APPLBLK  *appblk;
#endif
#if XAAES
	struct scroll_info
	         *listbox;
#endif
	char	 *free_string;
	char 	 *string;
	void     *v;
} OBSPEC;

#if G_PRFXS
typedef struct object
{
	G_i		ob_next, ob_head, ob_tail;
	unsigned
	G_i		ob_type, ob_flags, ob_state;
	OBSPEC	ob_spec;
#if AES_RECT
	RECT	r;
#else
	G_i		ob_x, ob_y, ob_width, ob_height;
#endif
} OBJECT;
#else
typedef struct object
{
	G_i		next,		/* -> object's next sibling     */
			head,		/* -> head of object's children */
			tail;		/* -> tail of object's children */
	unsigned
	G_i		type,		/* object type: BOX, CHAR,...   */
			flags,		/* object flags                 */
			state;		/* state: SELECTED, OPEN, ...   */
	OBSPEC	spec;		/* "out": -> anything else      */
#if AES_RECT
	RECT	r;
#else
/* The following is in fact a RECT, but is too offten used to change it */
	G_i		x,			/* upper left corner of object  */
			y,			/* upper left corner of object  */
			w,			/* object width                 */
			h;			/* object height                */
#endif
} OBJECT;
#endif

#if G_PRFXS
typedef struct
{
        OBJECT  *mn_tree;
        G_i     mn_menu,
                mn_item,
                mn_scroll,
                mn_keystate;
} MENU;
#else
typedef struct
{
        OBJECT  *tree;
                menu,
                item,
                scroll,
                keystate;
} MENU;
#endif

typedef struct
{
        long   display,
               drag,
               delay,
               speed;
        G_i    height;
} MN_SET;

typedef struct
{	
	char	*string;		/* etwa "TOS|KAOS|MAG!X"          */	
	G_i     num,			/* Nr. der aktuellen Zeichenkette */
			maxnum;			/* maximal erlaubtes <num>        */
} SWINFO;

typedef struct
{
     OBJECT	*tree;		/* Popup- MenÅ                    */
     G_i	 obnum;		/* aktuelles Objekt von <tree>    */
} POPINFO;

/****** Menu definitions ************************************************/

/* menu_bar modes */

/* Menu bar install/remove codes */

typedef enum
{
	MENU_INQUIRE =-1,
	MENU_HIDE,					/* TOS         */
	MENU_REMOVE = MENU_HIDE,
	MENU_SHOW,					/* TOS         */
	MENU_INSTALL = MENU_SHOW,
	MENU_INSTL = 100			/* MAG!X       */
} MBAR_DO;

#define ME_INQUIRE   0		/* HR: menu_attach codes */
#define ME_ATTACH    1
#define ME_REMOVE    2

/****** Form definitions ************************************************/

typedef enum
{
	FMD_START,
	FMD_GROW,
	FMD_SHRINK,
	FMD_FINISH
} FMD_TY;

typedef struct	/* form_xdo definitions */
{
	char scancode;
	char nclicks;
	G_i  objnr;
} SCANX;

typedef struct
{
	SCANX	*unsh;
	SCANX	*shift;
	SCANX	*ctrl;
 	SCANX	*alt;
	void	*resvd;
} XDO_INF;

#if G_PRFXS
typedef struct _xted
{
	char *xte_ptmplt;
	char *xte_pvalid;
	G_i	  xte_vislen;
	G_i	  xte_scroll;
} XTED;
#else
typedef struct _xted /* scrollable textedit objects */
{
	char *tmplt;
	char *valid;
	G_i	  vislen;
	G_i	  scroll;
} XTED;
#endif


/****** Graph definitions ************************************************/

/* Mouse forms */

typedef enum
{
	ARROW,
	TEXT_CRSR,
	HOURGLASS,
	BUSYBEE   = HOURGLASS,
	BUSY_BEE  = HOURGLASS,
	POINT_HAND,
	FLAT_HAND,
	THIN_CROSS,
	THICK_CROSS,
	OUTLN_CROSS,
	USER_DEF    = 255,
	M_OFF,
	M_ON,
	M_SAVE,
	M_LAST,
	M_RESTORE,
	M_FORCE     = 0x8000,
	M_PUSH      = 100,
	M_POP
} MICE;

/* Mouse form definition block */
#if G_PRFXS
typedef struct mfstr
{
	G_i	mf_xhot,
		mf_yhot,
		mf_nplanes,
		mf_fg,
		mf_bg,
		mf_mask[16],
		mf_data[16];
} MFORM;
#else
typedef struct mfstr
{
	G_i	xhot,
		yhot,
		nplanes,
		fg,
		bg,
		mask[16],
		data[16];
} MFORM;
#endif



/****** Window definitions **********************************************/

typedef enum 
{
	NAME		=0x0001,
	CLOSE		=0x0002,
	CLOSER		=CLOSE,
	FULL		=0x0004,
	FULLER		=FULL,
	MOVE		=0x0008,
	MOVER		=MOVE,
	INFO		=0x0010,
	SIZE		=0x0020,
	SIZER		=SIZE,
	UPARROW		=0x0040,
	DNARROW		=0x0080,
	VSLIDE		=0x0100,
	LFARROW		=0x0200,
	RTARROW		=0x0400,
	HSLIDE		=0x0800,
	MENUBAR		=0x1000,		/* XaAES     */
	HOTCLOSEBOX =0x1000,		/* GEM 2.x   */
	BACKDROP    =0x2000,		/* KAOS 1.4  */
	ICONIFY     =0x4000,			/* iconifier */
	ICONIFIER	=ICONIFY,
	SMALLER		=ICONIFY
} WIND_ATTR;

typedef enum
{
	WF_KIND=1,
	WF_NAME,
	WF_INFO,
	WF_WXYWH,
	WF_WORKXYWH	=	WF_WXYWH,
	WF_CXYWH,
	WF_CURRXYWH	=	WF_CXYWH,
	WF_PXYWH,
	WF_PREVXYWH	=	WF_PXYWH,
	WF_FXYWH,
	WF_FULLXYWH	=	WF_FXYWH,
	WF_HSLIDE,
	WF_VSLIDE,
	WF_TOP,
	WF_FIRSTXYWH,
	WF_NEXTXYWH,
	WF_RESVD,
	WF_NEWDESK,
	WF_HSLSIZE,
	WF_HSLSIZ	=	WF_HSLSIZE,
	WF_VSLSIZE,
	WF_VSLSIZ	=	WF_VSLSIZE,
	WF_SCREEN,
	WF_COLOR,
	WF_DCOLOR,
	WF_OWNER,				/* AES 4       */
	WF_BEVENT = 24,
	WF_BOTTOM,
	WF_ICONIFY,				/* AES 4.1     */
	WF_UNICONIFY,			/* AES 4.1     */
	WF_UNICONIFYXYWH,		/* AES 4.1     */
	WF_TOOLBAR = 30,		/* compatible  */
	WF_FTOOLBAR,
	WF_NTOOLBAR,
	WF_MENU,
	WF_WIDGET,
	WF_LAST,				/* end of contiguous range */
	WF_WHEEL       =40,		/* wheel support */
	WF_M_BACKDROP  = 100,	/* KAOS 1.4    */
	WF_M_OWNER,				/* KAOS 1.4    */
	WF_M_WINDLIST,			/* KAOS 1.4    */
	WF_SHADE       =0x575d,	/* WINX 2.3	*/
	WF_STACK	   =0x575e,	/* WINX 2.3	*/
	WF_TOPALL	   =0x575f,	/* WINX 2.3	*/
	WF_BOTTOMALL   =0x5760	/* WINX 2.3	*/
} WIND_CODE;

typedef enum
{
	W_BOX ,
	W_TITLE,
	W_CLOSER,
	W_NAME,
	W_FULLER,
	W_INFO,
	W_DATA,
	W_WORK,
	W_SIZER,
	W_VBAR,
	W_UPARROW,
	W_DNARROW,
	W_VSLIDE,
	W_VELEV,
	W_HBAR,
	W_LFARROW,
	W_RTARROW,
	W_HSLIDE,
	W_HELEV,
	W_SMALLER,		/* AES 4.1     */
	W_BOTTOMER,		/* MagiC 3     */
	W_HIDER  = W_BOTTOMER,
	W_HIGHEST
} WIDGET_I;

/* wind_set(WF_BEVENT) */

typedef enum
{
	BEVENT_WORK=1,		/* AES 4.0	*/
	BEVENT_INFO,		/* MagiC 6	*/
} BEVENT;

typedef enum
{
	WA_UPPAGE,
	WA_DNPAGE,
	WA_UPLINE,
	WA_DNLINE,
	WA_LFPAGE,
	WA_RTPAGE,
	WA_LFLINE,
	WA_RTLINE,
	WA_WHEEL			/* wheel support */
} WIND_ARROW;

typedef enum
{
	WC_BORDER,						/* wind calc flags */
	WC_WORK
} WIND_CALC_C;

typedef enum
{
	END_UPDATE,
	BEG_UPDATE,
	END_MCTRL,
	BEG_MCTRL,
	BEG_EMERG,
	END_EMERG
} WIND_UPDATE;


/****** Resource definitions ********************************************/

typedef enum					/* data structure types */
{
	R_TREE,
	R_OBJECT,
	R_TEDINFO,
	R_ICONBLK,
	R_BITBLK,
	R_STRING,					/* gets pointer to free strings */
	R_IMAGEDATA,				/* gets pointer to free images */
	R_OBSPEC,
	R_TEPTEXT,					/* sub ptrs in TEDINFO */
	R_TEPTMPLT,
	R_TEPVALID,
	R_IBPMASK,					/* sub ptrs in ICONBLK */
	R_IBPDATA,
	R_IBPTEXT,
	R_BIPDATA,					/* sub ptrs in BITBLK */
	R_FRSTR,					/* gets addr of ptr to free strings */
	R_FRIMG,					/* gets addr of ptr to free images  */
} RSRC_TYPE;

#if XAAES
typedef struct rsc_hdr
{
	G_i   rsh_vrsn;			/* RCS version no. */
	G_u   rsh_object,	/* Offset to object[] */
	      rsh_tedinfo,	/* Offset to tedinfo[] */
	      rsh_iconblk,	/* Offset to iconblk[] */
	      rsh_bitblk,	/* Offset to bitblk[] */
	      rsh_frstr,	/* Offset to free string index */
	      rsh_string,	/* HR: unused (Offset to first string) */
	      rsh_imdata,	/* Offset to image data */
	      rsh_frimg,	/* Offset to free image index */
	      rsh_trindex;	/* Offset to object tree index */
	G_i   rsh_nobs,		/* Number of objects */
	      rsh_ntree,	/* Number of trees */
	      rsh_nted,		/* Number of tedinfos */
	      rsh_nib,		/* Number of icon blocks */
	      rsh_nbb,		/* Number of blt blocks */
	      rsh_nstring,	/* Number of free strings */
	      rsh_nimages;	/* Number of free images */
	G_u   rsh_rssize;	/* Total bytes in resource */
} RSHDR;
#elif G_PRFXS
typedef struct rshdr
{
	G_i	rsh_vrsn,
		rsh_object,
		rsh_tedinfo,
		rsh_iconblk,    /* list of ICONBLKS */
		rsh_bitblk,
		rsh_frstr,
		rsh_string,
		rsh_imdata,     /* image data */
		rsh_frimg,
		rsh_trindex,
		rsh_nobs,       /* counts of various structs */
		rsh_ntree,
		rsh_nted,
		rsh_nib,
		rsh_nbb,
		rsh_nstring,
		rsh_nimages,
		rsh_rssize;     /* total bytes in resource */
} RSHDR;
#else
typedef struct rshdr
{
	G_i	vrsn,
		object,
		tedinfo,
		iconblk,    /* list of ICONBLKS */
		bitblk,
		frstr,
		string,
		imdata,     /* image data */
		frimg,
		trindex,
		nobs,       /* counts of various structs */
		ntree,
		nted,
		nib,
		nbb,
		nstring,
		nimages,
		rssize;     /* total bytes in resource */
} RSHDR;
#endif

/****** Shell definitions ***********************************************/

/* tail for default shell */

typedef struct
{
	G_i  dummy;                   /* ein Nullwort               */
	long magic;                   /* 'SHEL', wenn ist Shell     */
	G_i  isfirst;                 /* erster Aufruf der Shell    */
	long lasterr;                 /* letzter Fehler             */
	G_i  wasgr;                   /* Programm war Grafikapp.    */
} SHELTAIL;

/* shel_write modes for parameter "isover" */

typedef enum
{
	SHW_IMMED,			/* PC-GEM 2.x  */
	SHW_CHAIN,			/* TOS         */
	SHW_DOS,			/* PC-GEM 2.x  */
	SHW_PARALLEL=100,	/* MAG!X       */
	SHW_SINGLE			/* MAG!X       */
} SHW_ISOVER;

/* shel_write modes for parameter "doex" */

typedef enum
{
	SHW_NOEXEC,
	SHW_EXEC,
	SHW_EXEC_ACC =3,		/* AES 3.3	*/
	SHW_SHUTDOWN,			/* AES 3.3     */
	SHW_RESCHNG,			/* AES 3.3     */
	SHW_BROADCAST=7,		/* AES 4.0     */
	SHW_INFRECGN =9,		/* AES 4.0     */
	SHW_AESSEND,			/* AES 4.0     */
	SHW_THR_CREATE=20		/* MagiC 4.5	*/
} SHW_DOEX;

/* extended shel_write() modes and parameter structure */

typedef enum
{
	SHW_XMDLIMIT = 256,
	SHW_XMDNICE  = 512,
	SHW_XMDDEFDIR=1024,
	SHW_XMDENV   =2048,
	SHW_XMDFLAGS =4096
} SHW_XMD;

typedef struct {
	char *command;
	long limit;
	long nice;
	char *defdir;
	char *env;
	long flags;		/* ab MagiC 6 */
} XSHW_COMMAND;

/*
 *	XaAES/oAESis Extended Shell Write structure 
 *	- Extra fields for UID/GID setting of spawned clients.
 *  Different naming.
 */
typedef struct _xshelw
{
	char *newcmd;
	long psetlimit,
	     prenice;
	char *defdir;
	char *env;
	G_i   uid,            /* New child's UID */
	      gid;            /* New child's GID */
} XSHELW;

typedef enum
{
	SW_PSETLIMIT	= 0x100,
	SW_PRENICE		= 0x200,
	SW_PDEFDIR		= 0x400,
	SW_ENVIRON		= 0x800,
	SW_UID 			= 0x1000,	/* Set user id of launched child */
	SW_GID			= 0x2000	/* Set group id of launched child */
} XSHEL_SW;

#if !((defined  __STDC__) && CDECL)
/*	   using this structure is not possible
 *      if ANSI keywords only is ON, and __Cdecl is non empty
 */
typedef struct {
	long __Cdecl (*procedure)(void *par);
	void *user_stack;
	G_ul stacksize;
	G_i  mo;		/* immer auf 0 setzen! */
	long res1;		/* immer auf 0L setzen! */
} THREADINFO;
#endif

#ifndef AES_FUNC_H
#include <aes_func.h>
#endif

#if G_EXT
include <aes_xtnd.h>
#endif

extern G_w aes_handle,MagX_version,radio_bgcol;
extern bool MagX,MiNT;
extern MAGX_COOKIE *magic;

#endif

