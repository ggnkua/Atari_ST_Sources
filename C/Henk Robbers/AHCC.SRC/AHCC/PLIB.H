/* Copyright (c) 2004 - present by H. Robbers.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * plib.h
 *
 * common between ld.c, po.c and as_out.c
 */

#include "list.h"

extern MEMBASE defmem, refmem, opndmem;
extern STATS stats;

VpV		init_stats, pr_stats, list_flist;
void	new_flist(Cstr);
bool	is_ref		(short ty);
bool	is_lc_entry	(short ty);
bool	is_gl_entry	(short ty);
bool	is_entry	(short ty);
short	ldhash		(Cstr s);
bool	no_image	(short ty);
bool	is_module	(short ty);
char *	fixup_name	(short ty);
void	disp_fix	(FIXUP *f, short level, char *out);
void	list_fixups	(FIXUP *f);
void	list_all_fixups(void);
char *	disp_target	(short tg);
void	list_refs	(REFS *rf, bool in);
void	clr_treebase(REFBASE *rb, bool hashed, short numhash, REFS **hash_row, char *name);
FLIST *	ins_flist	(Cstr f, XA_key key, FLIST *after, XA_run_out *ranout);
REFS *	ins_ref		(MEMBASE *mb, REFBASE *rb, AREA *area, FIXUP *f, XA_run_out *ranout);
FIXUP * new_fixup	(FIXBASE *this, PO_NAME *name, short target, short ty, char *start, long disp, XA_run_out *ranout);
AREA *	new_area	(FLIST *fl, short target, Cstr name, XA_run_out *ranout);
char *	add_areas	(short ty, char **to, long *l);
void	write_areas	(long hdl, short ty);
void 	write_object(Cstr, short, bool, XA_run_out *);
void	list_areas	(AREA *ar, bool out);
