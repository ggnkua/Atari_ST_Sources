/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */
#include "top.h"

#define	TOUCHED(bp)	((bp)->flags & B_TOUCHED)

/*
 * bcomp(bc) - return the complement of the given branch code
 *
 * Used when a branch reversal is needed.
 */
static	int
bcomp(bc)
register int	bc;
{
	switch (bc) {
	case BHI: return BLS;
	case BLS: return BHI;
	case BCC: return BCS;
	case BCS: return BCC;
	case BNE: return BEQ;
	case BEQ: return BNE;
	case BVC: return BVS;
	case BVS: return BVC;
	case BPL: return BMI;
	case BMI: return BPL;
	case BGE: return BLT;
	case BLT: return BGE;
	case BGT: return BLE;
	case BLE: return BGT;
	default:
		fprintf(stderr, "bcomp() - bad branch code %d\n", bc);
		exit(1);
	}
}

/*
 * isbranch(s) - determines if 's' is a branch opcode
 *
 * Returns 1 for branches whose destination is the first operand,
 * and 2 for branches whose dest. is the second.
 */
static	int
isbranch(c)
register int	c;
{
	switch (c) {
	case BRA: case BHI: case BLS: case BCC:
	case BCS: case BNE: case BEQ: case BVC:
	case BVS: case BPL: case BMI: case BGE:
	case BLT: case BGT: case BLE:
		return 1;

	case DBRA: case DBHI: case DBLS: case DBCC:
	case DBCS: case DBNE: case DBEQ: case DBMI:
	case DBGE: case DBLT: case DBGT: case DBLE:
	case  DBT:
		return 2;

	default:
		return 0;
	}
}

/*
 * cblock(cp) - return the first block containing some code
 *
 * Starting with 'cp', find a block that has one or more instructions
 * in it. This is useful to collapse multiple null blocks into a single
 * logical point. This happens at points in the generated code where
 * there are multiple labels at the same logical location.
 */
static	BLOCK *
cblock(bp)
register BLOCK	*bp;
{
	while (bp->first == NULL && bp->bcond == NULL) {
		if (bp->bfall == NULL) {
			fprintf(ofp, "cblock() - error in block %s\n",
				bp->name);
			exit(1);
		}
		bp = bp->bfall;
	}

	return bp;
}

/*
 * bsplit() - split up blocks with branches inside them
 *
 * Look for branch instructions in each block. If somewhere in the middle of
 * the block, split up the block. When done, the blocks are broken down into
 * true basic blocks.
 */
static	void
bsplit(bp)
BLOCK	*bp;
{
	register BLOCK	*cp;	/* the current block */
	register BLOCK	*np;	/* new block (if needed) */
	register INST	*ip;	/* current instruction */

	for (cp = bp; cp != NULL ;cp = cp->chain) {
		for (ip = cp->first; ip != NULL ;ip = ip->next) {
			if (isbranch(ip->opcode) && ip->next != NULL) {
				np = mksym(mktmp());

				np->chain = cp->chain;
				cp->chain = np;

				np->next = cp->next;
				cp->next = np;

				np->first = ip->next;
				np->first->prev = NULL;
				np->last = cp->last;

				cp->last = ip;
				cp->last->next = NULL;

			} else if (ip->opcode == DC) {
				BLOCK	*db;

				/*
				 * If the instruction is part of a branch
				 * table, both the current block and the
				 * destination need to be marked as "reached".
				 */
				cp->flags |= B_ISREACHED;

				if ((db = getsym(ip->src.astr)) != NULL)
					db->flags |= B_ISREACHED;
				else {
					fprintf(stderr,
					  "bsplit() - symbol '%s' not found\n",
					  ip->src.astr);
					exit(1);
				}
			}
		}
	}
}

/*
 * bfix() - fix up the branch pointers
 *
 * Go through each block setting up 'bcond' and 'bfall' properly. If the
 * last instruction in the block is an unconditional branch, remove it
 * and set 'bfall' instead. The idea is that there should be no branch
 * instructions left when we're done. We remember the logical effect of
 * each branch, but reconstruct the branches later in a more optimal way.
 */
static	void
bfix(bp)
register BLOCK	*bp;
{
	register BLOCK	*cp;	/* current block */
	register INST	*ip;	/* current instruction */

	for (cp = bp; cp != NULL ;cp = cp->chain) {

		/* no instructions in the block */
		if (cp->first == NULL) {
			cp->bcond = NULL;
			cp->bfall = cp->next;
			continue;
		}

		/* the last instruction is a "return" */
		if (cp->last->opcode == RTS) {
			cp->bcond = cp->bfall = NULL;
			cp->flags |= B_RET;
			continue;
		}

		/* the last instruction isn't a branch */
		if (!isbranch(cp->last->opcode)) {
			cp->bcond = NULL;
			cp->bfall = cp->next;
			continue;
		}

		/*
		 * If we reach this point, then we've got a branch we need
		 * to remove at the end of this block.
		 */
		cp->bfall = cp->next;
		if (isbranch(cp->last->opcode) == 1) {
			cp->bcode = cp->last->opcode;
			cp->bcond = getsym(cp->last->src.astr);
		} else {
			cp->bcode = -1;
			cp->bcond = getsym(cp->last->dst.astr);
		}

		if (cp->bcond == NULL) {
			fprintf(stderr, "top: branch to bad label '%s'\n",
				cp->last->src.astr);
			exit(1);
		}

		if (cp->bcode < 0)
			continue;

		for (ip = cp->first; ip != NULL ;ip = ip->next) {
			if (ip->next == cp->last) {
				ip->next = NULL;
				break;
			}
		}
		free(cp->last->src.astr);
		free(cp->last);

		if (cp->first == cp->last)
			cp->first = cp->last = NULL;
		else
			cp->last = ip;
		/*
		 * If the branch was unconditional, we want to represent
		 * it as a "fall through", so fix the pointers to do that.
		 */
		if (cp->bcode == BRA) {
			s_bdel++;
			cp->bfall = cp->bcond;
			cp->bcond = NULL;
		}
	}
}

/*
 * bclean() - remove references to empty blocks
 *
 * Called after bsplit() and bfix().
 */
static	void
bclean(bp)
register BLOCK	*bp;
{
	register BLOCK	*cp;

	/*
	 * First clean up references to empty blocks
	 */
	for (cp = bp; cp != NULL ;cp = cp->chain) {
		if (cp->bcond != NULL)
			cp->bcond = cblock(cp->bcond);
		if (cp->bfall != NULL)
			cp->bfall = cblock(cp->bfall);
	}

	/*
	 * Now there are generally blocks that are still linked by the
	 * 'chain' pointers, but no longer referenced through 'bcond'
	 * or 'bfall' pointers. They don't actually need to be deleted
	 * since they won't cause trouble anywhere else.
	 */
}

#if 0
/*
 * reachable(p1, p2) - is p2 reachable (with constraints) from p1
 *
 * Try to reach p2 from p1 by following the 'bfall' pointers, without
 * going through a block that has already been touched. We stop searching
 * after a while since this function doesn't have to be perfect, and we're
 * mainly interested in improving small loops anyway.
 */
static	bool
reachable(p1, p2)
register BLOCK	*p1, *p2;
{
	register int	i;

	for (i=0; (i < 40) && (p1 != NULL) ;i++, p1 = p1->bfall) {

		if (TOUCHED(p1))
			return FALSE;

		if (p1 == p2)
			return TRUE;
	}
	return FALSE;
}
#endif

/*
 * bwalk() - recursive walk through the branch graph
 *
 * Starting at the entry point, walk through the block graph placing
 * blocks on the output list. By traversing the "bfall" nodes first
 * we attempt to make blocks that fall through come in order so that
 * branches are minimized.
 *
 * Joe describes this process as "grabbing the tree at the top and
 * shaking".
 *
 * The 'lp' variable below maintains our position in the generated list
 * of blocks.
 */
static	BLOCK	*lp;	/* pointer to the next block in the file */

static	bwalk(p)
register BLOCK	*p;
{
	if (p == NULL || TOUCHED(p))
		return;

#if 0
	/*
	 * The following code still needs some work, so it is disabled
	 * for now...
	 */
	/*
	 * Check to see if loop rotation is required. We "rotate" the loop
	 * by skipping the current node and traversing the 'bfall' node,
	 * and then the 'bcond' node. The function reachable() tells us
	 * that there's a loop through the 'bfall' nodes allowing us to
	 * make this optimization. The net result is that we try to move
	 * conditional branches to the bottoms of loops making the loop
	 * one instruction shorter. The overall number of branches remains
	 * the same.
	 *
	 * Rather than marking all the nodes again within the function
	 * "reachable", we just give up after a while if no loop is
	 * detected. This isn't perfect, but we get the biggest gain in
	 * small loops, and these will be detected accurately.
	 */
	if (do_lrot && p->bcond != NULL && reachable(p->bfall, p)) {
		s_lrot++;
		bwalk(p->bfall);
		bwalk(p->bcond);
		return;
	}
#endif

	p->flags |= B_TOUCHED;
	lp->next = p;
	lp = lp->next;

	/*
	 * We should swap 'bfall' and 'bcond' and alter 'bcode' IF:
	 *
	 * 1. Both bfall and bcond are non-null.
	 * 2. The branch is a simple one (not a DBcc inst.)
	 * 3. Branch reversals are enabled.
	 * 4. The block at bfall has already been touched.
	 * 5. The block at bcond hasn't been touched.
	 *
	 * In this case, we can avoid an extra branch if we reverse the
	 * sense of the conditional branch, and swap the pointers.
	 */
	if (p->bfall != NULL && p->bcond != NULL && p->bcode >= 0 &&
	    do_brev && TOUCHED(p->bfall) && !TOUCHED(p->bcond)) {
		register BLOCK	*tmp;

		s_brev++;
	    	tmp = p->bfall;
	    	p->bfall = p->bcond;
	    	p->bcond = tmp;
	    	if ((p->bcode = bcomp(p->bcode)) < 0) {
	    		fprintf(stderr, "top: internal error in bwalk()\n");
	    		exit(1);
	    	}
	}
	bwalk(p->bfall);
	bwalk(p->bcond);
}

/*
 * bsort() - branch optimization
 *
 * Initialize and terminate the 'next' pointers before and after
 * traversing the branch graph.
 */
static	void
bsort(bp)
register BLOCK	*bp;
{
	register BLOCK	*cb;

	lp = bp;

	bwalk(bp);	/* traverse the tree starting at the entry point */

	/*
	 * Now look for other parts of the tree that don't appear to be
	 * reachable, but really are. This can happen through the jump
	 * tables created for switch statements. For each such block,
	 * walk the subtree starting with it.
	 */
	for (cb = bp; cb != NULL ;cb = cb->chain) {
		if (!TOUCHED(cb) && (cb->flags & B_ISREACHED))
			bwalk(cb);
	}

	lp->next = NULL;
}

/*
 * bsetlab() - figure out which blocks really need labels
 *
 * This can be called AFTER bsort() to mark the blocks that are going to
 * need labels. Anything that we're going to branch to later gets a label.
 */
static	void
bsetlab(bp)
register BLOCK	*bp;
{
	for (; bp != NULL ;bp = bp->next) {
		if (bp->bcond != NULL)
			cblock(bp->bcond)->flags |= B_LABEL;
		if (bp->bfall != NULL && bp->bfall != bp->next)
			cblock(bp->bfall)->flags |= B_LABEL;
		/*
		 * If the block is reached via a jump table, then we
		 * need a label on THIS block directly.
		 */
		if (bp->flags & B_ISREACHED)
			bp->flags |= B_LABEL;
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
bjoin(bp)
register BLOCK	*bp;
{
	BLOCK	*np, *bnext;

	for (; bp != NULL ;bp = bnext) {
		bnext = bp->next;

		/*
		 * First block can't end with a conditional branch.
		 */
		if (bp->bcond != NULL)
			continue;

		/*
		 * Block must fall through to the next thing in the file.
		 */
		if (bp->next == NULL || bp->next != bp->bfall)
			continue;

		np = bp->next;

		/*
		 * Second block can't be the destination of a branch.
		 */
		if (np->flags & B_LABEL)
			continue;

		/*
		 * Join the blocks...
		 */
		if (np->first != NULL)
			np->first->prev = bp->last;

		if (bp->last != NULL)
			bp->last->next = np->first;
		else {
			bp->first = np->first;
			bp->last = np->last;
		}

		if (np->flags & B_RET)
			bp->flags |= B_RET;

		bp->last = np->last;
		bp->bfall = np->bfall;
		bp->bcond = np->bcond;
		bp->bcode = np->bcode;
		bp->next = np->next;

		/*
		 * Fix pointers so we don't free the instructions
		 * twice later on.
		 */
		np->first = NULL;
		np->last = NULL;

		/*
		 * If we've done a join, then we want to loop again on
		 * the current block to see if any others can be joined.
		 */
		bnext = bp;
	}
}

/*
 * bopt() - coordinates branch optimization for the given function
 */
void
bopt(bp)
register BLOCK	*bp;
{
	bsplit(bp);
	bfix(bp);
	bclean(bp);
	bsort(bp);
	bsetlab(bp);
	bjoin(bp);
}
