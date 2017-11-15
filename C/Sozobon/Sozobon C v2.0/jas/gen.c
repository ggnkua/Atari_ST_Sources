
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

geninst( sp )
	STMT *sp;
{
	register OPERAND *op;
	register char *cp;
	register short nbits = 0;
	register long fill = 0L;
	register short emode, ereg;
	OPERAND *eff[2];
	int which, do_immediate = 0;
	CBUF *cbp;
	extern int line;
	extern long newdot;
	extern Optimize;
	extern CBUF *generate();

	findinst( sp );
	eff[0] = eff[1] = (OPERAND *) NULL;

	if ( sp->op0 && sp->op0->mode == O_IMM )
		do_immediate = 1;

	for ( cp = sp->inst->format; *cp; cp++ ) {
		if ( *cp == 'o' ) {
			do {
				cp++;
				fill = ( fill << 3 ) | ( *cp - '0' );
				nbits += 3;
			} while ( cp[1] >= '0' && cp[1] <= '7' );
		} else if ( *cp == 'x' ) {
			do {
				cp++;
				if ( *cp <= '9' )
					fill = ( fill << 4 ) | ( *cp - '0' );
				else
					fill = ( fill << 4 ) | (*cp - 'a' + 10);
				nbits += 4;
			} while ( (cp[1] >= '0' && cp[1] <= '9') ||
						(cp[1] >= 'a' && cp[1] <= 'f'));

		} else if ( *cp == '0' ) {
			fill = ( fill << 1 );
			nbits++;
		} else if ( *cp == '1' ) {
			fill = ( fill << 1 ) | 1;
			nbits++;
		} else if ( *cp == '$' ) {
			switch ( *++cp ) {
			case 's':
				fill = ( fill << 2 ) |
						( ( sp->misc & (S_BWL) ) >> 1 );
				nbits += 2;
				break;
			case 'c':
				fill = ( fill << 4 ) | ( sp->misc >> 4 );
				nbits += 4;
				break;
			case 'd':
				fill = ( fill << 1 ) |
						( ( sp->misc & 0x8 ) >> 3 );
				nbits++;
				break;
			}
		} else if ( *cp == '%' ) {
			OPERAND *mp;

			cp++;
			if ( *cp == '0' ) {
				which = 0;
				op = sp->op0;
				cp++;
			} else if ( *cp == '1' ) {
				which = 1;
				op = sp->op1;
				cp++;
			} else if ( *cp >= 'A' && *cp <= 'Z' ) {
				which = 1;
				op = sp->op1;
			} else /* if ( *cp >= 'a' && *cp <= 'z' ) */ {
				which = 0;
				op = sp->op0;
			}

			switch ( *cp ) {
			case 'r':
				fill = ( fill << 3 ) | (op->reg & 0x7 );
				nbits += 3;
				break;
			case 'q':
				fill = ( fill << 3 ) | (op->expr.value & 0x7);
				nbits += 3;
				do_immediate = 0;
				break;
			case 'k':
				fill = ( fill << 8 ) | (op->expr.value & 0xff);
				nbits += 8;
				do_immediate = 0;
				break;
			case 'v':
				fill = ( fill << 4 ) | (op->expr.value & 0x0f);
				nbits += 4;
				do_immediate = 0;
				break;
			case 'm':
				if ( nbits % 8 )
					error( line, "internal alignment" );
				generate( nbits, GENSTMT, fill, (SYM *) NULL );
				nbits = 0;
				fill = 0L;
				if ( op->mode == O_DN || op->mode == O_AN )
					op->expr.value = 1L << op->reg;
				op->mode = O_REGS;
				mp = ( which == 0 ) ? sp->op1 : sp->op0;
				if ( mp->mode == O_PRE ) {
					/*
					 * we must reverse the bits !GAG!
					 */
					int i, k;

					k = op->expr.value;
					for ( i = 0; i < 16; i++ ) {
						fill <<= 1;
						if ( k & 1 )
							fill |= 1;
						k >>= 1;
					}
					generate( 16, GENVALUE, fill,
								(SYM *) NULL );
					fill = 0L;
				} else {
					generate( 16, GENVALUE, op->expr.value,
								(SYM *) NULL );
				}
				break;
			case 'd':
				if (! Optimize ) {
					fill <<= 8;
					nbits += 8;
					if ( nbits % 8 )
						error( line,
							"internal alignment" );
					generate( nbits, GENSTMT, fill,
								(SYM *) NULL);
					nbits = 0;
					fill = 0L;
					generate( 16, GENPCREL, op->expr.value,
								op->expr.psym);
					break;
				}
				if ( nbits != 8 )
					error( line, "internal alignment" );
				cbp = generate(8, GENBRNCH, fill, (SYM *) NULL);
				nbits = 0;
				fill = 0L;

				generate( 8, GENPCREL, op->expr.value,
								op->expr.psym);
				add_brnch( cbp, newdot );
				break;
			case 'D':
				if ( nbits % 8 )
					error( line, "internal alignment" );
				generate( nbits, GENSTMT, fill, (SYM *) NULL );
				nbits = 0;
				fill = 0L;
				generate( 16, GENPCREL, op->expr.value,
								op->expr.psym);
				break;
			case 'L':
				if ( nbits % 8 )
					error( line, "internal alignment" );
				generate( nbits, GENSTMT, fill, (SYM *) NULL );
				nbits = 0;
				fill = 0L;
				generate( 16, GENVALUE, op->expr.value,
								(SYM *) NULL );
				do_immediate = 0;
				break;
			case 'f':
			case 'e':
				emode = ereg = 0;
				switch ( op->mode ) {
				case O_DN:
					emode = 0x0;
					ereg = op->reg & 0x7;
					break;
				case O_AN:
					emode = 0x1;
					ereg = op->reg & 0x7;
					break;
				case O_INDR:
					emode = 0x2;
					ereg = op->reg & 0x7;
					break;
				case O_POST:
					emode = 0x3;
					ereg = op->reg & 0x7;
					break;
				case O_PRE:
					emode = 0x4;
					ereg = op->reg & 0x7;
					break;
				case O_DISP:
					emode = 0x5;
					ereg = op->reg & 0x7;
					eff[which] = op;
					break;
				case O_INDX:
					emode = 0x6;
					ereg = op->reg & 0x7;
					eff[which] = op;
					break;
#ifdef MINIX
				case O_SABS:
					emode = 0x7;
					ereg = 0x0;
					eff[which] = op;
					break;
#endif
				case O_ABS:
					emode = 0x7;
					ereg = 0x1;
					eff[which] = op;
					break;
				case O_PCRL:
					emode = 0x7;
					ereg = 0x2;
					eff[which] = op;
					break;
				case O_PCIX:
					emode = 0x7;
					ereg = 0x3;
					eff[which] = op;
					break;
				case O_IMM:
					emode = 0x7;
					ereg = 0x4;
					break;
				}
				if ( *cp == 'e' ) {
					fill = ( fill << 3 ) | emode;
					fill = ( fill << 3 ) | ereg;
				} else {
					fill = ( fill << 3 ) | ereg;
					fill = ( fill << 3 ) | emode;
				}
				nbits += 6;
				break;
			}
		} 
	}
	if ( nbits % 8 )
		error( line, "internal alignment" );
	if ( nbits ) {
		generate( nbits, GENSTMT, fill, (SYM *) NULL );
		nbits = 0;
	}
	fill = 0L;
	if ( do_immediate ) {
		int size;
		op = sp->op0;

		size = sp->misc & (S_BWL);
		if ( size == S_B ) {
			generate( 8, GENVALUE, 0L, (SYM *) NULL );
		}
		generate( size << 3, GENRELOC, op->expr.value, op->expr.psym );
	}
	for ( which = 0; which <= 1; which++ ) {
		if ( eff[which] == (OPERAND *) NULL )
			continue;
		op = eff[which];
		switch ( op->mode ) {
		case O_DISP:
			generate( 16, GENRELOC, op->expr.value, op->expr.psym );
			break;
		case O_INDX:
			fill = op->inx & 0x0f;
			fill = ( fill << 4 ) | ((op->inx & 0x10) >> 1);
			generate(8, GENVALUE, fill, (SYM *) NULL );
			generate( 8, GENRELOC, op->expr.value, op->expr.psym );
			break;
#ifdef MINIX
		case O_SABS:
			if ( sp->inst->flags & F_PC )
				generate( 16, GENPCREL, op->expr.value,
								op->expr.psym );
			else
				generate( 16, GENRELOC, op->expr.value,
								op->expr.psym );
			break;
#endif
		case O_ABS:
			if ( sp->inst->flags & F_PC )
				generate( 16, GENPCREL, op->expr.value,
								op->expr.psym );
			else
				generate( 32, GENRELOC, op->expr.value,
								op->expr.psym );
			break;
		case O_PCRL:
#ifdef MINIX
			if ( op->expr.psym )
				generate( 16, GENPCREL, op->expr.value,
								op->expr.psym );
			else
				generate( 16, GENVALUE, op->expr.value,
								(SYM *) NULL );
#else
			generate( 16, GENVALUE, op->expr.value, (SYM *) NULL );
#endif
			break;
		case O_PCIX:
			fill = op->inx & 0x0f;
			fill = ( fill << 4 ) | ((op->inx & 0x10) >> 1);
			generate(8, GENVALUE, fill, (SYM *) NULL );
#ifdef MINIX
			if ( op->expr.psym )
				generate( 8, GENPCREL, op->expr.value,
								op->expr.psym );
			else
				generate( 8, GENVALUE, op->expr.value,
								(SYM *) NULL );
#else
			generate( 8, GENVALUE, op->expr.value, (SYM *) NULL );
#endif
			break;
		}
	}
}

findinst( sp )
	STMT *sp;
{
	register INST *ip;
	register INST *jp;

	ip = sp->inst;
	for ( ; ; ) {
		if (! inst_ok( sp ) ) {
			return;
		}
		jp = ip+1;
		if (! strcmp( jp->mnemon, ip->mnemon ) ) {
			sp->inst = ip = jp;
			continue;
		}
		break;
	}
	Yerror( "illegal instruction" );
}

inst_ok( sp )
	register STMT *sp;
{
	register INST *ip = sp->inst;
	register unsigned short size;
	extern Optimize;

	if (! Optimize ) {
		/*
		 * if we're not optimizing, don't change jsr's to bsr's
		 */
		if (! strncmp( ip->mnemon, "jsr", 3 ) )
			if (! strncmp( ip->format, "x61", 3 ) )
				return -18;
	}

	if ( ip->op0 != O_NONE && sp->op0 == (OPERAND *) NULL )
		return -1;
	if ( ip->op1 != O_NONE && sp->op1 == (OPERAND *) NULL )
		return -2;
	if ( sp->op1 && ip->op1 == O_NONE )
		return -3;
	if ( sp->op0 ) {
		if ( ip->op0 == O_NONE )
			return -4;
		if ( ( sp->op0->mode & ip->op0 ) != sp->op0->mode )
			return -5;
	}
	if ( sp->op1 ) {
		if ( ip->op1 == O_NONE )
			return -6;
		if ( ( sp->op1->mode & ip->op1 ) != sp->op1->mode )
			return -7;
	}
	size = sp->misc & (S_BWL);
	if ( ( size & ip->size ) != size )
		return -8;
	if ( ip->flags & F_Q ) {
		long val = sp->op0->expr.value;

		if ( sp->op0->expr.psym )
			return -9;
		if ( val < 1 || val > 8 )
			return -10;
	}
	if ( ip->flags & F_MQ ) {
		long val = sp->op0->expr.value;

		if ( sp->op0->expr.psym )
			return -11;
		if ( val < -128 || val > 127 )
			return -12;
	}
	if ( ip->flags & F_TV ) {
		long val = sp->op0->expr.value;

		if ( sp->op0->expr.psym )
			return -13;
		if ( val < 0 || val > 15 )
			return -14;
	}
	if ( ip->flags & F_TXT ) {
		OPERAND *op = sp->op0;

		if ( op->mode == O_DN ) /* the db$c instruction */
			op = sp->op1;
		switch ( op->mode ) {
		case O_DISP: case O_INDX:
			if ( op->expr.psym ) {
				switch ( op->expr.psym->flags & SEGMT ) {
				case 0: case TXT:
					break;
				default:
					return -15;
				}
			}
			break;
		case O_ABS:
			if ( op->expr.psym == (SYM *) NULL )
				return -16;
			switch ( op->expr.psym->flags & SEGMT ) {
			case 0: case TXT:
				break;
			default:
				return -17;
			}
			break;
		}
	}

	/*
	 * set the default size, if none is specified
	 */
	if ( size == 0 )
		sp->misc |= ( ip->flags & (S_BWL) );

	return 0;
}
