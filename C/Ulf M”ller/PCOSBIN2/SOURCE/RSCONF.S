	.TEXT

          .globl Rsconf
Rsconf:
	move.l    A2,-(A7)
	move.w    $000C(A7),-(A7)
	move.w    $000C(A7),-(A7)
	move.w    $000C(A7),-(A7)
	move.w    D2,-(A7)
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$000F,-(A7)
	trap	#14
	lea.l     $000E(A7),A7
	movea.l   (A7)+,A2
	rts

	.END

