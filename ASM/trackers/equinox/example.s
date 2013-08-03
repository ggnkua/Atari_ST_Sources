;------------------------------------------------
;----- Example for using the playroutine --------
;------------------------------------------------


	clr.l	-(sp)
	move.W	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.b	$fffa09
	lea	zic,a0
	jsr	play
	move.l	$70,-(sp)
	move.l	#vbl,$70
att	cmp.b	#$39,$fffc02
	bne	att
	move.w	#$2700,sr
	move.l	(sp)+,$70
	jsr	play+8
	move.b	#$64,$fffa09
	move.W	#$2300,sr
	move	#4000,d0
wait_mfp	
	nop
	dbra	d0,wait_mfp
	clr.w	-(sp)
	trap	#1

vbl
	jsr	play+4
	rte

play	incbin	player.bin
zic	incbin	v42
	even




