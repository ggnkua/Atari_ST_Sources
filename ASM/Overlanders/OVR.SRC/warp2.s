* musiques de warp

	pea	main
	move	#$26,-(sp)
	trap	#14
	lea	6(sp),sp
	
	clr	-(sp)
	trap	#1
	
main	pea	mess
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#2,d0   ; d0=2,3,4,5,6,7,8,10
	bsr.s	musix

	move.l	#musix+8,$4e2.w
	
sync	move	#$25,-(sp)
	trap	#14
	addq.l	#2,sp

	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmp.b	#$3b,D0		'F2' ?
	bls.s	sync2
	cmp.b	#$42,d0		'F8' ?
	bhi.s	sync2
	sub	#$3a,d0
	bsr.s	musix

sync2	cmp.b	#$39,d0		space ?
	bne.s	sync
	
	clr.l	$4e2.w

	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	rts

mess	dc.b	27,'E'
	dc.b	'Musiques de Warp:press F2 to F8',0
	even
musix	incbin	\musics_2\warp2.b
