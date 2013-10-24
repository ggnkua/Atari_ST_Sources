*
* autorun.s
*

	opt	o+,w+,p+


	SECTION	TEXT

start
	bra	code
	dc.b	'<AUTORUN Version 4.2 (C) 1990'
	dc.b	' MAC SYS DATA & BORIS >'
	ds.b	300
stack	dc.l	0
	even
code
	move.l	sp,a5
	lea	stack(pc),sp
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	lea	exec_type(pc),a6
	pea	get_type(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp
;	cmp.w	#"$$",(a6)
;	beq.s	.exit

	pea	load_mess(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp

	bsr.s	set_palette

	lea	path(pc),a5
	tst.w	(a5)
	beq.s	.no_path

	pea	$200+16.w
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,sp

.no_path
	clr.l	-(sp)
	pea	com_tail(pc)
	pea	$202.w
	clr.w	-(sp)
	move.w	#$4b,-(sp)
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
.exit
	clr.w	-(sp)
	trap	#1


***************
* Subroutines *
***************

reset
	move.l	$4.w,-(sp)
	rts


get_type
	move.w	$200.w,(a6)
	move.w	$210.w,-2(a6)
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
	dc.b	27,'Y',11+32,14+32, 'AUTORUN 4.2'
	dc.b	27,'Y',13+32,14+32, 'LOADING....'
	dc.b	7
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
	dc.w	$000,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777


**********************
* Uninitialised data *
**********************

	SECTION	BSS

path		ds.w	1
exec_type	ds.w	1

