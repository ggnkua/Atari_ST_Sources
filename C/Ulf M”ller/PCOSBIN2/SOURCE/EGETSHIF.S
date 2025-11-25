	.TEXT

          .globl Egetshift
Egetshift:
	move.l    A2,-(A7)
	move.w    #$0051,-(A7)
	trap	#14
	addq.l    #2,A7
	movea.l   (A7)+,A2
	rts

	.END

