	move.l 4(a7),a5
	move.l #$1500,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	add.w #12,a7

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	move.b	$700,d0
	cmp.b	#'2',d0
	bne.s	gomenu

nova	move.b	$701,$ffff820a.w
	move.w	#0,$700
	clr.w	-(a7)
	trap	#1

gomenu	move.l	#mess,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#$777,$ffff825e.w

	moveq	#20,d1
l2	move.l	#$ffff,d0
l1	dbf	d0,l1
	dbf	d1,l2

	move.l	#$10000,-(a7)
	move.l	#$10000,-(a7)
	move.l	#yomenu,-(a7)
	move.w	#0,-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	lea	16(a7),a7

	clr.w	-(a7)
	trap	#1

mess	dc.b	27,'E',27,'f',27,'v'
	dc.b	' IF YOU SELECT SUPANOVA, YOUR ST WILL   '
	dc.b	' RE-BOOT. THIS IS PERFECTLY NORMAL !!',13,10,10
	dc.b	' WHEN DESKTOP APPEARS, DOUBLE-CLICK ON  '
	dc.b	' SUPANOVA.PRG TO RUN IT. OKEY DOKEY ?',0
yomenu	dc.b	'cd26a.wld'


  