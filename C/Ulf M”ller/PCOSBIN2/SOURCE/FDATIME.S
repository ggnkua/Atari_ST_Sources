	.TEXT

          .globl Fdatime
Fdatime:
	move.l    a2,-(sp)
	
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.l    A0,-(A7)
	move.w    #$0057,-(A7)
	trap	#1
	lea.l     $000A(A7),A7
	
	move.l    (sp)+,a2
	rts

	.END

