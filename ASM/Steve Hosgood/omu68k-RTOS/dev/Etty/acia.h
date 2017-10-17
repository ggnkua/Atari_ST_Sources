/*
 * Character i/o using 8531 ACIA (Eltec board).
 */

# define	ACIA_A		0	/* Acia A dev no */
# define	ACIA_B		1	/* Acia B dev no */

/* Registers */

# define	COMMAND		0	/* Command register */
# define	INTPENDING	3	/* Interupts pending register */
# define	BAUDL		12	/* Baud rate low byte */
# define	BAUDH		13	/* Baud rate high byte */

/* Commands to Command register ACIA */

# define	REN_RXINT	0x20	/* Renables RX interupt for next char */
# define	REN_TXINT	0x28	/* Renables TX interupt for next char */
# define	REN_INT		0x38	/* Renables All interupts */
# define	REN_ERROR	0x30	/* Renables Error bits */

/* Interupt status bits register 3 */

# define	B_STATUSINT	0x01	/* Channel B status interupt */
# define	B_TXINT		0x02	/* Channel B TX interupt */
# define	B_RXINT		0x04	/* Channel B RX interupt */
# define	A_STATUSINT	0x08	/* Channel A status interupt */
# define	A_TXINT		0x10	/* Channel A TX interupt */
# define	A_RXINT		0x20	/* Channel A RX interupt */

/* Status bits */

#define		RXRDY	0x0001		/* RXRDY Recieved RX character */
#define		TXRDY	0x0004		/* TXRDY Tx buffer ready for next */
#define		BREAK   0x0080


/* Acia port structure */

struct	acia{
	char	status;
	char	null;
	char	data;
};
