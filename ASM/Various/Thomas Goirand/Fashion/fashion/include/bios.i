Bconin	macro	; dev
	move.w	\1,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

DEV_PRINTER	EQU	0
DEV_AUX		EQU	1
DEV_CONSOLE	EQU	2
DEV_MIDI	EQU	3
DEV_IKBD	EQU	4
DEV_RAW		EQU	5

Bconout	macro	; dev,ch
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	ENDM

Bconstat	macro	; dev
	move.w	\1,-(sp)
	move.w	#1,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

Bcostat	macro	; dev
	move.w	\1,-(sp)
	move.w	#8,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

Drvmap	MACRO
	move.w	#$A,-(sp)
	trap	#13
	addq.l	#2,sp
	ENDM

Getbpb	macro	; dev
	move.w	\1,-(sp)
	move.w	#7,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

Getmpb	macro	; mpb
	pea	\1
	clr.w	-(sp)
	trap	#13
	addq.l	#6,sp
	ENDM

Kbshift	macro	; mode
	move.w	\1,-(sp)
	move.w	#$B,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

K_RSHIFT	EQU	$01
K_LSHIFT	EQU	$02
K_CTRL		EQU	$04
K_ALT		EQU	$08
K_CAPSLOCK	EQU	$10
K_CLRHOME	EQU	$20
K_INSERT	EQU	$40

Mediach	macro	; dev
	move.w	\1,-(sp)
	move.w	#9,-(sp)
	trap	#13
	addq.l	#4,sp
	ENDM

MED_NOCHANGE	EQU	0
MED_UNKNOWN	EQU	1
MED_CHANGED	EQU	2

Rwabs	macro	; mode,buf,count,recno,dev,lrecno
	IFNE	'\6',''
	move.l	\6,-(sp)
	ENDC
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	pea	\2
	move.w	\1,-(sp)
	move.w	#4,-(sp)
	trap	#13
	lea	18(sp),sp
	ENDM

RW_READ		EQU	0
RW_WRITE	EQU	$1
RW_NOMEDIACH	EQU	$2
RW_NORETRIES	EQU	$4
RW_NOTRANSLATE	EQU	$8

Setexc	macro	; num,newvec
	pea	\2
	move.w	\1,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	ENDM

VEC_BUSERROR		EQU	$002
VEC_ADRESSERROR		EQU	$003
VEC_ILLEGALINSTRUCTION	EQU	$004
VEC_GEMDOS		EQU	$021
VEC_GEM			EQU	$022
VEC_BIOS		EQU	$02D
VEC_XBIOS		EQU	$02E
VEC_TIMER		EQU	$100
VEC_CRITICALERROR	EQU	$101
VEC_TERMINATE		EQU	$102

Tickcal	MACRO
	move.w	#6,-(sp)
	trap	#13
	addq.l	#2,sp
	ENDM