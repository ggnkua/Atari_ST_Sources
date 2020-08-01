
/*
 * Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Joseph M Treat
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#include "jas.h"

BRANCH *brlist = (BRANCH *) NULL;

add_brnch( cptr, where )
	CBUF *cptr;
	long where;
{
	register BRANCH *bp;

	bp = ALLO(BRANCH);

	bp->where = where;
	bp->cptr = cptr;
	bp->link = brlist;
	brlist = bp;
}

do_opt()
{
	BRANCH *bp, **lbp;
	register CBUF *cp;
	SYM *sp;
	register int changed = 0;
	extern long dottxt;

	/* 
	 * first take care of jsr's to external routines
	 */
	lbp = &brlist;
	for ( bp = brlist; bp != (BRANCH *) NULL; bp = bp->link ) {
		cp = bp->cptr;
		if ( cp->value.value != 0x61 /* BSR */ ) {
			lbp = &bp->link;
			continue;
		}
		sp = cp[1].value.psym;
		if ( sp->flags & SEGMT ) {
			lbp = &bp->link;
			continue;
		}
		/* 
		 * change it to a jsr
		 */
		cp[0].nbits = 16;
		cp[0].value.value = 0x4eb9;	/* jsr abs.l */
		cp[1].nbits = 32;
		cp[1].action = GENRELOC;
		dottxt += 4;
		/*
		 * move all text symbols after this point up four bytes
		 */
		fixsymval( bp->where, 4L, TXT );
		/*
		 * move the location of all branches after this point up
		 */
		{
			register BRANCH *xbp;

			for ( xbp = brlist; xbp != bp; xbp = xbp->link )
				xbp->where += 4;
		}
		/*
		 * remove this entry from the branch list
		 */
		*lbp = bp->link;
		/*
		 * don't bother to free it, it will just make later ALLO's 
		 * slower
		 */
	}
	/* 
	 * now do normal branches and remaining bsr's
	 */
	do {
		changed = 0;

		lbp = &brlist;
		for ( bp = brlist; bp != (BRANCH *) NULL; bp = bp->link ) {
			register long val;

			cp = bp->cptr;
			sp = cp[1].value.psym;

			val = cp[1].value.value + sp->value - bp->where;
			if ( val >= -128 && val <= 127 && val != 0 ) {
				lbp = &bp->link;
				continue;
			}
			/* 
			 * change it to a 16-bit displacement
			 */
			cp[0].nbits = 16;
			cp[0].value.value <<= 8;
			cp[1].nbits = 16;
			cp[1].action = GENPCREL;
			dottxt += 2;
			/*
			 * move all text symbols after this point up two bytes
			 */
			fixsymval( bp->where, 2L, TXT );
			/*
			 * move the location of all branches after this point up
			 */
			{
				register BRANCH *xbp;
	
				for ( xbp = brlist; xbp != bp; xbp = xbp->link )
					xbp->where += 2;
			}
			/*
			 * remove this entry from the branch list
			 */
			*lbp = bp->link;
			changed = 1;
		}

	} while ( changed );
}
