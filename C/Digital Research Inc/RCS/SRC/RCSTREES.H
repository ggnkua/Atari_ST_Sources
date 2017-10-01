   /* external function declarations for rcstrees.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSTREES_H

#define RCSTREES_H

EXTERN	WORD	trpan_f(WORD obj);
EXTERN	WORD	fit_vtrees(VOID);
EXTERN	WORD	fit_htrees(VOID);
EXTERN	WORD	need_vtrees(VOID);
EXTERN	WORD	snap_trs(WORD tr);
EXTERN	WORD	clamp_trs(WORD tr);
EXTERN	VOID	do_trsinc(WORD inc);
EXTERN	VOID	view_trees(VOID);
EXTERN  VOID    slid_trees(VOID);
EXTERN	VOID	redo_trees(VOID);
EXTERN	VOID	del_tree(WORD sobj);
EXTERN	VOID	cut_tree(WORD sobj, WORD dup);
EXTERN	VOID	paste_tree(WORD dobj, WORD dx, WORD dy, WORD dup);
EXTERN	VOID	new_tree(WORD sobj, WORD dobj, WORD dx, WORD dy);
EXTERN	VOID	dup_tree(WORD sobj, WORD dobj, WORD dx, WORD dy);
EXTERN  WORD	mov_tree(WORD sobj, WORD dobj, WORD dx, WORD dy);
EXTERN	VOID	open_tree(WORD obj);
EXTERN	VOID	clos_tree(VOID);
EXTERN	VOID	name_tree(WORD obj);
EXTERN	VOID	type_tree(WORD obj);
EXTERN  VOID	select_tree(LONG tree, WORD obj);
EXTERN	VOID	dselct_tree(LONG tree, WORD obj);

#endif
