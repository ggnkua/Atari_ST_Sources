/*  io.h - header file for i/o drivers					*/

/*
**  return codes
*/

#define	DEVREADY	-1L		/*  device ready		*/
#define	DEVNOTREADY	0L		/*  device not ready		*/
#define	MEDIANOCHANGE	0L		/*  media def has not changed	*/
#define	MEDIAMAYCHANGE	1L		/*  media may have changed	*/
#define	MEDIACHANGE	2L		/*  media def has changed	*/

/*
**  typedefs
*/

#define	ISR	int
#define	ECODE	LONG

typedef	int	(*PFI)() ;	/*  straight from K & R, pg 141		*/

/*
**  code macros
*/

#define	ADDRESS_OF(x)	x
#define	INP		inp
#define	OUTP		outp

/*
**  externs
*/

EXTERN	BYTE	INP() ;
EXTERN	VOID	OUTP() ;

