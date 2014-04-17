/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemlib.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:25:02 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemlib.h,v $
* Revision 2.2  89/04/26  18:25:02  mui
* TT
* 
* Revision 2.1  89/02/22  05:28:06  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:34:26  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMLIB.H	03/15/84 - 01/07/85	Lee Lorenzen		*/
/*	EVNTLIB.H	03/15/84 - 05/16/84	Lee Lorenzen		*/
/*	to 68k		03/08/85 - 05/11/85	Lowell Webster		*/
/*	Add defines	11/25/87		D.Mui			*/
/*	Update		01/06/88		D.Mui			*/
/*	Add cmdlen	1/13/88			D.Mui			*/
/*	Add g_path	1/28/88			D.Mui			*/
/*	Add SAVE_AFILE	2/16/88			D.Mui			*/
/*	Change SIZE_AFILE	04/22/88	D.Mui			*/

/*	Be careful when changing the THEGLO				*/
/*	Gembind.s Gemoblib.c may be affected 				*/

/*	Change these defines and you have to change those in		*/
/*	deskapp.h							*/

#define NUM_ANODES 32				/* # of appl. nodes	*/
#define PATH_LEN 121				/* define maximum path	*/
						/*   length		*/
#define SAVE_ATARI 128				/* atari specific bytes */
						/*  in DESKTOP.INF file */
						/* size of DESKTOP.INF	*/
						/*   file		*/

#define EXTENSION  6
						/* size of DESKTOP.INF	*/
						/*   file		*/

#define SIZE_AFILE ((NUM_ANODES*PATH_LEN)+(NUM_ANODES*EXTENSION)+SAVE_ATARI )	
						
/***********************************************************************/
#define CMDLEN 128

#define RES3	3
#define RES4	4
#define RES5	5
						/* mu_flags		*/
#define MU_KEYBD 0x0001	
#define MU_BUTTON 0x0002
#define MU_M1 0x0004
#define MU_M2 0x0008
#define MU_MESAG 0x0010
#define MU_TIMER 0x0020

#define M_OFF	256
#define M_ON	257
#define ARROW	0


typedef struct moblk
{
	WORD		m_out;
	WORD		m_x;
	WORD		m_y;
	WORD		m_w;
	WORD		m_h;
} MOBLK ;


/*	MENULIB.H	05/04/84 - 11/01/84	Lowell Webster	*/

#define NUM_DESKACC 6
#define WID_DESKACC 21
	
#define MTH 1					/* menu thickness	*/

#define THESCREEN 0
#define THEBAR 1
#define THEACTIVE 2
#define THEMENUS ( LWGET(OB_TAIL(THESCREEN)) )

/*** STATE DEFINITIONS FOR menu_state ***********************************/

#define INBAR	1	/* mouse position	outside menu bar & mo dn */
			/* multi wait		mo up | in menu bar	*/
			/* moves		-> 5  ,  ->2		*/

#define OUTTITLE 2  	/* mouse position	over title && mo dn	*/
			/* multiwait		mo up | out title rect	*/
			/* moves		-> 5  ,	->1 ->2  ->3	*/

#define OUTITEM 3 	/* mouse position	over item && mo dn	*/
			/* multi wait		mo up | out item rect	*/
			/* moves		-> 5  , ->1 ->2 ->3 ->4	*/

#define INBARECT 4	/* mouse position	out menu rect && bar && mo dn*/			/* multi wait	mo up | in menu rect | in menu bar */
			/* moves	-> 5  ,	-> 3	     , -> 2	*/



/*	APPLLIB.H	05/05/84 - 10/16/84	Lee Lorenzen		*/

#define SCR_MGR 0x0001			/* pid of the screen manager*/

#define AP_MSG 		0
#define MN_SELECTED 	10

#define WM_REDRAW 	20
#define WM_TOPPED 	21
#define WM_CLOSED 	22
#define WM_FULLED 	23
#define WM_ARROWED 	24
#define WM_HSLID 	25
#define WM_VSLID 	26
#define WM_SIZED 	27
#define WM_MOVED 	28
#define WM_UNTOPPED	30
#define WM_ONTOP	31

#define AC_OPEN 	40
#define AC_CLOSE 	41

#define CT_UPDATE 50


/*	FORMLIB.H	05/05/84 - 10/16/84	Gregg Morris		*/

#define FMD_START 0
#define FMD_GROW 1
#define FMD_SHRINK 2
#define FMD_FINISH 3

/*	SCRPLIB.H	05/05/84 - 01/05/85	Lee Lorenzen		*/

/*	FSELLIB.H	05/05/84 - 01/07/85	Lee Lorenzen		*/

#define RET_CODE int_out[0]

#define FS_IPATH addr_in[0]
#define FS_ISEL addr_in[1]

#define FS_BUTTON int_out[1]

#define NM_FILES 100


/*	RSRCLIB.H	05/05/84 - 09/13/84	Lowell Webster		*/

#define OP_VERSION control[0]
#define OP_CODE control[1]
#define OP_ID control[2]
#define OP_FLAGS control[3]
#define RET_CODE int_out[0]

#define RS_PFNAME addr_in[0]		/* rs_init, 			*/
#define RS_TYPE int_in[0]
#define RS_INDEX int_in[1]
#define RS_INADDR addr_in[0]
#define RS_OUTADDR addr_out[0]		


#define RMODE_RD 0
#define RMODE_WR 1
#define RMODE_RW 2

#define SMODE 0				/* seek mode is absolute offset	*/
#define F_ATTR 0			/* file attribute for creating	*/

typedef struct rssofln
{
	WORD	rss_offset;
	WORD	rss_length;
}RSSOFLN;

typedef struct imofln			/* image block structure	*/
{
	WORD	rim_offset;
	WORD	rim_length;
}IMOFLN;

typedef struct rstree
{
	WORD	rst_first;
	WORD	rst_count;
}RSTREE;

#define RES_TREE	8		/* # of long tree pointers	*/
					/*  reserved in the global array*/

			/* these must coincide w/ rshdr */
#define RT_VRSN 0
#define RT_OB 1
#define RT_TEDINFO 2
#define RT_ICONBLK 3
#define RT_BITBLK 4
#define RT_FREESTR 5
#define RT_STRING 6
#define RT_IMAGEDATA 7
#define	RT_FREEIMG 8
#define RT_TRINDEX 9

#define NUM_RTYPES 10

#define R_NOBS 10
#define R_NTREE 11
#define R_NTED 12
#define R_NICON 13
#define R_NBITBLK 14
#define R_NSTRING 15
#define R_IMAGES 16

#define NUM_RN 7

#define RS_SIZE 17				/* NUM_RTYPES + NUM_RN	*/

#define HDR_LENGTH (RS_SIZE + 1) * 2		/* in bytes	*/


typedef struct rshdr
{
	WORD		rsh_vrsn;	/* must same order as RT_	*/
	WORD		rsh_object;
	WORD		rsh_tedinfo;
	WORD		rsh_iconblk;	/* list of ICONBLKS		*/
	WORD		rsh_bitblk;
	WORD		rsh_frstr;	
	WORD		rsh_string;
	WORD		rsh_imdata;	/* image data			*/
	WORD		rsh_frimg;	
	WORD		rsh_trindex;
	WORD		rsh_nobs;	/* counts of various structs	*/
	WORD		rsh_ntree;
	WORD		rsh_nted;
	WORD		rsh_nib;
	WORD		rsh_nbb;
	WORD		rsh_nstring;
	WORD		rsh_nimages;
	WORD		rsh_rssize;	/* total bytes in resource	*/
}RSHDR;


/* type definitions for use by an application when calling	*/
/*  rsrc_gaddr and rsrc_saddr					*/

#define R_TREE 0
#define R_OBJECT 1
#define R_TEDINFO 2
#define R_ICONBLK 3
#define R_BITBLK 4
#define R_STRING 5		/* gets pointer to free strings	*/
#define R_IMAGEDATA 6		/* gets pointer to free images	*/
#define R_OBSPEC 7
#define R_TEPTEXT 8		/* sub ptrs in TEDINFO	*/
#define R_TEPTMPLT 9
#define R_TEPVALID 10
#define R_IBPMASK 11		/* sub ptrs in ICONBLK	*/
#define R_IBPDATA 12
#define R_IBPTEXT 13
#define R_BIPDATA 14		/* sub ptrs in BITBLK	*/
#define R_FRSTR 15		/* gets addr of ptr to free strings	*/
#define R_FRIMG 16		/* gets addr of ptr to free images	*/


/*	WINDLIB.H	05/05/84 - 01/26/85	Lee Lorenzen		*/

#define WS_FULL 0
#define WS_CURR 1
#define WS_PREV 2
#define WS_WORK 3
#define WS_TRUE 4

#define XFULL 0
#define YFULL gl_hbox
#define WFULL gl_width
#define HFULL (gl_height - gl_hbox)

/* Bit mask for window components */
#define NAME	0x0001
#define CLOSER	0x0002
#define FULLER	0x0004
#define MOVER	0x0008
#define INFO	0x0010
#define SIZER	0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE	0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE	0x0800
/* Added Jul 23 91 for new window manager - ml. */
#define MNBAR	0x1000


#define	TPARTS	(NAME|CLOSER|FULLER|MOVER)
#define	VPARTS	(UPARROW|DNARROW|VSLIDE)
#define	HPARTS	(LFARROW|RTARROW|HSLIDE)


#define	HASHSIZ	8		/* size of hash table */
#define	NUMWIN	8		/* # window structures per block of memory */
#define	MAXOBJ	20		/* maximum number of objects in a window */
#define	NUMRECT	80		/* # RLISTs per block of memory allocated */
#define	SHADOW	2		/* thickness of drop shadow in pixels */
#define	BORDER	0		/* # pixels taken up by border around obj */


/* Bit masks of pieces of a window */
#define TOP	0x0001
#define LEFT	0x0002
#define RIGHT	0x0004
#define BOTTOM	0x0008


/* Indices into object tree of window */
#define	W_BOX	    0		/* background of window */
#define	W_TITLE	    1		/* parent of closer, name and fuller */
#define	W_CLOSER    2		/* closer */
#define	W_NAME	    3		/* name and mover bar */
#define	W_FULLER    4		/* fuller */
#define	W_INFO	    5		/* info line */
#define	W_DATA	    6		/* holds remaining window elements */
#define	W_WORK	    7		/* application work area */
#define	W_SIZER	    8		/* sizer */
#define	W_VBAR	    9		/* holds vertical slider elements */
#define	W_UPARROW   10		/* vertical slider up arrow */
#define	W_DNARROW   11		/* vertical slider down arrow */
#define	W_VSLIDE    12		/* vertical slider background */
#define	W_VELEV	    13		/* vertical slider thumb/elevator */
#define	W_HBAR	    14		/* holds horizontal slider elements */
#define	W_LFARROW   15		/* horizontal slider left arrow */
#define	W_RTARROW   16		/* horizontal slider right arrow */
#define	W_HSLIDE    17		/* horizontal slider background */
#define	W_HELEV	    18		/* horizontal slider thumb/elevator */
#define	W_MNBAR	    19		/* menu bar (added Jul 23 91 - ml.) */


/* Callers of totop() */
#define	WMOPEN	0		/* called from wm_open() */
#define	WMCLOSE	1		/* called from wm_close() */
#define	WMSET	2		/* called from wm_set() */


/* Ob_spec values */
#define	GBOX_OBS    0x00010000	/* ob_spec value for GBOX objects */


/* Memory descriptor structure */
typedef	struct	memhdr {
    int	    numused;		/* number of window structures used */
    struct  memhdr *mnext;	/* pointer to next memory descriptor */
} MEMHDR;


/* Rectangle list structure */
typedef	struct	rlist {
    struct {
	unsigned rused : 1;	/* bit 0 ->1: slot is currently used */
    } rstatus;
    GRECT   rect;		/* the rectangle dimensions */
    MEMHDR  *rwhere;		/* ptr to memory this RLIST resides in */
    struct  rlist *rnext;	/* ptr to next RLIST */
} RLIST;


/* Window structure */
typedef	struct	window {
    struct {
	unsigned used : 1;	/* bit 0 -> 1: slot is currently used */
	unsigned opened : 1;	/* bit 1 -> 1: window is currently opened */
    } status;			/* window status */
    PD	    *owner;		/* owner of this window */
    UWORD   mowner;		/* mouse owner of this window */
    UWORD   handle;		/* window handle */
    UWORD   kind;		/* flag for components of window */
    OBJECT  *aesobj;		/* for use in AES */
    OBJECT  obj[MAXOBJ];	/* definition of each object */
    WORD    tcolor[MAXOBJ];	/* object colors if window is topped */
    WORD    bcolor[MAXOBJ];	/* object colors if window is in background */
    TEDINFO ttxt;		/* title bar text */
    TEDINFO itxt;		/* info line text */
    TEDINFO mtxt;		/* menu bar text */
    GRECT   full;		/* coords and size when full */
    GRECT   prev;		/* previous coords and size */
    GRECT   curr;		/* current coords and size */
    RLIST   *fxywh;		/* first rect in rectangle list */
    RLIST   *nxywh;		/* next rect in rectangle list */
				/* slider positions and sizes are in 1-1000
				   range and relative to the scroll bar */
    UWORD   hslpos;		/* horizontal slider position */
    UWORD   vslpos;		/* vertical slider position */
    UWORD   hslsz;		/* horizontal slider size */
    UWORD   vslsz;		/* vertical slider size */
    UWORD   ontop;		/* handle # of window on top */
    UWORD   under;		/* handle # of window under */
    UWORD   nxthndl;		/* next handle # in used */
    UWORD   parent;		/* handle # of parent window */
    UWORD   child;		/* handle # of 1st child window */
    UWORD   type;		/* window's characteristics	*/
    UWORD   sibling;		/* handle # of next sibling window */
    MEMHDR  *wwhere;		/* ptr to memory this WINDOW resides in */
    struct  window *wnext;	/* ptr to next WINDOW in database */
} WINDOW;


#define WC_BORDER   0
#define WC_WORK	    1


#define WF_KIND		1
#define WF_NAME		2
#define WF_INFO		3
#define WF_WORKXYWH	4
#define WF_CURRXYWH	5
#define WF_PREVXYWH	6
#define WF_FULLXYWH	7
#define WF_HSLIDE	8
#define WF_VSLIDE	9
#define WF_TOP      	10
#define WF_FIRSTXYWH 	11
#define WF_NEXTXYWH 	12
#define WF_RESVD   	13
#define WF_NEWDESK 	14
#define WF_HSLSIZE   	15
#define WF_VSLSIZE   	16
#define WF_SCREEN   	17
/* window color settings added 900227 - kbad */
#define WF_COLOR	18	/* set window element by handle */
#define WF_DCOLOR	19	/* set default element */

/* added Jul 23 91 for menu bar in window - ml. */
#define	WF_OWNER	20

/* added Feb 25 92 to allow bottoming window - ml. */
#define WF_BEVENT	24
#define	WF_BOTTOM	25

#define	WF_MENUBAR	99

						/* arrow message	*/
#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7


#define G_SIZE 15

/* system has 3 pds to start - app, control mgr, acc	*/

#define THEGLO struct glstr
THEGLO
{
/* GLOBAL */ UDA	g_uda;			/* must be first */
/* GLOBAL */ UDA2	g_2uda;
/* GLOBAL */ UDA3	g_3uda;
/* GLOBAL */ PD		g_pd[NUM_PDS];
/* GLOBAL */ CDA	g_cda[NUM_PDS];
/* GLOBAL */ EVB	g_evb[NUM_EVBS];

/* GLOBAL */ FPD	g_fpdx[NFORKS];
/* GLOBAL  ORECT 	g_olist[NUM_ORECT]; */

/* GLOBAL */ BYTE	g_rawstr[MAX_LEN];	/* used in gemoblib.s	*/
/* GLOBAL */ BYTE	g_tmpstr[MAX_LEN];	/* used in gemoblib.s	*/
/* GLOBAL */ BYTE	g_valstr[MAX_LEN];	/* used in gembind.s	*/
/* GLOBAL */ BYTE	g_fmtstr[MAX_LEN];	/* used in gemoblib.s	*/

/* GLOBAL */ BYTE	g_loc1[256];		/* MAX alert length	*/
/* GLOBAL */ BYTE	g_loc2[256];

/* GLOBAL */ WORD	g_scrap[82];

/* GLOBAL */ BYTE	g_dir[CMDLEN];		/* changed from 82 to 128 */

/* GLOBAL */ UWORD	g_sysglo[G_SIZE];

/* GLOBAL */ BYTE	g_path[CMDLEN];		/* new element		*/

/* GLOBAL */ BYTE	s_cmd[CMDLEN];
/* GLOBAL */ BYTE	s_save[SIZE_AFILE];	/* SIZE_AFILE		*/
/* GLOBAL */ BYTE	s_tail[CMDLEN];

/* GLOBAL  WINDOW	w_win[NUM_WIN];*/
};
