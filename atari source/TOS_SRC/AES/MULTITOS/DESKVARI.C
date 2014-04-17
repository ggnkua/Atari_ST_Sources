/*	DESKSTOR.C		6/12/89 - 6/13/89	Derek Mui	*/
/*	Take out some variable	6/28/89	- 9/13/89	D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "osbind.h"

/*
 *	Set the DESKPRG flag to compile this file for a
 *	replacement Desktop. Clear it for making GEM.SYS
 *      DESKPRG must also be set/cleared in
 *	      DESKSTAR.S, DESKTOP.C, DESKROM.C
 *	See the Defines in the softload.h file.
 */
#include "softload.h"

BYTE	dr[32];		/* drives flag			*/	
WORD	p_timedate;	/* preserve time and date	*/

WINDOW	*ww_win;	/* for w_gfirst and w_gnext	*/

WORD	d_nrows;	/* number of rows used by show	*/
WORD	d_level;	/* window path level		*/
BYTE	*d_path;	/* window path buffer		*/

WORD	pxyarray[10];	/* input point array 		*/

WORD	d_xywh[18];	/* disk icon pline points	*/
WORD	f_xywh[18];	/* file icon pline points	*/

OBJECT	*menu_addr;	/* menu address			*/
OBJECT	*background;	/* desktop object address	*/	
GRECT	dicon;		/* desktop icon size		*/
GRECT	r_dicon;	/* real time desktop icon size	*/
OBJECT	*iconaddr;	/* desktop icon dialogue address*/
WORD	maxicon;	/* max number of desktop icons	*/
WORD	i_status;	/* current status TURE or FALSE	*/
/* WORD	g_defdrv;	*/	/* save the default drive		*/
LONG	gh_buffer;	/* ghost icon outline buffer address	*/	
IDTYPE	*backid;	/* background icon type definition	*/
APP	*appnode;	/* app buffer array		*/
APP	*appfree;	/* app buffer free list		*/
APP	*applist;	/* app buffer list		*/
DTA	dtabuf;		/* dta buffer	*/
WINDOW	*warray[MAXWIN];/* window structure	*/	

/*	Variables for the desktop.inf file	*/

WORD	s_sort;		/* sort item	*/
WORD	s_view;		/* view item	*/
WORD	ccopy_save;	/* copy ?	*/
WORD	cdele_save;	/* delete ?	*/
WORD	write_save;	/* write ?	*/
WORD	cbit_save;	/* bitblt 	*/
WORD	pref_save;	/* screen pref	*/
WORD	s_cache;	/* cache 	*/
WORD	s_stofit;	/* size to fit	*/
UWORD	windspec;	/* window pattern	*/

/************************************************/

BYTE	autofile[PATHLEN];
BYTE	path1[PATHLEN];	/* utility path		*/
BYTE	path2[PATHLEN];
BYTE	*path3;
BYTE	inf_path[PATHLEN];	/* store the inf path	*/

BYTE	g_buffer[160];	/* merge string buffer	*/
BYTE	comtail[PATHLEN];/* comtail tail buffer	*/

WINDOW	winpd[MAXWIN + 1];/* window process structure	*/
WINDOW	*winhead;	/* head of window list 		*/
GRECT	full;		/* full window size value	*/

GRECT	fobj;		/* file object	*/

WORD	deskp[3];	/* desktop pattern	*/
WORD	winp[3];	/* window pattern	*/

BYTE 	getall[] = "*.*";
BYTE 	bckslsh[] = "\\";
BYTE 	curall[] = ".\\*.*";
BYTE 	baklvl[] = ".\\..";
BYTE	wildext[] = "A:\\*.*";
BYTE	wilds[] = "\\*.*"; 
BYTE	noext[] = "*.";
BYTE	Nostr[] = "";
BYTE	infdata[] = "DESKTOP.INF";
BYTE	infpath[] = "C:\\NEWDESK.INF";
BYTE	icndata[] = "C:\\DESKICON.RSC";
BYTE	cicndata[] = "C:\\DESKCICN.RSC";
BYTE	Nextline[] = "\012\015";


#if DESKPRG
/* APGSXIF.C Globals */
GLOBAL WORD	gl_nrows;
GLOBAL WORD	gl_ncols;

GLOBAL WORD	gl_wchar;	/* character cell width	*/
GLOBAL WORD	gl_hchar;	/* character cell height*/

GLOBAL WORD	gl_wbox;
GLOBAL WORD	gl_hbox;

GLOBAL WORD	contrl[12];
GLOBAL WORD	intin[256];
GLOBAL WORD	ptsin[256];
GLOBAL WORD	intout[256];
GLOBAL WORD	ptsout[256];

GLOBAL LONG	ad_intin;

GLOBAL	LONG	gl_vdo;

GLOBAL  WORD	ctldown;	/* ctrl key down ?	*/

#endif
