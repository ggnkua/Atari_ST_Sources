/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
 *           (c) 1990 - present by H. Robbers.
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
 * The code in this file deals with "registerizing" local variables and
 * parameters. The general idea is to look for highly referenced local
 * variables and parameters and effectively turn them into register
 * variables automatically. All register types are considered:
 * Data, address and floating point registers.
 *
 * We need to be certain of several things about a variable before placing
 * it in a register. It's address must not be taken, and it must not be
 * referred to through "aliases" (e.g. when casting to a shorter object).
 * It must be able to fit in a register. And to keep things like printf from
 * breaking, parameters can only be registerized if none of the parameters
 * have their address taken.
 *
 * The compiler makes this all possible by placing instructions within the
 * generated inetrchange code. These hints appear as instructions and are parsed
 * by the optimizer. The information is stashed away by calling addvar().
 * The hints give us the size and offset of each parameter and local variable.
 * Their names are also given, although that information isn't needed here.
 *
 * There are tradeoffs to be wary of when registerizing. If no register
 * variables exist yet, then "movem" instructions have to be added, requiring
 * more references to make this worthwhile. In the case of parameters, the
 * register has to be initialized from the stack. The four cases are:
 *
 *	Locals	w/ other regs:	1 reference  required
 *		no other regs:	4 references required
 *	Parms	w/ other regs:	2 references required
 *		no other regs:	6 references required
 *
 * The numbers above represent the break-even point based on a savings of
 * 2 bytes per reference, and the incremental cost of adding "movem" or
 * "move" instructions as needed.
 *
 * This optimizes for space only. To optimize for time, each reference would
 * be weighted based on the loop nesting level at which it occurs.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "common/mallocs.h"
#include "param.h"

#include "out.h"
#include "opt.h"
#include "po.h"
#include "reg.h"
#include "inst.h"

#define debugR (G.xflags['r'-'a'])
#define error console

#define	ALIASED		0x1	/* offset is aliased with another */
#define	REFERED		0x2	/* address of the variable was taken */
#define ARPTR	    0x4	/* pointer to standard area */

global
LOCVAR *locals;

#define	IS_LOCAL(x)	((x)->loffset < 0)
#define	IS_PARM(x)	((x)->loffset > 0)

/* This LOWVREGS code seems to be OK, but I am not confident.
 * virtual regs is designed such that this code is not needed at all.
 * Yet, I want it to be correct before sending it to the attic.
 * As long as it is not, it is left disabled by default.
 */
#define LOWVREGS 0

static
bool  paddr;	/* address of a parameter was taken */
static
short rcnt;		/* number of locals that got registerized */

static
RMASK omask, nmask;	/* old and new register masks */

static
char *ltypes[] = { "", "FRG", "PTR", "ARD" };

static
void dump_table(LOCVAR *loc, Cstr txt)
{
	char *pclass(short);
	short lcnt = 0;
	console("areas, local variables and parameters: %s\n", txt);
	while (loc)
	{
		console(" %-4s, %3ld.%d %2dX v%d(%d/%d)",
			loc->name ? loc->name : "~~9",
			loc->loffset,
			loc->size,
			loc->ref,
			loc->vreg.r, loc->vreg.l, loc->vreg.s);
		if (loc->reg >= 0)
			console(" reg=%s",preg(loc->reg));
		if (loc->flags & REFERED)
			console(" REFERED");
		if (loc->flags & ALIASED)
			console(" ALIASED");
		if (loc->type)
			console("\t%s", ltypes[loc->type-DRG]);
		if (loc->flags & ARPTR)
			console(" AREA %s",
			pclass(loc->area));
		console("\n");
/*
		if (loc->disps)
		{
			depth++;
			dump_table(loc->disps, txt);
			depth--;
		}
*/		loc = loc->next;
		lcnt++;
	}
	console("%d found\n", lcnt);
}

/*
 * addvar - add a variable entry for the current function
 *
 * These come from hints the compiler gives us about local variables.
 * We use the size and offset here to make sure we don't have aliasing
 * problems with the local variables we want to registerize.
 */

static
LOCVAR *new_locvar(LOCVAR **this)
{
	LOCVAR *follow = *this,
	       *new = CC_xcalloc(1, sizeof(*new), AH_LOCVAR, CC_ranout);

	if (new)
	{
		if (follow)
			while(follow->next)
				follow = follow->next;
		new->prior = follow;
		new->next = nil;
		if (follow)
			follow->next = new;
		else
			*this = new;
	}

	return new;
}

global
LOCVAR *addvar(IP ip, short type)
{
	long atols(char **);
	OPND *op = ip->arg;
	LOCVAR *new = new_locvar(&locals);
	if (new)
	{
		new->loffset = op->disp;
		new->size   = type eq PTR ? DOT_L : ip->sz;
		new->flags  = 0;
		new->type   = type;
		new->ref    = 0;
		new->reg    = -1;
		new->vreg   = op->vreg;
	}

	return new;
}

static
LOCVAR *addarea(short area)
{
	LOCVAR *new = new_locvar(&locals);
	if (new)
	{
		new->disps  = nil;
		new->loffset = 0;
		new->size   = DOT_L;
		new->type   = PTR;
		new->area   = area;
		new->ref    = 0;
		new->flags  = ARPTR;
		new->reg    = -1;
	}

	return new;
}

static
LOCVAR *adddisp(LOCVAR **disps, short area, short offs)
{
	LOCVAR *new = new_locvar(disps);
	if (new)
	{
		new->disps  = nil;
		new->loffset = offs;
		new->size   = DOT_L;
		new->type   = ARD;
		new->area   = area;
		new->ref    = 0;
		new->flags  = 0;
		new->reg    = -1;
	}

	return new;
}

/*
 * clrvar()  - init the variable list
 * freevar() - free the variable list
 */
global
void clrvar(void)
{
	paddr = false;
	rcnt = 0;
	locals = nil;
}

global
void freevar(LOCVAR *loc)
{
	while(loc)
	{
		LOCVAR *nx = loc->next;
		freevar(loc->disps);
		CC_xfree(loc);
		loc = nx;
	}
}

static
bool same_var(OPND *op, LOCVAR *loc)
{
	return
	       op->vreg.r ne 0
	   and op->vreg.r eq loc->vreg.r
	   and op->vreg.l eq loc->vreg.l
	   and op->vreg.s eq loc->vreg.s;		/* tcheck no */
}

static
bool overlaps(IP ip, OPND *op, LOCVAR *loc)
{
	long d1,d2,s1,s2;

	if (	loc->vreg.l <= op->vreg.l		/* same or lower level, different scope = */
	    and loc->vreg.s ne op->vreg.s)		/*                  disjunct scopes, no problem */
		return false;

	d1 = op->disp;
	s1 = ip->sz;
	d2 = loc->loffset;
	s2 = loc->size;

	if (d1 + s1 eq d2 + s2)		/* if the fields have the same high address alignment, its OK */
		return false;
	if (d1 >= d2 + s2)			/* field 1 entirely above field 2 */
		return false;
	if (d1 + s1 <= d2)			/* field 1 entirely below field 2 */
		return false;

	return true;		/* overlap means: not entirely disjunct and not completely embraced and justified right */
}

/*
 * ckref() - check for a local variable reference
 *
 * If a local variable reference is found, it's added to the table or
 * (if already there) its reference count is incremented. If we're
 * taking its address, note that too.
 */
static
void ckref(IP ip, OPND *op)
{
	LOCVAR *loc;

	if (op)
	{
		long disp = op->disp + op->namedisp;

		if (op->aname and disp < 32768)
		{
			loc = locals;

			/* is the area already in the table? */
			while (loc)
			{
				if (loc->area eq op->areg)
				{
					loc->ref++;
					break;
				}

				loc = loc->next;
			}

			/* If not in the table, add an entry for it. */

			if (loc eq nil)
			{
				loc = addarea(op->areg);
				if (loc)
					loc->ref = 1;
			}

			if (loc)
			{
				LOCVAR *this = loc;

				loc = loc->disps;
				/* is the displacement in the displacement list? */
				while (loc)
				{
					if (loc->loffset eq disp)
					{
						loc->ref++;
						break;
					}

					loc = loc->next;
				}

				if (loc eq nil)
				{
					loc = adddisp(&this->disps, this->area, disp);
					if (loc)
						loc->ref = 1;
				}
			}
		}
		elif (    MO(op->am) eq REGID
		      and op->areg   eq FRAMEP
		      and op->type
		     )
		{
			/* is the local variable already in the table? */
			loc = locals;
			while (loc)
			{
				if (same_var(op, loc))
				{
					loc->ref++;		/* OK got one */
					break;
				}
				elif (ip->sz)		/* lea & pea have size 0 */
				if (overlaps(ip, op, loc))
				{
					loc->flags |= ALIASED;		/* to be removed later */
					break;
				}

				loc = loc->next;
			}

			if (loc)
			{
				if (idata[ip->opcode].iflag & LEA)
				{
					loc->flags |= REFERED;

					/* If we took the address of a parameter, note that
					   by setting 'paddr'.	*/

					if (IS_PARM(loc))
						paddr = true;
				}
			}
		}
	}
}

/*
 * X_spec() - convert a partial register spec
 *
 * Convert a string like "Rm" or "Rm-Rn" to a mask.
 */
static
RMASK X_spec(Cstr s)
{
	short base, m, n, i = 0;
	RMASK mask = 0;

	if (*s)
	{
		switch(s[0])
		{
			case 'd':
			case '$':
				base = DREG; break;
#if FLOAT
			case 'f':
				if (s[1] eq 'p')
					s++, i++;
			case '~':
				base = FREG; break;
#endif
			case 'a':
			case '*':
				base = AREG;
		}

	/* If everything is right 'ln' and 'sp' mnemonics cant occur here */
		m = s[1] - '0' + base;

		if (s[2] ne '-')
			return RM(m);

		n = s[i+4] - '0' + base;

		while (m <= n)
			mask |= RM(m), m++;

	}
	return mask;
}

/*
 * s_to_mask() - convert a register list to a mask
 *
 * Convert a string like "Rx/Rm-Rn/Ro-Rp/... etc"  to the appropriate
 * mask value.
 */
global
RMASK s_to_mask(Cstr s)
{
	RMASK mask = X_spec(s);

	do
	{
		while (*s and *s ne '/') s++;
		if (*s eq '/')
			mask |= X_spec(++s);
	}
	while (*s);
	return mask;
}

global
RMASK get_locs(IP ip)
{
	OPND *arg = ip->arg;

	if (arg)
	{
		if   (MO(arg->am) eq RLST)
			return s_to_mask(arg->astr);
		elif (MO(arg->am) eq IMM)
			return arg->disp;
		elif (MO(arg->am) eq REG)
			return RM(arg->areg);
		elif (MO(arg->am) eq ABS)
			return loclist;
		else
			error("mmx/mms error\n");
	}

	return 0;
}

/*
 * lcheck() - scan for local variable references in the given function
 */
static
void lcheck(BP bp)
{
	if (bp)
	{
		while (bp)
		{
			IP ci = bp->first;
			while (ci)
			{
				if (ci->arg)
				{
					ckref(ci, ci->arg->next);
					ckref(ci, ci->arg);
				}
				ci = ci->next;
			}
			bp = bp->next;
		}

		omask = loclist;	/* registers currently used for locals: set by 'reg' instruction */
	}
}

static
void rem_loc_var(LOCVAR *loc)
{
	/* remove from list */
	if (loc->prior)
		loc->prior->next = loc->next;
	else
		locals = loc->next;

	if (loc->next)
		loc->next->prior = loc->prior;
}

static
void ins_loc_var(LOCVAR *this, LOCVAR *after)
{
	this->prior = after;

	if (after->next)
		after->next->prior = this;

	this->next = after->next;
	after->next = this;

}

static
void do_sort(void)
{
	LOCVAR *loc = locals;

	/* simple bubble sort */

	while (loc->next)
	{
		if (loc->ref < loc->next->ref)
		{
			LOCVAR *pr = loc->prior,
			       *nx = loc->next;
			/* exchange loc :: loc->next */
			rem_loc_var(loc);		/* remove loc from list */
			ins_loc_var(loc, nx);	/* insert loc after its former next */
			if (pr)
				loc = pr;
		}
		else
			loc = loc->next;
	}
}

#if LOWVREGS
extern
BP fhead;

static
void lop(OPND *op, VREG_INFO fro)
{
	if (op)
	{
		if (    MO(op->am) eq REGID
		    and op->areg   eq FRAMEP)
		{
			if (    op->vreg.r
			    and op->vreg.r eq fro.r
			    and op->vreg.l eq fro.l
			    and op->vreg.s eq fro.s
			   )
				op->vreg.r--;
		}
	}
}

static
void lower_ops(BP bp, VREG_INFO fro)
{
	while (bp)
	{
		IP ip = bp->first;
		while (ip)
		{
			if (ip->arg)
			{
				lop(ip->arg, fro);
				lop(ip->arg->next, fro);
			}
			ip = ip->next;
		}
		bp = bp->next;
	}
}

static
void lower_vregs(LOCVAR *loc, VREG_INFO v)
{

	LOCVAR *m = locals;

	while (m and m < loc)
	{
		if (m->vreg.r and m->vreg.r eq v.r)
			return;
		m = m->next;
	}

	while (loc and loc->vreg.l eq v.l and loc->vreg.s eq v.s)
	{
		if (loc->vreg.r > v.r)
		{
			lower_ops(fhead, loc->vreg);
			loc->vreg.r--;
		}

		loc = loc->next;
	}

	while (loc and loc->vreg.l > v.l)
	{
		if (loc->vreg.r > v.r)
		{
			lower_ops(fhead, loc->vreg);
			loc->vreg.r--;
		}

		loc = loc->next;
	}
}
#endif

static
void
lclean_up(void)
{
	LOCVAR *loc = locals;

	/* Remove uninteresting references from consideration:
	   1. Variables whose address was taken, or are aliased with another.
	   2. Variables that don't fit in a register.	*/

	while (loc)
	{
		LOCVAR *nx = loc->next;

		if (    (loc->flags&(REFERED|ALIASED)) ne 0
			or  (    loc->type eq FRG
			     and loc->size ne DOT_X
			     and loc->size ne DOT_D
			     and loc->size ne DOT_S		/* 03'11 HR also DOT_S */
			    )
		   )
		{

#if LOWVREGS
			/* Lower the vregs */
			lower_vregs(nx, loc->vreg);
#endif
			freevar(loc->disps);
			rem_loc_var(loc);
			CC_xfree(loc);
		}

		loc = nx;
	}

	/* If paddr is set, remove any parameters from consideration. We
	   have to do this so that things like printf (that take the address
	   of a parameter and increment it) don't break. Only if no parameter
	   addresses are taken, can we consider registerizing any of them.	*/

	if (paddr)
	{
		loc = locals;
		while (loc)
		{
			LOCVAR *nx = loc->next;
			if (IS_PARM(loc) and (loc->ref > 0))
			{
				freevar(loc->disps);
				rem_loc_var(loc);
				CC_xfree(loc);
			}

			loc = nx;
		}
	}
}

/* sort_areadisp
 *
 * Find most frequently used displacement for areas that are assigned a register.
 */

static
void sort_areadisp(void)
{
	LOCVAR *loc = locals;

	while (loc)
	{
		if (    loc->type eq PTR
			and loc->reg >= 0
		    and (loc->flags&ARPTR) ne 0
		    and loc->disps
		   )
		{
			short high = 0, disp = 0;
			LOCVAR *dsp = loc->disps;
			while (dsp)
			{
				if (dsp->ref > high)
				{
					high = dsp->ref;
					disp = dsp->loffset;
				}

				dsp = dsp->next;
			}

			loc->loffset = disp;
		}

		loc = loc->next;
	}
}

/* Same virtual registers in disjunct scopes can get the same real register allocated */
static
void set_more_regs(LOCVAR *loc, short type, short vr, short rr)
{
	while (loc)
	{
		if (    loc->reg <= 0				/* not already allocated */
		    and loc->vreg.r
		    and loc->vreg.r eq vr
		    and loc->type eq type 			/* tcheck yes */
		   )
			loc->reg = rr;

		loc = loc->next;
	}
}

/*
 * lassign(), assignr() - assign local variable to registers
 *
 * Check for aliases, sort the table, and then decide how to assign
 * the local variables to registers.
 */

static
short assignr(short r, short m, short type)
{
	LOCVAR *loc = locals;

	while (r <= m)
	{
		/*
		 * If the register is already in use, skip it.
		 */
		if (omask & RM(r))
		{
			r++;
			continue;
		}

		/* If no more eligible variables, then stop. */
		if (loc eq nil)
			break;

		if ((loc->flags & ~ARPTR) eq 0)		/* allow ARPTR */
		if (loc->type eq type)
		{
			short weight = 0;

			if (loc->flags & ARPTR)
				weight = 2;

			if (loc->ref > weight and loc->reg <= 0)
			{
				loc->reg = r;
				nmask |= RM(r);
				if ((loc->flags & ARPTR) eq 0)
					set_more_regs(loc, loc->type, loc->vreg.r, r);
				r++;
				rcnt++;
			}
		}
		loc = loc->next;
	}

	return r;
}

static
void lassign(void)
{
	lclean_up();		/* remove anything not applicable from locals */
	if (locals)
		do_sort();		/* sort by reference count */
	nmask = omask;
	assignr(DRV_START, DRV_END, DRG);
#if FLOAT
	assignr(FRV_START, FRV_END, FRG);
#endif
	assignr(ARV_START, ARV_END, PTR);
	sort_areadisp();
}


/*
 * str_alloc(s) - copy s to dynamically allocated space
 */
global
char * str_alloc(Cstr s)
{
	long l = strlen(s);
	if (l <= 0)
		l  = 1;
	return strcpy(CC_qalloc(&opndmem, l + 1, CC_ranout, AH_CC_INST_OP), s);
}

static
void fixmove(OPND *op)
{
	loclist = nmask;
	if (op)
	{
#if REGLIST
		MO(op->am) = RLST;
		op->astr = str_alloc(mask_to_s(nmask));
#else
		MO(op->am) = IMM;
		op->disp   = nmask;
#endif
	}
}

static
void addinits(BP bp, IP ip)
		/* block where we're working */
				/* instruction before the moves */
{
	LOCVAR *loc = locals;
	IP ni;

	if (ip eq nil)		/* no LINK found */
		return;

	while (loc)
	{
		/* If it's a local variable, we don't have to do anything. */
		if ( !(IS_LOCAL(loc) or loc->reg < 0) )
		{
			/* Allocate and initialize a new instruction */
			ni = allocIn();
			ni->sz = loc->size;
			ni->live = 0;
			/* Set up the register operand */
			ni->reg  = loc->reg;

			if (loc->flags & ARPTR)
			{
				ni->opcode = LAX;
				ni->arg = CC_qalloc(&opndmem, sizeof(OPND), CC_ranout, AH_CC_INST_OP);
				if (ni->arg)
				{
					pzero(ni->arg);
					MO(ni->arg->am) = ABS;
#if AMFIELDS
					ni->arg->am.f.symb = 1;
#else
					ni->arg->am |= SYMB;
#endif
					ni->arg->astr = P.area_po_names[loc->area]->s;
					ni->arg->areg = P.area_po_names[loc->area]->area_number;
					ni->arg->disp = loc->loffset;
				}
			othw
				ni->opcode = LDX;
				console("addinits: LDX\n");
				ni->arg = CC_qalloc(&opndmem, sizeof(OPND), CC_ranout, AH_CC_INST_OP);
				if (ni->arg)
				{
					pzero(ni->arg);
					/* Set up the variable reference. */
					MO(ni->arg->am) = REGID;
					ni->arg->areg   = FRAMEP;
					ni->arg->disp   = loc->loffset;
					ni->arg->type   = loc->type;
				}
			}

			/* Set up the register usage */
			uprefs(ni);

			/* Link the instruction into the block */
			ni->next = ip->next;	/* link LDX to its neighbors */
			ni->prior = ip;
			ip->next = ni;			/* link neighbors to the LDX */

			if (bp->last eq ip)
				bp->last = ni;
			else
				ni->next->prior = ni;
		}

		loc = loc->next;
	}
}

/*
 * findlnk() - find the LINK instruction in the given block
 *
 * When profiling, the LINK isn't the first instruction in the entry
 * block. This function lets us handle both cases cleanly.
 */
static	IP
findlnk(BP bp, long sz)
{
	IP ip = bp->first;

	while (ip)
		if (ip->opcode eq LKX)
			return ip;
		else
			ip = ip->next;

	return nil;
}

extern long lineno;

static
short fixref(IP ip, OPND *op)
{
	LOCVAR *loc = locals;
	extern short s_memref, s_regref;

#if OPTBUG
	lineno = ip->snr;
#endif
	if (op)
	{
		if (    MO(op->am) eq REGID
		    and op->areg   eq FRAMEP
		   )
		{
		/* Does the reference need to be changed? */
			while (loc)
			{
				if (    loc->flags  eq 0			/* no ARPTR (area pointer) */
				    and loc->reg    >= 0
					and ip->sz
				    and same_var(op, loc)
				   )
				{

					{
						MO(op->am) = REG;
						op->areg = loc->reg;
						s_regref++;
						return 1;
					}
				}

				loc = loc->next;
			}
		}
		elif (op->aname)		/* operands for which we know area number and area displacement */
		{
			/* Can the reference be changed? */
			if (MM(op->am) ne IMM)
			{
				while (loc)
				{
					if (loc->reg >= 0)
					{
						if (loc->area eq op->areg)
						{
							op->areg = loc->reg;
							op->disp += op->namedisp;
							op->disp -= loc->loffset;
							op->aname = false;
							op->namedisp = 0;
							op->astr = nil;
							MO(op->am) = op->disp ? REGID : REGI;
							s_memref++;
							return 2;
						}
					}
					loc = loc->next;
				}
			}
		}
	}

	return 0;
}

/*
 * lrewrite() - rewrite the function based on the new register assignments
 *
 * Fixing the references is easy, but we have to fix up (or add) the movem
 * instructions as well. Also, we call addinits() to initialize any registers
 * that will contain parameters or area addresses
 */
static
void lrewrite(BP bp)
{
	BP cb = bp;
	IP ci;

	/* First, rewrite all the references to the locals that
	   we've reassigned to registers.	*/

	while (cb)
	{
		ci = cb->first;
		while(ci)
		{
			ASMOP op1 = ci->opcode;
			short fixed_arg = 0, fixed_dst = 0;

			if (ci->arg)
			{
				if (    ci->opcode eq LDX
				    and MM(ci->arg->am) eq IMM
#if AMFIELDS
					and ci->arg->am.f.symb ne 0
#else
				    and (ci->arg->am & SYMB) ne 0
#endif
				    and ISA(ci->reg)
				   )
				{
					ci->opcode = LAX;
#if AMFIELDS
					ci->arg->am.f.m = ABS;
#else
					ci->arg->am &= AMFLGS;
					ci->arg->am |= ABS;
#endif
					PDBG(ci, p0_imm);
				}

				fixed_arg = fixref(ci, ci->arg);
				fixed_dst = fixref(ci, ci->arg->next);
			}

		 	if (fixed_arg eq 1)
			{
		/*
		 *  tramsformations that have to be made to keep opcodes
		 *  consistent with operands.
		 *  NN.BB. Only the combinations that couldnt produce correct code
		 *         without the peephole optimizations are placed here.
		 */
#if FLOAT
				if (op1 eq FASN)
				{
					ci->opcode = STO;
					ci->reg = ci->arg->areg;
					ci->arg = ci->arg->next;
					uprefs(ci);
					PDBG(ci, s_fasn);
				}
				elif (op1 eq FPSH)
				{
					ci->opcode = PSH;
					uprefs(ci);
					PDBG(ci, p_fpsh);
				}
				else
#endif
				/* tst    <ea> is now tst An */
				if (    !(G.i2_68020 or G.Coldfire)
					  and op1 eq TST
					  and (ci->arg)
					  and is_areg(ci->arg->am, ci->arg->areg)
					  )
				{
					ci->opcode = CPX;
					ci->reg = ci->arg->areg;
					MO(ci->arg->am) = IMM;
					ci->arg->disp = 0;
					uprefs(ci);
					PDBG(ci, tst_areg);
				}
				else
					uprefs(ci);
			}

#if FLOAT
			if (fixed_dst eq 1 and op1 eq FASN and ci->arg->next)
			{
				ci->opcode = LDX;
				ci->reg = ci->arg->next->areg;
				ci->arg->next = nil;
				uprefs(ci);
				PDBG(ci, d_fasn);
			}
#endif
			if (fixed_dst or fixed_arg eq 2)
				uprefs(ci);

			ci = ci->next;
		}

		cb = cb->next;
	}


	/* If the movem's are there, just find them and fix up
	   the register specs.	*/
	/* !!! movem's are always generated */

	fixmove(regi->arg);		/* just fix up the spec in the 'reg' instruction. */

	ci = bp->first;
	if (ci ne nil and ci->opcode eq RGL)
	{
		ci = ci->next;
		if (ci ne nil and ci->opcode eq LKX)
		{
			ci = ci->next;
			if (ci ne nil and ci->opcode eq MMS)
				/* add the initialization instructions. */
				addinits(bp, ci);
			else
				error("OE: lost start of function\n");
		}
	}
}

/*
 * setreg() - try to "registerize" local variables in the given function
 */
global
void setreg(BP bp)
{
	lcheck(bp);
	if (locals)
	{
		lassign();

		if (rcnt > 0)
			lrewrite(bp);
	}

	s_reg += rcnt;		/* keep totals for accounting */
}
