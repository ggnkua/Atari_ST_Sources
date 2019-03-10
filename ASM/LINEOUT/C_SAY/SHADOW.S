	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1

	clr.l	d0
	lea	$FFFF8800.w,a0
	movep.l	d0,(a0)

	clr.w	-(sp)
	trap	#1
	