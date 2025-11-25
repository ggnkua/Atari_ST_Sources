	.TEXT

          .globl Xbtimer
Xbtimer:
	move.l    A2,-(A7)
	move.l    A0,-(A7)
	move.w    D2,-(A7)
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$001F,-(A7)
	trap	#14
	lea.l     $000C(A7),A7
	movea.l   (A7)+,A2
	rts

	.END

