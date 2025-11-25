	.TEXT

          .globl Funlock
Funlock:
	move.l    a2,-(sp)
	
	move.w    D0,-(A7)
	move.w    #$0065,-(A7)
	trap	#1
	addq.l    #4,A7
	
	move.l    (sp)+,a2
	rts

	.END

