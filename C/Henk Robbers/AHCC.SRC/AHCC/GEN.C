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
 *	gen.c
 *
 *	Generate code.
 *	Includes main routine and code generation for unary nodes
 *	and leafs.
 *
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "param.h"

#include "d2.h"
#include "gen.h"
#include "g2.h"
#include "gsub.h"
#include "md.h"
#include "out.h"

RMASK reserve,		/* reserved regs */
      inhibit,		/* inhibit certain regs. pe already loaded argregs. */
      argused;		/* but not until the reg is in use */

#define debugG  G.xflags['g'-'a']
#define debugy  G.yflags['y'-'a']

#define AS_FORSIDE NOVAL_OK|IMMA_OK
#define holdcon(np) ((np)->misc = (np)->val.i)

global
short context_flags[] =
{
	0,				/* NOCONTEXT */
	AS_FORSIDE,		/* FORSIDE */
	IMMA_OK,		/* FORPUSH */
	CC_OK,			/* FORCC */
	IMMA_OK,		/* FORIMA */
	0,				/* FORADR */
	0,				/* FORLVAL */
	IMMA_OK,		/* FORINIT 	 12'08 HR usage tracking */
	0,				/* IND0 */
	0,				/* INF0 */
	0,				/* INA0 */
	0,				/* SWITCH */
	0,				/* RETSTRU */
	AS_FORSIDE,		/* FORLINIT local init */
	AS_FORSIDE,		/* FORLAINIT */
	AS_FORSIDE,		/* FORSTRINIT */
	0,				/* FORVALUE primary block */
	0,				/* FORTRUTH #if xpr */
	0,				/* FORASM */
	0				/* FORSEE */
};

#if C_DEBUG
global
void retreg(NP np, short r)
{
	np->token = REGVAR;
	np->rno = r;
}
#endif

static
void force_ralloc(short rno)
{
	reserve |= RM(rno);
	G.prtab->wregmsk |= reserve&~WORKX;
}

global
void ret_df_reg(NP np)
{
	if (np->rno eq -1)	/* This should come from internally generated call's */
	{
#if FLOAT
		if (is_hw_fp(np->ty))	/* fpu Proc ret Real <*/
		{
			force_ralloc(FREG);
			retreg(np, FREG);
		}
		else
#endif
		{
			force_ralloc(DREG);
			retreg(np, DREG);
		}
	othw
		force_ralloc(np->rno);		/* normally typed call's */
		retreg(np, np->rno);
	}
}

static
bool anycode(NP np)
{
	if (np->type)				return true;
	if (np->tt eq EV_NONE)		return false;
	if (np->tt eq EV_LEFT)		return anycode(np->left);
	if (np->tt eq EV_RIGHT)		return anycode(np->right);
	if (np->tt eq EV_LR or np->tt eq EV_RL)				/* 10'10 HR: ooooffff second np->tt omitted (=COBOL) */
								return anycode(np->left) or anycode(np->right);
	CE_("anycode: unknown type");
	return false;
}

global
short ralloc(short type, NP np)
{
	short starti, endi;
	short i;

	if (G.scope)
	{
		if (type eq AREG)
			starti = AREG,
			endi = max_A + AREG;
#if FLOAT
		elif (type eq FREG)
			starti = FREG,
			endi = max_F + FREG;
#endif
		elif (type eq DREG)
		{
			starti = DREG;
			endi = max_D + DREG;

#if FLOAT
			if ( np )				/* If np=0 force Dn */
				if (    G.use_FPU
				    and (   np->ty eq ET_R
				         or np->ty eq ET_XC
				         or np->ty eq ET_FC
				        )
				   )
					starti = FREG,
					endi = max_F + FREG;
#endif
		}

		for (i = starti; i<endi; i++)
		{
			RMASK x = RM(i);
			if (    (reserve & x) eq 0
			    and (inhibit & x) eq 0
			   )
			{
				reserve |= x;
				G.prtab->wregmsk |= reserve&~WORKX;
				return i;
			}
		}
	}
 	return 0;
}

#if 0
global
bool arg_reg(short rno)
{
	if ((inhibit & RM(rno)) ne 0)
		return true;
	else
		return false;
}
#endif

global
RMASK regm1(short rno)
{
	if (rno > A0)
		rno--;
#if FLOAT
	elif (rno > F0 and rno < A0)
		rno--;
	elif (rno > D0 and rno < F0)
		rno--;
#else
	elif (rno > D0 and rno < A0)
		rno--;
#endif
	else
		return 0;
	return RM(rno);
}

global
void freetmps(NP np)
{
	if (np->r1 ne -1)
		rfree(np->r1);
	if (np->r2 ne -1)
		rfree(np->r2);
}

global
bool is_temp(short rno)
{
	if (rno <= Dhigh)
		return rno < max_D + DREG;
#if FLOAT
	if (rno <= Fhigh)
		return rno < max_F + FREG;
#endif
	return rno < max_A + AREG;
}

static
void utemp(NP np)
{
	NP lp = np->left;

	if (    lp->token eq REGVAR
	    and is_temp(lp->rno)
	   )
		linherit(np);
	else
	{
		retreg(np, ralloc(DREG, np));
#if COLDFIRE										/* 11'11 HR */
		if (lp->token eq ONAME and is_hw_fp(lp->ty))
		{
			tempr(np, AREG);
			addcode(np, "\tlmx \tR1\t<A\n\tldx<S\tA\tR1." C(utemp) "\n");
		}
		else
#endif
			addcode(np, "\tldx<S\tA\t<A" C(utemp) "\n");
	}
}

global
void free1(NP np, NP cp)
{
	if (cp->token ne OREG and cp->token ne REGVAR)
		return;
	else
	{
		short cr = cp->rno;

		if (np)
			if (    cr eq np->rno
				and (np->token eq OREG or np->token eq REGVAR) )
				return;

		if (is_temp(cr))
			rfree(cr);
	}
}

global
short tempr(NP np, short type)
{
	short i = -1;			/* 04'17 v5.6 */

	i = ralloc(type, np);

	if (np->r1 eq -1)
		np->r1 = i;
	elif (np->r2 eq -1)		/* 04'17 v5.6 */
		np->r2 = i;
	else
		warn("CE: all r in use: r1=%d, r2=%d",np->r1,np->r2);	/* 04'17 HR: v5.6 */

	return i;
}

#if FLOAT
static
void do_return(NP np, short r)
{
	if (          np->token  ne REGVAR
		or (!G.use_FPU and np->rno ne r)
		or ( G.use_FPU and np->ty ne ET_R and np->rno ne r )
		or ( r eq DREG and is_hw_fp(np->ty) and np->rno ne FREG )
	   )
	{
		np->r1 = r;					/* 11'13 HR v5; to correct place */
		if (   np->token eq ICON
			and np->val.i  eq 0
			and is_immed(np)
		   )
			addcode(np, "\tclxS\tR1" C(ind0 icon) "\n");		/* clr a0 translated to suba.l a0,a0 in the ultimate output phase */
		else
		{
			if (r eq DREG and is_hw_fp(np->ty))
			{
				np->r1 = FREG;
#if COLDFIRE										/* 09'10 HR */
				if (np->token eq ONAME)
				{
					tempr(np, AREG);
					addcode(np, "\tlmx \tR2\tA\n\tldxS\tR1\tR2." C(ind0 cf freg) "\n");
				}
				else
#endif
					addcode(np, "\tldxS\tR1\tA" C(ind0 freg) "\n");
			}
			else
				addcode(np, "\tldxS\tR1\tA" C(ind0 reg) "\n");
		}
	}
}

#else

static
void do_return(NP np, short r)
{
	if (np->token ne REGVAR or np->rno ne r)
	{
		np->r1 = r;					/* 11'13 HR v5; to correct place */
		if (   np->token eq ICON
			and np->val.i  eq 0
			and is_immed(np)
		   )
			addcode(np, "\tclxS\tR1" C(ind0 zero) "\n");		/* clr a0 translated to suba.l a0,a0 in the ultimate output phase */
		else
			addcode(np, "\tldxS\tR1\tA" C(ind0) "\n");
	}
}
#endif

static
bool contextmon(NP np, short context)
{
	if (np eq nil) return false;
	switch (context)
	{
	case FORINIT:
#if FOR_A
	case FORSTRINIT:
#endif
	{
		bool any = anycode(np) ne 0, imm = np->eflgs.f.imm ne 0;
		if (!any and imm)
		{
			np->eflgs.f.imm = 0;		/* for out_let('A') ipo out_A() */
#if FOR_A
			if (context eq FORSTRINIT)
				addcode(np, "\t^YS\t\tP" C(out_str) "\n");
#endif
			addcode(np, "\t^YS\t\tA" C(cmon_init) "\n");

			next_gp(nil);
			return true;
		}
		error("Illegal initialisation");
		return false;
	}
	case SWITCH:
	case IND0:				/* return something */
		do_return(np, DREG);
		return true;
	case INA0:				/* argregs (Pure C compatible) */
		do_return(np, AREG);
		return true;
	case RETSTRU:					/* ook voor s/w double */
		freetmps(np);
		strret(np);
		return true;
#if FOR_A
	case FORLINIT:
		if (   np->left->cflgs.f.qc eq 0
			or  np->size > DOT_L
		   )
			break;
		if (!is_con(np->token))
			break;
		np->cflgs.f.qc = 1;		/* pass it on */
		return true;
#endif
	}
	return true;
}

#if FLOAT
/* possible for real float and integer CONS cause they */
/* have no address (to the outside world, that is) */

static
short save_Rcon(NP np)
{
	NP tp, zp = G.consave;
	VP dp;

	if (np->token ne RCON or (np->token eq RCON and np->val.dbl eq nil))
	{
		CE_N(np, "not RCON");
		return -1;
	}

	while (zp)
	{
		VP zdp = zp->val.dbl,
		   ndp = np->val.dbl;

		if (zp->token eq np->token and zdp->rval eq ndp->rval)
		{
			np->token   = ONAME;
			np->nflgs.f.nheap = 0;
			freeVn(np->val.dbl);
			np->val.dbl = nil;
			np->area_info = zp->area_info;

			return zp->lbl;
		}

		zp = zp->left;
	}

	dp = np->val.dbl;
	tp = copyone(np);		/* does not copy the RLNODE */
	np->token = ONAME;
	tp->nflgs.f.nheap = np->nflgs.f.nheap;
	np->nflgs.f.nheap = 0;
	tp->val.dbl = dp;
	np->val.dbl = nil;
	tp->lbl = new_lbl();
	tp->nflgs.f.brk_l = 1;
	tp->eflgs.f.imm = 0;		/* for out_let 'A' */
#if NODESTATS
		G.ncnt[tp->nt]--;
		G.ncnt[GENODE]++;
#endif
	tp->nt = GENODE;
	addcode(tp, "L1:\n\t^YS\t\tA\n");
	putn_fifo(&G.consave, &G.conlast, tp);
	set_class(np, CON_class);
	np->area_info.disp = std_areas->ar[np->area_info.class].size;
	std_areas->ar[np->area_info.class].size += tp->size;
	tp->area_info = np->area_info;

	return tp->lbl;
}
#endif

#if LL || COLDFIRE
#include "save_con.h"
#endif

static
void take_address(NP np)
{
	NP nlp;

/* too much information for 1 node ?  Use 2! */
	nlp = copyone(np);
	nlp->right = nil;
	nlp->left = np->left;
	nlp->tt = EV_LEFT;
	np->type = nil;			/* code remains in nlp */
	np->left = nlp;
	retreg(np, ralloc(AREG, nil));
	addcode(np, "\tlax  \tA\t<A" C(take_address) "\n");		/* last dynamic addcode() replaced */
}

global
void imm_oname(NP np)
{
	if (np->token eq ONAME and np->eflgs.f.imm)
	{
		np->eflgs.f.imm = 0;
		take_address(np);
	}
}

/* fixes nodes with no code or aX is temp that are #d(aX) */
global
void imm_oreg(NP np)
{
	if (np->token eq OREG and np->eflgs.f.imm)
	{
		np->eflgs.f.imm = 0;
		if (np->val.i eq 0)
		{									/* #(a0) -> a0 */
			np->token = REGVAR;
			return;
		}
		if (is_temp(np->rno))
		{
			holdcon(np);
			addcode(np, "\tadxS\tA\t#K" C(imm_oreg 1) "\n");
			np->token = REGVAR;
			return;
		}

		take_address(np);
	}
}

/* branch_tree:  same order as language tokens (NOTEQ, EQUALS, ....) */
global
Cstr tstnm[] =
{
	"",			/* dummy 0 */
	"eq",		/* == */	/* signed */
	"ne",		/* != */
	"lt",		/* < */
	"ge",		/* >= */
	"le",		/* <= */
	"gt",		/* > */

	"eq",		/* == */	/* unsigned */
	"ne",		/* != */
	"cs",		/* < */
	"cc",		/* >= */
	"ls",		/* <= */
	"hi",		/* > */
};

global
bool cast_CC(NP np)
{
	NP lp = np->left;

	if (is_CC(lp))		/* cast CC to other */
	{
		short cpty = lp->brt;
		TP btb = basic_type(T_BOOL, 72);

		if (cpty)
		{
	/* this replaces the code for 'Q' out_let() */
	/* branch token is given for false, so must reverse it for set cc */
			name_to_str(lp, tstnm[reverse(cpty)]);
			retreg(lp, ralloc(DREG, nil));

	/* hw fp is not casted, so we dont know which side is
		at least float. We cant use the 'D' out_let here. ("Dsn \tA\n") */
#if COLDFIRE
			if (G.Coldfire)
			{
				if (lp->ty ne ET_CC)
				{
					name_to_str(lp, tstnm[cpty]);
					addcode(lp, "\tclx \tA\n\tfbN\t\tLf\n\tldx \tA\t#1" C(cast fcc) "\nLf:\n");
				}
				else
					addcode(lp, "\tsN  \tA\n\tanx.l\tA\t#1" C(cast_cc l) "\n");
			}
			else
#endif
			{
				if (lp->ty ne ET_CC)
					addcode(lp, "\tfsN \tA\n");
				else
					addcode(lp, "\tsN  \tA\n");

				addcode(lp, "\tanxS\tA\t#1" C(cast_cc) "\n");
			}

			side_cc(lp);
		}

		lp->ty   = btb->ty;		/* change ty & size */
		lp->size = btb->size;
		linherit(np);
		return true;			/* 01'12 HR ooooffff */
	}
#if FOR_A			/* Otherwise it bites existing use of enum boolean { false, true } bool; */
	/* true boolean: cast to boolean variable.
	   This is my own invention: 'bool b := someothertype;'
					efectively translates to 'bool b:=someothertype ne 0;'
	   This is both usefull and well defined */

	elif (G.lang eq 'a' and np->ty eq ET_B and lp->ty ne ET_B)
	{
		retreg(np, ralloc(DREG, lp));
	    if (lp->ty eq ET_P)	/* cant use tst; tst is subject to optimization */
		/* This prevents removal of a tst before a memory location is downed to a register */
			addcode(np, "\ttsp<S\t\t<A\n\tsne \tA\n\tanxS\tA\t#1" C(cg_10a) "\n");
		else
			addcode(np, "\ttst<S\t\t<A\n\tsne \tA\n\tanxS\tA\t#1" C(cg_10b) "\n");
		side_cc(np);

		return true;			/* finished */
	}
#endif
	return false;			/* not finished */
}

#if FLOAT
static
bool castable(NP np)
{
	NP lp = np->left;
	if (   lp->ty > ET_R
	    or lp->ty < ET_CC
	    or np->ty > ET_R
	    or np->ty < ET_CC
	   )
		return false;
	return true;
}
#else
static
bool castable(NP np)
{
	NP lp = np->left;
	if (   lp->ty > ET_P
	    or lp->ty < ET_CC
	    or np->ty > ET_P
	    or np->ty < ET_CC
	   )
		return false;
	return true;
}
#endif

static
short cast_gen(NP np)
{
	NP lp = np->left;
	long npsz, lpsz;
	short npty, lpty;

	if (cast_CC(np))
	{
#if FLOAT
		if (np->ty eq ET_R)			/* 11'15 v5.3 */
		{
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldx<S\tA\t<A" C(cast_xc) "\n");
		}
#endif
		return 1;
	}

	if (!castable(np))			/* 01'12 HR: allow all kinds of spurious casts */
		return 0;

	npsz = np->size;
	lpsz = lp->size;
	npty = np->ty;
	lpty = lp->ty;

	if (npsz eq 0) 	/* prototyping; cast to void: ignore value */
		return 0;

#if FLOAT
	if (    ((lpty >= ET_B) and (lpty <= ET_P))
		and ((npty >= ET_B) and (npty <= ET_P))
	   )
	{
#endif
		/* the old stuff; changed nothing. */
		if (npsz > lpsz)			/* widening */
		{
			if (lpty eq ET_U or lpty eq ET_P)
			{
				retreg (np, ralloc(DREG, nil));

				if (npsz eq DOT_W and lpsz eq DOT_B)
					addcode(np, "\twmvz<S\tA\t<A" C(cg_1) "\n");
				else
					addcode(np, "\tmvz<S\tA\t<A" C(cg_1a) "\n");

				return 2;
			}

			if (istdreg(lp))
				linherit(np);
			else
				retreg (np, ralloc(DREG, nil));

			if (npsz eq DOT_W and lpsz eq DOT_B)
				addcode(np, "\twmvs<S\tA\t<A" C(cg_2) "\n");
			else
				addcode(np, "\tmvs<S\tA\t<A" C(cg_2a) "\n");

			return 3;
		}

		if (npsz < lpsz)			/* narrowing */
			if (   lp->token eq ONAME
				or lp->token eq OREG)
			{
				if (is_immed(lp))
				{
					retreg (np, ralloc(DREG, nil));
					addcode(np, "\tldx<S\tA\t<A" C(cg_5) "\n");
					return 4;
				othw
					linherit(np);
					np->val.i = lp->val.i + (lpsz - npsz);
					return 5;
				}
			}
			elif (    lp->token eq REGVAR
				  and npsz eq DOT_B
				  and isareg(lp)
				  )
			{
				retreg (np, ralloc(DREG, nil));
				addcode(np, "\tldx<S\tA\t<A" C(cg_6) "\n");
				return 6;
			}
		/* 05'12 HR: cast ptr to long or vice versa */
		if (npty ne lpty and (npty eq ET_P or lpty eq ET_P) and npsz eq DOT_L)
		{
			linherit(np);
			if (np->ty eq ET_P)
				np->ty = lp->ty;			/* 05'12 HR: inherit and 1 more thing ! */
			return 7;
		}

#if FLOAT
	othw
		/* casting involving floating point */

		if (npty eq lpty and npsz eq lpsz)
			return 0;

		if (npty eq ET_R and lpty eq ET_R)		/* both floating point */
		{
			if (!isfreg(lp))		/* 06'11 HR */
			{
				retreg(np, ralloc(FREG, nil));
#if COLDFIRE
				if (lp->token eq ONAME or lp->token eq OLNAME)
				{
					tempr(np, AREG);
					addcode(np, "\tlmx  \tR1\t<A\n\tldx<S\tA\tR1." C(cg_7f) "\n");
				}
				else
#endif
					addcode(np, "\tldx<S\tA\t<A" C(cg_7) "\n");
				return 8;
			}
		}
		elif (npty eq ET_R or lpty eq ET_R)			/* 01'12 HR: must check this */
		{
			if (lpty eq ET_R) 		 /* cast floating point to integral */
			{
			/* little pieces of hacks needed here */

				retreg(np, ralloc(DREG, nil));
				if (!isfreg(lp))
				{
					np->r1 = ralloc(FREG, nil);
#if COLDFIRE											/* 02'12 HR */
					if ((G.Coldfire and lp->token eq ONAME) or lp->token eq OLNAME)
					{
						tempr(np, AREG);
						addcode(np, "\tlmx  \tR2\t<A\n\tldx<S\tR1\tR2.\n\tintrz.d\tR1\tR1" C(cg_11f) "\n");
					}
					else
#endif
						addcode(np, "\tldx<S\tR1\t<A\n\tintrz.x\tR1\tR1" C(cg_9a) "\n");


					switch (npsz)
					{
						case DOT_B:
							addcode(np, "\tsto.w\tR1\tA" C(cg_9c) "\n");
						break;
						case DOT_W:
							addcode(np, "\tsto.l\tR1\tA" C(cg_9d) "\n");
						break;
						case DOT_L:
							if (npty eq ET_U)
							{
#if COLDFIRE	 										/* 02'12 HR */
								if (G.Coldfire)
								{
									addcode(np, "\tldx.l\tA\t^E\n");
									addcode(np, "\tadj.l\tR1\tA\n");
								}
								else
#endif
									addcode(np, "\tadj.l\tR1\t^E\n");

								addcode(np, "\tsto.l\tR1\tA\n");
								addcode(np, "\tadj.l\tA\t^E\n");
							}
							else
								addcode(np, "\tsto.l\tR1\tA" C(cg_9e) "\n");
						break;
					}
				othw
					addcode(np, "\tintrz.x\t<A\t<A" C(cg_9b) "\n");		/* intrz: K&R 2nd ed */
					switch (npsz)
					{
						case DOT_B:
							addcode(np, "\tsto.w\t<A\tA" C(cg_9f) "\n");
						break;
						case DOT_W:
							addcode(np, "\tsto.l\t<A\tA" C(cg_9g) "\n");
						break;
						case DOT_L:
							if (npty eq ET_U)
							{
#if COLDFIRE	 	 									/* 02'12 HR */
								if (G.Coldfire)
								{
									addcode(np, "\tldx.l\tA\t#^E\n");
									addcode(np, "\tadj.l\t<A\tA\n");
								}
								else
#endif
									addcode(np, "\tadj.l\t<A\t^E\n");

								addcode(np, "\tsto.l\t<A\tA\n");
								addcode(np, "\tadj.l\tA\t^E\n");
							}
							else
								addcode(np, "\tsto.l\t<A\tA" C(cg_9h) "\n");
						break;
					}
				}
				return 9;
			}
			elif (!isfreg(lp) or npty eq ET_R)	/* cast integral to floating point */
			{
				retreg(np, ralloc(FREG, nil));
#if COLDFIRE
				if ((G.Coldfire and lp->token eq ONAME) or lp->token eq OLNAME)
				{
					tempr(np, AREG);
					addcode(np, "\tlmx  \tR1\t<A\n\tldx<S\tA\tR1." C(cg_10f) "\n");
				}
				else
#endif
					addcode(np, "\tldx<S\tA\t<A" C(cg_10) "\n");

				return 10;
			}
		}
	}
#endif

	return false;
}

static
void pull_arg(NP np)
{
	force_ralloc(np->rno);
	if (np->size eq DOT_B)
		np->size = DOT_W;
	addcode(np, "\tplaS\tR0" C(pl_a) "\n");
}

#if FLOAT
#if 0
static
struct
{
	short tok;
	char n[8];
} rmonops[]=
{
	{FABS,	"abs"	},
	{ACOS,	"acos"	},
	{ASIN,	"asin"	},
	{ATAN,	"atan"	},
	{ATANH,	"atanh"	},
	{COS,	"cos"	},
	{COSH,	"cosh"	},
	{ETOX,	"etox"	},
	{ETOXM1,"etoxm1"},
	{GETEXP,"gexp"	},
	{GETMAN,"gman"	},
	{INT,	"int"	},
	{INTRZ,	"intrz"	},
	{LOGN,	"logn"	},
	{LOGNP1,"lognp1"},
	{LOG10,	"log10"	},
	{LOG2,	"log2"	},
	{NEG,	"neg"	},
	{SIN,	"sin"	},
	{SINH,	"sinh"	},
	{SQRT,	"sqrt"	},
	{TAN,	"tan"	},
	{TANH,	"tanh"	},
	{TENTOX,"tentox"},
	{TWOTOX,"twotox"},
	{-1, ""}
};

static
Cstr get_monop(short tok)
{
	short i = 0;
	while (rmonops[i].tok >= 0)
		if (rmonops[i].tok eq tok)
			return rmonops[i].n;
		else
			i++;
	return "";
}
#else
static
Cstr get_monop(Cstr s)
{
	static
char sn[12];
	char *tn = sn;
	while (*s eq '_') s++;
	if (*s eq 'F' or *s eq 'f') s++;
	while (*s ne '_') *tn++ = tolower(*s++);
	*tn = 0;
	return sn;
}
#endif
#endif

global
void sys_call(NP np)		/* __syscall__  operator */
{
	NP lp = np->left;
	bool push = lp->cflgs.f.cdec;

	if ((short)lp->lbl >= 0)	/* fld.offset = trap #, lbl = opcode */
	{
		if (push)
		{
			lp->misc += DOT_W;
			addcode(np, "\tpsh \t\t#<T\n");
		}
		else
			addcode(np, "\tldx \tRd0\t#<T\n");
	}

	if (lp->fld.offset eq 2)			/* AES/VDI special case */
		addcode(np, "\tldx.l\tRd1\tRa0" C(syscall aes vdi) "\n");

/* very special: trap 1, 13 & 14 do not save A2
	AND A2 is NOT a work register.
	ralloc and force_ralloc make sure that non-work usage appears
	in the reglist for movem.
*/
	force_ralloc(A2);
	addcode(np, "\ttrap\t\t#<F,<K" C(syscall trap) "\n");

	if (np->ty eq ET_P)
		addcode(np, "\tldx.l\tRa0\tRd0" C(syscall return ptr) "\n");
}
#if COLDFIRE
Cstr rmsg = "rotate not available for Coldfire yet";
#endif

static
bool u_sube(NP np, short context, RMASK r_inhib)
{
	NP lp = np->left;
	short flags = context_flags[context];

	inhibit = r_inhib;

#if FLOAT
	if (np->cflgs.f.rlop)	/* real monadic operators if FPU=1 */
	{
		Cstr fmop = get_monop(np->name);

#if COLDFIRE
		if (G.Coldfire and !np->cflgs.f.cfop)
			error("%s is not a Coldfire FP operation", fmop);
#endif
		if (    lp->token eq REGVAR
		    and is_temp(lp->rno)
		    and !ISD(lp->rno)
	/*  All fpu instruction must have a fp reg as destination.
		so if the dest is a <dn> it is treated as an <ea>.
	*/
		   )
		{
			linherit(np);
			addcode(np, "\t");
			addcode(np, fmop);
			addcode(np, "S\tA" C(u_sube rmonop 1) "\n");
		othw
			retreg(np, ralloc(DREG, np));
#if COLDFIRE
			if (G.Coldfire and lp->token eq ONAME)
			{
				tempr(np, AREG);
				addcode(np, "\tlmx  \tR1\t<A\n\t");		/* 06'11 HR: lax --> lmx */
				addcode(np, fmop);
				addcode(np, "<S\tA\tR1." C(u_sube rmonop 1f) "\n");
			}
			else
#endif
			{
				addcode(np, "\t");
				addcode(np, fmop);
				addcode(np, "<S\tA\t<A" C(u_sube rmonop 2) "\n");
			}
		}
		side_cc(np);
		return true;
	}								/* > */
#endif

	switch (np->token)
	{
	case SELECT:
		if (np->fld.width)
		{
			lp->val.i += np->val.i;	/* major HACK, hope it works */
			retreg(np, ralloc(DREG, np));

#if FLOAT
			if (G.i2_68020 && !G.Coldfire)
				addcode(np, "\tldbD\tA\t(F:W)<A" C(fldget 20) "\n");
			else
#endif
			{
#if COLDFIRE
				if (G.Coldfire and np->ty eq ET_U and np->size < DOT_L)
				{
					addcode(np, "\tmvz.w\tA\t<A" C(fldget cf 2) "\n");		/* get word */
					fldtoint(np);
				}
				else
#endif
				{
					addcode(np, "\tldxS\tA\t<A" C(fldget 1) "\n");		/* get word */
					fldtoint(np);
				}
			}
			side_cc(np);		/* 11'10 HR */
		othw
			short offs = np->val.i;
			linherit(np);
			np->val.i += offs;
		}
		return true;
	case DEREF:
		if (is_immed(lp))
		{
			linherit(np);
			np->eflgs.f.imm = 0;
			if (np->token eq ICON)		/* 04'09:  *(char *)0xffff5201 = ... */
				np->token = O_ABS;
		}
		elif (isareg(lp))
		{
			np->token = OREG;		/* indir */
			np->val.i = 0;
			np->rno = lp->rno;
		othw							/* NEED A temp */
			np->token = OREG;		/* indir */
			np->val.i = 0;
			if (lp->token eq OREG and is_temp(lp->rno))
				np->rno = lp->rno;
			else
				np->rno = ralloc(AREG, nil);

			addcode(np, "\tldx.l\tR0\t<A" C(u_sube deref) "\n");
		}
		return true;
	case TAKE:
		if (is_immed(lp))
			warnn(lp, "'%s' ignored", graphic[ADDRESS]);
		elif (lp->token eq REGVAR)
			errorn(lp, "ref regvar");
		linherit(np);
		np->eflgs.f.imm = 1;
		if ((flags & IMMA_OK) eq 0)
			imm_oreg(np);
		return true;
	case BINNOT:
		utemp(np);
		addcode(np, "\tnoxS\tA" C(u_sube binnot) "\n");
#if COLDFIRE
		if (G.Coldfire)
#endif
			side_cc(np);
		return true;
	case BSWP:				/* 03'09 byte swap */
		utemp(np);
		if (np->size eq SIZE_L)
			addcode(np, "\trorx \tA\t#8\n\tswx \tA\n\trorx \tA\t#8"  C(u_sube bswp l) "\n");
		else
			addcode(np, "\trorx \tA\t#8"  C(u_sube bswp s) "\n");
		side_cc(np);
		return true;
	case SETSR:
		addcode(np, "\tstsr \t\t<A" C(u_sube setsr) "\n");
		side_cc(np);
		return true;
	case HALT:				/* 03'09 stop .... get & set SR */
		addcode(np, "\tstop \t\t<A" C(u_sube stop) "\n");
		side_cc(np);
		return true;
	case GETSR:
		addcode(np, "\tldsr \t\t<A" C(u_sube getsr) "\n");
		side_cc(np);
		return true;
	case GETSETSR:
		retreg(np, ralloc(DREG, np));
		addcode(np, "\tldsr \t\tA\n\tstsr \t\t<A" C(u_sube getsetsr) "\n");
		side_cc(np);
		return true;
	case DELAY:				/* 05.13 v4.15 */
		utemp(np);
		addcode(np, "\tldxS\tA\t<A\n\tsbxS\tA\t#1\tbpl \t\t*-2" C(u_sube delay) "\n");
		return true;
	case UPLUS:
		linherit(np);
		return true;
	case NEGATE:
		utemp(np);
		addcode(np, "\tngxS\tA" C(u_sube negate) "\n");
		side_cc(np);
		return true;
	case EXPCNV:
	case IMPCNV:
	case ARGCNV:
		if (!cast_gen(np))
			linherit(np);
		return true;
	case PUSHER:	/* must not be on left of assign or asn-op */
		if ((lp->token ne OREG and lp->token ne REGVAR) or
			is_temp(lp->rno) eq 0)
		{
			linherit(np);
			return true;
		}

		if (aggregate(lp))
			strpush(np, -1, false);
		else
			addcode(np, "\tpsh<S\t\t<A" C(u_sube pusher) "\n");
		return true;
	case CALL:
/*	call nodes that return aggregs or s/w doubles are made binary
	nodes by the compiler, so they wont arrive here anymore.
*/
		ret_df_reg(np);
		lp->misc = 0;		/* no arguments, no stack adjust */

#if FOR_A
		if (np->left->token eq STMT)
			addcode(np, "\tbra  \t\t<L1\n<L2:\t\t" C(u_sube primary stmt) "\n");
		elif (np->left->aflgs.f.lproc)
			addcode(np, "\tjsl  \t\t<A" C(u_sube local call) "\n");
		else
#endif
		if (lp->cflgs.f.sysc)		/* 01'12 HR */
			sys_call(np);
		else
		{
			if (np->left->cflgs.f.inl_v)	/* 12'13 v5 Pure C type inline */
			{
				to_inl_v(np);
				addcode(np, "\tinlv \t\t<A" C(u_sube inl_v) "\n");
			}
			else
				addcode(np, "\tjsr  \t\t<A" C(u_sube call) "\n");
		}
		return true;
	case INCR:
		holdcon(np);
		linherit(np);
		if (np->token eq REGVAR)
			addcode(np, "\tadxS\tA\t#K"  C(u_sube inc 1) "\n");
		else
#if COLDFIRE
			if (G.Coldfire)
			{
				tempr(np, DREG);
				addcode(np, "\tldxS\tR1\t#K\n\tadsS\tR1\t<A" C(u_sube inc 2f) "\n");
			}
			else
#endif
				addcode(np, "\tadiS\t\t#K,A" C(u_sube inc 2) "\n");
		side_cc(np);
		return true;
	case DECR:
		holdcon(np);
		linherit(np);
		if (np->token eq REGVAR)
			addcode(np, "\tsbxS\tA\t#K"  C(u_sube dec 1) "\n");
		else
#if COLDFIRE
			if (G.Coldfire)
			{
				tempr(np, DREG);
				addcode(np, "\tldxS\tR1\t#K\n\tsbsS\tR1\t<A" C(u_sube dec 2f) "\n");
			}
			else
#endif
				addcode(np, "\tsbiS\t\t#K,A" C(u_sube dec 2) "\n");
		side_cc(np);
		return true;
	case POSTINCR:
		if ((flags & NOVAL_OK) eq 0)
		{
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldxS\tA\t<A" C(u_sube postinc 1) "\n");
		}
		if (lp->token eq REGVAR)
			addcode(np, "\tadxS\t<A\t#O"  C(u_sube postinc 2) "\n");
		else
#if COLDFIRE
			if (G.Coldfire)
			{
				tempr(np, DREG);
				addcode(np, "\tldxS\tR1\t#O\n\tadsS\tR1\t<A" C(u_sube postinc 3f) "\n");
			}
			else
#endif
				addcode(np, "\tadiS\t\t#O,<A" C(u_sube postinc 3) "\n");
		return true;
	case POSTDECR:
		if ((flags & NOVAL_OK) eq 0)
		{
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldxS\tA\t<A" C(u_sube postdec 1) "\n");
		}
		if (lp->token eq REGVAR)
			addcode(np, "\tsbxS\t<A\t#O"  C(u_sube postdec 2) "\n");
		else
#if COLDFIRE
			if (G.Coldfire)
			{
				tempr(np, DREG);
				addcode(np, "\tldxS\tR1\t#O\n\tsbsS\tR1\t<A" C(u_sube postdec 3f) "\n");
			}
			else
#endif
				addcode(np, "\tsbiS\t\t#O,<A" C(u_sube postdec 3) "\n");
		return true;
	case NOT:
		CE_N(np, "Unresolved 'not'");
		return true;
	case ARG:				/* unary ARG only when argregs */
		onearg(lp);			/*		last arg in list */
	case COMMA:				/* local procs: unary comma: dont push */
	case ARGP:				/* push pointer for struct return */
		return true;
	case PULLARG:
		pull_arg(np);
		return true;
	default:
		CE_X("Weird u_eval %s ", np->name);
		return false;
	}
}

static
bool l_eval(NP np, short context, RMASK r_inhib)
{
	switch (np->token)
	{
	case ID:
		switch (np->sc)
		{
		case K_AUTO:
			np->rno = FRAMEP;
			np->token = OREG;
			break;
		case K_REG:
			np->token = REGVAR;
			break;
		default:					/* permanent extent */
			np->token = ONAME;
			break;
		}
		return true;
	case PULLARG:
		pull_arg(np);
		return true;
	case ICON:
		np->eflgs.f.imm = 1;
		return true;
#if FLOAT
	case FCON:
#if COLDFIRE
		if (	G.prtab->insc ne K_GLOBAL
			and G.prtab->insc ne K_STATIC		/* not static init */
		    and context ne FORINIT
		   )
			np->lbl = save_Fcon(np),
			np->sc = K_STATIC;
		else
#else
			np->eflgs.f.imm = 1;
		return true;
#endif
	case RCON:				/* sw dbl RCON imm's also delayed */
		if (	G.prtab->insc ne K_GLOBAL
			and G.prtab->insc ne K_STATIC		/* not static init */
		    and context ne FORINIT
		   )
			np->lbl = save_Rcon(np),
			np->sc = K_STATIC;
		else
			np->eflgs.f.imm = 1;
		return true;
#endif
#if LL
	case LCON:
		if (	G.prtab->insc ne K_GLOBAL
			and G.prtab->insc ne K_STATIC		/* not static init */
		    and context ne FORINIT
		   )
			np->lbl = save_Lcon(np),
			np->sc = K_STATIC;
		else
			np->eflgs.f.imm = 1;
		return true;
#endif
	case SCON:
		np->eflgs.f.imm = 1;
		np->token = ONAME;
		np->sc = K_STATIC;
		return true;
#if COLDFIRE
	case COLDCON:
		np->lbl = save_Icon(np);
		np->sc = K_STATIC;
		return true;
#endif
	case OREG:
		return true;
	case ZERO:
		return true;
	case K_NOP:
		np->token = ONAME;		/* safe, as long as we dont out A in the code template. */
		addcode(np, "\tnop" C(l_eval nop) "\n");
		return true;
	case K_SAVE:
		np->token = ONAME;
		addcode(np, "\tmms.l\t\t$0-$7/*0-*6" C(l_eval save) "\n");
		return true;
	case K_REST:
		np->token = ONAME;
		addcode(np, "\tmmx.l\t\t$0-$7/*0-*6" C(l_eval restore) "\n");
		return true;
	case K_SR:			/* 12'11 HR */
		if (!np->eflgs.f.l_ass)
		{
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldsr \t\tA" C (get sr) "\n");
		}
		return true;
	case K_CR:			/* 12'11 HR */
		if (!np->eflgs.f.l_ass)
		{
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldcr \t\tA" C (get ccr) "\n");
		}
		return true;
#if FLOAT
	case FPSR:			/* 12'11 HR */
		if (!np->eflgs.f.l_ass)
		{
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldfsr \t\tA" C (get fsr) "\n");
		}
		return true;
	case FPCR:			/* 12'11 HR */
		if (!np->eflgs.f.l_ass)
		{
			retreg(np, ralloc(DREG, np));
			addcode(np, "\tldfcr \t\tA" C (get fcr) "\n");
		}
		return true;
#endif
#if FOR_A
	case STMT:
		return true;
#endif
	}

	return false;
}

static
bool u_eval(NP np, short context, RMASK r_inhib)
{
	short subcontext = FORADR;

	if (np->cflgs.f.rlop)		/* fpu: monops */
		subcontext = FORCC;
	elif (np->token eq DEREF)
		subcontext = FORIMA;
	elif (np->token eq CALL)
		r_inhib = 0;
	elif (np->token eq ARG)		/* argregs: unary ARG is last arg */
	{
		if (np->rno < 0)
		{
			reserve &= ~r_inhib;
			r_inhib = 0;
		}
		else
			r_inhib |= regm1(np->rno);
		subcontext = FORPUSH;
	}
	elif (np->token eq ARGP)
		subcontext = FORPUSH;
	elif (np->token eq NOT)
		subcontext = FORCC;
#if FLOAT
	elif ( is_conv(np) )
		if (context eq FORINIT and np->left->token eq RCON)
			np->left->sc = np->sc;
#endif
	if (eval(np->left, subcontext, r_inhib) eq false)
		return false;

	return u_sube(np, context, r_inhib);
}

global
bool eval(NP np, short context, RMASK r_inhib)
{
	bool rv = false;
	np->r1 = np->r2 = -1;

	if (np ne nil)
		if (np->tt eq EV_NONE)
			rv = l_eval(np, context, r_inhib);
		elif (np->tt eq EV_LEFT)
		{
			rv = u_eval(np, context, r_inhib);
			freetmps(np);
			free1(np, np->left);
		}
		else
		{
			rv = b_eval(np, context, r_inhib);
			/* already did freetmps */
			free1(np, np->left);
			free1(np, np->right);
		}
	return rv;
}

static
ALREG max_afd = {0, ARV_END+1-AREG,
#if FLOAT
					FRV_END+1-FREG,
#else
					0,
#endif
					DRV_END+1-DREG};	/* No local variables at compile time */

global
bool geni(NP np)		/* reduced version for data areas */
{
	bool ok;
	if (G.nmerrors)
		return false;
	eval_order(np, max_afd);		/* must not generate code anyhow */
	reserve = 0;
	ok = eval(np, FORINIT, 0);
	if (ok eq true)
		ok = contextmon(np, FORINIT);
	return ok;
}

global
bool genx(NP np, short context)
{
	bool ok;

	if (G.nmerrors)
		return false;

	eval_order(np, max_afd);
	reserve = 0;
	ok = eval(np, context, 0);
	if (ok eq true and context)
		ok = contextmon(np, context);

	if (G.prtab->tmps)
		if (G.prtab->tmps > G.scope->b_tsize)
			G.scope->b_tsize = G.prtab->tmps;
#if PRLN
	G.To_prln = np;		/* For #pragma prln */
#endif
	return ok;
}
