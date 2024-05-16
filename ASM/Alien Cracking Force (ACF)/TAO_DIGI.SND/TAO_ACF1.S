; Musics done by TAO of ACF
; with some C64-conversions...

	pea	0.w
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#0,d0
	bsr	music

	move.l	#music+8,$4d2.w

	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.l	$4d2.w

	moveq	#1,d0
	bsr	music

	move.b	#7,$484.w

	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap #1

music:
	incbin	SPELL.MUS
	;incbin	CATS.MUS
	;incbin	MASTER.MUS
	even