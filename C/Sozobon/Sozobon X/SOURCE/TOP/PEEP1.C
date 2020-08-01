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
 * Single-instruction peephole optimizations and the overall driver routine.
 */

#include "top.h"


void
peep(bp)
register BLOCK	*bp;
{
	bool	peep1(), peep2(), peep3();
	extern	BLOCK	*fhead;
	register bool	changed;

	peep1(bp);

	/*
	 * Loop until no more changes are made. After each change, do
	 * live/dead analysis or the data gets old. In each loop, make
	 * at most one change.
	 */
	do {
		changed = peep3(bp);

		if (!changed)
			changed = peep2(bp);

		if (!changed)
			changed = peep1(bp);

		rhealth(fhead, FALSE);

	} while (changed);
}

/*
 * ipeep1(ip) - check for changes to the instruction 'ip'
 */
static	bool
ipeep1(bp, ip)
register BLOCK	*bp;
register INST	*ip;
{
	/*
	 * clr.l  Dn			=> moveq.l  Dn
	 */
	if (ip->opcode == CLR && ip->src.amode == REG &&
	    ISD(ip->src.areg) && (ip->flags & LENL)) {
		ip->opcode = MOVEQ;
		ip->dst = ip->src;	/* we'll have two operands now */
		ip->src.amode = IMM;
		ip->src.disp = 0;
		DBG(printf("%d ", __LINE__))
		return TRUE;
	}

	/*
	 * move.*  #n,Dn		=> moveq.l  #n,Dn
	 *
	 * moveq is always a long operation, but as long as the immediate
	 * value is appropriate, we don't care what the original length
	 * was. Clearing upper bytes won't matter.
	 */
	if (ip->opcode == MOVE && ip->src.amode == IMM && ISD(ip->dst.areg) &&
	    D8OK(ip->src.disp)) {
	    	ip->opcode = MOVEQ;
	    	ip->flags = LENL;
		DBG(printf("%d ", __LINE__))
	    	return TRUE;
	}

	/*
	 * add.x  #n, X 		=> addq.x  #n, X
	 *
	 * where 1 <= n <= 8
	 */
	if (ip->opcode == ADD && ip->src.amode == IMM &&
	    ip->src.disp >= 1 && ip->src.disp <= 8) {
	    	ip->opcode = ADDQ;
		DBG(printf("%d ", __LINE__))
	    	return TRUE;
	}

	/*
	 * sub.x  #n, X 		=> subq.x  #n, X
	 *
	 * where 1 <= n <= 8
	 */
	if (ip->opcode == SUB && ip->src.amode == IMM &&
	    ip->src.disp >= 1 && ip->src.disp <= 8) {
	    	ip->opcode = SUBQ;
		DBG(printf("%d ", __LINE__))
	    	return TRUE;
	}

	/*
	 * movem.x  Reg,-(sp)		=> move.x Reg,-(sp)
	 */
	if (ip->opcode == MOVEM && ip->src.amode == REG &&
	    ip->dst.areg == SP && ip->dst.amode == (REGI|DEC)) {
	    	ip->opcode = MOVE;
		DBG(printf("%d ", __LINE__))
	    	return TRUE;
	}

	/*
	 * movem.x  (sp)+,Reg		=> move.x (sp)+,Reg
	 */
	if (ip->opcode == MOVEM && ip->dst.amode == REG &&
	    ip->src.amode == (REGI|INC) && ip->src.areg == SP) {
	    	ip->opcode = MOVE;
		DBG(printf("%d ", __LINE__))
	    	return TRUE;
	}

	/*
	 *	add[q]	#?, Rn
	 *
	 * Remove instruction if Rn is dead. This is most often used
	 * to eliminate the fixup of SP following a function call when
	 * we're just about to return, since the "unlk" clobbers SP
	 * anyway.
	 */
	if ((ip->opcode == ADDQ || ip->opcode == ADD) && ip->src.amode == IMM &&
	     ip->dst.amode == REG) {

		if (gflag && (ip->dst.areg == SP))
			goto end1;

		if ((ip->live & RM(ip->dst.areg)) == 0) {
		     	delinst(bp, ip);
			DBG(printf("%d ", __LINE__))
		     	return TRUE;
		}
	}
end1:

	/*
	 *	move.x	X, X
	 *
	 *	Delete as long as X isn't INC or DEC
	 */
	if ((ip->opcode == MOVE) && opeq(&ip->src, &ip->dst) &&
	    ((ip->src.amode & (INC|DEC)) == 0)) {

		delinst(bp, ip);
		DBG(printf("%d ", __LINE__))
		return TRUE;
	}

	/*
	 *	move.x	Rm, Rn
	 *
	 *	Delete if Rn is dead.
	 */
	if (ip->opcode == MOVE &&
	     ip->src.amode == REG && ip->dst.amode == REG) {

		if ((ip->live & RM(ip->dst.areg)) == 0) {
		     	delinst(bp, ip);
			DBG(printf("%d ", __LINE__))
		     	return TRUE;
		}
	}


	/*
	 *	cmp.x	#0, X		=>	tst.x	X
	 *	beq/bne				beq/bne
	 *
	 *	Where X is not An
	 */
	if (bp->last == ip && (bp->bcode == BEQ || bp->bcode == BNE) &&
	    ip->opcode == CMP &&
	    ((ip->dst.amode != REG) || !ISA(ip->dst.areg))) {

		if (ip->src.amode == IMM && ip->src.disp == 0) {
			ip->opcode = TST;
			ip->src = ip->dst;
			ip->dst.amode = NONE;
			DBG(printf("%d ", __LINE__))
			return TRUE;
		}
	}

	/*
	 * add.x  #n, Am 		=> lea  n(Am), Am
	 *
	 * where 'n' is a valid displacement
	 */
	if (ip->opcode == ADD && ip->src.amode == IMM && ip->dst.amode == REG &&
	    ISA(ip->dst.areg) && DOK(ip->src.disp)) {
	    	ip->opcode = LEA;
	    	ip->flags = 0;
	    	ip->src.amode = REGID;
	    	ip->src.areg = ip->dst.areg;
		DBG(printf("%d ", __LINE__))
	    	return TRUE;
	}

	return FALSE;
}

/*
 * peep1(bp) - peephole optimizations with a window size of 1
 */
static	bool
peep1(bp)
register BLOCK	*bp;
{
	register INST	*ip;
	register bool	changed = FALSE;
	register bool	bchange;

	DBG(printf("p1: "))
	for (; bp != NULL ;bp = bp->next) {
		bchange = FALSE;
		for (ip = bp->first; ip != NULL ;ip = ip->next) {
			if (ipeep1(bp, ip)) {
				s_peep1++;
				changed = TRUE;
				bchange = TRUE;
			}
		}
		if (bchange)
			bprep(bp);
	}
	DBG(printf("\n"); fflush(stdout))
	return changed;
}
