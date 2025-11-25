	.TEXT

          .globl Iorec
Iorec:
	move.l    A2,-(A7)
	move.w    D0,-(A7)
	move.w    #$000E,-(A7)
	trap	#14
	addq.w    #4,A7
	movea.l   D0,A0
	movea.l   (A7)+,A2
	rts

	.END

