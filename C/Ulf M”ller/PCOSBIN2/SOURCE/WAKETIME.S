	.TEXT

          .globl Waketime
Waketime:
	move.l    A2,-(A7)
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$002f,-(A7)
	trap	#14
	addq.w    #6,A7
	movea.l   (A7)+,A2
	rts

	.END

