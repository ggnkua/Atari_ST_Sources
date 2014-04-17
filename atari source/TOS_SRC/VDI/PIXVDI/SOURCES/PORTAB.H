/*
******************************  portab.h   ************************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/portab.h,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/08 15:56:03 $     $Locker:  $
* =============================================================================
*
* $Log:	portab.h,v $
* Revision 3.1  91/01/08  15:56:03  lozben
* Deleted the "#define DEFAULT int" line.
* 
* Revision 3.0  91/01/03  15:15:42  lozben
* New generation VDI
* 
*******************************************************************************
*/

#ifndef _PORTAB_H_
#define _PORTAB_H_

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
#define	UBYTE	unsigned char			/* Unsigned byte	   */


/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/
#define	FAILURE	(-1)			/*	Function failure return val */
#define SUCCESS	(0)			/*	Function success return val */
#define	YES	1			/*	"TRUE"			    */
#define	NO	0			/*	"FALSE"			    */
#define	FOREVER	for(;;)			/*	Infinite loop declaration   */
#define	NULL	0L			/*	Null pointer value	    */
#define NULLPTR (char *) 0		/*				    */
#define	EOF	(-1)			/*	EOF Value		    */
#define	TRUE	(1)			/*	Function TRUE  value	    */
#define	FALSE	(0)			/*	Function FALSE value	    */

#endif
