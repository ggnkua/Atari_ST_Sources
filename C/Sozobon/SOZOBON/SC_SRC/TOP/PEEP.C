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
 * Peephole optimization routines
 */

#include "top.h"


/*
 * ipeep1(ip) - check for changes to the instruction 'ip'
 */
static	int
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
		return 1;
	}

	/*
	 * move.*  #n,Dn		=> moveq.*  #n,Dn
	 */
	if (ip->opcode == MOVE && ip->src.amode == IMM && ISD(ip->dst.areg) &&
	    ip->flags == LENL && ip->src.disp >= -128  && ip->src.disp <= 127) {
	    	ip->opcode = MOVEQ;
	    	return 2;
	}

	/*
	 * add.x  #n, Reg 		=> addq.x  #n, Reg
	 * where 1 <= n <= 8
	 */
	if (ip->opcode == ADD && ip->src.amode == IMM && ip->dst.amode == REG &&
	    ip->src.disp >= 1 && ip->src.disp <= 8) {
	    	ip->opcode = ADDQ;
	    	return 3;
	}

	/*
	 * sub.x  #n, Reg 		=> subq.x  #n, Reg
	 * where 1 <= n <= 8
	 */
	if (ip->opcode == ADD && ip->src.amode == IMM && ip->dst.amode == REG &&
	    ip->src.disp >= 1 && ip->src.disp <= 8) {
	    	ip->opcode = SUBQ;
	    	return 4;
	}

	/*
	 * movem.x  Reg,-(sp)		=> move.x Reg,-(sp)
	 */
	if (ip->opcode == MOVEM && ip->src.amode == REG &&
	    ip->dst.areg == SP && ip->dst.amode == (REGI|DEC)) {
	    	ip->opcode = MOVE;
	    	return 5;
	}

	/*
	 * movem.x  (sp)+,Reg		=> move.x (sp)+,Reg
	 */
	if (ip->opcode == MOVEM && ip->dst.amode == REG &&
	    ip->src.amode == (REGI|INC) && ip->src.areg == SP) {
	    	ip->opcode = MOVE;
	    	return 6;
	}

	/*
	 *	add[q]	#?,sp
	 *
	 *	Remove instruction if sp is dead.
	 */
	if ((ip->opcode == ADDQ || ip->opcode == ADD) && ip->src.amode == IMM &&
	     ip->dst.amode == REG && ip->dst.areg == SP) {

		if (do_dflow && ((ip->live & RM(SP)) == 0)) {
		     	delinst(bp, ip);
		     	s_idel++;
		     	return 7;
		}
	}

	return 0;
}

/*
 * peep1(bp) - peephole optimizations with a window size of 1
 *
 * Returns TRUE if any optimizations were made.
 */
static	bool
peep1(bp)
register BLOCK	*bp;
{
	register INST	*ip;
	register bool	changed = FALSE;
	register int	pnum;

#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "peep1: ");
#endif
	for (; bp != NULL ;bp = bp->next) {
		for (ip = bp->first; ip != NULL ;) {
			if (pnum = ipeep1(bp, ip)) {
				changed = TRUE;
				s_peep1++;
#ifdef	DEBUG
				if (debug)
					fprintf(stderr, "%d ", pnum);
#endif
				/*
				 * Start over in case the instruction we
				 * just looked at got deleted.
				 */
				ip = bp->first;
			} else
				ip = ip->next;
		}
	}
#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "\n");
#endif

	return changed;
}

/*
 * ipeep2(bp, ip) - look for 2-instruction optimizations at the given inst.
 */
static	int
ipeep2(bp, ip)
register BLOCK	*bp;
register INST	*ip;
{
	INST	*ni = ip->next;	/* the next instruction */
	INST	*tni;		/* "temporary" next inst, for skipping */

	/*
	 *	addq	#4,sp
	 *	... stuff that doesn't use SP ...
	 *	move.l	?,-(sp)		=>	move.l	?,(sp)
	 */
	if (ip->opcode == ADDQ && ip->src.amode == IMM && ip->src.disp == 4 &&
	    ip->dst.amode == REG && ip->dst.areg == SP) {

		tni = ni;
		while (do_dflow && !uses(tni, SP)) {
			if (tni->next == NULL)
				return 0;
			tni = tni->next;
		}

		if (tni->opcode == MOVE && tni->flags == LENL &&
		    tni->dst.amode == (REGI|DEC) && tni->dst.areg == SP) {
		    	tni->dst.amode = REGI;
		    	delinst(bp, ip);
		    	s_idel++;
		    	return 1;
		}
	}

	/*
	 *	addq	#2,sp
	 *	... stuff that doesn't use SP ...
	 *	move.w	?,-(sp)		=>	move.w	?,(sp)
	 */
	if (ip->opcode == ADDQ && ip->src.amode == IMM && ip->src.disp == 2 &&
	    ip->dst.amode == REG && ip->dst.areg == SP) {

		tni = ni;
		while (do_dflow && !uses(tni, SP)) {
			if (tni->next == NULL)
				return 0;
			tni = tni->next;
		}

		if (tni->opcode == MOVE && tni->flags == LENW &&
		    tni->dst.amode == (REGI|DEC) && tni->dst.areg == SP) {
		    	tni->dst.amode = REGI;
		    	delinst(bp, ip);
		    	s_idel++;
		    	return 2;
		}
	}

	/*
	 *	move.x	X, Y		=>	move.x	X, Y
	 *	tst.x	Y			...deleted...
	 *	beq/bne				beq/bne
	 *
	 *	Where Y is not An, because "movea" doesn't set the
	 *	zero flag.
	 */
	if (bp->last == ni && (bp->bcode == BEQ || bp->bcode == BNE) &&
	    ip->opcode == MOVE && ni->opcode == TST &&
	    ip->flags == ni->flags) {

		int	is_dec = FALSE;

		/*
		 * If pre-decrement is set on the dest. of the move,
		 * don't let that screw up the operand comparison.
		 */
		if (ip->dst.amode & DEC) {
			is_dec = TRUE;
			ip->dst.amode &= ~DEC;
		}

		if (opeq(&ip->dst, &ni->src)) {
			if (ip->dst.amode != REG || ISD(ip->dst.areg)) {
				if (is_dec)
					ip->dst.amode |= DEC;
			    	delinst(bp, ni);
			    	s_idel++;
			    	return 3;
			}
		}
		if (is_dec)
			ip->dst.amode |= DEC;
	}

	/*
	 *	add[q]	#?,sp
	 *	... stuff that doesn't use SP ...
	 *	unlk	An		=>	unlk	An
	 */
	if ((ip->opcode == ADDQ || ip->opcode == ADD) && ip->src.amode == IMM &&
	     ip->dst.amode == REG && ip->dst.areg == SP) {

		tni = ni;
		while (do_dflow && !uses(tni, SP)) {
			if (tni->next == NULL)
				return 0;
			tni = tni->next;
		}
		if (tni->opcode == UNLK) {
		     	delinst(bp, ip);
		     	s_idel++;
		     	return 4;
		}
	}

	/*
	 *	move.x	Dm, Dn		=>	move.x	Dm, Dn
	 *	move.x	Dn, Dm
	 */
	if ((ip->opcode == MOVE) && (ni->opcode == MOVE) &&
	    (ip->src.amode == REG) && (ip->dst.amode == REG) &&
	    (ni->src.amode == REG) && (ni->dst.amode == REG)) {

		if (ISD(ip->src.areg) && (ip->src.areg == ni->dst.areg) &&
		    ISD(ip->dst.areg) && (ip->dst.areg == ni->src.areg)) {
		     	delinst(bp, ni);
		     	s_idel++;
		     	return 5;
		}
	}

	/*
	 *	move.l	Am, Dn		=>	move.l	Am, Ao
	 *	... stuff ...			... stuff ...
	 *	move.l	Dn, Ao
	 *
	 *	where "stuff" doesn't set Dn.
	 */
	if ((ip->opcode == MOVE) && (ip->flags == LENL) &&
	    (ip->src.amode == REG) && ISA(ip->src.areg) &&
	    (ip->dst.amode == REG) && ISD(ip->dst.areg)) {

		tni = ni;
		while (do_dflow && !sets(tni, ip->dst.areg)) {

			if ((tni->opcode == MOVE) && (tni->flags == LENL) &&
			    (tni->src.amode == REG) && ISD(tni->src.areg) &&
			    (tni->dst.amode == REG) && ISA(tni->dst.areg) &&
			    (ip->dst.areg == tni->src.areg)) {
	
				/*
				 * If the intermediate register isn't dead,
				 * then we have to keep using it.
				 */
				if ((tni->live & RM(tni->src.areg)) != 0)
					return 0;
	
				ip->dst.areg = tni->dst.areg;
	
			     	delinst(bp, tni);
			     	s_idel++;
			     	return 6;
			}

			if (tni->next == NULL)
				return 0;

			tni = tni->next;
		}
	}

	/*
	 *	sub.l	#1, Am
	 *	... stuff ...
	 *	???.b	..(Am)..	=>	???.b	..-(Am)..
	 *
	 *	Nothing in "stuff" can refer to Am.
	 */
	if ((ip->opcode == SUB) && (ip->flags & LENL) &&
	    (ip->src.amode == IMM) && (ip->src.disp == 1) &&
	    (ip->dst.amode == REG) && ISA(ip->dst.areg)) {

		int	rm = ip->dst.areg;

		while (ni != NULL) {

			if (ni->src.amode == REGI && ni->src.areg == rm) {

				if ((ni->flags & LENB) == 0)
					return 0;

				ni->src.amode |= DEC;

			    	delinst(bp, ip);
			    	s_idel++;
			    	return 7;
			}
			if (ni->dst.amode == REGI && ni->dst.areg == rm) {

				if ((ni->flags & LENB) == 0)
					return 0;

				ni->dst.amode |= DEC;

			    	delinst(bp, ip);
			    	s_idel++;
			    	return 7;
			}

			if (uses(ni, RM(rm)))
				return 0;

			if (ni->next == NULL)
				return 0;
			else
				ni = ni->next;

		}
	}

	/*
	 *	sub.l	#2, Am
	 *	... stuff ...
	 *	???.w	..(Am)..	=>	???.w	..-(Am)..
	 *
	 *	Nothing in "stuff" can refer to Am.
	 */
	if ((ip->opcode == SUB) && (ip->flags & LENL) &&
	    (ip->src.amode == IMM) && (ip->src.disp == 2) &&
	    (ip->dst.amode == REG) && ISA(ip->dst.areg)) {

		int	rm = ip->dst.areg;

		while (ni != NULL) {

			if (ni->src.amode == REGI && ni->src.areg == rm) {

				if ((ni->flags & LENW) == 0)
					return 0;

				ni->src.amode |= DEC;

			    	delinst(bp, ip);
			    	s_idel++;
			    	return 8;
			}
			if (ni->dst.amode == REGI && ni->dst.areg == rm) {

				if ((ni->flags & LENW) == 0)
					return 0;

				ni->dst.amode |= DEC;

			    	delinst(bp, ip);
			    	s_idel++;
			    	return 8;
			}

			if (uses(ni, RM(rm)))
				return 0;

			if (ni->next == NULL)
				return 0;
			else
				ni = ni->next;

		}
	}
	/*
	 *	sub.l	#4, Am
	 *	... stuff ...
	 *	???.l	..(Am)..	=>	???.l	..-(Am)..
	 *
	 *	Nothing in "stuff" can refer to Am.
	 */
	if ((ip->opcode == SUB) && (ip->flags & LENL) &&
	    (ip->src.amode == IMM) && (ip->src.disp == 4) &&
	    (ip->dst.amode == REG) && ISA(ip->dst.areg)) {

		int	rm = ip->dst.areg;

		while (ni != NULL) {

			if (ni->src.amode == REGI && ni->src.areg == rm) {

				if ((ni->flags & LENL) == 0)
					return 0;

				ni->src.amode |= DEC;

			    	delinst(bp, ip);
			    	s_idel++;
			    	return 9;
			}
			if (ni->dst.amode == REGI && ni->dst.areg == rm) {

				if ((ni->flags & LENL) == 0)
					return 0;

				ni->dst.amode |= DEC;

			    	delinst(bp, ip);
			    	s_idel++;
			    	return 9;
			}

			if (uses(ni, RM(rm)))
				return 0;

			if (ni->next == NULL)
				return 0;
			else
				ni = ni->next;

		}
	}
	return 0;
}

/*
 * peep2(bp) - scan blocks starting at 'bp'
 */
static bool
peep2(bp)
register BLOCK	*bp;
{
	register INST	*ip;
	register bool	changed = FALSE;
	register int	pnum;

#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "peep2: ");
#endif

	for (; bp != NULL ;bp = bp->next) {
		for (ip = bp->first; ip != NULL && ip->next != NULL ;) {
			if (pnum = ipeep2(bp, ip)) {
				changed = TRUE;
				s_peep2++;
#ifdef	DEBUG
				if (debug)
					fprintf(stderr, "%d ", pnum);
#endif
				/*
				 * If we had a match, then either instruction
				 * may have been deleted, so the safe thing to
				 * do is to start the block over.
				 */
				ip = bp->first;
			} else
				ip = ip->next;
		}
	}
#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "\n");
#endif
	return changed;
}

/*
 * ipeep3(bp, ip) - look for 3-instruction optimizations at the given inst.
 */
static	int
ipeep3(bp, i1)
register BLOCK	*bp;
register INST	*i1;
{
	INST	*i2 = i1->next;		/* the next instruction */
	INST	*i3 = i1->next->next;	/* the third instruction */

	/*
	 *	move.l	Am, Dn		=>	lea	N(Am), Ao
	 *	add.l	#N, Dn
	 *	move.l	Dn, Ao
	 *
	 *	Also, Dn must be dead after the third instruction.
	 */
	if ((i1->opcode == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) &&
	    ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((i2->opcode == ADD) || (i2->opcode == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) &&
		    DOK(i2->src.disp) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((i3->opcode == MOVE) && (i3->flags & LENL) &&
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
			    	s_idel += 2;
			    	return 1;
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
	if ((i1->opcode == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) &&
	    ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((i2->opcode == ADD) || (i2->opcode == ADDQ)) &&
		    (i2->flags & (LENL|LENW)) &&
		    (i2->src.amode == REG) &&
		    ISD(i2->src.areg) && (i1->dst.areg != i2->src.areg) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((i3->opcode == MOVE) && (i3->flags & LENL) &&
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
			    	s_idel += 2;
			    	return 2;
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
	if ((i1->opcode == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REGI || i1->src.amode == REGID) &&
	    (i1->dst.amode == REG) &&
	    ISD(i1->dst.areg)) {

		if (((i2->opcode == ADD) || (i2->opcode == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) &&
		    DOK(i2->src.disp) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == i1->dst.areg)) {

			if ((i3->opcode == MOVE) && (i3->flags & LENL) &&
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
			    	s_idel++;
			    	return 3;
			}
		}
	}

	/*
	 *	move.l	Am, An
	 *	addq.l	#1, Am
	 *	... stuff ...
	 *	???.b	..(An)..	=>	???.b	..(Am)+..
	 *
	 *	An must be dead after the last instruction. Nothing in
	 *	"stuff" can modify Am.
	 */
	if ((i1->opcode == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) && ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) && ISA(i1->dst.areg)) {

		int	rm = i1->src.areg;
		int	rn = i1->dst.areg;

		if (((i2->opcode == ADD) || (i2->opcode == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) && (i2->src.disp == 1) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == rm)) {

			while (i3 != NULL) {
				if (sets(i3, RM(rm)))
					return 0;

				if (i3->src.amode==REGI && i3->src.areg==rn) {
					if (i3->live & RM(rn))
						return 0;

					if ((i3->flags & LENB) == 0)
						return 0;

					i3->src.amode |= INC;
					i3->src.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	s_idel += 2;
				    	return 4;
				}
				if (i3->dst.amode==REGI && i3->dst.areg==rn) {
					if (i3->live & RM(rn))
						return 0;

					if ((i3->flags & LENB) == 0)
						return 0;

					i3->dst.amode |= INC;
					i3->dst.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	s_idel += 2;
				    	return 4;
				}

				if (i3->next == NULL)
					return 0;
				else
					i3 = i3->next;

			}
		}
	}

	/*
	 *	move.l	Am, An
	 *	addq.l	#2, Am
	 *	... stuff ...
	 *	???.w	..(An)..	=>	???.w	..(Am)+..
	 *
	 *	An must be dead after the last instruction. Nothing in
	 *	"stuff" can modify Am.
	 */
	if ((i1->opcode == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) && ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) && ISA(i1->dst.areg)) {

		int	rm = i1->src.areg;
		int	rn = i1->dst.areg;

		if (((i2->opcode == ADD) || (i2->opcode == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) && (i2->src.disp == 2) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == rm)) {

			while (i3 != NULL) {
				if (sets(i3, RM(rm)))
					return 0;

				if (i3->src.amode==REGI && i3->src.areg==rn) {
					if (i3->live & RM(rn))
						return 0;

					if ((i3->flags & LENW) == 0)
						return 0;

					i3->src.amode |= INC;
					i3->src.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	s_idel += 2;
				    	return 5;
				}
				if (i3->dst.amode==REGI && i3->dst.areg==rn) {
					if (i3->live & RM(rn))
						return 0;

					if ((i3->flags & LENW) == 0)
						return 0;

					i3->dst.amode |= INC;
					i3->dst.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	s_idel += 2;
				    	return 4;
				}

				if (i3->next == NULL)
					return 0;
				else
					i3 = i3->next;

			}
		}
	}
	/*
	 *	move.l	Am, An
	 *	addq.l	#4, Am
	 *	... stuff ...
	 *	???.l	..(An)..	=>	???.l	..(Am)+..
	 *
	 *	An must be dead after the last instruction. Nothing in
	 *	"stuff" can modify Am.
	 */
	if ((i1->opcode == MOVE) && (i1->flags & LENL) &&
	    (i1->src.amode == REG) && ISA(i1->src.areg) &&
	    (i1->dst.amode == REG) && ISA(i1->dst.areg)) {

		int	rm = i1->src.areg;
		int	rn = i1->dst.areg;

		if (((i2->opcode == ADD) || (i2->opcode == ADDQ)) &&
		    (i2->flags & LENL) &&
		    (i2->src.amode == IMM) && (i2->src.disp == 4) &&
		    (i2->dst.amode == REG) &&
		    (i2->dst.areg == rm)) {

			while (i3 != NULL) {
				if (sets(i3, RM(rm)))
					return 0;

				if (i3->src.amode==REGI && i3->src.areg==rn) {
					if (i3->live & RM(rn))
						return 0;

					if ((i3->flags & LENL) == 0)
						return 0;

					i3->src.amode |= INC;
					i3->src.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	s_idel += 2;
				    	return 6;
				}
				if (i3->dst.amode==REGI && i3->dst.areg==rn) {
					if (i3->live & RM(rn))
						return 0;

					if ((i3->flags & LENL) == 0)
						return 0;

					i3->dst.amode |= INC;
					i3->dst.areg = rm;

				    	delinst(bp, i1);
				    	delinst(bp, i2);
				    	s_idel += 2;
				    	return 4;
				}

				if (i3->next == NULL)
					return 0;
				else
					i3 = i3->next;

			}
		}
	}

	return 0;
}

/*
 * peep3(bp) - scan blocks starting at 'bp'
 */
static bool
peep3(bp)
register BLOCK	*bp;
{
	register INST	*ip;
	register bool	changed = FALSE;
	register int	pnum;

	/*
	 * All of the 3-inst stuff requires data-flow analysis
	 */
	if (!do_dflow)
		return FALSE;

#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "peep3: ");
#endif

	for (; bp != NULL ;bp = bp->next) {
		ip = bp->first;
		while (ip!=NULL && ip->next != NULL && ip->next->next != NULL) {
			if (pnum = ipeep3(bp, ip)) {
				changed = TRUE;
				s_peep3++;
#ifdef	DEBUG
				if (debug)
					fprintf(stderr, "%d ", pnum);
#endif
				/*
				 * If we had a match, then any instruction
				 * could have been deleted, so the safe thing
				 * to do is to start the block over.
				 */
				ip = bp->first;
			} else
				ip = ip->next;
		}
	}
#ifdef	DEBUG
	if (debug)
		fprintf(stderr, "\n");
#endif
	return changed;
}

void
peep(bp)
register BLOCK	*bp;
{
	extern	BLOCK	*fhead;
	bool	changed;

	peep1(bp);

	/*
	 * Loop until no more changes are made. After each change, do
	 * live/dead analysis or the data gets old. In each loop, make
	 * at most one change.
	 */
	for (changed = TRUE; changed ;rhealth(fhead)) {
		if (peep2(bp))
			changed = TRUE;
		else if (peep3(bp))
			changed = TRUE;
		else
			changed = FALSE;
	}
}
