	.TEXT

          .globl Unlock
Unlock:
	move.l    a2,-(sp)
	
	move.l    A0,-(A7)
	move.w    #$007B,-(A7)
	trap	#1
	addq.l    #6,A7
	
	move.l    (sp)+,a2
	rts

	.END

