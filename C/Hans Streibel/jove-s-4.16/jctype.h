/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* NOTE: unlike standard is* routines, these must not be applied
 * to EOF.  On the other hand, they may safely be applied to
 * sign-extended values.
 */

#define	C_UPPER	0001	/* UPPER case */
#define	C_LOWER	0002	/* LOWER case */
#define	C_DIGIT	0004	/* DIGIT */
#define	C_PUNCT	0010	/* PUNCTuation */
#define	C_PRINT	0020	/* PRINTable */
#define	C_WORD	0040	/* WORD */
#define	C_BRA	0100	/* open BRAket */
#define	C_KET	0200	/* close braKET */

extern const unsigned char	CharTable[NCHARS];

#define	has_syntax(c,s)	((CharTable[ZXC(c)]&(s)) != 0)
#define	jisdigit(c)	has_syntax(c, C_DIGIT)
#define	jisopenp(c)	has_syntax(c, C_BRA)
#define	jisclosep(c)	has_syntax(c, C_KET)

#define	jiswhite(c)	((c) == ' ' || (c) == '\t')	/* NOT isspace! */

extern bool	jisident proto((DAPchar));

#ifdef USE_CTYPE

# include <ctype.h>
# define	jisprint(c)	isprint(ZXC(c))
# define	jisword(c)	isalnum(ZXC(c))
# define	jisupper(c)	isupper(ZXC(c))
# define	jislower(c)	islower(ZXC(c))

# define	CharUpcase(c)	toupper(ZXC(c))
# define	CharDowncase(c)	tolower(ZXC(c))

#ifndef NO_SETLOCALE
extern char	LcCtype[32];		/* VAR: lc-ctype, for use in setlocale */
extern void		locale_adjust proto ((void));
#endif

#else /* !USE_CTYPE */

# define	jisprint(c)	has_syntax(c, C_PRINT)
# define	jisword(c)	has_syntax(c, C_WORD)
# define	jisupper(c)	has_syntax(c, C_UPPER)
# define	jislower(c)	has_syntax(c, C_LOWER)

  extern const char
	RaiseTable[NCHARS],
	LowerTable[NCHARS];

# define	CharUpcase(c)	ZXC(RaiseTable[ZXC(c)])
# define	CharDowncase(c)	ZXC(LowerTable[ZXC(c)])

#endif /* !USE_CTYPE */

#define cind_eq(a, b)	(CharUpcase(a) == CharUpcase(b))
