/* Setbuffer regions */

#define	SR_PLAY		0	/* Set playback registers */
#define	SR_RECORD	1	/* Set record registers */

/* Soundcmd Modes */

#define LTATTEN		0	/* Left-channel output attenuation */
#define	RTATTEN		1	/* Right channel atten */
#define	LTGAIN		2	/* Left input gain */
#define	RTGAIN		3	/* Right channel gain */
	/* gain and attenuation in 1.5db units, 0x00V0, V:0-15 */
#define	ADDERIN		4	/* Select inputs to adder 0=off, 1=on */
#define	ADCIN		1	/* Input from ADC */
#define	MATIN		2	/* Input from connection matrix */
#define	ADCINPUT	5	/* Select input to ADC, 0=mic, 1=PSG */
#define	ADCRT		1	/* Right channel input */
#define	ADCLT		2	/* Left input */
#define	SETPRESCALE	6	/* Set TT compatibility prescaler */
#define	PREMUTE		0	/* was /1280, now is invalid, mutes */
#define	PRE1280		PREMUTE
#define	PRE640		1	/* divide by 640 */
#define	PRE320		2	/* / 320 */
#define	PRE160		3	/* / 160 */

/* Record/Playback modes */

#define	STEREO8		0	/* 8 bit stereo */
#define	STEREO16	1	/* 16 bit stereo */
#define	MONO8		2	/* 8 bit mono */

/* Record/Playback tracks range from 0 to 3 */

/* XXX Doc for Settracks could be clearer. Can we individually set, e.g.,
   tracks 0 & 2 for playback, or must track selections be contiguous? */

/* Sound buffer interrupts */
	/* sources */
#define	SI_TIMERA	0	/* Timer A interrupt */
#define	SI_MFPI7	1	/* MFP interrupt 7 */
	/* causes */
#define	SI_NONE		0	/* No interrupts */
#define	SI_PLAY		1	/* Intr at end of play buffer */
#define	SI_RECORD	2	/* Intr at end of record buffer */
#define	SI_BOTH		3	/* Interrupt for either play or record */

/* Buffoper flags */

#define	SB_PLA_ENA	1	/* Play enable */
#define	SB_PLA_RPT	2	/* Play repeat (continuous loop mode) */
#define	SB_REC_ENA	4	/* Record enable */
#define SB_REC_RPT	8	/* Record repeat */

/* Dsptristate - 0=tristate, 1=enable */

/* Gpio modes */

#define	GPIO_SET	0	/* Set I/O direction, 0=in, 1=out */
#define	GPIO_READ	1	/* Read bits - only 3 bits on gpio */
#define	GPIO_WRITE	2	/* Write gpio data bits */

/* Devconnect (connection matrix) source devices */

#define	DMAPLAY		0	/* DMA playback */
#define	DSPXMIT		1	/* DSP transmit */
#define	EXTINP		2	/* External input */
#define	ADC		3	/* Microphone/PSG, see Soundcmd(ADCINPUT) */

/* Devconnect destination devices, bitmapped */

#define	DMAREC		1	/* DMA record */
#define	DSPRECV		2	/* DSP receive */
#define	EXTOUT		4	/* External output */
#define	DAC		8	/* Headphone, internal speaker, monitor */

/* Devconnect clock sources */

#define	CLK25M		0	/* Internal 25.175 MHz clock */
#define	CLKEXT		1	/* External clock */
#define	CLK32M		2	/* Internal 32 MHz. Invalid for CODEC */

/* Devconnect clock prescaler values */

/* XXX Doc lists incorrect hz numbers for many of these... */

#define CLKOLD		0	/* TT compatible, see Soundcmd(SETPRESCALE) */
#define	CLK50K		1	/* 49170 hz */
#define	CLK33K		2	/* 32780 hz */
#define	CLK25K		3	/* 24585 hz */
#define	CLK20K		4	/* 19668 hz */
#define	CLK16K		5	/* 16390 hz */
		/*	6	(14049 hz) invalid for CODEC */
#define	CLK12K		7	/* 12292 hz */
		/*	8	(10927 hz) invalid for CODEC */
#define	CLK10K		9	/* 9834 hz */
		/*	10	(8940 hz) invalid for CODEC */
#define	CLK8K		11	/* 8195 hz */
		/*	12	(7565 hz) invalid */
		/*	13	(7024 hz) invalid */
		/*	14	(6556 hz) invalid */
		/*	15	(6146 hz) invalid */

#define DISABLE     0
#define ENABLE      1

#define HANDSHAKE   0
#define NOSHAKE     1

/* Sndstatus command */

#define	SND_CHECK	0	/* Check current status */
#define	SND_RESET	1	/* Reset sound system */
	/*
	 * Reset effects: DSP tristated, gain=atten=0, matrix reset,
	 * ADDERIN=0, Mode=STEREO8, Play=Record=Monitor tracks=0,
	 * interrupts disabled, buffer operation disabled.
	 */

/* Sndstatus status return */

#define	SS_OK		0	/* No errors */
#define	SS_CTRL		1	/* Invalid control field (Data assumed OK) */
#define	SS_SYNC		2	/* Invalid sync format (mutes) */
#define	SS_SCLK		3	/* Serial clock out of valid range (mutes) */

#define	SS_RTCLIP	0x10	/* Right channel is clipping */
#define	SS_LTCLIP	0x20	/* Left channel is clipping */

/* Structure used by Buffptr */

typedef struct SndBufPtr {
	char *play;
	char *record;
	long reserve1;
	long reserve2;
} SndBufPtr;
