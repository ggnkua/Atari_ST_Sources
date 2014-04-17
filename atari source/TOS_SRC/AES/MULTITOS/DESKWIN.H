/*	DESKWIN.H		3/15/89 - 3/30/89	Derek Mui	*/
/*	Change w_iblk to w_ciblk	7/11/92		D.Mui		*/

#ifndef _DESKWIN_H_
#define _DESKWIN_H_

#include "obdefs.h"

#define	SUP		0
#define SDOWN	1
#define SLEFT	2
#define	SRIGHT	3

#define	MAXWIN	8	/* max number of window	*/

#define PATHLEN	128
#define INFOLEN	62

#define MAX_DEPTH  8		/* Max folder level	*/

#define	SCREEN	  0	/* related to background			*/

#define NAME		0x0001
#define CLOSE		0x0002
#define FULL		0x0004
#define MOVE		0x0008
#define INFO		0x0010
#define SIZE		0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE		0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE		0x0800
#define SMALLER 	0x4000

#define ALLITEMS 0x4FFF

#if 0
typedef struct	grect
{
	WORD	x;
	WORD	y;
	WORD	w;
	WORD	h;
} GRECT;
#endif

typedef	struct	dir
{
	WORD	d_att;		/* attribute	*/
	UWORD	d_time;		/* time		*/
	UWORD	d_date;		/* date		*/
	LONG	d_size;		/* size		*/
	BYTE	d_name[14];	/* name		*/
	WORD	d_state;	/* selected	*/
	WORD	d_order;	/* file's order	*/
} DIR;

typedef	struct	dta
{
	BYTE	reserved[20];	/* reserved area*/
	DIR	dirfile;
} DTA;

typedef struct myblk
{
	GRECT	*mygrect;
	BYTE	*myptr;
} MYBLK;


typedef	struct	window
{
	BYTE	*w_next;		/* link pointer		*/
	UWORD	w_id;			/* window handle	*/
	UWORD	w_free;			/* window free to use	*/
	BYTE	*w_path;		/* window path name	*/
	BYTE	*w_buf;			/* scratch buffer	*/
	WORD	w_level;		/* max level allowed in this path */
	BYTE	w_info[INFOLEN];	/* info line		*/
	GRECT	w_sizes;	/* window current size and pos	*/
	GRECT	w_work;		/* the current working xywh	*/
	GRECT	w_normsizes;	/* window's size & pos when not iconified */
	OBJECT	*w_obj;		/* pointer to objects			*/
	WORD	w_iconified;	/* true == window is iconified		*/
	OBJECT	*w_icnobj;	/* pointer to objects in iconified state*/
	DIR	w_icndir;	/* file memory when iconified (just 1 dir) */
	WORD	w_srtitem;	/* file item # to start with		*/
	WORD	w_icon;		/* disk icon that owns this window	*/
	WORD	w_vicons;	/* maximum visible icons		*/
	BYTE	*w_memory;	/* file memory owns by this window	*/
	WORD	w_items;	/* max number of file items		*/
	WORD	w_maxicons;	/* max # of icons allocated in window	*/
	WORD	w_icol;		/* max number of col at any time	*/
	WORD	w_irow;		/* max number of row at any time	*/
	TEDINFO	*w_ted;
	CICONBLK *w_ciblk;	/* starting address of iconblk		*/
	BYTE	*w_text;	/* starting address of text		*/
	WORD	w_coli;		/* the horizontal column index 		*/
	WORD	w_hvicons;	/* number of invisible icon per row	*/
	WORD	w_rowi;		/* the vertical row index		*/
	WORD	w_vvicons;	/* number of invisible icon per col	*/
	WORD	w_xcol;		/* number of visible column of icon	*/
	WORD	w_xrow;		/* number of visible row of icon	*/
	WORD	w_saveid;
} WINDOW;	


/* stuff added from gemlib.h since gemlib.h has a different window struct */\
/* DLF 2/23/93 */

#define MU_KEYBD 	0x0001	/* mu_flags		*/
#define MU_BUTTON 	0x0002
#define MU_M1 		0x0004
#define MU_M2 		0x0008
#define MU_MESAG 	0x0010
#define MU_TIMER 	0x0020
#define MU_XBUTTON	0x0040

/*	WINDOW Manager Definitions.					*/
						/* Window Attributes	*/
#define NAME    0x0001
#define CLOSER  0x0002
#define FULLER  0x0004
#define MOVER   0x0008
#define INFO    0x0010
#define SIZER   0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE  0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE  0x0800
#define SMALLER 0x4000

						/* wind_create flags	*/
#define WC_BORDER 	0
#define WC_WORK   	1
						/* wind_get flags	*/
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
#define WF_COLOR 	18	/* set window element by handle */
#define WF_DCOLOR 	19	/* set default element */
#define	WF_OWNER	20

#define WF_BEVENT	24
#define WF_BOTTOM	25
#define WF_ICONIFY	26
#define WF_UNICONIFY	27
#define WF_UNICONIFYXYWH	28
#define WF_ICONSLOT	29
#define WF_TOOLBAR	30
#define WF_FTOOLBAR	31
#define	WF_NTOOLBAR	32

						/* update flags		*/
#define	END_UPDATE 0
#define	BEG_UPDATE 1
#define	END_MCTRL  2
#define	BEG_MCTRL  3

/*	GRAPHICS Manager Definitions					*/
						/* Mouse Forms		*/
#define	ARROW	    0
#define	TEXT_CRSR   1
#define	HOURGLASS   2
#define	POINT_HAND  3
#define	FLAT_HAND   4
#define	THIN_CROSS  5
#define	THICK_CROSS 6
#define	OUTLN_CROSS 7
#define	USER_DEF  	255
#define M_OFF     	256
#define M_ON      	257
#define M_RESTORE	259	

#define AI_NTEXT	0
#define AI_STEXT	1
#define AI_E1		2
#define AI_LANG		3

#define	SHADOW	2		/* thickness of drop shadow in pixels */

#define M_ARROW		0
#define M_CURSOR	1
#define M_BEE		2
#define M_FINGER	3
#define M_FLATHAND	4
#define	M_CROSSHAIR	5	
#define M_TCROSSHAIR	6	/* thick cross hair	*/
#define M_OCROSSHAIR	7	/* outline cross hair	*/
#define M_USERDEFINE	255
#define M_OFF		256
#define M_ON		257
#define	M_SAVEFORM	258
#define	M_RESTORE	259
#define	M_PREVIOUS	260

/*	RESOURCE Manager Definitions					*/
						/* data structure types */
#define R_TREE     0
#define R_OBJECT   1
#define R_TEDINFO  2
#define R_ICONBLK  3
#define R_BITBLK   4
#define R_STRING   5		/* gets pointer to free strings	*/
#define R_IMAGEDATA 6		/* gets pointer to free images	*/
#define R_OBSPEC   7
#define R_TEPTEXT  8		/* sub ptrs in TEDINFO	*/
#define R_TEPTMPLT 9
#define R_TEPVALID 10
#define R_IBPMASK  11		/* sub ptrs in ICONBLK	*/
#define R_IBPDATA  12
#define R_IBPTEXT  13
#define R_BIPDATA  14		/* sub ptrs in BITBLK	*/
#define R_FRSTR    15		/* gets addr of ptr to free strings	*/
#define R_FRIMG    16		/* gets addr of ptr to free images	*/

/*	FORM Manager Definitions					*/
						/* Form flags		*/
#define FMD_START  0
#define FMD_GROW   1
#define FMD_SHRINK 2
#define FMD_FINISH 3

#endif

