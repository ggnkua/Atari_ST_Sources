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

/*
 * Routines for data flow analysis by block and function.
 */

#include "top.h"

/*
 * bprep() - initial analysis of a block
 */
void
bprep(bp)
BLOCK	*bp;
{
	register INST	*ip;
	register int	ref, set;

	ref = set = 0;
	for (ip = bp->first; ip != NULL ;ip = ip->next) {
		ref |= (ip->rref = reg_ref(ip)) & ~set;
		set |= (ip->rset = reg_set(ip));
	}
	bp->rref = ref;
	bp->rset = set;
}

/*
 * fprep() - perform initial analysis of individual blocks in a function
 */
static	void
fprep(bp)
BLOCK	*bp;
{
	register BLOCK	*cp;

	for (cp = bp; cp != NULL ;cp = cp->next)
		bprep(cp);
}

static	bool
scan_ref(bp, reg)
register BLOCK	*bp;
register int	reg;
{
	register INST	*ip;

	if (bp == NULL)
		return FALSE;

	if (bp->rref & reg)
		return TRUE;

	if (bp->rset & reg)
		return FALSE;

	if (bp->flags & B_MARK)
		return FALSE;

	if (bp->flags & B_RET)
		return FALSE;

	bp->flags |= B_MARK;

	if (scan_ref(bp->bcond, reg))
		return TRUE;

	if (scan_ref(bp->bfall, reg))
		return TRUE;

	for (ip = bp->first; ip != NULL ;ip = ip->next) {
		if (ip->opcode == DC && (ip->flags & LENL)) {
			BLOCK	*db;

			if (is_astr(ip->src.amode) && (ip->src.astr != NULL) &&
			    (db = getsym(ip->src.astr)) != NULL)
				if (scan_ref(db, reg))
					return TRUE;
		}
	}
	return FALSE;
}

/*
 * is_live(bp, reg) - is 'reg' live at the end of block 'bp'
 *
 * Look ahead through the traversal graph to see what might happen to the
 * given register. If we can find any reachable block that references 'reg'
 * before setting it, the register is live. Scanning stops when the register
 * is set, we loop back to the starting block, or the function returns.
 */
static	bool
is_live(bp, reg)
register BLOCK	*bp;
register int	reg;
{
	register INST	*ip;
	register BLOCK	*cp;

	/*
	 * Clear all the mark bits
	 */
	for (cp = fhead; cp != NULL ;cp = cp->next)
		cp->flags &= ~B_MARK;

	bp->flags |= B_MARK;

	if (scan_ref(bp->bfall, reg))
		return TRUE;

	if (scan_ref(bp->bcond, reg))
		return TRUE;

	for (ip = bp->first; ip != NULL ;ip = ip->next) {
		if (ip->opcode == DC && (ip->flags & LENL)) {
			BLOCK	*db;

			if (is_astr(ip->src.amode) && (ip->src.astr != NULL) &&
			    (db = getsym(ip->src.astr)) != NULL)
				if (scan_ref(db, reg))
					return TRUE;
		}
	}
	return FALSE;
}

/*
 * bflow() - live/dead analysis for a given block
 *
 * Work backward from the end of the block, checking the status of registers.
 * To start with, figure out the state of each register as of the end of the
 * block. Then work backward, checking registers only as necessary.
 */
static	void
bflow(bp)
BLOCK	*bp;
{
	register INST	*ip;
	register int	live = 0;
	register int	reg;

	/*
	 * Figure out what's alive at the end of this block.
	 */
	for (reg = FIRSTREG; reg <= LASTREG ;reg++) {
		if (is_live(bp, RM(reg)))
			live |= RM(reg);
	}
	/*
	 * Now work through the instructions in the block.
	 */
	for (ip = bp->last; ip != NULL ;ip = ip->prev) {
		ip->live = live;

		for (reg = FIRSTREG; reg <= LASTREG ;reg++) {
			if (ip->rref & RM(reg))
				live |= RM(reg);
			else if (ip->rset & RM(reg))
				live &= ~RM(reg);
		}
	}
}

void
rhealth(bp, do_prep)
BLOCK	*bp;
bool	do_prep;
{
	register BLOCK	*cp;

	if (do_prep)
		fprep(bp);

	for (cp = bp; cp != NULL ;cp = cp->next)
		bflow(cp);
}
