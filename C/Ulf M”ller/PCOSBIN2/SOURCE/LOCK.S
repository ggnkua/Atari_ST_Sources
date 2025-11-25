	.TEXT

          .globl Lock
Lock:
	move.l    a2,-(sp)
	
	move.l    A0,-(A7)
	move.w    #$007C,-(A7)
	trap	#1
	addq.l    #6,A7
	
	move.l    (sp)+,a2
	rts


	.END

