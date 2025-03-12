	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	lea	$FFFF8930.w,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2


	clr.w	-(sp)
	trap	#1

