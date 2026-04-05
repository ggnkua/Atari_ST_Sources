/*
 * ctype.h
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#ifndef _CTYPE_H_
#define _CTYPE_H_

#ifndef	_FEATURES_H
# include <features.h>
#endif

int toupper(int c);
int tolower(int c);
int toascii(int c);
int isalnum(int c);
int isalpha(int c);
int isascii(int c);
int iscntrl(int c);
int isdigit(int c);
int isgraph(int c);
int islower(int c);
int isprint(int c);
int ispunct(int c);
int isspace(int c);
int isupper(int c);
int isxdigit(int c);
int isblank(int c);

extern unsigned char const __libc_ctype[256];
extern unsigned char const __libc_ctype2[256];

#define	_IScntrl	0x01		/* control character */
#define	_ISdigit	0x02		/* numeric digit */
#define	_ISupper	0x04		/* upper case */
#define	_ISlower	0x08		/* lower case */
#define	_ISspace	0x10		/* whitespace */
#define	_ISpunct	0x20		/* punctuation */
#define	_ISxdigit	0x40		/* hexadecimal */
#define _ISprint	0x80		/* print */
#define _ISblank	0x01		/* blank */
#define _ISgraph	0x02		/* graph */

#define	isascii(c)	(!((c)&~0x7F))
#define	toascii(c)	((c)&0x7F)
#define	isalnum(c)	(__libc_ctype[(unsigned char)((c))] & (_ISupper|_ISlower|_ISdigit))
#define	isalpha(c)	(__libc_ctype[(unsigned char)((c))] & (_ISupper|_ISlower))
#define	isdigit(c)	(__libc_ctype[(unsigned char)((c))] & _ISdigit)
#define	islower(c)	(__libc_ctype[(unsigned char)((c))] & _ISlower)
#define isprint(c)	(__libc_ctype[(unsigned char)((c))] & _ISprint)
#define	ispunct(c)	(__libc_ctype[(unsigned char)((c))] & _ISpunct)
#define	isspace(c)	(__libc_ctype[(unsigned char)((c))] & _ISspace)
#define	isupper(c)	(__libc_ctype[(unsigned char)((c))] & _ISupper)
#define	isxdigit(c)	(__libc_ctype[(unsigned char)((c))] & _ISxdigit)
#define	isgraph(c)	(__libc_ctype2[(unsigned char)((c))] & _ISgraph)
#ifdef __USE_ISOC99
#define isblank(c)	(__libc_ctype2[(unsigned char)((c))] & _ISblank)
#endif


/* Problem: iscntrl(255) and iscntrl(EOF) should produce different values
   (IMHO this is nonsense).  For non-GNU compilers there is now way to
   implement that safely.  */
#ifndef __GNUC__
# define	iscntrl(c)	(((c) == -1) ? 0 : \
	(unsigned char) (c) == 255 ? 1 : \
	(__libc_ctype[(unsigned char)((c))]&_IScntrl))

#else /* GNU C */
# define        iscntrl(c) \
  ({ int _c = (int) (c);   \
     _c == -1 ? 0 : \
     (unsigned char) (_c) == 255 ? 1 : __libc_ctype[(unsigned char)(_c)]&_IScntrl; })

#endif /* GNU C */

#endif /* CTYPE_H_ */
