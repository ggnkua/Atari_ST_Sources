	.TEXT

          .globl Rwabs
Rwabs:
	move.l    A2,-(A7)
	move.w    $0008(A7),-(A7)
	move.w    D2,-(A7)
	move.w    D1,-(A7)
	move.l    A0,-(A7)
	move.w    D0,-(A7)
	move.w    #$0004,-(A7)
	trap	#13
	lea.l     $000E(A7),A7
	movea.l   (A7)+,A2
	rts

	.END

