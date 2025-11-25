	.TEXT

          .globl Supexec
Supexec:
	move.l    A2,-(A7)
	move.l    A0,-(A7)
	move.w    #$0026,-(A7)
	trap	#14
	addq.w    #6,A7
	movea.l   (A7)+,A2
	rts

	.END

