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

/* This file is experimental: it replaces tony.h
 * and tries to be as fast (but good) as scan_live
 *   (my version of health())
 */

extern BP  fhead;			/* head of the current function */

static
void fprep(BP bp)
{
	
	while (bp)
	{
		IP ip = bp->first;
		RMASK ref = 0, set = 0;

		while (ip)
		{
/* 05'16 HR v5.4: reg_ref performed on each singular change of a instruction */
			ref |= ip->rref & ~set;
			set |= ip->rset;
			ip = ip->next;
		}

		bp->rref = ref;
		bp->rset = set;

		bp = bp->next;
	}
}

RMASK scan_ref(BP bp, short lvl); /* recursion */
RMASK scan_dc (BP bp, short lvl);

/*
 * Scan(bp) - Which regs are live at the end of block 'bp'
 *
 * Look ahead through the traversal graph to see what might happen to the
 * given register. If we can find any reachable block that references any reg
 * before setting it, the register(s) ar live.
 */

/* 05'16 HR: considerably reduced speed by handling all (24) regs
 * in a single swoop by using OR operation on ref and set bits.
 * (Compare with tony.h file)
 */

static
RMASK Scan(BP bp, short lvl)
{
	RMASK live = 0;
	
	if (bp)
	{
		bp->bflg.mark=1;
		live = bp->rref;
		live |= scan_ref(bp->cond, lvl);
		live |= scan_ref(bp->fall, lvl);
		live |= scan_dc (bp      , lvl);
	}
	
	return live;
}

static
RMASK scan_dc(BP bp, short lvl)
{
	RMASK live = 0;
	IP ip = bp->first;

	while (ip)
	{
		if (   ip->opcode eq DCS
			or ip->opcode eq JSL
		   )
			if (ip->arg)
				live = scan_ref(getsym(ip->arg->astr), lvl+1);

		ip = ip->next;
	}

	return live;
}

static
RMASK scan_ref(BP bp, short lvl)
{
	RMASK live = 0;

	if (bp)
	{
		live = bp->rref;
		if (!bp->bflg.mark and !bp->bflg.ret)
			live = Scan(bp, lvl+1);
	}
	return live;
}

/*
 * bflow() - live/dead analysis for a given block
 *
 * Work backward from the end of the block, checking the status of registers.
 * To start with, figure out the state of registers as of the end of the
 * block. Then work backward.
 */

static
void bflow(BP bp)
{
	RMASK live; IP ip = bp->last;
	
	unmark(fhead);	/*  Clear all the mark bits */

	/*
	 * Figure out what's alive at the end of this block.
	 */
	live = Scan(bp, 0);

	/*
	 * Now work through the instructions in the block.
	 */
	while (ip)
	{
		if ((idata[ip->opcode].iflag&USG) eq 0)
		{
			anywhere_used |= ip->rref | ip->rset;
			anywhere_set  |= ip->rset;
		}

		ip->live = live;
		live = (live & ~ip->rset) | ip->rref;

		ip = ip->prior;
	}

	flows++;
}

global void
#if TONY == 2
	rhealth(BP bp)
#else
	Thealth(BP bp)
#endif
{
	anywhere_used = 0;
	anywhere_set  = 0;

	fprep(bp);

	while (bp)
	{
		bflow(bp);

		bp = bp->next;
	}

	peep_loops++;
}