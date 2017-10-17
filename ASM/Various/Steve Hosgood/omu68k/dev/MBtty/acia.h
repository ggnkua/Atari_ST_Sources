/*
 * Character i/o using 68681 ACIA (Microbox board).
 */

# define	ACIA_A		0	/* Acia A dev no */
# define	ACIA_B		1	/* Acia B dev no */

/* Basic data structure (note shorts used but only lower byte used) */
struct	Acia {
	short	modea;
	short	statusa;
	short	commanda;
	short	dataa;
	short	acr;
	short	intmask;
	short	counterh;
	short	counterl;
	short	modeb;
	short	statusb;
	short	commandb;
	short	datab;
	short	intvec;
	short	outcont;
	short	outport;
	short	stopc;
};

/*	Mode register 0 */
# define	RXRTS		0x80	/* Rx RTS enable */
# define	NOPARITY	0x10	/* No parity */
# define	EIGHTBITS	0x03	/* Eight bit data */

/* No parity 8 bits per char no RTS */
# define	MODE0		(NOPARITY | EIGHTBITS)

/*	Mode register 1 */
# define	TXCTS		0x10	/* Tx CTS enable */
# define	STOPB2		0xF	/* Two stop bits */

/* 1 Stop bit */
# define	MODE1		STOPB2

/*	Status registers */
# define	TXRDY		0x4	/* Tx ready */
# define	RXRDY		0x1	/* Rx ready */
# define	ERROR		0xFA	/* Error conditions */

/*	Command registers */
# define	SETMODE0	0x10	/* Sets pointer to Mode0 register */
# define	RESETERROR	0x40	/* Resets error bits */
# define	TXENABLE	0x04	/* Enable TX */
# define	RXENABLE	0x01	/* Enable RX */

/* Tx enabled Rx enabled */
# define	COMREG		(TXENABLE | RXENABLE)

/*	Acr register */
# define	BAUDALT		0x80	/* Altenate baud rates */
# define	TIMER16		0x70	/* Timer bits */
# define	IPINTENABLE	0x0F	/* Interupt enable on input port bits */

# define	ACR		BAUDALT | TIMER16

/*	Intstatus	*/
# define	TXAINT		0x1
# define	RXAINT		0x2
# define	TXBINT		0x10
# define	RXBINT		0x20
# define	TIMINT		0x08

/*	Interupt mask register */
# define	INTMASK		0x3B	/* Tx and Rx and timmer interupts */

/*	Counter timer	*/
# define	CNTH		0x00
# define	CNTL		0x00

# define	COUNT20MS	2300	/* 20 ms counter period */
