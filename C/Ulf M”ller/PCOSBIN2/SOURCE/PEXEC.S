	.TEXT

          .globl Pexec
Pexec:
	move.l    a2,-(sp)
	
	move.l    $0008(A7),-(A7)
	move.l    A1,-(A7)
	move.l    A0,-(A7)
	move.w    D0,-(A7)
	move.w    #$004B,-(A7)
	trap	#1
	lea.l     $0010(A7),A7
	
	move.l    (sp)+,a2
	rts


	.END

