   /* external function declarations for rcsiedit.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSIEDIT_H

#define RCSIEDIT_H

EXTERN	VOID	del_img(BOOLEAN mouse, WORD which);
EXTERN	VOID	clear_clipb(VOID);
EXTERN	VOID	draw_outline(GRECT *area);
EXTERN	VOID	copy_clor(LONG spt, WORD color);
EXTERN	VOID	draw_clipb(BOOLEAN mouse, GRECT *dirty);
EXTERN	VOID	copy_img(BOOLEAN mouse);
EXTERN	VOID	cut_img(VOID);
EXTERN	VOID	do_paste_img(VOID);
EXTERN	VOID	solid_img(VOID);
EXTERN	VOID	invrt_img(VOID);
EXTERN	VOID	icon_size(WORD *pwidth, WORD *pheight);
EXTERN	VOID	horiz_scale(BYTE *srcpt, WORD srcw, BYTE *despt);
EXTERN	VOID	scale_img(LONG srcpt, WORD srcw, WORD srch, LONG despt);
EXTERN	VOID	keep_img(LONG srcpt, WORD srcw, WORD srch, LONG despt);
EXTERN	VOID	resize(LONG src_pt, WORD src_w, WORD src_h, LONG des_pt);

#endif
