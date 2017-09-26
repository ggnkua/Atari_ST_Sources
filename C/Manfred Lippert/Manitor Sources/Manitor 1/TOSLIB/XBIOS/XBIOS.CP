/*----------------------------------------------------------------------------------------
	xbios.cp, part of TOS Linker for CodeWarrior

	Xbios system calls for TOS
	CodeWarrior version
	
	04.11.1998 by Manfred Lippert

	last change: 23.7.2002

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#include <xbios.h>

#ifndef __MWERKS__
	#error This Source (xbios.cp) is for Metrowerks CodeWarrior only
#endif


#define XBIOS_0(nr)		pea (a2); \
						move.w %nr,-(sp); \
						trap %14; \
						addq.l %2,sp; \
						move.l (sp)+,a2

#define XBIOS_2(nr)		pea (a2); \
						move.w 8(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						addq.l %4,sp; \
						move.l (sp)+,a2

#define XBIOS_4(nr)		pea (a2); \
						move.l 8(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						addq.l %6,sp; \
						move.l (sp)+,a2

#define XBIOS_6(nr)		pea (a2); \
						move.l 10(sp),-(sp); \
						move.w 12(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						addq.l %8,sp; \
						move.l (sp)+,a2

#define XBIOS_8(nr)		pea (a2); \
						move.l 12(sp),-(sp); \
						move.l 12(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						lea 10(sp),sp; \
						move.l (sp)+,a2

#define XBIOS_10(nr)	pea (a2); \
						move.l 14(sp),-(sp); \
						move.l 14(sp),-(sp); \
						move.w 16(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						lea 12(sp),sp; \
						move.l (sp)+,a2

#define XBIOS_12(nr)	pea (a2); \
						move.l 16(sp),-(sp); \
						move.l 16(sp),-(sp); \
						move.l 16(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						lea 14(sp),sp; \
						move.l (sp)+,a2

#define XBIOS_16(nr)	pea (a2); \
						move.l 20(sp),-(sp); \
						move.l 20(sp),-(sp); \
						move.l 20(sp),-(sp); \
						move.l 20(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						lea 18(sp),sp; \
						move.l (sp)+,a2

#define XBIOS_18(nr)	pea (a2); \
						move.l 22(sp),-(sp); \
						move.l 22(sp),-(sp); \
						move.l 22(sp),-(sp); \
						move.l 22(sp),-(sp); \
						move.w 24(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						lea 20(sp),sp; \
						move.l (sp)+,a2

#define XBIOS_20(nr)	pea (a2); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.l 24(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						lea 22(sp),sp; \
						move.l (sp)+,a2

#define XBIOS_24(nr)	pea (a2); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.l 28(sp),-(sp); \
						move.w %nr,-(sp); \
						trap %14; \
						lea 26(sp),sp; \
						move.l (sp)+,a2
						
asm int32 CDECL			Bconmap(int16 dev) {
	XBIOS_2(44);
	rts
}
asm void CDECL			Bioskeys(void) {
	XBIOS_0(24);
	rts
}
asm int16 CDECL			Blitmode(int16 mode) {
	XBIOS_2(64);
	rts
}
asm int32 CDECL			buffoper(int16 mode) {
	XBIOS_2(136);
	rts
}
asm int32 CDECL			buffptr(int32 *ptr) {
	XBIOS_4(141);
	rts
}
asm void CDECL			cardmagic(int16 val) {
	XBIOS_2(500);
	rts
}
asm int16 CDECL			Cursconf(int16 function, int16 operand) {
	XBIOS_4(21);
	rts
}
asm int32 CDECL			devconnect(int16 src, int16 dst, int16 srcclk, int16 prescale, int16 protocol) {
	XBIOS_10(139);
	rts
}
asm int32 CDECL			DMAread(int32 sector, int16 count, void *buf, int16 dev) {
	XBIOS_10(42);
	rts
}
asm int32 CDECL			DMAwrite(int32 sector, int16 count, void *buf, int16 dev) {
	XBIOS_10(43);
	rts
}
asm void CDECL			Dosound(const char *ptr) {
	XBIOS_4(32);
	rts
}
asm void CDECL			Dsp_Available(int32 *x, int32 *y) {
	XBIOS_8(106);
	rts
}
asm void CDECL			Dsp_BlkBytes(void *data_in, int32 size_in, void *data_out, int32 size_out) {
	XBIOS_16(124);
	rts
}
asm void CDECL			Dsp_BlkHandShake(int8 *data_in, int32 size_in, int8 *data_out, int32 size_out) {
	XBIOS_16(97);
	rts
}
asm void CDECL			Dsp_BlkUnpacked(int32 *data_in, int32 size_in, int32 *data_out, int32 size_out) {
	XBIOS_16(98);
	rts
}
asm void CDECL			Dsp_BlkWords(void *data_in, int32 size_in, void *data_out, int32 size_out) {
	XBIOS_16(123);
	rts
}
asm void CDECL			Dsp_DoBlock(int8 *data_in, int32 size_in, int8 *data_out, int32 size_out) {
	XBIOS_16(96);
	rts
}
asm void CDECL			Dsp_ExecBoot(int8 *code, int32 size, int16 ability) {
	XBIOS_10(110);
	rts
}
asm void CDECL			Dsp_ExecProg(int8 *code, int32 size, int16 ability) {
	XBIOS_10(109);
	rts
}
asm void CDECL			Dsp_FlushSubroutines(void) {
	XBIOS_0(115);
	rts
}
asm int16 CDECL			Dsp_GetProgAbility(void) {
	XBIOS_0(114);
	rts
}
asm int16 CDECL			Dsp_GetWordSize(void) {
	XBIOS_0(103);
	rts
}
asm int16 CDECL			Dsp_Hf0(int16 flag) {
	XBIOS_2(119);
	rts
}
asm int16 CDECL			Dsp_Hf1(int16 flag) {
	XBIOS_2(120);
	rts
}
asm int16 CDECL			Dsp_Hf2(void) {
	XBIOS_0(121);
	rts
}
asm int16 CDECL			Dsp_Hf3(void) {
	XBIOS_0(122);
	rts
}
asm int8 CDECL			Dsp_HStat(void) {
	XBIOS_0(125);
	rts
}
asm int16 CDECL			Dsp_InqSubrAbility(int16 ability) {
	XBIOS_2(117);
	rts
}
asm void CDECL			Dsp_InStream(int8 *data_in, int32 block_size, int32 num_blocks, int32 *blocks_done) {
	XBIOS_16(99);
	rts
}
asm void CDECL			Dsp_IOStream(int8 *data_in, int8 *data_out, int32 block_insize, int32 block_outsize, int32 num_blocks, int32 *blocks_done) {
	XBIOS_24(101);
	rts
}
asm int16 CDECL			Dsp_LoadProg(char *file, int16 ability, int8 *buf) {
	XBIOS_10(108);
	rts
}
asm int16 CDECL			Dsp_LoadSubroutine(int8 *code, int32 codesize, int16 ability) {
	XBIOS_10(116);
	rts
}
asm int16 CDECL			Dsp_Lock(void) {
	XBIOS_0(104);
	rts
}
asm int32 CDECL			Dsp_LodToBinary(char *file, int8 *code) {
	XBIOS_8(111);
	rts
}
asm void CDECL			Dsp_MultBlocks(int32 numsend, int32 numreceive, DSPBLOCK *sendblocks, DSPBLOCK *receiveblocks) {
	XBIOS_16(127);
	rts
}
asm void CDECL			Dsp_OutStream(int8 *data_out, int32 block_size, int32 num_blocks, int32 *blocks_done) {
	XBIOS_16(100);
	rts
}
asm void CDECL			Dsp_RemoveInterrupts(int16 mask) {
	XBIOS_2(102);
	rts
}
asm int16 CDECL			Dsp_RequestUniqueAbility(void) {
	XBIOS_0(113);
	rts
}
asm int16 CDECL			Dsp_Reserve(int32 x, int32 y) {
	XBIOS_8(107);
	rts
}
asm int16 CDECL			Dsp_RunSubroutine(int16 handle) {
	XBIOS_2(118);
	rts
}
asm void CDECL			Dsp_SetVectors(void (*reveiver)(), int32 (*transmitter)()) {
	XBIOS_8(126);
	rts
}
asm void CDECL			Dsp_TriggerHC(int16 vector) {
	XBIOS_2(112);
	rts
}
asm void CDECL			Dsp_Unlock(void) {
	XBIOS_0(105);
	rts
}
asm int32 CDECL			dsptristate(int16 dspxmit, int16 dsprec) {
	XBIOS_4(137);
	rts
}
asm void CDECL			EgetPalette(int16 idx, int16 count, int16 *palette) {
	XBIOS_8(85);
	rts
}
asm int16 CDECL			EgetShift(void) {
	XBIOS_0(81);
	rts
}
asm int16 CDECL			EsetBank(int16 bank) {
	XBIOS_2(82);
	rts
}
asm int16 CDECL			EsetColor(int16 idx, int16 color) {
	XBIOS_4(83);
	rts
}
asm int16 CDECL			EsetGray(int16 mode) {
	XBIOS_2(86);
	rts
}
asm void CDECL			EsetPalette(int16 idx, int16 count, int16 *palette) {
	XBIOS_8(84);
	rts
}
asm int16 CDECL			EsetShift(int16 mode) {
	XBIOS_2(80);
	rts
}
asm int16 CDECL			EsetSmear(int16 mode) {
	XBIOS_2(87);
	rts
}
asm int16 CDECL			Flopfmt(void *buf, int32 filler, int16 dev, int16 spt, int16 track, int16 side, int16 interlv, int32 magic, int16 virgin) {
	XBIOS_24(10);
	rts
}
asm int16 CDECL			Floprate(int16 drive, int16 seekrate) {
	XBIOS_4(41);
	rts
}
asm int16 CDECL			Floprd(void *buf, int32 filler, int16 dev, int16 sect, int16 track, int16 side, int16 count) {
	XBIOS_18(8);
	rts
}
asm int16 CDECL			Flopver(void *buf, int32 filler, int16 dev, int16 sect, int16 track, int16 side, int16 count) {
	XBIOS_18(19);
	rts
}
asm int16 CDECL			Flopwr(void *buf, int32 filler, int16 dev, int16 sect, int16 track, int16 side, int16 count) {
	XBIOS_18(9);
	rts
}
asm int16 CDECL			Getrez(void) {
	XBIOS_0(4);
	rts
}
asm int32 CDECL			Gettime(void) {
	XBIOS_0(23);
	rts
}
asm uint8 CDECL			Giaccess(uint16 data, int16 regno) {
	XBIOS_4(28);
	rts
}
asm int32 CDECL			gpio(int16 mode, int16 data) {
	XBIOS_4(138);
	rts
}
asm void CDECL			Ikbdws(int16 count, const char *ptr) {
	XBIOS_6(25);
	rts
}
asm void CDECL			Initmous(int16 type, MOUSPARAM *param, void *(*vec)()) {
	XBIOS_10(0);
	rts
}
asm IOREC* CDECL		Iorec(int16 dev) {
	XBIOS_2(14);
	movea.l d0,a0
	rts
}
asm void CDECL			Jdisint(int16 intno) {
	XBIOS_2(26);
	rts
}
asm void CDECL			Jenabint(int16 intno) {
	XBIOS_2(27);
	rts
}
asm KBDVECS* CDECL		Kbdvbase(void) {
	XBIOS_0(34);
	movea.l d0,a0
	rts
}
asm int16 CDECL			Kbrate(int16 initial, int16 repeat) {
	XBIOS_4(35);
	rts
}
asm KEYTAB* CDECL		Keytbl(char *unshift, char *shift, char *capslock) {
	XBIOS_12(16);
	movea.l d0,a0
	rts
}
asm void* CDECL			Logbase(void) {
	XBIOS_0(3);
	movea.l d0,a0
	rts
}
asm int32 CDECL			locksnd(void) {
	XBIOS_0(128);
	rts
}
asm int16 CDECL			mon_type(void) {
	XBIOS_0(89);
	rts
}
asm int32 CDECL			Metaclose(int16 drive) {
	XBIOS_2(50);
	rts
}
asm int32 CDECL			Metadiscinfo(int16 drive, CD_DISC_INFO *buf) {
	XBIOS_6(63);
	rts
}
asm int32 CDECL			Metagettoc(int16 drive, int16 flag, CD_TOC_ENTRY *buf) {
	XBIOS_8(62);
	rts
}
asm void CDECL			Metainit(META_INFO_1 *buf) {
	XBIOS_4(48);
	rts
}
asm int32 CDECL			Metaioctl(int16 drive, int32 magic, int16 opcode, void *buf) {
	XBIOS_12(55);
	rts
}
asm int32 CDECL			Metaopen(int16 drive, META_DRVINFO *buf) {
	XBIOS_6(49);
	rts
}
asm int32 CDECL			Metaread(int16 drive, void *buf, int32 blockno, int16 count) {
	XBIOS_12(51);
	rts
}
asm int32 CDECL			Metasetsongtime(int16 drive, int16 repeat, int32 starttime, int32 endtime) {
	XBIOS_12(61);
	rts
}
asm int32 CDECL			Metastartaudio(int16 drive, int16 flag, uint8 *buf) {
	XBIOS_8(59);
	rts
}
asm int32 CDECL			Metastatus(int16 drive, void *buf) {
	XBIOS_6(54);
	rts
}
asm int32 CDECL			Metastopaudio(int16 drive) {
	XBIOS_2(60);
	rts
}
asm int32 CDECL			Metawrite(int16 drive, void *buf, int32 blockno, int16 count) {
	XBIOS_12(52);
	rts
}
asm void CDECL			Mfpint(int16 intno, void (*vector)()) {
	XBIOS_6(13);
	rts
}
asm void CDECL			Midiws(int16 count, void *buf) {
	XBIOS_6(12);
	rts
}
asm int16 CDECL			NVMaccess(int16 op, int16 start, int16 count, int8 *buf) {
	XBIOS_10(46);
	rts
}
asm void CDECL			Offgibit(int16 bitno) {
	XBIOS_2(29);
	rts
}
asm void CDECL			Ongibit(int16 bitno) {
	XBIOS_2(30);
	rts
}
asm int16 CDECL			Oscanis(void) {
	XBIOS_0(4200);
	rts
}
asm OVERPATCH* CDECL	Oscanpath(void) {
	XBIOS_0(4205);
	movea.l d0,a0
	rts
}
asm int16 CDECL			Oscanphy(int16 mode) {
	XBIOS_2(4202);
	rts
}
asm int16 CDECL			Oscanscr(int16 mode) {
	XBIOS_2(4203);
	rts
}
asm int16 CDECL			Oscanswitch(int16 mode) {
	XBIOS_2(4206);
	rts
}
asm SCREEN* CDECL		Oscantab(int16 res) {
	XBIOS_2(4201);
	movea.l d0,a0
	rts
}
asm int16 CDECL			Oscanvb(int16 mode) {
	XBIOS_2(4204);
	rts
}
asm void* CDECL			Physbase(void) {
	XBIOS_0(2);
	movea.l d0,a0
	rts
}
asm void CDECL			Protobt(void *buf, int32 sernr, int16 disktype, int16 execflag) {
	XBIOS_12(18);
	rts
}
asm void CDECL			Prtblk(PBDEF *def) {
	XBIOS_4(36);
	rts
}
asm void CDECL			Puntaes(void) {
	XBIOS_0(39);
	rts
}
asm int32 CDECL			Random24(void) {
	XBIOS_0(17);
	rts
}
asm uint32 CDECL		Rsconf(int16 speed, int16 flowctl, int16 ucr, int16 rsr, int16 tsr, int16 scr) {
	XBIOS_12(15);
	rts
}
asm void CDECL			Scrdmp(void) {
	XBIOS_0(20);
	rts
}
asm int32 CDECL			setbuffer(int16 reg, void *begaddr, void *endaddr) {
	XBIOS_10(131);
	rts
}
asm int16 CDECL			Setcolor(int16 idx, int16 color) {
	XBIOS_4(7);
	rts
}
asm int32 CDECL			setinterrupt(int16 src_inter, int16 cause) {
	XBIOS_4(135);
	rts
}
asm int32 CDECL			setmode(int16 mode) {
	XBIOS_2(132);
	rts
}
asm int32 CDECL			setmontracks(int16 montrack) {
	XBIOS_2(134);
	rts
}
asm void CDECL			Setpalette(int16 *palette) {
	XBIOS_4(6);
	rts
}
asm int16 CDECL			Setprt(int16 config) {
	XBIOS_2(33);
	rts
}
asm void CDECL			Setscreen(void *logLoc, void *physLoc, int16 res) {
	XBIOS_10(5);
	rts
}
asm void CDECL			Settime(int32 datetime) {
	XBIOS_4(22);
	rts
}
asm int32 CDECL			settracks(int16 playtracks, int16 rectracks) {
	XBIOS_4(133);
	rts
}
asm int32 CDECL			sndstatus(int16 reset) {
	XBIOS_2(140);
	rts
}
asm int32 CDECL			soundcmd(int16 mode, int16 data) {
	XBIOS_4(130);
	rts
}
asm int32 CDECL			Ssbrk(int16 amount) {
	XBIOS_2(1);
	rts
}
asm int32 CDECL			Supexec(int32 (*func)()) {
	XBIOS_4(38);
	rts
}
asm int32 CDECL			unlocksnd(void) {
	XBIOS_0(129);
	rts
}
asm void CDECL			VgetRGB(int16 index, int16 count, int32 *array) {
	XBIOS_8(94);
	rts
}
asm int32 CDECL			VgetSize(int16 mode) {
	XBIOS_2(91);
	rts
}
asm void CDECL			VsetMask(int16 ormask, int16 andmask, int16 overlay) {
	XBIOS_6(150);
	rts
}
asm int16 CDECL			Vsetmode(int16 mode) {
	XBIOS_2(88);
	rts
}
asm void CDECL			VsetRGB(int16 index, int16 count, int32 *array) {
	XBIOS_8(93);
	rts
}
asm void CDECL			VsetSync(int16 flag) {
	XBIOS_2(90);
	rts
}
asm void CDECL			Vsync(void) {
	XBIOS_0(37);
	rts
}
asm void CDECL			Xbtimer(int16 timer, int16 control, int16 data, void (*func)()) {
	XBIOS_10(31);
	rts
}

asm int32 CDECL Trapper(int16 layer, int16 install, int16 opcode, void *function)
{
	move.l #TRAPPER_OPCODE,d0
	XBIOS_10(TRAPPER_OPCODE)
	rts
}
