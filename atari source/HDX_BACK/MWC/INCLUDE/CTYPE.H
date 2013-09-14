/*
 * ctype.h -- routines to classify character types.
 *
 * Copyright (c) 1981-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#ifndef	_U

extern char _ctype[];

/* Bits classifications */
#define	_U	01		/* Upper-case alphabetic */
#define	_L	02		/* Lower-case alphabetic */
#define	_A	(_U|_L)		/* Alphabetic */
#define	_D	010		/* Digits */
#define	_S	020		/* White-space character */
#define	_P	040		/* Punctuation character */
#define	_C	0100		/* Control character */
#define	_X	0200		/* Printable, but nothing else */

#define	isalpha(c)	(_ctype[(c)+1]&_A)
#define	isupper(c)	(_ctype[(c)+1]&_U)
#define	islower(c)	(_ctype[(c)+1]&_L)
#define	isdigit(c)	(_ctype[(c)+1]&_D)
#define	isalnum(c)	(_ctype[(c)+1]&(_A|_D))
#define	isspace(c)	(_ctype[(c)+1]&_S)
#define	ispunct(c)	(_ctype[(c)+1]&_P)
#define	isprint(c)	(_ctype[(c)+1]&(_P|_X|_A|_D))
#define	iscntrl(c)	(_ctype[(c)+1]&_C)
#define	isascii(c)	(((c)&~0177)==0)
#define	_tolower(c)	((c)|('a'-'A'))
#define	_toupper(c)	((c)&~('a'-'A'))
#define	toascii(c)	((c)&0177)
#endif

/* End of ctype.h */
