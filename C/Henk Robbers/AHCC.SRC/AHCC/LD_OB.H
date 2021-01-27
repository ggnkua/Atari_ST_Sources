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
 * ld_ob.h           code for loading objectfiles in ld
 *
 * built in linker for Pure C object format
 */

typedef struct
{
	short f,
	     j,
	     m,
	     st,
	     v,
	     y,
	     tt,
	     b,
	     d,
	     t,
	     map,
	     glo,
	     loc,
	     nmsym;
} FLGS;

extern
FLGS flags;

extern
bool gfa;

extern
long stacksize;

extern
char stackname[];

extern
short ld_lbl;

extern
REFBASE gl_base;

AREA *	anon_ref		(FIXUP *f, REFS *loc, long *disp);
short	format_error	(FLIST *fl, short nr);
bool	load_ob			(FLIST *fl);
void	new_locref		(MEMBASE *mb, REFBASE *rb, AREA *area, FIXUP *f);
void	new_ref			(MEMBASE *mb, REFBASE *rb, AREA *area, FIXUP *f, int obty);
REFS *	find_locref		(REFBASE *rb, short nd);
