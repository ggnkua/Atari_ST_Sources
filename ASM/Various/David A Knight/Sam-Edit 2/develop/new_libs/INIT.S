************************************
*                                  *
* Assembly Library                 *
*                                  *
* Version 4.0                      *
*                                  *
* Author: D.A.Knight               *
*                                  *
* Date: 12/11/1997                 *
*                                  *
* Last update: 30/12/1997          *
*                                  *
************************************

GEM	equ	2

true	equ	1
false	equ	0

	COMMENT	HEAD=7

	include	d:\develop\new_libs\os.i

	include	d:\develop\new_libs\aes_macs.s
	include	d:\develop\new_libs\sys_macs.s
	include	d:\develop\new_libs\vdi_macs.s

	include	d:\develop\new_libs\get_cook.s
	include	d:\develop\new_libs\id.s
	include	d:\develop\new_libs\argv.s
	include	d:\develop\new_libs\envstrng.s
	include	d:\develop\new_libs\errors.s
	include	d:\develop\new_libs\main.s

	include	d:\develop\new_libs\dialog.i
	include	d:\develop\new_libs\gem_mess.s
	include	d:\develop\new_libs\info.s

	include	d:\develop\new_libs\falcon.s

	include	d:\develop\new_libs\details.s
	include	d:\develop\new_libs\string.s
	include	d:\develop\new_libs\div_mul.s

	include	multi.i
	include	sam_glob.i

	SECTION	text
initProgram

	move.l	a7,a5		; save a7
	move.l	#userStack,a7	; stack pointer to new stack
	move.l	4(a5),a5		; base page address
	lea	$81(a5),a1
	move.l	a1,cli		; command line address
	move.b	$80(a5),cliLength	; length of cli
	lea	44(a5),a3
	move.l	(a3),argvLocation	; argv address
	move.l	$2c(a5),a3
	move.l	a3,envPointer
	move.l	$c(a5),d0		; base page offset to text length
	add.l	$14(a5),d0		; base page offset to data length
	add.l	$1c(a5),d0		; base page offset to bss length
	add.l	#$100,d0		; base page size
	
	m_shrink	d0,a5

	getrez
	move.w	d0,-(sp)		; store returned mode

	appl_init	
	move.w	intout,apId
	move.w	global,aesVersion

	graf_handle
	move.w	intout,grHandle
** GDOS **
	moveq.w	#-2,d0
	trap	#2
	addq	#2,d0
	beq	noGdos		; gdos not present
	move.w	(sp)+,d0
	addq.w	#2,d0

	move.w	#1,gdos
	bra	sNoGdos

noGdos	move.w	#1,d0		; 1 default as no GDOS loaded
sNoGdos
	v_opnvwk	grHandle,d0,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1

	move.w	contrl+12,wsHandle	; store v_workstation handle 
** End GDOS **	

	f_setdta	#dta	

	wind_get	#0,#4
	move.w	intout+2,screenX
	move.w	intout+4,screenY
	move.w	intout+6,screenW
	move.w	intout+8,screenH

	graf_mouse	#0,#0

	bsr	idMachine

	bsr	argvDetection

	lea	avString,a0
	bsr	locateEnvString
	move.l	d0,avServer

	lea	userString,a0
	bsr	locateEnvString
	tst.l	d0
	bne	.setUserPath
	move.l	#current,d0
.setUserPath
	stringCopy	d0,#usrPath
; does the path end with a "\"
	lea	usrPath,a3
	stringLength	a3
	ext.l	d1
	subq.l	#1,d1
	add.l	d1,a3

	cmpi.b	#'\',(a3)
	beq	.usrPathOk

	addq.l	#1,a3
	move.w	#'\'*256,(a3)
.usrPathOk
	move.l	#usrPath,userDirectoryPath

	scrp_read	#clipPath

; is appl_getinfo available?
	cmpi.w	#$400,aesVersion	; AES 4.1?
	blt	.findAGI
	move.w	#1,agi
	bra	.AGIcheckedFor
.findAGI
	appl_find	#agiFind
	tst.w	intout
	bmi	.AGIcheckedFor
	move.w	#1,agi
.AGIcheckedFor
	bra	beginProgram

	SECTION	bss
cli	ds.b	4
cliLength	ds.b	2
argvLocation	ds.b	4
envPointer	ds.b	4
agi	ds.b	2

apId	ds.b	2
aesVersion	ds.b	2

grHandle	ds.b	2
wsHandle	ds.b	2

gdos	ds.b	2

dta	ds.b	44

screenX	ds.b	2
screenY	ds.b	2
screenW	ds.b	2
screenH	ds.b	2

clipPath	ds.b	256

avServer	ds.b	4
userDirectoryPath	ds.b	4
usrPath	ds.b	256
	
	ds.b	8196
userStack	ds.b	4

	SECTION	data
previous	dc.b	'..',0
current	dc.b	'.\',0
agiFind	dc.b	'?AGI',0