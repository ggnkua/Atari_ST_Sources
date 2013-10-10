Main
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp
	movec cacr,d0
	move.l	#$3111,d0
	movec d0,cacr
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp
	move.w	#0,-(sp)
	trap	#1