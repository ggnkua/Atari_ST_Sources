	clr.w	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	#$752019f3,$420.w
	clr.l	$426
	clr.l	$42a
	move.l	$4.w,a0
	jmp	(a0)
