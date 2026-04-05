/*
 * GNU-C Bindings for Falcon XBIOS functions
 * -- hyc 11-9-1992 (uunet!hanauma.Jpl.Nasa.Gov!hyc)
 */

#ifndef _FALCON_H
#define _FALCON_H 1

#ifndef _MINT_OSBIND_H
# include <mint/osbind.h>
#endif

__BEGIN_DECLS

#ifndef trap_14_wwwwww
#define trap_14_wwwwww(n,a,b,c,d,e)					\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
									\
	__asm__ volatile						\
	(								\
		"movw	%6,%%sp@-\n\t"					\
		"movw	%5,%%sp@-\n\t"					\
		"movw	%4,%%sp@-\n\t"					\
		"movw	%3,%%sp@-\n\t"					\
		"movw	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#14\n\t"					\
		"lea	%%sp@(12),%%sp"					\
	: "=r"(__retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e)		\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc", "memory");		\
	__retvalue;							\
})
#endif

#ifndef trap_14_wllll
#define trap_14_wllll(n,a,b,c,d)					\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
									\
	__asm__ volatile						\
	(								\
		"movl	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#14\n\t"					\
		"lea	%%sp@(18),%%sp"					\
	: "=r"(__retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d)			\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc", "memory");		\
	__retvalue;							\
})
#endif

#ifndef trap_14_wllllll
#define trap_14_wllllll(n,a,b,c,d,e,f)					\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
	long _e = (long)(e);						\
	long _f = (long)(f);						\
									\
	__asm__ volatile						\
	(								\
		"movl	%7,%%sp@-\n\t"					\
		"movl	%6,%%sp@-\n\t"					\
		"movl	%5,%%sp@-\n\t"					\
		"movl	%4,%%sp@-\n\t"					\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#14\n\t"					\
		"lea	%%sp@(26),%%sp"					\
	: "=r"(__retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e), "r"(_f)	\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc", "memory");		\
	__retvalue;							\
})
#endif

#ifndef trap_14_wll
#define trap_14_wll(n,a,b)						\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
									\
	__asm__ volatile						\
	(								\
		"movl	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#14\n\t"					\
		"lea	%%sp@(10),%%sp"					\
	: "=r"(__retvalue)						\
	: "g"(n), "r"(_a), "r"(_b)					\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc", "memory");		\
	__retvalue;							\
})
#endif

#ifndef trap_14_wlwl
#define trap_14_wlwl(n,a,b,c)						\
__extension__								\
({									\
	register long __retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	short _b = (short)(b);						\
	long _c = (long)(c);						\
									\
	__asm__ volatile						\
	(								\
		"movl	%4,%%sp@-\n\t"					\
		"movw	%3,%%sp@-\n\t"					\
		"movl	%2,%%sp@-\n\t"					\
		"movw	%1,%%sp@-\n\t"					\
		"trap	#14\n\t"					\
		"lea	%%sp@(12),%%sp"					\
	: "=r"(__retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)				\
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc", "memory");		\
	__retvalue;							\
})
#endif


/*
 * Video
 */

/* Bitmasks for Vsetmode() */
#define BPS1			0x00
#define BPS2			0x01
#define BPS4			0x02
#define BPS8			0x03
#define BPS16			0x04
#define BPS32			0x05	/* SuperVidel's RGBx truecolour (4 bytes per pixel) */
#define BPS8C			0x07	/* SuperVidel's 8-bit chunky mode */

#define COL80			0x08	/* 80 column if set, else 40 column */
#define COL40			0x00

#define VGA				0x10	/* VGA if set, else TV mode */
#define TV				0x00

#define PAL				0x20	/* PAL if set, else NTSC */
#define NTSC			0x00

#define OVERSCAN		0x40	/* Multiply X&Y rez by 1.2, ignored on VGA */

#define STMODES			0x80	/* ST compatible */

#define VERTFLAG		0x100	/* double-line on VGA, interlace on ST/TV */

/*
 * Bits 9-13 specify SuperVidel's base resolution:
 *
 * 0: 640x480; 1280x720 (with OVERSCAN set)
 * 1: 800x600; 1680x1050 (with OVERSCAN set)
 * 2: 1024x768; 1920x1080 (with OVERSCAN set)
 * 3: 1280x1024; 1920x1200 (with OVERSCAN set)
 * 4: 1600x1200; 2560x1440 (with OVERSCAN set)
 */
#define SVEXT_BASERES(res) ((res & 0xf) << 9)	/* specify base resolution */
#define	SVEXT			0x4000	/* enable SuperVidel's extensions */

#define VM_INQUIRE		-1

#define	NUMCOLS		7	/* Mask for number of bits per pixel */

/* VgetMonitor() return values */
enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};

/* Values returned by VgetMonitor() */
#define MON_MONO		0
#define MON_COLOR		1
#define MON_VGA			2
#define MON_TV			3

/* VsetSync flags - 0=internal, 1=external */

#define	VID_CLOCK	1
#define	VID_VSYNC	2
#define	VID_HSYNC	4

/* VsetSync() params */
#define VCLK_EXTERNAL	0
#define VCLK_EXTVSYNC	1
#define VCLK_EXTHSYNC	2

#define OVERLAY_ON		1
#define OVERLAY_OFF		0

/* Bitmasks for Dsp_RemoveInterrupts() */
#define RTS_OFF			0x01
#define RTR_OFF			0x02

/* Dsp_Hf0() params */
#define HF_CLEAR		0
#define HF_SET			1
#define HF_INQUIRE		-1

/* Dsp_Hstat() bits */
#define ICR_RXDF		0
#define ICR_TXDE		1
#define ICR_TRDY		2
#define ICR_HF2			3
#define ICR_HF3			4
#define ICR_DMA			6
#define ICR_HREQ		7

/* Dsp_SetVectors() params */
#define DSPSEND_NOTHING	0x00000000
#define DSPSEND_ZERO	0xff000000

/* Dsp_MultBlocks() params */
#define BLOCK_LONG 0
#define BLOCK_WORD 1
#define BLOCK_UBYTE 2

#define VsetScreen(lscrn,pscrn,rez,mode)					\
	(void)trap_14_wllww((short)5,(long)(lscrn),(long)(pscrn),	\
		(short)(rez),(short)(mode))
#define VsetMode(mode)							\
	(short)trap_14_ww((short)88,(short)(mode))
#define VgetMonitor()							\
	(short)trap_14_w((short)89)
#define	VgetSize(mode)							\
	(long)trap_14_ww((short)91,(short)(mode))
#define	VsetSync(ext)							\
	(void)trap_14_ww((short)90,(short)(ext))
#define VsetRGB(index,count,array)					\
	(void)trap_14_wwwl((short)93,(short)(index),(short)(count),	\
		(long *)(array))
#define VgetRGB(index,count,array)					\
	(void)trap_14_wwwl((short)94,(short)(index),(short)(count),	\
		(long *)(array))
#define Validmode(mode)							\
	(short)trap_14_ww((short)95,(short)(mode))
#define VsetMask(ormask,andmask,overlay)					\
	(short)trap_14_www((short)150,(long)(ormask),(long)(andmask),(short)(overlay))


/*
 * Sound
 */

/* _SND cookie values */

#define SND_PSG		0x01	/* PSG */
#define	SND_8BIT	0x02	/* 8-bit DMA */
#define	SND_16BIT	0x04	/* 16-bit CODEC */
#define	SND_DSP		0x08	/* DSP */
#define	SND_MATRIX	0x10	/* Connection matrix */
#define SND_EXT		0x20	/* Extended XBIOS routines (Milan, GSXB) */

/*
 * Sound data memory layout - samples are all signed values
 *
 * 				(each char = 1 byte, 2 chars = 1 word)
 * 1 16 bit stereo track:	LLRRLLRRLLRRLLRR
 * 1 8 bit stereo track:	LRLRLRLR  
 * 2 16 bit stereo tracks:	L0R0L1R1L0R0L1R1
 *  etc...
 */

/* Setbuffer regions */

#define	SR_PLAY		0	/* Set playback registers */
#define	SR_RECORD	1	/* Set record registers */

/* Soundcmd Modes */

#define LTATTEN		0	/* Left-channel output attenuation */
#define	RTATTEN		1	/* Right channel atten */
#define	LTGAIN		2	/* Left input gain */
#define	RTGAIN		3	/* Right channel gain */
	/* gain and attenuation in 1.5 dB units, 0x00V0, V:0-15 */
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

#define SS_ERROR	0xf


/* Soundcmd() params */

#define LEFT_MIC		0x00
#define LEFT_PSG		0x02
#define RIGHT_MIC		0x00
#define RIGHT_PSG		0x01

#define SND_INQUIRE		-1

/* Value returned by Locksnd() */
#define SNDLOCKED		-129

/* Value returned by Unlocksnd() */
#define SNDNOTLOCK		-128

/* Setmode() modes */
#define MODE_STEREO8	0
#define MODE_STEREO16	1
#define MODE_MONO		2

/* Dsptristate() params */
#define DSP_TRISTATE	0
#define DSP_ENABLE		1

#define HANDSHAKE		0
#define NO_SHAKE		1

/* Structure used by Dsp_MultBlocks() */
typedef struct
{
	short  blocktype;
	long  blocksize;
	void* blockaddr;
} _DSPBLOCK;

/* Structure used by Buffptr */

typedef struct SndBufPtr {
	char *play;
	char *record;
	long reserve1;
	long reserve2;
} SndBufPtr;

#define Locksnd()							\
	(long)trap_14_w((short)128)
#define Unlocksnd()							\
	(long)trap_14_w((short)129)
#define Setbuffer(region,beg,end)					\
	(long)trap_14_wwll((short)131,(short)(region),(long)(beg),(long)(end))
#define Soundcmd(mode,data)						\
	(long)trap_14_www((short)130,(short)(mode),(short)(data))
#define NSoundcmd(mode,data,data2)						\
	(long)trap_14_wwwl((short)130,(short)(mode),(short)(data),(long)(data2))
#define Setmode(stereo_mode)						\
	(long)trap_14_ww((short)132,(short)(stereo_mode))
#define Settracks(play,rec)						\
	(long)trap_14_www((short)133,(short)(play),(short)(rec))
#define Setmontracks(montrack)						\
	(long)trap_14_ww((short)134,(short)(montrack))
#define Setinterrupt(src_inter,cause)					\
	(long)trap_14_www((short)135,(short)(src_inter),		\
		(short)(cause))
#define NSetinterrupt(src_inter,cause,inth_addr)			\
		(long)trap_14_wwwl((short)135,(short)(src_inter),	\
		(short)(cause),(long)(inth_addr))
#define Buffoper(mode)							\
	(long)trap_14_ww((short)136,(short)(mode))
#define Dsptristate(dspxmit,dsprec)					\
	(long)trap_14_www((short)137,(short)(dspxmit),			\
		(short)(dsprec))
#define Gpio(mode,data)							\
	(long)trap_14_www((short)138,(short)(mode),(short)(data))
#define Devconnect(src,dst,sclk,pre,proto)				\
	(long)trap_14_wwwwww((short)139,(short)(src),(short)(dst),	\
		(short)(sclk),(short)(pre),(short)(proto))
#define Sndstatus(reset)						\
	(long)trap_14_ww((short)140,(short)(reset))
#define Buffptr(ptr)							\
	(long)trap_14_wl((short)141,(long)(ptr))


/*
 * DSP functions
 *
 * Don't even *think* of trying to use these without the manual!
 */

#define	Dsp_DoBlock(data_in,size_in,data_out,size_out)			\
	(void)trap_14_wllll((short)96,(long)(data_in),(long)(size_in),	\
		(long)(data_out),(long)(size_out))
#define	Dsp_BlkHandShake(data_in,size_in,data_out,size_out)		\
	(void)trap_14_wllll((short)97,(long)(data_in),(long)(size_in),	\
		(long)(data_out),(long)(size_out))
#define	Dsp_BlkUnpacked(data_in,size_in,data_out,size_out)		\
	(void)trap_14_wllll((short)98,(long)(data_in),(long)(size_in),	\
		(long)(data_out),(long)(size_out))
#define	Dsp_BlkWords(data_in,size_in,data_out,size_out)			\
	(void)trap_14_wllll((short)123,(long)(data_in),(long)(size_in),	\
		(long)(data_out),(long)(size_out))
#define	Dsp_BlkBytes(data_in,size_in,data_out,size_out)			\
	(void)trap_14_wllll((short)124,(long)(data_in),(long)(size_in),	\
		(long)(data_out),(long)(size_out))
#define	Dsp_MultBlocks(numsend,numrecv,sendblks,recvblks)		\
	(void)trap_14_wllll((short)127,(long)(numsend),(long)(numrecv),	\
		(long)(sendblks),(long)(recvblks))
#define	Dsp_InStream(data_in,blksiz,numblks,blksdone)			\
	(void)trap_14_wllll((short)99,(long)(data_in),(long)(blksiz),	\
		(long)(numblks),(long)(blksdone))
#define	Dsp_OutStream(data_out,blksiz,numblks,blksdone)			\
	(void)trap_14_wllll((short)100,(long)(data_out),(long)(blksiz),	\
		(long)(numblks),(long)(blksdone))
#define	Dsp_IOStream(data_in,data_out,blkisiz,blkosiz,numblks,blksdone)	\
	(void)trap_14_wllllll((short)101,(long)(data_in),(long)(data_out),\
		(long)(blkisiz),(long)(blkosiz),(long)(numblks),	\
		(long)(blksdone))
#define	Dsp_SetVectors(rcvr,xmtr)					\
	(void)trap_14_wll((short)126,(long)(rcvr),(long)(xmtr))
#define	Dsp_RemoveInterrupts(mask)					\
	(void)trap_14_ww((short)102,(short)(mask))
#define	Dsp_GetWordSize()	(short)trap_14_w((short)103)
#define	Dsp_Lock()		(short)trap_14_w((short)104)
#define	Dsp_Unlock()		(void)trap_14_w((short)105)
#define	Dsp_Available(xmem,ymem)					\
	(void)trap_14_wll((short)106,(long)(xmem),(long)(ymem))
#define	Dsp_Reserve(xmem,ymem)						\
	(short)trap_14_wll((short)107,(long)(xmem),(long)(ymem))
#define	Dsp_LoadProg(file,ability,buffer)				\
	(short)trap_14_wlwl((short)108,(long)(file),(short)(ability),	\
		(long)(buffer))
#define	Dsp_ExecProg(codeptr,codesiz,ability)				\
	(void)trap_14_wllw((short)109,(long)(codeptr),(long)(codesiz),	\
		(short)(ability))
#define	Dsp_ExecBoot(codeptr,codesiz,ability)				\
	(void)trap_14_wllw((short)110,(long)(codeptr),(long)(codesiz),	\
		(short)(ability))
#define	Dsp_LodToBinary(file,codeptr)					\
	(long)trap_14_wll((short)111,(long)(file),(long)(codeptr))
#define	Dsp_TriggerHC(vector)						\
	(void)trap_14_ww((short)112,(short)(vector))
#define	Dsp_RequestUniqueAbility()	(short)trap_14_w((short)113)
#define	Dsp_GetProgAbility()		(short)trap_14_w((short)114)
#define	Dsp_FlushSubroutines()		(void)trap_14_w((short)115)
#define	Dsp_LoadSubroutine(ptr,siz,ability)				\
	(short)trap_14_wllw((short)116,(long)(ptr),(long)(siz),		\
		(short)(ability))
#define	Dsp_InqSubrAbility(ability)					\
	(short)trap_14_ww((short)117,(short)(ability))
#define	Dsp_RunSubroutine(handle)					\
	(short)trap_14_ww((short)118,(short)(handle))
#define	Dsp_Hf0(flag)							\
	(short)trap_14_ww((short)119,(short)(flag))
#define	Dsp_Hf1(flag)							\
	(short)trap_14_ww((short)120,(short)(flag))
#define	Dsp_Hf2()		(short)trap_14_w((short)121)
#define	Dsp_Hf3()		(short)trap_14_w((short)122)
#define	Dsp_HStat()		(char)trap_14_w((short)125)

__END_DECLS

#endif /* _FALCON_H */
