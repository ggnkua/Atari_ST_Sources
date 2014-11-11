   /* external function declarations for rcsimain.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSIMAIN_H

#define RCSIMAIN_H

EXTERN	VOID	fat2sml(WORD x[], WORD y[], WORD count, WORD isdata);
EXTERN	VOID	set_pix(VOID);
EXTERN	VOID	set_scroll(VOID);
EXTERN	VOID	copy_colplanes(LONG longaddr, WORD color, WORD isdata);
EXTERN	VOID	dr_image(VOID);
EXTERN	VOID	hold_to_undo(VOID);
EXTERN	VOID	save_fat(BOOLEAN undo);
EXTERN	VOID	fattify(GRECT *area);
EXTERN	WORD	CDECL	dr_code(LONG pparmbk);
EXTERN	VOID	fb_redraw(VOID);
EXTERN	VOID	set_bgcol(WORD item, BOOLEAN invert);
EXTERN	VOID	set_fgcol(WORD item,BOOLEAN invert);
EXTERN	VOID	save_img(VOID);
EXTERN	VOID	rubrec_off(VOID);
EXTERN	VOID	undo_img(VOID);
EXTERN	VOID	iconmain(VOID);

#endif
