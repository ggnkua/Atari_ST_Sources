	.TEXT

          .globl Bconout
Bconout:
	move.l    A2,-(A7)
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$0003,-(A7)
	trap	#13
	addq.w    #6,A7
	movea.l   (A7)+,A2
	rts

	.END

