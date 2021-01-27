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
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "param.h"

#include "opt.h"

/* usefull for looking beyond blocks */
globalRMASK anywhere_used, anywhere_set;

#if OPTBUG
void pusage(IP ip, short level)
{
	Cstr pascode(short tok), mask_to_s(RMASK);
	send_msg("%d>%s \tR:%s", level, pascode(ip->opcode), mask_to_s(ip->rref));
	send_msg("\tS:%s", mask_to_s(ip->rset));
	send_msg("\tL:%s\n", mask_to_s(ip->live));
}
#endif

static
void unmark(BP bp)
{
	while (bp)
		bp->bflg.mark = 0,
		bp = bp->next;
}

#if TONY
	/* HR: Tony's original v1.2 is extreeeemely non linear :-(
	   On the file icon.c (62Kb) of Teradesk rhealth
	   took 40 times longer.
	   Tony's took 20 seconds, mine only 0.5 sec.
	   Between he two methods can be switched dynamically.
	   check AH5 button in the KIT or pass option -t to the TTP version.
	   The purpose of this option is to revert to the old 
	   (mine) code.
	   if AHCC is compiled with TONY = 0, TONY_H's code is not
	   implemented at all, so the slightly failed fast code is
	   always used. Works OK for AHCC itself.
	   if AHCC is compiled with TONY == 2, only TONY_H's code will be used.
	*/

#include TONY_H

#endif


/* Replaced all of the original Sozobon health.c
   (functions: fprep, scan_ref, is_live & bflow)
   by a single recursive function (scan_live).

   It does everything at the correct time at the correct
   place and all looks now even intelligeable ;-)

   This was made possible by updating the instructions reg usage
   when a inst is read and only when a inst is changed.
 */

RMASK scan_live(BP bp, short level);		/* recursion */

static
RMASK scan_refs(BP bp, RMASK live, short level)
{
	RMASK bl_rref = 0, bl_rset = 0;

	IP ip = bp->last;
	while (ip)
	{
		if ((idata[ip->opcode].iflag&USG) eq 0)
		{
			Cstr pascode(short tok);
			anywhere_used |= ip->rref | ip->rset;
			anywhere_set  |= ip->rset;
		}

		if (   ip->opcode eq DCS
			or ip->opcode eq JSL)
		{
			if (ip->arg)
			{
				BP rp = getsym(ip->arg->astr);
				if (rp)
				{
					scan_live(rp, level+1);
					live |= rp->live;
				}
			}
		}

		ip->live = live;
		live = (live & ~ip->rset) | ip->rref;

		bl_rref |= ip->rref;
		bl_rset |= ip->rset;

		ip = ip->prior;
	}

#if 0
	bp->live |= live;
#else
	bp->live = live;
#endif
	bp->live = live;
	bp->rref = bl_rref;
	bp->rset = bl_rset;
	return live;
}

static
RMASK scan_live(BP bp, short level)	/* 05'16 HR v5.4 returns RMASK for later convenience, not used yet */
{
	RMASK live = 0;
	BP fb, cb;

	if (bp)
	{
		bool marked = bp->bflg.mark;

		bp->bflg.mark = 1;

		cb = bp->cond;
		fb = bp->fall;

		if (!bp->bflg.ret)
		{
			if (cb)
			{
				if (!marked)
					scan_live(cb, level+1);
#if DBGB
				send_msg("%d>cond %s(%d)\n", level, cb->name, cb->bn);
#endif
				live |= cb->live;
			}

			if (fb)
			{
				if (!marked)
					scan_live(fb, level+1);
#if DBGB
				send_msg("%d>fall %s(%d)\n", level, fb->name, fb->bn);
#endif
				live |= fb->live;
			}
		}

/* Work backward from the end of each block, checking the status of registers.
 * To start with, figure out the state of the registers as of the end of the
 * block.
 */
/*		live is state at end of block */
		live |= scan_refs(bp, live, level);
	}

	return live;		/* 05'16 HR v5.4 (not used yet) */
}

/* N.B. !!! There must always be a TONY with a value */
#if TONY == 1
static void Mhealth(BP bp)		/* My original health */
{
	unmark(bp);
	anywhere_used = 0;
	anywhere_set  = 0;
/* console("My health!!!!\n"); */
	scan_live(bp, 0);
	peep_loops++;
}

global
void rhealth(BP bp)
{
/* has_loop set by bfix() */
	if (  G.at_Tony
	   or bp->bflg.has_loop
	 )
		Thealth(bp);
	else
		Mhealth(bp);
}
#elif TONY == 0
global
void rhealth(BP bp)
{
	unmark(bp);
	anywhere_used = 0;
	anywhere_set  = 0;
	scan_live(bp, 0);
	peep_loops++;
}
#endif
