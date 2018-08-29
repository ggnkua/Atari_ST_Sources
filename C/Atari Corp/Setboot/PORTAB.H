/************************************************************************/
/*	PORTAB.H	Pointless redefinitions of C syntax.		*/
/*		Copyright 1985 Atari Corp.				*/
/*									*/
/*	WARNING: Use of this file may make your code incompatible with	*/
/*		 C compilers throughout the civilized world.		*/
/************************************************************************/

#ifndef mc68k
#define mc68k 1
#endif

/*
 *	ATARI ST machine
 */
 
#ifndef	ATARI_ST
#define	ATARI_ST 1
#endif

/*
 *	today we are using Mark Williams C-Compiler for the ATARI ST
 */

#ifndef MWC
#define MWC 1
#endif

/*
 *	Standard type definitions
 */

#define	BYTE	char
#define UBYTE 	unsigned char
#define BOOLEAN	int
#define	WORD	int
#define	UWORD	unsigned int
#define	LONG	long
#define	ULONG	unsigned long

#define	VOID	void	

#define REG	register

#define REGBYTE register char
#define REGWORD register int
#define REGLONG register long


#define	LOCAL	static
#define GLOBAL	/* */

typedef WORD (*WFCTP)();	/* pointer to function which returns a word */
typedef BYTE (*BFCTP)();	/* pointer to function which returns a byte */
typedef LONG (*LFCTP)();	/* ptr to function which returns a long word */

/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/

#define	FAILURE	(-1)			/*	Function failure return val */
#define SUCCESS	(0)			/*	Function success return val */
#define	YES	1			/*	"TRUE"			    */
#define	NO	0			/*	"FALSE"			    */
#define	FOREVER	for(;;)			/*	Infinite loop declaration   */
#ifndef NULL
#define	NULL	0L			/*	Null pointer value	    */
#endif
#ifndef NUL
#define NUL	0			/*				    */
#endif
#define NULLPTR (char *) 0L		/*				    */
#ifndef EOF
#define	EOF	(-1)			/*	EOF Value		    */
#endif
#ifndef TRUE
#define	TRUE	(1)			/*	Function TRUE  value	    */
#define	FALSE	(0)			/*	Function FALSE value	    */
#endif
#ifndef ERR
#define ERR	(-1)			/* 	Function ERROR value        */
#endif
#ifndef CR
#define CR	13
#define LF	10
#endif
