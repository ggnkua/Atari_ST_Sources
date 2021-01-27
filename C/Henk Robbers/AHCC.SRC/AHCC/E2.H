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
 *	e2.h
 */

typedef void TYPE_FUN(NP np, short context, short usage);

TYPE_FUN
		form_types,
		binary_types,
		leaf_types;

void	cold_con		(NP np, TP tp);

VpNI	do_expr;
TpN		for_row_expr,
		for_ref_expr;
VpN		aposty_expr,
		aprioty_expr;
VpNT   	ret_expr,
		from_expr,
		by_expr,
		take_flgs;
void	to_expr			(NP np, TP lv, short l);

BpTT	coercable;

long	confold_value	(NP np, short context);

#if FLOAT
void	newrcon			(NP np, double x);
#endif

NpV		asm_expr;

NP 		make_bin		(short tok, Cstr name, NP lp, NP rp);

