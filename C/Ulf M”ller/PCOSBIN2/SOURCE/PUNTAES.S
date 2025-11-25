	.TEXT

          .globl Puntaes
Puntaes:
	move.l    A2,-(A7)
	move.w    #$0027,-(A7)
	trap	#14
	addq.w    #2,A7
	movea.l   (A7)+,A2
	rts

	.END

