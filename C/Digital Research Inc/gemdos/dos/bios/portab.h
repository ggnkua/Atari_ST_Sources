
/*
*	PORTAB.H:  This file contains all the definition
*                  to assist the user in writing portable C
*		   program.  All the types are redefined in this include file.
*
*/

 
#define BYTE	char				/* Signed byte		   */
#define UBYTE	char				/* Unsigned byte	   */
#define BOOLEAN int				/* 2 valued (true/false)   */
#define WORD	short int			/* Signed word (16 bits)   */
#define UWORD	unsigned short int		/* unsigned word	   */

#define LONG	long				/* signed long (32 bits)   */
#define ULONG	unsigned long			/* Unsigned long	   */

#define REG	register			/* register variable	   */
#define LOCAL	auto				/* Local var on 68000	   */
#define EXTERN	extern				/* External variable	   */
#define MLOCAL	static				/* Local to module	   */
#define GLOBAL	/**/				/* Global variable	   */
#define VOID	/**/				/* Void function return    */
#define DEFAULT int				/* Default size 	   */
#define FLOAT	float				/* Floating Point	   */
#define DOUBLE	double				/* Double precision	   */
#define	CODE	int				/* 68000 code word aligned */

/****************************************************************************/
/*	Miscellaneous Definitions:					    */
/****************************************************************************/
#define FAILURE (-1)			/*	Function failure return val */
#define SUCCESS (0)			/*	Function success return val */
#define YES	1			/*	"TRUE"                      */
#define NO	0			/*	"FALSE"                     */
#define FOREVER for(;;) 		/*	Infinite loop declaration   */
#define NULL	0			/*	Null character value	    */
#define NULLPTR (char *) 0		/*	Null pointer value	    */
#define EOF	(-1)			/*	EOF Value		    */
#define TRUE	(1)			/*	Function TRUE  value	    */
#define FALSE	(0)			/*	Function FALSE value	    */
#define STDIN	 0			/*	Standard Input		    */
#define STDOUT	 1			/*	Standard Output 	    */
#define STDERR	 2			/*	Standard Error		    */


/****************************************************************************/
/****************************************************************************/

