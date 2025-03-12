		move.w	#10000,d6
wait		move.w	#11,-(sp)
		trap	#1
		addq.w	#2,sp
		tst.l	d0
		bmi.s	.yes
		sub.w	#1,d6
		bne.s	wait
		bra	.over
.yes		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
.over
