/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
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
 * Jan 1991: Modified by Han Driesen, Stichting ST, The Netherlands
 * Optimizer integrated in the compiler.
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include "param.h"

#include "out.h"
#include "opt.h"
#include "reg.h"
#include "peep.h"
#include "inst.h"
#include "list.h"

char *str_alloc(Cstr s);
Cstr pascode(short tok);

global
bool change_reg(IP ip, short to, short fro)
{
	OPND *arg = ip->arg,
	     *dst = nil;

	OPMODE am;

	bool changed = false;

	if (ip->reg eq fro)
		changed |= true,
		ip->reg = to;

	if (arg)
	{
		dst = arg->next;
#if AMFIELDS
		am = arg->am;
		am.f.inc = 0;
		am.f.dec = 0;
		am.f.xl  = 0;
#else
		am = arg->am&~(INC|DEC|XLONG);
#endif
		if (MO(am) > NONE and MO(am) <= REGIDX and arg->areg eq fro)
			changed |= true,
			arg->areg = to;

		if ( (MO(am) eq PCDX or MO(am) eq REGIDX) and arg->ireg eq fro)
			changed |= true,
			arg->ireg = to;
	}

	if (dst)
	{
#if AMFIELDS
		am = dst->am;
		am.f.inc = 0;
		am.f.dec = 0;
		am.f.xl  = 0;
#else
		am = dst->am&~(INC|DEC|XLONG);
#endif
		if (MO(am) > NONE and MO(am) <= REGIDX and dst->areg eq fro)
			changed |= true,
			dst->areg = to;

		if ( (MO(am) eq PCDX or MO(am) eq REGIDX) and dst->ireg eq fro)
			changed |= true,
			dst->ireg = to;
	}

	if (changed)
	{
		uprefs(ip);
		PDBG(ip, p1_reg);
	}
	return changed;
}

global
bool change_all_reg(BP bp, short to, short fro)
{
	bool changed = false;

	while (bp)
	{
		IP ip = bp->first;
		while (ip)
		{
			if ( ((ip->rref|ip->rset)&RM(fro)) ne 0)
				 changed |= change_reg(ip, to, fro);
			ip = ip->next;
		}
		bp = bp->next;
	}

	return changed;
}

static
bool used_reg(IP ip, RMASK regs)
{
	return ((ip->rref|ip->rset) & regs) ne 0;
}

global
bool reg_used(BP bp, IP ip, RMASK regs)
{
	/* first check following ip */
	ip = ip->next;
	while (ip)
	{
		if (used_reg(ip, regs))
			return true;
		ip = ip->next;
	}
	/* then check following bp */
	bp = bp->next;
	while (bp)
	{
		if ((bp->rref | bp->rset) &regs)
			return true;
		bp = bp->next;
	}

	return false;
}

static
bool changed_reg(IP ip, short reg1, short reg2)
{
	RMASK regs = RM(reg1)|RM(reg2);

	if ((regs & ip->rset) eq 0)
		return false;

	if (    (ip->opcode eq LDX)
	    and ip->arg
		and MO(ip->arg->am) eq REG
	    and (ip->rref|ip->rset) eq regs
	   )
		return false;		/* not really changed :-) */

	return true;
}

global
bool reg_changed(BP bp, IP ip, short reg1, short reg2)
{
	/* first check following ip in this block*/
	ip = ip->next;
	while (ip)
	{
		if (changed_reg(ip, reg1, reg2))
			return true;
		ip = ip->next;
	}
	/* then check following blocks */
	bp = bp->next;
	while (bp)
	{
		ip = bp->first;
		while (ip)
		{
			if (changed_reg(ip, reg1, reg2))
				return true;
			ip = ip->next;
		}
		bp = bp->next;
	}
	return false;
}

static
bool regdown(BP bp, RMASK wrk, RMASK var)
{
	short to = 0, fro = 0;

	while ( (var & (RM(fro))) eq 0 )
		fro++;	/* find a used var */
	while ( (wrk & (RM(to ))) ne 0 )
		to ++; /* find a unused work */

	return change_all_reg(bp, to, fro);
}

/* returns true if CC is not involved in the next instruction (or block) */
global
bool not_cc(IP ip, BP bp)
{
	if (ISA(ip->reg))		/* setting address reg doesnt change cc */
		return true;
	if (ip->next)
		return (idata[ip->next->opcode].iflag&CCU) eq 0;
	else
		return bp->cond eq nil;		/* last instruction and no conditional block */
}

global
bool is_number(const OPND *op)
{
	if (op)						/* 12'09 HR: stupid Milan!!! */

	if (MM(op->am) eq ABS)
	{
		Cstr s = op->astr;
		if (s eq nil) return true;		/* 12'09 HR: then already in op->disp */
		if (isdigit(s[0]))
			return true;
		if (s[0] eq '-' and isdigit(s[1]))
			return true;
	}
	return false;
}

static
bool any_number(IP ip)
{
	if (ip->arg)
	{
		if (is_number(ip->arg))
			return true;
		if (ip->arg->next)
			if (is_number(ip->arg->next))
				return true;
	}
	return false;
}

#if COLDFIRE
global
bool coldfire_ok(IP ip, OPND *s, OPND *d, short sz)
{
	short sm = MM(s->am), dm = MM(d->am);

	if (sm eq SPPLUS)					return true;
	if (sm <  REGID)					return true;
	switch (sm)
	{
		case REGID:
		case PCD:
			if (dm < REGIDX)			return true;
		break;
		case IMM:
			if (    sz eq DOT_L
				and MO(s->am) eq IMM /* NO other flags (ABS) */
			    and can_3q(s->disp)
			    and op_dreg(s)
			   )
			   return false;			/* 09'12 v4.12: moveq is OK, dont split */
		/* fallthru OK */
		case REGIDX:
		case ABS:
		case PCDX:
			if (dm < REGID)				return true;
	}
	return false;
}
#endif
static
short free_work(IP ip, short reg)
{
	short i;
	if (reg > A0)
	{
		for (i = A0; i < ARV_START; i++)		/* 06'11 < */
			if ((ip->live&RM(i)) eq 0)
				if ((ip->rref&RM(i)) eq 0)
					return i;
		return -1;
	}
#if FLOAT
	if (reg > F0)
	{
		for (i = F0; i < FRV_START; i++)		/* 06'11 < */
			if ((ip->live&RM(i)) eq 0)
				if ((ip->rref&RM(i)) eq 0)
					return i;
		return -1;
	}
#endif
	for (i = D0; i < DRV_START; i++)		/* 06'11 < */
		if ((ip->live&RM(i)) eq 0)
			if ((ip->rref&RM(i)) eq 0)
				return i;
	return -1;
}

static
bool cf_split(BP bp, IP ip)
{
	IP new;
	short r = free_work(ip, D0);
	if (r < 0)
	{
		OPND *arg, *dst;
#if OPTBUG
		console("[%ld]split move: no free reg\n", ip->snr);
#endif
		/* 06'11 HR: No free reg, make pusher */
		new = instbefore(bp, ip, true);
		arg = new->arg;
		dst = ip->arg->next;
		new->opcode = PSH;
		new->arg = ip->arg;
		ip->arg = arg;
		MO(ip->arg->am) = SPPLUS;
		ip->arg->next = dst;
		new->iflg.i = ip->iflg.i;
		new->sz   = ip->sz;
		uprefs(new);
		uprefs(ip);
		return true;
	othw
#if OPTBUG
		console("[%ld]split\n",ip->snr);
#endif
		new = instbefore(bp, ip, false);
		new->arg = ip->arg;
		ip-> arg = ip->arg->next;
		new->reg = r;
		ip-> reg = r;
		new->opcode = LDX;
		ip-> opcode = STO;
		new->iflg.i = ip->iflg.i;
		new->sz   = ip->sz;
		uprefs(new);
		uprefs(ip);
		return true;
	}
}

/*
 * ipeep1(ip) - check for changes to the instruction 'ip'
 */

static	short
ipeep1(BP bp, IP ip)
{
	short reg, op1, areg;
	IDATA *id; OPMODE am1;

	if (ipeep0(bp, ip) )			/* context free transformations */
		return true;

	if (ip->arg)
	{
		am1  = ip->arg->am;
		areg = ip->arg->areg;
	othw
		MO(am1) = NONE;
		areg = -1;
	}

	op1 = ip->opcode;
	id = &idata[op1];
	reg = ip->reg;

	/* voor testen met eem test assemblerfiletje of kleine C filetjes
	is dit niet erg handig, dit maakt nogal wat test instructies weg
	        voor we aan andere optmizations toe zijn   */

	/*	The compiler does not generate constructs that leave parts of
	 *	registers alive
	 *
	 *	op.x    Rn   X
	 *
	 *	Delete if Rn is set and Rn is dead.
	 *  inst not followed by Bcc. and no side effects
	 *  and no INC|DEC in the argument
	 *  unless the inst itself uses reg
	 */

#if 1
	if (    (id->regf  & SET ) ne 0
		and (id->iflag & SIDE) eq 0
#if AMFIELDS
		and !(   am1.f.inc
		      or am1.f.dec
		     )
#else
	    and (am1 & (INC|DEC)) eq 0
#endif
		and not_cc(ip, bp)
	   )
	{		
		if ((ip->live & RM(reg)) eq 0)
		{
			if (!any_number(ip))		/* 04'09 HR IO memory */
			{
#if OPTBUG
				IP np, pp = ip->prior;

				np = delinst(bp, ip);
			    if (np)
					PDBG(np, p1_0)
				elif (pp)
					PDBG(pp, p1_0)
				else
					peepcnt.p1_0++;
#else
				delinst(bp, ip);
#endif
			    return 1;
		    }
		}
	}
#endif
	if (    (op1 eq LKX or op1 eq ULX)
	    and (anywhere_used & RM(FRAMEP)) eq 0
	   )
	{
		s_lnk++;
		delinst(bp, ip);
		return 1;
	}

	if (ip->arg eq nil)
		return 0;

	/* if LDX is turned into load same reg
	 * delete if not followed by Bcc.
	 */
	if (    op1 eq LDX
	    and MO(am1) eq REG
	    and reg eq areg
	    and not_cc(ip, bp)
	   )
	{
	#if OPTBUG
		IP np, pp = ip->prior;

		np = delinst(bp, ip);
	    if (np)
			PDBG(np, p1_3)
		elif (pp)
			PDBG(pp, p1_3)
		else
			peepcnt.p1_3++;
	#else
		delinst(bp, ip);
	#endif
		return 1;
	}

	if (	op1 eq SVA
	    and MO(am1) eq REG
		)
	{
		if (  (ip->live&RM(areg)) eq 0		/* the register var itself is dead */
		    or reg eq areg					/* or the register var has been downed */
		   )
		{
			if (not_cc(ip, bp))
			{
	#if OPTBUG
				IP np, pp = ip->prior;

				np = delinst(bp, ip);
			    if (np)
					PDBG(np, p1_2)
				elif (pp)
					PDBG(pp, p1_2)
				else
					peepcnt.p1_2++;
	#else
				delinst(bp, ip);
	#endif
			othw				/* change sva to tsx */
				if (!ISA(reg))
				{
					ip->opcode = TSX;
					ip->arg = nil;
					uprefs(ip);
					PDBG(ip, p1_4)
				}
			}
		    return 1;
		}
	}

	if (op1 eq FLX or op1 eq FLD)
	{
		OPND *dst = ip->arg->next;
		if (MO(dst->am) eq IMM and dst->disp <= 8)
		{
			ip->arg = dst;
			ip->opcode = LSRX;
			uprefs(ip);
			PDBG(ip, p1_shift);
			return 1;
		}
	}

	if (op1 eq LFLX or op1 eq LFLD)
	{
		OPND *dst = ip->arg->next;
		if (MO(dst->am) eq IMM and dst->disp <= 8)
		{
			ip->arg = dst;
			ip->opcode = LSLX;
			uprefs(ip);
			PDBG(ip, p1_shift);
			return 1;
		}
	}

	if (op1 eq AFLD)
	{
		OPND *dst = ip->arg->next;
		if (MO(dst->am) eq IMM and dst->disp <= 8)
		{
			ip->arg = dst;
			ip->opcode = ASRX;
			uprefs(ip);
			PDBG(ip, p1_shift);
			return 1;
		}
	}

	/* field shift not followed by comparison but with Z cc check can be removed.
	   NB: This instruction is ALWAYS precede by a AND.
	*/
	if (op1 eq FLX)
	{
		if (    ip->next eq nil
		    and (ip->live & RM(reg)) eq 0
		    and bp->cond
		    and (bp->opcode eq BEQ or bp->opcode eq BNE)
		   )
		{
#if OPTBUG
			IP np, pp = ip->prior;

			np = delinst(bp, ip);
		    if (np)
				PDBG(np, p1_5)
			elif (pp)
				PDBG(pp, p1_5)
			else
				peepcnt.p1_5++;
#else
			delinst(bp, ip);
#endif
			return 1;
		}
	}

	if (   op1 eq MOV
#if COLDFIRE
	    or op1 eq M3Q
#endif
	    )
	{
		if (ip->arg)
			if (ip->arg->next)
			{
				OPND *dst = ip->arg->next;

				if (op_dreg(dst))
				{
					ip->opcode = LDX;
					ip->reg = dst->areg;
					ip->arg->next = nil;
					PDBG(ip, p1_ldx)
					uprefs(ip);
#if OPTBUG
					console("[%ld]p1_ldx\n", ip->snr);
#endif
					return 1;
				}
			}
	}

#if COLDFIRE
	if (G.Coldfire)
	{
		if (op1 eq MOV or op1 eq M3Q)
		{
			OPND *arg = ip->arg,
			     *dst = ip->arg->next;
			if (!coldfire_ok(ip, arg, dst, ip->sz))
			{
				if (!(    !G.i2_68020
				      and ip->sz eq DOT_L		/* 09'12 HR v4.12 */
				      and MO(ip->arg->am) eq IMM
			          and can_3q(ip->arg->disp)
			         )
			       )
					if (cf_split(bp, ip))
					{
						PDBG(ip, p1_split);
						return 1;
					}
			}
		}
	}
#endif

	if (op1 eq REGL)
	{
		RMASK m = loclist & anywhere_used;

		if (loclist ne m)
		{
			loclist = m;	/* !! The no regs dumped is reduced !! */
#if REGLIST
			ip->arg->astr = str_alloc(mask_to_s(loclist));
			MO(ip->arg->am) = RLST;
#else
			ip->arg->disp  = loclist;
			MO(ip->arg->am) = IMM;
#endif
			PDBG(ip, p1_1)
			uprefs(ip);
			return 1;
		}
	}

	return 0;
}

static
bool reg_reduce(BP bp)
{
	RMASK u = anywhere_used;
	RMASK m = loclist & u;

	if ((m&DM) ne 0 and (u&WDM) ne WDM)
	{
		if (regdown(bp, (u&WDM)|MSKD, m&DM))
			return true;
	}
	elif ((m&AM) ne 0 and (u&WAM) ne WAM)
	{
		if (regdown(bp, (u&WAM)|MSKA, m&AM))
			return true;
	}
#if FLOAT
	elif ((m&FM) ne 0 and (u&WFM) ne WFM)
	{
		if (regdown(bp, (u&WFM)|MSKF, m&FM))
			return true;
	}
#endif

	return false;
}

/*
 * peep1(bp) - peephole optimizations with a window size of 1
 */

static bool
peep1(BP bp)
{
	BP rp = bp;
	IP ip, next_ip;
	bool  changed = false;

	while (bp)
	{
		ip = bp->first;
		while (ip)
		{
			next_ip = ip->next;

			if (ip->opcode eq REGL)
			{
				loclist = get_locs(ip);

				if (reg_reduce(rp))	/* downing of regs can reduce movem's or movem time */
				{
					rhealth(rp);	/* because all regs after this instr are downed */
					return true;		/* return here!!!! */
				}
			}

			changed |= ipeep1(bp, ip);

			ip = next_ip;
		}
		bp = bp->next;
	}
	return changed;
}

globalvoid peep(BP bp)
{
	/*
	 * Loop until no more changes are made. After each change, do
	 * live/dead analysis or the data gets old. In each loop, make
	 * at most one change.
	 */

#if DBGH
	console("\n**** optimizing %s\n\n", bp ? bp->name : "~~~");
#endif

#if 1
	do
	{
		rhealth(bp);

	#if OPTBUG
		if break_in break;	/* Getting trapped in a loop is easy here */
	#endif
	}
	while (    peep3(bp)
			or peep2(bp)
			or peep1(bp)
		  );
#else
	/* If you cant trust your compiler
		whether it evaluates 'or' terms
		 allways left to right, you must use
		  the following sequence:	*/
	{
		bool changed;
		do
		{
			rhealth(bp);
	#if OPTBUG
			if break_in break;
	#endif
			    changed = peep3(bp);
			if (!changed)
				changed = peep2(bp);
			if (!changed)
				changed = peep1(bp);

		} while (changed);
	}
#endif
	
}
