	.TEXT

          .globl Keytbl
Keytbl:
	move.l    A2,-(A7)
	move.l    $0008(A7),-(A7)
	move.l    A1,-(A7)
	move.l    A0,-(A7)
	move.w    #$0010,-(A7)
	trap	#14
	lea.l     $000E(A7),A7
	movea.l   D0,A0
	movea.l   (A7)+,A2
	rts

	.END

