
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

extern long newdot;
extern int line;

extern SYM dot;

CLIST	*t_head = (CLIST *) NULL,
	*d_head = (CLIST *) NULL;
CLIST	*txtptr = (CLIST *) NULL,
	*datptr = (CLIST *) NULL;

bufhead() 
{
	txtptr = t_head;
	datptr = d_head;
	if ( txtptr )
		txtptr->inx = 0;
	if ( datptr )
		datptr->inx = 0;
}

CBUF *
cget( seg )
	unsigned short seg;
{
	register CLIST *xc, *oxc;

	xc = seg == TXT ? txtptr : datptr;
	if ( xc == (CLIST *) NULL )
		return (CBUF *) NULL;

	if ( xc->inx >= xc->cnt ) {
		/*
		 * the current CLIST is used up
		 */
		oxc = xc;
		xc = xc->next;
		*( seg == TXT ? &txtptr : &datptr ) = xc;
		free( (char *) oxc );
		if (! xc ) {
			return (CBUF *) NULL;
		}
		xc->inx = 0;
	}
	return &xc->cblock[xc->inx++];
}

CBUF *
generate( n, act, val, psym )
	short n, act;
	long val;
	SYM *psym;
{
	register CLIST *xc;
	register CBUF *cp;

	if ( act == GENRELOC && psym == (SYM *) NULL )
		act = GENVALUE;

/* out for now ...
	fprintf( stderr, "generate( [%x], %d, %d, %lx, ",
						dot.flags, n, act, val );
	if ( psym ) 
		fprintf( stderr, "\"%.8s\" )\n", psym->name );
	else
		fprintf( stderr, "\"\" )\n" );
... */

	switch ( dot.flags ) {
	case TXT:
		if ( txtptr == (CLIST *) NULL )
			txtptr = t_head = ALLO(CLIST);
		xc = txtptr;
		break;
	case BSS:
		if ( act != GENVALUE || val != 0L || psym != (SYM *) NULL )
			Yerror( "Attempt to initialize bss" );
		newdot += n / 8;
		return;
	case DAT:
		if ( datptr == (CLIST *) NULL )
			datptr = d_head = ALLO(CLIST);
		xc = datptr;
		break;
	}

	if ( xc->cnt == CBLEN || (act == GENBRNCH && xc->cnt >= CBLEN-1) ) {
		xc->next = ALLO(CLIST);
		xc = xc->next;
		*( dot.flags == TXT ? &txtptr : &datptr ) = xc;
		xc->cnt = 0;
		xc->next = (CLIST *) NULL;
	}

	cp = &xc->cblock[xc->cnt++];

	if ( psym ) 
		psym->flags |= DEFINED;
	cp->action = act == GENBRNCH ? GENSTMT : act;
	cp->nbits = n;
	cp->value.value = val;
	cp->value.psym = psym;
	cp->line = line;

	newdot += n / 8;
	return cp;
}

zeros( n )
	register long n;
{
	if ( newdot & 1 ) {
		generate( 8, GENVALUE, 0L, (SYM *) NULL );
		n--;
	}
/* out for now ...
	for (; n >= 4; n -= 4 )
		generate(32, GENVALUE, 0L, (SYM *) NULL );
... */
	for (; n >= 2; n -= 2 )
		generate( 16, GENVALUE, 0L, (SYM *) NULL );
	if ( n )
		generate( 8, GENVALUE, 0L, (SYM *) NULL );
}
