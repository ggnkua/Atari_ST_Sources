/*
 * Atari ST hardware:
 * Motorola 68901 Multi-Function Peripheral
 */

#define	MFP	(((struct mfp *)AD_MFP) + 0)
#define	MFP2	(((struct mfp *)AD_MFP) + 1)	/* only in STE and TT */

struct mfp {
	_VOLATILE unsigned char	mfb[128];	/* use only the odd bytes */
};

#define	mf_gpip		mfb[ 1]	/* general purpose I/O interrupt port */
#define	mf_aer		mfb[ 3]	/* active edge register */
#define	mf_ddr		mfb[ 5]	/* data direction register */
#define	mf_iera		mfb[ 7]	/* interrupt enable register A */
#define	mf_ierb		mfb[ 9]	/* interrupt enable register B */
#define	mf_ipra		mfb[11]	/* interrupt pending register A */
#define	mf_iprb		mfb[13]	/* interrupt pending register B */
#define	mf_isra		mfb[15]	/* interrupt in-service register A */
#define	mf_isrb		mfb[17]	/* interrupt in-service register B */
#define	mf_imra		mfb[19]	/* interrupt mask register A */
#define	mf_imrb		mfb[21]	/* interrupt mask register B */
#define	mf_vr		mfb[23]	/* vector register */
#define	mf_tacr		mfb[25]	/* timer control register A */
#define	mf_tbcr		mfb[27]	/* timer control register B */
#define	mf_tcdcr	mfb[29]	/* timer control register C+D */
#define	mf_tadr		mfb[31]	/* timer data register A */
#define	mf_tbdr		mfb[33]	/* timer data register B */
#define	mf_tcdr		mfb[35]	/* timer data register C */
#define	mf_tddr		mfb[37]	/* timer data register D */
#define	mf_scr		mfb[39]	/* synchronous character register */
#define	mf_ucr		mfb[41]	/* USART control register */
#define	mf_rsr		mfb[43]	/* receiver status register */
#define	mf_tsr		mfb[45]	/* transmitter status register */
#define	mf_udr		mfb[47]	/* USART data register */

/* names of IO port bits: */
#define	IO_PBSY	0x01		/* Parallel Busy */
#define	IO_SDCD	0x02		/* Serial Data Carrier Detect */
#define	IO_SCTS	0x04		/* Serial Clear To Send */
/*		0x08		   reserved */
#define	IO_AINT	0x10		/* ACIA interrupt (KB or MIDI) */
#define	IO_DINT	0x20		/* DMA interrupt (FDC or HDC) */
#define	IO_SRI	0x40		/* Serial Ring Indicator */
#define	IO_MONO	0x80		/* Monochrome Monitor Detect */

/* names of interrupts in register A: */
#define	IA_MONO	0x80		/* IO_MONO (1st MFP only) */
#define	IA_SCSI	0x80		/* IO_SCSI (2nd MFP only) */
#define	IA_SRI	0x40		/* IO_SRI  (1st MFP only) */
#define	IA_RTC	0x40		/* IO_RTC  (2nd MFP only)*/
#define	IA_TIMA	0x20		/* Timer A */
#define	IA_RRDY	0x10		/* Serial Receiver Ready(=Full) */
#define	IA_RERR	0x08		/* Serial Receiver Error */
#define	IA_TRDY	0x04		/* Serial Transmitter Ready(=Empty) */
#define	IA_TERR	0x02		/* Serial Transmitter Error */
#define	IA_TIMB	0x01		/* Timer B */

/* names of interrupts in register B: */
#define	IB_DINT	0x80		/* IO_DINT:DMA 1st MFP ACSI/FDC; 2nd MFP SCSI */
#define	IB_AINT	0x40		/* IO_AINT: kbd or midi; 2nd MFP: reserved */
#define	IB_TIMC	0x20		/* Timer C */
#define	IB_TIMD	0x10		/* Timer D */
/*		0x08		   reserved (1st MFP only) */
#define	IB_SCCRI	0x08	/* IO_SCC Ring Indicator (2nd MFP only) */
#define	IB_SCTS	0x04		/* IO_SCTS (1st MFP only) */
#define	IB_SCC 	0x04		/* IO_SCC DMA (2nd MFP only) */
#define	IB_SDCD	0x02		/* IO_SDCD; 2nd MFP: general purpose */
#define	IB_PBSY	0x01		/* IO_PBSY; 2nd MFP: general purpose */

/* bits in VR: */
#define	V_S	0x08		/* software end-of-interrupt mode */
#define	V_V	0xF0		/* four high bits of vector */
#define	V_INIT	(0x40)		/* interrupts to vectors 0x40 to 0x4F */
				/* automatic end-of-interrupt mode    */
#define	V_INIT2	(0x50)		/* interrupts to vectors 0x50 to 0x5F */
				/* automatic end-of-interrupt mode    */

/* bits in TCR: */
/*		0x07		   divider */
#define	T_STOP	  0x00		/* don't count */
#define	T_Q004	  0x01		/* divide by 4 */
#define	T_Q010	  0x02		/* divide by 10 */
#define	T_Q016	  0x03		/* divide by 16 */
#define	T_Q050	  0x04		/* divide by 50 */
#define	T_Q064	  0x05		/* divide by 64 */
#define	T_Q100	  0x06		/* divide by 100 */
#define	T_Q200	  0x07		/* divide by 200 */
#define	T_EXTI	0x08		/* use extern impulse */
#define	T_LOWO	0x10		/* force output low */

/* bits in UCR: */
/*		0x01		   not used */
#define	U_EVEN	0x02		/* even parity */
#define	U_PAR	0x04		/* use parity */
/*		0x18		   sync/async and stop bits */
#define	U_SYNC	  0x00		/* synchrone */
#define	U_ST1	  0x08		/* async, 1 stop bit */
#define	U_ST1_5	  0x10		/* async, 1.5 stop bit */
#define	U_ST2	  0x18		/* async, 2 stop bits */
/*		0x60		   number of data bits */
#define	U_D8	  0x00		/* 8 data bits */
#define	U_D7	  0x20		/* 7 data bits */
#define	U_D6	  0x40		/* 6 data bits */
#define	U_D5	  0x60		/* 5 data bits */
#define	U_Q16	0x80		/* divide clock by 16 */

/* bits in RSR: */
#define	R_ENA	0x01		/* Receiver Enable */
#define	R_STRIP	0x02		/* Synchronous Strip Enable */
#define	R_CIP	0x04		/* Character in Progress */
#define	R_BREAK	0x08		/* Break Detected */
#define	R_FE	0x10		/* Frame Error */
#define	R_PE	0x20		/* Parity Error */
#define	R_OE	0x40		/* Overrun Error */
#define	R_FULL	0x80		/* Buffer Full */

/* bits in TSR: */
#define	T_ENA	0x01		/* Transmitter Enable */
/*		0x06		   state of dead transmitter output */
#define	T_TRI	  0x00		/* Quiet Output Tristate */
#define	T_LOW	  0x02		/* Quiet Output Low */
#define	T_HIGH	  0x04		/* Quiet Output High */
#define	T_BACK	  0x06		/* Loop Back Mode */
#define	T_BREAK	0x08		/* Break Detected */
#define	T_EOT	0x10		/* End of Transmission */
#define	T_TURN	0x20		/* Auto Turnaround */
#define	T_UE	0x40		/* Underrun Error */
#define	T_EMPTY	0x80		/* Buffer Empty */
