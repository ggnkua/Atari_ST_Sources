/****************************************************************************
*
*	  C P / M   C   R U N   T I M E   L I B   H E A D E R   F I L E
*	  -------------------------------------------------------------
*	Copyright 1982 by Digital Research Inc.  All rights reserved.
*
*	This is an include file for assisting the user to write portable
*	programs for C.  All processor dependencies should be located here.
*
****************************************************************************/
/*
 *	Standard type definitions
 */
#define	BYTE	char				/* Signed byte		   */
#define UBYTE	char				/* Unsigned byte 	   */
#define BOOLEAN	char				/* 2 valued (true/false)   */
#define	WORD	short  				/* Signed word (16 bits)   */
#define	UWORD	unsigned int			/* unsigned word	   */

#define	LONG	long				/* signed long (32 bits)   */
#define	ULONG	unsigned long			/* Unsigned long	   */

#define	REG	register			/* register variable	   */
#define	LOCAL	auto				/* Local var on 68000	   */
#define	EXTERN	extern				/* External variable	   */
#define	MLOCAL	static				/* Local to module	   */
#define	GLOBAL	/**/				/* Global variable	   */
#define	VOID	/**/				/* Void function return	   */
#define UBWORD(a) ((UWORD)a & 0xff)


/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/
#define	FAILURE	(-1)			/*	Function failure return val */
#define SUCCESS	(0)			/*	Function success return val */
#define	YES	1			/*	"TRUE"			    */
#define	NO	0			/*	"FALSE"			    */
#define	FOREVER	for(;;)			/*	Infinite loop declaration   */
#define	NULL	(BYTE *) 0			/*	Null character value	    */
#define	EOF	(-1)			/*	EOF Value		    */
#define	TRUE	(1)			/*	Function TRUE  value	    */
#define	FALSE	(0)			/*	Function FALSE value	    */

#define abs(x)  ((x) < 0? -(x): (x))
#define max(x,y) (((x) > (y))? (x): (y))
#define min(x,y) (((x) < (y))? (x): (y))

/****************************************************************************/
/****************************************************************************/
