
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

#define R_ABS	0
#define R_DAT	1
#define R_TXT	2
#define R_BSS	3
#define R_EXT	4
#define R_UPPER	5
#define R_FIRST	7

#define RBLEN 256

typedef struct _reloc {
	struct _reloc *next;
	unsigned short cnt;
	unsigned short reloc[RBLEN];
} RELOC;
	
RELOC *relptr = (RELOC *) NULL;
RELOC *curptr;

extern SYM dot;
extern long newdot;

#define SEG(p) ( (p)->flags & SEGMT )

#ifdef UNIXHOST
char *mklowbyte(), *mklowshort(), *mklowlong();
#endif

translate( seg, null )
	unsigned short seg;
	int null;
{
	register unsigned short stype;
	register CBUF *code;
	register unsigned short rval, orval;
	int havebyte = 0;
	int cline = 0;
	extern CBUF *cget();

	if ( relptr == (RELOC *) NULL ) {
		relptr = ALLO(RELOC);
		curptr = relptr;
	}

	rval = R_ABS;
	for ( ; code = cget( seg ); newdot += code->nbits / 8 ) {
		cline = code->line;
		orval = rval;
		rval = R_ABS;
		if ( code->action == GENSTMT )
			dot.value = newdot;
		
		stype = UNK;
		if ( code->value.psym ) {
			stype = SEG(code->value.psym);
			switch ( stype ) {
			case DAT:
				rval = R_DAT;
				break;
			case TXT:
				rval = R_TXT;
				break;
			case BSS:
				rval = R_BSS;
				break;
			default:
				rval = R_EXT;
				break;
			}
			if ( code->value.psym->flags & EQUATED ) {
				stype = EQUATED;
				rval = R_ABS;
			}
		}
		if ( code->action == GENPCREL ) {
			if ( code->value.psym && stype != TXT )
				warn( cline, "illegal pc-relative reference" );
			rval = R_ABS;
			stype = UNK;
			code->value.value -= (dot.value + 2);
		}

		if ( code->value.psym ) {
			if ( code->value.psym->flags & (SEGMT|EQUATED) )
				code->value.value += code->value.psym->value;
		}

		/* don't check anything right now ...
			chkvalue( code );
		... */

#ifndef UNIXHOST
		code->value.value <<= (32 - code->nbits);
		output( (char *) &code->value.value, sizeof (char),
							(int) code->nbits/8 );
#else
		switch (code->nbits) {
		case 8:
			output( mklowbyte(code->value.value), sizeof (char),
				1 );
			break;
		case 16:
			output( mklowshort(code->value.value), sizeof (char),
				2 );
			break;
		case 32:
			output( mklowlong(code->value.value), sizeof (char),
				4 );
			break;
		default:
			error( cline, "internal size error" );
		}
#endif
		if ( rval == R_EXT )
			rval |= ( code->value.psym->index << 3 );

		if ( havebyte == 1 && code->nbits != 8 )
			error( cline, "relocation alignment error" );
		if ( havebyte == 1 && rval == R_ABS && orval == R_FIRST )
			rval = R_FIRST;
		if ( havebyte == 1 && rval != orval )
			error( cline, "bytes not separately relocatable" );

		if ( code->action == GENSTMT && rval != R_ABS )
			error( cline, "relocatable operation word" );
		if ( code->action == GENSTMT )
			rval = R_FIRST;
		if ( code->nbits == 8 && havebyte == 0 ) {
			if ( rval != R_ABS && rval != R_FIRST )
				error( cline,
					"bytes not separately relocatable" );
			havebyte = 1;
			continue;
		}
		havebyte = 0;

		if ( code->nbits == 32 ) {
			addrel( R_UPPER );
		}
		addrel( rval );
	}

	dot.value = newdot += null;
	while ( null-- ) {
		char zip = 0;

		output( (char *) &zip, sizeof (char), 1 );
		if ( havebyte && rval != R_ABS )
			error( cline, "bytes not separately relocatable" );
		if ( havebyte == 0 ) {
			havebyte = 1;
			rval = R_ABS;
			continue;
		}
		havebyte = 0;
		addrel( rval );
	}
	if ( havebyte ) 
		error( cline, "internal relocation alignment error" );
}

addrel( rval )
	unsigned short rval;
{
	if ( curptr->cnt == RBLEN ) {
		curptr->next = ALLO(RELOC);
		curptr = curptr->next;
	}
	curptr->reloc[curptr->cnt++] = rval;
}

dumprel()
{
	register RELOC *rp;

	for ( rp = relptr; rp; rp = rp->next ) {
#ifdef UNIXHOST
		swapw( rp->reloc, rp->cnt );
#endif
		output( (char *) rp->reloc, sizeof (unsigned short),
								(int) rp->cnt );
	}
	return;
} 

chkvalue( code )
	CBUF *code;
{
	long value;

	value = code->value.value;

	if ( code->nbits != 32 ) {
		value <<= (32 - code->nbits);
		value >>= (32 - code->nbits);
		if ( value != code->value.value )
			warn( code->line, "value overflows byte/word" );
	}
}
