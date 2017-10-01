   /* external function declarations for rcsdata.c */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSDATA_H

#define RCSDATA_H

#include "rcsdefs.h"
#include "rcslib.h"

EXTERN	VOID	del_objindex(LONG tree, WORD obj);
EXTERN	VOID	count_free(LONG tree, WORD obj);
EXTERN	VOID	dcomp_tree(LONG tree, WORD obj);
EXTERN	VOID	ini_buff(VOID);
EXTERN	VOID	clr_tally(VOID);
EXTERN	VOID	tally_obj(LONG tree, WORD obj);
EXTERN	VOID	map_all(fkt_parm routine);
EXTERN	WORD	find_tree(WORD n);
EXTERN	WORD	find_obj(LONG tree, WORD obj);
EXTERN	BYTE	*get_name(WORD key);
EXTERN	LONG	tree_addr(WORD n);
EXTERN	LONG	avail_mem(VOID);
EXTERN	VOID	tally_free(VOID);
EXTERN  WORD	new_index(BYTE *val, WORD kind, BYTE *name);
EXTERN	VOID	set_value(WORD key, BYTE *val);
EXTERN	BYTE	*get_value(WORD key);
EXTERN	WORD	get_kind(WORD key);
EXTERN	WORD	find_value(BYTE *val);
EXTERN	LONG	str_addr(WORD n);
EXTERN	LONG	img_addr(WORD n);
EXTERN	LONG	get_mem(UWORD bytes);
EXTERN	LONG	copy_tree(LONG stree, WORD obj, WORD specopy);
EXTERN	WORD	copy_objs(LONG stree, WORD obj, LONG dtree, WORD specopy);
EXTERN	VOID	add_trindex(LONG tree);
EXTERN  VOID	set_kind(WORD key, WORD kind);
EXTERN	WORD	find_name(BYTE *name);
EXTERN	WORD	tree_kind(WORD kind);
EXTERN	VOID	unique_name(BYTE *name, BYTE *ptn, WORD n);
EXTERN	LONG	tree_ptr(WORD n);
EXTERN	LONG	str_ptr(WORD n);
EXTERN	LONG	img_ptr(WORD n);
EXTERN	BYTE	*c_lookup(UWORD what, LOOKUP *where, UWORD n, BYTE *punt);
EXTERN	VOID	copy_spec(LONG tree, WORD obj);
EXTERN	VOID	indx_obs(LONG tree, WORD which);
EXTERN	WORD	fnd_ob(WORD old);
EXTERN  VOID	dcomp_free(VOID);
EXTERN	VOID	zap_objindex(LONG tree, WORD obj);
EXTERN	WORD	name_ok(BYTE *name, WORD ok, WORD nilok);
EXTERN	WORD	set_obname(LONG tree, WORD obj, BYTE *name, LONG ntree, WORD nobj);
EXTERN	VOID	get_obname(BYTE *name, LONG ntree, WORD nobj);
EXTERN	LONG	mak_trindex(WORD nentry);
EXTERN	LONG	mak_frstr(WORD nentry);
EXTERN	LONG	get_obmem(VOID);		/* in RCSDATA.C */
EXTERN  VOID	update_if(LONG taddr, BYTE *naddr);

#endif
