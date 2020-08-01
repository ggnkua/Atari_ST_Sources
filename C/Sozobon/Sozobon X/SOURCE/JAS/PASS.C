
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

#define SCTALIGN 2

long dottxt = 0L, dotdat = 0L, dotbss = 0L, newdot = 0L;
long uptxt, updat, upbss, txtsize, datsize, bsssize;

SYM dot;

aspass1()
{
	extern jmp_buf err_buf;
	extern Optimize;

	dot.flags = TXT;
	dot.value = newdot = 0L;

	yyinit();
	if ( yyparse() ) {
		longjmp( err_buf, 1 );
	}

	chsegmt(TXT);

	if ( Optimize )
		do_opt();

	txtsize = dottxt;
	if ( uptxt = txtsize % SCTALIGN )
		txtsize += (uptxt = SCTALIGN - uptxt);
	datsize = dotdat;
	if ( updat = datsize % SCTALIGN )
		datsize += (updat = SCTALIGN - updat);
	bsssize = dotbss;
	if ( upbss = bsssize % SCTALIGN )
		bsssize += (upbss = SCTALIGN - upbss);

/* don't adjust the segments ...
	fixsymval( 0L, txtsize, DAT );
	fixsymval( 0L, txtsize + datsize, BSS );
...  */

	bufhead();
	symindex();
	headers();

	dot.value = newdot = 0L;
	translate( TXT, (int) uptxt );
	translate( DAT, (int) updat );
	dumpsym();
	dumprel();
}

chsegmt( segment )
	unsigned short segment;
{
	switch ( dot.flags & SEGMT ) {
	case TXT:
		dottxt = newdot;
		break;
	case DAT:
		dotdat = newdot;
		break;
	case BSS:
		dotbss = newdot;
		break;
	}

	switch ( segment & SEGMT ) {
	case TXT:
		newdot = dottxt;
		break;
	case DAT:
		newdot = dotdat;
		break;
	case BSS:
		newdot = dotbss;
		break;
	}

	dot.flags = segment;
	dot.value = newdot;
}
