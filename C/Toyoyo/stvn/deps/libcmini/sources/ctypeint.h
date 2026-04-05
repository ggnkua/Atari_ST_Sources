extern unsigned char const __libc_ctype[256];
extern unsigned char const __libc_ctype2[256];

#undef _IScntrl
#undef _ISdigit
#undef _ISupper
#undef _ISlower
#undef _ISspace
#undef _ISpunct
#undef _ISxdigit
#undef _ISprint
#undef _ISblank
#undef _ISgraph

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
