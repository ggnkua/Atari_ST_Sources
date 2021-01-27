/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
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
 *	gsub.h
 */

VpN		branch_tree,
		untype,
		fldtoint,
		strret;

BpN		specasn;

void	gen_boolean	(NP np, short lbl, short truth),
		addcode		(NP np, Cstr s),
		addcode_betw(NP np, Cstr s);

bool	strasn		(NP np, bool fmeaea);

long	strpush		(NP np, short ty, bool fpeaea);

void	gen_switch	(VP np, short size, short odlbl);
