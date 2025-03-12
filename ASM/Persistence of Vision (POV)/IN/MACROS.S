*** Macros for Lynx TriSoundSequencer (GigaSong v1.0)
*** written by Mac Sys Data of Persistence Of Vision
*** June '94

col0	equ	$ffff8240

startup	macro
	move.l	4(sp),a3
	move.l	$C(a3),d0
	add.l	$14(a3),d0
	add.l	$1C(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

getrez	macro
	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	endm

setrez	macro	\1
	move.w	\1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endm


super	macro	\1
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,\1
	endm

user	macro	\1
	move.l	\1,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	endm

getpal	macro	\1
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,\1
	endm

setpal	macro	\1
	movem.l	\1,d0-d7
	movem.l	d0-d7,$ffff8240.w
	endm

getphys	macro
	move.w	#2,-(sp)
	trap	#14
	addq.w	#2,sp
	endm

vsync	macro
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	endm

term	macro
	clr.w	-(sp)
	trap	#1
	endm

ins_vbi	macro	\1
	move.w	sr,d7
	move.w	#$2700,sr
	move.w	$454.w,d0
	move.l	$456.w,a0

**** don't know if these are ok but I'll try them.....
		move.w	d0,Cdata+50
		move.l	a0,Cdata+52

	subq.w	#1,d0
insloop	tst.l	(a0)+
	beq.s	local
	dbf	d0,insloop
	move.w	$454.w,d0
	subq.w	#1,d0
	move.l	$456.w,a1

**** don't know if these are ok but I'll try them.....
		lea	Cdata+56,a0
insloop2	move.l	(a1)+,(a0)+
		dbf	d0,insloop2
		move.w	#$20,$454.w

**** don't know if these are ok but I'll try them.....
		move.l	#Cdata+56,$456.w
local		move.l	a0,Cdata+56+$80

	move.l	#play3v,(a0)
	move.w	d7,sr
	endm

deins_vbi	macro

**** don't know if these are ok but I'll try them.....
		move.l	Cdata+56,a0
		clr.l	(a0)

**** don't know if these are ok but I'll try them.....
		move.w	Cdata+50,$454.w
		move.l	Cdata+52,$456.w

	endm

waitkey	macro
	move.w	#1,-(sp)
	trap	#1
	addq.w	#2,sp
	endm

print	macro	\1
	pea	\1
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	endm

