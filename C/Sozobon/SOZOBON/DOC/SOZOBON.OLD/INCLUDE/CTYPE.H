/*
 *	CTYPE.H		Character classification and conversion
 */

#ifndef CTYPE_H
#define CTYPE_H

extern	unsigned char	_ctype[];

#define	_CTc	0x01		/* control character */
#define	_CTd	0x02		/* numeric digit */
#define	_CTu	0x04		/* upper case */
#define	_CTl	0x08		/* lower case */
#define	_CTs	0x10		/* whitespace */
#define	_CTp	0x20		/* punctuation */
#define	_CTx	0x40		/* hexadecimal */

#define	isalnum(c)	(_ctype[c]&(_CTu|_CTl|_CTd))
#define	isalpha(c)	(_ctype[c]&(_CTu|_CTl))
#define	isascii(c)	!((c)&~0x7F)
#define	iscntrl(c)	(_ctype[c]&_CTc)
#define	isdigit(c)	(_ctype[c]&_CTd)
#define	isgraph(c)	!(_ctype[c]&(_CTc|_CTs))
#define	islower(c)	(_ctype[c]&_CTl)
#define	isprint(c)	!(_ctype[c]&_CTc)
#define	ispunct(c)	(_ctype[c]&_CTp)
#define	isspace(c)	(_ctype[c]&_CTs)
#define	isupper(c)	(_ctype[c]&_CTu)
#define	isxdigit(c)	(_ctype[c]&_CTx)

#define	toupper(c)	(islower(c) ? (c)^0x20 : (c))
#define	tolower(c)	(isupper(c) ? (c)^0x20 : (c))
#define	_toupper(c)	((c)^0x20)
#define	_tolower(c)	((c)^0x20)
#define	toascii(c)	((c)&0x7F)

#endif CTYPE_H
