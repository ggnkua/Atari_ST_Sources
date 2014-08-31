/* portab.h - portability support for Turbo/Pure-C */

#ifndef __PORTAB__
#define __PORTAB__

typedef          void    VOID;
typedef          char    CHAR;
typedef          char    BYTE;
typedef          int     WORD;
typedef          long    LONG;
typedef unsigned char    UBYTE;
typedef unsigned int     UWORD;
typedef unsigned long    ULONG;

#define EXTERN		extern
#define MLOCAL		static
#define REG		register

#define _(params)	params

#define STDARGS		cdecl

#define	FALSE		(0)		/* boolean false */
#define	TRUE		(!FALSE)	/* boolean true */
#define YES	TRUE
#define NO	FALSE
#define SUCCESS	TRUE
#define FAILURE	FALSE

#define EOF (-1)
#define NULLPTR	NULL
#define NULLFUNC	((void(*)(void))0)

#ifndef NULL
#define NULL	((void *)0)
#endif
#endif

