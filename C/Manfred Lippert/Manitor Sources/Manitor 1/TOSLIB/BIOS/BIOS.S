;----------------------------------------------------------------------------------------
;	bios.s, part of TOS Linker for CodeWarrier
;
;	Gemdos system calls for TOS
;	Pure Asm version
;
;	16.11.1998 by Daniel Hšpfl, Manfred Lippert
;   based on CodeWarrior-Version by Manfred Lippert
;
;	last change: 26.11.1998
;
;	Don't edit this file.
;
;	If you have to make any changes on this file, please contact:
;	mani@mani.de
;----------------------------------------------------------------------------------------

.export Bconin, Bconout, Bconstat, Bcostat
.export Drvmap
.export Getbpb, Getmpb
.export Kbshift
.export Mediach
.export Rwabs
.export Setexc
.export Tickcal

MACRO BIOS_0 nr
		pea (a2)
		move.w #nr,-(sp)
		trap #13
		addq.l #2,sp
		move.l (sp)+,a2
ENDM

MACRO BIOS_2 nr
		pea (a2)
		move.w 8(sp),-(sp)
		move.w #nr,-(sp)
		trap #13
		addq.l #4,sp
		move.l (sp)+,a2
ENDM

MACRO BIOS_4 nr
		pea (a2)
		move.l 8(sp),-(sp)
		move.w #nr,-(sp)
		trap #13
		addq.l #6,sp
		move.l (sp)+,a2
ENDM

MACRO BIOS_6 nr
		pea (a2)
		move.l 10(sp),-(sp)
		move.w 12(sp),-(sp)
		move.w #nr,-(sp)
		trap #13
		addq.l #8,sp
		move.l (sp)+,a2
ENDM

MACRO BIOS_16 nr
		pea (a2)
		move.l 20(sp),-(sp)
		move.l 20(sp),-(sp)
		move.l 20(sp),-(sp)
		move.l 20(sp),-(sp)
		move.w #nr,-(sp)
		trap #13
		lea 18(sp),sp
		move.l (sp)+,a2
ENDM

.MODULE Bconin
	BIOS_2(2)
	rts

.MODULE Bconout
	BIOS_4(3)
	rts

.MODULE Bconstat
	BIOS_2(1)
	rts

.MODULE Bcostat
	BIOS_2(8)
	rts

.MODULE Drvmap
	BIOS_0(10)
	rts

.MODULE Getbpb
	BIOS_2(7)
	movea.l d0,a0
	rts

.MODULE Getmpb
	BIOS_4(0)
	rts

.MODULE Kbshift
	BIOS_2(11)
	rts

.MODULE Mediach
	BIOS_2(9)
	rts

.MODULE Rwabs
	BIOS_16(4)
	rts

.MODULE Setexc
	BIOS_6(5)
	movea.l d0,a0
	rts

.MODULE Tickcal
	BIOS_0(6)
	rts

