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

/*
 * ipeep3(bp, ip) - look for 3-instruction optimizations at the given inst.
 */
static bool
ipeep3(BP bp, IP i1)
{
	IP i2 = i1->next, 		/* the next instruction */
	   i3 = i1->next->next;	/* the third instruction */

	ASMOP op2 = i2->opcode,
	      op3 = i3->opcode;
	short reg = i1->reg,
	      areg = -1;

	OPMODE am;

	MO(am) = NONE;
	
	if (i1->arg)
	{
		am   = i1->arg->am;
		areg = i1->arg->areg;
	}

#if 0
#include "wegp3.h"			/* obsoleted optimization */
#endif

	/*
	 *	move.l	X, Dm		=>	move.l	X, An
	 *	INST					INST
	 *	move.l	Dm, An			...deleted...
	 *
	 *	IXC:
	 *
	 *	ldx.l  Dm   X		=>	ldx.l  An   X
	 *	INST					INST
	 *	ldx.l  An   Dm			...delete...
	 *
	 *	where INST doesn't use Dm or An, and Dm is dead after i3
	 */
	if (    op3 eq LDX
		and i3->arg
		and i1->sz     eq i2->sz
		and i1->iflg.i eq i2->iflg.i
	    and ISD(reg)
	    and (MO(i3->arg->am) eq REG)
	    and (i3->arg->areg  eq reg)
	    and ISA(i3->reg)
	    and !p2_uses(i2, reg)
	    and !p2_uses(i2, i3->reg)
	   )
	{
		if ((i3->live & RM(reg)) eq 0)
		{
			i1->reg = i3->reg;

			uprefs(i1);
			delinst(bp, i3);
			PDBG(i2, p3_1);
			return true;
		}
	}

#if 0
	/* optimize unary operations after registerization
	 *	ldx  X   X1       =>  unop X1
	 *  unop X
	 *  ldx  X1  X
	 *    where X is dead
	 */
	{
		IDATA *id = &idata[i2->opcode];

		if (    (id->iflag & SX) and op3 eq LDX
		    and i1->sz eq i2->sz      and i2->sz eq i3->sz
			and MO(i1->arg->am) eq REG and MO(i3->arg->am) eq REG
		   )
		{
		    if (id->argf eq 0)
		    {
				if (
				        i1->reg       eq i2->reg
				    and i3->arg->areg eq i2->reg
				    and i1->arg->areg eq i3->reg
				    and (i3->live & RM(i2->reg)) eq 0
				   )
				{
					i2->reg = i3->reg;
					uprefs(i2);
					delinst(bp, i1);
					delinst(bp, i3);
					PDBG(i2, p3_5);
					return true;
				}
			}
			else
			{
				if (
				        i1->reg       eq i2->arg->areg
				    and i3->arg->areg eq i2->arg->areg
				    and i1->arg->areg eq i3->reg
				    and (i3->live & RM(i2->arg->areg)) eq 0
				   )
				{
					i2->arg->areg = i3->reg;
					uprefs(i2);
					delinst(bp, i1);
					delinst(bp, i3);
					PDBG(i2, p3_5);
					return true;
				}
			}
		}
	}
#endif

	/*	Try to use post-increment where possible
	 *
	 *	move.l	Am, An			...deleted...
	 *	addq.l	#1, Am			...deleted...
	 *	... stuff ...			... stuff ...
	 *	???.b	..(An)..	=>	???.b	..(Am)+..
	 *
	 *	IXC:
	 *
	 *	ldx.l  An    Am
	 *	adx.l  Am    #S || lax   Am   Am.S
	 *	... stuff ...
	 *	???.S   ... An. ...		=>	???.S   ... Am+ ...
	 *	An must be dead after the last instruction. Nothing in
	 *	"stuff" can modify Am.
	 */
	if (    i1->sz eq DOT_L
	    and is_areg(am, areg)
	    and ISA(reg)
	    and i2->arg
	   )
	{
		OPND *arg2 = i2->arg;

		if (	(   (    op2 eq ADX
				     and MO(arg2->am) eq IMM
			        )
			    or  (    op2 eq LAX
			         and MO(arg2->am) eq REGID
			         and i2->reg eq arg2->areg

			        )
			    )
		    and i2->reg eq areg
	        and (   arg2->disp eq DOT_B
	             or arg2->disp eq DOT_W
	             or arg2->disp eq DOT_L
	             or arg2->disp eq DOT_D
	             or arg2->disp eq DOT_X
	            )
		   )
		{
			while (i3)
			{
				OPND *arg3 = i3->arg;

				if (p2_sets(i3, areg))
					break;

				if (arg3)
				{
					OPND *dst3 = i3->arg->next;

					if (	MO(arg3->am) eq REGI
						and arg3->areg  eq reg )
					{
						if (i3->live & RM(reg))
							break;

						if (i3->sz ne arg2->disp)
							break;

#if AMFIELDS
						arg3->am.f.inc = 1;
#else
						arg3->am |= INC;
#endif
						arg3->areg = areg;
						uprefs(i3);
						delinst(bp, i1);
						delinst(bp, i2);
						PDBG(i3, p3_2);
						return true;
	/* cant do this twice */
					}

					if (dst3)
					{
						if (	MO(dst3->am) eq REGI
							and dst3->areg  eq reg)
						{
							if (i3->live & RM(reg))
								break;

							if (i3->sz ne arg2->disp)
								break;

#if AMFIELDS
							dst3->am.f.inc = 1;
#else
							dst3->am |= INC;
#endif
							dst3->areg = areg;
							uprefs(i3);
							delinst(bp, i1);
							delinst(bp, i2);
							PDBG(i3, p3_3);
							return true;
						}
					}
				}

				i3 = i3->next;
			}
		}
	}

#if 0
#include "p3_4.h"		/* Not ready */
#endif

	return false;
}

/*
 * peep3(bp) - scan blocks starting at 'bp'
 */
global
bool peep3(BP bp)
{
	IP ip;
	bool changed = false;

	while (bp)
	{
		ip = bp->first;
		while (ip)
		{
			if (ip->opcode eq LDX and ip->arg)		/* all peep3's start with LDX */
			{
				if (ip->next and ip->next->next)
					if (ipeep3(bp, ip))
					{
						s_peep3++;
						changed = true;
						/*
						 * If we had a match, then any instruction
						 * could have been deleted, so the safe thing
						 * to do is to go to the next block.
						 */
						break;
					}
			}
			ip = ip->next;
		}
		bp = bp->next;
	}

	return changed;
}
