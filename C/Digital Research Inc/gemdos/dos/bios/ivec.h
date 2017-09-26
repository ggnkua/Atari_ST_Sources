/*  ivec.h - interrupt vector info for vme-10				*

/*
**  warning: this file is also used as input to assembler files which are
**	fed to the pre processor.  be careful what you write.
**	for example: the numbers below are in decimal, so that asm68 won't
**	gag on them.
*/


/*
**  vector numbers
*/

#define	KBDVECNO	66
				/*  0x042		*/
#define	SIOVECNO	69
				/*  0x045		*/
#define	TIMVECNO	76
				/*  0x04c		*/

/*
**  vector addresses
*/

#define	KBDVADDR	(KBDVECNO*4)
#define	SIOVADDR	(SIOVECNO*4)
#define	TIMVADDR	(TIMVECNO*4)

