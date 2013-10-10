/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gsxdefs.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:27:54 $	$Locker: kbad $
* =======================================================================
*  $Log:	gsxdefs.h,v $
* Revision 2.2  89/04/26  18:27:54  mui
* TT
* 
* Revision 2.1  89/02/22  05:30:18  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:35:29  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GSXDEFS.H	05/06/84 - 12/08/84	Lee Lorenzen		*/

typedef struct wsstr
{
	WORD		ws_xres;
	WORD		ws_yres;
	WORD		ws_noscale;
	WORD		ws_wpixel;
	WORD		ws_hpixel;
	WORD		ws_ncheights;
	WORD		ws_nlntypes;
	WORD		ws_nlnwidths;
	WORD		ws_nmktypes;
	WORD		ws_nmksizes;
	WORD		ws_nfaces;
	WORD		ws_npatts;
	WORD		ws_nhatchs;
	WORD		ws_ncolors;
	WORD		ws_ngdps;
	WORD		ws_supgdps[10];
	WORD		ws_attgdps[10];
	WORD		ws_color;
	WORD		ws_rotate;
	WORD		ws_fill;
	WORD		ws_cell;
	WORD		ws_npals;
	WORD		ws_nloc;
	WORD		ws_nval;
	WORD		ws_nchoice;
	WORD		ws_nstring;
	WORD		ws_type;
	WORD		ws_pts0;
	WORD		ws_chminh;
	WORD		ws_pts2;
	WORD		ws_chmaxh;
	WORD		ws_lnminw;
	WORD		ws_pts5;
	WORD		ws_lnmaxw;
	WORD		ws_pts7;
	WORD		ws_pts8;
	WORD		ws_mkminw;
	WORD		ws_pts10;
	WORD		ws_mkmaxw;
} WS;


typedef struct fdbstr
{
	LONG		fd_addr;
	WORD		fd_w;
	WORD		fd_h;
	WORD		fd_wdwidth;
	WORD		fd_stand;
	WORD		fd_nplanes;
	WORD		fd_r1;
	WORD		fd_r2;
	WORD		fd_r3;
} FDB;


typedef struct mfstr
{
	WORD	mf_xhot;
	WORD	mf_yhot;
	WORD	mf_nplanes;
	WORD	mf_fg;
	WORD	mf_bg;
	WORD	mf_mask[16];
	WORD	mf_data[16];
} MFORM ;

