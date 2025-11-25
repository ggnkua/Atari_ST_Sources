	.TEXT

          .globl Maddalt
Maddalt:
	move.l    a2,-(sp)
	
	move.l    A0,-(A7)
	move.l    D0,-(A7)
	move.w    #$0014,-(A7)
	trap	#1
	lea.l     $000A(A7),A7
	
	move.l    (sp)+,a2
	rts

	.END

