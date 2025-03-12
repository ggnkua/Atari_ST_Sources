* MACROS for use instead of BIOSSHEL.S
* by James Ingram, April 1993
*


bios_definitions	equ	1

r_shfit	equ	0
l_shift	equ	1
cntrl	equ	2
alt	equ	3
caps	equ	4
r_mouse	equ	5
l_mouse	equ	6


getmpb	macro
	IIF NARG<>1	fail	need abs address or Ax register

	move.l	\1,-(a7)
	clr.w	-(a7)
	trap	#13
	addq.l	#6,a7
	endm


in_constat	macro
	IIF	NARG<>1	fail	need device number

	move.w	\1,-(a7)
	move.w	#1,-(a7)
	trap	#1
	addq.l	#4,a7
	endm



bconin	macro
	IIF	NARG<>1	fail	need device number

	move.w	\1,-(a7)
	move.w	#2,-(a7)
	trap	#13
	addq.l	#4,a7
	endm


bconout	macro
	IIF	NARG<>2	fail	need char and device

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	endm


rwabs	macro
	IIF	NARG<>5	fail	need device, sec no, no of secs, BUFFER.L, r/w flag

	move.w	\1,-(a7)
	move.w	\2,-(a7)
	move.w	\3,-(a7)
	move.l	\4,-(a7)
	move.w	\5,-(a7)
	move.w	#4,-(a7)
	trap	#13
	lea	14(a7),a7
	endm


setexec	macro
	IIF	NARG<>2	fail	need vector addr and vector no

	move.l	\1,-(a7)
	move.w	\2,-(a7)
	trap	#13
	addq.l	#6,a7
	endm


tickcal	macro
	move.w	#6,-(a7)
	trap	#13
	addq.l	#2,a7
	endm


getbpb	macro
	IIF	NARG<>1	fail	need device number

	move.w	\1,-(a7)
	move.w	#7,-(a7)
	trap	#13
	addq.l	#4,a7
	endm

out_constat	macro
	IIF	NARG<>1	fail	need device number

	move.w	\1,-9a7)
	move.w	#8,-(a7)
	trap	#13
	addq.l	#4,a7
	endm


mediach	macro
	IIF	NARG<>1	fail	need device number

	move.w	\1,-(a7)
	move.w	#9,-(a7)
	trap	#13
	addq.l	#4,a7
	endm


drvmap	macro
	move.w	#10,-(a7)
	trap	#13
	addq.l	#2,a7
	endm


kbshift	macro
	IIF	NARG<>1	fail	need status or -1

	move.w	\1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	endm


get_shift	macro
	kbshift	#-1
	endm


	

