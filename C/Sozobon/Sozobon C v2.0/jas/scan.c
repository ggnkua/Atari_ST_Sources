
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
#include "scan.h"
#include "parse.h"

FILE *yyin;
int lastc = 0;
int ateof = 0;
int do_star = 1;

#ifdef MINIX
	/*
	 * this table is used to keep track of 'number' lables and references
	 * to them; e.g. bra 4f, bge 3b, etc
	 */

static int back_labs[10] = { 0 };
static int forw_labs[10] = { 0 };
static int lab_no = 101;

#endif

getnext()
{
	static char buf[80];
	static int cnt = 0, size = 0;
	static last = '\n';
	int sawstar = 0;
	extern char *fgets();

	do {
		while ( cnt >= size ) {
			if ( fgets( buf, 80, yyin ) == (char *) NULL ) {
				return EOF;
			}
			size = strlen( buf );
			cnt = 0;
			if ( do_star && last == '\n' ) {
				while ( buf[cnt] &&
						(buf[cnt]==' '||buf[cnt]=='\t'))
					cnt++;
				if ( sawstar || buf[cnt] == '*' ) {
					sawstar = 1;
					while ( buf[cnt] && buf[cnt] != '\n' )
						cnt++;
				}
			}
		}
		if (sawstar || (do_star && buf[cnt]=='\t' && buf[cnt+1]=='*')) {
			sawstar = 1;
			while ( buf[cnt] && buf[cnt] != '\n' )
				cnt++;
		}
	} while ( ! buf[cnt] );
	return last = buf[cnt++];
}

yygetc()
{
	register int c;

	if ( ateof )
		return 0;
	if ( lastc ) {
		c = lastc;
		lastc = 0;
	} else
		c = getnext();
	if ( c && c != EOF ) {
		return c;
	}
	ateof = 1;
	return 0;
}

yyungetc( c )
	int c;
{
	if ( lastc ) {
		char buf[32];
		extern int line;

		sprintf( buf, "%c & %c pushed back!!", lastc, c );
		error( line, buf );
	}
	lastc = c;
}

yylex()
{
	register int i;
	int c;
	struct lexacts *lp;
	char buf[16];
	extern YYSTYPE yylval;
	extern int nwords;
	extern struct lexacts actions[];
	extern struct reserved words[];
	extern INST *ifind();
	extern SYM *lookup();

	for ( c = yygetc(); c; c = yygetc() ) {
		lp = &actions[c];
		if ( lp->acts & L_EXTRA ) {
			i = yyprocess( c );
			if ( i == COMMENT )
				continue;
			else if ( i )
				return i;
		}
		if ( lp->acts & L_TOKEN ) {
			return lp->retval;
		}
		if ( lp->acts & L_BEGID ) {
			int tsz;
			char *nm, *tnm;
			extern yywidth;

			tsz = 16;
			nm = ALLOC(tsz,char);
			for (i = 0; c && (actions[c].acts & L_MIDID); ) {
				if ( i+2 > tsz ) {
					tsz += 16;
					nm = REALLO(nm,tsz,char);
				}
				nm[i++] = c;
				c = yygetc();
			}
			nm[i] = '\0';
			if ( c )
				yyungetc( c );
			tnm = STRCPY(nm);
			yymodify( tnm );
			yywidth = 0;

			tsz = strlen( tnm );
			if ( tsz >= 2 && tnm[tsz-2] == '.' ) {
				switch ( tnm[tsz-1] ) {
				case 'b':
					yywidth = 8;
					nm[tsz-2] = tnm[tsz-2] = '\0';
					break;
				case 'w':
					yywidth = 16;
					nm[tsz-2] = tnm[tsz-2] = '\0';
					break;
				case 'l':
					yywidth = 32;
					nm[tsz-2] = tnm[tsz-2] = '\0';
					break;
				}
			}
			
			{
				register int lo = 0;
				register int hi = nwords-2;
				register int d;
				register struct reserved *rp;

				while ( lo <= hi ) {
					i = (lo + hi) / 2;
					rp = &words[i];
					d = strcmp( tnm, rp->name );
					if (! strcmp( tnm, rp->name ) ) {
						yylval.val = rp->value;
#ifdef MINIX
						if ( rp->token == _DC || rp->token == _DS )  {
							if ( rp->value )
								yywidth = rp->value;
						}
#endif
						return rp->token;
					} else if ( d < 0 ) {
						hi = i-1;
					} else if ( d > 0 ) {
						lo = i+1;
					} else { /* wrong scope */
						break;
					}
				}
			}
			
			/*
			 * if it's not a reserved word, put the length back
			 */
			if ( yywidth != 0 )
				nm[tsz-2] = tnm[tsz-2] = '.';

			{
				register STMT *sp;
				register INST *ip;
				short misc;

				ip = ifind( tnm, &misc );
				if ( ip != (INST *) NULL ) {
					sp = ALLO(STMT);
					sp->inst = ip;
					sp->misc = misc;
					yylval.stmt = sp; 
					return INSTR;
				}
			}

			/*
			 * if it's not a mnemonic, take the length away
			 */
			if ( yywidth != 0 )
				nm[tsz-2] = '\0';

			yylval.sym = lookup( nm );
			free( tnm );
			free( nm );
			return lp->retval;
		}
		if ( lp->acts & L_DIGIT ) {
			extern long getnum();

#ifdef MINIX
			if ( c >= '0' && c <= '9' ) {
				int k;
				char lbuf[16];

				k = yygetc();
				switch ( k ) {
				case ':':
					yyungetc( ':' );
					k = c - '0';
					if ( forw_labs[k] ) {
						back_labs[k] = forw_labs[k];
						forw_labs[k] = 0;
					} else {
						back_labs[k] = lab_no++;
					}
					sprintf( lbuf, "L#%d", back_labs[k] );
					yylval.sym = lookup( lbuf );
					return NAME;
				case 'f':
					k = c - '0';
					if (! forw_labs[k] ) {
						forw_labs[k] = lab_no++;
					}
					sprintf( lbuf, "L#%d", forw_labs[k] );
					yylval.sym = lookup( lbuf );
					return NAME;
				case 'b':
					k = c - '0';
					if (! back_labs[k] ) {
						Yerror( "back reference to unknown numbered label" );
					}
					sprintf( lbuf, "L#%d", back_labs[k] );
					yylval.sym = lookup( lbuf );
					return NAME;
				default:
					yyungetc( k );
					break;
				}
			}
#endif
			for (i = 0; c && (actions[c].acts & L_DIGIT); i++) {
				buf[i] = c;
				c = yygetc();
			}
			buf[i] = '\0';
			if ( c )
				yyungetc( c );
			yylval.val = getnum( buf );
			return lp->retval;
		}
		/* L_SKIP */
	}
	return 0;
}

long
getnum( s )
	register char *s;
{
	register long val;
	register int base;

	switch ( *s ) {
	case '$':
		base = 16;
		s++;
		break;
	case '0':
#ifdef MINIX
		if ( s[1] == 'x' ) {
			s += 2;
			base = 16;
			break;
		}
#endif
	case '@':
		base = 8;
		s++;
		break;
	default:
		base = 10;
		break;
	}

	for ( val = 0L; *s; s++ ) {
		if ( *s >= '0' && *s <= '7' ) {
			val = val * base + ( *s - '0' );
		} else if ( *s >= '8' && *s <= '9' ) {
			if ( base == 8 )
				Yerror( "invalid octal constant" );
			val = val * base + ( *s - '0' );
		} else if ( *s >= 'a' && *s <= 'f' ) {
			if ( base == 8 )
				Yerror( "invalid octal constant" );
			if ( base == 10 )
				Yerror( "invalid decimal constant" );
			val = val * base + ( *s - 'a' + 10 );
		} else /* if ( *s >= 'A' && *s <= 'F' ) */ {
			if ( base == 8 )
				Yerror( "invalid octal constant" );
			if ( base == 10 )
				Yerror( "invalid decimal constant" );
			val = val * base + ( *s - 'A' + 10 );
		}

	}
	return val;
}
