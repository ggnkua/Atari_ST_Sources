/*
 * WinDom Portable definition
 * This file can be inside the source WinDom directory
 */

#ifndef __WPORTAB_H__
#define __WPORTAB_H__

#ifndef __PORTAB_H__
#define __PORTAB_H__

/* Compiler */

#ifdef __PUREC__
# define __MSHORT__		/* int have a 16-bit size */
# define __CDECL cdecl
# define __EXTERN extern
# define __PROTO(a) a
#else
# ifndef _COMPILER_H_
#  include <compiler.h>
# endif
#endif


/* Type */

#ifdef __PUREC__
# define INT16 int
#else
# define INT16 short
#endif

#define BYTE 	char
#define UBYTE	unsigned char
#define WORD 	INT16
#define UWORD	unsigned INT16
#define LONG	long
#define	ULONG	unsigned long
#define VOID	void
#define VOIDP	void*

/* Special keyword */
#define EXTERN	__EXTERN

/* Constants */
#define TRUE	1
#define FALSE	0

#endif /* __PORTAB_H__ */
#endif /* __WPORTAB_H__ */
