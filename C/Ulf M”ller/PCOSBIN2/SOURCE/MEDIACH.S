	.TEXT

          .globl Mediach
Mediach:
	move.l    A2,-(A7)
	move.w    D0,-(A7)
	move.w    #$0009,-(A7)
	trap	#13
	addq.w    #4,A7
	movea.l   (A7)+,A2
	rts

	.END

