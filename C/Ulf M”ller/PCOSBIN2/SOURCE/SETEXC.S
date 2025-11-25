	.TEXT

          .globl Setexc
Setexc:
	move.l    A2,-(A7)
	move.l    A0,-(A7)
	move.w    D0,-(A7)
	move.w    #$0005,-(A7)
	trap	#13
	addq.w    #8,A7
	movea.l   D0,A0
	movea.l   (A7)+,A2
	rts

	.END

