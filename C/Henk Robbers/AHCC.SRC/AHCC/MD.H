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
 *	md.h
 */

typedef void CON_CAST(NP cp, TP ctp, TP ntp);

TpNI	shiftty,
		bitsty,
		normalty;
TpN		scalety,		/* was addty */
		colonty;

TpT		functy, yields_proc;

VpN		chkcmp,
		ins_zero,
		cmp_zero;

void	cast_up(NP, TP, char *);

NpN 	arg_regs;

VpNN	castasn,
		castasop,
		castasmagic,
		comma_r,
		comma_l,
		fieldas;

void	cast_compare(NP, NP, NP);

IpN		icon_ty;

bool	is_CC(void *),
		const_check	(NP lp, short context);

BpN		external_unary_op,
		external_cast,
		external_binary_op,
		mustlval,
		is_zero;

BpNI	mustty, must2ty;

TpTI	yields_ty;

TpNTI	hardasmagic;
TpNT	hardas;

void	Cast		(NP np, TP tp, short cnv, Cstr cn),
		asn_check	(TP ltp, NP rp, short context),
		castdefault	(NP lp, NP rp, TP tp),
		add_argbase	(TP tp, TP tm, long base);

bool
#if FOR_A
		arg_check	(NP np, TP tl, bool loc),
#else
		arg_check	(NP np, TP tl),
#endif
		postincdec	(NP np, TP tp, short firstun, short newun, short newop),
		incdec		(NP np, TP tp, short newop),
		lc_reg		(ALREG *rp, TP xp, char *up),
		is2pow		(long val),
		make2pow	(long *val);

short	modify_type	(short type, short modifier),
		plain_type	(short old),
		widen		(short ty),
		narrow		(TP tp, short to),
		lwiden		(short ty);

long	arg_align	(long sz, TP np);

Cstr	prdeclarer	(TP list);
bool	cast_con	(NP cp, TP ntp, Cstr cn, short context);