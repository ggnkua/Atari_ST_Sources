/*
 *	ctype.h
 *
 * Patterned after the Eunuchs one by jrd
 * 12/30/86
 *
 */

				/* upcase alphabetic */
#define	_U	01
				/* lowcase alpha */
#define	_L	02
				/* numeric */
#define	_N	04
				/* whitespace */
#define	_S	010
				/* printable */
#define _P	020
				/* control */
#define _C	040
				/* hex digit */
#define _X	0100

extern	char	_ctype_[];

#define	isalpha(c)	((_ctype_)[c]&(_U|_L))
#define	isupper(c)	((_ctype_)[c]&_U)
#define	islower(c)	((_ctype_)[c]&_L)
#define	isdigit(c)	((_ctype_)[c]&_N)
#define	isxdigit(c)	((_ctype_)[c]&(_N|_X))
#define	isspace(c)	((_ctype_)[c]&_S)
#define ispunct(c)	((_ctype_)[c]&_P)
#define isalnum(c)	((_ctype_)[c]&(_U|_L|_N))
#define isprint(c)	((_ctype_)[c]&(_P|_U|_L|_N))
#define iscntrl(c)	((_ctype_)[c]&_C)
#define isascii(c)	((unsigned)(c)<=0177)
#define toupper(c)	((c)-'a'+'A')
#define tolower(c)	((c)-'A'+'a')
#define toascii(c)	((c)&0177)
