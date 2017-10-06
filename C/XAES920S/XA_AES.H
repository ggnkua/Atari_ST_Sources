/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
 *	Definitions for the standard GEM application data structures
 *	taken out of the AESBIND.H standard header
 */

#ifndef _K_DEFS_H_
#define _K_DEFS_H_

#ifdef __GNUC__
#define __stdargs
#define __regargs
#define far
#define __saveds
typedef short bits;				/* use these for bitfields */
typedef unsigned short ubits;
#endif

#ifdef __LATTICE__
typedef short bits;				/* use these for bitfields */
typedef unsigned short ubits;
#endif

#ifdef __PUREC__
#define far
#define __stdargs cdecl
#define __regargs
#define __saveds
#define short int

#if 0		/* in project file */
/* Switch off some of PC's warning messages */
/* HR: not by me :-) I want to see them, to keep me alert. */
#pragma warn -aus	/* 'foo' is assigned a value which is never used */
#pragma warn -rch	/* Unreachable code */
#pragma warn -stv	/* Structure passed by value */
#pragma warn -use	/* 'foo' declared but never used */
#pragma warn -cln	/* Constant is long */
#pragma warn -par	/* Parameter 'foo' is never used */
#endif

/* Pure C doesnt accept short for bit fields */
typedef int bits;				/* use these for bitfields */
typedef unsigned int ubits;

#endif /* __PUREC__ */

#include "xa_defs.h"

/* Event library definitions */
#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020
#define MU_MX		0x0040		/* HR: XaAES extension: report any mouse movement */
								/*                      used for recursive menu's */
#define MU_NORMKEY	0x0080		/* 					    return normalized key code. */

#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_CTRL		0x0004
#define K_ALT		0x0008

#define MN_SELECTED	10

#define SCR_MGR     0x0001	/* Process id of the screen manager - this is redundant */
							/* and will probably require a kludge to redirect it to the */
							/* 'real' desktop (check the AVSERVER variable?) */
#define AP_MSG           0

#define WM_REDRAW	20
#define WM_TOPPED	21
#define WM_CLOSED	22
#define WM_FULLED	23
#define WM_ARROWED	24
#define WM_HSLID	25
#define WM_VSLID	26
#define WM_SIZED	27
#define WM_MOVED	28
#define WM_NEWTOP	29
#define WM_UNTOPPED	30
#define WM_ONTOP	31
#define WM_OFFTOP	32
#define PR_FINISH	33		/* What is PR_FINISH? It has the same number as WM_BOTTOMED... */
#define WM_BOTTOMED	33
#define WM_BOTTOM	33

#define WM_ICONIFY			34
#define WM_UNICONIFY		35
#define WM_ALLICONIFY		36

#define AC_OPEN		40
#define AC_CLOSE	41

#define AP_TERM         50
#define AP_TFAIL        51
#define AP_RESCHG       57
#define SHUT_COMPLETED  60
#define RESCH_COMPLETED 61

#define SC_CHANGED		80
#define CH_EXIT         90
#define OLD_CH_EXIT		80

#define CT_UPDATE	50
#define CT_MOVE		51
#define CT_NEWTOP	52
#define CT_KEY		53

/* Drag'n'Drop */
#define AP_DRAGDROP			63
#define	DD_OK				0
#define DD_NAK				1
#define DD_EXT				2
#define DD_LEN				3
#define DD_TRASH			4
#define DD_PRINTER			5
#define DD_CLIPBOARD		6
#define DD_TIMEOUT			4000	/* Timeout in milliseconds */
#define DD_NUMEXTS			8
#define DD_EXTSIZE			32L
#define DD_NAMEMAX			128		/* Max size of a drag&drop item name */
#define DD_HDRMAX			(8 + DD_NAMEMAX)	/* Max length of a drag&drop header */

#define WA_UPPAGE	0
#define WA_DNPAGE	1
#define WA_UPLINE	2
#define WA_DNLINE	3
#define WA_LFPAGE	4
#define WA_RTPAGE	5
#define WA_LFLINE	6
#define WA_RTLINE	7

typedef struct moblk
{
	short m_out;
	short m_x;
	short m_y;
	short m_w;
	short m_h;
} MOBLK;

/* Object library definitions */
#define ROOT		0
/* #define NIL			-1		HR: a very wrong choice! */

#define MAX_DEPTH	32	/* Max depth of search or draw */

#define IP_HOLLOW	0	/* Inside patterns */
#define IP_1PATT	1
#define IP_2PATT	2
#define IP_3PATT	3
#define IP_4PATT	4
#define IP_5PATT	5
#define IP_6PATT	6
#define IP_SOLID	7
                           /* System foreground and */
                           /*   background rules    */
#define SYS_FG      0x1100 /*   but transparent     */

#define WTS_FG      0x11a1 /* Window title selected */
                           /*   using pattern 2 &   */
                           /*   replace mode text   */
#define WTN_FG      0x1100 /* Window title normal   */

#define IBM			3	/* Font types */
#define SMALL		5

typedef enum
{
	G_BOX		= 20,	/* Graphic types of obs	*/
	G_TEXT,
	G_BOXTEXT,
	G_IMAGE,
	G_PROGDEF,
	G_USERDEF	= G_PROGDEF,
	G_IBOX,
	G_BUTTON,
	G_BOXCHAR,
	G_STRING,
	G_FTEXT,
	G_FBOXTEXT,
	G_ICON,
	G_TITLE,
	G_CICON,

	G_SLIST,	/* XaAES extended object - scrolling list */

/* HR: for completeness */

	G_POPUP,		/* MAG!X       */
	G_RESVD1,		/* MagiC 3.1	*/
	G_EDIT,
	G_SHORTCUT,		/* MagiC 6 */
	G_UNKNOWN,
	G_MAX			/* Maximum number of object types */
} OB_TYPE;

typedef enum
{
	 NONE		= 0x0000,	/* Object flags	*/
	 SELECTABLE	= 0x0001,
	 DEFAULT	= 0x0002,
	 EXIT		= 0x0004,
	 EDITABLE	= 0x0008,
	 RBUTTON	= 0x0010,
	 LASTOB		= 0x0020,
	 TOUCHEXIT	= 0x0040,
	 HIDETREE	= 0x0080,
	 INDIRECT	= 0x0100,
	 FLD3DIND	= 0x0200,	/* AES3.3 and over extended object flags for 3d widgets */
	 FLD3DBAK	= 0x0400,	/* Atari Compendium mixes up FLD3DACT & FLD3DBAK */
	 FLD3DACT	= 0x0600,
	 FLD3DANY	= 0x0600,
	 SUBMENU	= 0x0800
} OB_FLAGS;

typedef enum
{
	 NORMAL		= 0x0000,	/* Object states */
	 SELECTED	= 0x0001,
	 CROSSED	= 0x0002,
	 CHECKED	= 0x0004,
	 DISABLED	= 0x0008,
	 OUTLINED	= 0x0010,
	 SHADOWED	= 0x0020,
	 SPECIAL	= 0x0040,	/* User defined object state */
	 WHITEBAK	= 0x0040,
	 DRAW3D		= 0x0080
} OB_STATES;

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

#define TE_LEFT		0	/* Editable text justification */
#define TE_RIGHT	1
#define TE_CNTR		2

typedef struct gem_rectangle
{
	short x,y,w,h;
} RECT;

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

typedef struct
{
	struct object *tree;
	short menu,item,scroll,keystate;
} MENU;

typedef struct
{
	long display,drag,delay,speed;
	short height;
} MN_SET;

typedef struct text_edinfo
{
	char *te_ptext;
	char *te_ptmplt;
	char *te_pvalid;
	short te_font;
	short te_fontid;		/* AES 4.1 extension */
	short te_just;
	OBJC_COLOURS te_color;
	short te_fontsize;		/* AES 4.1 extension */
	short te_thickness;
	short te_txtlen;
	short te_tmplen;
} TEDINFO;

/* AES 4.1 extended te_font types */
#define TE_GDOS_PROP	0	/* Use a proportional SPEEDOGDOS font */
#define TE_GDOS_MONO	1	/* Use a monospaced SPEEDOGDOS font */
#define TE_GDOS_BITM	2	/* Use a GDOS bitmap font */
#define TE_STANDARD		3	/* Use the standard system font (10 point) */
#define TE_SMALL		5	/* Use the small syatem font (8 point) */

typedef struct icon_block
{
	short *ib_pmask;
	short *ib_pdata;
	char *ib_ptext;
	short ib_char;
	short ib_xchar;
	short ib_ychar;
	RECT ic,tx;
} ICONBLK;

typedef struct cicon_data
{
	short num_planes;							/* Number of planes in the following data          */
	short *col_data;							/* Pointer to color bitmap in standard form        */
	short *col_mask;							/* Pointer to single plane mask of col_data        */
	short *sel_data;							/* Pointer to color bitmap of selected icon        */
	short *sel_mask;							/* Pointer to single plane mask of selected icon   */
	struct cicon_data *next_res;	/* Pointer to next icon for a different resolution */
}	CICON;

typedef struct cicon_blk
{
	ICONBLK monoblk;		/* Default monochrome icon                         */
	CICON *mainlist;		/* List of color icons for different resolutions */
}	CICONBLK;

typedef struct bit_block
{
	short *bi_pdata;
	short bi_wb;
	short bi_hl;
	short bi_x;
	short bi_y;
	OBJC_COLOURS colours;
} BITBLK;

typedef struct parm_blk
{
	struct object *pb_tree;
	short pb_obj;
	short pb_prevstate;
	short pb_currstate;
	RECT r,c;
	long pb_parm;
} PARMBLK;

typedef struct appl_blk
{
	int __stdargs (*ab_code)(PARMBLK *);		/* FIX_PC */
	long ab_parm;
} APPLBLK;						/* is this the USERBLK ? */

typedef struct
{
	unsigned char
		character,
		framesize;
	OBJC_COLOURS
		colours;
} SPEC;

typedef union obspecptr
{
	long      lspec;
	union obspecptr
	         *indirect;
	SPEC      this;
	TEDINFO  *tedinfo;
	ICONBLK  *iconblk;
	CICONBLK *ciconblk;
	BITBLK   *bitblk;
	APPLBLK  *appblk;
	struct scroll_info
	         *listbox;
	struct menu_attachments
	         *attachment;
	char     *string;
	void *v;
} OB_SPEC;

typedef struct object
{
	short ob_next;
	short ob_head;
	short ob_tail;
	unsigned short ob_type;
	unsigned short ob_flags;
	unsigned short ob_state;
	OB_SPEC ob_spec;
	RECT r;
} OBJECT;


#ifdef __GNUC__
typedef struct
{
	void		*fd_addr;   /* Addrerss of upper left corner of first*/
                                    /* plane of raster area. If NULL then   */
                                    /* MFDB is for a physical device        */
	short		fd_w;	    /* Form Width in Pixels                 */
	short		fd_h;       /* Form Height in Pixels                */
	short		fd_wdwidth; /* Form Width in shorts(fd_w/sizeof(int)*/
	short		fd_stand;   /* Form format 0= device spec 1=standard*/
	short		fd_nplanes; /* Number of memory planes              */
	short		fd_r1;      /* Reserved                             */
	short		fd_r2;      /* Reserved                             */
	short		fd_r3;      /* Reserved                             */
} MFDB;

#define S_ONLY 		3
#define S_OR_D 		7

#define MD_REPLACE	1
#define MD_TRANS	2
#define MD_XOR		3
#define MD_ERASE	4


/* Something out of the Lattice C includes */
#define FIS_HOLLOW	0
#define FIS_SOLID	1
#define FIS_PATTERN	2
#define FIS_HATCH	3
#define FIS_USER	4

#define	SOLID	0

#endif /* __GNUC__ */

#ifdef __PUREC__			/* in aes.h */
typedef struct mouse_form
	{
	short	mf_xhot;
	short 	mf_yhot;
	short 	mf_nplanes;
	short	mf_bg;
	short 	mf_fg;
	short 	mf_mask[16];
	short 	mf_data[16];
	} MFORM ;
#endif

/* New structures for scrolled list objects
   HR: moved to xa_types.h */

typedef struct grect
{
	short g_x;
	short g_y;
	short g_w;
	short g_h;
} GRECT;

/* Form library definitions */
#define ED_START	0	/* Editable text field definitions */
#define EDSTART	ED_START
#define ED_INIT	1
#define EDINIT	ED_INIT
#define ED_CHAR	2
#define EDCHAR	ED_CHAR
#define ED_END	3
#define EDEND	ED_END

#define FMD_START	0
#define FMD_GROW	1
#define FMD_SHRINK	2
#define FMD_FINISH	3

/* Graphics library definitions */
#define	ARROW		0
#define	TEXT_CRSR	1
#define	HOURGLASS	2
#define	BUSYBEE	HOURGLASS
#define	BUSY_BEE	HOURGLASS
#define	POINT_HAND	3
#define	FLAT_HAND	4
#define	THIN_CROSS	5
#define	THICK_CROSS	6
#define	OUTLN_CROSS	7
#define	USER_DEF	255
#define M_OFF		256
#define M_ON		257
#define M_PUSH         100
#define M_POP          101

#define VERTICAL	0
#define HORIZONTAL	1

/* Scrap library definitions */
#define SCRAP_CSV   0x0001
#define SCRAP_TXT   0x0002
#define SCRAP_GEM   0x0004
#define SCRAP_IMG   0x0008
#define SCRAP_DCA   0x0010
#define SCRAP_USR   0x8000

/* Window library definitions */
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
	HOTCLOSEBOX =0x1000,		/* GEM 2.x     */
	BACKDROP    =0x2000,		/* KAOS 1.4    */
	SMALLER     =0x4000,		/* iconifier */
} WIND_ATTR;

/* Alas! No long enum in C */
typedef unsigned long XA_WIND_ATTR;

#define USE_INTIN5 0x8000
typedef enum
{
	XMENU		=0x0001
} WIND_XATTR;

/* Extended XaAES Attributes */

/* Visible (settable) to the outside world (WIND_XATTR << 16) */
#define XaMENU		0x00010000L	/* Have a menu bar */


/* Internal */
#define STORE_BACK	0x80000000L	/* Store the background of a window & don't generate redraw  */
								/* messages to windows below */
#define NO_WORK		0x40000000L	/* A window with no work area */
#define NO_REDRAWS	0x20000000L	/* Don't generate WM_REDRAW messages to the owner app */
#define NO_MESSAGES	0x30000000L	/* Don't generate any messages at all to the owner app */
#define NO_LIST     0x08000000L /* Domt put this window in a list */
#define NO_TOPPED   0x04000000L	/* Send MU_BUTTON for a click on workarea, not WM_TOPPED */
#define XaTOP       0x02000000L /* Window stayes permanently on top (mostly popups) */
#define XaPOP		0x01000000L /* Special kind of window. */
/* visible widgets */
#define V_WIDG  (CLOSE|NAME|MOVE|SMALLER|FULL|XaMENU|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)

typedef enum
{
	WF_KIND		=	1,
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
	WF_IGNORE,
	WF_NEWDESK,
	WF_HSLSIZE,
	WF_HSLSIZ	=	WF_HSLSIZE,
	WF_VSLSIZE,
	WF_VSLSIZ	=	WF_VSLSIZE,
	WF_SCREEN,
	WF_COLOR,
	WF_DCOLOR,
	WF_OWNER,
	WF_BEVENT   =	24,
	WF_BOTTOM,
	WF_ICONIFY,
	WF_UNICONIFY,
	WF_UNICONIFYXYWH,
	WF_TOOLBAR  =	30,		/* compatible */
	WF_FTOOLBAR,
	WF_NTOOLBAR,
	WF_LAST
} WIND_SET;

/* XaAES Special modes */
#define WF_AUTOREDRAW		100		/* new */
#define WF_STOREBACK		101
#define WF_WIDGET			102
#define WF_MENU				110

/* XaAES extensions */

#define	END_UPDATE	0
#define	BEG_UPDATE	1
#define	END_MCTRL	2
#define	BEG_MCTRL	3
#define BEG_EMERG        4
#define END_EMERG        5

#define WC_BORDER	0
#define WC_WORK		1

#define DESK	0

#define	W_BOX		0
#define W_TITLE		1
#define W_CLOSER	2
#define W_NAME		3
#define W_FULLER	4
#define W_INFO		5
#define W_DATA		6
#define W_WORK		7
#define W_SIZER		8
#define W_VBAR		9
#define W_UPARROW	10
#define W_DNARROW	11
#define W_VSLlDE	12
#define W_VELEV		13
#define W_HBAR		14
#define W_LFARROW	15
#define W_RTARROW	16
#define W_HSLIDE	17
#define W_HELEV		18

/* Resource library definitions */
#define R_TREE		0
#define R_OBJECT	1
#define R_TEDINFO	2
#define R_ICONBLK	3
#define R_BITBLK	4
#define R_STRING	5	/* Gets pointer to free strings */
#define R_IMAGEDATA	6	/* Gets pointer to free images */
#define R_OBSPEC	7
#define R_TEPTEXT	8	/* Sub ptrs in TEDINFO */
#define R_TEPTMPLT	9
#define R_TEPVALID	10
#define R_IBPMASK	11	/* Sub ptrs in ICONBLK */
#define R_IBPDATA	12
#define R_IBPTEXT	13
#define R_BIPDATA	14	/* Sub ptrs in BITBLK */
#define R_FRSTR		15	/* Gets addr of ptr to free strings */
#define R_FRIMG		16	/* Gets addr of ptr to free images */

typedef struct
{
	short rsh_vrsn;			/* RCS version no. */
	unsigned short rsh_object;	/* Offset to object[] */
	unsigned short rsh_tedinfo;	/* Offset to tedinfo[] */
	unsigned short rsh_iconblk;	/* Offset to iconblk[] */
	unsigned short rsh_bitblk;	/* Offset to bitblk[] */
	unsigned short rsh_frstr;		/* Offset to free string index */
	unsigned short rsh_string;	/* HR: unused (Offset to first string) */
	unsigned short rsh_imdata;	/* Offset to image data */
	unsigned short rsh_frimg;		/* Offset to free image index */
	unsigned short rsh_trindex;	/* Offset to object tree index */
	short rsh_nobs;			/* Number of objects */
	short rsh_ntree;			/* Number of trees */
	short rsh_nted;			/* Number of tedinfos */
	short rsh_nib;			/* Number of icon blocks */
	short rsh_nbb;			/* Number of blt blocks */
	short rsh_nstring;		/* Number of free strings */
	short rsh_nimages;		/* Number of free images */
	unsigned short rsh_rssize;	/* Total bytes in resource */
} RSHDR;

/* HR 150501:
   At last give in to the fact that it is a struct, NOT an array */

typedef union
{
	void *spec;			/* PC_GEM */
	long l;
	short pi[2];
} private;

typedef struct aes_global
{
	short version,
		count,
		id;
	private *pprivate;		/* 3,4 */
	OBJECT **ptree;			/* 5,6 */
	RSHDR *rshdr;			/* 7,8 */
	short lmem,				/* 9 */
		nplanes,			/* 10 */
		res1,client_end,	/* 11, 12 */
		c_max_h, bvhard;	/* 13, 14 */
} GLOBAL;

/* AES parameter block */
typedef struct {
	short *contrl;
	GLOBAL *globl;
	short *intin;
	short *intout;
	void  **addrin;
	void  **addrout;
} AESPB;

/*
 *	XaAES/oAESis Extended Shell Write structure 
 *	- Extra fields for UID/GID setting of spawned clients.
 */
typedef struct _xshelw {
	char *newcmd;
	long psetlimit;
	long prenice;
	char *defdir;
	char *env;
	short uid;            /* New child's UID */
	short gid;            /* New child's GID */
} XSHELW;

#define SW_PSETLIMIT	0x100
#define SW_PRENICE		0x200
#define SW_PDEFDIR		0x400
#define SW_ENVIRON		0x800
#define SW_UID 			0x1000   /* Set user id of launched child */
#define SW_GID			0x2000   /* Set group id of launched child */

/* Menu bar install/remove codes */
#define MENU_REMOVE		0
#define MENU_INSTALL	1
#define MENU_INQUIRE	-1

#define ME_INQUIRE   0		/* HR: menu_attach codes */
#define ME_ATTACH    1
#define ME_REMOVE    2

enum		/* HR: objc_sysvar values */
{
	SV_INQUIRE,
	SV_SET,
	LK3DIND = 1,
	LK3DACT,
	INDBUTCOL,
	ACTBUTCOL,
	BACKGRCOL,
	AD3DVAL
};

/*------------------------------------------------------------ */
/* SPECIAL XaAES stuff */

/* AES Command types */
#define AESCMD_STD		0xc8		/* Standard blocking AES call (process blocks for reply) */
#define AESCMD_TEST		0xc9		/* The 'secret' test for installed AES call */
#define AESCMD_NOREPLY	0xca		/* Process isn't interested in reply so don't give one */
#define AESCMD_NOBLOCK	0xcb		/* Don't block for reply, but place in process reply pipe */
									/* - Process is handling its own reply pipe */
#define VDICMD_STD		0x73		/* The trap was a VDI trap, so call the old vector instead */

/* Mouse Handler Fake Process */
#define XAPID_MOUSE		0			/* As MiNT is always pid 0 and won't send XaAES any */
									/* commands, I use id 0 to fake up a mouse server process */

/* Extra mouse forms */
#define XACRS_BUBBLE_DISC	258		/* The Data Uncertain logo */
#define XACRS_RESIZER		259		/* The 'resize window' cursor */
#define XACRS_MOVER			260		/* The 'move window' cursor */

#define	CGd		0x01	/* Numeric digit */
#define CGa		0x02	/* Alpha */
#define	CGs		0x04	/* Whitespace */
#define	CGu		0x08	/* Upper case */
#define CGp 	0x10	/* Punctuation character */
#define	CGdt	0x20	/* Dot */
#define	CGw		0x40	/* Wild card */
#define CGxp	0x80	/* Extended punctuation */

#endif

#if FIX_PC
#include <vdi.h>
#endif