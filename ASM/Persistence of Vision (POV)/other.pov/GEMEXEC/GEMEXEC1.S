*
* gemexec1.s
*

	include	'c:\include\gemmacro.s'

start
	bra.s	.code
	dc.b	'<GEMEXEC Version 1.0 (C) 1990 Boris>'
	even
.code
	move.l	#mystack,a7

	pea	palette-2(pc)
	move.w	#6,-(sp)
	trap	#14
	addq.w	#6,sp

	appl_init
	move.w	d0,ap_id

	menu_register	ap_id,#mymenu

	evnt_timer	#2000
	pea	load_mess(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	bsr.s	set_palette

	clr.l	-(sp)
	pea	com_tail(pc)
	pea	$202.w
	clr.w	-(sp)
	move.w	#75,-(sp)
	trap	#1
	add.w	#16,sp
	tst.l	d0
	bmi.s	.fault
	pea	reset(pc)
	move.w	#38,-(sp)
	trap	#14
.fault
	bsr.s	set_palette
	pea	err_mess(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
.endless
	bra.s	.endless


***************
* Subroutines *
***************

reset
	move.l	$4.w,-(sp)
	rts


set_palette
	pea	palette(pc)
	move.w	#6,-(sp)
	trap	#14
	addq.w	#6,sp
	rts


********************
* Initialised data *
********************

	SECTION	DATA

load_mess
	dc.b	27,'c0',27,'b',15+32,27,'E'
	dc.b	27,'Y',12+32,15+32, 'LOADING...'
	dc.b	0
	even

err_mess
	dc.b	27,'c0',27,'b',15+32,27,'E',27,'f'
	dc.b	27,'Y',10+32,8+32, '* * *  E R R O R  * * *'
	dc.b	27,'Y',12+32,5+32, 'This disc seems to be faulty!'
	dc.b	27,'Y',13+32,6+32, 'You should get another copy.'
	dc.b	0
	even

com_tail
	dc.l	0

palette
	dcb.w	15,0
	dc.w	$777

mymenu
	dc.b	'  GEM exec',0
	even


**********************
* Uninitialised data *
**********************

	SECTION	BSS

ap_id		ds.w	1

		ds.b	1000
mystack		ds.l	1


* if not linking then include the run-times

	IFEQ	__LK
	include	'c:\include\aeslib.s'
	ENDC
