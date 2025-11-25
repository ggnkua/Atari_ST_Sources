	.TEXT

          .globl Tgetdate
Tgetdate:
	move.l    a2,-(sp)
	
	move.w    #$002A,-(A7)
	trap	#1
	addq.w    #2,A7
	
	move.l    (sp)+,a2
	rts

	.END

