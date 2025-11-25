	.TEXT

          .globl Frunlock
Frunlock:
	move.l    a2,-(sp)
	
	move.l    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$0063,-(A7)
	trap	#1
	addq.l    #8,A7
	
	move.l    (sp)+,a2
	rts

	.END

