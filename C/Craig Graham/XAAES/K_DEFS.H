/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
	Definitions for the standard GEM application data structures
	taken out of the AESBIND.H standard header
*/

#ifndef _K_DEFS_H_
#define _K_DEFS_H_

#ifdef __PUREC__
#define far
#define __regargs
#define __saveds
#define short	int

/* Switch off some of PC's warning messages */
#pragma warn -aus	/* 'foo' is assigned a value which is never used */
#pragma warn -rch	/* Unreachable code */
#pragma warn -stv	/* Structure passed by value */
#pragma warn -use	/* 'foo' declared but never used */
#pragma warn -cln	/* Constant is long */
#pragma warn -par	/* Parameter 'foo' is never used */

#endif /* __PUREC__ */


#include "XA_DEFS.H"

/* Event library definitions */
#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020

#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_CTRL		0x0004
#define K_ALT		0x0008

#define MN_SELECTED	10

#define SCR_MGR     0x0001	/* process id of the screen manager - this is redundant */
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

#define CH_EXIT         80

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
#define DD_TIMEOUT			4000	/* timeout in milliseconds */
#define DD_NUMEXTS			8
#define DD_EXTSIZE			32L
#define DD_NAMEMAX			128		/* max size of a drag&drop item name */
#define DD_HDRMAX			(8+DD_NAMEMAX)	/* max length of a drag&drop header */

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
#define NIL			-1

#define MAX_DEPTH	8	/* max depth of search or draw */

#define IP_HOLLOW	0	/* inside patterns */
#define IP_1PATT	1
#define IP_2PATT	2
#define IP_3PATT	3
#define IP_4PATT	4
#define IP_5PATT	5
#define IP_6PATT	6
#define IP_SOLID	7
                           /* system foreground and */
                           /*   background rules    */
#define SYS_FG      0x1100 /*   but transparent     */

#define WTS_FG      0x11a1 /* window title selected */
                           /*   using pattern 2 &   */
                           /*   replace mode text   */
#define WTN_FG      0x1100 /* window title normal   */

#define IBM			3	/* font types */
#define SMALL		5

#define G_BOX		20	/* Graphic types of obs	*/
#define G_TEXT		21
#define G_BOXTEXT	22
#define G_IMAGE		23
#define G_PROGDEF	24
#define	G_USERDEF	G_PROGDEF
#define G_IBOX		25
#define G_BUTTON	26
#define G_BOXCHAR	27
#define G_STRING	28
#define G_FTEXT		29
#define G_FBOXTEXT	30
#define G_ICON		31
#define G_TITLE		32
#define G_CICON         33

#define NONE		0x0000	/* Object flags	*/
#define SELECTABLE	0x0001
#define DEFAULT		0x0002
#define EXIT		0x0004
#define EDITABLE	0x0008
#define RBUTTON		0x0010
#define LASTOB		0x0020
#define TOUCHEXIT	0x0040
#define HIDETREE	0x0080
#define INDIRECT	0x0100
#define FLD3DIND	0x0200	/* AES3.3 and over extended object flags for 3d widgets */
#define FLD3DBAK	0x0400	/* Atari Compendium mixes up FLD3DACT & FLD3DBAK */
#define FLD3DACT	0x0600
#define FLD3DANY	0x0600
#define SUBMENU		0x0800

#define NORMAL		0x0000	/* Object states */
#define SELECTED	0x0001
#define CROSSED		0x0002
#define CHECKED		0x0004
#define DISABLED	0x0008
#define OUTLINED	0x0010
#define SHADOWED	0x0020
#define SPECIAL		0x0040	/* user defined object state */
#define WHITEBAK    0x0040
#define DRAW3D      0x0080

#define IS_EDIT     0x8000	/* XaAES special - this object has the text focus */

#define WHITE		0	/* Object colors */
#define BLACK		1
#define RED		2
#define GREEN		3
#define BLUE		4
#define CYAN		5
#define YELLOW		6
#define MAGENTA		7
#define LWHITE		8
#define LBLACK		9
#define LRED		10
#define LGREEN		11
#define LBLUE		12
#define LCYAN		13
#define LYELLOW		14
#define LMAGENTA	15

#define TE_LEFT		0	/* editable text justification */
#define TE_RIGHT	1
#define TE_CNTR		2

typedef struct object
{
	short ob_next;
	short ob_head;
	short ob_tail;
	unsigned short ob_type;
	unsigned short ob_flags;
	unsigned short ob_state;
	void *ob_spec;
	short ob_x;
	short ob_y;
	short ob_width;
	short ob_height;
} OBJECT;

typedef struct text_edinfo
{
	char *te_ptext;
	char *te_ptmplt;
	char *te_pvalid;
	short te_font;
	short te_fontid;		/* AES 4.1 extension */
	short te_just;
	short te_color;
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
	short ib_xicon;
	short ib_yicon;
	short ib_wicon;
	short ib_hicon;
	short ib_xtext;
	short ib_ytext;
	short ib_wtext;
	short ib_htext;
} ICONBLK;

typedef struct cicon_data
{
	short num_planes;							/* number of planes in the following data          */
	short *col_data;							/* pointer to color bitmap in standard form        */
	short *col_mask;							/* pointer to single plane mask of col_data        */
	short *sel_data;							/* pointer to color bitmap of selected icon        */
	short *sel_mask;							/* pointer to single plane mask of selected icon   */
	struct cicon_data *next_res;	/* pointer to next icon for a different resolution */
}	CICON;

typedef struct cicon_blk
{
	ICONBLK monoblk;		/* default monochrome icon                         */
	CICON *mainlist;		/* list of color icons for different resolutions */
}	CICONBLK;

typedef struct bit_block
{
	short *bi_pdata;
	short bi_wb;
	short bi_hl;
	short bi_x;
	short bi_y;
	short bi_color;
} BITBLK;

typedef struct parm_blk
{
	OBJECT *pb_tree;
	short pb_obj;
	short pb_prevstate;
	short pb_currstate;
	short pb_x;
	short pb_y;
	short pb_w;
	short pb_h;
	short pb_xc;
	short pb_yc;
	short pb_wc;
	short pb_hc;
	long pb_parm;
} PARMBLK;

typedef struct appl_blk
{
	int (*__stdargs ab_code)(PARMBLK *);
	long ab_parm;
} APPLBLK;

typedef struct grect
{
	short g_x;
	short g_y;
	short g_w;
	short g_h;
} GRECT;

/* From Atari Compendium - not sure if the bitfield stuff works properly with
   GNU or Pure C, but it's fine with Lattice */
typedef struct objc_colorword
{
	unsigned short borderc:4;
	unsigned short textc:4;
	unsigned short opaque:1;
	unsigned short pattern:3;
	unsigned short fillc:4;
} OBJC_COLORWORD;

/* Form library definitions */
#define ED_START	0	/* editable text field definitions */
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
#define scrp_read(a)	(_AESaddrin[0]=a,_AESif(280))
#define scrp_write(a)	(_AESaddrin[0]=(void *)(a),_AESif(284))
#define SCRAP_CSV   0x0001
#define SCRAP_TXT   0x0002
#define SCRAP_GEM   0x0004
#define SCRAP_IMG   0x0008
#define SCRAP_DCA   0x0010
#define SCRAP_USR   0x8000

/* Window library definitions */
#define NAME		0x0001
#define CLOSE		0x0002
#define CLOSER		CLOSE
#define FULL		0x0004
#define FULLER		FULL
#define MOVE		0x0008
#define MOVER		MOVE
#define INFO		0x0010
#define SIZE		0x0020
#define SIZER		SIZE
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE		0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE		0x0800
#define SMALLER		0x4000

/* Extended XaAES Attributes */
#define STORE_BACK	0x80000000L	/* Store the background of a window & don't generate redraw  */
								/* messages to windows below */
#define NO_WORK		0x40000000L	/* A window with no work area */
#define NO_REDRAWS	0x20000000L	/* Don't generate WM_REDRAW messages to the owner app */
#define NO_MESSAGES	0x30000000L	/* Don't generate any messages at all to the owner app */



#define WF_RETURN		1
#define WF_KIND			1
#define WF_NAME 		2
#define WF_INFO 		3
#define WF_WXYWH		4
#define WF_WORKXYWH		WF_WXYWH
#define WF_CXYWH		5
#define WF_CURRXYWH		WF_CXYWH
#define WF_PXYWH		6
#define WF_PREVXYWH		WF_PXYWH
#define WF_FXYWH		7
#define WF_FULLXYWH		WF_FXYWH
#define WF_HSLIDE		8
#define WF_VSLIDE		9
#define WF_TOP			10
#define WF_FIRSTXYWH	11
#define WF_NEXTXYWH		12
#define WF_IGNORE		13
#define WF_NEWDESK		14
#define WF_HSLSIZE		15
#define WF_HSLSIZ		WF_HSLSIZE
#define WF_VSLSIZE		16
#define	WF_VSLSIZ		WF_VSLSIZE
#define WF_SCREEN		17
#define WF_COLOR		18
#define WF_DCOLOR		19
#define WF_OWNER    	20
#define WF_BEVENT   	24
#define WF_BOTTOM		25
#define WF_ICONIFY			26
#define WF_UNICONIFY		27
#define WF_UNICONIFYXYWH	28

/* XaAES Special modes */
#define WF_AUTOREDRAW		100
#define WF_STOREBACK		101
#define WF_WIDGET			102

/* keyboard focus policy */

#define FOCUS_MOUSE				1

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
#define R_STRING	5	/* gets pointer to free strings */
#define R_IMAGEDATA	6	/* gets pointer to free images */
#define R_OBSPEC	7
#define R_TEPTEXT	8	/* sub ptrs in TEDINFO */
#define R_TEPTMPLT	9
#define R_TEPVALID	10
#define R_IBPMASK	11	/* sub ptrs in ICONBLK */
#define R_IBPDATA	12
#define R_IBPTEXT	13
#define R_BIPDATA	14	/* sub ptrs in BITBLK */
#define R_FRSTR		15	/* gets addr of ptr to free strings */
#define R_FRIMG		16	/* gets addr of ptr to free images */

typedef struct
{
	short rsh_vrsn;			/* RCS version no. */
	unsigned short rsh_object;	/* offset to object[] */
	unsigned short rsh_tedinfo;	/* offset to tedinfo[] */
	unsigned short rsh_iconblk;	/* offset to iconblk[] */
	unsigned short rsh_bitblk;	/* offset to bitblk[] */
	unsigned short rsh_frstr;		/* offset to free string index */
	unsigned short rsh_string;	/* offset to first string */
	unsigned short rsh_imdata;	/* offset to image data */
	unsigned short rsh_frimg;		/* offset to free image index */
	unsigned short rsh_trindex;	/* offset to object tree index */
	short rsh_nobs;			/* number of objects */
	short rsh_ntree;			/* number of trees */
	short rsh_nted;			/* number of tedinfos */
	short rsh_nib;			/* number of icon blocks */
	short rsh_nbb;			/* number of blt blocks */
	short rsh_nstring;		/* number of free strings */
	short rsh_nimages;		/* number of free images */
	unsigned short rsh_rssize;	/* total bytes in resource */
} RSHDR;

/* AES parameter block */
typedef struct {
	short *contrl;
	short *globl;
	short *intin;
	short *intout;
	void  **addrin;
	void  **addrout;
} AESPB;

/*
	XaAES/oAESis Extended Shell Write structure 
	- extra fields for UID/GID setting of spawned clients.
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

/*------------------------------------------------------------ */
/* SPECIAL XaAES stuff */

/* AES Command types */
#define AESCMD_STD		0xc8		/* Standard blocking AES call (process blocks for reply) */
#define AESCMD_TEST		0xc9		/* The 'secret' test for installed AES call */
#define AESCMD_NOREPLY	0xca		/* Process isn't interested in reply so don't give one */
#define AESCMD_NOBLOCK	0xcb		/* Don't block for reply, but place in process reply pipe */
									/* -process is handling it's own reply pipe */
#define VDICMD_STD		79			/* The trap was a VDI trap, so call the old vector instead */

/* Mouse Handler Fake Process */
#define XAPID_MOUSE		0			/* As MiNT is always pid 0 and won't send XaAES any */
									/* commands, I use id 0 to fake up a mouse server process */

/* Extra mouse forms */
#define XACRS_BUBBLE_DISC	258		/* The Data Uncertain logo */
#define XACRS_RESIZER		259		/* The 'resize window' cursor */
#define XACRS_MOVER			260		/* The 'move window' cursor */

#define	CGd		0x01	/* numeric digit */
#define CGa		0x02	/* alpha */
#define	CGs		0x04	/* whitespace */
#define	CGu		0x08	/* upper case */
#define CGp 	0x10	/* punctuation character */
#define	CGdt	0x20	/* dot */
#define	CGw		0x40	/* wild card */
#define CGxp	0x80	/* extended punctuation */

#endif