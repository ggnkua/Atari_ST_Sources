
set_falcon_rez	move.w	d0,-(sp)
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp
		rts
