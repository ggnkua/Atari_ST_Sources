

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	lea	zik+$43a56-$3ff8a,a6
	lea	zik+$3ff8a-$3ff8a,a4
	jsr	zik+$4474e-$3ff8a

	move.l	$4d2.w,$200.w

	move.l	a6,$4d2.w


main:	move.w	#$555,$ffff8240	

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#$000,$ffff8240
	
	move.w	#2000,d0
stb	nop
	dbra	d0,stb
	
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main


	move.l	$200.w,$4d2.w

	clr.l	-(sp)
	trap	#1
	

zik:	incbin	zikos.mus