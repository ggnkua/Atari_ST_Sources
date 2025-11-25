	.TEXT

          .globl Bconmap
Bconmap:
	move.l    A2,-(A7)
	move.w    D0,-(A7)
	move.w    #$002C,-(A7)
	trap	#14
	addq.l    #4,A7
	movea.l   (A7)+,A2
	rts

	.END

