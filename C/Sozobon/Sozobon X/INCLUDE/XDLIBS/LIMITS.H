/*
 * @(#)limits.h, XdLibs, SozobonX
 * 
 */

#ifndef	_LIMITS_H
#define	_LIMITS_H

#define	PATHSIZE	(128)		/* maximum pathname length */

#define	BITSPERBYTE	8

/* constants with only the high bit set */
#define	HIBITS	((short) (1 << (BITSPERBYTE * sizeof(short) - 1)))
#define	HIBITI	((int) (1 << (BITSPERBYTE * sizeof(int) - 1)))
#define	HIBITL	((long) (1L << (BITSPERBYTE * sizeof(long) - 1)))

/* largest value for each type */
#define	MAXSHORT	((short) (~HIBITS))
#define	MAXINT		((int) (~HIBITI))
#define	MAXLONG		((long) (~HIBITL))

/* smallest value for each type (assumes 2's complement representation) */
#define	MINSHORT	HIBITS
#define	MININT		HIBITI
#define	MINLONG		HIBITL

/* similar #defines for ANSI compatibility */
#define	CHAR_BIT	BITSPERBYTE
#define	CHAR_MAX	SCHAR_MAX
#define	CHAR_MIN	SCHAR_MIN
#define	INT_MAX		MAXINT
#define	INT_MIN		MININT
#define	LONG_MAX	MAXLONG
#define	LONG_MIN	MINLONG
#define	SCHAR_MAX	(127)
#define	SCHAR_MIN	(-128)
#define	SHRT_MAX	MAXSHORT
#define	SHRT_MIN	MINSHORT
#define	UCHAR_MAX	~((unsigned char) 0)
#define	UINT_MAX	~((unsigned int) 0)
#define	ULONG_MAX	~((unsigned long) 0)
#define	USHRT_MAX	~((unsigned short) 0)

#endif 	/* _LIMITS_H	*/
