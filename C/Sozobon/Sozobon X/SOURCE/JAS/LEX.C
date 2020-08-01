
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

extern do_star;

struct reserved words[] = {
	/*
	 * alphabetized list of reserved words
	 */
#ifdef MINIX
	{ ".align",	_ALIGN,		0 },
	{ ".ascii",	_DC,		8 },
	{ ".asciz",	_ASCII,		0 },
#endif
	{ ".bss",	_BSS,		0 },
	{ ".comm",	_COMM,		0 },
	{ ".data",	_DATA,		0 },
#ifdef MINIX
	{ ".data1",	_DC,		8 },
	{ ".data2",	_DC,		16 },
	{ ".data4",	_DC,		32 },
#endif
	{ ".dc",	_DC,		0 },
#ifdef MINIX
	{ ".define",	_GLOBL,		0 },
#endif
	{ ".ds",	_DS,		0 },
	{ ".end",	END,		0 },
	{ ".equ",	_EQU,		0 },
	{ ".even",	_EVEN,		0 },
#ifdef MINIX
	{ ".extern",	_GLOBL,		0 },
#endif
	{ ".globl",	_GLOBL,		0 },
	{ ".org",	_ORG,		0 },
#ifdef MINIX
	{ ".rom",	_DATA,		0 },
	{ ".sect",	_SECT,		0 },
	{ ".space",	_DS,		8 },
#endif
	{ ".text",	_TEXT,		0 },
	{ "a0",		REG,		8 },
	{ "a1",		REG,		9 },
	{ "a2",		REG,		10 },
	{ "a3",		REG,		11 },
	{ "a4",		REG,		12 },
	{ "a5",		REG,		13 },
	{ "a6",		REG,		14 },
	{ "a7",		REG,		15 },
	{ "bss",	_BSS,		0 },
	{ "ccr",	SREG,		O_CCR },
	{ "comm",	_COMM,		0 },
	{ "d0",		REG,		0 },
	{ "d1",		REG,		1 },
	{ "d2",		REG,		2 },
	{ "d3",		REG,		3 },
	{ "d4",		REG,		4 },
	{ "d5",		REG,		5 },
	{ "d6",		REG,		6 },
	{ "d7",		REG,		7 },
	{ "data",	_DATA,		0 },
	{ "dc",		_DC,		0 },
	{ "ds",		_DS,		0 },
	{ "end",	END,		0 },
	{ "equ",	_EQU,		0 },
	{ "even",	_EVEN,		0 },
	{ "globl",	_GLOBL,		0 },
	{ "org",	_ORG,		0 },
	{ "pc",		PC,		0 },
	{ "sp", 	REG,		15 },
	{ "sr",		SREG,		O_SR },
	{ "text",	_TEXT,		0 },
	{ "usp",	SREG,		O_USP },
	{ "", 0, 0 }
};

int nwords = (sizeof words) / (sizeof (struct reserved));

struct lexacts actions[256];

struct lextab lextab[] = {
#ifdef MINIX
	{ '=', { L_TOKEN, _EQU } },
#endif
	{ '\t', { L_SKIP, 0 } },
	{ '\n', { L_TOKEN, NL } },
	{ '\r', { L_SKIP, 0 } },
	{ ' ', { L_SKIP, 0 } },
	{ '"', { L_EXTRA|L_TOKEN, ERR } },
	{ '\'', { L_EXTRA|L_TOKEN, ERR } },
	{ '%', { L_TOKEN, MOD } },
	{ '(', { L_TOKEN, LP } },
	{ ')', { L_TOKEN, RP } },
	{ '*', { L_TOKEN, STAR } },
	{ '-', { L_TOKEN, MINUS } },
	{ '+', { L_TOKEN, PLUS } },
	{ ',', { L_TOKEN, COMMA } },
	{ '/', { L_EXTRA|L_TOKEN, DIV } },
	{ '~', { L_EXTRA|L_TOKEN, NOT } },
	{ '#', { L_TOKEN, POUND } },
	{ '@', { L_EXTRA|L_DIGIT, NUMBER } },
	{ '$', { L_EXTRA|L_DIGIT, NUMBER } },
	{ '0', { L_MIDID|L_DIGIT, NUMBER } },
	{ '1', { L_MIDID|L_DIGIT, NUMBER } },
	{ '2', { L_MIDID|L_DIGIT, NUMBER } },
	{ '3', { L_MIDID|L_DIGIT, NUMBER } },
	{ '4', { L_MIDID|L_DIGIT, NUMBER } },
	{ '5', { L_MIDID|L_DIGIT, NUMBER } },
	{ '6', { L_MIDID|L_DIGIT, NUMBER } },
	{ '7', { L_MIDID|L_DIGIT, NUMBER } },
	{ '8', { L_MIDID|L_DIGIT, NUMBER } },
	{ '9', { L_MIDID|L_DIGIT, NUMBER } },
	{ ':', { L_TOKEN, COLON } },
	{ ';', { L_TOKEN|L_EXTRA, COMMENT } },
#ifdef MINIX
	{ '!', { L_TOKEN|L_EXTRA, COMMENT } },
#endif
	{ '<', { L_EXTRA|L_TOKEN, ERR } },
	{ '>', { L_EXTRA|L_TOKEN, ERR } },
	{ 'A', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'B', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'C', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'D', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'E', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'F', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'G', { L_BEGID|L_MIDID, NAME } },
	{ 'H', { L_BEGID|L_MIDID, NAME } },
	{ 'I', { L_BEGID|L_MIDID, NAME } },
	{ 'J', { L_BEGID|L_MIDID, NAME } },
	{ 'K', { L_BEGID|L_MIDID, NAME } },
	{ 'L', { L_BEGID|L_MIDID, NAME } },
	{ 'M', { L_BEGID|L_MIDID, NAME } },
	{ 'N', { L_BEGID|L_MIDID, NAME } },
	{ 'O', { L_BEGID|L_MIDID, NAME } },
	{ 'P', { L_BEGID|L_MIDID, NAME } },
	{ 'Q', { L_BEGID|L_MIDID, NAME } },
	{ 'R', { L_BEGID|L_MIDID, NAME } },
	{ 'S', { L_BEGID|L_MIDID, NAME } },
	{ 'T', { L_BEGID|L_MIDID, NAME } },
	{ 'U', { L_BEGID|L_MIDID, NAME } },
	{ 'V', { L_BEGID|L_MIDID, NAME } },
	{ 'W', { L_BEGID|L_MIDID, NAME } },
	{ 'X', { L_BEGID|L_MIDID, NAME } },
	{ 'Y', { L_BEGID|L_MIDID, NAME } },
	{ 'Z', { L_BEGID|L_MIDID, NAME } },
	{ '.', { L_BEGID|L_MIDID, NAME } },
	{ '_', { L_BEGID|L_MIDID, NAME } },
	{ 'a', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'b', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'c', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'd', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'e', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'f', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
	{ 'g', { L_BEGID|L_MIDID, NAME } },
	{ 'h', { L_BEGID|L_MIDID, NAME } },
	{ 'i', { L_BEGID|L_MIDID, NAME } },
	{ 'j', { L_BEGID|L_MIDID, NAME } },
	{ 'k', { L_BEGID|L_MIDID, NAME } },
	{ 'l', { L_BEGID|L_MIDID, NAME } },
	{ 'm', { L_BEGID|L_MIDID, NAME } },
	{ 'n', { L_BEGID|L_MIDID, NAME } },
	{ 'o', { L_BEGID|L_MIDID, NAME } },
	{ 'p', { L_BEGID|L_MIDID, NAME } },
	{ 'q', { L_BEGID|L_MIDID, NAME } },
	{ 'r', { L_BEGID|L_MIDID, NAME } },
	{ 's', { L_BEGID|L_MIDID, NAME } },
	{ 't', { L_BEGID|L_MIDID, NAME } },
	{ 'u', { L_BEGID|L_MIDID, NAME } },
	{ 'v', { L_BEGID|L_MIDID, NAME } },
	{ 'w', { L_BEGID|L_MIDID, NAME } },
#ifdef MINIX
	{ 'x', { L_BEGID|L_MIDID|L_DIGIT, NAME } },
#else
	{ 'x', { L_BEGID|L_MIDID, NAME } },
#endif
	{ 'y', { L_BEGID|L_MIDID, NAME } },
	{ 'z', { L_BEGID|L_MIDID, NAME } }
};

struct lexacts deflexact = { L_TOKEN, ERR };

static int lextabsize = (sizeof lextab) / (sizeof (struct lextab));

yyinit()
{
	{
		register struct lexacts *ap;
		
		for ( ap = actions; ap < &actions[256]; ap++ )
			*ap = deflexact;
	}
	{
		register struct lextab *lp;
		register struct lextab *ep;
		
		ep = &lextab[lextabsize];
		for ( lp = lextab; lp < ep; lp++ )
			actions[lp->select] = lp->action;
	}
}

yyprocess( c )
	register char c;
{
	register int i;
	char buf[256];
	extern YYSTYPE yylval;
	extern int line;

	switch ( c ) {
	case '/':
		c = yygetc();
		if ( c != '*' ) {
			yyungetc( c );
			return 0;
		}
		do_star = 0;
		for ( c = yygetc(); c; c = yygetc()) {
			if ( c == '\n' ) {
				line++;
			} else {
				if ( c == '*' ) {
					c = yygetc();
					if ( c == '/' ) {
						do_star = 1;
						return COMMENT;
					}
					yyungetc( c );
				}
			}
		}
		error( line, "non-terminated comment");

	case '\'':
		do_star = 0;
		c = yygetc();
		for ( i = 0; c; ) {
			buf[i++] = c;
			if ( c == '\\' ) 
				buf[i++] = yygetc();
			c = yygetc();
			if ( c == '\'' )
				break;
		}
		if (! c )
			error( line, "non-terminated string" );
		buf[i] = '\0';
		yylval.str = STRCPY( buf );
		do_star = 1;
		return STRING;
	case '"':
		do_star = 0;
		c = yygetc();
		for (i = 0; c; ) {
			buf[i++] = c;
			if ( c == '\\' )
				buf[i++] = yygetc();
			c = yygetc();
			if ( c == '"' )
				break;
		}
		if (! c )
			error( line, "non-terminated string" );
		buf[i] = '\0';
		yylval.str = STRCPY( buf );
		do_star = 1;
		return STRING;
	case '<':
		c = yygetc();
		if ( c == '<' )
			return LSH;
		yyungetc( c );
		return 0;
	case '>':
		c = yygetc();
		if ( c == '>' )
			return RSH;
		yyungetc( c );
		return 0;
	case '@':
		c = yygetc();
		if ( c >= '0' && c <= '7' ) {
			yyungetc( c );
			return 0;
		}
		return ERR;
	case '$':
		c = yygetc();
		if ( c >= '0' && c <= '9' ||
				c >= 'a' && c <= 'f' ||
						c >= 'A' && c <= 'F' ) {
			yyungetc( c );
			return 0;
		}
		return ERR;
#ifdef MINIX
	case '!':
#endif
	case ';':
		do_star = 0;
		do {
			c = yygetc();
		} while ( c && c != '\n' );
		if ( c )
			yyungetc( c );
		do_star = 1;
		return COMMENT;
	default:
		return 0;
	}
}

yymodify( buf )
	char *buf;
{
	register char *cp;

	for ( cp = buf; *cp; cp++ )
		if ( isupper( *cp ) )
			*cp = toupper( *cp );
}
