;***********************************************
;* Modulname      : FALCNLIB.S                 *
;* Autor          : Thomas Binder              *
;* Zweck          : Libraryroutinen fÅr das    *
;*                  XBIOS-Interface des F030   *
;*                  (ohne DSP-Routinen!)       *
;* Compiler       : Pure C 1.0                 *
;* Erstellt am    : 20.05.1993                 *
;* Letzte énderung: 26.08.1993                 *
;***********************************************


	export	VSetscreen, Vsetmode, mon_type,
	export	VsetSync, VgetSize, VsetRGB,
	export	VgetRGB, VsetMask
	export	locksnd, unlocksnd, soundcmd
	export	setbuffer, setsndmode, settrack
	export	setmontrack, setinterrupt, buffoper
	export	dsptristate, gpio, devconnect
	export	sndstatus, buffptr

MACRO pusha2
	move.l	a2,-(sp)
ENDM

MACRO pulla2
	move.l	(sp)+,a2
ENDM
	
	text

MODULE VSetscreen
	pusha2
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea		14(sp),sp
	pulla2
	rts
ENDMOD

MODULE Vsetmode
	pusha2
	move.w	d0,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD

MODULE mon_type
	pusha2
	move.w	#89,-(sp)
	trap	#14
	addq.l	#2,sp
	pulla2
	rts
ENDMOD

MODULE VsetSync
	pusha2
	move.w	d0,-(sp)
	move.w	#90,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD

MODULE VgetSize
	pusha2
	move.w	d0,-(sp)
	move.w	#91,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD

MODULE VsetRGB
	pusha2
	move.l	a0,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#93,-(sp)
	trap	#14
	lea		10(sp),sp
	pulla2
	rts
ENDMOD

MODULE VgetRGB
	pusha2
	move.l	a0,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#94,-(sp)
	trap	#14
	lea		10(sp),sp
	pulla2
	rts
ENDMOD

MODULE VsetMask
	pusha2
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#150,-(sp)
	trap	#14
	addq.l	#6,sp
	pulla2
	rts
ENDMOD
	
MODULE locksnd
	pusha2
	move.w	#128,-(sp)
	trap	#14
	addq.l	#2,sp
	pulla2
	rts
ENDMOD

MODULE unlocksnd
	pusha2
	move.w	#129,-(sp)
	trap	#14
	addq.l	#2,sp
	pulla2
	rts
ENDMOD

MODULE soundcmd
	pusha2
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	pulla2
	rts
ENDMOD

MODULE setbuffer
	pusha2
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.w	d0,-(sp)
	move.w	#131,-(sp)
	trap	#14
	lea		12(sp),sp
	pulla2
	rts
ENDMOD

MODULE setsndmode
	pusha2
	move.w	d0,-(sp)
	move.w	#132,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD

MODULE settrack
	pusha2
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#133,-(sp)
	trap	#14
	addq.l	#6,sp
	pulla2
	rts
ENDMOD

MODULE setmontrack
	pusha2
	move.w	d0,-(sp)
	move.w	#134,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD

MODULE setinterrupt
	pusha2
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#135,-(sp)
	trap	#14
	addq.l	#6,sp
	pulla2
	rts
ENDMOD

MODULE buffoper
	pusha2
	move.w	d0,-(sp)
	move.w	#136,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD

MODULE dsptristate
	pusha2
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#137,-(sp)
	trap	#14
	addq.l	#6,sp
	pulla2
	rts
ENDMOD

MODULE gpio
	pusha2
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#138,-(sp)
	trap	#14
	addq.l	#6,sp
	pulla2
	rts
ENDMOD

MODULE devconnect
	pusha2
	move.w	10(sp),-(sp)
	move.w	10(sp),-(sp)
	move.w	d2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#139,-(sp)
	trap	#14
	lea		12(sp),sp
	pulla2
	rts
ENDMOD

MODULE sndstatus
	pusha2
	move.w	d0,-(sp)
	move.w	#140,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD

MODULE buffptr
	pusha2
	move.l	a0,-(sp)
	move.w	#141,-(sp)
	trap	#14
	addq.l	#4,sp
	pulla2
	rts
ENDMOD
