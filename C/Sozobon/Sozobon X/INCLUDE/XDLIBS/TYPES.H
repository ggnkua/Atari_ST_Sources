/*
 * @(#)types.h, Xdlibs, SozobonX
 * typedef some types, especially unsigned ones
 * define _Portab to prevent typedefs of LONG, etc types
 */

#ifndef _TYPES_H
#define _TYPES_H

#ifndef _STDDEF_H
#include <stddef.h>
#endif

#ifndef VOID
#define VOID	void
#endif

	/* some macros	*/
#define	bool	int
#define	REGISTER	register

/* this is not portable!!! */
/* typedef unsigned char   BYTE; */	 /* 8-bit unsigned */
/* typedef unsigned int    WORD; */	 /* 16-bit unsigned */
/* typedef unsigned long   LONG; */	 /* 32-bit unsigned */
/* so I relplaced it with:	*/

#ifndef _Portab
	/* some portable software needs it's own typedefs	*/
typedef	signed char	BYTE;			/* 8-bit un/signed */
typedef	char		CHAR;
typedef	unsigned char	UBYTE;
typedef	unsigned char	UCHAR;

typedef	int	BOOLEAN;				/* type of TRUE/FALSE	*/
typedef	int	BOOL;

typedef	signed short	WORD;		/* 16-bit un/signed */
typedef	unsigned short	UWORD;

typedef	signed long	LONG;			/* 32-bit un/signed */
typedef	unsigned long	ULONG;

#endif /* _Portab */

typedef unsigned char	uchar;		/* 8-bit unsigned */
typedef unsigned short	ushort;		/* 16-bit unsigned */
typedef unsigned int	uint;		/* 16?-bit unsigned */
typedef unsigned long	ulong;		/* 32-bit unsigned */

	/* for compatibility	*/
typedef unsigned char	u_char;		/* 8-bit unsigned */
typedef unsigned short	u_short;	/* 16-bit unsigned */
typedef unsigned int	u_int;		/* 16?-bit unsigned */
typedef unsigned long	u_long;		/* 32-bit unsigned */

	/* ATARI specials	*/
typedef unsigned short	dev_t;		/* device (drive) id */

	/* library types (should be in stddef.h)	*/
typedef unsigned long	fpos_t;		/* file position offset */
typedef unsigned long	time_t;		/* raw date/time */
typedef long		clock_t;	/* clock ticks */

#endif 	/* _TYPES_H	*/
