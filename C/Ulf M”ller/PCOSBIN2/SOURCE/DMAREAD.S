	.TEXT

          .globl DMAread
DMAread:
	move.l    A2,-(A7)
	move.w    D2,-(A7)
	move.l    A0,-(A7)
	move.w    D1,-(A7)
	move.l    D0,-(A7)
	move.w    #$002A,-(A7)
	trap	#14
	lea.l     $000E(A7),A7
	movea.l   (A7)+,A2
	rts

	.END

