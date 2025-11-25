	.TEXT

          .globl Scrdmp
Scrdmp:
	move.l    A2,-(A7)
	move.w    #$0014,-(A7)
	trap	#14
	addq.w    #2,A7
	movea.l   (A7)+,A2
	rts

	.END

