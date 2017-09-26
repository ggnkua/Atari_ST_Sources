/*  kbq.h - keyboard queue header				*/


/*
**  KBQENTRY - type of data in a kbq.  
**	This is a word, with the hi byte being the status value, and the
**	low byte being the actual scan code.
*/

typedef	UWORD	KBQENTRY ;

/*
**  KBSCNCODE - turns a kbq entry into a scan code
*/

#define	KBSCNCODE(x)	(  (UBYTE)(x & 0x00ff)  )

/*
**  KBSTATUS - turns a kbq entry into the keyboard status assoc'd with the
**	scan code
*/

#define	KBSTATUS(x)	(  (UBYTE)( (x<<8) & 0x00ff )  )

