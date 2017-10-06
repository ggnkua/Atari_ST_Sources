/*
 *	ctype.h		Character classification and conversion
 */

#ifndef _CTYPE_H
#define _CTYPE_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

begin_decls

extern	unsigned char	*_ctype;

#define	_CTc	0x01		/* control character */
#define	_CTd	0x02		/* numeric digit */
#define	_CTu	0x04		/* upper case */
#define	_CTl	0x08		/* lower case */
#define	_CTs	0x10		/* whitespace */
#define	_CTp	0x20		/* punctuation */
#define	_CTx	0x40		/* hexadecimal */
#define _CTb	0x80		/* blank */

int isalnum (int c);
int isalpha (int c);
#if defined(__USE_SVID) || defined(__USE_MISC)
int isascii (int c);
int toascii (int c);
#endif /* _POSIX_SOURCE */
int iscntrl (int c);
int isdigit (int c);
int isgraph (int c);
int isprint (int c);
int ispunct (int c);
int isspace (int c);
int isupper (int c);
int isxdigit (int c);
#ifdef __USE_GNU
int isblank (int c);
#endif
int toupper (int c);
int tolower (int c);

/* HR: Please!! macros have side effects. Grow up and use functions! */

#ifdef __USE_MISC

#ifdef __GNUC__
/* use safe versions */

#define toint(c)    \
    ({typeof(c) _c = (c);     \
	    (_c <= '9') ? (_c - '0') : (toupper(_c) - 'A' + 10); })
#define isodigit(c) \
    ({typeof(c) _c = (c);      \
	    (_c >='0') && (_c<='7'); })
#define iscymf(c)   \
    ({typeof(c) _c = (c);      \
	    isalpha(_c) || (_c == '_'); })
#define iscym(c)    \
    ({typeof(c) _c = (c);      \
	    isalnum(_c) || (_c == '_'); })

#else /* you know what */

#define toint(c)	( (c) <= '9' ? (c) - '0' : toupper(c) - 'A' + 10)
#define isodigit(c)	( (c)>='0' && (c)<='7' )
#define iscymf(c)	(isalpha(c) || ((c) == '_') )
#define iscym(c)	(isalnum(c) || ((c) == '_') )

#endif /* __GNUC__ */
#endif /* __USE_MISC */

end_decls

#endif /* _CTYPE_H */
