/* The <ctype.h> header file defines some macros used to identify characters.
 * It works by using a table stored in ctype.c.  When a character is presented
 * to one of these macros, the character is used as an index into the table
 * (__ctype) to retrieve a byte.  The relevant bit is then extracted.
 */

#ifndef _CTYPE_H
#define _CTYPE_H

extern unsigned char __ctype[];	/* property array declared in ctype.c */
extern unsigned char __tmp;	/* scratch variable declared in ctype.c */

#define _U		0001	/* this bit is for upper-case letters [A-Z] */
#define _L		0002	/* this bit is for lower-case letters [a-z] */
#define _N		0004	/* this bit is for numbers [0-9] */
#define _S		0010	/* this bit is for white space \t \n \f etc */
#define _P		0020	/* this bit is for punctuation characters */
#define _C		0040	/* this bit is for control characters */
#define _X		0100	/* this bit is for hex digits [a-f] and [A-F]*/
#define _SP		0200	/* this bit is for the space character only */

/* Function Prototypes (have to go before the macros). */
#ifndef _ANSI_H
#include <ansi.h>
#endif

_PROTOTYPE( int isalnum, (int  __c)  );	/* alphanumeric [a-z], [A-Z], [0-9] */
_PROTOTYPE( int isalpha, (int  __c)  );	/* alphabetic */
_PROTOTYPE( int iscntrl, (int  __c)  );	/* control characters */
_PROTOTYPE( int isdigit, (int  __c)  );	/* digit [0-9] */
_PROTOTYPE( int isgraph, (int  __c)  );	/* graphic character */
_PROTOTYPE( int islower, (int  __c)  );	/* lower-case letter [a-z] */
_PROTOTYPE( int isprint, (int  __c)  );	/* printable character */
_PROTOTYPE( int ispunct, (int  __c)  );	/* punctuation mark */
_PROTOTYPE( int isspace, (int  __c)  );	/* white space sp, \f, \n, \r, \t, \v*/
_PROTOTYPE( int isupper, (int  __c)  );	/* upper-case letter [A-Z] */
_PROTOTYPE( int isxdigit,(int  __c)  );	/* hex digit [0-9], [a-f], [A-F] */

/* Macros for identifying character classes. */
#define isalnum(c)	((__ctype+1)[c]&(_U|_L|_N))
#define isalpha(c)	((__ctype+1)[c]&(_U|_L))
#define iscntrl(c)	((__ctype+1)[c]&_C)
#define isdigit(c)	((__ctype+1)[c]&_N)
#define isgraph(c)	((__ctype+1)[c]&(_P|_U|_L|_N))
#define islower(c)	((__ctype+1)[c]&_L)
#define isprint(c)	((__ctype+1)[c]&(_SP|_P|_U|_L|_N))
#define ispunct(c)	((__ctype+1)[c]&_P)
#define isspace(c)	((__ctype+1)[c]&_S)
#define isupper(c)	((__ctype+1)[c]&_U)
#define isxdigit(c)	((__ctype+1)[c]&(_N|_X))
#define isascii(c)	((unsigned) ((c) + 1) < 129)

/* The following two macros are weird to keep the Language Police at bay.
 * The macro 'tolower' only affects upper case letters, and 'toupper'
 * only affects lower case letters.  Neither one is permitted to evaluate
 * its argument more than once.  Thus a simple definition like:
 *
 *	#define tolower(c)	(isupper(c) ? c - 'A' + 'a' : c)
 *
 * is prohibited because the argument 'c' is evaluated twice.
 * It might be an expression that has side effects, such as a function
 * call that increments a counter and returns its value as a character.
 * The solution is to first copy the argument to a scratch variable, __tmp.
 */

#define tolower(c) (__tmp = (c), isupper(__tmp) ? __tmp - 'A' + 'a' : __tmp)
#define toupper(c) (__tmp = (c), islower(__tmp) ? __tmp - 'a' + 'A' : __tmp)

#endif /* _CTYPE_H */
