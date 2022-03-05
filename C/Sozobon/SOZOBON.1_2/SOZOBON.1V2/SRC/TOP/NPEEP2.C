/* Copyright (c) 1988 by Sozobon, Limited.  Author: Tony Andrews
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
 * 2-instruction peephole optimizations
 */

#include "top.h"

/*
 * Macros to reference commonly-used values... cleans up the following
 * code quite a bit.
 */
#define	sm1	i1->src.amode	/* source & dest addressing modes */
#define	dm1	i1->dst.amode
#define	sm2	i2->src.amode
#define	dm2	i2->dst.amode

#define	sr1	i1->src.areg	/* source & dest registers */
#define	dr1	i1->dst.areg
#define	sr2	i2->src.areg
#define	dr2	i2->dst.areg


/*
 * ipeep2(bp, i1) - look for 2-instruction optimizations at the given inst.
 */
static	int
ipeep2(bp, i1)
BLOCK	*bp;
register INST	*i1;
{
	register INST	*i2;		/* the next instruction */
	register INST	*ti2;		/* "temporary" next inst */

	register int	op1, op2;	/* opcodes, for speed */

	i2  = i1->next;
	op1 = i1->opcode;
	op2 = i2->opcode;

	/*
	 * Avoid stack fix-ups after a call if possible.
	 */

	/*
	 *	addq	#4,sp
	 *	... stuff that doesn't use SP ...
	 *	move.l	?,-(sp)		=>	move.l	?,(sp)
	 */
	if (op1 == ADDQ && sm1 == IMM && i1->src.disp == 4 &&
	    dm1 == REG && dr1 == SP) {

		ti2 = i2;
		while (!uses(ti2, SP)) {
			if (ti2->next == NULL)
				goto end2;
			ti2 = ti2->next;
		}

		if (ti2->opcode == MOVE && ti2->flags == LENL &&
		    ti2->dst.amode == (REGI|DEC) && ti2->dst.areg == SP) {
		    	ti2->dst.amode = REGI;
		    	delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
		    	return CLEAN;
		}
	}
end2:

	/*
	 *	addq	#2,sp
	 *	... stuff that doesn't use SP ...
	 *	move.w	?,-(sp)		=>	move.w	?,(sp)
	 */
	if (op1 == ADDQ && sm1 == IMM && i1->src.disp == 2 &&
	    dm1 == REG && dr1 == SP) {

		ti2 = i2;
		while (!uses(ti2, SP)) {
			if (ti2->next == NULL)
				goto end3;
			ti2 = ti2->next;
		}

		if (ti2->opcode == MOVE && ti2->flags == LENW &&
		    ti2->dst.amode == (REGI|DEC) && ti2->dst.areg == SP) {
		    	ti2->dst.amode = REGI;
		    	delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
		    	return CLEAN;
		}
	}
end3:

	/*
	 * Avoid "tst" instructions following instructions that
	 * set the Z flag.
	 */

	/*
	 *	move.x	X, Y		=>	move.x	X, Y
	 *	tst.x	X or Y			...deleted...
	 *	beq/bne				beq/bne
	 *
	 *	Where Y is not An, because "movea" doesn't set the
	 *	zero flag.
	 */
	if (bp->last == i2 && (bp->bcode == BEQ || bp->bcode == BNE) &&
	    op1 == MOVE && op2 == TST &&
	    i1->flags == i2->flags) {

		/*
		 * If pre-decrement is set on the dest. of the move,
		 * don't let that screw up the operand comparison.
		 */
		if (dm1 & DEC)
			dm1 &= ~DEC;

		if (opeq(&i1->dst, &i2->src) || opeq(&i1->src, &i2->src)) {
			if (dm1 != REG || ISD(dr1)) {
			    	delinst(bp, i2);
			    	DBG(printf("%d ", __LINE__))
			    	return CLEAN;
			}
		}
	}

	/*
	 *	and.x	X, Y		=>	and.x	X, Y
	 *	tst.x	X or Y			...deleted...
	 *	beq/bne				beq/bne
	 *
	 *	Where Y is not An, because "movea" doesn't set the
	 *	zero flag.
	 */
	if (bp->last == i2 && (bp->bcode == BEQ || bp->bcode == BNE) &&
	    op1 == AND && op2 == TST &&
	    i1->flags == i2->flags) {

		/*
		 * If pre-decrement is set on the dest. of the move,
		 * don't let that screw up the operand comparison.
		 */
		if (dm1 & DEC)
			dm1 &= ~DEC;

		if (opeq(&i1->dst, &i2->src) || opeq(&i1->src, &i2->src)) {
			if (dm1 != REG || ISD(dr1)) {
			    	delinst(bp, i2);
			    	DBG(printf("%d ", __LINE__))
			    	return CLEAN;
			}
		}
	}

	/*
	 *	ext.x	Dn		=>	ext.x	Dn
	 *	tst.x	Dn			...deleted...
	 *	beq/bne				beq/bne
	 *
	 *	Where Y is not An, because "movea" doesn't set the
	 *	zero flag.
	 */
	if ((bp->last == i2) && (bp->bcode == BEQ || bp->bcode == BNE) &&
	    (op1 == EXT) && (op2 == TST) &&
	    (i1->flags == i2->flags)) {

		if ((sm1 == REG) && ISD(sr1) && (sm2 == REG) && (sr1 == sr2)) {
		    	delinst(bp, i2);
		    	DBG(printf("%d ", __LINE__))
		    	return CLEAN;
		}
	}

	/*
	 *	move.?	X, Dn		=>	move.?	X, Dn
	 *	ext.?	Dn			...deleted...
	 *	beq/bne				beq/bne
	 *
	 *	Where Dn is dead after the "ext".
	 */
	if (bp->last == i2 && (bp->bcode == BEQ || bp->bcode == BNE) &&
	    op1 == MOVE && op2 == EXT) {

		if ((dm1 == REG) && ISD(dr1) &&
		    (sm2 == REG) && (dr1 == sr2)) {
			if ((i2->live & RM(sr2)) == 0) {
				delinst(bp, i2);
			    	DBG(printf("%d ", __LINE__))
		 		return CLEAN;
			}
		}
	}

	/*
	 *	ext.l	Dm		=>	...deleted...
	 *	tst.l	Dm			tst.w	Dm
	 *
	 *	where Dm is dead after the "tst".
	 */
	if (op1 == EXT && op2 == TST &&
	    ((i1->flags & LENL) != 0) &&  ((i2->flags & LENL) != 0) &&
	    (sr1 == sr2) && ISD(sr1)) {

		if ((i2->live & RM(sr2)) == 0) {
			i2->flags = LENW;
			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

#if 0
	/*
	 *	add[q]	#?,sp
	 *	... stuff that doesn't use SP ...
	 *	unlk	An		=>	unlk	An
	 */
	if ((op1 == ADDQ || op1 == ADD) && sm1 == IMM &&
	     dm1 == REG && dr1 == SP) {

		ti2 = i2;
		while (!uses(ti2, SP)) {
			if (ti2->next == NULL)
				goto end8;
			ti2 = ti2->next;
		}
		if (ti2->opcode == UNLK) {
		     	delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
		     	return CLEAN;
		}
	}
end8:
#endif

	/*
	 *	ext.l	Dm		=>	...deleted...
	 *	???	N(An,Dm.l), ??		???	N(An,Dm.w), ??
	 *
	 *	Where Dm is dead
	 */
	if ((op1 == EXT) && (i1->flags & LENL) &&
	    (sm2 == (REGIDX|XLONG)) &&
	    (sr1 == i2->src.ireg)) {

		if ((i2->live & RM(sr1)) == 0) {
			sm2 &= ~XLONG;
			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

	/*
	 *	ext.l	Dm		=>	...deleted...
	 *	???	??, N(An,Dm.l)		???	??, N(An,Dm.w)
	 *
	 *	Where Dm is dead
	 */
	if ((op1 == EXT) && (i1->flags & LENL) &&
	    (dm2 == (REGIDX|XLONG)) &&
	    (sr1 == i2->dst.ireg)) {

		if ((i2->live & RM(sr1)) == 0) {
			dm2  &= ~XLONG;
			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

	/*
	 * Avoid intermediate registers.
	 */

	/*
	 *	move.x	X, Dm		=>	INST.x	X, Dn
	 *	INST.x	Dm, Dn
	 *
	 *	where Dm is dead, and INST is one of: add, sub, and, or, cmp
	 */
	if ((op1 == MOVE) &&
	    ((op2==ADD)||(op2==SUB)||(op2==AND)||(op2==OR)||(op2==CMP)) &&
	    (i1->flags == i2->flags) &&
	    (dm1 == REG) && ISD(dr1) &&
	    (sm2 == REG) && ISD(sr2) &&
	    (dm2 == REG) && ISD(dr2) &&
	    (dr1 == sr2)) {

		if ((i2->live & RM(sr2)) == 0) {

			i1->opcode = i2->opcode;
			dr1 = dr2;

			delinst(bp, i2);
		    	DBG(printf("%d ", __LINE__))
			return DIRTY;
		}
	}

	/*
	 * Silly moves
	 */

	/*
	 *	move.x	X, Y		=>	move.x	X, Y
	 *	move.x	Y, X
	 */
	if ((op1 == MOVE) && (op2 == MOVE) &&
	    (i1->flags == i2->flags) &&
	    opeq(&i1->src, &i2->dst) && opeq(&i1->dst, &i2->src) &&
	    ((sm1 & (INC|DEC)) == 0) &&
	    ((dm1 & (INC|DEC)) == 0)) {

	     	delinst(bp, i2);
	    	DBG(printf("%d ", __LINE__))
	     	return CLEAN;
	}

	/*
	 *	move.x	X, Y		=>	move.x	X, Rn
	 *	move.x	Y, Rn			move.x	Rn, Y
	 *
	 *	where Y isn't INC or DEC, and isn't register direct
	 */
	if ((op1 == MOVE) && (op2 == MOVE) && (dm2 == REG) &&
	    opeq(&i1->dst, &i2->src) && ((dm1 & (INC|DEC)) == 0) &&
	    (i1->flags == i2->flags) && (dm1 != REG)) {

		freeop(&i1->dst);
		i1->dst = i2->dst;
		i2->dst = i2->src;
		i2->src = i1->dst;

	    	DBG(printf("%d ", __LINE__))
		return CLEAN;
	}

	/*
	 *	move.x	Dm, X		=>	move.x	Dm, X
	 *	move.x	X, Y			move.x	Dm, Y
	 *
	 * Where 'x' is the same, and 'X' has no side-effects.
	 */
	if ((op1 == MOVE) && (op2 == MOVE) &&
	    (sm1 == REG) && ISD(sr1) &&
	    (i1->flags == i2->flags) && opeq(&i1->dst, &i2->src) &&
	    ((dm1 & (DEC|INC)) == 0)) {


		freeop(&i2->src);
		i2->src = i1->src;
	    	DBG(printf("%d ", __LINE__))
	     	return DIRTY;
	}

#if 0
	/*
	 *	move.?	Rm, Rn		=>	move.?	Rm, Rn
	 *	... stuff ...			... stuff ...
	 *	move.?	Rm, Rn
	 *
	 *	where "stuff" doesn't set Rm or Rn. Also make sure a
	 *	conditional branch doesn't directly follow the second
	 *	move. If so, we need to leave the move alone since it
	 *	sets condition codes.
	 */
	if ((op1 == MOVE) && (sm1 == REG) && (dm1 == REG)) {
		ti2 = i2;
		while (ti2 != NULL && !sets(ti2, sr1) && !sets(ti2, dr1)) {

			if ((ti2->opcode==MOVE) && (i1->flags==ti2->flags) &&
			    (ti2->src.amode==REG) && (ti2->dst.amode==REG) &&
			    (sr1 == ti2->src.areg) &&
			    (dr1 == ti2->dst.areg)) {

			     	delinst(bp, ti2);
			    	DBG(printf("%d ", __LINE__))
			     	return DIRTY;
			}
			ti2 = ti2->next;
		}
	}
#endif

	/*
	 *	move.l	Am, Dn		=>	move.l	Am, Ao
	 *	... stuff ...			... stuff ...
	 *	move.l	Dn, Ao
	 *
	 *	where "stuff" doesn't set Dn.
	 */
	if ((op1 == MOVE) && (i1->flags == LENL) &&
	    (sm1 == REG) && ISA(sr1) && (dm1 == REG) && ISD(dr1)) {

		ti2 = i2;
		while (!sets(ti2, dr1)) {

			if ((ti2->opcode == MOVE) && (ti2->flags == LENL) &&
			    (ti2->src.amode == REG) && ISD(ti2->src.areg) &&
			    (ti2->dst.amode == REG) && ISA(ti2->dst.areg) &&
			    (dr1 == ti2->src.areg)) {
	
				/*
				 * If the intermediate register isn't dead,
				 * then we have to keep using it.
				 */
				if ((ti2->live & RM(ti2->src.areg)) != 0)
					goto end14;
	
				dr1 = ti2->dst.areg;
	
			     	delinst(bp, ti2);
			    	DBG(printf("%d ", __LINE__))
			     	return DIRTY;
			}

			if (ti2->next == NULL)
				goto end14;

			ti2 = ti2->next;
		}
	}
end14:

	/*
	 *	move.l	Dm, An		=>	move.l	Dm, Ao
	 *	lea	(An), Ao
	 *
	 *	where An is dead
	 */
	if ((op1 == MOVE) && (op2 == LEA) && (sm1 == REG) && ISD(sr1) &&
	    (dm1 == REG) && ISA(dr1) && (sm2 == REGI) && (dm2 == REG) &&
	    ISA(dr2) && (dr1 == sr2)) {

		if ((i2->live & RM(sr2)) == 0) {

			dr1 = dr2;
			i1->live = i2->live;

			delinst(bp, i2);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

	/*
	 *	lea	X, An		=>	lea	X, Ao
	 *	lea	(An), Ao
	 *
	 *	where An is dead
	 */
	if ((op1 == LEA) && (op2 == LEA) && (sm2 == REGI) && (dr1 == sr2)) {

		if ((i2->live & RM(sr2)) == 0) {

			dr1 = dr2;
			i1->live = i2->live;

			delinst(bp, i2);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

	/*
	 *	lea	N(Am), Am	=>
	 *	?	(Am)[,...]		?	N(Am)[,...]
	 *
	 *	Where Am is either dead after the second instruction or
	 *	is a direct destination of the second instruction.
	 */
	if ((op1 == LEA) && (sm1 == REGID) && (sr1 == dr1) &&
	    (sm2 == REGI) && (dr1 == sr2)) {

		if (((i2->live & RM(sr2)) == 0) ||
		   ((dm2 == REG) && (dr2 == sr2))) {
			i2->src.amode = REGID;
			i2->src.disp = i1->src.disp;
			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return DIRTY;
		}
	}

	/*
	 *	lea	N(Am), Am	=>
	 *	?	X, (Am)			?	X, N(Am)
	 *
	 *	Where X doesn't reference Am, and Am is dead after the
	 *	second instruction.
	 */
	if ((op1 == LEA) && (sm1 == REGID) &&
	    (sr1 == dr1) && (dm2 == REGI) && (dr1 == dr2)) {

		if (((i2->live & RM(dr2)) == 0) &&
		    ((sm2 == IMM) || (sm2 == ABS) || (sr2 != dr2))) {
			dm2 = REGID;
			i2->dst.disp = i1->src.disp;
			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return DIRTY;
		}
	}

	/*
	 *	lea	X, Am		=>	...deleted...
	 *	clr.x	(Am)			clr.x	X
	 *
	 *	where Am is dead
	 */
	if ((op1 == LEA) && (op2 == CLR) && (sm2 == REGI) && (dr1 == sr2)) {

		if ((i2->live & RM(sr2)) == 0) {
			i2->src = i1->src;
	
			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

	/*
	 *	lea	X, Am		=>	...deleted...
	 *	move.x	Y, (Am)			move.x	Y, X
	 *
	 *	where Am is dead
	 */
	if ((op1 == LEA) && (op2 == MOVE) && dm2 == REGI && (dr1 == dr2)) {

		if ((i2->live & RM(dr2)) == 0) {
			i2->dst = i1->src;

			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

	/*
	 *	lea	X, Am		=>	...deleted...
	 *	move.x	(Am), Y			move.x	X, Y
	 *
	 *	where Am is dead
	 */
	if ((op1 == LEA) && (op2 == MOVE) && sm2 == REGI && (dr1 == sr2)) {

		if ((i2->live & RM(sr2)) == 0) {
			i2->src = i1->src;

			delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
			return CLEAN;
		}
	}

	/*
	 *	move.x	Dm, X		=>	move.x	Dm, X
	 *	cmp.x	#N, X			cmp.x	#N, Dm
	 *
	 *	Where X isn't register direct.
	 *
	 *	Since X generally references memory, we can compare
	 *	with the register faster.
	 */
	if ((op1 == MOVE) && (op2 == CMP) &&
	    (i1->flags == i2->flags) && (sm2 == IMM) &&
	    (sm1 == REG) && ISD(sr1) && (dm1 != REG) &&
	    opeq(&i1->dst, &i2->dst) && ((dm1 & (INC|DEC)) == 0)) {

		freeop(&i2->dst);
		dm2 = REG;
		dr2 = sr1;

	    	DBG(printf("%d ", __LINE__))
		return DIRTY;
	}


	/*
	 * Try to use register indirect w/ displacement and/or index
	 */

	/*
	 *	add.l	Am, Dn		=>	lea	0(Am,Dn.l), Ao
	 *	move.l	Dn, Ao
	 *
	 *	where Dn is dead
	 */
	if ((op1 == ADD) && (op2 == MOVE) &&
	    (sm1 == REG) && ISA(sr1) &&
	    (dm1 == REG) && ISD(dr1) &&
	    (sm2 == REG) && ISD(sr2) &&
	    (dm2 == REG) && ISA(dr2) &&
	    (dr1 == sr2) &&
	    (i1->flags & LENL) && (i2->flags & LENL)) {

		if ((i2->live & RM(sr2)) == 0) {

			i2->opcode = LEA;
			i2->flags = 0;

			sm2 = REGIDX|XLONG;
			i2->src.disp = 0;
			sr2 = sr1;
			i2->src.ireg = dr1;

		    	delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
		    	return CLEAN;
		}
	}

	/*
	 *	add.l	Dm, An		=>	move.x	0(An,Dm.l), Do
	 *	move.x	(An), Do
	 *
	 *	where An is dead
	 */
	if ((op1 == ADD) && (op2 == MOVE) &&
	    (sm1 == REG) && ISD(i1->src.areg) &&
	    (dm1 == REG) && ISA(dr1) &&
	    (sm2 == REGI)&& ISA(sr2) &&
	    (dm2 == REG) && ISD(dr2) &&
	    (dr1 == sr2) && (i1->flags & LENL)) {

		if ((i2->live & RM(sr2)) == 0) {

			sm2 = REGIDX|XLONG;
			i2->src.disp = 0;
			i2->src.ireg = sr1;

		    	delinst(bp, i1);
		    	DBG(printf("%d ", __LINE__))
		    	return CLEAN;
		}
	}

	/*
	 *	lea	N(Am), An	=>	lea	N(Am,Do.l), An
	 *	add.l	Do, An
	 *
	 */
	if ((op1 == LEA) && (op2 == ADD) && (sm1 == REGID) &&
	    (sm2 == REG) && ISD(sr2) && (dm2 == REG) && ISA(dr2) &&
	    (dr1 == dr2) && D8OK(i1->src.disp)) {

		sm1 = REGIDX|XLONG;
		i1->src.ireg = sr2;
		i1->live = i2->live;
		delinst(bp, i2);
	    	DBG(printf("%d ", __LINE__))
		return CLEAN;
	}



	/*
	 * Try to use the pre-decrement and post-increment modes
	 * whenever possible.
	 */

	/*
	 *	sub.l	#1, Am
	 *	... stuff ...
	 *	???.b	..(Am)..	=>	???.b	..-(Am)..
	 *
	 *	Nothing in "stuff" can refer to Am.
	 */
	if ((op1 == SUBQ) && (i1->flags & LENL) &&
	    (sm1 == IMM) && (i1->src.disp == 1) &&
	    (dm1 == REG) && ISA(dr1)) {

		while (i2 != NULL) {

			if (sm2 == REGI && sr2 == dr1) {

				if ((i2->flags & LENB) == 0)
					goto end24;

				sm2 |= DEC;

			    	delinst(bp, i1);
			    	DBG(printf("%d ", __LINE__))
			    	return DIRTY;
			}
			if (dm2 == REGI && dr2 == dr1) {

				if ((i2->flags & LENB) == 0)
					goto end24;

				dm2 |= DEC;

			    	delinst(bp, i1);
			    	DBG(printf("%d ", __LINE__))
			    	return CLEAN;
			}

			if (uses(i2, RM(dr1)))
				goto end24;

			if (i2->next == NULL)
				goto end24;
			else
				i2 = i2->next;

		}
	}
end24:

	/*
	 *	sub.l	#2, Am
	 *	... stuff ...
	 *	???.w	..(Am)..	=>	???.w	..-(Am)..
	 *
	 *	Nothing in "stuff" can refer to Am.
	 */
	if ((op1 == SUBQ) && (i1->flags & LENL) &&
	    (sm1 == IMM) && (i1->src.disp == 2) &&
	    (dm1 == REG) && ISA(dr1)) {

		while (i2 != NULL) {

			if (sm2 == REGI && sr2 == dr1) {

				if ((i2->flags & LENW) == 0)
					goto end26;

				sm2 |= DEC;

			    	delinst(bp, i1);
			    	DBG(printf("%d ", __LINE__))
			    	return CLEAN;
			}
			if (dm2 == REGI && dr2 == dr1) {

				if ((i2->flags & LENW) == 0)
					goto end26;

				dm2 |= DEC;

			    	delinst(bp, i1);
			    	DBG(printf("%d ", __LINE__))
			    	return CLEAN;
			}

			if (uses(i2, RM(dr1)))
				goto end26;

			if (i2->next == NULL)
				goto end26;
			else
				i2 = i2->next;

		}
	}
end26:

	/*
	 *	sub.l	#4, Am
	 *	... stuff ...
	 *	???.l	..(Am)..	=>	???.l	..-(Am)..
	 *
	 *	Nothing in "stuff" can refer to Am.
	 */
	if ((op1 == SUBQ) && (i1->flags & LENL) &&
	    (sm1 == IMM) && (i1->src.disp == 4) &&
	    (dm1 == REG) && ISA(dr1)) {

		while (i2 != NULL) {

			if (sm2 == REGI && sr2 == dr1) {

				if ((i2->flags & LENL) == 0)
					goto end28;

				sm2 |= DEC;

			    	delinst(bp, i1);
			    	DBG(printf("%d ", __LINE__))
			    	return CLEAN;
			}
			if (dm2 == REGI && dr2 == dr1) {

				if ((i2->flags & LENL) == 0)
					goto end28;

				i2->dst.amode |= DEC;

			    	delinst(bp, i1);
			    	DBG(printf("%d ", __LINE__))
			    	return CLEAN;
			}

			if (uses(i2, RM(dr1)))
				goto end28;

			if (i2->next == NULL)
				goto end28;
			else
				i2 = i2->next;

		}
	}
end28:

	return UNCHANGED;
}

/*
 * peep2(bp) - scan blocks starting at 'bp'
 */
int
peep2(bp)
register BLOCK	*bp;
{
	register INST	*ip;
	register bool	i;
	register int	state = UNCHANGED;

	DBG(printf("p2 :"))

	for (; bp != NULL ;bp = bp->next) {
		for (ip = bp->first; ip != NULL && ip->next != NULL ;) {
			if ((i = ipeep2(bp, ip)) != UNCHANGED) {

				if (i == DIRTY)
					state = DIRTY;
				if (state == UNCHANGED)
					state = CLEAN;

				s_peep2++;
				/*
				 * If we had a match, then either instruction
				 * may have been deleted, so the safe thing to
				 * do is to go to the next block.
				 */
				break;
			} else
				ip = ip->next;
		}
	}
	DBG(printf("\n"); fflush(stdout))
	return state;
}
