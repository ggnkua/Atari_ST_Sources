/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/portab.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:30:02 $	$Locker: kbad $
* =======================================================================
*  $Log:	portab.h,v $
* Revision 2.2  89/04/26  18:30:02  mui
* TT
* 
* Revision 2.1  89/02/22  05:31:59  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:36:12  lozben
* Initial revision
* 
*************************************************************************
*/
#define mc68k 0
/****************************************************************************
*
*	  C P / M   C   R U N   T I M E   L I B   H E A D E R   F I L E
*	  -------------------------------------------------------------
*	Copyright 1982 by Digital Research Inc.  All rights reserved.
*
*	This is an include file for assisting the user to write portable
*	programs for C.
*
****************************************************************************/
#define UCHARA 1				/* if char is unsigned     */
/*
 *	Standard type definitions
 */
#define	BYTE	char				/* Signed byte		   */
#define BOOLEAN	int				/* 2 valued (true/false)   */
#define	WORD	int  				/* Signed word (16 bits)   */
#define	UWORD	unsigned int			/* unsigned word	   */

#define	LONG	long				/* signed long (32 bits)   */
#define	ULONG	long				/* Unsigned long	   */

#define	REG	register			/* register variable	   */
#define	LOCAL	auto				/* Local var on 68000	   */
#define	EXTERN	extern				/* External variable	   */
#define	MLOCAL	static				/* Local to module	   */
#define	GLOBAL	/**/				/* Global variable	   */
#define	VOID	/**/				/* Void function return	   */
#define	DEFAULT	int				/* Default size		   */

#ifdef UCHARA
#define UBYTE	char				/* Unsigned byte 	   */
#else
#define	UBYTE	unsigned char			/* Unsigned byte	   */
#endif

/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/
#define	FAILURE	(-1)			/*	Function failure return val */
#define SUCCESS	(0)			/*	Function success return val */
#define	YES	1			/*	"TRUE"			    */
#define	NO	0			/*	"FALSE"			    */
#define	FOREVER	for(;;)			/*	Infinite loop declaration   */
#define	NULL	0			/*	Null pointer value	    */
#define NULLPTR (char *) 0		/*				    */
#define	EOF	(-1)			/*	EOF Value		    */
#define	TRUE	(1)			/*	Function TRUE  value	    */
#define	FALSE	(0)			/*	Function FALSE value	    */

