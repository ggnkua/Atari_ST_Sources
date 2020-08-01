/*
 * GNU-C Bindings for Falcon XBIOS functions
 * -- hyc 11-9-92 (uunet!hanauma.Jpl.Nasa.Gov!hyc)
 */

#ifndef _FALCON_H
#define _FALCON_H

#ifndef _OSBIND_H
#include <osbind.h>
#endif

#ifdef __LATTICE__

#define __F_TRAP {register d2,a2; "4e4e";}

void _vfv(int);
char _bfv(int);
short _sfv(int);
long _lfv(int);

void _vfs(int, int);
short _sfs(int, int);
long _lfs(int, int);

void _vfss(int, int, int);
long _lfss(int, int, int);
void _vfll(int, long, long);
void _vflp(int, long, void *);

void _vfssr(int, int, int, long *);
void _vfssR(int, int, int, const long *);
void _vfpls(int, void *, long, int);
short _sflsp(int, long, int, void *);
short _sfpls(int, void *, long, int);
long _lfspp(int, int, void *, void *);

short _sfppss(int, void *, void *, int, int);
void _vfllpp(int, long, long, void *, void *);
void _vfplll(int, void *, long, long, long);
void _vfplpl(int, void *, long, void *, long);

long _lfsssss(int, int, int, int, int, int);

void _vfppllll(int, void *, void *, long, long, long, long);


#pragma inline _vfv((short))	__F_TRAP
#pragma inline d0=_bfv((short))	__F_TRAP
#pragma inline d0=_sfv((short))	__F_TRAP
#pragma inline d0=_lfv((short))	__F_TRAP

#pragma inline _vfs((short),(short))	__F_TRAP
#pragma inline d0=_sfs((short),(short))	__F_TRAP
#pragma inline d0=_lfs((short),(short))	__F_TRAP

#pragma inline _vfss((short),(short),(short))	__F_TRAP
#pragma inline d0=_lfss((short),(short),(short))	__F_TRAP
#pragma inline _vfll((short),,)	__F_TRAP
#pragma inline _vflp((short),,)	__F_TRAP

#pragma inline _vfssr((short),(short),(short),)	__F_TRAP
#pragma inline _vfssR((short),(short),(short),)	__F_TRAP
#pragma inline _vfpls((short),,,(short))	__F_TRAP
#pragma inline d0=_sfpls((short),,,(short))	__F_TRAP
#pragma inline d0=_sflsp((short),,(short),)	__F_TRAP
#pragma inline d0=_lfspp((short),(short),,)	__F_TRAP

#pragma inline d0=_sfppss((short),,,(short),(short))	__F_TRAP
#pragma inline _vfllpp((short),,,,)	__F_TRAP
#pragma inline _vfplll((short),,,,)	__F_TRAP
#pragma inline _vfplpl((short),,,,)	__F_TRAP

#pragma inline d0=_lfsssss((short),(short),(short),(short),(short),(short))	__F_TRAP

#pragma inline _vfppllll((short),,,,,)	__F_TRAP

#else /* !__LATTICE__ */

#ifdef __C68__
#define trap_14_wwwwww	_trap_14_wwwwww
#define trap_14_wllll	_trap_14_wllll
#define trap_14_wllllll	_trap_14_wllllll
#define trap_14_wll	_trap_14_wll
#define trap_14_wlwl	_trap_14_wlwl
__EXTERN long trap_14_wwwwww __PROTO((short, short, short, short, short,
				      short));
__EXTERN long trap_14_wllll __PROTO((short, long, long, long, long));
__EXTERN long trap_14_wllllll __PROTO((short, long, long, long, long,
				       long, long));
__EXTERN long trap_14_wll __PROTO((short, long, long));
__EXTERN long trap_14_wlwl __PROTO((short, long, short, long));

#else /* !__C68__ */

#ifdef __SOZOBON__
#define trap_14_wwwwww	xbios
#define trap_14_wllll	xbios
#define trap_14_wllllll	xbios
#define trap_14_wll	xbios
#define trap_14_wlwl	xbios

#else /* !__SOZOBON__ */

#ifndef trap_14_wwwwww
#if __GNUC__ > 1
#define trap_14_wwwwww(n,a,b,c,d,e)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
									\
	__asm__ volatile						\
	("\
		movw	%6,sp@-; \
		movw	%5,sp@-; \
		movw	%4,sp@-; \
		movw	%3,sp@-; \
		movw	%2,sp@-; \
		movw	%1,sp@-; \
		trap	#14; \
		lea	sp@(12),sp"					\
	: "=r"(retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e)		\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory");		\
	retvalue;							\
})
#else
#define trap_14_wwwwww(n,a,b,c,d,e)					\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	short _b = (short)(b);						\
	short _c = (short)(c);						\
	short _d = (short)(d);						\
	short _e = (short)(e);						\
									\
	__asm__ volatile						\
	("\
		movw	%4,sp@-; \
		movw	%3,sp@-; \
		movw	%2,sp@-; \
		movw	%1,sp@-; \
		movw	%0,sp@- "					\
	:: "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e));		\
									\
	__asm__ volatile						\
	("\
		movw	%1,sp@-; \
		trap	#14; \
		lea	sp@(12),sp"					\
	: "=r"(retvalue)						\
	: "g"(n)							\
	: "d0", "d1", "d2", "a0", "a1", "a2");				\
	retvalue;							\
})
#endif
#endif

#ifndef trap_14_wllll
#define trap_14_wllll(n,a,b,c,d)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
									\
	__asm__ volatile						\
	("\
		movl	%5,sp@-; \
		movl	%4,sp@-; \
		movl	%3,sp@-; \
		movl	%2,sp@-; \
		movw	%1,sp@-; \
		trap	#14; \
		lea	sp@(18),sp"					\
	: "=r"(retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d)			\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory");		\
	retvalue;							\
})
#endif

#ifndef trap_14_wllllll
#define trap_14_wllllll(n,a,b,c,d,e,f)					\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
	long _c = (long)(c);						\
	long _d = (long)(d);						\
	long _e = (long)(e);						\
	long _f = (long)(f);						\
									\
	__asm__ volatile						\
	("\
		movl	%7,sp@-; \
		movl	%6,sp@-; \
		movl	%5,sp@-; \
		movl	%4,sp@-; \
		movl	%3,sp@-; \
		movl	%2,sp@-; \
		movw	%1,sp@-; \
		trap	#14; \
		lea	sp@(26),sp"					\
	: "=r"(retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c), "r"(_d), "r"(_e), "r"(_f)	\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory");		\
	retvalue;							\
})
#endif

#ifndef trap_14_wll
#define trap_14_wll(n,a,b)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	long _b = (long)(b);						\
									\
	__asm__ volatile						\
	("\
		movl	%3,sp@-; \
		movl	%2,sp@-; \
		movw	%1,sp@-; \
		trap	#14; \
		lea	sp@(10),sp"					\
	: "=r"(retvalue)						\
	: "g"(n), "r"(_a), "r"(_b)					\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory");		\
	retvalue;							\
})
#endif

#ifndef trap_14_wlwl
#define trap_14_wlwl(n,a,b,c)						\
__extension__								\
({									\
	register long retvalue __asm__("d0");				\
	long _a = (long)(a);						\
	short _b = (short)(b);						\
	long _c = (long)(c);						\
									\
	__asm__ volatile						\
	("\
		movl	%4,sp@-; \
		movw	%3,sp@-; \
		movl	%2,sp@-; \
		movw	%1,sp@-; \
		trap	#14; \
		lea	sp@(12),sp"					\
	: "=r"(retvalue)						\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)				\
	: "d0", "d1", "d2", "a0", "a1", "a2", "memory");		\
	retvalue;							\
})
#endif

#endif /* __SOZOBON__ */
#endif /* __C68__ */
#endif /* __LATTICE__ */

/*
 * Video
 */

/* Video mode codes */

#define	VERTFLAG	0x100	/* double-line on VGA, interlace on ST/TV */
#define	STMODES		0x080	/* ST compatible */
#define	OVERSCAN	0x040	/* Multiply X&Y rez by 1.2, ignored on VGA */
#define	PAL		0x020	/* PAL if set, else NTSC */
#define	VGA		0x010	/* VGA if set, else TV mode */
#define	COL80		0x008	/* 80 column if set, else 40 column */
#define	NUMCOLS		7	/* Mask for number of bits per pixel */
#define	BPS16		4
#define	BPS8		3
#define	BPS4		2
#define	BPS2		1
#define	BPS1		0

/* Montype return values */
enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};

/* VsetSync flags - 0=internal, 1=external */

#define	VID_CLOCK	1
#define	VID_VSYNC	2
#define	VID_HSYNC	4

#undef Setscreen

#ifdef __LATTICE__

#define Setscreen(a, b, c, d) _sfppss(5, a, b, c, d)
#define Vsetmode(a) _sfs(88, a)
#define Montype() _sfv(89)
#define VsetSync(a) _vfs(90)
#define VgetSize(a) _lfs(91)
#define VsetRGB(a, b, c) _vfssR(93, a, b, c)
#define VgetRGB(a, b, c) _vfssr(94, a, b, c)
#define VsetMask(a, b) _vfss(150, a, b)

#else /* !__LATTICE__ */


#define Setscreen(lscrn,pscrn,rez,mode)					\
	(short)trap_14_wllww((short)5,(long)(lscrn),(long)(pscrn),	\
		(short)(rez),(short)(mode))
#define Vsetmode(mode)							\
	(short)trap_14_ww((short)88,(short)(mode))
#define Montype()							\
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
#define VsetMask(andmask,ormask)					\
	(short)trap_14_www((short)150,(short)(andmask),(short)(ormask))

#endif /* __LATTICE__ */

/*
 * Sound
 */

/* _SND cookie values */

#define SND_PSG		0x01	/* Yamaha PSG */
#define	SND_8BIT	0x02	/* 8 bit DMA stereo */
#define	SND_16BIT	0x04	/* 16 bit CODEC */
#define	SND_DSP		0x08	/* DSP */
#define	SND_MATRIX	0x10	/* Connection Matrix */

/* XXX Docs say Falcon shows 0x3f. What does bit 0x20 mean ??? */

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

#ifdef __LATTICE__

long _lfS(int, SndBufPtr *);
#pragma inline d0=_lfS((short),)	__F_TRAP

#define Locksnd() _lfv(128)
#define Unlocksnd() _lfv(129)
#define Soundcmd(a, b) _lfss(130, a, b)
#define Setbuffer(a, b, c) _lfspp(131, a, b, c)
#define Setmode(a) _lfs(132, a)
#define Settracks(a, b) _lfss(133, a, b)
#define Setmontracks(a) _lfs(134, a)
#define Setinterrupt(a, b) _lfss(135, a, b)
#define Buffoper(a) _lfs(136, a)
#define Dsptristate(a, b) _lfss(137, a, b)
#define Gpio(a, b) _lfss(138, a, b)
#define Devconnect(a, b, c, d, e) _lfsssss(139, a, b, c, d, e)
#define Sndstatus(a) _lfs(140, a)
#define Buffptr(a) _lfS(141, a)

#else /* !__LATTICE__ */

#define Locksnd()							\
	(long)trap_14_w((short)128)
#define Unlocksnd()							\
	(long)trap_14_w((short)129)
#define Setbuffer(region,beg,end)					\
	(long)trap_14_wwll((short)131,(short)(region),(long)(beg),(long)(end))
#define Soundcmd(mode,data)						\
	(long)trap_14_www((short)130,(short)(mode),(short)(data))
#define Setmode(stereo_mode)						\
	(long)trap_14_ww((short)132,(short)(stereo_mode))
#define Settracks(play,rec)						\
	(long)trap_14_www((short)133,(short)(play),(short)(rec))
#define Setmontracks(montrack)						\
	(long)trap_14_ww((short)134,(short)(montrack))
#define Setinterrupt(src_inter,cause)					\
	(long)trap_14_www((short)135,(short)(src_inter),		\
		(short)(cause))
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

#endif /* __LATTICE__ */

/*
 * DSP functions
 *
 * Don't even *think* of trying to use these without the manual!
 */

#ifdef __LATTICE__

#define Dsp_DoBlock(a, b, c, d) _vfplpl(96, a, b, c, d)
#define Dsp_BlkHandShake(a, b, c, d) _vfplpl(97, a, b, c, d)
#define Dsp_BlkUnpacked(a, b, c, d) _vfplpl(98, a, b, c, d)
#define Dsp_InStream(a, b, c, d) _vfplll(99, a, b, c, d)
#define Dsp_OutStream(a, b, c, d) _vfplll(100, a, b, c, d)
#define Dsp_IOStream(a, b, c, d, e, f) _vfppllll(101, a, b, c, d, e, f)
#define Dsp_RemoveInterrupt(a) _vfs(102, a)
#define Dsp_GetWordSize() _sfv(103)
#define Dsp_Lock() _sfv(104)
#define Dsp_Unlock() _vfv(105)
#define Dsp_Available(a, b) _vfll(106, a, b)
#define Dsp_Reserve(a, b) _vfll(107, a, b)
#define Dsp_LoadProg(a, b, c) _sflsp(108, a, b, c)
#define Dsp_ExecProg(a, b, c) _vfpls(109, a, b, c)
#define Dsp_ExecBoot(a, b, c) _vfpls(110, a, b, c)
#define Dsp_LodToBinary(a, b) _vflp(111, a, b)
#define Dsp_TriggerHC(a) _vfs(112, a)
#define Dsp_RequestUniqueAbility() _sfv(113)
#define Dsp_GetProgAbility() _sfv(114)
#define Dsp_FlushSubroutines() _sfv(115)
#define Dsp_LoadSubroutine(a, b, c) _sfpls(116, a, b, c)
#define Dsp_InqSubrAbility(a) _sfs(117, a)
#define Dsp_RunSubroutine(a) _sfs(118, a)
#define Dsp_Hf0(a) _sfs(119, a)
#define Dsp_Hf1(a) _sfs(120, a)
#define Dsp_Hf2() _sfv(121)
#define Dsp_Hf3() _sfv(122)
#define Dsp_BlkWords(a, b, c, d) _vfplpl(123, a, b, c, d)
#define Dsp_BlkBytes(a, b, c, d) _vfplpl(124, a, b, c, d)
#define Dsp_Hstat() _bfv(125)
#define Dsp_SetVectors(a, b) _vfll(126, a, b)
#define Dsp_MultBlocks(a, b, c, d) _vfllpp(127, a, b, c, d)

#else /* !__LATTICE__ */

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

#endif /* __LATTICE__ */

#endif /* _FALCON_H */
