	.TEXT

          .globl Cconrs
Cconrs:
	move.l    a2,-(sp)
	
	move.l    A0,-(A7)
	move.w    #$000A,-(A7)
	trap	#1
	addq.w    #6,A7
	
	move.l    (sp)+,a2
	rts

	.END

