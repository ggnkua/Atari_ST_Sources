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
 * 3-instruction peephole optimizations
 */

#include "top.h"


/*
 * ipeep3(bp, ip) - look for 3-instruction optimizations at the given inst.
 */
static bool
ipeep3(bp, i1)
register BLOCK	*bp;
register INST	*i1;
{
	register INST	*i2 = i1->next;	/* the next instruction */
	INST	*i3 = i1->next->next;	/* the third instruction */

	register int	op1 = i1->opcode;
	register int	op2 = i2->opcode;
	register int	op3 = i3->opcode;

	/*
	 *	move.l	Am, Dn		=>	lea	N(Am), Ao
	 *	add.l	#N, Dn
	 *	move.l	Dn, Ao
	 *
	 *	Also, Dn must be dead after the third instruction.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) &&
	    ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((op2 == ADD) || (op2 == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) &&
		    DOK(i2->src.disp) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((op3 == MOVE) && (i3->flags & LENL) &&
			    (i3->src.amode == REG) &&
			    (i3->src.areg == i1->dst.areg) &&
			    (i3->dst.amode == REG) &&
			    ISA(i3->dst.areg) &&
			    ((i3->live & RM(i3->src.areg)) == 0)) {

				/*
				 * rewrite i1 and delete i2 and i3
				 */
				i1->opcode = LEA;
				i1->flags = 0;
				i1->dst = i3->dst;

				i1->src.amode = REGID;
				i1->src.disp = i2->src.disp;

			    	delinst(bp, i2);
			    	delinst(bp, i3);
			    	DBG(printf("%d ", __LINE__))
			    	return TRUE;
			}
		}
	}

	/*
	 *	move.l	Dm, Dn		=>	move.l	Dm, Ao
	 *	add.l	#N, Dn			lea	N(Ao), Ao
	 *	move.l	Dn, Ao
	 *
	 *	Also, Dn must be dead after the third instruction.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) &&
	    ISD(i1->src.areg) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((op2 == ADD) || (op2 == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) &&
		    DOK(i2->src.disp) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((op3 == MOVE) && (i3->flags & LENL) &&
			    (i3->src.amode == REG) &&
			    (i3->src.areg == i1->dst.areg) &&
			    (i3->dst.amode == REG) &&
			    ISA(i3->dst.areg) &&
			    ((i3->live & RM(i3->src.areg)) == 0)) {

				/*
				 * rewrite i1 and i2 and delete i3
				 */
				i1->dst.areg = i3->dst.areg;
				
				i2->opcode = LEA;
				i2->flags = 0;
				i2->dst = i3->dst;

				i2->src.amode = REGID;
				i2->src.areg = i2->dst.areg;
				i2->src.disp = i2->src.disp;

			    	delinst(bp, i3);
			    	DBG(printf("%d ", __LINE__))
			    	return TRUE;
			}
		}
	}

	/*
	 *	move.l	Am, Dn		=>	lea	-N(Am), Ao
	 *	sub.l	#N, Dn
	 *	move.l	Dn, Ao
	 *
	 *	Also, Dn must be dead after the third instruction.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) &&
	    ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((op2 == SUB) || (op2 == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) &&
		    DOK(i2->src.disp) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((op3 == MOVE) && (i3->flags & LENL) &&
			    (i3->src.amode == REG) &&
			    (i3->src.areg == i1->dst.areg) &&
			    (i3->dst.amode == REG) &&
			    ISA(i3->dst.areg) &&
			    ((i3->live & RM(i3->src.areg)) == 0)) {

				/*
				 * rewrite i1 and delete i2 and i3
				 */
				i1->opcode = LEA;
				i1->flags = 0;
				i1->dst = i3->dst;

				i1->src.amode = REGID;
				i1->src.disp = -i2->src.disp;

			    	delinst(bp, i2);
			    	delinst(bp, i3);
			    	DBG(printf("%d ", __LINE__))
			    	return TRUE;
			}
		}
	}

	/*
	 *	move.l	Am, Dn		=>	lea	0(Am, Do), Ap
	 *	add.x	Do, Dn
	 *	move.l	Dn, Ap
	 *
	 *	The second instruction can be either a word or long add.
	 *	Also, Dn must be dead after the third instruction.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) &&
	    ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((op2 == ADD) || (op2 == ADDQ)) &&
		    (i2->flags & (LENL|LENW)) &&
		    (i2->src.amode == REG) &&
		    ISD(i2->src.areg) && (i1->dst.areg != i2->src.areg) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((op3 == MOVE) && (i3->flags & LENL) &&
			    (i3->src.amode == REG) &&
			    (i3->src.areg == i1->dst.areg) &&
			    (i3->dst.amode == REG) &&
			    ISA(i3->dst.areg) &&
			    ((i3->live & RM(i3->src.areg)) == 0)) {

				/*
				 * rewrite i1 and delete i2 and i3
				 */
				i1->opcode = LEA;
				i1->flags = 0;
				i1->dst = i3->dst;

				i1->src.amode = REGIDX;
				if (i2->flags & LENL)
					i1->src.amode |= XLONG;
				i1->src.ireg = i2->src.areg;
				i1->src.disp = 0;

			    	delinst(bp, i2);
			    	delinst(bp, i3);
			    	DBG(printf("%d ", __LINE__))
			    	return TRUE;
			}
		}
	}

	/*
	 *	move.l	X(Am), Dn	=>	move.l	X(Am), Ao
	 *	add.l	#N, Dn
	 *	move.l	Dn, Ao			lea	N(Ao), Ao
	 *
	 *	Also, Dn must be dead after the third instruction.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REGI || i1->src.amode == REGID) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((op2 == ADD) || (op2 == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) &&
		    DOK(i2->src.disp) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((op3 == MOVE) && (i3->flags & LENL) &&
			    (i3->src.amode == REG) &&
			    (i3->src.areg == i1->dst.areg) &&
			    (i3->dst.amode == REG) &&
			    ISA(i3->dst.areg) &&
			    ((i3->live & RM(i3->src.areg)) == 0)) {

				/*
				 * rewrite i1 and i3 and delete i2
				 */
				i1->dst = i3->dst;

				i3->opcode = LEA;
				i3->flags = 0;
				i3->src.amode = REGID;
				i3->src.areg = i3->dst.areg;
				i3->src.disp = i2->src.disp;

			    	delinst(bp, i2);
			    	DBG(printf("%d ", __LINE__))
			    	return TRUE;
			}
		}
	}

	/*
	 *	move.x	X, Dn		=>	move.x	X, Do
	 *	ext.y	Dn			ext.y	Do
	 *	move.y	Dn, Do
	 *
	 *	Where Dn is dead.
	 */
	if ((op1 == MOVE)&&(op2 == EXT)&&(op3 == MOVE)&&
	    (i1->dst.amode == REG) && ISD(i1->dst.areg) &&
	    (i2->src.amode == REG) && (i3->src.amode == REG) &&
	    (i3->dst.amode == REG) && ISD(i3->dst.areg) &&
	    (i1->dst.areg == i2->src.areg) && (i1->dst.areg == i3->src.areg) &&
	    (i2->flags == i3->flags)) {

		if ((i3->live & RM(i3->src.areg)) == 0) {
			i1->dst.areg = i3->dst.areg;
			i2->src.areg = i3->dst.areg;

		    	delinst(bp, i3);
		    	DBG(printf("%d ", __LINE__))
		    	return TRUE;
		}
	}

	/*
	 *	move.l	X, Dm		=>	move.l	X, An
	 *	INST				INST
	 *	move.l	Dm, An			...deleted...
	 *
	 *	where INST doesn't modify Dm, and Dm is dead after i3
	 */
	if ((op1 == MOVE) && (op3 == MOVE) &&
	    (i1->dst.amode == REG) && ISD(i1->dst.areg) &&
	    (i3->src.amode == REG) && (i1->dst.areg == i3->src.areg) &&
	    (i3->dst.amode == REG) && ISA(i3->dst.areg) &&
	    !uses(i2, i3->src.areg)) {

		if ((i3->live & i3->src.areg) == 0) {
			i1->dst.areg = i3->dst.areg;
			delinst(bp, i3);

		    	DBG(printf("%d ", __LINE__))
			return TRUE;
		}
	}

	/*
	 *	move.l	Am, An			...deleted...
	 *	addq.l	#1, Am			...deleted...
	 *	... stuff ...			... stuff ...
	 *	???.b	..(An)..	=>	???.b	..(Am)+..
	 *
	 *	An must be dead after the last instruction. Nothing in
	 *	"stuff" can modify Am.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) && ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) && ISA(i1->dst.areg)) {

		int	rm = i1->src.areg;
		int	rn = i1->dst.areg;

		if (((op2 == ADD) || (op2 == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) && (i2->src.disp == 1) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == rm)) {

			while (i3 != NULL) {
				if (sets(i3, rm))
					goto end7;

				if (i3->src.amode==REGI && i3->src.areg==rn) {
					if (i3->live & RM(rn))
						goto end7;

					if ((i3->flags & LENB) == 0)
						goto end7;

					i3->src.amode |= INC;
					i3->src.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	DBG(printf("%d ", __LINE__))
				    	return TRUE;
				}
				if (i3->dst.amode==REGI && i3->dst.areg==rn) {
					if (i3->live & RM(rn))
						goto end7;

					if ((i3->flags & LENB) == 0)
						goto end7;

					i3->dst.amode |= INC;
					i3->dst.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	DBG(printf("%d ", __LINE__))
				    	return TRUE;
				}

				if (i3->next == NULL)
					goto end7;
				else
					i3 = i3->next;

			}
		}
	}
end7:

	/*
	 *	move.l	Am, An
	 *	addq.l	#2, Am
	 *	... stuff ...
	 *	???.w	..(An)..	=>	???.w	..(Am)+..
	 *
	 *	An must be dead after the last instruction. Nothing in
	 *	"stuff" can modify Am.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) && ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) && ISA(i1->dst.areg)) {

		int	rm = i1->src.areg;
		int	rn = i1->dst.areg;

		if (((op2 == ADD) || (op2 == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) && (i2->src.disp == 2) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == rm)) {

			while (i3 != NULL) {
				if (sets(i3, rm))
					goto end9;

				if (i3->src.amode==REGI && i3->src.areg==rn) {
					if (i3->live & RM(rn))
						goto end9;

					if ((i3->flags & LENW) == 0)
						goto end9;

					i3->src.amode |= INC;
					i3->src.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	DBG(printf("%d ", __LINE__))
				    	return TRUE;
				}
				if (i3->dst.amode==REGI && i3->dst.areg==rn) {
					if (i3->live & RM(rn))
						goto end9;

					if ((i3->flags & LENW) == 0)
						goto end9;

					i3->dst.amode |= INC;
					i3->dst.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	DBG(printf("%d ", __LINE__))
				    	return TRUE;
				}

				if (i3->next == NULL)
					goto end9;
				else
					i3 = i3->next;

			}
		}
	}
end9:

	/*
	 *	move.l	Am, An
	 *	addq.l	#4, Am
	 *	... stuff ...
	 *	???.l	..(An)..	=>	???.l	..(Am)+..
	 *
	 *	An must be dead after the last instruction. Nothing in
	 *	"stuff" can modify Am.
	 */
	if ((op1 == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) && ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) && ISA(i1->dst.areg)) {

		int	rm = i1->src.areg;
		int	rn = i1->dst.areg;

		if (((op2 == ADD) || (op2 == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) && (i2->src.disp == 4) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == rm)) {

			while (i3 != NULL) {
				if (sets(i3, rm))
					goto end11;

				if (i3->src.amode==REGI && i3->src.areg==rn) {
					if (i3->live & RM(rn))
						goto end11;

					if ((i3->flags & LENL) == 0)
						goto end11;

					i3->src.amode |= INC;
					i3->src.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	DBG(printf("%d ", __LINE__))
				    	return TRUE;
				}
				if (i3->dst.amode==REGI && i3->dst.areg==rn) {
					if (i3->live & RM(rn))
						goto end11;

					if ((i3->flags & LENL) == 0)
						goto end11;

					i3->dst.amode |= INC;
					i3->dst.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	DBG(printf("%d ", __LINE__))
				    	return TRUE;
				}

				if (i3->next == NULL)
					goto end11;
				else
					i3 = i3->next;

			}
		}
	}
end11:

	return FALSE;
}

/*
 * peep3(bp) - scan blocks starting at 'bp'
 */
bool
peep3(bp)
register BLOCK	*bp;
{
	register INST	*ip;
	register bool	changed = FALSE;

	DBG(printf("p3: "))
	for (; bp != NULL ;bp = bp->next) {
		ip = bp->first;
		while (ip!=NULL && ip->next != NULL && ip->next->next != NULL) {
			if (ipeep3(bp, ip)) {
				s_peep3++;
				bprep(bp);
				changed = TRUE;
				/*
				 * If we had a match, then any instruction
				 * could have been deleted, so the safe thing
				 * to do is to go to the next block.
				 */
				break;
			} else
				ip = ip->next;
		}
	}
	DBG(printf("\n"); fflush(stdout))
	return changed;
}
