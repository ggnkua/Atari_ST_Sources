	.TEXT

          .globl Cauxout
Cauxout:
	move.l    a2,-(sp)
	
	move.w    D0,-(A7)
	move.w    #$0004,-(A7)
	trap	#1
	addq.w    #4,A7
	
	move.l    (sp)+,a2
	rts

	.END

