	.TEXT

          .globl Fseek
Fseek:
	move.l    a2,-(sp)
	
	move.w    D2,-(A7)
	move.w    D1,-(A7)
	move.l    D0,-(A7)
	move.w    #$0042,-(A7)
	trap	#1
	lea.l     $000A(A7),A7
	
	move.l    (sp)+,a2
	rts

	.END

