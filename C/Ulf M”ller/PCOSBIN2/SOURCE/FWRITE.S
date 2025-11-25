	.TEXT

          .globl Fwrite
Fwrite:
	move.l    a2,-(sp)
	
	move.l    A0,-(A7)
	move.l    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$0040,-(A7)
	trap	#1
	lea.l     $000C(A7),A7
	
	move.l    (sp)+,a2
	rts

	.END

