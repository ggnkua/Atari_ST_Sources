	.TEXT

          .globl Drvmap
Drvmap:
	move.l    A2,-(A7)
	move.w    #$000A,-(A7)
	trap	#13
	addq.w    #2,A7
	movea.l   (A7)+,A2
	rts

	.END

