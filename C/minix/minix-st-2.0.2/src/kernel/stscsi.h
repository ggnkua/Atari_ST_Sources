/*
 * Atari TT hardware:
 * SCSI circuitry (NCR 5380)
 */

#define	SCSI_HW	((struct scsi *)AD_SCSI)

struct scsi {
    _VOLATILE unsigned char	scsi_regs[16];	/* use only odd bytes */
};
			/* RO = read only, WO = write only, RW = read/write */
#define	ODR      scsi_regs[1]		/* output data register (WO) */
#define	CSD      scsi_regs[1]		/* current SCSI data (RO) */
#define	ICR      scsi_regs[3]		/* initiator command register (RW) */
#define	MR2      scsi_regs[5]		/* mode register 2 (RW) */
#define	TCR      scsi_regs[7]		/* target command register (RW) */
#define	SER      scsi_regs[9]		/* select enable register (WO) */
#define	CSB      scsi_regs[9]		/* current SCSI bus status (RO) */
#define	BSR      scsi_regs[11]		/* bus and status (RO) */
#define	SDS      scsi_regs[11]		/* start DMA send (WO) */
#define	SDT      scsi_regs[13]		/* start DMA target receive (WO) */
#define	IDR      scsi_regs[13]		/* input data register (RO) */
#define	SDI      scsi_regs[15]		/* start DMA initiator receive (WO) */
#define	RPI      scsi_regs[15]		/* reset parity/interrupts (RO) */

/* intitiator command register bits */

#define ASS_DBUS 0x01		/* assert data bus */
#define ASS_ATN	 0x02		/* assert attention */
#define ASS_SEL	 0x04		/* assert select */
#define ASS_BSY	 0x08		/* assert busy */
#define ASS_ACK	 0x10		/* assert acknowledge */
#define DIFF	 0x20		/* differential enable (WO) (not used) */
#define LA	 0x20		/* lost arbitration (RO) */
#define TEST	 0x40		/* test mode enable (WO) */
#define AIP	 0x40		/* arbitration in progress (RO) */
#define ASS_RST	 0x80		/* assert rst */

/* mode register 2 bits */

#define ARB	0x01		/* arbitrate */
#define DMA	0x02		/* dma mode */
#define MBSY	0x04		/* monitor busy */
#define EOP	0x08		/* enable eop interrupt */
#define PINT	0x10		/* enable SCSI partiy interrupt */
#define PCHK	0x20		/* enable SCSI parity checking */
#define TARG	0x40		/* target mode */
#define BLK	0x80		/* block mode dma */

/* target command register bits */

#define ASS_IO	0x01		/* assert I/O */
#define ASS_CD	0x02		/* assert C/D */
#define ASS_MSG	0x04		/* assert MSG */
#define ASS_REQ	0x08		/* assert REQ */

/* current SCSI bus status register bits */

#define DBP	0x01		/* DBP (parity) */
#define SEL	0x02		/* SEL */
#define IO	0x04		/* I/O */
#define CD	0x08		/* C/D */
#define MSG	0x10		/* MSG */
#define REQ	0x20		/* REQ */
#define BSY	0x40		/* BSY */
#define RST	0x80		/* RST */

/* combinations for different scsi phases */

#define CSB_PHASE_MASK		0x1c

#define DATA_OUT_PHASE		0
#define DATA_IN_PHASE		IO
#define COMMAND_PHASE		CD
#define STATUS_PHASE		(IO | CD)
#define MESSAGE_OUT_PHASE	(MSG | CD)
#define MESSAGE_IN_PHASE	(MSG | CD | IO)

/* bus and status register bits */

#define ACKN	0x01		/* Acknowledge */
#define ATN	0x02		/* Attention */
#define MBSY	0x04		/* Busy error */
#define PHSM	0x08		/* phase match */
#define INT	0x10		/* interrupt request */
#define SPER	0x20		/* SCSI parity error */
#define DRQ	0x40		/* DMA request */
#define EDMA	0x80		/* End of DMA */
