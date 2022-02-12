/*
 * Atari ST hardware:
 * Yahama YM-2149 Programmable Sound Generator
 */

#define	SOUND	((struct sound *)AD_SOUND)

struct sound {
	_VOLATILE unsigned char	sdb[4];		/* use only the even bytes */
};

#define	sd_selr		sdb[0]	/* select register */
#define	sd_rdat		sdb[0]	/* read register data */
#define	sd_wdat		sdb[2]	/* write register data */

/*
 * Accessing the YM-2149 registers is indirect through ST-specific
 * circuitry by writing the register number into sd_selr.
 */
#define	YM_PA0		0	/* Period Channel A, bits 0-7 */
#define	YM_PA1		1	/* Period Channel A, bits 8-11 */
#define	YM_PB0		2	/* Period Channel B, bits 0-7 */
#define	YM_PB1		3	/* Period Channel B, bits 8-11 */
#define	YM_PC0		4	/* Period Channel C, bits 0-7 */
#define	YM_PC1		5	/* Period Channel C, bits 8-11 */
#define	YM_PNG		6	/* Period Noise Generator, bits 0-4 */
#define	YM_MFR		7	/* Multi Function Register */
#define	YM_VA		8	/* Volume Channel A */
#define	YM_VB		9	/* Volume Channel B */
#define	YM_VC		10	/* Volume Channel C */
#define	YM_PE0		11	/* Period Envelope, bits 0-7 */
#define	YM_PE1		12	/* Period Envelope, bits 8-15 */
#define	YM_WFE		13	/* Wave Form Envelope */
#define	YM_IOA		14	/* I/O port A */
#define	YM_IOB		15	/* I/O port B */

/* bits in MFR: */
#define	SA_OFF	0x01		/* Sound Channel A off */
#define	SB_OFF	0x02		/* Sound Channel B off */
#define	SC_OFF	0x04		/* Sound Channel C off */
#define	NA_OFF	0x08		/* Noise Channel A off */
#define	NB_OFF	0x10		/* Noise Channel B off */
#define	NC_OFF	0x20		/* Noise Channel C off */
#define	PA_OUT	0x40		/* Port A for Output */
#define	PB_OUT	0x80		/* Port B for Output */

/* bits in Vx: */
#define	VOLUME	0x0F		/* 16 steps */
#define	ENVELOP	0x10		/* volume steered by envelope */

/* bits in WFE: */
#define	WF_HOLD		0x01	/* hold after one period */
#define	WF_ALTERNATE	0x02	/* up and down (no saw teeth) */
#define	WF_ATTACK	0x04	/* start up */
#define	WF_CONTINUE	0x08	/* multiple periods */

/* names for bits in Port A (ST specific): */
#define	PA_SIDEB	0x01	/* select floppy head if double-sided */
#define	PA_FLOP0	0x02	/* Drive Select Floppy 0 */
#define	PA_FLOP1	0x04	/* Drive Select Floppy 1 */
#define	PA_SRTS		0x08	/* Serial RTS */
#define	PA_SDTR		0x10	/* Serial DTR */
#define	PA_PSTROBE	0x20	/* Parallel Strobe */
#define	PA_USER		0x40	/* Free Pin on Monitor Connector */
#define	PA_FDDENS	0x80	/* floppy density selection (not standard) */
