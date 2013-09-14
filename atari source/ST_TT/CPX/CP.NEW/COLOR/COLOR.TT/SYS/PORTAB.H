/* PORTAB.H	Pointless redefinitions of C syntax
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 890829 kbad	Hacked up for ANSI
 *
 * WARNING: Use of this file may make your code incompatible with
 *	    C compilers throughout the civilized world.
 */

#ifndef PORTAB_H
#define PORTAB_H

#ifndef ANSI_C
#ifdef __STDC__
#define ANSI_C	__STDC__
#else
#define ANSI_C	0
#endif
#endif

/* Turbo doesn't allow cdecl's in __STDC__ */
#ifdef __TURBOC__
#undef	ANSI_C
#define ANSI_C	1
#endif

#define UCHARA	0			/* if char is unsigned		*/

/* Standard type definitions
 * ================================================================
 */

#if UCHARA
typedef char		UBYTE;		/* Alcyon don't like it unsigned */
#else
typedef	unsigned char	UBYTE;		/* Unsigned byte		*/
#endif

typedef char		BYTE;		/* Signed byte			*/
typedef	unsigned short	UWORD;		/* unsigned word		*/
typedef short		WORD;		/* Signed word (16 bits)	*/
typedef	unsigned long	ULONG;		/* Unsigned long		*/
typedef	long		LONG;		/* signed long (32 bits)	*/

/* silly definition conflicts with OBDEFS_H DEFAULT */
/* #define DEFAULT int */		/* Default size			*/

/* Boolean type, 2 valued (true/false) */
#if ANSI_C
typedef enum { FALSE, TRUE } bool;
#else
#define	FALSE	0
#define	TRUE	!0
typedef short		bool;
#endif
typedef bool		BOOLEAN;

/* Pointer to anything */
#if ANSI_C
#define		VOIDP	void *
#else
#define		VOIDP	char *
#define void	/* */
#endif


/* Storage class specifiers
 * ================================================================
 */

#define	REG	register		/* Register variable		*/
#define	LOCAL	auto			/* Local to function		*/
#define	EXTERN	extern			/* Externally defined		*/
#define	MLOCAL	static			/* Local to module		*/
#define	GLOBAL	/* */			/* Global variable/function	*/


/* Function declarations
 * ================================================================
 */

#ifdef __TURBOC__
#define _C	cdecl
#define VARGS	void, ...
#else
#define _C	/* */
#define VARGS	/* */
#endif
#define	VOID	void			/* Void function return		*/


/* Miscellaneous definitions
 * ================================================================
 * NOTE: SUCCESS and FAILURE are OPPOSITES of ANSI
 *	 EXIT_SUCCESS and EXIT_FAILURE because of AES strangeness.
 */
#define SUCCESS	!0			/* Function success return val	*/
#define	FAILURE	0			/* Function failure return val	*/
#define	YES	TRUE			/* "aye"			*/
#define	NO	FALSE			/* "nay"			*/
#define	FOREVER	for(;;)			/* Infinite loop declaration	*/

#ifndef EOF				/* This is defined by ANSI	*/
#define	EOF	(-1)			/* EOF Value			*/
#endif

#ifndef	NULL			/* This is defined by ANSI	*/
#define NULL	( (VOIDP)0L )
#endif

#define NULLPTR	NULL


#ifdef __TURBOC__
#undef REG
#define REG
#endif

#endif PORTAB_H
