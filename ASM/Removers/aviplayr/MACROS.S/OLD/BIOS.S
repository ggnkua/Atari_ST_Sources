***************
* Macros BIOS *
***************

Getmpb	macro
	pea	\1
	clr.w	-(sp)
	trap	#13
	addq.l	#6,sp
	endm
	
Bconstat	macro
	move.w	\1,-(sp)
	move.w	#1,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
Bconin	macro
	move.w	\1,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
Bconout	macro
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	endm
	
Rwabs	macro
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	pea	\2
	move.w	\1,-(sp)
	move.w	#4,-(sp)
	trap	#13
	lea	14(sp),sp
	endm
	
Setexc	macro
	pea	\2
	move.w	\1,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	endm
	
Tickcal	macro
	move.w	#6,-(sp)
	trap	#13
	addq.l	#2,sp
	endm
	
Getbpb	macro
	move.w	\1,-(sp)
	move.w	#7,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
Bcostat	macro
	move.w	\1,-(sp)
	move.w	#8,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
Mediach	macro
	move.w	\1,-(sp)
	move.w	#9,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
Drvmap	macro
	move.w	#10,-(sp)
	trap	#13
	addq.l	#2,sp
	endm
	
*******************
* Kbshift(mode.w) *
*******************
K_RSHIFT	equ	1<<0
K_LSHIFT	equ	1<<1
K_CTRL		equ	1<<2
K_ALT		equ	1<<3
K_CAPSLOCK	equ	1<<4
K_CLRHOME	equ	1<<5
K_INSERT	equ	1<<6

Kbshift	macro
	move.w	\1,-(sp)
	move.w	#11,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	