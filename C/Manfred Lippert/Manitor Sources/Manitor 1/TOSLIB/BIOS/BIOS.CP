/*----------------------------------------------------------------------------------------
	bios.cp, part of TOS Linker for CodeWarrior

	Bios system calls for TOS
	CodeWarrior version
	
	21.10.1998 by Manfred Lippert

	last change: 25.11.1998

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#include <bios.h>

#ifndef __MWERKS__
	#error This Source (bios.cp) is for Metrowerks CodeWarrior only
#endif


#define BIOS_0(nr)	pea (a2); \
					move.w %nr,-(sp); \
					trap %13; \
					addq.l %2,sp; \
					move.l (sp)+,a2

#define BIOS_2(nr)	pea (a2); \
					move.w 8(sp),-(sp); \
					move.w %nr,-(sp); \
					trap %13; \
					addq.l %4,sp; \
					move.l (sp)+,a2

#define BIOS_4(nr)	pea (a2); \
					move.l 8(sp),-(sp); \
					move.w %nr,-(sp); \
					trap %13; \
					addq.l %6,sp; \
					move.l (sp)+,a2

#define BIOS_6(nr)	pea (a2); \
					move.l 10(sp),-(sp); \
					move.w 12(sp),-(sp); \
					move.w %nr,-(sp); \
					trap %13; \
					addq.l %8,sp; \
					move.l (sp)+,a2

#define BIOS_10(nr)	pea (a2); \
					move.l 14(sp),-(sp); \
					move.l 14(sp),-(sp); \
					move.w 16(sp),-(sp); \
					move.w %nr,-(sp); \
					trap %13; \
					lea 12(sp),sp; \
					move.l (sp)+,a2

#define BIOS_16(nr)	pea (a2); \
					move.l 20(sp),-(sp); \
					move.l 20(sp),-(sp); \
					move.l 20(sp),-(sp); \
					move.l 20(sp),-(sp); \
					move.w %nr,-(sp); \
					trap %13; \
					lea 18(sp),sp; \
					move.l (sp)+,a2
						
asm int32 CDECL	Bconin(int16 dev)
{
	BIOS_2(2)
	rts
}
asm void CDECL	Bconout(int16 dev, int16 c)
{
	BIOS_4(3)
	rts
}
asm int16 CDECL	Bconstat(int16 dev)
{
	BIOS_2(1)
	rts
}
asm int32 CDECL	Bcostat(int16 dev)
{
	BIOS_2(8)
	rts
}
asm int32 CDECL	Drvmap(void)
{
	BIOS_0(10)
	rts
}
asm BPB* CDECL	Getbpb(int16 dev)
{
	BIOS_2(7)
	movea.l d0,a0
	rts
}
asm void CDECL	Getmpb(MPB *ptr)
{
	BIOS_4(0)
	rts
}
asm int32 CDECL	Kbshift(int16 mode)
{
	BIOS_2(11)
	rts
}
asm int32 CDECL	Mediach(int16 dev)
{
	BIOS_2(9)
	rts
}
asm int32 CDECL	Rwabs(int16 rwflag, void *buf, int16 count, int16 recno, int16 dev, int32 lrecno)
{
	BIOS_16(4)
	rts
}

asm void CDECL	(*Setexc(int16 number, void (*exchdlr)() )) ()
{
	BIOS_6(5)
	movea.l d0,a0
	rts
}
asm int32 CDECL	Tickcal(void)
{
	BIOS_0(6)
	rts
}
