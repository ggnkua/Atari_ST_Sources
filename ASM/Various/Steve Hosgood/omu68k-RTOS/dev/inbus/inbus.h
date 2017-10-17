/*******************************************************************************
 *	Inbus.h		Instrument bus definitions
 *******************************************************************************
 */

#define	INBUSSTART	0xDE0000	/* Start address of instrument bus */
#define NINSBOARDS	256		/* Number of instrument boards */
#define NINS		8		/* Number of instruments per board */
#define	BOARDSIZE	512		/* Size of instrument board in chars */

/* Structure of an instruments entry onto the instrument bus */

struct	Inbus {
	short	type;		/* Type of instrument */
	short	status;		/* Status of instrument */
	long	address;	/* Address pointer to instrument RAM */
	long	data;		/* Data at address pointed to */
	short	fill[2];	/* Spare */

	short	d0;		/* Data 0	Multi-purpose data port */
	short	d1;		/* Data 1	Multi-purpose data port */
	short	d2;		/* Data 2	Multi-purpose data port */
	short	d3;		/* Data 3	Multi-purpose data port */
	short	d4;		/* Data 4	Multi-purpose data port */
	short	d5;		/* Data 5	Multi-purpose data port */
	short	d6;		/* Data 6	Multi-purpose data port */
	short	d7;		/* Data 7	Multi-purpose data port */

	short	fill1[16];	/* Data 8 - */
};

/*
 *	Status bits
 */
# define	SRDY	0x80		/* Ready bit */
# define	SMODE	0x60		/* Mode bits */
# define	SINTE	0x08		/* Interupt enable */
# define	SINTP	0x07		/* Interupt priority bits */

# define	MREP	0x00		/* Repetative mode */
# define	MSH	0x20		/* Single shot mode */
# define	MSHB	0x60		/* Single shot mode Bus triggered */
# define	MSHIFT	5		/* Shift left value for mode bits */

# define	ADDINBOARD(x)	(struct Inbus *)(INBUSSTART + BOARDSIZE*(x))
