	.TEXT

          .globl Esetshift
Esetshift:
	move.l    A2,-(A7)
	move.w    D0,-(A7)
	move.w    #$0050,-(A7)
	trap	#14
	addq.l    #4,A7
	movea.l   (A7)+,A2
	rts

	.END

