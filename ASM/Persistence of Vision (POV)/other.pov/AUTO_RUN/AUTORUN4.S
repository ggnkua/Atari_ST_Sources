*
* autorun.s
*

	opt	o+,w+,p+


	SECTION	TEXT

start
	bra.s	.code
	dc.b	"        "
	dc.b	'<AUTORUN Version 4.6 (C) June 1992'
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
	beq.s	exit
	cmp.w	#"HM",(a6)
	beq.s	set_med
	bsr	print_loading

on	clr.l	-(sp)
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
	bsr	set_palette
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
	beq.s	exit

.reset	pea	reset(pc)
	move.w	#38,-(sp)
	trap	#14

exit	clr.w	-(sp)
	trap	#1

set_med	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	bra.s	on

***************
* Subroutines *
***************

reset
	clr.l	$420.w
	clr.l	$43a.w
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
	lea	160*96+32(a0),a0
	lea	loading(pc),a1
	move.w	#10-1,d0
.loop	move.l	(a1)+,(a0)
	move.l	(a1)+,4(a0)
	move.l	(a1)+,8(a0)
	move.l	(a1)+,12(a0)
	move.l	(a1)+,16(a0)
	move.l	(a1)+,20(a0)
	move.l	(a1)+,24(a0)
	move.l	(a1)+,28(a0)
	move.l	(a1)+,32(a0)
	move.l	(a1)+,36(a0)
	move.l	(a1)+,40(a0)
	move.l	(a1)+,44(a0)
	move.l	(a1)+,48(a0)
	move.l	(a1)+,52(a0)
	move.l	(a1)+,56(a0)
	move.l	(a1)+,60(a0)
	move.l	(a1)+,64(a0)
	move.l	(a1)+,68(a0)
	move.l	(a1)+,72(a0)
	move.l	(a1)+,76(a0)
	move.l	(a1)+,80(a0)
	move.l	(a1)+,84(a0)
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

loading
*  Hardware color pallet  (color 0 to 15):
;	$0000,$0004,$0007,$0141,$0433,$0530,$0653,$0754
;	$0700,$0111,$0222,$0333,$0444,$0555,$0666,$0777
*
	dc.w	$0000,$4000,$0000,$4000,$0000,$001F,$0000,$001F
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$0FFF,$0000,$0FFF
	dc.w	$0000,$FF83,$0000,$FF83,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$01FF,$0000,$01FF,$0000,$FFF0,$0000,$FFF0
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$F87F,$0000,$F87F
	dc.w	$0000,$FFFE,$0000,$FFFE,$E000,$E000,$0000,$E000
	dc.w	$003F,$003F,$0000,$003F,$FFFF,$FFFF,$0000,$FFFF
	dc.w	$9FFF,$9FFF,$0000,$9FFF,$FFC7,$FFC7,$0000,$FFC7
	dc.w	$FFFF,$FFFF,$0000,$FFFF,$E1FF,$E1FF,$0000,$E1FF
	dc.w	$FFF1,$FFF1,$0000,$FFF1,$FFFF,$FFFF,$0000,$FFFF
	dc.w	$FCFF,$FCFF,$0000,$FCFF,$FFFE,$FFFE,$0000,$FFFE
	dc.w	$0000,$0000,$E000,$E000,$0000,$0000,$0038,$0038
	dc.w	$0000,$0000,$0003,$0003,$0000,$0000,$9C00,$9C00
	dc.w	$0000,$0000,$01C7,$01C7,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$7000,$7000,$0000,$0000,$E001,$E001
	dc.w	$0000,$0000,$C000,$C000,$0000,$0000,$1CE0,$1CE0
	dc.w	$0000,$0000,$0000,$0000,$E000,$0000,$E000,$E000
	dc.w	$0038,$0000,$0038,$0038,$0003,$0000,$0003,$0003
	dc.w	$9C00,$0000,$9C00,$9C00,$01C7,$0000,$01C7,$01C7
	dc.w	$0000,$0000,$0000,$0000,$7000,$0000,$7000,$7000
	dc.w	$E001,$0000,$E001,$E001,$C000,$0000,$C000,$C000
	dc.w	$1CE0,$0000,$1CE0,$1CE0,$0002,$0000,$0002,$0002
	dc.w	$0000,$E000,$E000,$E000,$0000,$0038,$0038,$0038
	dc.w	$0000,$0003,$0003,$0003,$0000,$9FFF,$9FFF,$9FFF
	dc.w	$0000,$FFC7,$FFC7,$FFC7,$0000,$0000,$0000,$0000
	dc.w	$0000,$7000,$7000,$7000,$0000,$E001,$E001,$E001
	dc.w	$0000,$C000,$C000,$C000,$0000,$1CE0,$1CE0,$1CE0
	dc.w	$0000,$0007,$0007,$0007,$E000,$E000,$E000,$E000
	dc.w	$0038,$0038,$0038,$0038,$0003,$0003,$0003,$0003
	dc.w	$9FFF,$9FFF,$9FFF,$9FFF,$FFC7,$FFC7,$FFC7,$FFC7
	dc.w	$0000,$0000,$0000,$0000,$7000,$7000,$7000,$7000
	dc.w	$E001,$E001,$E001,$E001,$C000,$C000,$C000,$C000
	dc.w	$1CE0,$1CE0,$1CE0,$1CE0,$0007,$0007,$0007,$0007
	dc.w	$0000,$E000,$E000,$E000,$0000,$0038,$0038,$0038
	dc.w	$0000,$0003,$0003,$0003,$0000,$9C00,$9C00,$9C00
	dc.w	$0000,$01C7,$01C7,$01C7,$0000,$0000,$0000,$0000
	dc.w	$0000,$7000,$7000,$7000,$0000,$E001,$E001,$E001
	dc.w	$0000,$C000,$C000,$C000,$0000,$1CE0,$1CE0,$1CE0
	dc.w	$0000,$0007,$0007,$0007,$E000,$0000,$E000,$E000
	dc.w	$0038,$0000,$0038,$0038,$0003,$0000,$0003,$0003
	dc.w	$9C00,$0000,$9C00,$9C00,$01C7,$0000,$01C7,$01C7
	dc.w	$0000,$0000,$0000,$0000,$E000,$0000,$E000,$E000
	dc.w	$E001,$0000,$E001,$E001,$C000,$0000,$C000,$C000
	dc.w	$1CE0,$0000,$1CE0,$1CE0,$0007,$0000,$0007,$0007
	dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$FF3F,$FF3F
	dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$9C00,$9C00
	dc.w	$0000,$0000,$01C7,$01C7,$0000,$0000,$FFFF,$FFFF
	dc.w	$0000,$0000,$C3FF,$C3FF,$0000,$0000,$FFF9,$FFF9
	dc.w	$0000,$0000,$C000,$C000,$0000,$0000,$1CFF,$1CFF
	dc.w	$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFF,$0000,$FFFF
	dc.w	$FE1F,$FE1F,$0000,$FE1F,$FFFF,$FFFF,$0000,$FFFF
	dc.w	$0800,$0800,$0000,$0800,$0083,$0083,$0000,$0083
	dc.w	$FFFF,$FFFF,$0000,$FFFF,$01FF,$01FF,$0000,$01FF
	dc.w	$FFF0,$FFF0,$0000,$FFF0,$8000,$8000,$0000,$8000
	dc.w	$087F,$087F,$0000,$087F,$FFFE,$FFFE,$0000,$FFFE


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
	dc.w	$777,$111,$222,$333,$444,$555,$666,$777

cls	dc.b	27,'E',0,0

**********************
* Uninitialised data *
**********************

	SECTION	BSS

exec_type	ds.w	1

	ds.b	1000
stack	ds.l	1
