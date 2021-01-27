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
 *	g2.c
 *
 *	Generate code for binary nodes.
 */

#include <stdio.h>
#include <string.h>
#include <tos.h>

#include "param.h"

#include "code.h"
#include "gen.h"
#include "d2.h"
#include "g2.h"
#include "gsub.h"
#include "md.h"
#include "out.h"


extern
short context_flags[];

#define debugG G.xflags['g'-'a']


static short is_real(NP lp, NP rp)
{
#if FLOAT
	if (G.use_FPU)
		if (lp->ty eq ET_R or rp->ty eq ET_R)
			return REAL;
#endif
	return 0;
}

static
void pf(BOPS *bop)
{
	console("'%s'\t= %004x\n", bop->op, bop->opflags);
}

VpV popflags
{
	pf(&bop_cmp);
	pf(&bop_eor);
	pf(&bop_fcp);
	pf(&bop_mul);
	pf(&bop_div);
	pf(&bop_mod);
	pf(&bop_and);
	pf(&bop_or);
	pf(&bop_add);
	pf(&bop_sub);
	pf(&bop_asl);
	pf(&bop_asr);
	pf(&bop_rol);
	pf(&bop_ror);
	pf(&bop_fadd);
	pf(&bop_fsub);
	pf(&bop_assign);
}


#if FLOAT
global
bool is_sw_dbl(void *vp)
{
	NP np = vp;
	return !G.use_FPU and np->ty eq ET_R and double_size(np);
}
#endif

#if LL
bool is_ll(void *vp)
{
	NP np = vp;
	return (np->ty eq ET_S or np->ty eq ET_U) and np->size > SIZE_L;
}
#endif

static
void inherit(NP np, NP ip)
{
	np->token = ip->token;
	np->val.i = ip->val.i;
	np->area_info = ip->area_info;
#if FLOAT
	if (ip->token eq RCON)
		ip->val.dbl = nil;
#endif
	np->vreg = ip->vreg;
	np->rno   = ip->rno;
	np->eflgs.f.imm = ip->eflgs.f.imm;
}

global
void linherit(NP np)
{
	NP lp = np->left;
	inherit(np, lp);
	c_mods(np, lp);				/* 09'19 HR: v6 correct pascal behaviour */
	np->eflgs.f.lname = 1;
}

global
void rinherit(NP np)
{
	inherit(np, np->right);
	np->eflgs.f.rname = 1;
}

static
ushort class(NP np, ushort flop)
{
	short imm = np->eflgs.f.imm;

	switch (np->token)
	{
	case ICON:
#if FLOAT
	case FCON:
	case RCON:					/* sw dbl & fpu */
#endif
		return CL_IMM;
#if COLDFIRE
	case OLNAME:
		return CL_ADR|CL_ABS;		/* no immediates or memory direct */
#endif
	case ONAME:
	case O_ABS:					/* 03'10 */
#if COLDFIRE
	#if FLOAT
		if (G.Coldfire and np->ty eq ET_R)
			return CL_ADR|CL_ABS;		/* no immediates or memory direct */
	#endif
		if (imm)
			return CL_IMM;
		if (G.Coldfire)
			return CL_ADR|CL_ABS;	/* 09'10 HR: CL_ABS missing here */
		return CL_ADR;
#endif
	case OREG:
		if (imm)
			return CL_IMM;
		return CL_ADR;
	case PUSHER:
		return CL_ADR;
	case REGVAR:
		if (np->rno >= AREG)
			return CL_AREG;
/*  fpu: All fpu instruction must have a fp reg as destination.
	so if the dest is a <dn> it is treated as an <ea>.
	There were no bits left for, say, FopM flags.
	The flag is only given for class(ip).
*/
		if (np->rno <= Dhigh and flop)
			return CL_ADR;
		if (np->rno >= FREG and np->rno <= Fhigh)	/* 06'11 HR */
			return CL_DREG|CL_FREG;
		return CL_DREG;
	default:
		CE_NX(np, "Weird class %s", ptok(np->token));
		return CL_IMM;
	}
}

static
ushort quickflag(NP np, ushort flags)
{
	if (np->token ne ICON)
		return 0;

	/* for shifts only */
	if ((flags & QopD) ne 0)
	{
		if (is_quick(np->val.i))
			return IopD;
	}
	if (	(flags & ONEopM)
		and np->val.i  eq 1
		and np->size eq DOT_W			/* size must be word */
		)
		return IopM;

	return 0;
}

static
short cansh[] = {0, 0, 4, 0,  8, 0, 0, 0, 12};
static
short canswap;

#if C_DEBUG
ulong canflag(ulong l, ulong r)
{
	if (r > sizeof(cansh))
	{
		message("canflag %ld", r);
		return l;
	}
	return l << cansh[r];
}
#else
#define canflag(l, r)	(l << cansh[r])
#endif

/*	There are so many reasons for returning false. So I decided
    to reverse truth value and to put meaning into falsehood.
*/
static
short cando(NP np, ushort flags, ulong restr, ushort lc, ushort rc)
{
	NP lp = np->left, rp = np->right;

	/*  operation includes hw floating point */
	/*	dest must be FPU */
	/* !! There was no room left in rc,lc for a CL_FREG flag */
#if COLDFIRE
	if (G.Coldfire)		/* cant always do memory direct */
	{
		ulong rf, lf, m = CL_ABS;

		if ( (restr&CANAI) eq 0)		/* no assignments */
			m |= CL_IMM;

		rf = rc & m;
		lf = lc & m;

		if (restr & CANRM)
			if (rf)										return 101;
		if (restr & CANLM)
			if (lf)										return 102;

		/* 09'12 HR v4.13 */
		if ((restr & CAN3Q) and G.i2_68020)				return 103;
		/* 09'12 HR v4.12 */
		if (!G.i2_68020)
			if (restr & CAN3Q)
			{
				if (!(    (rc&CL_IMM)
					  and (rc&CL_ABS) eq 0
				      and can_3q(rp->val.i)
				      and lp->size eq DOT_L
				   ) )									return 104;		/* 09'12 v4.12 */
			}
		/* 06'11 HR: For binary (uniform) floating point operations: */
		if (restr & CANLRM)
			if (rf and !lf)								return 105;
		if (restr & CANRLM)
			if (rf and  lf)								return 106;
	}
	else
#endif
	if (restr & CAN3Q)									return 1040;

	if (flags & REAL)
	{
		if (restr & CANLR)
			if ( !(rc & CL_DREG) or !yfreg(rp) )		return 11;
		if (restr & CANRL)
			if ( !(lc & CL_DREG) or !yfreg(lp) )		return 12;

	othw					/* dest may NOT be FPU */
		if (restr & CANLR)
			if ( (rc & CL_DREG) and yfreg(rp) )			return 13;
		if (restr & CANRL)
			if ( (lc & CL_DREG) and yfreg(lp) )			return 14;
	}

	/* ixc #data as-> <ea> */
	if  ( restr & CANIM )
	{
		if ((flags & IopM) eq 0)						return 15;
		if ( !((rc & CL_IMM) and (lc & CL_ADR))	)		return 16;
		if (flags&ONEopM)								return 17;
		/*	memory shifts have their own table entry */
	}

	/* ixc #data as-> dn */
	if ( restr & LISREGVAR)
	{
		if ( ( lc & (CL_DREG|CL_AREG) ) eq 0 )			return 18;
		if (flags & QopD)
			if (!is_quick(rp->val.i))					return 19;
	}

	/* 06'11 HR for tblasn* */
	if ( restr & LISREG)
		if ( ( lc & (CL_DREG|CL_AREG) ) eq 0 )			return 20;
	if ( restr & RISREG)
		if ( ( rc & (CL_DREG|CL_AREG) ) eq 0 )			return 21;

/* below is same as HCC */
	if ( restr & RISTMP )
		if (   (rc & (CL_DREG|CL_AREG)) eq 0
			or is_temp(rp->rno) eq 0
		   )  											return 1;

	if (restr & LISTMP)
		if (   (lc & (CL_DREG|CL_AREG)) eq 0
			or is_temp(lp->rno) eq 0
		   )											return 2;

	if (restr & NDASSOC)
		if (canswap eq 0)	/* if !ASSOC */				return 3;

	if   (restr & (CANLR|CANLD))
		flags |= quickflag(lp, flags);
	elif (restr & (CANRL|CANRD))
		flags |= quickflag(rp, flags);

	lc &= 0x0f;			/* 09'10 HR security */
	rc &= 0x0f;
	flags &= 0xfff;

	if (    (restr & CANLR)
		and (flags & canflag(lc,     rc     )) eq 0)	return 4;
	if (    (restr & CANRL)
		and (flags & canflag(rc,     lc     )) eq 0)	return 5;
	if (    (restr & CANRD)
		and (flags & canflag(rc,     CL_DREG)) eq 0)	return 6;
	if (    (restr & CANDL)
		and (flags & canflag(CL_DREG,lc     )) eq 0)	return 7;
	if (    (restr & CANLD)
		and (flags & canflag(lc,     CL_DREG)) eq 0)	return 8;
	if (    (restr & CANDR)
		and (flags & canflag(CL_DREG,rc     )) eq 0)	return 9;
	if (    (restr & CANDD)
		and (flags & DopD) eq 0)						return 10;
	return 0;
}

static
void dotbl(MTBL *pt, NP np)
{
	if (pt->needregs or pt->needd or pt->needa)
	{
		short i, k;

		i = pt->needregs;
		if (i & RETLEFT)
			linherit(np);
		elif (i & RETRIGHT)
			rinherit(np);
		elif (i & RETAREG)
			retreg(np, ralloc(AREG, nil));
		elif (i & RETDREG)
			retreg(np, ralloc(DREG, np));
		k = pt->needd;
		while (k--)
			tempr(np, DREG);
		k = pt->needa;
		while (k--)
			tempr(np, AREG);
	}

	addcode(np, pt->template);

}

static
void pr_class(NP np, ushort fop, short cl, char *s)
{
	short imm = np->eflgs.f.imm;
	message("%s %s, imm %d, fop 0x%04x, rno %d class 0x%04x", s, ptok(np->token), imm, fop, np->rno, cl);
}

static
bool fix_sub(NP np, ushort flags, MTBL *pt)
{
	short lc = class(np->left, flags&REAL),	/* Ran out of bits for Fop.. flags */
	      rc = class(np->right,flags&REAL);

	while (pt->restr)
	{
		short rv = cando(np,
		           flags,
		           pt->restr,
		           lc,
		           rc
		          );

		if (rv eq 0)
		{
			dotbl(pt, np);
			return true;
		}
		pt++;
	}
	messagen(np, "Internal error: no code table match! ");
	return false;
}

static
bool fix2ops(NP np, BOPS *bop)
{
	bool r;
	ushort flgs = bop->opflags | is_real(np->left, np->right);

	canswap = bop->opflags & ASSOC;
	name_to_str(np, bop->op);

#if FLOAT
	if (flgs&REAL)
		r = fix_sub(np, flgs, tblf2);
	else
#endif
		r = fix_sub(np, flgs, tbl2);

	side_cc(np);		/* this is about condition code Z */
	return r;
}

static
bool fix_index(NP np, BOPS *bop)
{
	bool r;

	name_to_str(np, bop->op);
	r = fix_sub(np, bop->opflags, tblindex);
	side_cc(np);
	return r;
}

static
bool fix_asn(NP np, BOPS *bop)
{
	bool r;

	canswap = 0;
	name_to_str(np, bop->op);
	r = fix_sub(np, bop->opflags, tblasop);
	side_cc(np);
	return r;
}

/* N.B. DO NOT rely on the parameter casts because
   they are not produced for variable argument lists. */
global
long onearg(NP np)
{
	/* prototyping: ignore push of void */
	if (np->size eq 0 ) return 0;

#if COLDFIRE
	/* If arithmatic has casted to long but is really short */
	if (    np->size eq DOT_L
	    and !np->eflgs.f.typed
	    and  np->eflgs.f.cfl
	   )
	{
		NP ep = copyone(np);		/* must make new node because of the new size */
		ep->left = np->left;
		ep->right = np->right;
		np->left = ep;
		np->right = nil;
		np->type = nil;
		np->tt = EV_LEFT;
		np->size = DOT_W;

	}
#endif

	/* hack small ICON */
	if (np->size eq DOT_B and np->token eq ICON)
	{
		if (G.ai_int32)
		{
			if (np->eflgs.f.typed)
				np->size = DOT_W;
			else
				np->size = DOT_L;		/* configurable int size */
		}
		else
			np->size = DOT_W;		/* NOT SIZE_..; this code is h/w dependent */
									/* the DOT_.. map the C sizes to hardware sizes */
	}

	/* hack push of #OREG,#ONAME */
	if (   (   np->token eq OREG
		    or np->token eq ONAME
		   )
		and is_immed(np))
	{
		np->eflgs.f.imm = 0;
		addcode(np, "\tpea \t\tA" C(onearg imm) "\n");
		return DOT_L;
	}

	if (    np->ty eq ET_A
#if LL
	    or is_ll(np)
#endif
	   )
		return strpush(np, 0, false);

#if FLOAT
	if (np->ty eq ET_R)
	{
		if (G.use_FPU)
		{
			if ( isfreg(np) )
			{
				addcode (np, "\tpshS\t\tA" C(onearg freg) "\n");
				return np->size;
/*	must handle ARGCNV for h/w fp */
			}

			if (   (	(np->token eq RCON or np->token eq FCON)
					and is_immed(np)
				   )
				or (isdreg(np) and !isfreg(np))	/* d reg vars */
			   )
			{
				/* 04'17 HR: v5.6 */
				if (np->r1 eq -1)
				{
					np->r1 = ralloc(FREG, np);
					addcode(np, "\tldxS\tR1\tA\n\tpshS\t\tR1" C(onearg r1 dreg or fcon) "\n");
					rfree(np->r1);
				othw
message("F r1 in use %d", np->r1);
					np->r2 = ralloc(FREG, np);
					addcode(np, "\tldxS\tR2\tA\n\tpshS\t\tR2" C(onearg r2 dreg or fcon) "\n");
					rfree(np->r2);
				}
				return np->size;
			}

			return strpush(np, 0, true);
		}

		if (double_size(np))
			return strpush(np, 0, false);

		addcode(np, "\tpsh.l\t\tA" C(onearg sgl s/w) "\n");
		return DOT_L;
	}
#endif

	if (is_CC(np))		/* Pushing of CC */
	{
		/* Only arrive here for unprototyped or ... arguments and booleans (type _Bool) */
		extern Cstr tstnm[];
		/* branch token is given for false, so must reverse it for set cc */
		name_to_str(np, tstnm[reverse(np->brt)]);
		np->r1 = DREG;
#if FLOAT
		if (np->ty eq ET_FC or np->ty eq ET_XC)
	#if COLDFIRE
			if (G.Coldfire)
			{
				name_to_str(np, tstnm[np->brt]);
				addcode(np, "\tclx \tR1\n\tfbN\t\t\Lf\n\tldx \tR1\t#1\nLf:" C(onearg CF cc) "\n");
			}
			else
	#endif
				addcode(np, "\tfsN \tR1\n\tanxS\tR1\t#1" C(onearg fcc) "\n");
		else
#endif
			addcode(np, "\tsN \tR1\n\tanxS\tR1\t#1" C(onearg cc) "\n");
			addcode(np, "\tpsh \t\tR1\n");
		return DOT_W;
	}

	if (np->size eq DOT_B)
	{
		NP ep = copyone(np);		/* must make new node because of the new size in np */

		ep->left = np->left;
		ep->right = np->right;
		np->left = ep;
		np->right = nil;
		np->type = nil;
		np->tt = EV_LEFT;
		np->size = DOT_W;
		/* 04'17 HR: v5.6 */

		if (np->r1 eq -1)
		{
			np->r1 = ralloc(DREG, np);
			if (np->ty eq ET_U)
				addcode(np, "\twmvz.b\tR1\tA\n\tpsh.w\t\tR1" C(onearg r1 uchar) "\n");
			else
				addcode(np, "\twmvs.b\tR1\tA\n\tpsh.w\t\tR1" C(onearg r1 char) "\n");
			rfree(np->r1);
		othw
message("D r1(%d) in use: use r2(%d)", np->r1, np->r2);
			np->r2 = ralloc(DREG, np);
			if (np->ty eq ET_U)
				addcode(np, "\twmvz.b\tR2\tA\n\tpsh.w\t\tR2" C(onearg r2 uchar) "\n");
			else
				addcode(np, "\twmvs.b\tR2\tA\n\tpsh.w\t\tR2" C(onearg r2 char) "\n");
			rfree(np->r2);
		}

		return DOT_W;
	othw
		addcode(np, "\tpshS\t\tA" C(onearg) "\n");
		return (short)np->size;
	}
}

static
long arg_sizes(NP args)	/* was argmod(); onearg() now called in the right places */
{
	long size = 0;

	if (args->token eq ARGP)
	{
		size += args->size;
		args = args->right;
	}

	if (args->token eq PULL)
		args = args->right;

	while (args)					/* iterative */
	{
		args->tt = args->right
				 ? EV_RL
				 : EV_LEFT;			/* this is for out_expr() */
		size += args->left->size;
		args = args->right;
	}

	return size;
}

static
short free_argregs(NP np, RMASK *m)
{
	short sub = 0;

	*m = 0;
	if (np->token eq ARGP)
		np = np->right;

	if (np->token eq PULL)
	{
		np = np->left;

		if (np->token eq FUNF)		/* v5.1 if unfolded callee expression */
			np = np->right;			/* skip unfold */

		while (np)
		{
			*m |= RM(np->rno);
			rfree(np->rno);
			sub += np->size;
			np = np->left;
		}
	}

	inhibit = 0;
	return sub;
}

static
NREG rbin(NREG last, NREG first, ALREG max)
{
	NREG n;
	n.x = 0;

	n.a = first.a > last.a ? first.a : last.a + (first.a ? 1 : 0);
	if (n.a > max.a)
		n.a = max.a;

	n.d = first.d > last.d ? first.d : last.d + (first.d ? 1 : 0);
	if (n.d > max.d)
		n.d = max.d;

#if FLOAT
	n.f = first.f > last.f ? first.f : last.f + (first.f ? 1 : 0);
	if (n.f > max.f)
		n.f = max.f;
#endif
	return n;
}

static
NREG bin(NREG l, NREG r, ALREG mx)		/* 3'91 v1.2 bin replaced by bin&rbin */
{
	return      (r.d > l.d)
			 or (r.a > l.a)
#if FLOAT
			 or (r.f > l.f)
#endif
	       ? rbin(l, r, mx)
	       : rbin(r, l, mx);
}

static
NREG merge(NREG need, NREG have)
{
	NREG n;
	n.x = 0;
	n.a = (need.a > have.a ? need.a : have.a);
	n.d = (need.d > have.d ? need.d : have.d);
#if FLOAT
	n.f = (need.f > have.f ? need.f : have.f);
#endif
	return n;
}

static
void pusher(NP *cpp)
{
	NP cp = *cpp,
	   tp = copyone(cp);

	tp->left = cp;
	*cpp = tp;
	tp->token = PUSHER;
	name_to_str(tp, "Pusher");
	tp->tt = EV_LEFT;
}

static
NREG need_r(short d, short f, short a)
{
	NREG r;
	r.x = 0;
	r.d = d;
#if FLOAT
	r.f = f;
#endif
	r.a = a;
	return r;
}

static
NREG need_left(NP np)
{
	NREG r = need_r(0, 0, 0),
		 l = np->left->needs;
	if (yareg(np))
		r.a = l.a+1;
#if FLOAT
	elif (yfreg(np))
		r.f = l.f+1;
#endif
	else
		r.d = l.d+1;
	return r;
}

static
NREG need_1(NP np)
{
	NREG r = need_r(0, 0, 0);
	if (yareg(np))
		r.a = 1;
#if FLOAT
	elif (yfreg(np))
		r.f = 1;
#endif
	else
		r.d = 1;
	return r;
}

#if FLOAT
#define NEEDALL need_r(max.d, max.f, max.a)
#else
#define NEEDALL need_r(max.d, 0,     max.a)
#endif

global
bool aggregate(NP np)
{
	if (np->ty eq ET_A) return true;
#if FLOAT
	if (is_sw_dbl(np))  return true;
#endif
#if LL
	if (is_ll(np))		return true;
#endif
	return false;
}

/* dynamic passing of MAXD, MAXA & MAXF
   for arguments in registers (steal that from Pure C)	*/
global
void eval_order(NP np, ALREG max)
{
	NREG l, r;

	switch (np->tt)
	{
	case E_BIN:
		eval_order(np->right, max);
		r = np->right->needs;
	case E_UNARY:
		eval_order(np->left, max);
		l = np->left->needs;
		break;
	default:	/* leaf */
		np->tt = EV_NONE;
		if (np->token eq PULLARG)
			np->needs = need_1(np);
		else
			np->needs = need_r(0, 0, 0);
		return;		/* l & r not used */
	}

	if (np->tt eq E_UNARY)
	{
		switch (np->token)
		{
		case DEREF:
		case TAKE:
			np->needs = merge(l, need_r(0, 0, 1));	/* see the story told below */
			break;
		case CALL:
			np->needs = NEEDALL;
			break;
		case PULLARG:
			np->needs = merge(l, need_left(np));
			break;
		case EXPCNV:
		case IMPCNV:
		case ARGCNV:
		case POSTINCR:
		case POSTDECR:
		case NOT:
			np->needs = merge(l, need_r(1, 0, 0));
			break;
		case SELECTOR:
			if (np->fld.width)
				np->needs = merge(l, need_r(1, 0, 0));
			else
				np->needs = l;
			break;
		default:
			np->needs = l;
		}
		np->tt = EV_LEFT;

		return;		/* r not used */
	}

/* at this point, have binary node */

	switch (np->token)
	{
	case AND:
	case OR:
	case X_THEN:
	case X_ELSE:
		/* always left-right, no extra regs */
		np->tt = EV_LRSEP;
		if (aggregate(np))
			np->needs = merge(need_r(0, 0, 1), merge(l, r));
		else
			np->needs = merge(need_r(1, 0, 0), merge(l, r));
		return;
	case ARG:
		np->tt = EV_LRSEP;
		np->needs = merge(l, r);
		return;
	case ARGP:
	case PULL:					/* Put args in regs (pull them back from the stack) */
		np->tt = EV_RL;
		np->needs = merge(r, l);
		return;
	case COMMA:
	case FUNF:
		np->tt = EV_LRSEP;
		np->needs = merge(l, r);
		return;
	case CALL:
		np->needs = NEEDALL;	/* parameters & name xpr are completely apart */
	 	np->tt = EV_RLSEP;      /*	!!!!	 first the args, then the name xpr. */
		return;					/* when the args are on the stack all regs are free */
	case BINEOR:
	case SHL:
	case SHR:
	case ASSIGN SHL:
	case ASSIGN SHR:
	case ASSIGN DIV:
		np->needs = merge(bin(l, r, max), need_r(2, 0, 0));
		break;
	case ROL:
	case ROR:
#if COLDFIRE
		if (G.Coldfire)
			error("Not yet Coldfire rotate");
/*			np->needs = merge(bin(l, r, max), need_r(3, 0, 0));	*/ /* PM: needs 1 reg extra */
		else
#endif
			np->needs = merge(bin(l, r, max), need_r(2, 0, 0));
		break;
#if WITH_F
	case FIELDAS:		/* 02'17 HR v5.6 */
#endif
	case ASS:
		np->needs = merge(rbin(l, r, max), need_r(1, 0, 0));
	break;
	default:
		if (is_ass_op(np->token))
			np->needs = merge(rbin(l, r, max), need_r(1, 0, 0));
		else
			np->needs = merge( bin(l, r, max), need_r(1, 0, 0));
	}

	if (is_assignment(np->token)
	   )
		np->tt = EV_RL;	/* NO PUSHER's on L */
	else
		np->tt = (   r.a > l.a
		          or r.d > l.d
#if FLOAT
		          or r.f > l.f
#endif
		          )
					? EV_RL
					: EV_LR; 		/* worst first */
/*	NOTE: It seems that l & r contain no of EXTRA regs for dregs,
		Now aregs & dregs are handled excactly the same,
		it seems that l & r contain the TOTAL no aregs needed.
		Must analyse the DEREF & TAKE action to solve this.
		But now I am tired and go to bed.

P.S.	The changes themselves were made because I wanted to experiment
		with dynamic handling of the border between locals and temps,
		but also because there was a fundamental programming error
		involved in the use of AREG.

		For insiders:
		You cannot mingle digit positions (powers) with natural numbers.
		AREG was the (compiler internal) number of the first areg.
		This happened to be 8 which worked in 'l/AREG' where the divide was
		used for shift.
		Which worked because it coincided with the meaning.
		So when I added FREG to the set of registers, for convenience
		between AREG and DREG, AREG became 16.
		Now... it took me sOme time to find out what went disastrously wrong.
		Dividing by 8  is the same as left shifting 3.
		Dividing by 16 is definitely not the same as left shifting 6.

		Parameterizing is nice because it stops you worrying,
		but it flabbergasts you when its used wrongly.
*/

	if (np->tt eq EV_LR)
	{
		if (   r.d >= max.d
			or r.a >  max.a			/* see story told above */
#if FLOAT
			or r.f >= max.f
#endif
		   )
			pusher(&np->left);
	othw
		if (   l.d >= max.d
			or l.a >  max.a
#if FLOAT
			or l.f >= max.f
#endif
		   )
			pusher(&np->right);
	}
}

static
bool optadd(NP np, short flags, short sign)
{
	NP lp = np->left, rp = np->right;
	short ltok = lp->token;

	if (rp->token ne ICON or !is_immed(rp))
		return false;

	if (is_immed(lp))
	{
		if (   ltok eq OREG
		    or ltok eq ONAME
		    or ltok eq O_ABS			/* 09'19 HR: v6 O_ABS as well */
		   )
		{
			linherit(np);
			rp->val.i  = sign * rp->val.i; 
			np->val.i += rp->val.i;
			if ((flags & IMMA_OK) eq 0)
				imm_oreg(np);
			return true;
		}
	othw					/* ptradd with icon  eg: *(p+6) */
		if (ltok eq REGVAR and isareg(lp) )
		{
			linherit(np);
			np->token = OREG;
			np->eflgs.f.imm = 1;
			np->val.i = sign * rp->val.i;
			if ((flags & IMMA_OK) eq 0)
				imm_oreg(np);
			return true;
		}
	}
	return false;
}

static
bool needmask(NP np)
{
	NP rp = np->right;		/* 11'10 HR: must check rp for ICON */
	long mask;

	if (np->fld.width + np->fld.offset > np->size*8)
		return false;

	if (rp->token ne ICON)
		return true;

	mask = ones(np->fld.width);
	rp->val.i &= mask;					/* 11'10 HR repair */

	if (np->fld.width > 1 or rp->val.i eq 0)		/* 11'10 HR optimization */
		return true;

	return false;
}

global
void to_inl_v(NP np)
{
	NP lp = np->left;
	lp->token = ICON;
	lp->size = DOT_W;
	lp->eflgs.f.imm = 1;
}

static
bool is_address(NP np)		/* Not good enough yet (without AHCC now behaves like Pure C) *//* Not good enough yet (without AHCC now behaves like Pure C) */
{
	NP lp;
	if (!is_immed(np))
		return false;
	lp = np->left;
	if (!lp)
		return false;

	if (    np->token eq ONAME and np->ty eq ET_P
	    and lp->token eq ONAME and lp->ty eq ET_P
	   )
		return true;

	return false;
}

#if OFFS
/* 07'19 HR: v6 repair Pure C style offsetof */
static
bool icon_plus_icon(NP np)
{
		NP lp = np->left,
		   rp = np->right;

		if (lp->token eq ICON and rp->token eq ICON)
		{
			np->token = ICON;
			np->val.i = lp->val.i + rp->val.i;
			to_cp(np);
			to_immed(np);
			return true;
		}
	return false;	
}
#endif


static
bool b_sube(NP np, RMASK r_inhib, short flags)
{
	NP lp = np->left, rp = np->right;
	short fop = is_real(lp, rp);
	long size = np->size;

	inhibit = r_inhib;
	reserve |= r_inhib;

	/* float assign operations already unfolded. */
	if (is_ass_op(np->token))
		switch (np->token-(ASSIGN 0))
		{
		/* these get unfolded now */
		case TIMES:
			return fix_sub(np, bop_mul.opflags, tblamul);
		case DIV:
			return fix_sub(np, bop_div.opflags,
			                  np->ty eq ET_U
			               or np->ty eq ET_P ? tbluadiv : tbladiv);
		case MOD:
			return fix_sub(np, bop_mod.opflags,
			                  np->ty eq ET_U
			               or np->ty eq ET_P ? tbluamod : tblamod);
		case BINAND:
			return fix_asn(np, &bop_and);
		case BINOR:
			return fix_asn(np, &bop_or);
		case BINEOR:
			return fix_asn(np, &bop_eor);
		case PLUS:
		case INDEX:
			return fix_asn(np, &bop_add);
		case MINUS:
			return fix_asn(np, &bop_sub);
		case SHL:
			return fix_asn(np, &bop_asl);
		case SHR:
			return fix_asn(np, &bop_asr);
		default:
			CE_X("Weird as_eval %s ", np->name);
			return false;
		}

	switch (np->token)
	{
	case CALL:			/* binary: at least 1 arg */
#if FOR_A
		if (lp->token eq STMT)
			addcode(np, "\tbra \t\t<L1\n<L2:\t\t" C(u_sube primary stmt) "\n");
		elif (lp->aflgs.f.lproc)
		{
			addcode(np, "\tjsl \t\t<A" C(b_sube local call) "\n");
			if (aggregate(np))
				np->token = OREG;
			else
				ret_df_reg(np);
			return true;
		}
#endif

		lp->misc = arg_sizes(rp);	/* misc for #K */
		
	/*	aggreg return:
		does not return AREG anymore, but a tempvar in local name space
		who's off and size are set in the CALL node by untype()
	*/
	/* free argregs & adjust K & communicate argregs to the optimizer */
	/* put misc (K) and reserve (L) in name expression node (lp),
	   clashed with struct pusher loop value */

		lp->misc -= free_argregs(rp, &lp->reserve);

		if (aggregate(np))
			np->token = OREG;
		else
			ret_df_reg(np);

		if (lp->xflgs.f.sysc)		/* 01'12 HR */
			sys_call(np);
		else
			/* K = stack adjust, ^L = reglist for args in regs (for optimizer) */
			if (lp->xflgs.f.cdec)
				if (lp->xflgs.f.inl_v)
				{
					to_inl_v(np);
					addcode(np, "\tinlv \t\t<A,<K" C(b_sube cdecl inlv) "\n");
				}
				else
					addcode(np, "\tjsr \t\t<A,<K" C(b_sube cdecl call) "\n");
			else
				if (lp->xflgs.f.inl_v)
				{
					to_inl_v(np);
					addcode(np, "\tinlv \t\t<A,<K<^L" C(b_sube argreg inlv) "\n");
				}
				else
					addcode(np, "\tjsr \t\t<A,<K<^L" C(b_sube argreg call) "\n");
		return true;
	case COMMA:
		rinherit(np);
		return true;
	case FUNF:
	case PULL:			/* pull argregs */
		return true;
	case ARGP:
	case ARG:		/* COMMA in arglists */
					/* This is a change from the original compiler
					   onearg() is now performed in a logical position */
		onearg(lp);	/*  As a further benefit register allocation is now as one expects */
		return true;
	case AND:
	case OR:			/* AND & OR same since branch_tree */
		if (np->Tl)		/* true label only in continuous branch trees */
			addcode(np, "Lt:\t\t" C(b_sube and_or_true) "\n");
		if (np->Fl)
	/* branch_tree: if there's a false label, must use it here */
		{
			if (np->lbl)	/* If the use .lbl for K_STATICS is wrong */
				warnn(np, "CW: debug: and/or has label %d", np->lbl);
			np->lbl = new_lbl();
			free1(nil, rp);
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldx \tA\t#1\n\tbra \t\tL1\nLf:\n\tclx \tA" C(b_sube and_or_false) "\nL1:\n" );
			np->ty = ET_S;			/* 11'09 HR adjust */
		}
		return true;

	case X_THEN:			/* branch_tree: a little simplified */
		rinherit(np);
		return true;

	case X_ELSE:		/* branch_tree: usage of Lt & Lf (out_let()) */
	{
		bool lm, rm, ag = aggregate(np);

		free1(nil, rp);
		np->Tl = new_lbl();
		retreg(np, ralloc(ag ? AREG : DREG, np));

		lm = np->token ne lp->token or np->rno ne lp->rno;
		rm = np->token ne rp->token or np->rno ne rp->rno;

		if (ag)
		{
			if (lm)
				addcode_betw(np, "\tlax \tA\t<A" C(x_else 1a) "\n");
			if (rm)
				addcode     (np, "\tlax \tA\t>A" C(x_else 2a) "\n");
		othw
			if (lm)
#if COLDFIRE && FLOAT
				if (G.Coldfire and lp->ty eq ET_R and lp->token eq ONAME)
				{
					tempr(np, AREG);
					addcode_betw(np, "\tlmx \tR1\t<A\n\tldxS\tA\tR1." C(x_else 1f) "\n");
				}
				else
#endif
					addcode_betw(np, "\tldxS\tA\t<A" C(x_else 1) "\n");
			if (rm)
#if COLDFIRE && FLOAT
				if (G.Coldfire and rp->ty eq ET_R and rp->token eq ONAME)
				{
					tempr(np, AREG);
					addcode(np, "\tlmx \tR1\t>A\n\tldxS\tA\tR1." C(x_else 2f) "\n");
				}
				else
#endif
					addcode(np, "\tldxS\tA\t>A" C(x_else 2) "\n");
		}

		addcode_betw(np, "\tbra \t\tLt\nLf:" C(x_else false) "\n");
		addcode     (np, "Lt:" C(x_else true) "\n");
		return true;
	}
	case LESS:
	case GREATER:
	case LTEQ:
	case GTEQ:
	case EQUALS:
	case NOTEQ:
		/* The whole problem of comparing with zero
			is congenital to C which has neither a
			well defined boolean type nor
			well defined boolean operators cq operations,
		*/
		canswap = 0;

		if (rp->token eq ZERO)
		{				/* generalized compare with zero; there are manay ways to compare with 0 */
			if (!lp->brt and !lp->eflgs.f.cc)
			{
				if (isareg(lp))
					addcode(np, "\tcpx \t<A\t#0" C(cmp0 areg) "\n");
#if FLOAT
				elif (is_sw_dbl(lp))			/* We know s/w dbl  cannot reside in any register. */
					addcode(np, "\tpea \t\t<A\n\tjsr \t\t_dcmp0,#4\n" C(cmp0 dbl) "\n");		/* this is an opportunistic solution */
#endif
#if LL
				elif (is_ll(np))				/* We know longlong cannot reside in any register. */
					addcode(np, "\tpea \t\t<A\n\tjsr \t\t_llcmp0,#4\n" C(cmp0 ll) "\n");		/* this is an opportunistic solution */
#endif

#if 0
/* direct address is always non zero hence branch or fall through depending on brt */
/* Not good enough yet (without: AHCC now behaves like Pure C) */
				elif (is_address(lp) and np->brt eq B_NO)			/* 12'13 HR: v5 */
				{
					flags &= ~CC_OK;				/* dont test */
					addcode(np, "\tbra \t\tL1" C(cmp0 ptr) "\n");
					message("[2]address::0, brt=%s",ptok(np->brt));
				}
#endif
/* constant expression? either branch or fall through
 * a constant which is zero is false, hence branch or fall through depending on brt
 */
				elif (is_immed(lp) and  lp->token eq ICON)
				{
					if (   (lp->val.i eq 0 and np->brt eq B_EQ)
					    or (lp->val.i ne 0 and np->brt eq B_NE)
					   )
					{
						flags &= ~CC_OK;				/* dont test */
						addcode(np, "\tbra \t\tL1" C(cmp imm 1) "\n");
					}
					elif (   (lp->val.i eq 0 and np->brt eq B_NE)
					      or (lp->val.i ne 0 and np->brt eq B_EQ)
					     )
					{
						flags &= ~CC_OK;				/* dont test */
						addcode(np, "\tdiscard \t\t" C(cmp imm 2) "\n");
					}
				}
				/* IXC codes tst and lax can be subject to optimizing removal */
				elif (lp->ty eq ET_P)
				{
						if (is_immed(lp))				/* 12'13 HR: v5 */
						{
							tempr(np, AREG);
							un_immed(lp);
							addcode(np, "\tlaa \tR1\t<A\n\tcpx<S\tR1\t#0" C(cmp0 imm ptr) "\n");	/* 01'16 HR: v5.3 */
						}
						else
					/* This prevents removal of a tst before a memory location is downed to a register */
							addcode(np, "\ttsp<S\t\t<A" C(cmp0 ptr) "\n");
				othw
#if COLDFIRE			/* 12'11 HR */
					if ((G.Coldfire and lp->token eq ONAME) or lp->token eq OLNAME)
					{
						tempr(np, AREG);
						addcode(np, "\tlmx \tR1\t<A\n\ttst<S\t\tR1." C(cmp0 cf) "\n");
					}
					else
#endif
						addcode(np, "\ttst<S\t\t<A" C(cmp0) "\n");				/* 01'12 HR */
				}
			}
		}

		elif (fop)
#if COLDFIRE
			if (G.Coldfire)
				fix_sub(np, bop_fcp.opflags|fop, tblcf);
			else
#endif
				fix_sub(np, bop_fcp.opflags|fop, tblc);
		else
		{
#if COLDFIRE
			if (G.Coldfire)
				fix_sub(np, bop_cmp.opflags & ~IopM, tblc);
			else
#endif
				fix_sub(np, bop_cmp.opflags, tblc);
		}

		if (flags & CC_OK)
			addcode(np, "BL1" C(cc_ok) "\n");		/* branch */

		return true;
	case TIMES:
		if (!fop)
			if (size eq DOT_L and !(np->right->size eq DOT_W and  np->left->size eq DOT_W))
				return fix_sub(np, bop_mul.opflags, tbllmul);
			else
				return fix_sub(np, bop_mul.opflags, tblmul);
		else
			return fix2ops(np, &bop_mul);
	case SCALE:
		if (size eq DOT_L and !(np->right->size eq DOT_W and np->left->size eq DOT_W))
			return fix_sub(np, bop_mul.opflags, tbllscale);
		else
			/* special case int*int=long for scaling */
			return fix_sub(np, bop_mul.opflags, tblscale);
	case DIV:
		if (!fop)
			if (size eq DOT_L)
				return fix_sub(np, bop_div.opflags, tblldiv);
			else
				return fix_sub(np, bop_div.opflags,
			                      (   np->ty eq ET_U
			                       or np->ty eq ET_P ? tbludiv : tbldiv) );
		else
			return fix2ops(np, &bop_div);
	case MOD:
		if (!fop)
			if (size eq DOT_L)
				return fix_sub(np, bop_mod.opflags, tbllmod);	/* 04'10 HR */
			else
				return fix_sub(np, bop_mod.opflags,
			                      (   np->ty eq ET_U
			                       or np->ty eq ET_P ? tblumod : tblmod));
		else
			return fix2ops(np, &bop_mod);
	case BINAND:
		return fix2ops(np, &bop_and);
	case BINOR:
		return fix2ops(np, &bop_or);
	case BINEOR:
		return fix2ops(np, &bop_eor);
	case INDEX:
	{
		bool ret;
/* 07'19 HR: v6 repair Pure C style offsetof: icon_plus_icon */
#if OFFS
		if (icon_plus_icon(np))
			ret = true;
		else
#endif
		if (optadd(np, flags, 1))
			ret = true;
		else
			ret = fix_index(np, &bop_add);
		return ret;
	}
	case PLUS:
		if (optadd(np, flags, 1))
			return true;
		if (fop)
			return fix2ops(np, &bop_fadd);
		if (np->left->ty eq ET_P)
			return fix_index(np, &bop_add);
		return fix2ops(np, &bop_add);
	case MINUS:

		if (optadd(np, flags, -1))
			return true;
		if (fop)
			return fix2ops(np, &bop_fsub);
		if (    np->left ->ty eq ET_P
		    and np->right->ty ne ET_P)			/* right not pointer */
			return fix_index(np, &bop_sub);
		return fix2ops(np, &bop_sub);
	case SHL:
		return fix2ops(np, &bop_asl);
	case SHR:
		return fix2ops(np, &bop_asr);
	case ROL:
		return fix2ops(np, &bop_rol);
	case ROR:
		return fix2ops(np, &bop_ror);
	case ASS:
		if (specasn(np) or strasn(np, false))
			return true;
		return fix_sub(np, bop_assign.opflags, tblasn);
	case FIELDAS:		/* HR: still has to do bitfields in a long) */
		if (rp->token eq ICON)
		{
			linherit(np);		/* 02'17 HR: v5.6 */
#if COLDFIRE
			if (G.Coldfire)
			{
				retreg(np, ralloc(DREG, np));
				needmask(np);			/* for warning & masking */
				if (np->fld.width eq 1)
				{
					if (rp->val.i)
						addcode(np, "\tldxS\tA\t#^F\n"
						            "\tbset\tA\t<A" C(fieldas con 3) "\n");
					else
						addcode(np, "\tldxS\tA\t#^F\n"
						            "\tbclr\tA\t<A" C(fieldas con 4) "\n");
				othw
					if (rp->val.i)
						addcode(np, "\tldxS\tA\t<A\n"
						            "\tanx.l\tA\t#^M\n"
						            "\torx.l\tA\t#^C\n"
						            "\tstoS\tA\t<A" C(fieldas con 5) "\n");
					else
						addcode(np, "\tldxS\tA\t<A\n"
						            "\tanx.l\tA\t#^M\n"
						            "\tstoS\tA\t<A" C(fieldas con 6) "\n");
				}
			}
			else
#endif
			{
				if (needmask(np))		/* 11'10 HR needs needmask() */
					addcode(np, "\taniS\t\t#^M,<A" C(fieldas con 1) "\n");
				if (rp->val.i)
					addcode(np, "\toriS\t\t#^C,<A" C(fieldas con 2) "\n");
			}
		othw
			if (istdreg(rp))		/* if allready in reg */
				rinherit(np);
			else
			{
				retreg(np, ralloc(DREG,np));
				addcode(np, "\tldxS\tA\t>A" C(fieldas 0) "\n");		/* value */
			}

#if FLOAT
			if (G.i2_68020 && !G.Coldfire)
				addcode(np, "\tstb \tA\t(F:W)<A" C(fieldas 20) "\n");
			else
#endif
			{
				if (needmask(np))					/* mask off high bits */
					addcode(np, "\tanxH\tA\t#^W" C(fieldas 1) "\n");
				if (np->fld.shift)							/* shift into position */
				{
					tempr(np, DREG);
					addcode(np, "\tlfldH\tA\tR1,#^O" C(fieldas 2) "\n");
				}
#if COLDFIRE
				if (G.Coldfire)
				{
					if (np->r1 < 0)
						tempr(np, DREG);
					addcode(np, "\tldxS\tR1\t<A\n"
					            "\tanx.l\tR1\t#^M\n"		/* 04'10 HR: mask out old */
					            "\torx.l\tR1\tA\n"			/*         insert new   */
					            "\tstoS\tR1\t<A" C(fieldas cf 3) "\n");
				}
				else
#endif
					addcode(np, "\taniS\t\t#^M,<A\n"					/*  mask out old */
					            "\torsS\tA\t<A" C(fieldas 3) "\n");		/*  insert new   */
			}

			if ((flags & NOVAL_OK) eq 0)
				fldtoint(np);
		}
		return true;
	default:
		CE_X("Weird b_eval %s", np->name);
		return false;
	}
}

global
bool b_eval(NP np, short context, RMASK r_inhib)
{
	NP lp = np->left, rp = np->right;
	NP tp;
	short l_context = FORADR, r_context = FORADR;

	switch (np->token)
	{							/* special contexts */
	case AND:
	case OR:
		l_context = r_context = FORCC;
		break;
	case X_THEN:
		l_context = FORCC;
		break;
	case CALL:
		r_context = FORPUSH;
		r_inhib = 0;
		break;
	case ARG:				/*	COMMA in arglists */
		l_context = r_context = FORPUSH;
		if (np->rno < 0)
		{
			reserve &= ~r_inhib;
			r_inhib = 0;
		}
		else
			r_inhib |= regm1(np->rno);
		break;
	case ARGP:				/* struct return */
		l_context = FORPUSH;
		r_context = context;
		break;
	case COMMA:
	case FUNF:
	case PULL:				/* pull argregs */
		l_context = FORSIDE;
		r_context = context;
		break;
#if WITH_F
	case FIELDAS:			/* 2'17 HR: v5.6 */
#endif
	case ASS:
		r_context = FORIMA;
		break;
	case INDEX:
	case PLUS:
	case MINUS:
		tp = rp;
		while (	    is_conv(tp)
#if FLOAT
				and tp->ty ne ET_R
#endif
			  )
			tp = tp->left;
		if (tp->token eq ICON)
			l_context = FORIMA;
		break;
	}

	if (np->tt eq EV_LR)
	{
		if (eval(lp, l_context, r_inhib) eq false)
			return false;
		freetmps(lp);
		if (eval(rp, r_context, r_inhib) eq false)
			return false;
		freetmps(rp);
	}
	elif (np->tt eq EV_RL)
	{
		if (eval(rp, r_context, r_inhib) eq false)
			return false;
		freetmps(rp);
		if (eval(lp, l_context, r_inhib) eq false)
			return false;
		freetmps(lp);
	}
	elif (np->tt eq EV_LRSEP)
	{
		if (eval(lp, l_context, r_inhib) eq false)
			return false;
		freetmps(lp);
		free1(nil, lp);
		if (eval(rp, r_context, r_inhib) eq false)
			return false;
		freetmps(rp);
	}
	else				/* EV_RLSEP */
	{
		if (eval(rp, r_context, r_inhib) eq false)
			return false;
		freetmps(rp);
		free1(nil, rp);
		if (eval(lp, l_context, r_inhib) eq false)
			return false;
		freetmps(lp);
	}

	return b_sube(np, r_inhib, context_flags[context]);
}
