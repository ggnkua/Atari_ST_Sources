	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	
	move.l	#$752019f3,$420.w
	move.l	$4.w,a0
	jmp	(a0)