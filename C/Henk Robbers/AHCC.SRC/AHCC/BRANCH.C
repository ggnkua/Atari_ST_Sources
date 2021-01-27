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
 * branch optinixations.
 * Optimizer integrated in the compiler.
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "param.h"
#include "common/mallocs.h"
#include "common/qmem.h"
#include "common/amem.h"
#include "opt.h"

extern
MEMBASE opndmem;

#define error send_msg

/*
 * bcomp(bc) - return the complement of the given branch code
 *
 * Used when a branch reversal is needed.
 */
static
ASMOP bcomp(ASMOP bc)
{
	switch (bc)
	{
	case BHI: return BLS;
	case BLS: return BHI;
	case BCC: return BCS;
	case BCS: return BCC;
	case BVC: return BVS;
	case BVS: return BVC;
	case BPL: return BMI;
	case BMI: return BPL;

	case BNE: return BEQ;
	case BEQ: return BNE;
	case BGE: return BLT;
	case BLT: return BGE;
	case BGT: return BLE;
	case BLE: return BGT;

#if FLOAT
	case FBNE: return FBEQ;
	case FBEQ: return FBNE;
	case FBGE: return FBLT;
	case FBLT: return FBGE;
	case FBGT: return FBLE;
	case FBLE: return FBGT;
	#define HIGH_B FBLE
#else
	#define HIGH_B BMI
#endif
	default:
		error("OE: bcomp() - bad branch code %d\n", bc);
		return 0;
	}
}

/*
 * is_branch(s) - determines if c is a branch opcode
 *	Note that 'dbra' is not considered a branch; it uses the '*-2' operand
 */
static
short is_branch(ASMOP c)
{
/*	if (c eq DBF)					return 2;	  munges a reg */
	if (c >= BRA and c <= HIGH_B)	return 1;
									return 0;
}

/*
 * cblock(cp) - return the first block containing some code
 *
 * Starting with 'cp', find a block that has one or more instructions
 * in it. This is useful to collapse multiple null blocks into a single
 * logical point. This happens at points in the generated code where
 * there are multiple labels at the same logical location.
 */
static
BP cblock(BP bp)
{
	while (bp->first eq nil and bp->cond eq nil)
	{
		if (bp->fall eq nil)
		{
			error("OE: cblock() - error in block %s\n", bp->name);
			break;
		}
		bp = bp->fall;
	}

	return bp;
}

void upd_BC(BP cb)
{
	extern short BC;
	if (!cb->bn)
		cb->bn = ++BC;
#if DBGB
	send_msg("block '%s' = %d\n", cb->name, cb->bn);
#endif
}

/*
 * bsplit() - split up blocks with branches inside them
 *
 * Look for branch instructions in each block. If somewhere in the middle of
 * the block, split up the block. When done, the blocks are broken down into
 * true basic blocks.
 */
static
void bsplit(BP cp)
{
	BP np;	/* new block (if needed) */
	IP ip;	/* current instruction */

	extern short BC;
	BC = 0;
#if DBGB
	send_msg("\n");
#endif
	while (cp)
	{
		upd_BC(cp);
		ip = cp->first;
		while (ip)
		{
			if (is_branch(ip->opcode) and ip->next ne nil)
			{
				extern short tnum, BC;
				char *tname = CC_qalloc(&opndmem, 8, CC_ranout, AH_CC_BNAMES);

				sprintf(tname, "__%d", 10000+tnum++);

				np = mksym(tname);

				np->chain = cp->chain;
				cp->chain = np;

				np->next = cp->next;
				cp->next = np;

				np->first = ip->next;
				np->first->prior = nil;
				np->last = cp->last;

				cp->last = ip;
				cp->last->next = nil;
				upd_BC(np);
			}
			elif (   ip->opcode eq DCS
				  or ip->opcode eq JSL)

			{
				BP db;

				/*
				 * If the instruction is part of a branch
				 * table both the current block and the
				 * destination need to be marked as "reached".
				 */
				if (ip->arg)
				{
					db = getsym(ip->arg->astr);
					if (db ne nil)
						db->bflg.reached = 1;
					else
						error("OE: bsplit() - DC|JSL label '%s' not found\n", ip->arg->astr);
				}
				else
					error("OE: bsplit() - DC|JSL no operand\n");
			}
			ip = ip->next;
		}
		cp = cp->chain;
	}
}

/*
 * bfix() - fix up the branch pointers
 *
 * Go through each block setting up 'cond' and 'fall' properly. If the
 * last instruction in the block is an unconditional branch, remove it
 * and set 'fall' instead. The idea is that there should be no branch
 * instructions left when we're done. We remember the logical effect of
 * each branch, but reconstruct the branches later in a more optimal way.
 */
static
void bfix(BP cp)
{
	IP ip, lp;		/* current instruction */
	BP head = cp;

	while (cp)
	{
		lp = cp->last;

		if (cp->first eq nil)
		{						/* no instructions in the block */
			cp->cond = nil;
			cp->fall = cp->next;
		othw
			if (lp->opcode eq DCS)
				cp->bflg.swt = 1; /* the last instruction is a "dc" */
			elif (is_return(lp->opcode))
			{						 /* the last instruction is a "return" */
				cp->cond = nil;
				cp->fall = nil;
				cp->bflg.ret = 1;
			othw
				short isb = is_branch(lp->opcode);
				cp->fall = cp->next;

				if (isb eq 0)
				{				/* the last instruction isn't a branch */
					cp->cond = nil;
				othw
					/* If we reach this point, then we've got a branch we need
					   to remove at the end of this block.		*/
					cp->fall = cp->next;
					cp->opcode = lp->opcode;

					if (lp->arg)
					{
						cp->cond = getsym(lp->arg->astr);

						if (cp->cond eq nil)
#if OPTBUG
							error("OE %ld: no '%s' on '%s'\n",
								lp->snr, lp->arg->astr, idata[lp->opcode].text);
#else
							error("OE: no '%s' on '%s'\n",
								lp->arg->astr, idata[lp->opcode].text);
#endif
					}
					else
						cp->cond = nil;

					if (cp->opcode >= 0)
					{
						ip = cp->first;

						if (ip->opcode eq LOOP)
						{
							head->bflg.has_loop = 1;	/* 05'16 HR v5.4 */
							cp->bflg.loop = 1;
						}

						while (ip)
						{
							if (ip->next eq lp)
							{
								ip->next = nil;
								break;
							}
							if (ip->opcode eq JSL)
								cp->bflg.jsl = 1;
							ip = ip->next;
						}

						freeIunit(lp);

						if (cp->first eq lp)
							cp->first =nil,
							cp->last = nil;
						else
							cp->last = ip;
						/*
						 * If the branch was unconditional, we want to represent
						 * it as a "fall through", so fix the pointers to do that.
						 */

						/* 05'16 HR v5.4 */
						if   (cp->opcode >= BRA and cp->opcode <= BRF)
						{
							s_bdel++;
							cp->fall = cp->cond;
							cp->cond = nil;
						}

						if (cp->opcode eq BRB)
							head->bflg.has_loop = 1;	/* C: goto existing label (hence backward) */
					}
				}
			}
		}
		cp = cp->chain;
	}			/* while cp */
}

/*
 * bclean() - remove references to empty blocks
 *
 * Called after bsplit() and bfix().
 */
static
void bclean(BP cp)
{
	/*
	 * First clean up references to empty blocks
	 */
	while (cp)
	{
		if (cp->cond ne nil)
			cp->cond = cblock(cp->cond);
		if (cp->fall ne nil)
			cp->fall = cblock(cp->fall);
		cp = cp->chain;
	}

	/*
	 * Now there are generally blocks that are still linked by the
	 * 'chain' pointers, but no longer referenced through 'cond'
	 * or 'fall' pointers. They don't actually need to be deleted
	 * since they won't cause trouble anywhere else.
	 */
}

/*
 * bwalk() - recursive walk through the branch graph
 *
 * Starting at the entry point, walk through the block graph placing
 * blocks on the output list. By traversing the "fall" nodes first
 * we attempt to make blocks that fall through come in order so that
 * branches are minimized.
 *
 * Joe describes this process as "grabbing the tree at the top and
 * shaking".
 *
 * The 'lp' variable below maintains our position in the generated list
 * of blocks.
 */
static
BP lp;		/* pointer to the next block in the file */

static
void bwalk(BP pt)
{
	if (pt eq nil)
		return;
	if (pt->bflg.touched)
		return;

	pt->bflg.touched = 1;
	lp->next = pt;
	lp = lp->next;

	/*
	 * We should swap 'fall' and 'cond' and alter 'brt' IF:
	 *
	 * 1. Both fall and cond are non-null.
	 * 2. The branch is a simple one (not a DBcc inst.)
	 * 3. Branch reversals are enabled.
	 * 4. The block at fall has already been touched.
	 * 5. The block at cond hasn't been touched.
	 *
	 * In this case, we can avoid an extra branch if we reverse the
	 * sense of the conditional branch, and swap the pointers.
	 */

	if (    pt->fall ne nil
		and pt->cond ne nil
		and pt->opcode >= 0
		and !G.ab_no_branch_reversals
		and  pt->fall->bflg.touched
		and !pt->cond->bflg.touched
	   )
	{
		BP tmp;

		s_brev++;
    	tmp = pt->fall;
    	pt->fall = pt->cond;
    	pt->cond = tmp;

    	if ((pt->opcode = bcomp(pt->opcode)) < 0)
    		error("OE: top: internal error in bwalk()\n");
	}

	bwalk(pt->fall);
	bwalk(pt->cond);
}

/*
 * x() - branch optimization
 *
 * Initialize and terminate the 'next' pointers before and after
 * traversing the branch graph.
 */
static	void
bsort(BP bp)
{
	lp = bp;
	bwalk(bp);	/* traverse the tree starting at the entry point */

	/*
	 * Now look for other parts of the tree that don't appear to be
	 * reachable, but really are. This can happen through the jump
	 * tables created for switch statements. For each such block,
	 * walk the subtree starting with it.
	 */
	while (bp)
	{
		if (!bp->bflg.touched and bp->bflg.reached)
			bwalk(bp);
		bp = bp->chain;
	}
	lp->next = nil;
}

/*
 * bsetlab() - figure out which blocks really need labels
 *
 * This can be called AFTER bsort() to mark the blocks that are going to
 * need labels. Anything that we're going to branch to later gets a label.
 */
static
void bsetlab(BP bp)
{
	while (bp)
	{
		if (bp->cond ne nil)
			cblock(bp->cond)->bflg.label = 1;
		if (bp->fall ne nil and bp->fall ne bp->next)
			cblock(bp->fall)->bflg.label = 1;
		/*
		 * If the block is reached via a jump table, then we
		 * need a label on THIS block directly.
		 */
		if (bp->bflg.reached)
			bp->bflg.label = 1;
		bp = bp->next;
	}
}

/*
 * bjoin() - join blocks that always come together
 *
 * If block 'b' always follows block 'a' unconditionally, then move the
 * instructions in 'b' to the end of 'a', and remove 'b'. This allows us
 * to do better peephole optimization since we can optimize sequences that
 * used to span blocks.
 */
static
void bjoin(BP bp)
{
	BP np, bnext;

	while (bp)
	{
		bnext = bp->next;

		if (bp->cond eq nil)	/* First block can't end with a conditional branch. */
		{
			if (bp->next and bp->next eq bp->fall)
			{					/* Block must fall through to the next thing in the file. */
				np = bp->next;
				if (!np->bflg.label)
				{				/* Second block can't be the destination of a branch. */
					/*
					 * Join the blocks...
					 */
					if (np->first ne nil)
						np->first->prior = bp->last;

					if (bp->last ne nil)
						bp->last->next = np->first;
					else
						bp->first = np->first,
						bp->last  = np->last;

					if (np->bflg.ret)
						bp->bflg.ret = 1;

					bp->last    = np->last;
					bp->fall    = np->fall;
					bp->cond    = np->cond;
					bp->opcode  = np->opcode;
					bp->next    = np->next;
					np->first   = nil;
					np->last    = nil;

			/* If we've done a join, then we want to loop again on
			 * the current block to see if any others can be joined. */

					bnext = bp;
				}
			}
		}

		bp = bnext;
	}
}

/*
 * bopt() - coordinates branch optimization for the given function
 */
global
void bopt(BP bp)
{
	bsplit (bp);		/* also number blocks strictly sequentially */
	bfix   (bp);
	bclean (bp);
	bsort  (bp);
	bsetlab(bp);
	bjoin  (bp);
#if 0
	All_blocks(bp, 1, "via chain");
	All_blocks(bp, 0, "via next");
#endif
#if DBGB
	if (bp->bflg.has_loop)
 		send_msg("loop(s) in %s\n", bp->name);
#endif
}
