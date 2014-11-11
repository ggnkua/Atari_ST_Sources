   /* external function declarations for rcsobjs.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSOBJS_H

#define RCSOBJS_J

EXTERN	WORD	snap_xs(WORD x);
EXTERN	WORD	snap_ys(WORD y);
EXTERN	WORD	clamp_xs(LONG tree, WORD x);
EXTERN	WORD	clamp_ys(LONG tree, WORD y);
EXTERN	VOID	do_hsinc(WORD inc);
EXTERN	VOID	do_vsinc(WORD inc);
EXTERN	VOID	set_rootxy(LONG tree);
EXTERN  WORD	newsize_obj(LONG tree, WORD obj, WORD neww, WORD newh, WORD ok);
EXTERN  VOID	slid_objs(VOID);
EXTERN	VOID	view_objs(VOID);
EXTERN	VOID	type_obj(WORD obj);
EXTERN	VOID	del_ob(WORD sobj);
EXTERN  WORD	posn_obj(LONG tree, WORD obj, WORD *px, WORD *py, WORD w, WORD h, WORD exact_ok);
EXTERN	VOID	cut_obj(WORD sobj, WORD dup);
EXTERN	VOID	paste_obj(WORD dobj, WORD dx, WORD dy, WORD dup);
EXTERN	WORD	new_obj(LONG stree, WORD sobj, WORD dobj, WORD dx, WORD dy);
EXTERN	VOID	mov_obj(WORD sobj, WORD dobj, WORD dx, WORD dy);
EXTERN  VOID	size_obj(LONG tree, WORD obj);
EXTERN	VOID	slct_obj(LONG tree, WORD obj);
EXTERN	VOID	mslct_obj(LONG tree, WORD obj);
EXTERN	VOID	dslct_1obj(LONG tree, WORD obj);
EXTERN	VOID	map_dslct(LONG tree, WORD obj);
EXTERN	VOID	dslct_obj(LONG tree, WORD obj);
EXTERN	VOID	unhid_part(WORD obj);
EXTERN	VOID	sort_part(WORD obj);
EXTERN	VOID	flatten_part(WORD obj);

#endif
