	.TEXT

          .globl Kbshift
Kbshift:
	move.l    A2,-(A7)
	move.w    D0,-(A7)
	move.w    #$000B,-(A7)
	trap	#13
	addq.w    #4,A7
	movea.l   (A7)+,A2
	rts

	.END

