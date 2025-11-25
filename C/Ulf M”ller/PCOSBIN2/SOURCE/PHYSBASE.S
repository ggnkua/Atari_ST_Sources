	.TEXT

          .globl Physbase
Physbase:
	move.l    A2,-(A7)
	move.w    #$0002,-(A7)
	trap	#14
	addq.w    #2,A7
	movea.l   D0,A0
	movea.l   (A7)+,A2
	rts

	.END

