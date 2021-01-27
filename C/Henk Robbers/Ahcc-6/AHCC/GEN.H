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
 *	gen.h
 */

typedef bool GEN_CAST(NP np, NP lp);

bool	geni		(NP np),
		genx		(NP np, short context),
		is_temp		(short rno);

VpN		ret_df_reg,
		imm_oreg,
		imm_oname,
		freetmps,
		sys_call;

VpNN	free1;

bool	eval(NP, short, RMASK);

short 	tempr		(NP np, short type),
		ralloc		(short type, NP np);

RMASK	regm1		(short rno);

#define rfree(r)  (reserve &= ~RM(r))
