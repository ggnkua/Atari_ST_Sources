	.TEXT

          .globl Getmpb
Getmpb:
	move.l    A2,-(A7)
	move.l    A0,-(A7)
	move.w    #$0000,-(A7)
	trap	#13
	addq.w    #6,A7
	movea.l   (A7)+,A2
	rts

	.END

