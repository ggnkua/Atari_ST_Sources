/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
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
 *	reg.h
 */

typedef	struct linfo
{
	struct linfo *next,
	             *prior,
	             *disps;		/* list of displacements for area refs */
	long loffset;	/* offset from local name base */
	short
		size,		/* size of the object */
		ref,		/* # of references to the local */
		reg,		/* reg. we assigned it to */
		area,		/* standard area number */
		type,		/* type */
		flags;		/* attributes */
	Cstr name;
	VREG_INFO vreg;
	void *st;
} LOCVAR;

RMASK	s_to_mask	(Cstr),
		get_locs	(IP);

void	setreg		(BP),
        clrvar		(void),
        freevar		(LOCVAR *loc);
LOCVAR * addvar		(IP, short);

char *	str_alloc	(Cstr s);

extern LOCVAR *locals;