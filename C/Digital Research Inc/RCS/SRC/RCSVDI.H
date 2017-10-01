   /* external function declarations for rcsvdi.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSVDI_H

#define RCSVDI_H

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

EXTERN	VOID	gr_rect(WORD icolor, WORD ipattern, GRECT *pt);
EXTERN	VOID	gsx_sclip(GRECT *pt);
EXTERN	VOID	gsx_bxpts(GRECT *pt);
EXTERN	VOID	gsx_attr(WORD text, WORD mode, WORD color);
EXTERN	VOID	gsx_xbox(GRECT *pt);
EXTERN	VOID	gsx_untrans(LONG saddr, WORD swb, LONG daddr, WORD dwb, WORD h);
EXTERN	VOID	gsx_trans(LONG saddr, WORD swb, LONG daddr, WORD dwb, WORD h);
EXTERN	VOID	gsx_outline(GRECT *pt);
EXTERN	VOID	gsx_invert (GRECT *pt);
EXTERN	WORD	ch_width(WORD fn);
EXTERN	WORD	ch_height(WORD fn);
EXTERN	WORD	gsx_start(VOID);
EXTERN	VOID	gsx_vopen(VOID);
EXTERN	VOID	bb_save(GRECT *ps);
EXTERN	VOID	bb_restore(GRECT *pr);

#endif
