
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,sp
	bclr	#0,$484.w
	clr.b	$fffffc02.w
	moveq.l	#1,d0
	move.b	$fffffa09.w,old9
	move.b	$fffffa0d.w,oldd
	move.b	$fffffa15.w,old15
	move.b	$fffffa17.w,old17
	move.b	$fffffa1d.w,old1d


	move.l	d0,d1
	lea	muz1,a0
	move.l	$110.w,old110
	move.l	$70.w,old70
	jsr	muzak
	move.w	#$2700,sr
	move.l	#new70,$70.w
	move.w	#$2300,sr
keywait	cmpi.b	#57,$fffffc02.w
	bne.s	keywait
	move.w	#$2700,sr
	move.l	old70,$70.w
	move.b	old9,$fffffa09.w
	move.b	oldd,$fffffa0d.w
	move.b	old15,$fffffa15.w
	move.b	old17,$fffffa17.w
	move.b	old1d,$fffffa1d.w
 	move.w	#$2300,sr
	move.l	old110,$110.w
	move.l	#$707ffff,$ffff8800.w
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	clr.w	-(a7)
	trap	#1
new70	jsr	muzak+8
	rte
old70	ds.l	1
old110	ds.l	1
muzak	incbin	lxs.mus
muz1	equ	muzak+3956	*switch the stars around to play other music (i.e. take the star over here off and put it one line down...)
*muz1	incbin "lxs3.mus" for other muzaks
old9	ds.b	1
oldd	ds.b	1
old15	ds.b	1
old17	ds.b	1
old1d	ds.b	1	