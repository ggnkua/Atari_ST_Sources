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
 *	d2.h
 */

#define basic_type(a,b) bas_type(a)
TP		dummy_id	(TP xp, TP head,short parnr),
		bas_type	(short btype),
		asm_type	(void),
		default_type(short sclass, short qualification);

TP		CC_type	(NP, NP);
short	CC_ty	(NP, NP);

NpV		add_tseg;

NP	 	a_init(TP);
BpT 	static_init;

VpT		warn_const,
		array_to_pointer,
		func_to_pointer;

bool	double_size(void *),
		same_intty(TP, TP),
		same_int(TP, TP);

BpTT	ok_gx,
		ok_lx,
		ok_sux,
		ok_enx,
		ok_prx,
		ok_cast;

VpTI 	to_type,
		regvar_options,
		new_class;

void 	su_size		(long *lp, char * cp, TP xp, short isunion),
		arg_size	(long *lp, TP xp),
		su_field	(TP xp, long *lp, char * alp, short fldw, short *fop),
		afterfld	(long *szp, short *fop),
		opt_enval	(long *intp),
		opt_field	(TP xp, short *wdp, short isunion),
		auto_init	(TP xp, NP ap, NP e1, short context),
		def_arg		(TP *listpp, TP op);

bool	ok_gsh		(short sc, TP np),
		ok_prh		(short sc, TP np),
		ok_lsh		(short sc, TP np);

long 	loc_size	(NP fp, TP xp, long *lp, ALREG *rp);
short	default_class(void),
		similar_type(short lvl, short q, TP a, TP b, short proty, short context);
void	loc_advice	(TP, NP);
void	set_vreg	(TP);
void	permanent_var(TP, short class);
bool	can_pu		(TP);
NP 		e_temp_var	(TP type);
