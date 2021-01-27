/* Copyright (c) 1990 - present by H. Robbers.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC = distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	CTYPE.H		Character classification and conversion
 */

#ifndef CTYPE_H
#define CTYPE_H

extern unsigned char _ctype[];

enum
{
	_CTc	=	0x01,		/* control character */
	_CTd	=	0x02,		/* numeric digit */
	_CTu	=	0x04,		/* upper case */
	_CTl	=	0x08,		/* lower case */
	_CTs	=	0x10,		/* whitespace */
	_CTp	=	0x20,		/* punctuation */
	_CTx	=	0x40		/* hexadecimal */
};

#define	isalnum(c)	(_ctype[c]&(_CTu|_CTl|_CTd))
#define	is_alnum(c)	(_ctype[c]&(_CTu|_CTl|_CTd))
#define	isalpha(c)	(_ctype[c]&(_CTu|_CTl))
#define	is_alpha(c)	(_ctype[c]&(_CTu|_CTl))
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
