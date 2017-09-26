;----------------------------------------------------------------------------------------
;	xbios.s, part of TOS Linker for CodeWarrier
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

.export Bconmap, Bioskeys, Blitmode
.export buffoper, buffptr
.export Cursconf
.export devconnect
.export DMAread, DMAwrite
.export Dosound
.export Dsp_Available, Dsp_BlkBytes, Dsp_BlkHandShake, Dsp_BlkUnpacked, Dsp_BlkWords
.export Dsp_DoBlock, Dsp_ExecBoot, Dsp_ExecProg, Dsp_FlushSubroutines, Dsp_GetProgAbility
.export Dsp_GetWordSize, Dsp_Hf0, Dsp_Hf1, Dsp_Hf2, Dsp_Hf3
.export Dsp_HStat, Dsp_InqSubrAbility, Dsp_InStream, Dsp_IOStream, Dsp_LoadProg
.export Dsp_LoadSubroutine, Dsp_Lock, Dsp_LodToBinary, Dsp_MultBlocks, Dsp_OutStream
.export Dsp_RemoveInterrupts, Dsp_RequestUniqueAbility, Dsp_Reserve, Dsp_RunSubroutine, Dsp_SetVectors
.export Dsp_TriggerHC, Dsp_Unlock, dsptristate
.export EgetPalette, EgetShift, EsetBank, EsetColor, EsetGray
.export EsetPalette, EsetShift, EsetSmear
.export Flopfmt, Floprate, Floprd, Flopver, Flopwr
.export Getrez
.export Gettime
.export Giaccess
.export gpio,
.export Ikbdws, Initmous, Iorec
.export Jdisint, Jenabint
.export Kbdvbase, Kbrate, Keytbl
.export Logbase
.export locksnd
.export mon_type
.export Metaclose, Metadiscinfo, Metagettoc, Metainit, Metaioctl
.export Metaopen, Metaread, Metasetsongtime, Metastartaudio, Metastatus
.export Metastopaudio, Metawrite
.export Mfpint, Midiws
.export NVMaccess
.export Offgibit, Ongibit
.export Oscanis, Oscanpath, Oscanphy, Oscanscr, Oscanswitch
.export Oscantab, Oscanvb
.export Physbase
.export Protobt, Prtblk, Puntaes
.export Random
.export Rsconf
.export Scrdmp
.export setbuffer
.export Setcolor
.export setinterrupt
.export setmode
.export setmontracks
.export Setpalette
.export Setprt
.export Setscreen
.export Settime
.export settracks
.export sndstatus, soundcmd
.export Ssbrk
.export Supexec
.export unlocksnd
.export VgetRGB, VgetSize, VsetMask, Vsetmode, VsetRGB, VsetSync
.export Vsync
.export Xbtimer

MACRO XBIOS_0 nr
		pea (a2)
		move.w #nr,-(sp)
		trap #14
		addq.l #2,sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_2 nr
		pea (a2)
		move.w 8(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		addq.l #4,sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_4 nr
		pea (a2)
		move.l 8(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		addq.l #6,sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_6 nr
		pea (a2)
		move.l 10(sp),-(sp)
		move.w 12(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		addq.l #8,sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_8 nr
		pea (a2)
		move.l 12(sp),-(sp)
		move.l 12(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		lea 10(sp),sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_10 nr
		pea (a2)
		move.l 14(sp),-(sp)
		move.l 14(sp),-(sp)
		move.w 16(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		lea 12(sp),sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_12 nr
		pea (a2)
		move.l 16(sp),-(sp)
		move.l 16(sp),-(sp)
		move.l 16(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		lea 14(sp),sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_16 nr
		pea (a2)
		move.l 20(sp),-(sp)
		move.l 20(sp),-(sp)
		move.l 20(sp),-(sp)
		move.l 20(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		lea 18(sp),sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_18 nr
		pea (a2)
		move.l 22(sp),-(sp)
		move.l 22(sp),-(sp)
		move.l 22(sp),-(sp)
		move.l 22(sp),-(sp)
		move.w 24(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		lea 20(sp),sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_20 nr
		pea (a2)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.l 24(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		lea 22(sp),sp
		move.l (sp)+,a2
ENDM

MACRO XBIOS_24 nr
		pea (a2)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.l 28(sp),-(sp)
		move.w #nr,-(sp)
		trap #14
		lea 26(sp),sp
		move.l (sp)+,a2
ENDM


.MODULE Bconmap
	XBIOS_2(44)
	rts

.MODULE Bioskeys
	XBIOS_0(24)
	rts

.MODULE Blitmode
	XBIOS_2(64)
	rts

.MODULE buffoper
	XBIOS_2(136)
	rts

.MODULE buffptr
	XBIOS_4(141)
	rts

.MODULE Cursconf
	XBIOS_4(21)
	rts

.MODULE devconnect
	XBIOS_10(139)
	rts

.MODULE DMAread
	XBIOS_10(42)
	rts

.MODULE DMAwrite
	XBIOS_10(43)
	rts

.MODULE Dosound
	XBIOS_4(32)
	rts

.MODULE Dsp_Available
	XBIOS_8(106)
	rts

.MODULE Dsp_BlkBytes
	XBIOS_16(124)
	rts

.MODULE Dsp_BlkHandShake
	XBIOS_16(97)
	rts

.MODULE Dsp_BlkUnpacked
	XBIOS_16(98)
	rts

.MODULE Dsp_BlkWords
	XBIOS_16(123)
	rts

.MODULE Dsp_DoBlock
	XBIOS_16(96)
	rts

.MODULE Dsp_ExecBoot
	XBIOS_10(110)
	rts

.MODULE Dsp_ExecProg
	XBIOS_10(109)
	rts

.MODULE Dsp_FlushSubroutines
	XBIOS_0(115)
	rts

.MODULE Dsp_GetProgAbility
	XBIOS_0(114)
	rts

.MODULE Dsp_GetWordSize
	XBIOS_0(103)
	rts

.MODULE Dsp_Hf0
	XBIOS_2(119)
	rts

.MODULE Dsp_Hf1
	XBIOS_2(120)
	rts

.MODULE Dsp_Hf2
	XBIOS_0(121)
	rts

.MODULE Dsp_Hf3
	XBIOS_0(122)
	rts

.MODULE Dsp_HStat
	XBIOS_0(125)
	rts

.MODULE Dsp_InqSubrAbility
	XBIOS_2(117)
	rts

.MODULE Dsp_InStream
	XBIOS_16(99)
	rts

.MODULE Dsp_IOStream
	XBIOS_24(101)
	rts

.MODULE Dsp_LoadProg
	XBIOS_10(108)
	rts

.MODULE Dsp_LoadSubroutine
	XBIOS_10(116)
	rts

.MODULE Dsp_Lock
	XBIOS_0(104)
	rts

.MODULE Dsp_LodToBinary
	XBIOS_8(111)
	rts

.MODULE Dsp_MultBlocks
	XBIOS_16(127)
	rts

.MODULE Dsp_OutStream
	XBIOS_16(100)
	rts

.MODULE Dsp_RemoveInterrupts
	XBIOS_2(102)
	rts

.MODULE Dsp_RequestUniqueAbility
	XBIOS_0(113)
	rts

.MODULE Dsp_Reserve
	XBIOS_8(107)
	rts

.MODULE Dsp_RunSubroutine
	XBIOS_2(118)
	rts

.MODULE Dsp_SetVectors
	XBIOS_8(126)
	rts

.MODULE Dsp_TriggerHC
	XBIOS_2(112)
	rts

.MODULE Dsp_Unlock
	XBIOS_0(105)
	rts

.MODULE dsptristate
	XBIOS_4(137)
	rts

.MODULE EgetPalette
	XBIOS_8(85)
	rts

.MODULE EgetShift
	XBIOS_0(81)
	rts

.MODULE EsetBank
	XBIOS_2(82)
	rts

.MODULE EsetColor
	XBIOS_4(83)
	rts

.MODULE EsetGray
	XBIOS_2(86)
	rts

.MODULE EsetPalette
	XBIOS_8(84)
	rts

.MODULE EsetShift
	XBIOS_2(80)
	rts

.MODULE EsetSmear
	XBIOS_2(87)
	rts

.MODULE Flopfmt
	XBIOS_20(10)
	rts

.MODULE Floprate
	XBIOS_4(41)
	rts

.MODULE Floprd
	XBIOS_18(8)
	rts

.MODULE Flopver
	XBIOS_18(19)
	rts

.MODULE Flopwr
	XBIOS_18(9)
	rts

.MODULE Getrez
	XBIOS_0(4)
	rts

.MODULE Gettime
	XBIOS_0(23)
	rts

.MODULE Giaccess
	XBIOS_4(28)
	rts

.MODULE gpio
	XBIOS_4(138)
	rts

.MODULE Ikbdws
	XBIOS_6(25)
	rts

.MODULE Initmous
	XBIOS_10(0)
	rts

.MODULE Iorec
	XBIOS_2(14)
	movea.l d0,a0
	rts

.MODULE Jdisint
	XBIOS_2(26)
	rts

.MODULE Jenabint
	XBIOS_2(27)
	rts

.MODULE Kbdvbase
	XBIOS_0(34)
	movea.l d0,a0
	rts

.MODULE Kbrate
	XBIOS_4(35)
	rts

.MODULE Keytbl
	XBIOS_12(16)
	movea.l d0,a0
	rts

.MODULE Logbase
	XBIOS_0(3)
	movea.l d0,a0
	rts

.MODULE locksnd
	XBIOS_0(128)
	rts

.MODULE mon_type
	XBIOS_0(89)
	rts

.MODULE Metaclose
	XBIOS_2(50)
	rts

.MODULE Metadiscinfo
	XBIOS_6(63)
	rts

.MODULE Metagettoc
	XBIOS_8(62)
	rts

.MODULE Metainit
	XBIOS_4(48)
	rts

.MODULE Metaioctl
	XBIOS_12(55)
	rts

.MODULE Metaopen
	XBIOS_6(49)
	rts

.MODULE Metaread
	XBIOS_12(51)
	rts

.MODULE Metasetsongtime
	XBIOS_12(61)
	rts

.MODULE Metastartaudio
	XBIOS_8(59)
	rts

.MODULE Metastatus
	XBIOS_6(54)
	rts

.MODULE Metastopaudio
	XBIOS_2(60)
	rts

.MODULE Metawrite
	XBIOS_12(52)
	rts

.MODULE Mfpint
	XBIOS_6(13)
	rts

.MODULE Midiws
	XBIOS_6(12)
	rts

.MODULE NVMaccess
	XBIOS_10(46)
	rts

.MODULE Offgibit
	XBIOS_2(29)
	rts

.MODULE Ongibit
	XBIOS_2(30)
	rts

.MODULE Oscanis
	XBIOS_0(4200)
	rts

.MODULE Oscanpath
	XBIOS_0(4205)
	movea.l d0,a0
	rts

.MODULE Oscanphy
	XBIOS_2(4202)
	rts

.MODULE Oscanscr
	XBIOS_2(4203)
	rts

.MODULE Oscanswitch
	XBIOS_2(4206)
	rts

.MODULE Oscantab
	XBIOS_2(4201)
	movea.l d0,a0
	rts

.MODULE Oscanvb
	XBIOS_2(4204)
	rts

.MODULE Physbase
	XBIOS_0(2)
	movea.l d0,a0
	rts

.MODULE Protobt
	XBIOS_12(18)
	rts

.MODULE Prtblk
	XBIOS_4(36)
	rts

.MODULE Puntaes
	XBIOS_0(39)
	rts

.MODULE Random
	XBIOS_0(17)
	rts

.MODULE Rsconf
	XBIOS_12(15)
	rts

.MODULE Scrdmp
	XBIOS_0(20)
	rts

.MODULE setbuffer
	XBIOS_10(131)
	rts

.MODULE Setcolor
	XBIOS_4(7)
	rts

.MODULE setinterrupt
	XBIOS_4(135)
	rts

.MODULE setmode
	XBIOS_2(132)
	rts

.MODULE setmontracks
	XBIOS_2(134)
	rts

.MODULE Setpalette
	XBIOS_4(6)
	rts

.MODULE Setprt
	XBIOS_2(33)
	rts

.MODULE Setscreen
	XBIOS_10(5)
	rts

.MODULE Settime
	XBIOS_4(22)
	rts

.MODULE settracks
	XBIOS_4(133)
	rts

.MODULE sndstatus
	XBIOS_2(140)
	rts

.MODULE soundcmd
	XBIOS_4(130)
	rts

.MODULE Ssbrk
	XBIOS_2(1)
	rts

.MODULE Supexec
	XBIOS_4(38)
	rts

.MODULE unlocksnd
	XBIOS_0(129)
	rts

.MODULE VgetRGB
	XBIOS_8(94)
	rts

.MODULE VgetSize
	XBIOS_2(91)
	rts

.MODULE VsetMask
	XBIOS_6(150)
	rts

.MODULE Vsetmode
	XBIOS_2(88)
	rts

.MODULE VsetRGB
	XBIOS_8(93)
	rts

.MODULE VsetSync
	XBIOS_2(90)
	rts

.MODULE Vsync
	XBIOS_0(37)
	rts

.MODULE Xbtimer
	XBIOS_10(31)
	rts
