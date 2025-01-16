;
;	5 of the latest C64-conversions from TAO of ACF
;
;       Thanks a lot Jacky ! and sorry for our "non-use".
;
;                                        DEAF KLF/MV/AMAZINE !

	pea	0.w
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#1,d0
	bsr	music

	move.l	#music+8,$4d2.w

	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.l	$4d2.w

	moveq	#0,d0
	bsr	music

	move.b	#7,$484.w

	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr	-(sp)
	trap #1

music:
	incbin	BONUS\TAO_ACF\MANIACS.MUS
	;incbin	BONUS\TAO_ACF\PREMIX.MUS
	;incbin	BONUS\TAO_ACF\SLEEP.MUS
	;incbin	BONUS\TAO_ACF\ZOOLOOK.MUS
	;incbin	BONUS\TAO_ACF\ENDTHEME.MUS
	even