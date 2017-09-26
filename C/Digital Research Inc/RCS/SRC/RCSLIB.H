   /* external function declarations for rcslib.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSLIB_H

#define RCSLIB_H

#include <stdio.h>

typedef WORD (*fkt_parm)();

EXTERN	VOID	set_slsize(WORD w_handle, WORD h_size, WORD v_size);
EXTERN	VOID	set_slpos(WORD w_handle, WORD h_pos, WORD v_pos);
EXTERN	WORD	ini_tree(LONG *tree, WORD which);
EXTERN	LONG	image_addr(WORD which);
EXTERN	LONG	string_addr(WORD which);
EXTERN	VOID	arrange_tree(LONG tree, WORD wint, WORD hint,WORD *maxw, WORD *maxh);
EXTERN	WORD	get_parent(LONG tree, WORD obj);
EXTERN	WORD	nth_child(LONG tree, WORD nobj, WORD n);
EXTERN	WORD	child_of(LONG tree, WORD nobj, WORD obj);
EXTERN	VOID	table_code(LONG tree, WORD obj0, WORD *types, WORD ntypes, WORD type);
EXTERN	WORD	encode(LONG tree, WORD ob1st, WORD num);
EXTERN	VOID	map_tree(LONG tree, WORD this, WORD last, fkt_parm routine);
EXTERN	VOID	snap_xy(WORD *x, WORD *y);
EXTERN	VOID	snap_wh(WORD *w, WORD *h);
EXTERN  VOID	text_wh(LONG taddr, WORD type, WORD *w, WORD *h);
EXTERN  VOID	icon_wh(LONG taddr, WORD *w, WORD *h);
EXTERN	VOID	icon_tfix(LONG taddr);
EXTERN	VOID	trans_bitblk(LONG obspec);
EXTERN	VOID	rast_op(WORD mode, GRECT *s_area, MFDB *s_mfdb, GRECT *d_area, MFDB *d_mfdb);
EXTERN	VOID	outl_obj(LONG tree, WORD obj, GRECT *clprect);
EXTERN	VOID	invert_obj(LONG tree, WORD obj, GRECT *clprect);
EXTERN	VOID	trans_obj(LONG tree, WORD obj);
EXTERN	VOID	unfix_chpos(LONG where, WORD x_or_y);
EXTERN	VOID	rs_obfix(LONG tree, WORD curob);
EXTERN	VOID	enab_obj(LONG tree, WORD which);
EXTERN	VOID	disab_obj(LONG tree, WORD which);
EXTERN	VOID	sel_obj(LONG tree, WORD which);
EXTERN	VOID	desel_obj(LONG tre, WORD which);
EXTERN	VOID	chek_obj(LONG tree, WORD which);
EXTERN	VOID	unchek_obj(LONG tree, WORD which);
EXTERN	VOID	hide_obj(LONG tree, WORD which);
EXTERN	VOID	unhide_obj(LONG tree, WORD which);
EXTERN	VOID	sble_obj(LONG tree, WORD which);
EXTERN	VOID	unsble_obj(LONG tree, WORD which);
EXTERN	VOID	objc_xywh(LONG tree, WORD obj, GRECT *p);
EXTERN	VOID	ob_setxywh(LONG tree, WORD obj, GRECT *pt);
EXTERN	VOID	ob_relxywh(LONG tree, WORD obj, GRECT *pt);
EXTERN	WORD	min(WORD a, WORD b);
EXTERN	WORD	max(WORD a, WORD b);
EXTERN  VOID	strup(BYTE *p1);
EXTERN	VOID	LLSTRCPY(LONG src, LONG dest);
EXTERN	WORD	LLSTRCMP(LONG l1, LONG l2);
EXTERN	VOID	LWINC(LONG x);
EXTERN  WORD	dmcopy(FILE *stream, LONG msrc, LONG mdest, WORD mln);
EXTERN	WORD	GET_NEXT(LONG tree, WORD x);
EXTERN	WORD	GET_HEAD(LONG TREE, WORD x);
EXTERN	WORD	GET_TAIL(LONG tree, WORD x);
EXTERN	WORD	GET_TYPE(LONG tree, WORD x);
EXTERN	WORD	GET_FLAGS(LONG tree, WORD x);
EXTERN	WORD	GET_STATE(LONG tree, WORD x);
EXTERN	LONG	GET_SPEC(LONG tree, WORD x);
EXTERN	WORD	GET_X(LONG tree, WORD x);
EXTERN	WORD	GET_Y(LONG tree, WORD x);
EXTERN	WORD	GET_WIDTH(LONG tree, WORD x);
EXTERN	WORD	GET_HEIGHT(LONG tree, WORD x);
EXTERN	VOID	SET_NEXT(LONG tree, WORD x, WORD val);
EXTERN	VOID	SET_HEAD(LONG tree, WORD x, WORD val);
EXTERN	VOID	SET_TAIL(LONG tree, WORD x, WORD val);
EXTERN	VOID	SET_FLAGS(LONG tre, WORD x, WORD val);
EXTERN	VOID	SET_STATE(LONG tree, WORD x, WORD val);
EXTERN	VOID	SET_SPEC(LONG tree, WORD x, LONG val);
EXTERN	VOID	SET_X(LONG tree, WORD x, WORD val);
EXTERN	VOID	SET_Y(LONG tree, WORD x, WORD y);
EXTERN  VOID	SET_WIDTH(LONG tree, WORD x, WORD y);
EXTERN	VOID	SET_HEIGHT(LONG tree, WORD x, WORD y);

#endif
