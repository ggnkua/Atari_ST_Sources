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
 *	gsub.c
 *
 *	Various code generation subroutines
 *	Includes generation of switches and
 *	conversion of type lists to simple type,size.
 */

#include <stdio.h>
#include <string.h>
#include "param.h"

#include "d2.h"
#include "e2.h"
#include "gen.h"
#include "g2.h"
#include "gsub.h"
#include "md.h"
#include "out.h"

#define debug_g G.yflags['g'-'a']

void br_sub(NP np, short rev, short lbl);		/* recursion */

#define USELOOP 4			/* aggreg move/assign: no of moves */

enum
{
	C_SIMPLE	= 12,	/* use simple if n <= this */
	C_RATIO		= 3		/* use table if (max-min)/n <= this */
};

static
void br_split(NP np, short rev, short lbl)
{
	short nlbl = lbl;

	if (rev eq 0 or rev eq 3)
	{
		nlbl = new_lbl();
		if (np->Tl)
			CE_N(np, "truelabel error");
		np->Tl = nlbl;			/* The true label */
	}
	br_sub(np->left,  rev<2 ? 1 : 0, nlbl);
	br_sub(np->right, rev&1, lbl);
}

/* (?:)
   left  is '?' (X_THEN) is bool xpr.
   right is ':' (X_ELSE); its left is true choice, its right is false choice */
static
void br_quest(NP np)
{
	short l = new_lbl();
	np->right->Fl = l;
	br_sub(np->left, 1, l);		/* must generate for branch if false (as for 'if') */
	branch_tree(np->right);
}

/*	Create branch tree (put operand & entry labels in existing tree).
	Determine final branch operation part.
	Also split up tree in complete boolean parts
	and the non boolean interludes.
	(makes a lot of coding elsewhere obsolete and produces efficient object code)
	Now usable for any expression (not only for, if, while etc).
	Note that AND & OR are allways evaluated left to right,
	so that putting both true and false entry label in their
	respective nodes gives no evaluation order problems. */

global
void branch_tree(NP np)	/* traverses non_boolean op's */
{
	short l, tok = np->token;

	if (is_compare(tok) or tok eq AND or tok eq OR or tok eq NOT)
	{
		l = new_lbl();
		br_sub(np,  1, l);
		if (np->Fl)
			CE_N(np, "falselabel error");
		np->Fl = l;				/* The false label */
	}
	elif (tok eq X_THEN)
		br_quest(np);
	else
		switch(np->tt)
		{
			case E_BIN:
				branch_tree(np->right);
			case E_UNARY:
				branch_tree(np->left);
		}
}

static
void br_sub(NP np, short rev, short lbl)	/* rev = 0: branch if true	*/
{												/*       1:    "      false	*/
	short i;									/* lbl = branch label!!!	*/
	NP lp = np->left, rp = np->right;

	if	 (np->token eq AND)
		br_split(np, rev, lbl);
	elif (np->token eq OR)
		br_split(np, 2+rev, lbl);
	elif (np->token eq NOT)
	{
		*np = *lp;				/* remove it, because it will be completely used up.
								   and will sit only in the way. */
		freeunit(lp);
		br_sub(np, rev ? 0 : 1, lbl);		/* reverse truth */
	}
	elif (is_compare(np->token))
	{
		br_sub(rp, rev, lbl);
		br_sub(lp, rev, lbl);

		i = OP_X(np->token);
		i += (lp->ty eq ET_U
		   or lp->ty eq ET_P ? B_YES : B_EQ) - B_EQ;
		if (rev)
			i = reverse(i);
		np->brt = i;
		np->lbl = lbl;
	}
	elif (np->token eq X_THEN)
		br_quest(np);
	elif (np->token eq COMMA)		/* 11'09 HR: forgotten; very rare, see also gen_branches */
	{
		branch_tree(lp);
		br_sub(rp, rev, lbl);
	}
	else
		switch(np->tt)
		{
		case E_BIN:
			branch_tree(rp);
		case E_UNARY:
			branch_tree(lp);
		}
}

static
void cmp_zero_g(NP np)
{
	NP rp, cp;
	short ty = CC_ty(np, nil);

	rp = allocnode(GENODE);
	rp->token = ZERO;
	rp->val.i = 0;
	name_to_str(rp, "0");

	cp = for_old_copyone(np);

	np->left = cp;
	np->right = rp;
	np->tt = E_BIN;
	np->token = NOTEQ;
	name_to_str(np, "g cmp 0");

	np->ty = ty;
}

static
void gen_branches(NP np, short lbl, short truth) /* generate branches */
{
	short tok = np->token;

	if (tok eq COMMA)
	{
		branch_tree(np->left);
		gen_branches(np->right, lbl, truth);
	othw
		if (!(is_compare(tok) or tok eq AND or tok eq OR or tok eq NOT))
			cmp_zero_g(np);
		br_sub(np, truth, lbl);
	}
}

global
void gen_boolean(NP np, short lbl, short truth)	/* generate boolean expression */
{
	if (np)
	{
		G.prtab->tmps = 0;
		form_types(np, FORCC, 0);
#if 0 /* FOR_A */
		if (G.lang eq 'a')
		{
			if (np->type->token ne T_BOOL)
				errorn(np, "needs boolean expression; -=%s=-", graphic[np->type->token]);
		}
		else
#endif
			mustty(np, AC_BOOL,30);

/* If a boolean expression is incomplete a compare to zero is inserted */
/* e.g.  'if (a) ...'  is completed to 'if (a != 0) ... */

		if (!G.nmerrors)
		{
			untype(np);					/* transform to GENODE tree */
			gen_branches(np, lbl, truth);
			genx(np, FORCC);
		}
	}
}

/* 11'09 HR: The half_sw only works correct for all ranges of values
             when the case values are treated as unsigned internally.
             Allow long switch and long case values */

/* simple if-else type switch
	dlbl may be -1 -> fall through
	does not free np
*/
static
void simple_sw(VP np, short size, short dlbl)
{
	new_gp(nil, OUT);
	addcode(gp, ";sstart\n");
	out_gp();
	while (np)
	{
		new_gp(nil, OUT);
		gp->size = size;
		gp->rno = DREG;
		out_cmp(np->vval);
		out_b(B_EQ, np->cs.lbl);
		out_gp();
		np = np->next;
	}
	new_gp(nil, OUT);
	addcode(gp, ";send\n");
	out_gp();
	if (dlbl >= 0)
		out_br(dlbl);
}

#undef min
#undef max

/* use table switch
	dlbl is not -1
	does not free np
*/

static
void table_sw(VP np, short size, short dlbl, ulong min, ulong max)
{
	new_gp(nil, OUT);
	gp->size = size;
	gp->rno = DREG;
	out_cmp(min);
	out_b(B_ULT, dlbl);
	out_gp();
	new_gp(nil, OUT);
	gp->size = size;
	gp->rno = DREG;
	out_cmp(max);
	out_b(B_UGT, dlbl);
	out_gp();
	new_gp(nil, OUT);
	gp->size = size;
	gp->rno = DREG;
#if COLDFIRE
	if (G.Coldfire and size < DOT_L)	/* 03'11 HR */
	{
		out_anx(DOT_L);		/* needs original gp->size */
		gp->size = DOT_L;
	}
	else
#endif
	if (size < DOT_W)					/* 03'11 HR */
	{
		out_anx(DOT_W);		/* needs original gp->size */
		gp->size = DOT_W;
	}

	if (min)
		out_sbx(min);

	out_tsw();
	out_gp();

	while (np)
	{
		while (min < np->vval)
		{
			out_tlbl(dlbl);
			min++;
		}
		out_tlbl(np->cs.lbl);
		min++;
		np = np->next;
	}
}

static
VP find_value(VP pt, ulong cut)
{
	VP this;

	while (pt->vval < cut)
		this = pt, pt = pt->next;
	return this;
}

static
bool find_gap(VP pt, ulong *tmin, ulong *tmax)
{
	while(pt->next)
	{
		if (pt->next->vval >= pt->vval + C_SIMPLE)
		{
			*tmin = pt->vval;
			*tmax = pt->next->vval;
			return true;
		}

		pt = pt->next;
	}

	return false;
}

/* cut switch in half (by value)
	dlbl is not -1
	will free np
 */

static
void half_sw(VP np, short size, short dlbl, ulong cut, ushort n)
{
	VP pt, last;
	ushort nlo, nhi;
	short l1;

	for (pt = np; pt->vval < cut; pt = pt->next )
		last = pt;
	/* we KNOW both pieces are non-nil ! */
	last->next = nil;
	last = pt;

	nlo = 0;
	nhi = 0;
	for (pt = np; pt; pt = pt->next )
		nlo++;
	nhi = n - nlo;

	if (nhi eq 1)
	{						/* switch hi and low */
		pt = np;
		np = last;
		last = pt;
		nlo = 1;
		nhi = n-1;
	}
	if (nlo eq 1)
	{						/* also nhi eq 1 */
		new_gp(nil, OUT);
		gp->size = size;
		gp->rno = DREG;
		out_cmp(np->vval);
		out_b(B_EQ, np->cs.lbl);
		out_gp();
		freeVn(np);
		gen_switch(last, size, dlbl);		/* half */
		return;
	}
	l1 = new_lbl();
	new_gp(nil, OUT);
	gp->size = size;
	gp->rno = DREG;
	out_cmp(cut);
	out_b(B_UGE, l1);
	out_gp();
	gen_switch(np, size, dlbl);			/* half 1 */
	def_lbl(l1);
	gen_switch(last, size, dlbl);		/* half 2 */
}

/* generate switch
	size: of switch expression
	np - list of nodes with value, label pairs (sorted)
	dlbl - default label or -1
 */

global
void gen_switch(VP np, short size, short odlbl)	/* new: size (for switch(long) */
{
	ushort n = 0;
	short dlbl;
	ulong min, max;
	VP pt;

	if (np)
	{
		/* if no default,  make one! */
		if (odlbl < 0)
			dlbl = new_lbl();
		else
			dlbl = odlbl;

/* values are already sorted. */
		pt = np;
		min = pt->vval;
		while (pt)
		{
			max = pt->vval;
			n++;
			pt = pt->next;
		}

		if (n <= C_SIMPLE)
			simple_sw(np, size, odlbl), freeVn(np);
		elif (n <= (max-min)/C_RATIO)		/* 02'11 HR: make calculation independent of seperate rests */
			half_sw(np, size, dlbl, max/2 + min/2, n);
		else
		{
			/* 03'11 HR: optimization: Find a gap > C_SIMPLE. If there, split. */
			ulong tmin, tmax;

			if (find_gap(np, &tmin, &tmax))
				half_sw(np, size, dlbl, tmin/2 + tmax/2, n);
			else
				table_sw(np, size, dlbl, min, max), freeVn(np);
		}

		if (odlbl < 0)
			def_lbl(dlbl);
	}
}

/* Generally used for all aggregates incl arrays and doubles */
static
bool is_tempa(NP np)
{
	return
		   (np->token eq OREG and is_temp(np->rno))
		or (isareg(np));
}

global
bool strasn(NP np, bool fmeaea)
/* fmeaea: force for fmove <ea>,<ea>  (that does not exist) */
{
	long count, size;
	short align;
	short lisa, risa, rissp;
	short useloop, ra, la, isntbyte;

	if (!fmeaea)
		if (    np->ty ne ET_A
#if FLOAT
		    and !is_sw_dbl(np)
#endif
#if LL
		    and !is_ll(np)
#endif
		   )
			return false;

	align = 0;
	isntbyte = 0;
	size = np->size;
	count = size;
	np->chunk_size = 1;
	np->ty = ET_A;			/* in case ET_R */

	/* If no type alignment (char) and right addr mode is OREG other than a6
	    allways use byte move because address is indeterminable.
	   If it is a local variable, d(a6), address is determinable by offset,
		because a6 is a copy of the stack pointer at a moment when
		the stack is even and a6 is allways and only used for addressing
		local variables.
		This all is necessary because ANSI let us do array assigns
		for local array initialisation.
		Remember that K&R originally did not allow that.
		Now you know why they did'nt.
		And why then not allow array assignment everywhere in C ?
		Well if in some future time that may be the case, this compiler
		will be prepared for it.
		But if you will allow arrays of different sizes and depths to be
		assigned you still will need some even more sophisticated ways.
	*/

	if (	np->aln
		or (   !np->aln
			and np->right->token eq OREG
			and np->right->rno eq FRAMEP/* -AREG */	/* should remove -AREG !!!! 12'13 done */
		   )
	   )
	{
		isntbyte = 1;
		la = np->left ->val.i & 1;
		ra = np->right->val.i & 1;

		align = la and ra;	/* both odd: 1 byte before; rest fast */

		if (la eq ra)		/* either both odd or both even */
		{
			count  = (size-align)>>2;	/* now chunk allways 4 */
			np->chunk_size = 4;
		}
	}
	useloop = count > USELOOP;

	lisa = is_tempa(np->left);
	risa = is_tempa(np->right);
	rissp = (np->right->token eq PUSHER);		/* now for pull */

/* 10'10 HR: moved to here (before tempr's and OREG) */
	if (     fmeaea
	    and !G.Coldfire
	    and !(np->left->token eq ONAME or np->right->token eq ONAME))
	{
		linherit(np);		/* !!! */
		addcode(np, "\tfasn>S\t\t>A,<A" C(fp_asn) "\n");
		return true;
	}

	np->token = OREG;
	np->val.i = 0;
	np->rno   = lisa ? np->left->rno : ralloc(AREG, nil);	/* R0 */

	if (risa)
		np->r1 = np->right->rno;
	elif (rissp)
		np->r1 = SP;
	else
		tempr(np, AREG);	/* R1 */

	if (useloop)
		tempr(np, DREG);	/* R2 */

	if (lisa eq 0 or np->left->val.i ne 0)
#if COLDFIRE
		if (G.Coldfire and useloop eq 0)
			addcode(np, "\tlmx \tR0\t<A" C(strasn 0f) "\n");
		else
#endif
			addcode(np, "\tlax \tR0\t<A" C(strasn 0) "\n");

	if (   (risa  eq 0 or np->right->val.i ne 0)
	    and rissp eq 0
	   )
		addcode(np, "\tlax \tR1\t>A" C(strasn 1) "\n");

	if (align)
	{
		addcode(np, "\tmov.b\t\tR1+,R0+" C(strasn 2) "\n");	/* 1 byte before */
		size -= 1;
	}

	if (useloop)
	{
		np->misc = count;					/* for #K */
		addcode(np, "\tldct\tR2\t#K\n"
		            "\tmovC\t\tR1+,R0+\n"
				    "\tbct \tR2\t*-2" C(strasn 3) "\n" );	/* L voor normale labels etc etc */
		size -= count*np->chunk_size;
	}
				/* Hoe intelligenter de mens hoe minder werk.
				   Hoe intelligenter het programma hoe meer werk. */

				/* intelligentere move */


	while ((isntbyte and size > 4) or (!isntbyte and size > 0) )
	{
		addcode(np, "\tmovC\t\tR1+,R0+" C(strasn 4) "\n");
		size -= np->chunk_size;
	}

	if (size)				/* restanten */
	{
		if (rissp)
		{
			switch(size)
			{
			case 4:
				addcode(np, "\tmov.l\t\tR1+,R0+" C(strasn 5) "\n");
				break;
			case 3:
				addcode(np, "\tmov \t\tR1+,R0+" C(strasn 6) "\n");
			case 1:			/* fall through */
				addcode(np, "\tmov.b\t\tR1+,R0+" C(strasn 7) "\n");
				break;
			case 2:
				addcode(np, "\tmov \t\tR1+,R0+" C(strasn 8) "\n");
			}

			if ( !ra and (size & 1))		/* keep stack even ??? */
				addcode(np, "\tadx \t*s\t#1" C(strasn 9) "\n");		/* NB pull */
		}
		else
			switch(size)
			{
			case 4:
				addcode(np, "\tmov.l\t\tR1.,R0." C(strasn 10) "\n");
				break;
			case 3:
				addcode(np, "\tmov \t\tR1.,R0." C(strasn 11) "\n");
			case 1:			/* fall through */
				addcode(np, "\tmov.b\t\tR1.,R0." C(strasn 12) "\n");
				break;
			case 2:
				addcode(np, "\tmov \t\tR1.,R0." C(strasn 13) "\n");
			}
	}

	return true;
}

global
void strret(NP np)	/* same as return s/w double */
{				/* use invisible param on 'argbase(local name space pointer)' ie 8(a6) ie *temp */
	NP bp  = copyone(np);	/* make binary node for '*temp = struct' */

	np->type = nil;
	bp->left = np->left;
	bp->right = np->right;
	np->right = bp;
	name_to_str(np, "strret");
	np->left = copyone(np);
	np->tt = E_BIN;
	np->left->tt = E_LEAF;
	np->left->rno = ralloc(AREG, nil);
	np->left->token = OREG;		/* nieuwe left node tbv strasn */
	np->left->val.i = 0;
	np->rno = AREG;
	np->val.i = 0;
	np->token = REGVAR;
	addcode(np, "\tldx.l\tR0\tG" C(strret) "\n");	/* G = argbase(local name space pointer) */
	if (!strasn(np, false))
		addcode(np, "\tmovS\t\t>A,<A" C(strret 1) "\n");
}

#if PSHL

static
void push(NP np, bool b)
{
	if (b)
		addcode(np, "\tpshS\t\t<A" C(push pusher) "\n");
	else
		addcode(np, "\tpshS\t\tA" C(push for_push) "\n");
}

static
void push_4_4(NP np, bool b)
{
	if (b)
		addcode(np, "\tpsh.l\t\t<J4" C(push_4_4 pusher) "\n");
	else
		addcode(np, "\tpsh.l\t\tJ4" C(push_4_4 for_push) "\n");
}
static
void push_4_0(NP np, bool b)
{
	if (b)
		addcode(np, "\tpsh.l\t\t<A" C(push_4_0 pusher) "\n");
	else
		addcode(np, "\tpsh.l\t\tA" C(push_4_0 for_push) "\n");
}

static
void push_2_0(NP np, bool b)
{

	if (b)
		addcode(np, "\tpsh.w\t\t<A" C(push_2_0 pusher) "\n");
	else
		addcode(np, "\tpsh.w\t\tA" C(push_2_0 for_push) "\n");
}

#endif

global
long strpush(NP np, short tolbl, bool fpeaea)
{										/* tolbl 0: FORPUSH; -1: PUSHER */
	long count, size, ret, offs;
	short useloop;

	size = np->size;
	count = size / DOT_L;

	if (size&1)
		size++;
	ret = size;

#if PSHL
	if (size <= 2*DOT_L)
	{
		switch (size)
		{
		case 2*DOT_L:
			push_4_4(np, tolbl);
			push_4_0(np, tolbl);
		break;
		case DOT_L+DOT_W:
			push_4_4(np, tolbl);
			push_2_0(np, tolbl);
		break;
		case DOT_L:
			push    (np, tolbl);
		break;
		case DOT_W:
			push    (np, tolbl);
		}
		return size;
	}
#else
	if (size <= DOT_L)
	{
		np->chunk_size = size;
		if (tolbl)
			addcode(np, "\tpshC\t\t<A" C(strpush pusher) "\n");
		else
			addcode(np, "\tpshC\t\tA" C(strpush for_push) "\n");

		return size;
	}
#endif

	np->chunk_size = DOT_L;
	offs = np->val.i;
#if FLOAT
	if (fpeaea)
	{
		/* must hold on to offset of first byte, for recognizing of registerizable variable */
		if (np->r1 eq -1)
			np->r1 = ralloc(AREG, nil);
	#if COLDFIRE								/* 09'10 HR */
		if (np->token eq ONAME)
		{
			tempr(np, AREG);
			addcode(np, "\tlmx \tR1\tA\n\tfpshS\t\tR1." C(fpeaea cf) "\n");
		}
		else
	#endif
		{
			/* must hold on to offset of first byte, for recognizing of registerizable variable */
/*			if (np->r1 eq -1)
				np->r1 = ralloc(AREG, nil);
*/			addcode(np, "\tfpshS\t\tA" C(fpeaea) "\n");
		}
	}
	else
#endif
	{
		short isa;

		np->ty = ET_A;
		np->val.i += size;		/* push is high to low, so point to end of source */
		useloop = count > USELOOP;

		if (useloop and np->r2 eq -1)
			np->r2 = ralloc(DREG, nil);

		/* set up 'from' address */

		if (tolbl)			/* push of intermediate structured result */
		{
			isa = is_tempa(np->left);

			if (isa and np->left->val.i eq 0)
			{
				np->r1 = np->left->rno;
				addcode(np, "\tlax \tR1\tR1.O" C(strpush pusher reg) "\n");
			othw
				tempr(np, AREG);
				addcode(np, "\tlax \tR1\t<A" C(strpush pusher) "\n");
			}
		othw
			isa = is_tempa(np);

			if (isa and !offs)
			{
				np->r1 = np->rno;
				addcode(np, "\tlax \tR1\tR1.O" C(strpush for_push reg) "\n");
			othw
				tempr(np, AREG);
				addcode(np, "\tlax \tR1\tA" C(strpush for_push) "\n");
			}
		}

		/* generate copy loop */
		if (useloop)
		{
			np->misc = count;				/* for #K */
			addcode(np, "\tldct\tR2\t#K\n"
			            "\tpshC\t\tR1-\n"
			            "\tbct \tR2\t*-2"
			            C(strpsh)
			            "\n");
			size -= count*np->chunk_size;
		}

		while (size > 2)
		{
			addcode(np, "\tpshC\t\tR1-\n");
			size -= np->chunk_size;
		}

		if (size eq 2)		/* size made even */
			addcode(np, "\tpsh \t\tR1-\n");
	}
	if (tolbl eq 0)
	{
		freetmps(np);
		free1(nil, np);
	}
	return ret;
}

/*
 * stuff to do field extract and field assign
 * Yes, this stuff can be optimized a lot more ... feel free
 *
 * Yes I felt free
 *
 * 	introduced '^' as warning character to avoid running out of
 *	steering ch's in out_let.
 *	I started with this on fields because we have all the stuff together here.
 */

global
void fldtoint(NP np)		/* also signed/unsigned fields */
{
	if (np->ty eq ET_U)
	{
		short how = np->fld.shift;

		if (how and np->fld.offset)		/* 11'10 HR for optimizer */
		{
			tempr(np, DREG);
			addcode(np, "\tanxH\tA\t#^K\n"
			            "\tflxH\tA\tR1,#^O" C(fldtoint 1) "\n");
		othw
			if (how)									/* shift to position */
			{
				tempr(np, DREG);
				addcode(np, "\tfldH\tA\tR1,#^O" C(fldtoint 2) "\n");
			}
			if (np->fld.offset)
				addcode(np, "\tanxH\tA\t#^W" C(fldtoint 3) "\n");
		}
	othw											/* sign extend */
		short howra = (np->size*8)-np->fld.width;

		if (np->fld.offset)
		{
			tempr(np, DREG);
			addcode(np, "\tlflxH\tA\tR1,#F\n");
		}
		if (howra)
		{
#if COLDFIRE
			if (G.Coldfire and np->size < DOT_L)
				addcode(np, "\texx.l\tA" C(fldtoint cf) "\n");
#endif
			if (np->r1 < 0)
				tempr(np, DREG);
			addcode(np, "\tafldH\tA\tR1,#^G" C(fldtoint 4) "\n");
		}
	}
}

global
bool specasn(NP np)
{
	NP lp = np->left, rp = np->right;

	if is_sreg(lp)				/* 12'11 HR */
	{
		rinherit(np);						/* preliminary, should also cast */
		if (rp->token ne REGVAR)
		{
			retreg(np, ralloc(DREG, np));
			np->eflgs.f.imm = 0;
			addcode(np, "\tldxS\tA\t>A\n");
		}

		switch(lp->token)
		{
			case K_SR:
				np->size = DOT_W;
				addcode(np, "\tstsr \t\tA" C (set sr) "\n");
			break;
			case K_CR:
				np->size = DOT_W;
				addcode(np, "\tstcr \t\tA" C (set ccr) "\n");
			break;
#if FLOAT
			case FPSR:
				np->size = DOT_L;
				addcode(np, "\tstfsr \t\tA" C (set fsr) "\n");
			break;
			case FPCR:
				np->size = DOT_L;
				addcode(np, "\tstfcr \t\tA" C (set fcr) "\n");
			break;
#endif
		}

		return true;
	}

	if (	(	(rp->token eq ICON)
#if FLOAT
			 or	(rp->token eq FCON and !G.use_FPU)
#endif
			)
		and is_immed(rp) )
	{
		rinherit(np);

		if (rp->val.i eq 0 )
		{
			bool isa = isareg(lp);
			addcode(np, isa ? "\tsbxS\t<A\t<A" C(specasn clr areg) "\n"
			 				: ( lp->token eq REGVAR
			 					  ? "\tclxS\t<A" C(specasn clr reg) "\n"
			 					  : "\tclsS\t\t<A" C(specasn clr mem) "\n") );
			return true;
		}
	}

#if FLOAT
	/* Non existing fmove <ea>,<ea> */
	if (	rp->ty eq ET_R
		and lp->ty eq ET_R
		and rp->token ne REGVAR
		and lp->token ne REGVAR
	   )
	{
		strasn(np, true);	/* tell its aggreg */
		return true;
	}
#endif
	imm_oreg(rp);		/* 06'11 HR */
#if COLDFIRE
	if (G.Coldfire)
		imm_oname(rp);		/* 06'11 HR */
#endif
	return false;
}

static
NP g_temp_var(short ty, short sz, short aln)
{
	NP t1 = gx_node();

	t1->token = OREG;
	t1->tt = EV_NONE;
	t1->rno = FRAMEP;
	t1->ty = ty;
	t1->size = sz;
	t1->aln = aln;
	G.prtab->tmps += sz;
	t1->val.i = -(G.scope->b_size + G.prtab->tmps);
	name_to_str(t1, "g_temp_var");
	return t1;
}

extern
BASTAB btbl[];

static
void ty_to_e(NP np)
{
	TP tp;

/* EXNODE en GENODE now same struct	*/
/* A lot of code in this function is for internal integrity checking */

	tp = np->type;
	switch (np->tt)
	{
	case E_BIN:
		ty_to_e(np->right);
	case E_UNARY:
		ty_to_e(np->left);
	}

/* 		takeup type data		*/
	{
		short aln;
		long size;

		aln = tp->aln;
		size = tp->size;

		switch(tp->token)
		{
		case K_STRUCT:
		case K_UNION:
		case ROW:
			np->ty  = ET_A;		/* 3'91 v1.2 */
			np->size= size;
			np->aln = aln;
		break;
		case T_PROC:
			c_mods(np, tp);							/* 09'19 HR: v6 correct pascal behaviour */
			np->xflgs.f.sysc = tp->xflgs.f.sysc;	/* __syscall__ */
			np->fld.offset = tp->fld.offset;		/* __syscall__ params */
			np->lbl = tp->lbl;
		break;
#if FOR_A
		case L_PROC:
			np->aflgs.f.lproc = 1;
		break;
#endif
		case T_BOOL:		/* bool is different in different versions of the language */
			/* moreover: there are different types of bool (ET_B & ET_?C) we need the one from tp */
			np->ty  = tp->ty;
			np->size= tp->size;
			np->aln = tp->aln;
		break;
		default:
			if (is_basic(tp) or tp->token eq REFTO)
			{
				BASTAB *pb = &btbl[tp->token - FIRST_BAS];

				np->ty  = pb->type;
				np->size= pb->size;
				np->aln = pb->align;
			}
		break;
		}

		if (tp->ty eq ET_A and tp->tflgs.f.pu)		/* 10'13 v5 HR */
			np->eflgs.f.pu = 1;
	}
}

static
void e_to_g(NP np)
{
	switch (np->tt)
	{
	case E_BIN:
		e_to_g(np->right);
	case E_UNARY:
		e_to_g(np->left);
	}

	if (is_ct(np))
		freeTn(np->type);
	np->type = nil;
	not_nct(np);

#if NODESTATS
	G.ncnt[np->nt]--;
	G.ncnt[GENODE]++;
#endif
	np->nt = GENODE;					/* transition */
	np->r1 = -1;
	np->r2 = -1;

/*	s/w dbl & struct return.
	Exactly the point between typing and generating for insertion of
	the push of the address of the temp that receives
	the aggregate to be returned.
*/

	if (	np->token eq CALL
	    and aggregate(np)		/* !! verhuizen naar function_type() */
	   )
	{
		short n;
		NP pp = gx_node();		/* insert first parameter: &temp	*/
		to_type((TP)pp, REFTO);	/* ty,sz & aln from REFTO */
		pp->token = TAKE;		/*  but its really & */
		name_to_str(pp, "struct return");
		pp->tt = E_UNARY;
		pp->left = g_temp_var(np->ty, np->size, np->aln);
		if (np->right eq nil)	/* no args */
		{
			NP argp = gx_node();	/* insert unary ARG (imparative for eval context) */
			argp->token = ARG;
			argp->tt = E_UNARY;
			argp->left = pp;
			argp->val.i = 1;
			np->right = argp;
		othw
			n = np->right->token eq ARG ? np->right->val.i : 1;		/* COMMA in arglista */
			comma_r(np->right, pp);
			np->right->tt = E_BIN;
			np->right->token = ARGP;
			np->right->val.i = n + 1;
		}

		np->right->size = pp->size;
		np->tt = E_BIN;
		np->val.i = pp->left->val.i;
		np->rno = pp->left->rno;
	}
}

global
void untype(NP np)
{
	ty_to_e(np);
	e_to_g(np);
}

/* Code is stored in nodes as merely static strings which from now
   on we shall call 'templates'. Because of the static nature of these
   templates, we only need to store their pointer.
 */

global
void addcode(NP np, Cstr s)
{
#if C_DEBUG
	if (np->nt ne GENODE)
	{
		CE_("adding code to no gnode");
		return;
	}
#endif

	if (!np->type)
	{
		np->type = (void *)s;			/* first template, put as string */
		np->nflgs.f.n_ct = 1;
#if NODESTATS
		G.strcode++;
#endif
	othw
		VP cp;
		if (np->nflgs.f.n_ct)			/* node data is astring a string */
		{
			Cstr ns = (Cstr)np->type;		/* change to list of nodes */
			cp = allocVn(TPNODE);
			np->type = (TP)cp;
			not_nct(np);
			cp->tnr = 1;
			cp->ts[0] = ns;
#if NODESTATS
			G.strcode--;
			G.npcode++;
#endif
		othw
			cp = (VP)(np->type);
			while (cp->codep)	/* find last of list */
				cp = cp->codep;
		}

		if (cp->tnr >= TPLMAX)
		{
			cp->codep = allocVn(TPNODE);
			cp->nflgs.f.n_ct = 0;
			cp = cp->codep;
			cp->tnr = 0;
		}
		cp->ts[cp->tnr++] = s;
#if NODESTATS
		G.npcode++;
#endif
	}
}

/* add code for between L and R */
global
void addcode_betw(NP np, Cstr s)
{
	VP cp;

#if C_DEBUG
	if (np->nt ne GENODE)
	{
		CE_("adding code to no gnode");
		return;
	}
#endif

	if (np->betw eq nil)
		np->betw = allocVn(TPNODE);

	cp = np->betw;

	if (cp->tnr < TPLMAX)
		cp->ts[cp->tnr++] = s;
#if C_DEBUG
	else
		error("CE: too much code between");
#endif
}
