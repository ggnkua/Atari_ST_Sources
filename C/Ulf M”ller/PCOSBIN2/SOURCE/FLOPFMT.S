	.TEXT

          .globl Flopfmt
Flopfmt:
	move.l    A2,-(A7)
	move.w    $0012(A7),-(A7)
	move.l    $0010(A7),-(A7)
	move.w    $0012(A7),-(A7)
	move.w    $0012(A7),-(A7)
	move.w    $0012(A7),-(A7)
	move.w    D2,-(A7)
	move.w    D1,-(A7)
	move.l    D0,-(A7)
	move.l    A0,-(A7)
	move.w    #$000A,-(A7)
	trap	#14
	lea.l     $001A(A7),A7
	movea.l   (A7)+,A2
	rts

	.END

