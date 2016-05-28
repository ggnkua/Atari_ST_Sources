/*
* SNDBIND.H	Low level Sound function bindings for use with PC
*		and the added Sound XBIOS calls.
*
*		Mike Schmal		7/7/92
*		Revised Brainstorm	25/8/92
*
* Updates:
* 7/13/92 MS  Added buffptr function.
*
*/

#define	INQUIRE		-1

/*
 *  SOUND XBIOS Errors.
 */

#define	SNDNOTLOCK	-128
#define	SNDLOCKED	-129

/*
 *  SOUND XBIOS Enums.
 */

typedef enum {		/* used by SndCmd */
	LTATTEN=0,
	RTATTEN,
	LTGAIN,
	RTGAIN,
	ADDERIN,
	ADCINPUT,
	SETPRESCALE
} SNDCMD_ENUM;

typedef enum {		/* used by SndSetMode */
	STEREO8=0,
	STEREO16,
	MONO8
} SNDMODE_ENUM;

typedef enum {		/* used by SndDspTristate */
	TRISTATE=0,
	ENABLE
} SNDDSP_ENUM;

typedef enum {		/* used by SndBufOper */
	NO_OP=0,
	PLAY_ENABLE=1,
	PLAY_REPEAT=2,
	RECORD_ENABLE=4,
	RECORD_REPEAT=8
} SNDOP_ENUM;

typedef enum {		/* used by SndSetBuffer */
	PLAY=0,
	RECORD
} SNDSETBUF_ENUM;

typedef enum {		/* used by SndDevConnect */
	DMAPLAY=0,
	DSPXMIT,
	EXTINP,
	ADC
} SNDSRC_ENUM;

typedef enum {		/* used by SndDevConnect */
	DMAREC=1,
	DSPRECV=2,
	EXTOUT=4,
	DAC=8
} SNDDST_ENUM;

typedef enum {		/* used by SndDevConnect */
	CLK_25M=0,
	CLK_EXT,
	CLK_32M
} SNDSRCLK_ENUM;

typedef enum {		/* used by SndDevConnect */
	CLK50K=1,
	CLK33K=2,
	CLK25K=3,
	CLK20K=4,
	CLK16K=5,
	CLK12K=7,
	CLK10K=9,
	CLK8K=11
} SNDCLK_ENUM;

typedef enum {		/* used by SndDevConnect */
	HANDSHAKE=0,
	NOHANDSHAKE
} SNDHNDSHK_ENUM;

enum SNDACTCLK_ENUM {
	ACT_CLK50K=49170L,
	ACT_CLK33K=33880L,
	ACT_CLK25K=24585L,
	ACT_CLK20K=20770L,
	ACT_CLK16K=16490L,
	ACT_CLK12K=12292L,
	ACT_CLK10K=9834L,
	ACT_CLK8K=8195L
};

typedef	long	SNDACTCLK_ENUM;

typedef	void	*SAM_PTR;

typedef	struct {	/* used by SndBufPtr */
	SAM_PTR	play;
	SAM_PTR	record;
	SAM_PTR	res1;
	SAM_PTR	res2;
} SNDBUF_STRUCT;

/*
 * SOUND XBIOS trap calling routine.
 */

short	IsSndDrv(void);
long	SndLock(void);
long	SndUnlock(void);
long	SndCmd(SNDCMD_ENUM,short);
long	SndSetBuffer(SNDSETBUF_ENUM,SAM_PTR,SAM_PTR);
long	SndSetMode(SNDMODE_ENUM);
long	SndSetTrack(short,short);
long	SndSetMonTrack(short);
long	SndSetInterrupt(short,short);
long	SndBufOper(SNDOP_ENUM);
long	SndDspTriState(SNDDSP_ENUM,SNDDSP_ENUM);
long	SndGpio(short,short);
long	SndDevConnect(SNDSRC_ENUM,SNDDST_ENUM,SNDSRCLK_ENUM,SNDCLK_ENUM,short);
long	SndStatus(short);
long	SndBufPtr(SNDBUF_STRUCT *);

#define	AVR_MAGIC	'2BIT'

typedef struct {
	long	magic;	/* '2BIT' */
	char	name[8];
	short	stereo;	/* 0:mono/-1:stereo */
	short	res;	/* 8/16 bit */
	short	sign;	/* 0/-1 */
	short	loop;	/* 0/-1/... */
	short	note;	/* -1/0xffXX/0xLLHH */
	long	freq;	/* XX/freq in Hz */
	long	length;
	long	first;	/* 0L if unused */
	long	last;	/* length is unused */
	short	midi;
	short	comp;
	short	fill;	/* 0 */
	char	ext[20];	/* cat with name */
	char	user[64];
} AVR_STRUCT;

typedef	AVR_STRUCT *AVR_PTR;
