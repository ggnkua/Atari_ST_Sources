/* 	RCSDEFS.H	Tim Oren	10/08/84 - 05/21/85	*/
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSDEFS_H

#define RCSDEFS_H

#include <stdio.h>

/* variables used in icon edit mode */

EXTERN	UWORD	loword, hiword;
EXTERN	GRECT	trans_area;
EXTERN	MFDB	trans_mfdb, tmp_mfdb, tmp2_mfdb;  
EXTERN	WORD	junk;	
EXTERN	WORD	out1, xwait, ywait, wwait, hwait,out2;
EXTERN	WORD	mousex, mousey, bstate, kstate,kreturn, bclicks;
EXTERN	UWORD bit_mask[];
EXTERN	BOOLEAN	icn_edited, iconedit_flag, gl_isicon, is_mask, flags,pen_on;
EXTERN	LONG	save_tree, gl_icnspec;
EXTERN	WORD	save_obj, save_state, gl_wimage, gl_himage,  gl_datasize;
EXTERN	GRECT	scrn_area, hold_area, src_img, fat_area;
EXTERN	GRECT	scroll_fat, icon_area, data_area, mask_area, gridbx;
EXTERN	MFDB	undo_mfdb,hold_mfdb, scrn_mfdb;
EXTERN	LONG	src_mp, dst_mp;
EXTERN	LONG	ibuff_size;
EXTERN  WORD    fgcolor, bgcolor;
#define  MAX_DATA   256

/*use word length not long length*/
#define dos_read(x,y,z) read_piece(x,y,z)
#define dos_write(x,y,z) write_piece(x,y,z)

#define X_FWD 0x0100		/* extended object type codes */
#define X_BAK 0x0200		/* for use with selector trees */
#define X_SEL 0x0300

#define THESCREEN 0
#define THEBAR 1
#define THEACTIVE 2

#define ARROW 0
#define HGLASS 2
#define FINGER 3
#define HAND 4
#define MAXSEL 100			/* Max objects selected at once		*/
#define NDXSIZE 1000		/* indices for tree/object names	*/
#define VIEWSIZE 60			/* maximum icons on workbench view	*/
#define TRACESIZE 1000		/* entries in the tree trace array	*/
#define MAPSIZE 3000		/* entries in the string/image map	*/
#define MAX_ICON_W 0x0040	/* largest icon to be displayed		*/
#define MAX_ICON_H 0x0040	/* is 64 X 64 pixels			*/
#define ICON_W 0x0030		/* icon width in pixels			*/
#define ICON_H 0x0018		/* icon height in pixels		*/
#define MIN_WINT 8			/* horiz. pixels between workbench icons */
#define MIN_HINT 12			/* vert. pixels between workbench icons  */
#define PBX_WINT 16			/* horiz. pixels between partbox objects */
#define PBX_HINT 6			/* vert. pixels between partbox objects */
#define INTER_HSPACE 0		/* alert spacing height in chars	*/
#define INTER_WSPACE 2		/* alert spacing width in chars		*/

#define	NOFILE_STATE 	0	/* defines the current editing procedure */
#define FILE_STATE 	1
#define	PANL_STATE	2
#define	DIAL_STATE	3
#define ALRT_STATE	4
#define MENU_STATE	5
#define FREE_STATE	6

#define NUM_TYP 6		/* the number of tree types */
#define UNKN	0		/* their names and numbers  */
#define PANL	1
#define MENU	2
#define DIAL	3
#define ALRT	4
#define FREE	5
#define OBJKIND 0x100
#define FRSTR	0x101
#define FRIMG	0x102

#define SORTX	0		/* sub-tree sort modes */
#define	SORTY	1
#define SORTXY	2
#define SORTYX	3

#define IB_PMASK(x)		(x)
#define IB_PDATA(x)		(x + 4)		/* definitions for direct access */
#define	IB_PTEXT(x)		(x + 8)		/* to resource structures	 */
#define IB_CHAR(x)		(x + 12)
#define IB_XCHAR(x)		(x + 14)
#define IB_YCHAR(x)		(x + 16)
#define IB_XICON(x)		(x + 18)
#define IB_WICON(x)		(x + 22)
#define IB_HICON(x)		(x + 24)
#define IB_XTEXT(x)		(x + 26)
#define IB_YTEXT(x)		(x + 28)
#define IB_WTEXT(x)		(x + 30)
#define TE_PTEXT(x)		(x)
#define	TE_PTMPLT(x)	(x + 4)
#define	TE_PVALID(x)	(x + 8)
#define TE_FONT(x) 		(x + 12)
#define TE_JUST(x)		(x + 16)
#define TE_FG(x)		(x + 18)
#define TE_THICK(x)		(x + 22)
#define TE_TXTLEN(x)	(x + 24)
#define TE_TMPLEN(x)	(x + 26)
#define BI_PDATA(x)		(x)
#define BI_WB(x)		(x + 4)
#define BI_HL(x)		(x + 6)
#define BI_COLOR(x)		(x + 12)

/* 	adapted from RSRCLIB.H		*/

#define SMODE	0			/* seek mode is absolute offset	*/
#define F_ATTR	0			/* file attribute for creating	*/

#define RT_VRSN 		0	/* these must coincide w/ rshdr */
#define RT_OB 			1
#define RT_TEDINFO		2
#define RT_ICONBLK		3
#define RT_BITBLK		4
#define RT_FREESTR		5
#define RT_STRING		6
#define RT_IMAGEDATA	7
#define	RT_FREEIMG		8
#define RT_TRINDEX		9

#define NUM_RTYPES 10

#define R_NOBS		10
#define R_NTREE		11
#define R_NTED		12
#define R_NICON		13
#define R_NBITBLK	14
#define R_NSTRING	15
#define R_IMAGES	16

#define NUM_OBS		LWGET(rs_hdr + 2*R_NOBS)
#define NUM_TREE	LWGET(rs_hdr + 2*R_NTREE)
#define NUM_TI		LWGET(rs_hdr + 2*R_NTED)
#define NUM_IB		LWGET(rs_hdr + 2*R_NICON)
#define NUM_BB		LWGET(rs_hdr + 2*R_NBITBLK)
#define NUM_FRSTR	LWGET(rs_hdr + 2*R_NSTRING)
#define NUM_FRIMG	LWGET(rs_hdr + 2*R_IMAGES)

#define NUM_RN 7
#define RS_SIZE 17				/* NUM_RTYPES + NUM_RN	*/
#define HDR_LENGTH (RS_SIZE + 1) * 2		/* in bytes	*/

/*	end of RSRCLIB.H stuff 		*/

#define	NOPTS	8

#define	RSH_VRSN(x)		(x)
#define	RSH_OBJECT(x)	(x + 2)
#define	RSH_TEDINFO(x)	(x + 4)
#define	RSH_ICONBLK(x)	(x + 6)
#define	RSH_BITBLK(x)	(x + 8)
#define	RSH_FRSTR(x)	(x + 10)
#define	RSH_STRING(x)	(x + 12)
#define	RSH_IMDATA(x)	(x + 14)
#define	RSH_FRIMG(x)	(x + 16)
#define	RSH_TRINDEX(x)	(x + 18)
#define	RSH_NOBS(x)		(x + 20)
#define	RSH_NTREE(x)	(x + 22)
#define	RSH_NTED(x)		(x + 24)
#define	RSH_NIB(x)		(x + 26)
#define	RSH_NBB(x)		(x + 28)
#define	RSH_NSTRING(x)	(x + 30)
#define	RSH_NIMAGES(x)	(x + 32)
#define	RSH_RSSIZE(x)	(x + 34)

#define OB_NEXT(x)		(tree + (x) * sizeof(OBJECT) + 0)
#define OB_HEAD(x)		(tree + (x) * sizeof(OBJECT) + 2)
#define OB_TAIL(x)		(tree + (x) * sizeof(OBJECT) + 4)
#define OB_TYPE(x)		(tree + (x) * sizeof(OBJECT) + 6)
#define OB_FLAGS(x)		(tree + (x) * sizeof(OBJECT) + 8)
#define OB_STATE(x)		(tree + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(x)		(tree + (x) * sizeof(OBJECT) + 12)
#define OB_X(x)			(tree + (x) * sizeof(OBJECT) + 16)
#define OB_Y(x)			(tree + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(x)		(tree + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(x)	(tree + (x) * sizeof(OBJECT) + 22)

EXTERN	LONG	GET_SPEC();

EXTERN   WORD 	gl_mode;
EXTERN   WORD 	gl_tcolor;
EXTERN   WORD 	gl_lcolor;

EXTERN	WORD	gl_nrows;
EXTERN	WORD	gl_ncols;
EXTERN	WORD	gl_wchar;
EXTERN	WORD	gl_hchar;
EXTERN	WORD	gl_wschar;
EXTERN	WORD	gl_hschar;
EXTERN	WORD	gl_wbox;
EXTERN	WORD	gl_hbox;
EXTERN	WORD	gl_handle;
EXTERN	WORD	gl_nplanes;
EXTERN	WORD	gl_apid;
EXTERN  WORD	gl_width;
EXTERN	WORD	gl_height;
EXTERN	BYTE	sav_rcspath[];
EXTERN	BYTE	sav_icnpath[];
EXTERN	BYTE	rcs_rfile[];
EXTERN	BYTE	rcs_dfile[];
EXTERN	BYTE	rcs_infile[];
EXTERN  BYTE    icn_file[];
EXTERN	BYTE	rcs_app[];
EXTERN	UWORD	hard_drive;
EXTERN	FILE	*rcs_rhndl;
EXTERN	FILE	*rcs_dhndl;
EXTERN  WORD	rcs_edited;
EXTERN	WORD	partp;
EXTERN	WORD	toolp;
EXTERN  LONG	ad_menu;
EXTERN	LONG	ad_tools;
EXTERN  LONG	ad_view;
EXTERN	LONG	ad_pbx;
EXTERN	LONG	ad_clip;
EXTERN  LONG    ad_itool;
EXTERN  LONG    ad_idisp;
EXTERN	WORD	rcs_clipkind;
EXTERN	WORD	rcs_view;
EXTERN	GRECT	full;
EXTERN	GRECT	view;
EXTERN	GRECT	pbx;
EXTERN	GRECT	tools;
EXTERN  GRECT   itool;
EXTERN  GRECT   idisp;
EXTERN	WORD	rcs_trpan;	/* Tree row offset in window	*/
EXTERN	WORD	rcs_xpan;	/* (Positive) offset of root	*/
EXTERN	WORD	rcs_ypan;
EXTERN	WORD	rcs_xtsave;	/* Tree x,y before being opened */
EXTERN	WORD	rcs_ytsave;
EXTERN	WORD	rcs_mform;	/* Current mouse form */
EXTERN	WORD	rcs_hot;	/* Currently active tools */
EXTERN	GRECT	wait;		/* Current mouse wait rectangle */
EXTERN	WORD	wait_io;	/* Waiting for in or out? */

EXTERN	WORD	rcs_svfstat;
EXTERN  WORD	rcs_state;
EXTERN  WORD	icn_state;
EXTERN	BYTE	rcs_title[];
EXTERN	WORD	rcs_nsel;
EXTERN	WORD	rcs_sel[];
EXTERN  WORD    rcs_fsrtflag;
EXTERN	WORD	rcs_cflag;
EXTERN	WORD	rcs_hflag;
EXTERN	WORD	rcs_oflag;
EXTERN	WORD	rcs_cbflag;
EXTERN	WORD	rcs_f77flag;
EXTERN	WORD	rcs_lock;
EXTERN	WORD	rcs_xpert;
EXTERN	WORD	rcs_low;		/* in memory trouble ? */
EXTERN	WORD	rcs_panic;		/* in deep memory trouble! */
EXTERN	WORD	rcs_menusel;		/* only used in MENU_STATE */
EXTERN  WORD	rcs_rmsg[];
EXTERN  LONG	ad_rmsg;

EXTERN	OBJECT	rcs_work[];		/* Space for workbench objects	*/
EXTERN	ICONBLK	rcs_icons[];	/* Space for workbench iconblks */
EXTERN	WORD	rcs_typ2icn[];
/* Variables used in write_file */
EXTERN	UWORD	rcs_wraddr;		/* Current offset in output file */
EXTERN	UWORD	wr_obnum;		/* Count of obj in tree		*/
EXTERN	WORD	wr_obndx[];		/* Tree trace index is built here */

EXTERN  UWORD	rcs_ndxno;

#define INDEX struct index

EXTERN	INDEX	{
	BYTE	*val;
	WORD	kind;
	BYTE	name[10];
} rcs_index[];

#define DEFLTS struct deflts

EXTERN	DEFLTS  {
	WORD	option;
	BOOLEAN	 state;
} deflt_options[];
EXTERN  BYTE	rsc_path[];

EXTERN  WORD    OK_ICN[];
EXTERN  WORD    OK_NOICN[];
EXTERN  WORD    OK_EDITED[];
EXTERN	WORD	OK_NOFILE[]; 
EXTERN	WORD	OK_FILE[];
EXTERN	WORD	OK_TREES[];
EXTERN	WORD	ILL_LOCK[];
EXTERN	WORD	HOT_IBOX[]; 
EXTERN	WORD	HOT_BOX[];
EXTERN	WORD	HOT_TEXT[];
EXTERN	WORD	HOT_IMAGE[];
EXTERN	WORD	HOT_ICON[];
EXTERN	WORD	HOT_BTEXT[];

EXTERN	FILE	*rcs_hhndl;	/* used in write_files and c_ routines */
EXTERN	BYTE	rcs_hfile[], hline[];

EXTERN	struct tally {
	WORD	nobj;
	WORD	nib;
	WORD	nbb;
	WORD	nti;
	WORD	nimg;
	WORD	nstr;
	LONG	nbytes;
} rcs_tally;

EXTERN	WORD	c_obndx[];	/* maps from disk address to string/image # */
EXTERN	WORD	c_nstring;
EXTERN	WORD	c_frstr;	/* first string referenced by freestr */
EXTERN	WORD	c_nfrstr;
EXTERN	WORD	c_nimage;
EXTERN	WORD	c_frimg;	/* first image referenced by freebits */
EXTERN	WORD	c_nbb;
EXTERN	WORD	c_nfrbit;
EXTERN	WORD	c_nib;
EXTERN	WORD	c_nted;
EXTERN	WORD	c_nobs;
EXTERN	WORD	c_ntree;

EXTERN	struct popmap {
	WORD	hotobj;
	WORD	popmenu;
	WORD	outline;
} rcs_ht2pop[], icn_ht2pop[];

EXTERN	struct map {
	WORD	mfrom;
	WORD	mto;
} rcs_it2thk[], grid_patrn[];

EXTERN	struct obitmap {
	WORD	flagmask;
	WORD	statemask;
	WORD	objno;
} rcs_bit2obj[]; 
		     
#define	N_TYPES	13
#define	N_FLAGS	10
#define	N_STATES 7
#define LOOKUP struct looktbl
EXTERN	LOOKUP {
	UWORD	l_val;
	BYTE	l_name[11];
} c_types[];
EXTERN 	LOOKUP	c_flags[];
EXTERN	LOOKUP	c_states[];

#define N_COLORS 16L
#define N_PTNS 8L
#define N_BTHKS 7L
#define N_CHCOLS 16L

EXTERN	WORD	str_types[];
EXTERN	WORD	box_types[];
EXTERN	WORD	txt_types[];

EXTERN	OBJECT	blank_obj;

EXTERN	BYTE	*hptns[];
EXTERN	BYTE	*optns[];
EXTERN	BYTE	*bptns[];
EXTERN	BYTE	*fptns[];

EXTERN	LONG	rs_hdr;
EXTERN	LONG	head;
EXTERN	LONG	buff_size;
EXTERN	LONG	rcs_free;

#endif
