	XDEF	wait_key
wait_key
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts