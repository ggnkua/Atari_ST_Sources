/*----------------------------------------------------------------------------------------
	xbios.h, part of TOS Linker for CodeWarrior

	Xbios system calls for TOS
	
	04.11.1998 by Manfred Lippert

	last change: 12.03.2000

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __TOS_xbios_h_
#define __TOS_xbios_h_

#ifndef __PORTAB__
#include <portab.h>
#endif

#if !TARGET_TOS
	#error Xbios-Lib used in Non-TOS Project
#endif
#if !MC68K
	#error Xbios-Lib used in Non-68K Project
#endif

typedef struct {			/* used by Iorec */
	void	*ibuf;
	int16	ibufsiz;
	int16	ibufhd;
	int16	ibuftl;
	int16	ibuflow;
	int16	ibufhi;
} IOREC;

typedef struct {			/* used by Kbdvbase */
	void (*midivec)();
	void (*vkbderr)();
	void (*vmiderr)();
	void (*statvec)();
	void (*mousevec)();
	void (*clockvec)();
	void (*joyvec)();
	void (*midisys)();
	void (*ikbdsys)();
	uint8 drvstat;
} KBDVECS;

typedef struct {			/* used by Keytbl */
	char *unshift;
	char *shift;
	char *capslock;
} KEYTAB;

typedef struct {			/* used by Initmous */
	uint8 topmode;
	uint8 buttons;
	uint8 xparam;
	uint8 yparam;
} MOUSPARAM;
typedef struct {
	int16 xmax;
	int16 ymax;
	int16 xinitial;
	int16 yinitial;
} MOUSEXTRA;

typedef struct {
	int16 blocktype;	/* type of data:*/
							/*	0 : LongInt	*/
							/*	1 : Integer	*/
							/*	2 : Byte	*/
	int32 blocksize;
	void *blockaddr;
} DSPBLOCK;

typedef struct {			/* used by Metadiscinfo */
	uint8 disctype;
	uint8 firsttrack, lasttrack, curtrack;
	uint8 relposz, relposm, relposs, relposf;
	uint8 absposz, absposm, absposs, absposf;
	uint8 endposz, endposm, endposs, endposf;
	uint8 index, res[3];
	uint32 reserved[123];
} CD_DISC_INFO;

typedef struct {			/* used by Metagettoc */ 
	uint8 trackno;
	uint8 minute;
	uint8 second;
	uint8 frame;
} CD_TOC_ENTRY;

typedef struct {
	uint16 mi_version;			/* version (0x230 = '02.30') */
	int32 mi_magic;				/* magic value '_MET' */
	const int8 *mi_log2phys;	/* GEMDOS->Meta-DOS mapping */
} META_INFO_2;

typedef struct {			/* used by Metainit */ 
	uint32 drivemap;		/* Bits for Meta-DOS drives (bit 0 = A, 1 = B etc...) */
	char *version;			/* name and version of Meta-DOS */
	int32 reserved;
	META_INFO_2 *info;
} META_INFO_1;

typedef struct {			/* used by Metaopen */ 
	char *mdr_name;
	int32 reserved[3];
} META_DRVINFO;

typedef struct {
	int16 low_w, mid_w, high_w;			/* width in pixels */
	int16 low_h, mid_h, high_h;			/* height in pixels */
    int32 low_off, mid_off, high_off;	/* offset screen memory<>logbase */
	int32 mono_add, color_add;				/* additional memory usage */
	int8 clear_scan;							/* scan code of clear function */
	int8 clear_shift;							/* shift code of clear function */
	int8 setup_shift;							/* shift code of setup (mask) */
	int8 invert_shift;						/* shift code to invert mode */
	int8 abort_shift;							/* shift code to abort */
} OVERPATCH;

typedef struct {				/* used by Oscantab */
	int16 width;				/* width in pixels */
	int16 height;				/* height in pixels */
	int16 bytes_per_line;	/* bytes pro screen line */
	int32 length_of_screen;	/* length of screen buffer */
	int32 physbase_offset;	/* offset screen memory<>Physbase */
	int32 logbase_offset;	/* offset screen memory<>Logbase */
} SCREEN;

typedef struct {			/* used by Prtblk */
	void *pb_scrptr;		/* pointer to screen */
	int16 pb_offset;		/* additional offset */
	int16 pb_width;		/* screen width in points */
	int16 pb_height;		/* screen height in points */
	int16 pb_left;			/* left margin in points */
	int16 pb_right;		/* right margin in points */
	int16 pb_screz;		/* resolution */
	int16 pb_prrez;		/* printer type (Atari/Epson) */
	void *pb_colptr;		/* pointer to color table */
	int16 pb_prtype;		/*	0: Atari Matrix monochrom
								1: Atari Matrix farbig
								2: Atari Typenrad monochrom
								3: Epson Matrix monochrom */
	int16 pb_prport;		/* pinter port Centronics/RS-232 */
	void *pb_mask;			/* pointer to halftone mask */
} PBDEF;

extern C_CALL int32 CDECL		Bconmap(int16 dev);
extern C_CALL void CDECL		Bioskeys(void);
extern C_CALL int16 CDECL		Blitmode(int16 mode);
extern C_CALL int32 CDECL		buffoper(int16 mode);
extern C_CALL int32 CDECL		buffptr(int32 *ptr);
extern C_CALL void CDECL		cardmagic(int16 val);
extern C_CALL int16 CDECL		Cursconf(int16 function, int16 operand);
extern C_CALL int32 CDECL		devconnect(int16 src, int16 dst, int16 srcclk, int16 prescale, int16 protocol);
extern C_CALL int32 CDECL		DMAread(int32 sector, int16 count, void *buf, int16 dev);
extern C_CALL int32 CDECL		DMAwrite(int32 sector, int16 count, void *buf, int16 dev);
extern C_CALL void CDECL		Dosound(const char *ptr);
extern C_CALL void CDECL		Dsp_Available(int32 *x, int32 *y);
extern C_CALL void CDECL		Dsp_BlkBytes(void *data_in, int32 size_in, void *data_out, int32 size_out);
extern C_CALL void CDECL		Dsp_BlkHandShake(int8 *data_in, int32 size_in, int8 *data_out, int32 size_out);
extern C_CALL void CDECL		Dsp_BlkUnpacked(int32 *data_in, int32 size_in, int32 *data_out, int32 size_out);
extern C_CALL void CDECL		Dsp_BlkWords(void *data_in, int32 size_in, void *data_out, int32 size_out);
extern C_CALL void CDECL		Dsp_DoBlock(int8 *data_in, int32 size_in, int8 *data_out, int32 size_out);
extern C_CALL void CDECL		Dsp_ExecBoot(int8 *code, int32 size, int16 ability);
extern C_CALL void CDECL		Dsp_ExecProg(int8 *code, int32 size, int16 ability);
extern C_CALL void CDECL		Dsp_FlushSubroutines(void);
extern C_CALL int16 CDECL		Dsp_GetProgAbility(void);
extern C_CALL int16 CDECL		Dsp_GetWordSize(void);
extern C_CALL int16 CDECL		Dsp_Hf0(int16 flag);
extern C_CALL int16 CDECL		Dsp_Hf1(int16 flag);
extern C_CALL int16 CDECL		Dsp_Hf2(void);
extern C_CALL int16 CDECL		Dsp_Hf3(void);
extern C_CALL int8 CDECL		Dsp_HStat(void);
extern C_CALL int16 CDECL		Dsp_InqSubrAbility(int16 ability);
extern C_CALL void CDECL		Dsp_InStream(int8 *data_in, int32 block_size, int32 num_blocks, int32 *blocks_done);
extern C_CALL void CDECL		Dsp_IOStream(int8 *data_in, int8 *data_out, int32 block_insize, int32 block_outsize, int32 num_blocks, int32 *blocks_done);
extern C_CALL int16 CDECL		Dsp_LoadProg(char *file, int16 ability, int8 *buf);
extern C_CALL int16 CDECL		Dsp_LoadSubroutine(int8 *code, int32 codesize, int16 ability);
extern C_CALL int16 CDECL		Dsp_Lock(void);
extern C_CALL int32 CDECL		Dsp_LodToBinary(char *file, int8 *code);
extern C_CALL void CDECL		Dsp_MultBlocks(int32 numsend, int32 numreceive, DSPBLOCK *sendblocks, DSPBLOCK *receiveblocks);
extern C_CALL void CDECL		Dsp_OutStream(int8 *data_out, int32 block_size, int32 num_blocks, int32 *blocks_done);
extern C_CALL void CDECL		Dsp_RemoveInterrupts(int16 mask);
extern C_CALL int16 CDECL		Dsp_RequestUniqueAbility(void);
extern C_CALL int16 CDECL		Dsp_Reserve(int32 x, int32 y);
extern C_CALL int16 CDECL		Dsp_RunSubroutine(int16 handle);
extern C_CALL void CDECL		Dsp_SetVectors(void (*reveiver)(), int32 (*transmitter)());
extern C_CALL void CDECL		Dsp_TriggerHC(int16 vector);
extern C_CALL void CDECL		Dsp_Unlock(void);
extern C_CALL int32 CDECL		dsptristate(int16 dspxmit, int16 dsprec);
extern C_CALL void CDECL		EgetPalette(int16 idx, int16 count, int16 *palette);
extern C_CALL int16 CDECL		EgetShift(void);
extern C_CALL int16 CDECL		EsetBank(int16 bank);
extern C_CALL int16 CDECL		EsetColor(int16 idx, int16 color);
extern C_CALL int16 CDECL		EsetGray(int16 mode);
extern C_CALL void CDECL		EsetPalette(int16 idx, int16 count, int16 *palette);
extern C_CALL int16 CDECL		EsetShift(int16 mode);
extern C_CALL int16 CDECL		EsetSmear(int16 mode);
extern C_CALL int16 CDECL		Flopfmt(void *buf, int32 filler, int16 dev, int16 spt, int16 track, int16 side, int16 interlv, int32 magic, int16 virgin);
extern C_CALL int16 CDECL		Floprate(int16 drive, int16 seekrate);
extern C_CALL int16 CDECL		Floprd(void *buf, int32 filler, int16 dev, int16 sect, int16 track, int16 side, int16 count);
extern C_CALL int16 CDECL		Flopver(void *buf, int32 filler, int16 dev, int16 sect, int16 track, int16 side, int16 count);
extern C_CALL int16 CDECL		Flopwr(void *buf, int32 filler, int16 dev, int16 sect, int16 track, int16 side, int16 count);
extern C_CALL int16 CDECL		Getrez(void);
extern C_CALL int32 CDECL		Gettime(void);
extern C_CALL uint8 CDECL		Giaccess(uint16 data, int16 regno);
extern C_CALL int32 CDECL		gpio(int16 mode, int16 data);
extern C_CALL void CDECL		Ikbdws(int16 count, const char *ptr);
extern C_CALL void CDECL		Initmous(int16 type, MOUSPARAM *param, void *(*vec)());
extern C_CALL IOREC* CDECL		Iorec(int16 dev);
extern C_CALL void CDECL		Jdisint(int16 intno);
extern C_CALL void CDECL		Jenabint(int16 intno);
extern C_CALL KBDVECS* CDECL	Kbdvbase(void);
extern C_CALL int16 CDECL		Kbrate(int16 initial, int16 repeat);
extern C_CALL KEYTAB* CDECL	Keytbl(char *unshift, char *shift, char *capslock);
extern C_CALL void* CDECL		Logbase(void);
extern C_CALL int32 CDECL		locksnd(void);
extern C_CALL int16 CDECL		mon_type(void);
extern C_CALL int32 CDECL		Metaclose(int16 drive);
extern C_CALL int32 CDECL		Metadiscinfo(int16 drive, CD_DISC_INFO *buf);
extern C_CALL int32 CDECL		Metagettoc(int16 drive, int16 flag, CD_TOC_ENTRY *buf);
extern C_CALL void CDECL		Metainit(META_INFO_1 *buf);
extern C_CALL int32 CDECL		Metaioctl(int16 drive, int32 magic, int16 opcode, void *buf);
extern C_CALL int32 CDECL		Metaopen(int16 drive, META_DRVINFO *buf);
extern C_CALL int32 CDECL		Metaread(int16 drive, void *buf, int32 blockno, int16 count);
extern C_CALL int32 CDECL		Metasetsongtime(int16 drive, int16 repeat, int32 starttime, int32 endtime);
extern C_CALL int32 CDECL		Metastartaudio(int16 drive, int16 flag, uint8 *buf);
extern C_CALL int32 CDECL		Metastatus(int16 drive, void *buf);
extern C_CALL int32 CDECL		Metastopaudio(int16 drive);
extern C_CALL int32 CDECL		Metawrite(int16 drive, void *buf, int32 blockno, int16 count);
extern C_CALL void CDECL		Mfpint(int16 intno, void (*vector)());
extern C_CALL void CDECL		Midiws(int16 count, void *buf);
extern C_CALL int16 CDECL		NVMaccess(int16 op, int16 start, int16 count, int8 *buf);
extern C_CALL void CDECL		Offgibit(int16 bitno);
extern C_CALL void CDECL		Ongibit(int16 bitno);
extern C_CALL int16 CDECL		Oscanis(void);
extern C_CALL OVERPATCH* CDECL	Oscanpath(void);
extern C_CALL int16 CDECL		Oscanphy(int16 mode);
extern C_CALL int16 CDECL		Oscanscr(int16 mode);
extern C_CALL int16 CDECL		Oscanswitch(int16 mode);
extern C_CALL SCREEN* CDECL	Oscantab(int16 res);
extern C_CALL int16 CDECL		Oscanvb(int16 mode);
extern C_CALL void* CDECL		Physbase(void);
extern C_CALL void CDECL		Protobt(void *buf, int32 sernr, int16 disktype, int16 execflag);
extern C_CALL void CDECL		Prtblk(PBDEF *def);
extern C_CALL void CDECL		Puntaes(void);
extern C_CALL int32 CDECL		Random(void);
extern C_CALL uint32 CDECL		Rsconf(int16 speed, int16 flowctl, int16 ucr, int16 rsr, int16 tsr, int16 scr);
extern C_CALL void CDECL		Scrdmp(void);
extern C_CALL int32 CDECL		setbuffer(int16 reg, void *begaddr, void *endaddr);
extern C_CALL int16 CDECL		Setcolor(int16 idx, int16 color);
extern C_CALL int32 CDECL		setinterrupt(int16 src_inter, int16 cause);
extern C_CALL int32 CDECL		setmode(int16 mode);
extern C_CALL int32 CDECL		setmontracks(int16 montrack);
extern C_CALL void CDECL		Setpalette(int16 *palette);
extern C_CALL int16 CDECL		Setprt(int16 config);
extern C_CALL void CDECL		Setscreen(void *logLoc, void *physLoc, int16 res);
extern C_CALL void CDECL		Settime(int32 datetime);
extern C_CALL int32 CDECL		settracks(int16 playtracks, int16 rectracks);
extern C_CALL int32 CDECL		sndstatus(int16 reset);
extern C_CALL int32 CDECL		soundcmd(int16 mode, int16 data);
extern C_CALL int32 CDECL		Ssbrk(int16 amount);
extern C_CALL int32 CDECL		Supexec(int32 (*func)());
extern C_CALL int32 CDECL		unlocksnd(void);
extern C_CALL void CDECL		VgetRGB(int16 index, int16 count, int32 *array);
extern C_CALL int32 CDECL		VgetSize(int16 mode);
extern C_CALL void CDECL		VsetMask(int16 ormask, int16 andmask, int16 overlay);
extern C_CALL int16 CDECL		Vsetmode(int16 mode);
extern C_CALL void CDECL		VsetRGB(int16 index, int16 count, int32 *array);
extern C_CALL void CDECL		VsetSync(int16 flag);
extern C_CALL void CDECL		Vsync(void);
extern C_CALL void CDECL		Xbtimer(int16 timer, int16 control, int16 data, void (*func)());

/* special Xbios call "Trapper". More informations are available from mani@mani.de */

#define TRAPPER_OPCODE 555

#define TRAPPER_CHECK	-1
#define TRAPPER_BIOS		0
#define TRAPPER_XBIOS	1
#define TRAPPER_GEMDOS	2
#define TRAPPER_VDI		3
#define TRAPPER_AES		4

#define TRAPPER_INSTALL_CALL		0
#define TRAPPER_REMOVE_CALL		1
#define TRAPPER_INSTALL_RETURN	2
#define TRAPPER_REMOVE_RETURN		3

extern C_CALL int32 CDECL Trapper(int16 layer, int16 install, int16 opcode, void *function);

#endif
