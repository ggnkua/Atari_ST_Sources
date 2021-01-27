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
 * Optimizer integrated in the compiler.
 *     do all context free single inst transformations
 *            in 1 swoop (without exiting)
 *     to be called once after registerization.
 *     Try to reduce the peep_loops and hence the number
 *     of rhealth() calls.
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "param.h"

#include "out.h"
#include "opt.h"
#include "peep.h"
#include "inst.h"

/*
 * ipeep0(ip) - check for changes to the instruction 'ip'
 */

staticOPND nullopnd = {0};

global
bool ipeep0(BP bp, IP ip)
{
	short reg, areg = -1, op1 = ip->opcode;
	IDATA *id = &idata[op1];
	OPND  *arg,
	      *dst;
#if AMFIELDS
	OPMODE am;
	
	am.i = NONE;
#else
	short am = NONE;
#endif

	if (ip->arg)
	{
		if (ip->arg->next)
			dst = ip->arg->next;
		else
			dst = &nullopnd;
		arg = ip->arg;
		MO(am) = MO(arg->am);
		areg = arg->areg;
	}
	else
		arg = dst = &nullopnd;

	reg = ip->reg;

	if (   op1 eq MOV
#if COLDFIRE
	    or op1 eq M3Q
#endif
	    )
	{
		/*		after registerizing
		 *
		 *		mov.s     Dn,Dm			move.s     Dn,<ea>
		 *
		 *	==> ldx  Dm  Dn			==> sto   Dn   <ea>
		 *
		 */

		if (    MO(am) eq REG
			and dst
		   )
		{
			if (MO(dst->am) eq REG)
			{
				ip->opcode = LDX;
				ip->reg = dst->areg;
				ip->arg->next = nil;
				uprefs(ip);
				PDBG(ip, p0_1);
			othw
				ip->opcode = STO;
				ip->reg = areg;
				ip->arg = ip->arg->next;
				ip->arg->next = nil;
				uprefs(ip);
				PDBG(ip, p0_2);
			}
		    return true;
		}

		/*		after registerizing
		 *
		 *		mov.s     <ea>,Dn
		 *
		 *	==> ldx Dn  <ea>
		 *
		 */

		if (    dst
			and MO(dst->am) eq REG
			)
		{
			ip->opcode = LDX;
			ip->reg = dst->areg;
			ip->arg->next = nil;
			uprefs(ip);
			PDBG(ip, p0_3);
		    return true;
		}
	}

	/*		imm to <ea> that is a R
	 *					after registerizing
	 *
	 *  ..i #N,Rn		==> ..x  Rn  #N
	 *
	 */

	if (    op1 >= ORI
	    and op1 <= ADI
	    and dst
		and MO(dst->am) eq REG
	   )
	{
		ip->opcode -= ORI;
		ip->opcode *= 2;
		ip->opcode += ORX;
		ip->reg = dst->areg;
		ip->arg->next = nil;
		uprefs(ip);
		PDBG(ip, p0_4);
	    return true;
	}

	if (id->dstf)
		return false;			/* no more optimizations for dst */

	if (ip->arg eq nil)				/* must have arg */
		return false;

	if (    op1 eq ADX
	    and MO(am) eq IMM
	    and arg->disp < 0
	   )
	{
		ip->opcode = SBX;
		ip->arg->disp = -ip->arg->disp;
		uprefs(ip);
		PDBG(ip, p0_5);
		return true;
	}

	/*
	 *  adx.x  Am #n		   lax  Am   Am.n
	 *
	 * where 'n' is a valid displacement
	 */
	if (    op1 eq ADX
		and MO(am) eq IMM
		and ISA(reg)
		and  D16OK (arg->disp)
		and !D3OK(arg->disp)
		)
	{
		ip->opcode = LAX;
		ip->sz = 0;
		MO(ip->arg->am) = REGID;
		ip->arg->areg = reg;
		uprefs(ip);
		PDBG(ip, p0_11);
		return true;
	}

	/*
	 *	..s Dx Dy		==> ..x Dy Dx
	 * store instruction that have <ea> Dn complement.
	 * Exchange reg & arg, & change to complement (..x version)
	 */

	if ((id->iflag & REVDD) ne 0)
	{
		if (	MO(am) eq REG )
		{
			if (     (ISD(areg) and ISD(ip->reg))
			    and !(ISF(ip->reg) ne ISF(areg))
			   )
			{
				ip->opcode++;		/* ..s & ..x opcodes form pairs (see po_defs.h) */
				ip->reg = areg;
				ip->arg->areg = reg;
				uprefs(ip);
				PDBG(ip, p0_12);
			    return true;
			}
		}

	}

	/*
	 *	..s     Dy		==> ..x Dy
	 */

	if (    (id->iflag & REVD) ne 0
		and reg eq -1
		and MO(am) eq REG
		)
	{
		ip->opcode++;		/* ..s & ..x opcodes form pairs (see po_defs.h) */
		ip->reg = areg;
		ip->arg = nil;
		uprefs(ip);
		PDBG(ip, p0_13);
	    return true;
	}

	if (op1 eq TST and MO(am) eq REG)
	{
		ip->opcode = TSX;
		ip->reg = areg;
		ip->arg = nil;
		uprefs(ip);
		PDBG(ip, p0_tsf);
		return true;
	}

	/* tst    An  |  tsx  An  (after registerization) */
	if (!(G.i2_68020 or G.Coldfire))
	{
		if (    op1 eq TST
			and is_areg(am, areg)
		   )
		{
			ip->opcode = CPX;
			ip->reg = areg;
			MO(ip->arg->am) = IMM;
			ip->arg->disp = 0;
			uprefs(ip);
			PDBG(ip, p0_tst);
			return true;
		}

		if (    op1 eq TSX
			and ISA(reg)
		   )
		{
			ip->opcode = CPX;
			MO(ip->arg->am) = IMM;
			ip->arg->disp = 0;
			uprefs(ip);
			PDBG(ip, p0_tsx);
			return true;
		}
	}

	/*   (produced by tblindex)
	 *    ldx.l An   #SYMB 		=>		lax   An   SYMB
	 */

	if (    op1 eq LDX
		and ISA(reg)
#if AMFIELDS
		and am.f.m eq IMM
		and am.f.symb ne 0
#else
		and am eq (IMM|SYMB)
#endif
		)
	{
		ip->opcode = LAX;
		ip->sz = 0;
		MO(ip->arg->am) = ABS;
		uprefs(ip);
		PDBG(ip, p0_14);
	    return true;
	}

	/*    lax Am An.			=>		ldx.l	Am An
	 */

	if (    op1 eq LAX
	    and MO(am) eq REGI
	   )
	{
		ip->opcode = LDX;
		MO(ip->arg->am) = REG;
		ip->sz = DOT_L;
		uprefs(ip);
		PDBG(ip, p0_lea);
	    return true;
	}

	/*   ldx.l An   #0 		=>		clx.l   An
	 *
	 *			(the compiler doesnt produce other than .l)
	 */

	if (    op1 eq LDX
		and ISA(reg)
		and MO(am) eq IMM
		and arg->disp eq 0
		)
	{
		ip->opcode = CLX;		/* SBX not good for live/dead analysis !!!! */
		ip->sz = DOT_L;
		ip->arg = nil;
		PDBG(ip, p0_15);
	    return true;
	}

	return false;
}
/*
 * peep0(bp) - peephole optimizations with a window size of 1
 *             and no change of context


global
bool peep0(BP bp)
{
	bool  changed = false;

	while (bp)
	{
		IP ip = bp->first;
		while (ip)
		{
			changed |= ipeep0(bp, ip);
			ip = ip->next;
		}
		bp = bp->next;
	}
	return changed;
}
*/
