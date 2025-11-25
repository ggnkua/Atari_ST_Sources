	.TEXT

          .globl Floprd
Floprd:
	move.l    A2,-(A7)
	move.w    $000C(A7),-(A7)
	move.w    $000C(A7),-(A7)
	move.w    $000C(A7),-(A7)
	move.w    D2,-(A7)
	move.w    D1,-(A7)
	move.l    D0,-(A7)
	move.l    A0,-(A7)
	move.w    #$0008,-(A7)
	trap	#14
	lea.l     $0014(A7),A7
	movea.l   (A7)+,A2
	rts

	.END

