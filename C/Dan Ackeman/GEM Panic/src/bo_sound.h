
#ifndef _BO_SOUND_H
#define _BO_SOUND_H

extern long snd_system;
extern int sound_sys;
extern int snd_flag;
extern int temp_snd_flag;
extern int gemjing_id;
extern int sample_playing;

#define E_OK	0

/* chip sound defines */

#define S_APPEAR          0
#define S_MAGICBELL       1
#define S_BRICKSOUND      2
#define S_PERMBRICKSOUND  3
#define S_DEATH           4
#define S_LOSTBALL        5
#define S_PSOUND          6
#define S_OSOUND          7
#define S_BONUS           8
#define S_SIDE            9
#define S_TOP            10
#define S_BOTTOM         11

/* sound sys values */
#define ST_SOUND	1
#define STE_SOUND 	2
#define FLC_SOUND 	3

/* snd_flag values */
#define SND_OFF		0
#define	SND_CHIP	1
#define SND_XBIOS	2
#define SND_GEMJING	3

/* AVR defines */

#define AVR_MAGIC	0x32424954
#define AVR_MONO	0
#define AVR_STEREO	-1
#define AVR_UNSIGNED	0
#define AVR_SIGNED	-1
#define AVR_NON_LOOPING	0
#define AVR_LOOPING	-1
#define AVR_NOTE_NONE	-1

/* some sound structures */

typedef struct
{
 long magic;             /* ="2BIT"; */
 char name[8];           /* null-padded sample name */
 short mono;             /* 0 = mono, 0xffff = stereo */
 short rez;              /* 8 = 8 bit, 16 = 16 bit */
 short sign;             /* 0 = unsigned, 0xffff = signed */
 short loop;             /* 0 = no loop, 0xffff = looping sample */
 short midi;             /* 0xffff = no MIDI note assigned,
                            0xffXX = single key note assignment
                            0xLLHH = key split, low/hi note */
 long rate;              /* sample frequency in hertz */
 long size;              /* sample length in bytes or words (see rez) */
 long lbeg;              /* offset to start of loop in bytes or words.
                            set to zero if unused. */
 long lend;              /* offset to end of loop in bytes or words.
                            set to sample length if unused. */
 short res1;             /* Reserved, MIDI keyboard split */
 short res2;             /* Reserved, sample compression */
 short res3;             /* Reserved */
 char ext[20];           /* Additional filename space, used
                            if (name[7] != 0) */
 char user[64];          /* User defined. Typically ASCII message. */
} AVR_HEAD;

typedef struct 
{
	char fname[128];		/* filename of sample in sample directory */
	long length;			/* length of sample */
	long buf_len;			/* size of full buffer including header */
	long freq;				/* sample replay frequency */
	short rate;				/* sample replay 'rate' */
	short stereo;			/* Is the sample stereo */
	char name[28];			/* 28 character name - 0 padded */
	short rez;				/* 16 bit or 8 bit */
	short *buffer;			/* location of buffer */
	short *start;			/* start of sound data */
	short *end;				/* end of buffer */
	char zero;				/* a zero since h.name is not guaranteed */
							/* null terminated. */
}SAMPLE;

typedef struct
{
	SAMPLE *snd_data;
	int alt_chip;
}SND;

/* STe Sound Routines */

#define	sndbase	((volatile short *)0xffff8900L)

#define	sndbasehi	((volatile short *)0xffff8902L)
#define	sndbasemid	((volatile short *)0xffff8904L)
#define	sndbaselo	((volatile short *)0xffff8906L)

#define	sndendhi	((volatile short *)0xffff890eL)
#define	sndendmid	((volatile short *)0xffff8910L)
#define	sndendlo	((volatile short *)0xffff8912L)

#define	sndmode	((volatile short *)0xff8920L)


/* a few cookies */
#define _SND	0x5f534e44L
#define MgPC	0x4D675043L
#define McSn	0x4d63536eL

/* Some defines for DMA sound commands */

/**
 * Setbuffer() reg parameter values
**/
#define PLAY	0
#define	RECORD	1

/**
 * Soundcmd() mode parameter values
**/
#define	INQUIRE		-1
#define	LTATTEN		0
#define	RTATTEN		1
#define	LTGAIN		2
#define	RTGAIN		3
#define	ADDERIN		4
#define	ADCINPUT	5
#define	SETPRESCALE	6

/**
 * Sound BIOS errors
**/
#define	SNDNOTLOCK	-128
#define	SNDLOCKED	-129

/**
 * ADDERIN bit masks
**/
#define ADDERIN_ADC	1
#define ADDERIN_MATRIX	2

/**
 * SETPRESCALE values
**/
#define STE_6K		0	/* Invalid... won't do 6.25khz samples */
#define STE_12K		1	/* 12.5KHz STE/TT compatible */
#define STE_25K		2	/* 25KHz STE/TT compatible */
#define STE_50K		3	/* 50KHz STE/TT compatible */

/**
 * Setmode() parameter values
**/
#define	STEREO8		0
#define	STEREO16	1
#define	MONO8		2

/**
 * Buffoper parameter values
**/
#define	PLAY_ENABLE	0x1
#define	PLAY_REPEAT	0x2
#define	RECORD_ENABLE	0x4
#define	RECORD_REPEAT	0x8

/**
 * Dsptristate() parameter values
**/
#define	ENABLE		1
#define	TRISTATE	0

/**
 * Devconnect() source device parameter values
**/
#define	DMAPLAY	0	/* DMA playback */
#define	DSPXMIT	1	/* DSP transmit */
#define	EXTINP	2	/* External input */
#define	ADC	3	/* Microphone/PSG, see Soundcmd(ADCINPUT) */

/**
 * Devconnect() destination device parameter values
**/
#define	DMAREC	1	/* DMA record */
#define	DSPRECV	2	/* DSP receive */
#define	EXTOUT	4	/* External output */
#define	DAC		8	/* Headphone, internal speaker, monitor */

/**
 * Devconnect() clock input parameter values
**/
#define	CLK25M		0	/* internal 25.175 MHz clock */
#define	CLKEXT		1	/* external clock */
#define	CLK32M		2	/* internal 32 MHz */

/**
 * Devconnect() clock prescale parameter values
**/
#define CLK_OLD		0	/* STE/TT prescale values */
#define	CLK50K		1	/* 49170Hz */
#define	CLK33K		2	/* 33880Hz */
#define	CLK25K		3	/* 24585Hz */
#define	CLK20K		4	/* 20770Hz */
#define	CLK16K		5	/* 16490Hz */
#define	CLK12K		7	/* 12292Hz */
#define	CLK10K		9	/* 9834Hz */
#define	CLK8K		11	/* 8195Hz */

#define	ACT_CLK50K	49170
#define	ACT_CLK33K	33880
#define	ACT_CLK25K	24585
#define	ACT_CLK20K	20770
#define	ACT_CLK16K	16490
#define	ACT_CLK12K	12292
#define	ACT_CLK10K	9834
#define	ACT_CLK8K	8195

/**
 * Devconnect() protocol parameter values
**/
#define NO_SHAKE	1
#define HANDSHAKE	0

/* Now the actual routines */
int sound_init(void);
void sound_play(SND *p, int track, int mode);
void sound_wait(void);
void sound_stop(void);
void sound_exit(void);

SAMPLE *load_avr(char *avr);
void free_avr(SAMPLE *avr);

/* internal routines */
/* You can ignore these */

int chipsound_play(int num);
void chipsound_wait(void);
void chipsound_exit(void);

long wait_sample(void);
void stop_sound(void);

void play_avr(SAMPLE *p, int track, int mode);
void play_avr_once(char *avr_to_play, int track);

void startGEMJing(void);
void exitGEMJing(void);
int playGEMJing(SAMPLE *p);
void stopGEMJing(void);
void waitGEMJing(void);

#endif /* _BO_SOUND_H */

