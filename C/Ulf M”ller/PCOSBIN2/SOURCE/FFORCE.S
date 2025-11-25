	.TEXT

          .globl Fforce
Fforce:
	move.l    a2,-(sp)
	
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$0046,-(A7)
	trap	#1
	addq.w    #6,A7
	
	move.l    (sp)+,a2
	rts

	.END

