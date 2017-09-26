   /* external function declarations for rcsintf.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RSCINTF_H

#define RCSINTF_H

EXTERN  WORD	hndl_dial(LONG tree, WORD def, GRECT *p);
EXTERN  WORD	hndl_alert(WORD b_num, LONG addr);
EXTERN	VOID	hndl_locked(VOID);
EXTERN	VOID	mouse_form(WORD f_num);
EXTERN	VOID	ini_panes(VOID);
EXTERN	VOID	view_parts(VOID);
EXTERN	VOID	set_menus(VOID);
EXTERN	VOID 	menu_opts(LONG tree, WORD obj);
EXTERN	VOID	clr_hot(VOID);
EXTERN	VOID	set_hot(VOID);
EXTERN	VOID	set_switch(VOID);
EXTERN	VOID	new_state(WORD new);
EXTERN	WORD	file_view(VOID);
EXTERN	WORD	tree_view(VOID);
EXTERN	VOID	clr_clip(VOID);
EXTERN	VOID	set_title(BYTE *new);
EXTERN	VOID	get_defpath(BYTE *path, BYTE *spec);
EXTERN	VOID	clr_title(VOID);
EXTERN	VOID	hot_off(VOID);
EXTERN	VOID	wait_tools(VOID);
EXTERN	VOID	wait_obj(LONG tree, WORD obj);
EXTERN	WORD	pane_find(LONG *tree, WORD *obj, WORD mx, WORD my);
EXTERN	WORD	hndl_pop(WORD obj, BOOLEAN itool);
EXTERN	VOID	hot_dragbox(GRECT *p, GRECT *pc, WORD *mx, WORD *my, WORD hot);
EXTERN	VOID	clamp_rubbox(WORD x, WORD y, WORD wlow, WORD hlow, WORD whigh, WORD hhigh,
	LONG ahigh, WORD *w, WORD *h, GRECT *bound);
EXTERN	VOID	obj_handle(LONG tree, WORD obj, GRECT *p);
EXTERN	VOID	about_dial(VOID);
EXTERN	VOID	info_dial(WORD obj);
EXTERN	VOID	read_inf(WORD flag);
EXTERN	VOID	wrte_inf(VOID);
EXTERN	VOID	outp_dial(VOID);
EXTERN	VOID	safe_dial(VOID);
EXTERN	VOID	ini_prog(VOID);
EXTERN	VOID	show_prog(WORD strno);

#endif
