	.TEXT

          .globl EgetPalette
EgetPalette:
	move.l    A2,-(A7)
	move.l    A0,-(A7)
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$0055,-(A7)
	trap	#14
	lea.l     $000A(A7),A7
	movea.l   (A7)+,A2
	rts

	.END

