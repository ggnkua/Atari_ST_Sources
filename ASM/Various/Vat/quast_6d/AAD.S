	dc.l	$41fa001c
	dc.l	$43fa0144
	moveq	#0,d0
	moveq	#83,d7
getredy	move.l	(a0)+,d0
	move.l	(a1),d1
	rol.l	#1,d1	;ROL
	add.l	d0,d1	;ADD
	move.l	d1,(a1)+
	dbf	d7,getredy
	dc.l	$6000012e
	incbin	\decode.qst
	incbin	\quast_6d.bin
