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

/*	decl.h
 */

TP
		Declarer	(bool loc, short *dclass, short *sclass, bool *declty),
		Declare		(TP head, short dty),
		all_syms	(TP np, short usage);

BpV		loc_decls,
		is_ty_start;

IpT		dot_sym;

VpT 	loc_sym, globl_sym;

void	list_sym	(TP *list, TP xp);

TP 		ok_decl_A	(TP e1, TP head, short dty);
TP 		Declare_A	(TP e1, TP head);
TP 		B_follow	(TP);
