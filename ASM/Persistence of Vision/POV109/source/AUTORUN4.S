*
* autorun.s
*

	opt	o+,w+,p+


	SECTION	TEXT

start
	bra.s	.code
	dc.b	"        "
	dc.b	'<AUTORUN Version 4.5 (C) April 1992'
	dc.b	' Boris & Mac Sys Data >'
	dc.b	"        "
	even
.code
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
	cmp.w	#"$$",(a6)
	beq.s	.exit
	bsr.s	print_loading

	clr.l	-(sp)
	pea	com_tail(pc)
	pea	$200.w
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
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	.test
	bra.s	.endless

.test	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	cmp.b	#27,d0
	beq.s	.exit

.reset	pea	reset(pc)
	move.w	#38,-(sp)
	trap	#14

.exit	clr.w	-(sp)
	trap	#1

***************
* Subroutines *
***************

reset
	clr.l	$420.w
	move.l	$4.w,-(sp)
	rts


get_type
	move.w	$200.w,(a6)
	rts

print_loading
	pea	cls(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0
	lea	160*96+64(a0),a0
	lea	loading(pc),a1
	move.w	#8-1,d0
.loop	move.w	(a1)+,(a0)
	move.w	(a1)+,8(a0)
	move.w	(a1)+,16(a0)
	move.w	(a1)+,24(a0)
	lea	160(a0),a0
	dbf	d0,.loop

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

loading	dc.w	$707F,$9FDF,$CFF6,$3BFC
	dc.w	$7061,$9CD8,$C3C7,$BB0C
	dc.w	$7061,$9CD8,$C3C7,$FB00
	dc.w	$F063,$BFDE,$E3C6,$7B3C
	dc.w	$F063,$BFDE,$E3C6,$7B3C
	dc.w	$F063,$BCDE,$E3C6,$3B1C
	dc.w	$F063,$BCDE,$E3C6,$3B1C
	dc.w	$FE7F,$BCDF,$EFF6,$3BFC


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

cls	dc.b	27,'E',0,0

**********************
* Uninitialised data *
**********************

	SECTION	BSS

exec_type	ds.w	1

	ds.b	1000
stack	ds.l	1
