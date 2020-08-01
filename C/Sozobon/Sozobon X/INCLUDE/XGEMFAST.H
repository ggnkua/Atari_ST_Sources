/* tab expansion/compression should be set to 4 */
/**************************************************************************
 *
 * GEMFAST.H - Header file for common VDI and AES symbols.

 this is gemfast.h for xvdifast and xaesfast library
 (SOZOBON eXtended version's GEM library)
 It is based on the original gemfast.h, with little changes. So I kept
 all other stuff in here. -jerry-

 *
 *	This header file contains items compatible with both GEMDEFS and OBDEFS
 *	from the Alcyon system.  Note that there are no 'extern' definitions
 *	for the GEM functions, because they all return a signed int and work
 *	fine as autodefined functions.
 *
 *	If you have a lot of source already coded for #include <gemdefs.h>,
 *	you can create a dummy (empty) obdefs.h file, and code a new gemdefs.h
 *	file which contains only #include <gemfast.h>.	YOU CAN NO LONGER USE
 *	GEMDEFS AND OBDEFS WITH THE GEMFAST BINDINGS!  For the bindings libs
 *	to work correctly, this header file must be used.
 *
 * Credits dept:
 *	 This file bears an amazing similarity to the original Alcyon GEMDEFS
 *	 and OBDEFS header files, which are copyrighted by Atari.  What can I
 *	 say?  Copyrighted or not, these are the names and values that every-
 *	 body uses, so OF COURSE the files look *awful* similar...
 *
 * Maintenance:
 *	12/03/89 - v1.3
 *			   > Renamed a lot of functions, a name compatibility block was
 *				 added at the end of this file to smooth the transition.
 *			   > Added NO_OBJECT, MU_MENTRY, MU_MEXIT to defines.
 *			   > Added XMULTI struct, even though it really belongs to v2.0
 *	05/26/90 - v1.4
 *			   > Added RSHDR structure for imbedded resource support.
 *			   > Fixed all structures which defined pointers as 'long'...
 *				 - ICONBLK ib_pmask, ib_pdata, ib_ptext
 *				 - BITBLK  bi_pdata
 *				 - USERBLK ub_code
 *				 - PARMBLK pb_tree
 *				 All of these structure elements now define the proper ptr.
 *			   > Added AESUTIL_A, AESFAST_A and VDIFAST_A symbols.	This
 *				 allows specific indication of the presence or abscence of
 *				 the bindings libraries, allowing a programmer to use the
 *				 GEMFAST.H header without using the rest of GemFast.  This
 *				 also allows conditional compilation code to be more
 *				 specific:	it can now test for the presence of the header
 *				 file (and handle the differences in the structure defs),
 *				 and it can separately test for the presence of the libs,
 *				 and the extended functions available therein.
 *************************************************************************/

#ifndef GEMFAST_H				/* Prevent multiple inclusion */
	/* xgemfast is based on:	*/
#define GEMFAST_H		1		/* Tell the world GEMFAST header is used */
#define GEMF_VERSION	0x0141	/* Tell the world we are v1.41			 */
#define AESUTIL_A		1		/* Tell the world AESFAST utils  available */

#define _XGEMFAST		1		/* Tell the world XGEMfast is used */
#define _XAESFAST_A		0x104	/* Tell the world XAESFAST lib is used */
#define _XVDIFAST_A		0x105	/* Tell the world XVDIFAST lib is used */
#define	_XAESFASTVERSION "1.04"
#define	_XVDIFASTVERSION "1.05"


	/* the aes variables are to find at end of file	*/

	/* the VDI constants	*/

								/* VDI inside fill styles - new names	*/
#if 0

#define VIS_HOLLOW	0			/* these names will be phased out soon... */
#define VIS_SOLID	1
#define VIS_PATTERN 2
#define VIS_HATCH	3
#define VIS_UDPTRN	4

#define VIP_HOLLOW	0			/* these names will be phased out soon... */
#define VIP_1PTRN	1
#define VIP_2PTRN	2
#define VIP_3PTRN	3
#define VIP_4PTRN	4
#define VIP_5PTRN	5
#define VIP_6PTRN	6
#define VIP_SOLID	7

#endif
							/* polyline types	*/
enum {LT_SOLID =1, LT_LONGDASH, LT_DOTTED, LT_DASHDOT, LT_DASHED,
		LT_DASHDOTDOT, LT_USERDEF};

								/* polyline end styles	*/
enum {LE_SQUARED, LE_ARROWED, LE_ROUNDED};

								/* default polymarker types	*/
enum {MT_DOT = 1, MT_PLUS, MT_ASTERIK, MT_SQUARE, MT_DCROSS, MT_DIAMOND};

								/* graphic test special effects	*/
#define TF_NORMAL		0x00
#define TF_THICKENED	0x01
#define TF_LIGTHENED	0x02
#define TF_SLANTED		0x04
#define TF_UNDERLINED	0x08
#define TF_OUTLINED		0x10
#define TF_SHADOWED		0x20
								/* text alignment	*/
enum {TA_LEFT, TA_CENTER, TA_RIGHT};
enum {TA_BASELINE, TA_HALF, TA_ASCENT, TA_BOTTOM, TA_DESCENT, TA_TOP};

								/* VDI interior fill index	*/
#define IS_HOLLOW	0
#define IS_SOLID	1
#define IS_PATTERN	2
#define IS_HATCH	3
#define IS_UDPTRN	4
							/* alternative names:	*/
enum {FIS_HOLLOW, FIS_SOLID, FIS_PATTERN, FIS_HATCH, FIS_USER};

								/* VDI inside fill style index	*/
	/* (scanning) patterns (together with FIS_PATTERN)	*/
#define IP_HOLLOW	0
#define IP_1PTRN	1
#define IP_2PTRN	2
#define IP_3PTRN	3
#define IP_4PTRN	4
#define IP_5PTRN	5
#define IP_6PTRN	6
#define IP_7PTRN	7
#define IP_SOLID	8
	/* different patterns up to 24 follow	*/
#define IP_BRICK	9
#define IP_LAST		24

	/* hatchings (together with FIS_HATCH)	*/
#define IP_1HATCH	1
#define IP_2HATCH	2
#define IP_3HATCH	3
#define IP_4HATCH	4
#define IP_5HATCH	5
#define IP_6HATCH	6
#define IP_7HATCH	7
#define IP_8HATCH	8
#define IP_9HATCH	9
#define IP_10HATCH	10
#define IP_11HATCH	11
#define IP_12HATCH	12


							   /* VDI normal graphics drawing modes */
#define MD_REPLACE	1
#define MD_TRANS	2
#define MD_XOR		3
#define MD_ERASE	4
							   /* VDI bit blt rules */
#define ALL_WHITE	0
#define S_AND_D		1
#define S_AND_NOTD	2
#define S_ONLY		3
#define NOTS_AND_D	4
#define D_ONLY		5
#define S_XOR_D		6
#define S_OR_D		7
#define NOT_SORD	8
#define NOT_SXORD	9
#define D_INVERT	10
#define NOT_D		10
#define S_OR_NOTD	11
#define NOT_S		12
#define NOTS_OR_D	13
#define NOT_SANDD	14
#define ALL_BLACK	15

				/* VDI and AES colors	*/

#define WHITE		0
#define BLACK		1
#define RED			2
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


	/* the AES constants	*/

									/* font types */
#define IBM			3
#define SMALL		5

									/* evnt_multi flags */
#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020
									/* evnt_mouse flags */
#define MU_MENTRY	0x0000
#define MU_MEXIT	0x0001
									/* keyboard states */
#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_SHIFT		0x0003
#define K_CTRL		0x0004
#define K_ALT		0x0008

					/* event message values */
	/* extensions for AES 4.0 inserted	*/

#define MN_SELECTED 10
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
#define WM_UNTOPPED		30	/* AES 3.3 */
#define WM_ONTOP		31	/* AES 3.3 */

#define WM_ICONIFY		34	/* AES 4.1 */
#define WM_UNICONIFY	35	/* AES 4.1 */
#define WM_ALLICONIFY	36	/* AES 4.1 */

#define AC_OPEN			40
#define AC_CLOSE		41
#define AP_TERM			50	/* AES 4.0 */
#define AP_TFAIL		51	/* AES 4.0 */
#define AP_RESCHG		57	/* AES 4.0 */
#define SHUT_COMPLETED	60	/* AES 4.0 */
#define RESCH_COMPLETED	61	/* AES 4.0 */
#define AP_DRAGDROP		63	/* AES 4.0 */
#define SH_WDRAW		72	/* AES 4.0 */
#define CH_EXIT			90	/* AES 4.0	this is the real value */

#define WM_M_BDROPPED	100	/* MagiC 2.00	*/
#define SM_M_RES1		101 /* MagiC ?? */
	/* ...	*/
#define SM_M_RES9		109 /* MagiC ?? */

#define	WA_UPPAGE	0
#define	WA_DNPAGE	1
#define	WA_UPLINE	2
#define	WA_DNLINE	3
#define	WA_LFPAGE	4
#define	WA_RTPAGE	5
#define	WA_LFLINE	6
#define	WA_RTLINE	7

						/* form_dial opcodes */
#define FMD_START	0
#define FMD_GROW	1
#define FMD_SHRINK	2
#define FMD_FINISH	3
									/* rsrc_gaddr structure types */
#define ROOT		0				/* this name used by MWC */
#define R_TREE		0
#define R_OBJECT	1
#define R_TEDINFO	2
#define R_ICONBLK	3
#define R_BITBLK	4
#define R_STRING	5
#define R_IMAGEDATA 6
#define R_OBSPEC	7
#define R_TEPTEXT	8
#define R_TEPTMPLT	9
#define R_TEPVALID	10
#define R_IBPMASK	11
#define R_IBPDATA	12
#define R_IBPTEXT	13
#define R_BIPDATA	14
#define R_FRSTR		15
#define R_FRIMG		16
									/* Window Attributes */
#define NAME		0x0001
#define CLOSER		0x0002
#define FULLER		0x0004
#define MOVER		0x0008
#define INFO		0x0010
#define SIZER		0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE		0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE		0x0800

#define HOTCLOSEBOX	0x1000	/* MagiC ?? */
#define BACKDROP	0x2000	/* MagiC 1.00	*/
#define SMALLER		0x4000

									/* wind_calc flags */
#define WC_BORDER	0
#define WC_WORK		1
									/* wind_get/set flags */
#define WF_KIND		1
#define WF_NAME		2
#define WF_INFO		3
#define WF_WORKXYWH 4
#define WF_CURRXYWH 5
#define WF_PREVXYWH 6
#define WF_FULLXYWH 7
#define WF_HSLIDE	8
#define WF_VSLIDE	9
#define WF_TOP		10
#define WF_FIRSTXYWH 11
#define WF_NEXTXYWH 12
#define WF_RESVD	13
#define WF_NEWDESK	14
#define WF_HSLSIZE	15
#define WF_VSLSIZE	16
#define WF_SCREEN	17
#define WF_COLOR	18	/* AES 3.3 */
#define WF_DCOLOR	19	/* AES 3.3 */
#define WF_OWNER	20	/* AES 3.3 */
#define WF_BEVENT	24	/* AES 3.31 */
#define WF_BOTTOM	25	/* AES 3.31 */
#define WF_ICONIFY			26	/* AES 4.1 */
#define WF_UNICONIFY		27	/* AES 4.1 */
#define WF_UNICONIFYXYWH	28	/* AES 4.1 */

#define WF_M_OWNER		101		/* MagiC 2.00	*/
#define WF_M_WINDLIST	102		/* MagiC 2.00	*/
#define WF_M_BACKDROP	100		/* MagiC 2.00	*/

#ifndef DONT_USE_Winx
	/* Winx 2.1 ??	*/
#define WF_RETURN		1
#define WF_WINX			22360
#define	WF_WINXCFG		22361

#define WM_BOTTOMED		33
#endif

									/* wind_update flags */
#define END_UPDATE	0
#define BEG_UPDATE	1
#define END_MCTRL	2
#define BEG_MCTRL	3
#define BEG_CHECK	0x100
	/* or 'BEG...' with BEG_CHECK for non blocking wind_update()
		and test for an error (0)	*/

									/* graf_mouse mouse types*/
#define ARROW		0
#define TEXT_CRSR	1
#define BUSY_BEE	2
#define HOURGLASS	2				/* these names are used too */
#define BUSYBEE		2
#define BEE			2
#define POINT_HAND	3
#define FLAT_HAND	4
#define THIN_CROSS	5
#define THICK_CROSS 6
#define OUTLN_CROSS 7
#define USER_DEF	255
#define M_OFF		256
#define M_ON		257

#define M_SAVE			258		/* MultiTOS */
#define M_RESTORE		259		/* MultiTOS */
#define M_PREV			260		/* MultiTOS */

	/* menu_bar modes	*/
#define	MENU_HIDE	0
#define	MENU_SHOW	1
#define	MENU_INSTL	100	/* MagiC 1.0	*/

	/* objc_sysvar() */
#define OB_GETVAR	0
#define OB_SETVAR	1
	/* the objc_sysvar ob_swich values 	*/
#define	LK3DIND		1
#define LK3DACT		2
#define INDBUTCOL	3
#define ACTBUTCOL	4
#define BACKGRCOL	5
#define AD3DVALUE	6


				/* objects	*/

			/* max depth of search or draw	*/
#define MAX_DEPTH	8

			/* object types */
			/* value returned by objc_find(), et. al. */
#define NO_OBJECT	-1
#define G_BOX		20
#define G_TEXT		21
#define G_BOXTEXT	22
#define G_IMAGE		23
#define G_USERDEF	24
#define G_PROGDEF	24
#define G_IBOX		25
#define G_BUTTON	26
#define G_BOXCHAR	27
#define G_STRING	28
#define G_FTEXT		29
#define G_FBOXTEXT	30
#define G_ICON		31
#define G_TITLE		32
#define G_CICON 	33		/* AES 3.3 */

#define G_SWBUTTON	34		/* MagiC 1.00 */
#define G_POPUP		35		/* MagiC 1.00 */

								/* object flags */
#define NONE		0x0000
#define SELECTABLE	0x0001
#define DEFAULT		0x0002
#define EXIT		0x0004
#define EDITABLE	0x0008
#define RBUTTON		0x0010
#define LASTOB		0x0020
#define TOUCHEXIT	0x0040
#define HIDETREE	0x0080
#define INDIRECT	0x0100
#define		FL3DMASK	0x0600	/* 3D objects AES 3.4	*/
#define		FL3DNONE	0x0000
#define	FL3DIND		0x0200
#define	FL3DBAK		0x0400
#define	FL3DACT		0x0600	/* last of 3D object flags	*/

								/* Object states */
#define NORMAL		0x0000
#define SELECTED	0x0001
#define CROSSED		0x0002
#define CHECKED		0x0004
#define DISABLED	0x0008
#define OUTLINED	0x0010
#define SHADOWED	0x0020
#define WHITEBAK	0x0040
#define DRAW3D		0x0080

								/* editable text field definitions */
#define EDSTART		0
#define EDINIT		1
#define EDCHAR		2
#define EDEND		3
#define	ED_CRSR		100 	/* MagiC 1.00 */
#define ED_DRAW		103 	/* MagiC 2.00 */

								/* editable text justification */
#define TE_LEFT		0
#define TE_RIGHT	1
#define TE_CNTR		2

								/* VDI Memory Form Definition Block */
#if 0
#ifndef FDADDR					/* v1.3:  this typedef has been added to */
typedef char *FDADDR;			/* help provide compatibility between	 */
#endif							/* bindings systems.					 */
#else
typedef void *FDADDR;
#endif

typedef struct fdbstr {
	FDADDR		fd_addr;
	short		fd_w;
	short		fd_h;
	short		fd_wdwidth;
	short		fd_stand;
	short		fd_nplanes;
	short		fd_r1;
	short		fd_r2;
	short		fd_r3;
} MFDB;

#define FDB	MFDB					/* FDB for compatibily */

									/* Mouse Form Definition Block */
typedef struct mfstr {
	short mf_xhot;
	short mf_yhot;
	short mf_nplanes;
	short mf_fg;
	short mf_bg;
	short mf_mask[16];
	short mf_data[16];
} MFORM ;

typedef struct grect {
	short g_x;
	short g_y;
	short g_w;
	short g_h;
} GRECT;

typedef struct vrect {
	short v_x1;
	short v_y1;
	short v_x2;
	short v_y2;
} VRECT;

typedef struct text_edinfo {
	char	*te_ptext;				/* ptr to text				 */
	char	*te_ptmplt;			/* ptr to template			 */
	char	*te_pvalid;			/* ptr to validation chrs.	 */
	short	te_font;				/* font						 */
	short	te_junk1;				/* junk word				 */
	short	te_just;				/* justification			 */
	short	te_color;				/* color information word	 */
	short	te_junk2;				/* junk word				 */
	short	te_thickness;			/* border thickness			 */
	short	te_txtlen;				/* length of text string	 */
	short	te_tmplen;				/* length of template string */
} TEDINFO;

typedef struct bftecolor {
#if (SOZOBON  && __SOZOBONX__ < 0x223)
	unsigned innercol:4;
	unsigned fillpat:3;
	unsigned textmode:1;
	unsigned textcolor:4;
	unsigned framecolor:4;
#else
	unsigned framecolor:4;
	unsigned textcolor:4;
	unsigned textmode:1;
	unsigned fillpat:3;
	unsigned innercol:4;
#endif
}bfTECOLOR;

typedef struct Xtext_edinfo {
	char	*te_ptext;				/* ptr to text				 */
	char	*te_ptmplt;				/* ptr to template			 */
	char	*te_pvalid;				/* ptr to validation chrs.	 */
	short	te_font;				/* font						 */
	short	te_junk1;				/* junk word				 */
	short	te_just;				/* justification			 */
	bfTECOLOR	te_color;			/* color information word	 */
	short	te_junk2;				/* junk word				 */
	short	te_thickness;			/* border thickness			 */
	short	te_txtlen;				/* length of text string	 */
	short	te_tmplen;				/* length of template string */
} XTEDINFO;

typedef struct icon_block {
	short	*ib_pmask;
	short	*ib_pdata;
	char 	*ib_ptext;
	short	ib_char;
	short	ib_xchar;
	short	ib_ychar;
	short	ib_xicon;
	short	ib_yicon;
	short	ib_wicon;
	short	ib_hicon;
	short	ib_xtext;
	short	ib_ytext;
	short	ib_wtext;
	short	ib_htext;
} ICONBLK;

typedef struct bfibchar {
#if (SOZOBON  && __SOZOBONX__ < 0x223)
	unsigned iconchar:8;
	unsigned bgcolor:4;
	unsigned iconcolor:4;
#else
	unsigned iconcolor:4;
	unsigned bgcolor:4;
	unsigned iconchar:8;
#endif
} bfIBCHAR;

typedef struct Xicon_block {
	short		*ib_pmask;
	short		*ib_pdata;
	char		*ib_ptext;
	bfIBCHAR 	ib_char;
	short		ib_xchar;
	short		ib_ychar;
	short		ib_xicon;
	short		ib_yicon;
	short		ib_wicon;
	short		ib_hicon;
	short		ib_xtext;
	short		ib_ytext;
	short		ib_wtext;
	short		ib_htext;
} XICONBLK;

typedef struct cicon_data {
	short	num_planes; 		/* number of planes in the following data */
	short	*col_data;			/* pointer to color bitmap in standard form */
	short	*col_mask;			/* pointer to single plane mask of col_data */
	short	*sel_data;			/* pointer to color bitmap of selected icon */
	short	*sel_mask;			/* pointer to single plane mask of selected icon */
	struct	cicon_data *next_res;	/* pointer to next icon for a different resolution */
} CICON;

typedef struct cicon_blk {
	ICONBLK monoblk;	/* default monochrome icon */
	CICON *mainlist;	/* list of color icons for different resolutions */
} CICONBLK;



typedef struct bit_block {
	short	*bi_pdata;					/* ptr to bit forms data	*/
	short	bi_wb;						/* width of form in bytes	*/
	short	bi_hl;						/* height in lines			*/
	short	bi_x;						/* source x in bit form		*/
	short	bi_y;						/* source y in bit form		*/
	short	bi_color;					/* fg color of blt			*/
} BITBLK;


typedef struct user_blk {
	short (*ub_code)(struct parm_blk *p_blk);
	long ub_parm;
} USERBLK;

#define appl_blk user_blk
#define APPLBLK	USERBLK

typedef struct bfObspec {	/*  a bitfield for the ???BOX opsec	*/
#if (SOZOBON  && __SOZOBONX__ < 0x223)
#pragma echo little endian bitfields
	signed	framesize:8;
	unsigned character:8;
	unsigned innercol:4;
	unsigned fillpat:3;
	unsigned textmode:1;
	unsigned textcol:4;
	unsigned framecol:4;
#else
#pragma echo std bitfields
	unsigned character:8;
	signed	 framesize:8;
	unsigned framecol:4;
	unsigned textcol:4;
	unsigned textmode:1;
	unsigned fillpat:3;
	unsigned innercol:4;
#endif
} bfOBSPEC;

typedef union Obspec {
	long	obspec;
	bfOBSPEC bfobspec;
	TEDINFO	*tedinfo;
	ICONBLK	*iconblk;
	CICONBLK *ciconblk;
	BITBLK	*bitblk;
	USERBLK	*userblk;
	char	*free_string;
	struct Swinfo *swinfo;		/* MagiC	*/
	struct Popinfo *popinfo;	/* MagiC	*/
} OBSPEC;

typedef struct object {
	short			ob_next;		/* -> object's next sibling		*/
	short			ob_head;		/* -> head of object's children */
	short			ob_tail;		/* -> tail of object's children */
	unsigned short	ob_type;		/* type of object				*/
	unsigned short	ob_flags;		/* flags						*/
	unsigned short	ob_state;		/* state						*/
/*	long			ob_spec; */ /* replaced by following UNION -jerry-	*/
	OBSPEC			ob_spec;	/* whatever: ob_spec.obspec ...		*/
	short			ob_x;			/* upper left corner of object	*/
	short			ob_y;			/* upper left corner of object	*/
	short			ob_width;		/* width of obj					*/
	short			ob_height;		/* height of obj				*/
} OBJECT;

typedef struct parm_blk {
	OBJECT	*pb_tree;
	short	pb_obj;
	short	pb_prevstate;
	short	pb_currstate;
	short	pb_x, pb_y, pb_w, pb_h;
	short	pb_xc, pb_yc, pb_wc, pb_hc;
	long	pb_parm;
} PARMBLK;



	/* MagiC objects:	*/
typedef struct Popinfo {
	OBJECT	*tree;
	short	obnum;
} POPINFO;

typedef struct Swinfo {
	char	*string;
	short	num;
	short	maxnum;
} SWINFO;



/*-------------------------------------------------------------------------
 * RSHDR structure...
 *-----------------------------------------------------------------------*/

typedef struct rshdr {
	short			rsh_vrsn;		/* Resource structure version # */
	unsigned short	rsh_object;		/* Offset to first object		*/
	unsigned short	rsh_tedinfo;	/* Offset to first tedinfo		*/
	unsigned short	rsh_iconblk;	/* Offset to first iconblk		*/
	unsigned short	rsh_bitblk;		/* Offset to first bitblk		*/
	unsigned short	rsh_frstr;		/* Offset to free string index	*/
	unsigned short	rsh_string;		/* Offset to string data		*/
	unsigned short	rsh_imdata;		/* Offset to image data			*/
	unsigned short	rsh_frimg;		/* Offset to free image index	*/
	unsigned short	rsh_trindex;	/* Offset to tree index			*/
	unsigned short	rsh_nobs;		/* Number of objects			*/
	unsigned short	rsh_ntree;		/* Number object trees			*/
	unsigned short	rsh_nted;		/* Number of tedinfo structs	*/
	unsigned short	rsh_nib;		/* Number of iconblk structs	*/
	unsigned short	rsh_nbb;		/* Number of bitblk structs		*/
	unsigned short	rsh_nstring;	/* Number of free strings		*/
	unsigned short	rsh_nimages;	/* Number of free images		*/
	unsigned short	rsh_rssize;		/* total bytes in resource		*/
} RSHDR;

#define RSHDR_DEFINED 1 /* signal to other header files that RSHDR is done */


typedef struct _menu
{
	OBJECT *mn_tree;		/*  - the object tree of the menu 	*/
	short	mn_menu;	 	/* - the parent object of the menu items 	*/
	short	mn_item;	 	/* - the starting menu item	*/
	short	mn_scroll; 	/* - the scroll field status of the menu	*/
					/* 0	- The menu will not scroll	*/
					/* !0 - it will scroll if the number of menu
					 *	 items exceed the menu scroll height. The 
					 * NOTE: If the scroll field status is !0, the menu
					 *	 items must consist entirely of G_STRINGS.
					 */
	short	mn_keystate;	/* - The CTRL, ALT, SHIFT Key state at the time the	*/
} MENU;

typedef struct _mn_set {
	long	Display; 	/* - the submenu display delay	*/
	long	Drag;	 	/* - the submenu drag delay	*/
	long	Delay;	 	/* - the single-click scroll delay	*/
	long	Speed;	 	/* - the continuous scroll delay	*/
	short	Height; 	/* - the menu scroll height	*/
} MN_SET;


	/* new shel_write calls (AES 4.00, MagiC)	*/

/* MultiTOS (AES 4.00 and up) */

extern	short shel_write(short sh_wdoex, short sh_wisgr, short sh_wiscr,
					void *sh_wpcmd, char *sh_wptail);

/* sh_wdoex values:	*/
#define	SHW_LAUNCH	0x0000
#define	SHW_RUNAPP	0x0001
#define	SHW_RUNACC	0x0003
#define	SHW_SHUTDN	0x0004
#define	SHW_CHGRES	0x0005
#define	SHW_BRCAST	0x0007
#define	SHW_AESENV	0x0008
#define	SHW_RECMSG	0x0009
#define	SHW_SENDAES	0x000A
/*
 *  extended sh_wodex values, 'or' with one of the upper first 3 and
 *  use a SH_WPCMD * for sh_wpcmd parameter
 */
#define	SHW_PSETL	0x0100
	/* use psetlimit value from SH_WPCMD for the new process	*/
#define	SHW_PRENI	0x0200
	/* use prenice value from SH_WPCMD for the new process	*/
#define	SHW_SCWD	0x0400	
	/* chdir to cwd from SH_WPCMD for the new process	*/
#define	SHW_SENV	0x0800
	/* use the environment strings from SH_WPCMD and not AES' ones	*/

/* sh_wisgr	valid for (sh_wdoex & SHW_RUNAPP), i.e. 0x0001
	0 : GEM application
	1 : no GEM appication	*/

typedef struct	Sh_wpcmd {
	char	*cmd;			/* the command, needs no path or extension	*/
	long	psetlimit;
	long	prenice;
	char	*cwd;			/* the new process' cwd or NULL	*/
	char	*env;			/* the new process' environment or NULL	*/
} SH_WPCMD;


/* 	MagiC shel_write:
	extern	short shel_write(short doex, short isgr, 
				short isover, char *pcmd, char *ptail);

	doex is always 1 ??
	isgr is to set:
		1 : for a GEM application
		0 : for a no GEM appication
 */
/* important isover values */
#define SHW_IMMED	0
#define	SHW_CHAIN	1
#define	SHW_PARALLEL	100
#define	SHW_SINGLE		101



	/* special MagiC AES structures	*/

typedef	struct Scanx {
	char scancode;
	char nclicks;
	int  objnr;
} SCANX;

typedef struct Xdo_inf {
	SCANX *unsh;
	SCANX *shift;
	SCANX *ctrl;
	SCANX *alt;
	void  *resvd;
} XDO_INF;


	/* special xaesfast structures	*/

typedef struct xmouse {
	short retval;
	short bclicks;
	short mask;
	short state;
	short status;
	short mousex;
	short mousey;
	short mouseb;
	short keystate;
} XMOUSE;

typedef struct xmulti {
	short		msgbuf[8];	/* msg buffer	*/
	short		mflags,		/* click events	*/
			mbclicks,
			mbmask,
			mbstate,
				mm1flags;	/* mouse rect events	*/
	GRECT		mm1rect;
	short		mm2flags;
	GRECT		mm2rect;
	short		mtlocount,	/* timer events	*/
			mthicount;
	short		mwhich,		/* the return value, again	*/
			mmox,			/* the mouse state	*/
			mmoy,
			mmobutton,
			mmokstate,		/* the key state	*/
			mkreturn,		/* the key	*/
			mbreturn;		/* the mouse button	*/
} XMULTI;


	/* now the AES variables	*/
extern	void *aespb[6];				/* The AES parameter Block	*/
extern	short aescontrol[5];		/* AES contrl[] array	*/
extern short global[15];			/* AES global[] array	*/
	/* in there is	*/
extern	short	gl_apversion;	/* the AES version number	*/
extern	short	gl_apcount;		/* max # of concurrent AES applications	*/
extern	short	gl_apid;		/* id of the current application	*/
extern	long	gl_apprivate;	/* anything application wants to store 	*/
extern	OBJECT	**gl_apptree;	/* pointer to array of object tree ptrs	*/
extern	short	gl_ap1resv[];	/* global[7,8] pointer to head of rsc data	*/
extern	RSHDR	*gl_apprshdr;	/* pointer to head of rsc data	*/
extern	short	gl_ap2resv[6];	/* the rest of global array global[9-14]	*/
/* global[13, 14] not all AES versions:	*/
extern	short	_gl_chheight;	/* character heigth of AES font	*/
extern	short	_gl_smchheight;	/* character heigth of small AES font	*/

	/* some function prototypes	*/

extern	short vq_gdos();
extern	unsigned long vq_vgdos();
extern	void c_vdi(short *pb[5]);

extern short vqt_name(short handle, short index, char *name);
			/* char name[33], name[32] is only set with NVDI 	*/
extern short vqt_nvdi_name(short handle, short index, char *name, 
		char *face, unsigned short *vecflag, unsigned short *font_format,
		unsigned short *flags);
			/* char name[17], char face[17] both [16] set to '\0'	*/
extern short vqt_x_name(short handle, short index, char *name,
		unsigned short *vecflag, unsigned short *font_format, 
		unsigned short *flags);
			/* char name[33], name[32] is set to '\0'	*/


extern	void c_aes(unsigned long control, short *int_in, short *int_out,
						void *addr_in, void *addr_out);
extern	void call_aes(unsigned long control);
extern	void callaes(void);

/* special MagiC (including some GEM 2.x/3.x) AES functions	*/

extern	short	form_xdial(short flag,
			short littlx, short littly, short littlw, short littlh,
			short bigx, short bigy, short bigw, short bigh,
			void **flydial, void *dummy); /* dummy maybe a 'NULL' */
extern	short	form_xdo( OBJECT *form, short start, short *lastcrsr,
						XDO_INF *tabs, void *flydial);
extern	short	form_xerr(long errcode, char *errfile);
extern	short	form_popup(OBJECT *tree, short x, short y);
extern	short	scrp_clear();
extern	void	shel_rdef(char *lpcmd, char *lpdir);
extern	void	shel_xrdef(char *lpcmd, char *lpdir, char **buffer);
extern	void	shel_wdef(char *lpcmd, char *lpdir);
extern	short	menu_click(short val, short setit);
extern	short	menu_unregister(short mid);

#if 0
/* not in current version	*/
extern	short	appl_yield();
#endif




/**************************************************************************
 *
 * Name compatibility stuff.
 *
 *	05/26/90 - v1.4
 *				Added mapping of find_exttype to obj_xtfind.
 *	08/28/89 - v1.3
 *				In v1.3, a big push has been made to make a consistant
 *				naming standard for the AES utilities.	To avoid breaking
 *				a lot of existing code, the following block will direct
 *				the old names to the new routines.
 *
 *************************************************************************/

#define objclg_adjust			rc_gadjust
#define objclv_adjust			rc_vadjust

#define objrb_which(a,b)		obj_rbfind((a),(b),SELECTED)
#define obj_rbwhich(a,b)		obj_rbfind((a),(b),SELECTED)
#define objxrb_which			obj_rbfind

#define objc_xywh				obj_xywh

#define find_exttype			obj_xtfind

#define objst_change			obj_stchange
#define objfl_change			obj_flchange

#define	gl_aprshdr				gl_apprshdr

	/* AES related Functions  extensions to the standard GEM Lib	*/

extern	void do_bell(short res, void* res2);	
		/* beep without any console access!!	*/

extern short evnx_multi(XMULTI *xm);
extern void rsc_treefix(OBJECT *ptree);
extern void rsc_gstrings(OBJECT *ptree, short object, char **ppstr, ...);
extern void rsc_sstrings(OBJECT *ptree, short object, char *pstr, ...);
extern long rsc_gspec(OBJECT *tree, short object);
extern char *rsc_gpointer (OBJECT *tree, short object);
extern void rsc_sspec(OBJECT *tree, short object, long obspec_value);
extern void rsc_spointer(OBJECT *tree, short object, char *pointer);
extern GRECT *rc_gadjust(GRECT *prect, short hadjust, short vadjust);
extern VRECT *rc_vadjust(VRECT *prect, short hadjust, short vadjust);
extern GRECT *rc_vtog(VRECT *pvrect, GRECT *pgrect);
extern VRECT *rc_gtov(GRECT *pgrect, VRECT *pvrect);
extern void rc_union(GRECT *sourcerect, GRECT *destrect);
extern short rc_intersect(GRECT *sourcerect, GRECT *destrect);
extern void rc_copy(void *sourcerect, void *destrect);
extern short rc_equal(void *rect1, void *rect2);
extern void objcl_calc (OBJECT *tree, short object, GRECT *grect, VRECT *vrect);
extern void obj_flchange(OBJECT *ptree, short object, short newflags, short drawflag, ...);
extern void obj_stchange(OBJECT *ptree, short object, short newstate, short drawflag, ...);
extern void obj_offxywh(OBJECT *ptree, short object, GRECT *prect);
extern void obj_xywh(OBJECT *ptree, short object, GRECT *prect);
extern short obj_xtfind(OBJECT *ptree, short parent, short xtype);
extern short obj_rbfind(OBJECT *ptree, short parent, short rbstate);
extern short obj_rbselect(OBJECT *ptree, short selobj, short selstate);
extern short obj_parent(OBJECT *ptree, short object);
extern short frmx_center(OBJECT *ptree, GRECT *prect);
extern short winx_calc(short type, short kind, GRECT inrect, GRECT *outrect);
extern short winx_get(short whandle, short field, GRECT *outrect);


#endif

/*	end of xgemfast.h */
