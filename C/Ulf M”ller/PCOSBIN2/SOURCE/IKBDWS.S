	.TEXT

          .globl Ikbdws
Ikbdws:
	move.l    A2,-(A7)
	move.l    A0,-(A7)
	move.w    D0,-(A7)
	move.w    #$0019,-(A7)
	trap	#14
	addq.w    #8,A7
	movea.l   (A7)+,A2
	rts

	.END

