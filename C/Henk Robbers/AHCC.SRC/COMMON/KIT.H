/*  Copyright (c) 1989 - present by Henk Robbers Amsterdam.
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
 */

/*
 *	KIT.H
 *
 */

#ifndef CONFIG_H
#include "common/config.h"
#endif

typedef
struct kit_refs			/* make globally available */
{
	OBJECT *tree;			/*  KIT */
	TEDINFO	*varr,
			*vgrt,
			*vgrn,
#if WINTEXT
			*harr,
			*hgrn,
			*hgrt,
			*tabs,
			*tabn,
			*tabp,
			*split,
			*lnr,
#endif
#if GEMSHELL
			*definestr[5],
			*inclstr  [5],
			*matchstr,
			*libstr,
			*max_errors,
			*max_warnings,
			*rootname,
			*loads,
			*makes,
#endif
			*scvist;
#ifdef MNMULT
	S_path muldir;		/* multiple search directory */
#endif

#ifdef MNFCOMP
	S_path cp1dir,
		   cp2dir;
#endif
} KIT_REFS;

extern KIT_REFS pkit;
extern TEDINFO *dsfind[10];
extern short repl,edcur,butcur;
extern TEDINFO *dsrep;
extern S_path fdum;
extern char fkm[];
extern HELP_STACK *help_stack;

void	goto_line		(IT *wo,short l);	/* wo must be open & on top */
Cstr	get_matchstr	(void),
		get_definestr	(short),
		get_inclstr		(short),
		get_libstr		(void),
		get_rootname	(void),
		get_fistr		(short),
		get_repstr		(void);
short 	get_max_errors	(void),
		get_max_warnings(void),
		get_repl		(void);
void	kit_dial		(IT *w, short mn, short mt);
BpV		is_all,
		is_allw,
		is_talk,
		is_deep,
		is_once;
short 	find_type		(IT *,short);
VpV		invoke_kit,
		end_kit,
		kit_for_shell,
		reverse_rich,
		kit_save,
		find_multiple,
		coopt_save;
VpI		comp_folder;
bool	scan_file		(Cstr fn);
void	do_Search		(IT *w,short mt);
void	kit_drop		(IT *w, short ty, Wstr s, short mx, short my);
void	get_mulstr		(S_path *s);
void	change_font		(IT *wt, bool small);
void	flip_lnrs		(IT *wt, bool new);
void	get_cpfstr		(S_path *s1,S_path *s2);
void	set_find		(void);
void	restore_help_stack	(IT *w);
void	clear_help_stack(void);
void	menu_help		(bool);
