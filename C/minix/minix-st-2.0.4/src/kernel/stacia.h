/*
 * Atari ST hardware:
 * Motorola 6850 Asynchronous Communications Interface Adapter
 */

#define	KBD	(((struct acia *)AD_ACIA) + 0)
#define	MDI	(((struct acia *)AD_ACIA) + 1)

struct acia {
	_VOLATILE unsigned char	acb[4];		/* use only the even bytes */
};

#define	ac_cs	acb[0]		/* control and status register */
#define	ac_da	acb[2]		/* data register */

/* bits in control register: */
/*		0x03		   clock divider */
#define A_Q01	  0x00		/* don't divide */
#define A_Q16	  0x01		/* divide by 16 */
#define A_Q64	  0x02		/* divide by 64 */
#define A_RESET	  0x03		/* master reset */
/*		0x1C		   word select bits */
#define	A_72E	  0x00		/* 7 data, 2 stop, parity even */
#define	A_72O	  0x04		/* 7 data, 2 stop, parity odd */
#define	A_71E	  0x08		/* 7 data, 1 stop, parity even */
#define	A_71O	  0x0C		/* 7 data, 1 stop, parity odd */
#define	A_82N	  0x10		/* 8 data, 2 stop, no parity */
#define	A_81N	  0x14		/* 8 data, 1 stop, no parity */
#define	A_81E	  0x18		/* 8 data, 1 stop, parity even */
#define	A_81O	  0x1C		/* 8 data, 1 stop, parity odd */
/*		0x60		   RTS Low/High, TXINT en/dis, BREAK */
#define	A_TXPOL	  0x00		/* RTS Low, TXINT disabled */
#define	A_TXINT	  0x20		/* RTS Low, TXINT enabled */
#define	A_TXOFF	  0x40		/* RTS High, TXINT disabled */
#define	A_BREAK	  0x60		/* RTS Low, TXINT disabled, BREAK */
#define	A_RXINT	0x80		/* enable receiver interrupt */

/* bits in status register: */
#define	A_RXRDY	0x01		/* receiver ready */
#define	A_TXRDY	0x02		/* transmitter ready */
#define	A_CLOST	0x04		/* Carrier Lost */
#define	A_CTS	0x08		/* Clear To Send */
#define	A_FE	0x10		/* Frame Error */
#define	A_OE	0x20		/* Overrun Error */
#define	A_PE	0x40		/* Parity Error */
#define	A_IRQ	0x80		/* State of IRQ signal */

/* values for the ST: */
#define	KBD_INIT	(A_81N|A_Q64)
#define	MDI_INIT	(A_RXINT|A_TXPOL|A_81N|A_Q16)
