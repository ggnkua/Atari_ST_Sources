********* Zufallszahl erzeugen ************

random:		movem.l	d7/a0,-(sp)
		move.w	#$11,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d7/a0
		rts
	
