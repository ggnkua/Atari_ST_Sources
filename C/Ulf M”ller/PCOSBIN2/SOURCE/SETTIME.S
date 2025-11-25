	.TEXT

          .globl Settime
Settime:
	move.l    A2,-(A7)
	move.l    D0,-(A7)
	move.w    #$0016,-(A7)
	trap	#14
	addq.w    #6,A7
	movea.l   (A7)+,A2
	rts

	.END

