/*
 * portab.h
 * (c) 1993 Atari Corp.
 * =========================================================================
 * This new portab.h file reflects all of the declarations made by 
 * compiler.h and the old portab.h. Please use portab.h instead of 
 * compiler.h
 *
 * 930219	towns		add compiler.h declarations.
 * 920922	dmui		created.
 */

#ifndef _PORTAB_H_
#define _PORTAB_H_

#define ALCYON	1				/* Alcyon C Compiler		*/
#define UCHARA 	1				/* if char is unsigned		*/

/*	Standard type definitions	*/	

#define	BYTE	char			/* Signed byte				*/
#define BOOLEAN	int				/* 2 valued (true/false)	*/
#define	WORD	int  			/* Signed word (16 bits)	*/
#define	UWORD	unsigned int		/* unsigned word			*/

#define	LONG	long			/* signed long (32 bits)	*/
#define	ULONG	long			/* Unsigned long			*/

#define	REG		register		/* register variable		*/
#define	LOCAL	auto			/* Local var on 68000		*/
#define	EXTERN	extern			/* External variable		*/
#define	MLOCAL	static			/* Local to module			*/
#define	GLOBAL	/**/			/* Global variable			*/
#define	VOID	void			/* Void function return		*/
#define VOIDP	void *			/* void pointer return		*/
#define UBYTE	unsigned char		/* Unsigned byte 			*/


/* Misc definitions */

#define	FAILURE		(-1)		/* Function failure return val	*/
#define SUCCESS		(0)			/* Function success return val	*/
#define	YES			1			/* "TRUE"						*/
#define	NO			0			/* "FALSE"						*/
#define	FOREVER		for(;;)		/* Infinite loop declaration	*/
#define	NULL		0			/* Null pointer value			*/
#define NULLPTR		(char *)0	/*								*/
#define	EOF			(-1)		/* EOF Value					*/
#define	TRUE		(1)			/* Function TRUE  value			*/
#define	FALSE		(0)			/* Function FALSE value			*/
#define	LINKED		1			/* Compile codes				*/


typedef unsigned long int size_t;

#endif

