#ifndef DESKBIND_H

#define DESKBIND_H

/*	DESKBIND.H		12/13/84-06/09/85	Lee Lorenzen	*/
/*	for 3.0			4/9/86	- 5/5/86	MDF		*/
/*	for 2.3			9/25/87			mdf		*/
/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#if GEMDOS
#include <TOS.H>
#endif

/* leftovers from old deskdefn.h */

#if MULTIAPP
#define NUM_ADTREES 16
#else
#define NUM_ADTREES 14
#endif

#define	THESCREEN 0
#define THEBAR 1
#define THEACTIVE 2


#define THEMENUS 7
							/* Desk Menu	*/
#define L1ITEM 10           
#define DSK1ITEM 11
#define DSK2ITEM 12          
#define DSK3ITEM 13
#define DSK4ITEM 14      
#define DSK5ITEM 15     
#define DSK6ITEM 16   
#define FROOT 0
#define FSTITLE 1
#define FDIRECTORY 2
#define FSELECTION 3
#define FCLSBOX 4
#define FTITLE 5
#define FILEBOX 6
#define F1NAME 7
#define F2NAME 8
#define F3NAME 9
#define F4NAME 10
#define F5NAME 11
#define F6NAME 12
#define F7NAME 13
#define F8NAME 14
#define F9NAME 15
#define SCRLBAR 16
#define FUPAROW 17
#define FDNAROW 18
#define FSVSLID 19
#define FSVELEV 20
#define OK 21
#define CANCEL 22

#ifndef ARROW
#define ARROW 0x0
#endif
#define HRGLASS 0x2

#if MULTIAPP
#define DESKPID 0
#define GEMPID 1
#endif

#define MAX_OBS 60
#define MAX_LEVEL 8

typedef struct glnode {
	FNODE	g_flist[NUM_FNODES];
	FNODE	*g_favail;

	PNODE	g_plist[NUM_PNODES];
	PNODE	*g_pavail;
	PNODE	*g_phead;

	BYTE	g_wspec[LEN_ZPATH];
	LONG	a_wspec;
#if GEMDOS
	DTA		g_wdta;
#else
	FCB		g_wdta;
#endif
	LONG	a_wdta;

	WNODE	g_wlist[NUM_WNODES];
	WORD	g_wcnt;

/* this has been moved into gl_icons[NUM_WOBS] & declared in DESKGLOB.C	*/
	/* ICONBLK	g_icons[NUM_WOBS];*/

	WORD	g_index[NUM_WOBS];

	USERBLK	g_udefs[NUM_WOBS];

	/* view related parms	*/
	WORD	g_num;			/* number of points 	*/
	WORD	*g_pxy;		/* outline pts to drag	*/
	WORD	g_iview;		/* current view type	*/
	WORD	g_iwext;		/* w,h of extent of a	*/
	WORD	g_ihext;		/*   single iten	*/
	WORD	g_iwint;		/* w,h of interval	*/
	WORD	g_ihint;		/*   between item	*/
	WORD	g_iwspc;		/* w,h of extent of a	*/
	WORD	g_ihspc;		/*   single iten	*/
	WORD	g_incol;		/* # of cols in full	*/
	/*   window		*/
	WORD	g_isort;		/* current sort type	*/

	BYTE	g_srcpth[82];
	BYTE	g_dstpth[82];
	/* data xfer buffer and length for copying */
	LONG	g_xbuf;
	UWORD	g_xlen;
	/* stack of fcb's to use for non-recursive */
	/* directory tree traversal */
#if GEMDOS
	DTA		g_fcbstk[MAX_LEVEL];
#else
	FCB		g_fcbstk[MAX_LEVEL];
#endif
	LONG	g_nfiles;
	LONG	g_ndirs;
	LONG	g_size;

	BYTE	g_tmppth[82];

	WORD	g_xyobpts[MAX_OBS * 2];

	WORD	g_rmsg[8];
	LONG	a_rmsg;

	WORD	g_xdesk;
	WORD	g_ydesk;
	WORD	g_wdesk;
	WORD	g_hdesk;

	WORD	g_xfull;
	WORD	g_yfull;
	WORD	g_wfull;
	WORD	g_hfull;

	BYTE	g_cmd[128];
	LONG	a_cmd;

	BYTE	g_tail[128];
	LONG	a_tail;

	BYTE	g_fcb1[36];
	LONG	a_fcb1;

	BYTE	g_fcb2[36];
	LONG	a_fcb2;

	LONG	a_alert;

	LONG	a_trees[NUM_ADTREES];

	WORD	g_croot;		/* current pseudo root	*/

	WORD	g_cwin;			/* current window #	*/
	WORD	g_wlastsel;		/* window holding last	*/
	/*   selection		*/
	WORD	g_csortitem;		/* curr. sort item chked*/
	WORD	g_ccopypref;		/* curr. copy pref.	*/
	WORD	g_cdelepref;		/* curr. delete pref.	*/
	WORD	g_covwrpref;		/* curr. overwrite pref.*/
	WORD	g_cdclkpref;		/* curr. double click	*/
	WORD	g_cmclkpref;		/* curr. menu click	*/
	WORD	g_ctimeform;		/* curr. time format	*/
	WORD	g_cdateform;		/* curr. date format	*/

	BYTE	g_1text[256];
	BYTE	g_2text[256];

	WORD	g_icw;
	WORD	g_ich;
	WORD	g_nmicon;
	WORD	g_nmtext;
	WORD	g_xyicon[18];
	WORD	g_xytext[18];

	WORD	g_wicon;
	WORD	g_hicon;

	WORD	g_afsize;
	BYTE	*g_pbuff;
	ANODE	g_alist[NUM_ANODES];

	ANODE	*g_aavail;
	ANODE	*g_ahead;
	ICONBLK	g_idlist[NUM_IBLKS];
	ICONBLK	g_iblist[NUM_IBLKS];
	WORD	g_ismask[NUM_IBLKS*2];

	CSAVE	g_cnxsave;
	LONG	a_datastart;
	LONG	a_buffstart;

	LONG	a_screen;
	OBJECT	g_screen[NUM_SOBS];		/* NUM_SOBS	*/
} GLOBES;

#endif
