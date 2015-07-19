/*****************************************************************************
**
** 7201.h -	Header file that describes the various operations, commands,
**		and status for the NEC 7201 Multiprotocol Serial
**		Communications Controller.
**
** CREATED
** 23 sep 85 scc	(Abstracted from old SERIAL.C)
**
** NAMES
**	scc	Steven C. Cavender
******************************************************************************
*/

/* 7201 control register 0 operations */

#define SELREG1		1
#define SELREG2		2
#define SELREG3		3
#define SELREG4		4
#define SELREG5		5
#define SELREG6		6
#define SELREG7		7
#define ABRTSDLC	8
#define REXSTINT	0x10
#define CHANRST		0x18
#define INTNXTRC	0x20
#define RSTTXINT	0x28
#define ERRRST		0x30
#define EOINT		0x38
#define RSTRXCRC	0x40
#define RSTTXCRC	0x80
#define RSTTXUR		0xC0

/* 7201 control register 1 operations */

#define EXINTEN		1
#define TXINTEN		2
#define STATAFV		4
#define RXINTDS		0
#define RXINT1		8
#define RXINTALP	0x10
#define RXINTANP	0x18
#define WAITRXTX	0x20
#define WAITEN		0x80
#define INTDSMSK	0xE4

/* 7201 control register 2A operations (2B is int vector) */

#define BOTHINT		0
#define ADMABINT	1
#define BOTHDMA		2
#define PRIAGB		0
#define PRIRGT		4
#define M8085M		0
#define M8085S		8
#define M8086		0x10
#define NONVEC		0
#define INTVEC		0x20
#define RTSBP10		0
#define SYNCBP10	0x80

/* 7201 control register 3 operations */

#define RXENABLE	1
#define SYNLDIN		2
#define ADRSRCH		4
#define RXCRCEN		8
#define ENTHUNT		0x10
#define AUTOENA		0x20
#define RX5BITS		0
#define RX7BITS		0x40
#define RX6BITS		0x80
#define RX8BITS		0xC0
#define RXSZMSK		0x3F

/* 7201 control register 4 operations */

#define PARENAB		1
#define EVENPAR		2
#define ODDPAR		0
#define SYNCMODE	0
#define SBIT1		4
#define SBIT1P5		8
#define SBIT2		0xC
#define SBITMSK		0xF3
#define SYN8BIT		0
#define	SYN16BIT	0x10
#define SDLCMODE	0x20
#define EXTSYNC		0x30
#define CLKX1		0
#define CLKX16		0x40
#define CLKX32		0x80
#define CLKX64		0xC0

/* 7201 control register 5 operations */

#define TXCRCEN		1
#define RTS		2
#define CRC16		4
#define CRCCCITT	0
#define TXENABLE	8
#define SENDBRK		0x10
#define TX5BITS		0
#define TX7BITS		0x20
#define TX6BITS		0x40
#define TX8BITS		0x60
#define TXSZMSK		0x9F
#define DTR		0x80

/* 7201 control register 6 = sync bits 0-7 */
/* 7201 control register 7 = sync bits 8-15 */

/* 7201 status register 0 */

#define RXCHAR		1		/*Recieve character available */
#define INTPNDNG	2
#define TXBUFEMP	4		/*Transmit register is empty  */
#define DCD		8
#define SYNCHUNT	0x10
#define CTS		0x20
#define TXUNDER		0x40
#define BRKABRT		0x80

/* 7201 status register 1 */

#define PARERR		0x10
#define RXOVRUN		0x20
#define CRCFRMER	0x40
#define EOFRAME		0x80

/* 7201 status register 2 = int vector */
