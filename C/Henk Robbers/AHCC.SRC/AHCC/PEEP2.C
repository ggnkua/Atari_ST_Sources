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
 * Jan 1991: Major revision by Han Driesen, Stichting ST, The Netherlands
 * Optimizer integrated in the compiler.
 *     compiler now produces IXC  (which stands for 'interchange code')
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "param.h"

#include "opt.h"
#include "peep.h"
#include "inst.h"

#define error send_msg

bool double_ref(IP ip);
bool is_number(const OPND *op);

bool is_f(IP), no_cf(IP ip);

/*
 * 2-instruction peephole optimizations
 */

/*
 * find a dead workreg.
 */

static
short mvs_sz(IP ip)
{
	return ip->opcode eq WMVS ? DOT_W : DOT_L;
}

/*
 * sets(ip, reg) - is 'reg' set by the instruction 'ip'?
 */
global
bool p2_sets(IP ip, ACC reg)
{
	return ((reg_set(ip) & RM(reg)) != 0);
}

/*
 * refs(ip, reg) - is 'reg' referenced by the instruction 'ip'?
 */
global
bool p2_refs(IP ip, ACC reg)
{
	return ((reg_ref(ip) & RM(reg)) != 0);
}

/*
 * uses(ip, ref) - is 'reg' used by the instruction 'ip'?
 */
global
bool p2_uses(IP ip, ACC reg)
{
	return p2_sets(ip, reg) || p2_refs(ip, reg);
}

static
bool same_REGorI(short which, OPND *o, short reg)
{
	return     o
	       and o->am eq which
	       and o->areg eq reg;
}

static
bool same_ireg(OPND *arg, ACC reg, short size, short ty)
{
#if AMFIELDS
	if (arg->am.f.m ne REGIDX)
#else
	if ((arg->am & ~XLONG) ne REGIDX)
#endif
		return false;

	if  (arg->ireg eq reg)
		if (ty eq 1)			/* shift */
#if AMFIELDS
			if (arg->am.f.xl)
#else
			if ((arg->am & XLONG) ne 0)
#endif
				return size eq DOT_L;
			else
				return size eq DOT_W;
		else
			return true;

	return false;
}

static
bool disp_ok(OPMODE am, OPND *o1, OPND *o2)
{
	return
#if AMFIELDS
	      (am.i   eq REGI   and D16OK(           o2->disp))
	   or (am.i   eq REGID  and D16OK(o1->disp + o2->disp))
	   or (am.f.m eq REGIDX and D8OK (o1->disp + o2->disp))

#else
	      ( am         eq REGI   and D16OK(           o2->disp))
	   or ( am         eq REGID  and D16OK(o1->disp + o2->disp))
	   or ((am&~XLONG) eq REGIDX and D8OK (o1->disp + o2->disp))
#endif
	;
}

static
bool p2_4ab(OPND *o, short reg)
{
	return
#if 1
       (    ISA(o->areg)
    	and (    same_REGorI(REGI, o, reg)
    	     or (    same_REGorI(REGID, o, reg)
    	         and D8OK(o->disp)
			    )
			)
	   )
#else
       (    ISA(o->areg)
		and o->areg eq reg
		and (   MO(o->am) eq REGI
			 or (    MO(o->am) eq REGID
			     and o->disp > -127
			     and o->disp <  128
			    )
			)
	   )
#endif
	;
}

static
void do_p2_4(bool b, OPND *o, short areg, IP i1, IP ti2, BP bp)
{
	MO(o->am) = REGIDX;
	if (i1->sz eq DOT_L)
#if AMFIELDS
		o->am.f.xl = 1;
#else
		o->am |= XLONG;
#endif
	o->ireg = areg;
	uprefs(ti2);
/*	console("p2_4%c\n", b?'b':'a');
*/	delinst(bp, i1);
#if OPTBUG
	if (b)
		PDBG(ti2, p2_4b)
	else
		PDBG(ti2, p2_4a)
#endif
}

static
short scalable(IP ip, short *fac, short *ty)
{
	if (    (   ip->opcode eq ASLX
	         or ip->opcode eq LSLX
	        )
	    and MO(ip->arg->am) eq IMM
	    and (   ip->arg->disp eq 1
	         or ip->arg->disp eq 2
	         or (ip->arg->disp eq 3 and !G.Coldfire)
	        )
	   )
	{
		*fac = 1 << ip->arg->disp;
		*ty = 1;
		return ip->reg;
	}

 	if (    (   ip->opcode eq USCX
	         or ip->opcode eq SCX
	         or ip->opcode eq UMPX
	         or ip->opcode eq MPX
	        )
	    and MO(ip->arg->am) eq IMM
	    and (   ip->arg->disp eq 2
	         or ip->arg->disp eq 4
	         or (ip->arg->disp eq 8 and !G.Coldfire)
	        )
	   )
	{
		*fac = ip->arg->disp;
		*ty = 0;
		return ip->reg;
	}

	return -1;
}

static
bool same_ty(ACC reg1, ACC reg2)
{
	if (ISA(reg1) and ISA(reg2))
		return true;
#if FLOAT
	if (ISF(reg1) and ISF(reg2))
		return true;
#endif
	if (ISD(reg1) and ISD(reg2))			/* !!!! ISD includes fregs !!!! */
		return true;
	return false;
}

static
bool is_p2_8(OPMODE am, short reg, OPND *o)
{
	return
#if AMFIELDS
   (    (am.f.inc eq 0 and am.f.dec eq 0)
	and !(    (   am.f.m eq REGI
	           or am.f.m eq REGID
	           or am.f.m eq REGIDX
	          )
	      and o->areg eq reg
	     )
   )
#else
   (    (am & (INC|DEC)) eq 0
    and !(    (   am eq REGI
               or am eq REGID
               or (am&~XLONG) eq REGIDX
              )
          and o->areg eq reg
         )
   )
#endif
	;
}

static
bool is_regi_or_d(OPND *o)
{
	return    MO(o->am) eq REGI
	       or MO(o->am) eq REGID
#if AMFIELDS
		   or o->am.f.m eq REGIDX
#else
	       or (o->am&~XLONG) eq REGIDX
#endif
	;
}

/*
 * ipeep2(bp, i1) - look for 2-instruction optimizations at the given inst.
 */

static OPND nullopnd = {0};

static	bool
ipeep2(BP bp, IP i1)
{
	IP i2 = i1->next,		/* the next instruction */
	   ti2;					/* "temporary" next inst */

	ASMOP	op1 = i1->opcode,
	        op2 = i2->opcode;
	ACC		reg = i1->reg;
	OPND	*dst,
	        *arg;
	short areg = -1;
#if AMFIELDS
	OPMODE am1;

	am1.i = NONE;
#else
	short am1 = NONE;
#endif

	if (i1->arg)
	{
		if (i1->arg->next)
			dst = i1->arg->next;
		else
			dst = &nullopnd;
		arg = i1->arg;
		am1 = arg->am;
		areg = arg->areg;
	}
	else
		arg = dst = &nullopnd;

#if FLOAT || COLDFIRE
	/*    mpx,umpx   Dn #2, #4 or #8
	 * or aslx,lslx  Dn #1, #2 or #8      --> delete
	 *  ....
	 *    stuff not using Dn and Dn is dead after the indexing
	 *  ....
	 *    (An, Dn)                        --> (An, Dn*scale)
	 */

	if (G.i2_68020 or G.Coldfire)
	{
		short ireg, fac, type;

		ireg = scalable(i1, &fac, &type);			/* try to use indexed with scale factor */

		if (ireg >= 0)
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				OPND *arg2 = ti2->arg;

				if (arg2)
					if (same_ireg(arg2, reg, i1->sz, type))
						if (   (ti2->live & RM(reg)) eq 0
						    or p2_sets(ti2, reg)				/* we know the reg is used */
						   )
						{
							arg2->scale = fac eq 2 ? 1 : (fac eq 4 ? 2 : 3);

							if (i1->sz eq DOT_W and type eq 0)		/*  mul: in case of i*i=l */
							{
#if COLDFIRE
								if (G.Coldfire)
								{
									i1->opcode = (i1->opcode eq USCX or i1->opcode eq UMPX) ? MVZ : MVS;
									MO(i1->arg->am) = REG;
									i1->arg->areg = reg;
									uprefs(i1);
								}
								else
#endif
								{
#if AMFIELDS
									arg2->am.f.xl = 0;
#else
									arg2->am &= ~XLONG;
#endif
									delinst(bp, i1);
								}
							}
							else
								delinst(bp, i1);
							uprefs(ti2);
							PDBG(ti2, p2_27);
							return true;
						}

				if (p2_uses(ti2, reg))
					break;
			}
		}
	}
#endif

	if (op1 eq MVS)
	{
		/*  mvs.x   Dn X		ldx.x   Dn X
		 *        stuff that doesnt use Dn
		 *  adx/sbx.l An  Dn    adx/sbx.w  An  Dn
		 */

#if COLDFIRE
		if (!G.Coldfire)
#endif
		if (i1->sz eq DOT_W)
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (ti2->arg)
				{
					OPND *arg2 = ti2->arg;

					if (    (ti2->opcode eq ADX or ti2->opcode eq SBX)
				        and ISA(ti2->reg)
						and MO(arg2->am) eq REG
						and arg2->areg eq reg
					   )
					{
						ti2->sz = DOT_W;
						i1->opcode = LDX;
						uprefs(i1);
						uprefs(ti2);
						PDBG(ti2, p2_4c);
						return true;
					}
				}

				if (p2_uses(ti2, reg))
					break;
			}

		/*  mvs.x   Dn X		ldx.x   Dn X
		 *        stuff that doesnt use Dn
		 *  ads/sbs.l Dn An    ads/sbs.w  Dn An
		 *
		 */

#if COLDFIRE
		if (!G.Coldfire)
#endif
		if (i1->sz eq DOT_W)
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (ti2->arg)
				{
					OPND *arg2 = ti2->arg;

					if (    (ti2->opcode eq ADS or ti2->opcode eq SBS)
				        and MO(arg2->am) eq REG
				        and ISA(arg2->areg)
						and ti2->reg eq reg
					   )
					{
						ti2->sz = DOT_W;
						i1->opcode = LDX;
						uprefs(i1);
						uprefs(ti2);
						PDBG(i1, p2_4d);
						return true;
					}
				}

				if (ti2->rref & RM(reg))
					break;
			}

		/* Remove ineffective ext.l right before asr/lsr.w (after conversion of dvx(s/u)  */
		/* HR was only effective with choice of short scaling ???? */

		if (i2->arg and i1->sz eq DOT_W)
		{
			if (    (i2->opcode eq ASRX or i2->opcode eq LSRX)
			    and MO(i2->arg->am) eq IMM
			    and i2->reg eq reg
			    and i2->sz  eq DOT_W
			   )
		    {
		 		i1->opcode = LDX;
		 		uprefs(i1);
				PDBG(i1, p2_40);
				return true;
		    }
		}

		/* Remove ineffective extend right before masking */

		if (i2->arg)
		{
			short sz = i1->sz;
			OPND *arg2 = i2->arg;
			if (    i2->opcode eq ANX
			    and MO(arg2->am) eq IMM
			    and i2->reg eq reg
			    and i2->sz  eq sz
			    and (   (sz eq DOT_B and (ulong)arg2->disp < 0x100)
		             or (sz eq DOT_W and (ulong)arg2->disp < 0x10000)
		            )
			   )
		    {
		 		i1->opcode = LDX;
		 		uprefs(i1);
				PDBG(i1, p2_40);
				return true;
		    }
		}
	}

	if (i1->arg eq nil)
		return false;

	switch(op1)
	{
	case STO:
	{
		/*													ICX
		 *	move.x	X, Y		=>	move.x	X, Y			sto..  X  <ea>
		 *	tst.x	X or Y			...deleted...			tst       X|<ea>
		 *
		 * If pre-decrement is set on the dest. of the move,
		 * don't let that screw up the operand comparison.
		 */
		if (    OPFS(TST)
			and(   opeq (arg, i2->arg, false)
				or regeq(i2->arg, reg) )
			)
		{
			delinst(bp, i2);
			PDBG(i1, p2_9);
			return true;
		}

		/*											IXC
		 *	move.x	X, Y		=>	move.x	X, Y	sto Y <ea>
		 *	move.x	Y, X			IP				ldx Y <ea>
		 */
		if (    OPFS(LDX)
			and reg eq i2->reg
			and opeq(arg, i2->arg, true)
		    and !is_number(arg)				/* 04'09 HR IO memory */
		   )
		{
			if (is_p2_8(am1, reg, arg))
			{
				delinst(bp, i2);
				PDBG(i1, p2_8);
				return true;
			}
		}

		if (    OPFS(MVS)		/* b to l or w to l */
			and reg eq i2->reg
			and opeq(arg, i2->arg, true)
		    and !is_number(arg)				/* 04'09 HR IO memory */
		   )
		{
			if (is_p2_8(am1, reg, arg))
			{
				i2->opcode = EXX;
				i2->sz = DOT_L;
				uprefs(i2);
				PDBG(i2, p2_8);
				return true;
			}
		}

		if (    OPFS(WMVS)		/* b to w */
			and reg eq i2->reg
			and opeq(arg, i2->arg, true)
		    and !is_number(arg)				/* 04'09 HR IO memory */
		   )
		{
			if (is_p2_8(am1, reg, arg))
			{
				i2->opcode = EXX;
				i2->sz = DOT_W;
				uprefs(i2);
				PDBG(i2, p2_8);
				return true;
			}
		}

		/*												IXC
		 *	move.x	Dm, X		=>	move.x	Dm, X		sto.x Dm   X
		 *	cmp.x	#N, X			cmp.x	#N, Dm		cpi.x      #N,X => cpx.x Dm  #N
		 *
		 *	Where X isn't register direct.
		 *
		 *	Since X generally references memory, we can compare
		 *	with the register faster.
		 */
		if (    OPFS(CPI)
			and MO(i2->arg->am) eq IMM
			and i2->arg->next
			and ISD(reg)
			and opeq(arg, i2->arg->next, -1)
#if AMFIELDS
			and am1.f.inc eq 0
			and am1.f.dec eq 0
#else
			and ((am1 & (INC|DEC)) eq 0)
#endif
			)
		{
			i2->opcode = CPX;
			i2->arg->next = nil;
			i2->reg = reg;

			uprefs(i2);
			PDBG(i2, p2_101);
			return true;
		}
	}
	break;

	case MVS:
	case WMVS:
	{
		/*	(modified by hd)			IXC
		 *
		 *	(w)mvs.? Dn	X		=>	ldx.?  Dn X
		 *
		 *	Where Dn is dead after the inst.
		 */
		if (    ISD(reg)
			and (i1->live & RM(reg)) eq 0)
		{
			i1->opcode = LDX;
			uprefs(i1);
			PDBG(i1, p2_23);
			return true;
		}

		/*
		 *	mvs.x  Dn   X		=>	mvs.x  Do   X
		 *	ldx.y  Do   Dn
		 *
		 *	Where Dn is dead.
		 */
		if (    op2 eq LDX
			and ISD(reg)
		    and MO(i2->arg->am) eq REG
		    and i2->arg->areg  eq reg
		    and ISD(i2->reg)
		    and i1->sz eq mvs_sz(i2)
		    and i1->iflg.i eq i2->iflg.i
		   )
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i1->reg = i2->reg;

				uprefs(i1);
				delinst(bp, i2);
				PDBG(i1, p3_0);
				return true;
			}
		}
	}

	case LDX:
	{
#if COLDFIRE
	 	/* Also applicable in mvs-->ldx situations */

		/* If a move has been split and a operand has been lea'd
		 *
		 * ldx Dn <ea>            delete
		 * sto Dn <ea>		--> mov  <ea>,<ea>
		 *
		 * Dn is dead
		 */

		if (    OPFS(STO)
			and !ISF(reg)
			and i1->reg eq i2->reg
			and coldfire_ok(i2, i1->arg, i2->arg, i2->sz)
		    and (i2->live & RM(reg)) eq 0
		   )
		{
			i1->opcode = MOV;
			i1->arg->next = i2->arg;
			uprefs(i1);
			delinst(bp, i2);
			PDBG(i1, p2_combine);
			return true;
		}
#endif

#if 1 /* COLDFIRE */
		/* If a operation has been split and a operand has been registerized
		 *
		 * ldx Dn <ea>              delete
		 * op  Rm Dn 		--> op  Rm <ea>
		 *
		 * Dn is dead
		 */

		if (   (op2 eq ADX or op2 eq SBX)
		    and i1->iflg.i eq i2->iflg.i
			and i1->sz     eq i2->sz
		    and ISD(reg)
		    and MO(i2->arg->am) eq REG
		    and i2->arg->areg eq reg
		   )
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i2->arg = i1->arg;
				i1->arg = nil;
				uprefs(i2);
				delinst(bp, i1);
				PDBG(i2, p2_34);
				return true;
			}
		}

		/* If a operation has been split and a operand has been registerized
		 *
		 * ldx Dn <ea>              delete
		 * ops Dn Rm		--> opx Rm <ea>
		 *
		 * Dn is dead
		 */

		if (   (op2 eq ADS or op2 eq SBS)
		    and i1->iflg.i eq i2->iflg.i
			and i1->sz     eq i2->sz
		    and ISD(reg)
		    and MO(i2->arg->am) eq REG
		    and i2->reg eq reg
		   )
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i2->opcode++;
				i2->reg = i2->arg->areg;
				i2->arg = i1->arg;
				i1->arg = nil;
				uprefs(i2);
				delinst(bp, i1);
				PDBG(i2, p2_35);
				return true;
			}
		}

		/* If a move has been split and a operand has been registerized
		 *
		 * ldx Fn Fm            delete
		 * sto Fn Fs		--> sto Fm Fs
		 *
		 * Fn is dead
		 */

		 if   (    op2 eq STO
		       and ISF(reg)
		       and MO(am1) eq REG
		       and ISF(areg)
		       and i2->reg eq reg
		      )
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i2->reg = areg;
				uprefs(i2);
				delinst(bp, i1);
				PDBG(i2, p2_24);
				return true;
			}
		}

		if (    OPFS(LDX)
		    and MO(i2->arg->am) eq REG
		    and i2->arg->areg  eq reg
		   )
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i1->reg = i2->reg;
				uprefs(i1);
				PDBG(i1, p2_33);
				delinst(bp, i2);
				return true;
			}
		}
#endif		/* Coldfire */

		/* After scaling and deletion of the multiply by 2, 4 or 8:
		 *		ldx Dn, Dm      --> deleted
		 *   ....
		 * stuff not using Dn or Dm
		 *   ....
		 * (An, Dn)				--> (An, Dm)
		 */

		if (    ISD(reg)
		    and MO(am1) eq REG
		    and ISD(areg)
		   )
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				OPND *arg2 = ti2->arg;
				if (    arg2
					and same_ireg(arg2, reg, i1->sz, 1)
				   )
				{
					if ((ti2->live & RM(reg)) eq 0)
					{
						arg2->ireg = areg;
						uprefs(ti2);
						delinst(bp, i1);
						PDBG(ti2, p2_28);
						return true;
					}
				}

				if (   p2_uses(ti2, reg)
				    or p2_uses(ti2, areg)
				   )
					break;
			}
		}

		/*
		 *	move.x	X, Y		=>	move.x	X, Y			ldx..  Y  X
		 *	tst.x	X or Y			...deleted...			tst       X|Y
		 *
		 */
		if (    OPFS(TST)
			and (   opeq (arg, i2->arg, false)
				 or regeq(i2->arg, reg) )
			)
		{
			delinst(bp, i2);
			PDBG(i1, p2_91);
			return true;
		}

		/*		         						IXC
		 *	move.x	X, Dm	=>	INST.x	X, Dn	ldx.x  Dm  X   => op.x Dn X
		 *	INST.x	Dm, Dn						opx.x  Dn  Dm
		 *
		 *	where Dm is dead, and INST is one of: add, sub, and, or, cmp
		 */
		if (	regeq(i2->arg, reg)
			and !(ISA(i2->reg) and i2->sz eq DOT_B)
			and i1->iflg.i eq i2->iflg.i
			and i1->sz     eq i2->sz
			and (   op2 eq ADX
			     or op2 eq SBX
			     or op2 eq ANX
			     or op2 eq ORX
			     or op2 eq CPX
			    )
		   )
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i1->opcode = i2->opcode;
				i1->reg =    i2->reg;

				uprefs(i1);
				delinst(bp, i2);
				PDBG(i1, p2_12);
				return true;
			}
		}

		/*	After registerizing an <ea> to Dm
		 *	ldx.x  Dn  Dm
		 *	cpx.x  Dn  X          => cpx.x Dm  X
		 *
		 *	where Dn is dead
		 */
		if (    OPFS(CPX)
			and i2->reg eq reg
			and MO(am1) eq REG
			and !(ISA(areg) and i1->sz eq DOT_B)
		   )
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i2->reg = areg;

				uprefs(i2);
				PDBG(i2, p2_6);
				delinst(bp, i1);
				return true;
			}
		}

		/*  after registerization:
		 *										IXC
		 *	move Am, An							ldx  An Am			ldx An Am
		 *	move x(An), An	=> move x(Am), An	ldx  An An.x	=>  ldx An Am.x
		 *
		 */

		if (	op2 eq LDX
			and ISA(reg)
			and is_areg(am1, areg)
			and ISA(i2->reg)
			and reg eq i2->reg
			and (   MO(i2->arg->am) eq REGI
			     or MO(i2->arg->am) eq REGID
			    )
			and i2->arg->areg eq reg
			)
		{
			i2->arg->areg = areg;
			PDBG(i2, p2_2);
			uprefs(i2);
			return true;
		}
		/*  ldx   Dn   <ea>	=>  psh  <ea>
		 *  psh   Dn
		 *  Dn must dead after the psh
		 */
		if (    !ISF(reg)				/* 03'11 HR: cant do for pushers of fp */
		    and op2 eq PSH
		    and i1->sz eq i2->sz
		    and MO(i2->arg->am) eq REG
		    and i2->arg->areg eq reg
		    and (i2->live & RM(reg)) eq 0
		   )
		{
			i1->opcode = PSH;
			i1->reg = -1;
			uprefs(i1);
			delinst(bp, i2);
			PDBG(i1, p2_100);
			return true;
		}

		/*
		 *	ldx.l  Ao   Am 		                        move.l  Am,Ao
		 *	adx.s  Ao   Dn	 =>  lax  Ao  (Am,Dn.s)		add.s   Dn,Ao    ==> lea   (Am,Dn.s),Ao
		 */
		if (    op2 eq ADX
			and i1->sz eq DOT_L
			and is_areg(am1, areg)
			and ISA(reg)
			and MO(i2->arg->am) eq REG
			and ISD(i2->arg->areg)
			and i2->reg eq reg
		   )
		{
			i2->opcode = LAX;
			i2->iflg.f.flt = 0;
			i2->arg->ireg = i2->arg->areg;
			MO(i2->arg->am) = REGIDX;
			if (i2->sz eq DOT_L)
#if AMFIELDS
			i2->arg->am.f.xl = 1;
#else
			i2->arg->am |= XLONG;
#endif
			i2->arg->disp = 0;
			i2->arg->areg = areg;

			uprefs(i2);
			delinst(bp, i1);
			PDBG(i2, p2_7);
			return true;
		}

		/* dereferencing
		 *
		 *	ldx.l  An X
		 *		.... stuff not setting anything used by the first
		 *  ldx.l  An X				=> delete
		 */

		if (   ISA(reg)
			and arg->areg ne reg
		   )
		{
			RMASK use = i1->rref | i1->rset;
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (    ti2->opcode eq LDX
				    and ti2->reg    eq reg
				    and ti2->sz     eq i1->sz
				    and ti2->iflg.i eq i1->iflg.i
				    and opeq(arg, ti2->arg, -1)
				   )
				{
					delinst(bp, ti2);
					PDBG(i1, p2_32);
					return true;
				}

				if (ti2->rset & use)
					break;

				if (MO(am1) ne REG)
					if (ti2->arg)
					{
						IDATA *id = idata + ti2->opcode;
						if (    (id->argf & SET) ne 0
						    and opeq(arg, ti2->arg, -1)
						   )
							break;

						if (ti2->arg->next)
							if (    (id->dstf & SET) ne 0
							    and opeq(arg, ti2->arg->next, -1)
							   )
								break;
					}

			}
		}

		/*      after registerization simplify dereferencing
		 *	NEW:	for arg							IXC
		 *
		 *	move.l	Am, An	=>		move.l	Am, An		ldx.l An  Am
		 *	... stuff ...			... stuff ...
		 *	op.x  ...An. ...		op.x	...Am. ...	op.x  X   ..An. .
		 *												op.x	  ...An.,....
		 *	where "stuff" doesn't set Am or An
		 *	..An.. has no side effects
		 *  The second instr may itself set An via reg
		 */
		if (    i1->sz eq DOT_L
		    and ISA(reg)
		    and is_areg(am1, areg)
		    and reg ne areg
		   )
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				RMASK mask = RM(reg) | RM(areg);
				OPND *arg2 = ti2->arg;

				if (arg2)
				{
					if (   (    MO(arg2->am) eq REGI
						    or  MO(arg2->am) eq REGID
#if AMFIELDS
							or arg2->am.f.m eq REGIDX
#else
						    or (arg2->am&~XLONG) eq REGIDX
#endif
						    )
						and arg2->areg eq reg
						)
					{
						arg2->areg = areg;
						PDBG(ti2, p2_0);
						uprefs(ti2);
						return true;
					}
				}

				if (ti2->rset & mask)
					break;
			}
		}

		/*	NEW:	for dst							IXC
		 *
		 *	move.l	Am, An	=>	move.l	Am, An		ldx.l An  Am
		 *	... stuff ...		... stuff ...
		 *	op.x  ...An...		op.x	...Am...	op.x  X   ..An..
		 *											op.x	  .....,An..
		 *	where "stuff" doesn't set Am An
		 *	..An.. has no side effects
		 */
		if (    i1->sz eq DOT_L
		    and ISA(reg)
		    and is_areg(am1, areg)
		    and reg ne areg
		   )
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (ti2->rset & RM(reg))
					break;
				if (ti2->rset & RM(areg))
					break;
				if (ti2->arg)
				{
					OPND *dst2 = ti2->arg->next;
					if (dst2)
					{
						if (    (    MO(dst2->am) eq REGI
							     or  MO(dst2->am) eq REGID
#if AMFIELDS
							     or dst2->am.f.m eq REGIDX
#else
						         or (dst2->am&~XLONG) eq REGIDX
#endif
							    )
							and dst2->areg eq reg
							)
						{
							dst2->areg = areg;
							PDBG(ti2, p2_1);
							uprefs(ti2);
							return true;
						}
					}
				}
			}
		}
	}
	break;

	case MOV:
#if COLDFIRE
	case M3Q:
#endif
	{
		/*
		 *   both Y and X are not REG						IXC
		 *
		 *	move.x	X, Y		=>	move.x	X, Y			mov..    Y,X
		 *	tst.x	X or Y			...deleted...			tst      X|Y
		 */
		if (    OPFS(TST) )
			if (   opeq(dst, i2->arg, false)		/* ~DEC */
				or opeq(arg, i2->arg, false) )		/* ~DEC */
			{
				delinst(bp, i2);
				PDBG(i1, p2_92);
				return true;
			}

		/*										IXC
		 *	move.x	X, Y	=>	move.x	X, Rn	mov     X,Y		=>	ldx Rn  X
		 *	move.x	Y, Rn		move.x	Rn, Y   ldx Rn  Y			sto Rn  Y
		 *
		 *	where Y isn't INC or DEC, and isn't register direct
		 *	Y may not reference Rn		*hd*
		 *  04'09 HR: Y must not be ABS
		 */
		if (    OPFS(LDX)
			and i1->arg->next
			and opeq(dst, i2->arg, true)
#if AMFIELDS
			and dst->am.f.inc eq 0
			and dst->am.f.dec eq 0
			and dst->am.f.m ne REG
#else
			and (dst->am & (INC|DEC)) eq 0
			and  dst->am ne REG
#endif
			and !is_number(dst)						/* 04'09 HR IO addresses */
			and (i2->rref & RM(i2->reg)) eq 0)		/*hd*/
		{
			i1->opcode = LDX;
			i2->opcode = STO;
			i1->arg->next = nil;
			i1->reg = i2->reg;

			uprefs(i1);
			uprefs(i2);
			PDBG(i2, p2_15);
			return true;
		}

	}
	break;

	case PEA:
	{
		/*  for PureC calling
		 *
		 *	pea.x      X
		 *    ... stuff that doesnt mingle ....			Especially other pushes :-) (a7 usage)
		 *	pla.x  Rn	   ==>     lax.x Rn   X
		 *
		 */

		/* if the stack is not used between the 2 they belong to each other
		 * The effect is that push/pull pairs are removed from inside out
		 * if the target register of the pull is used, the optimization must not take place
		 */

		RMASK set = 0, uses = 0;

		for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
		{
			if (    ti2->opcode eq PLA
				and ti2->sz     eq DOT_L
				and ISA(ti2->reg)
			   )
			{
				if ((i1->rref & set) & ~RM(SP))		/* anything the push uses that is set anywhere */
					break;
				if ((uses|set) & RM(ti2->reg))		/* target of pull is used in between */
					break;
				ti2->opcode = LAX;
				ti2->arg = i1->arg;
				i1->arg = nil;
				uprefs(ti2);
				PDBG(ti2, p2_45)
				delinst(bp, i1);
				return true;
			}

			uses |= ti2->rref;
			set  |= ti2->rset;
			if ((uses|set) & RM(SP))
				break;
		}
	}
	break;

	case PSH:
	#if FLOAT
	case FPSH:
	#endif
	{
		/*  for PureC calling
		 *
		 *	psh.x      X
		 *    ... stuff that doesnt mingle ....
		 *	pla.x  Rn	   ==>     ldx.x Rn   X
		 *
		 */

		/* if the stack is not used between the 2 they might belong to each other */
		/* if the target register of the pull is used, the optimization must not take place */

		RMASK set = 0, uses = 0, psh_reg = i1->rref & ~RM(SP);

		for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
		{
			if (    ti2->opcode eq PLA
				and ti2->iflg.i eq i1->iflg.i
				and ti2->sz     eq i1->sz
			   )
			{
				if (   ((i1->rref  & set) & ~RM(SP)) ne 0	/* anything the push uses that is set anywhere */
				    or ((uses|set) & RM(ti2->reg))   ne 0	/* target of pull is used in between */
				   )
				{
					RMASK pll_reg = ti2->rset & ~RM(SP);

					/* If we cant change the pull, can we change the psh ?
					      pull reg must be different from push reg,
					      push reg must me dead after the push
					      and the pull reg must not be used in between.
					*/
					if (    (i1->live & psh_reg) eq 0
					    and ((uses|set) & pll_reg) eq 0
					   )
					{
						i1->opcode = LDX;
						i1->reg = ti2->reg;

						uprefs(i1);
						PDBG(i1, p2_47);
						delinst(bp, ti2);
						return true;;
					}

					break;
				}

				ti2->opcode = LDX;
				ti2->arg = i1->arg;
				i1->arg = nil;
				uprefs(ti2);
				PDBG(ti2, p2_46)
				delinst(bp, i1);
				if (    MO(am1) eq REG
					and areg eq ti2->reg
				   )
				{
					PDBG(ti2, p1_3);
					delinst(bp, ti2);
				}
				return true;
			}

			uses |= ti2->rref;
			set  |= ti2->rset;
			if ((uses|set) & RM(SP))
				break;
		}
	}
	break;

	case SVA:
	{
		/*  sva.. Dn Dm
		 *  Dn and Dm not really changed
		 *  change all Dm to Dn, remove sva
		 *
		 */
		if (    MO(am1) eq REG
		    and reg ne areg
		   )
		{
			bool have = false;

			if (!reg_used(bp, i1, RM(reg)))
				have = change_all_reg(bp, reg, areg);

			if (!have)
				if (!reg_changed(bp, i1, reg, areg))
					have |= change_all_reg(bp, reg, areg);

			if (have)
			{
		#if OPTBUG
				IP np, pp = i1->prior;

				np = delinst(bp, i1);
			    if (np)
					PDBG(np, p2_5)
				elif (pp)
					PDBG(pp, p2_5)
				else
					peepcnt.p2_5++;
		#else
				delinst(bp, i1);
		#endif
			    return true;
			}
		}

		/*	ICX
		 *	sva.. X  <ea>
		 *	tst      X|<ea>		...deleted...
		 *
		 * If pre-decrement is set on the dest. of the move,
		 * don't let that screw up the operand comparison.
		 */
		if (    OPFS(TST)
			and(   opeq (arg, i2->arg, false)		/* ~DEC */
				or regeq(i2->arg, reg) )
			)
		{
			delinst(bp, i2);
			PDBG(i1, p2_93);
			return true;
		}

		/*  sva Rm Rn
		 *  ... stuff that doesnt set Rm and doent use Rn ...
		 *  psh Rn					--> psh Rm
		 */

		if (MO(am1) eq REG )
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (    ti2->opcode eq PSH
					and i1->iflg.i  eq ti2->iflg.i
					and i1->sz      eq ti2->sz
					and same_REGorI(REG, ti2->arg, areg)
				   )
				{
					ti2->arg->areg = reg;
					uprefs(ti2);
					PDBG(ti2, p2_29)
					return true;
				}

				if (p2_uses(ti2, areg))
					break;
				if (p2_sets(ti2, reg))
					break;
			}
		}

		/*
		 *	sva Rm Rn
		 *	... stuff ...
		 *	ldx Rm Rn				... delete...
		 *
		 *	where "stuff" doesn't set Rm or Rn. Also make sure that
		 *	the second move isn't followed by a conditional branch.
		 *  or a Scc cq FScc
		 *	In that case leave everything alone since the branch
		 *	probably relies on flags set by the move.
		 */

		if (MO(am1) eq REG )
		{
			RMASK temp = 0;  /* RM(arg.areg) | RM(reg); */

			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (    ti2->opcode eq LDX
					and i1->iflg.i  eq ti2->iflg.i
					and i1->sz      eq ti2->sz
					and same_REGorI(REG, ti2->arg, areg)
					and ti2->reg        eq reg
				    and not_cc(ti2, bp)
				   )
				{
					delinst(bp, ti2);
					PDBG(i1, p2_3);
					return true;
				}

				temp |= ti2->rset;
				if (temp & (RM(reg) | RM(areg)))
					break;
			}
		}

		/*	for argregs
		 *	sva.x Rm Rn								move Rm,Rn
		 *	... stuff ...
		 *	ldx.x Rx Rn	 =>  ldx.x Rx Rm			move Rn,Rx	=> move Rm,Rx
		 *
		 *	where "stuff" doesn't set Rn or Rm
		 *
		 *	want to get rid of Rn which may be a only once used regarg
		 *  then we can also get rid of the movem, or part of it.
		 */

		if (MO(am1) eq REG )
		{
			RMASK temp = 0;

			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (    ti2->opcode eq LDX
				    and ti2->sz  eq i1->sz
				    and ti2->iflg.i     eq i1->iflg.i
				    and same_REGorI(REG, ti2->arg, areg)	/* Rn */
				    and ti2->reg ne reg						/* Rx */
				   )
				{
					ti2->arg->areg = reg;
					uprefs(ti2);
					PDBG(ti2, p2_17);
					return true;
				}

				temp |= ti2->rset;
				if (temp & (RM(reg)|RM(areg)))		/* Rm or Rn set */
					break;
			}
		}

		/*	for argregs
		 *	sva.x Rm Rn								move d0,d3
		 *	... stuff ...
		 *	sto.x Rn <ea> =>  sto.x Rm <ea>			move d3,<ea> => move d0,<ea>
		 *
		 *	where "stuff" doesn't set Rm or Rn
		 *
		 *	want to get rid of Rn which may be a only once used regarg
		 *  then we can also get rid of the movem, or part of it.
		 */

		if (MO(am1) eq REG )
		{
			RMASK temp = 0;

			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (    ti2->opcode eq STO
				    and ti2->sz     eq i1->sz
				    and ti2->iflg.i eq i1->iflg.i
				    and ti2->reg    eq areg				/* Rn */
				    and ti2->reg    ne reg				/* Rx */
#if AMFIELDS
					and !(    (   ti2->arg->am.f.inc
					           or ti2->arg->am.f.dec
					          )
#else
				    and !(    (ti2->arg->am & (INC|DEC)) ne 0
#endif
				          and  ti2->arg->areg eq reg
				         )
				   )
				{
					ti2->reg = reg;
					uprefs(ti2);
					PDBG(ti2, p2_16);
					return true;
				}

				temp |= ti2->rset;
				if (temp & (RM(reg)|RM(areg)))		/* Rm or Rn set */
					break;
			}
		}

		/*      after registerization simplify dereferencing
		 *	NEW:	for arg							IXC
		 *
		 *	move.l	Am, An	=>	move.l	Am, An		sva.l Am  An
		 *	... stuff ...		... stuff ...
		 *	op.x  ...An...		op.x	...Am...	op.x  X   ..An..
		 *											op.x	  ...An,....
		 *	where "stuff" doesn't set Am or An
		 *	..An.. has no side effects
		 *  The second instr may itself set An via reg
		 */
		if (    i1->sz eq DOT_L
			and ISA(reg)
			and is_areg(am1, areg)
			)
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				RMASK mask = RM(reg) | RM(areg);
				OPND *arg2 = ti2->arg;

				if (arg2)
				{
					if (   is_regi_or_d(arg2)
						and arg2->areg eq areg
						)
					{
						arg2->areg = reg;
						PDBG(ti2, p2_10);
						uprefs(ti2);
						return true;
					}
				}

				if (ti2->rset & mask)
					break;
			}
		}

		/*	NEW:	for dst							IXC
		 *
		 *	move.l	Am, An	=>	move.l	Am, An		sva.l Am  An
		 *	... stuff ...		... stuff ...
		 *	op.x  ...An...		op.x	...Am...	op.x  X   ..An..
		 *											op.x	  .....,An..
		 *	where "stuff" doesn't set Am or An
		 *	..An.. has no side effects
		 */
		if (    i1->sz eq DOT_L
			and ISA(reg)
			and is_areg(am1, areg)
			)
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (ti2->rset & RM(reg))
					break;
				if (ti2->rset & RM(areg))
					break;
				if (ti2->arg)
				{
					OPND *dst2 = ti2->arg->next;
					if (dst2)
					{
						if (    is_regi_or_d(dst2)
							and dst2->areg eq areg
							)
						{
							dst2->areg = op1 eq LDX ? areg : reg;
							PDBG(ti2, p2_11);
							uprefs(ti2);
							return true;
						}
					}
				}
			}
		}

	}
	break;

#if COLDFIRE
	case LMX:
	{
		/* 	After lea area
		 *
		 *	lmx *a  *b.d		=>	delete
		 *  inst Xn *a.				inst Xn *b.d
		 */


		 if (   (MO(am1) eq REGI or MO(am1) eq REGID)
		     and MO(i2->arg->am)  eq REGI
		     and i2->arg->areg eq reg
		    )
		 {
			OPND *dst = i2->arg->next;
			i2->arg = i1->arg;
			i2->arg->next = dst;
			i1->arg = nil;
			uprefs(i2);
			delinst(bp, i1);
			PDBG(i2, p2_lmx);
			return true;
		 }
	}
	break;
#endif

	case LAX:
	{
		/*											IXC
		 *	lea	   <ea>, An		=>	lea	<ea>, Am	lax   An  <ea>	=>	lax Am  <ea>
		 *	move.l   An, Am							ldx.l Am  An
		 *
		 *	where An is dead
		 */
		if (    op2 eq LDX
			and MO(i2->arg->am) eq REG
			and i2->arg->areg  eq reg
			and ISA(i2->reg)
			and i2->sz eq DOT_L
			)
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i1->reg = i2->reg;
				uprefs(i1);
				delinst(bp, i2);
				PDBG(i1, p2_13);
				return true;
			}
		}

		/*											IXC
		 *	lea	   <ea>, An		=>	lea	<ea>, Am	lax   An  <ea>	=>	lax Am  <ea>
		 *	move.l   An, Am							sva.l An  Am
		 *
		 *	where An is dead
		 */
		if (    (op2 eq SVA or op2 eq STO)
			and MO(i2->arg->am) eq REG
			and ISA(i2->arg->areg)
			and i2->reg  eq reg
			and i2->sz eq DOT_L
			)
		{
			if ((i2->live & RM(reg)) eq 0)
			{
				i1->reg = i2->arg->areg;
				uprefs(i1);
				delinst(bp, i2);
				PDBG(i1, p2_14);
				return true;
			}
		}

		/* ( push pointer arg )					IXC
		 *
		 *	lea 	...,An						lax   An  ...	=>	pea      ...
		 *  move.l	An,-(A7)	=>	pea	...		psh.l     An
		 *									or  pea       An.
		 *	Where An is dead after the push
		 *
		 *		all <ea>'s that can be lea'd can also be pea'd
		 */
		if (   (	op2 eq PSH
				and i2->sz eq DOT_L
				and same_REGorI(REG,  i2->arg, reg)
			   )
			or (	op2 eq PEA
			    and same_REGorI(REGI, i2->arg, reg)
			   )
			)
		{
			if (  (i2->live & RM(reg)) eq 0 )
			{
				i1->reg    = -1;
				i1->opcode = PEA;

				uprefs(i1);
				delinst(bp, i2);
				PDBG(i1, p2_18);
				return true;
			}
		}

		/*	(modified by hd)						IXC
		 *
		 *	lea	N(Am), An	=>						lax  An  Am.N
		 *	?	(An)[,...]       ?	N(Am)[,...]		?    X   An. ?	=>  ?  X  Am.N ?
		 *
		 *	Where An is either dead after the second instruction or
		 *	is a direct destination of the second instruction.		*)
		 */
		if (    MO(am1) eq REGID
			and same_REGorI(REGI, i2->arg, reg)
			)
		{
			if (   (i2->live & RM(reg)          ) eq 0
				or (i2->rset & RM(i2->arg->areg)) ne 0
				)
			{
				if (!double_ref(i2))
				{
					OPND *dst = i2->arg->next;
					i2->arg = i1->arg;
					i2->arg->next = dst;
					i1->arg = nil;
					uprefs(i2);
					delinst(bp, i1);
					PDBG(i2, p2_19);
					return true;
				}
			}
		}

		/*  for arg
		 *
		 *  lax An X
		 *			stuff that doesnt mingle
		 *  .....   An.,  ....		=>  ..... X, ....
		 *  where An is dead
		 */

		for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
		{
			if (same_REGorI(REGI, ti2->arg, reg))
			{
#if COLDFIRE && FLOAT
				if (!(    G.Coldfire
				      and ti2->sz eq DOT_D
				      and (   MM(am1) eq ABS
				           or MM(am1) eq REGIDX
				          )
				     )
				   )
#endif
					if (   (ti2->live & RM(reg) ) eq 0
						and !double_ref(ti2)
					   )
					{
						OPND *dst = ti2->arg->next;

						ti2->arg = i1->arg;
						ti2->arg->next = dst;
						i1->arg = nil;
						uprefs(ti2);
						delinst(bp, i1);
						PDBG(i2, p2_alea);
						return true;
					}
			}
			if (ti2->rref & RM(reg))		/* must not ref the lax's reg */
				break;
			if (ti2->rset & i1->rref)		/* must not set anything the lea refs */
				break;
		}

		/*  for dst
		 *
		 *  lea X, An
		 *			stuff that doesnt mingle
		 *  .....   ...,An.		=>  ..... ....,X
		 *  where An is dead
		 */

		for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
		{
			if (i2->arg)
			{
				if (i2->arg->next)
				{
					OPND *dst = i2->arg->next;

					if (same_REGorI(REGI, dst, reg))
					{
#if FLOAT && COLDFIRE
						if (!(    G.Coldfire
						      and ti2->sz eq DOT_D
						      and (   MM(am1) eq ABS
						           or MM(am1) eq REGIDX
						          )
						     )
						   )
#endif
							if (   (i2->live & RM(reg)         ) eq 0
							    and !double_ref(i2)
							   )
							{
								i2->arg->next = i1->arg;
								i1->arg = nil;
								uprefs(i2);
								delinst(bp, i1);
								PDBG(i2, p2_dlea);
								return true;
							}
					}
				}
			}
			if (ti2->rref & RM(reg))		/* must not ref the lax's reg */
				break;
			if (ti2->rset & i1->rref)		/* must not set anything the lea refs */
				break;
		}

		/*
		 *	lea	N(Am), An	=>	lea	N(Am,Do.s), An
		 *	add.s	Do, An
		 *
		 *	IXC
		 *
		 *	lax   An   Am.N	=>  lax An  (Am,Do.s)N
		 *	adx.s An   Do
		 */
		if (    op2 eq ADX
			and MO(am1) eq REGID
			and i2->arg
		    and i2->arg->am eq REG
		    and ISD(i2->arg->areg)
		    and ISA(i2->reg)
		    and i2->reg eq reg
		    and D8OK(arg->disp)
		    )
		{
			MO(i1->arg->am) = REGIDX;
			if (i2->sz eq DOT_L)
#if AMFIELDS
				i1->arg->am.f.xl = 1;
#else
				i1->arg->am |= XLONG;
#endif
			i1->arg->ireg = i2->arg->areg;

			uprefs(i1);
			delinst(bp, i2);
			PDBG(i1, p2_20);
			return true;
		}
	}
	break;

	case ADX:
	{
	/*
	 * Try to use register indirect w/ displacement and/or index
	 */
	 	/*	for arg
	 	 *
	 	 *  add   #x,An			delete				adx An #x
	 	 *  ...   An,...	==> ... x(An),...		...  An,...   ==> ... An.x,...
	 	 *
	 	 *  Where An is dead
	 	 */

		if (    MO(am1) eq IMM
		    and ISA(reg)
		    and i2->arg
		    and i2->arg->areg eq reg
		   )
		{
			OPMODE am2 = i2->arg->am;
			if ((i2->live & RM(reg)) eq 0)
			{
				if (disp_ok(am2, i2->arg, arg))
				{
					i2->arg->disp += arg->disp;
					if (MO(am2) eq REGI)
						MO(i2->arg->am) = REGID;
					uprefs(i2);
					delinst(bp, i1);
					PDBG(i2, p2_30);
					return true;
				}
			}
		}

	 	/*	for dst
	 	 *
	 	 *  add   #x,An			delete				adx An #x
	 	 *  ...   ...,(An)	==> ... ...,x(An)		...  ...,An.   ==> ... ...,An.x
	 	 *
	 	 *  Where An is dead
	 	 */

		if (    MO(am1) eq IMM
		    and ISA(reg)
		    and i2->arg
		   )
		{
			if (i2->arg->next)
			{
				OPND *dst = i2->arg->next;
				if (dst->areg eq reg)
				{
					OPMODE am2 = dst->am;
					if ((i2->live & RM(reg)) eq 0)
					{
						if (disp_ok(am2, dst, arg))
						{
							dst->disp += arg->disp;
							if (MO(am2) eq REGI)
								MO(dst->am) = REGID;
							uprefs(i2);
							delinst(bp, i1);
							PDBG(i2, p2_31);
							return true;
						}
					}
				}
			}
		}

		/*
		 *  for arg
		 *	adx.s  An   Dm
		 *        stuff that doesnt use An or modifies Dm
		 *	.........   An.		=> ....... (An,Dm.s)
		 *
		 *	where An is dead or i2 sets An
		 *
		 */
		if (    MO(am1) eq REG
			and ISD(areg)
			and ISA(reg)
		   )
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (ti2->arg)
				{
					OPND *arg2 = ti2->arg;
#if 1
					if (p2_4ab(arg2, reg))
#else
				    if (    ISA(arg2->areg)
						and arg2->areg eq reg
						and (   arg2->am eq REGI
							 or (    arg2->am eq REGID
							     and arg2->disp > -127
							     and arg2->disp <  128
							    )
							)
					   )
#endif
					{
						if ((   (ti2->live & RM(reg)) eq 0
							 or (    ti2->opcode eq LDX
								 and ti2->reg eq reg		/* ldx An An. */
							    )
							 )
#if FLOAT && COLDFIRE
						     and !(G.Coldfire and is_f(ti2))
#endif
							)
						{
							do_p2_4(false, arg2, areg, i1, ti2, bp);
							return true;
						}
					}
				}

				if (ti2->rref & RM(reg))		/* the address register of add Dn,An */
					break;
				if (ti2->rset & RM(areg))		/* the data register of add Dn,An */
					break;
			}
		}

		/*
		 *  for dst
		 *	adx.s  An   Dm		=> ....... (An,Dm.s)
		 *        stuff that doesnt modify An and Dm
		 *	.........   ..., An.
		 *
		 *	where An is dead or i2 sets An
		 */
		if (    MO(am1) eq REG
			and ISD(areg)
			and ISA(reg)
		   )
		{
			for (ti2 = i2; ti2 ne nil; ti2 = ti2->next)
			{
				if (ti2->arg)
				{
					OPND *arg2 = ti2->arg->next;		/* destination */

					if (arg2)
					{
#if 1
						if (p2_4ab(arg2, reg))
#else
					    if (    ISA(arg2->areg)
							and arg2->areg eq reg
							and (   arg2->am eq REGI
								 or (    arg2->am eq REGID
								     and arg2->disp > -127
								     and arg2->disp <  128
								    )
								)
						   )
#endif
						{
							if ((   (ti2->live & RM(reg)) eq 0
								 or (   ti2->opcode eq LDX
								 	and ti2->reg eq reg		/* ldx An An. */
								    )
								 )
#if FLOAT && COLDFIRE
						     and !(G.Coldfire and is_f(ti2))
#endif
							   )
							{
								do_p2_4(true, arg2, areg, i1, ti2, bp);
								return true;
							}
						}
					}
				}
				if (ti2->rref & RM(reg))		/* the address register of add Dn,An */
					break;
				if (ti2->rset & RM(areg))		/* the data register of add Dn,An */
					break;
			}
		}
	}

	break;
	case SBX:
	/*
	 * Try to use the pre-decrement modes whenever possible.
	 */

		/*	IXC
		 *
		 *	sbx  Am   #S
		 *	... stuff ...
		 *	???.S  ..Am. ...
	 	 *	Nothing in "stuff" may use Am.   *hd*
		 */
		if (    ISA(reg)
			and MO(am1) eq IMM
			and (   arg->disp eq DOT_B
				 or arg->disp eq DOT_W
				 or arg->disp eq DOT_L
				 or arg->disp eq DOT_D
				 or arg->disp eq DOT_X
			    )
			)
		{
			ti2 = i2;
			do
			{
				OPND *arg2 = ti2->arg;

				if (arg2)
				{
					OPND *dst2 = ti2->arg->next;

					if (same_REGorI(REGI, arg2, reg))
					{
						if (ti2->sz ne arg->disp)
							break;
#if AMFIELDS
						arg2->am.f.dec = 1;
#else
						arg2->am |= DEC;
#endif
						uprefs(ti2);
						delinst(bp, i1);
						PDBG(ti2, p2_22);
						return true;
					}

					if (dst2)
					{
						if (same_REGorI(REGI, dst2, reg))
						{
							if (ti2->sz ne arg->disp)
								break;

#if AMFIELDS
							dst2->am.f.dec = 1;
#else
							dst2->am |= DEC;
#endif
							uprefs(ti2);
							delinst(bp, i1);
							PDBG(ti2, p2_25);
							return true;
						}
					}
				}

				if (p2_uses(ti2, reg))
					break;

				ti2 = ti2->next;
			} while (ti2);
		}
	break;

	}
	return false;
}

#if P2_20
	/* (compiler generates more suitable code for indexing multidimension rows)
	 *  adx.l  An D0			==>         weg
	 *  ... stuff that doesnt use An or D0 or D1
	 *           			insert      adx   D0  D1
	 *	adx.l  An D1 		    ==>		adx   An  D0
	 *
	 * 				eventually you can converge to something like:
	 *						op.x   (base, D0)   if for 68020
	 *					because the original An is not changed anymore
	 *					you can also delete the lax base or ldx #base
	 */
#endif

/*
 * peep2(bp) - scan blocks starting at 'bp'
 */
global
bool peep2(BP bp)
{
	IP ip;
	bool	changed = false;

	while(bp)
	{
		ip = bp->first;
		while(ip and ip->next)
		{
			if (ipeep2(bp, ip ))
			{
				changed = true;
				s_peep2++;
				/*
				 * If we had a match, then either instruction
				 * may have been deleted, so the safe thing to
				 * do is to go to the next block.
				 */
				break;
			}
			ip = ip->next;
		}
		bp = bp->next;
	}
	return changed;
}
