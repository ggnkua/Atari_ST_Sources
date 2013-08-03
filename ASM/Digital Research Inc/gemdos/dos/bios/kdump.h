/* dump.h - common external declarations */

/*
**  
*/

#define	INTEL	0

#if	INTEL
#define	DMPHDR(h,s)	(idmphdr(h,s))
#else
#define	DMPHDR(h,s)	(dmphdr(h,s))
#endif

/*
**  memory dump routines
*/

EXTERN	char	*dmphdr() ;	/* output header in form "hhhhhhhh:  "	*/
EXTERN	char	*idmphdr() ;	/* output header in form "hhhh:hhhh:  "	*/
EXTERN	char	*ldump() ;	/* hhhhhhhh: 01234567 89ABCDEF 01234...	*/
EXTERN	char	*wdump() ;	/* hhhhhhhh: 0123 4567 89AB CDEF ...	*/
EXTERN	char	*bdump() ;	/* hhhhhhhh: 01 23 45 67 89 AB ...	*/

/*
**  longword dump routines
*/

EXTERN	char	*slhex() ;	/*  0x01234567 => "01234567 "		*/
EXTERN	char	*slwhex() ;	/*  0x01234567 => "0123 4567 "		*/
EXTERN	char	*slbhex() ;	/*  0x01234567 => "01 23 45 67 "	*/

/*
**  word dump routines
*/

EXTERN	char	*swhex() ;	/*  0x0123 => "0123 "			*/
EXTERN	char	*swbhex() ;	/*  0x0123 => "01 23 "			*/

/*
** byte dump routines
*/

EXTERN	char	*sbhex() ;	/* 0x01 => "01 " 			*/
EXTERN	char	ntoa() ;	/* 0x01 => '1', 0x02 => '2', ...	*/


#ifndef	MIN
#define	MIN(x,y)	( x < y ? x : y ) 
#endif

