	.TEXT

          .globl Fdelete
Fdelete:
	move.l    a2,-(sp)
	
	move.l    A0,-(A7)
	move.w    #$0041,-(A7)
	trap	#1
	addq.w    #6,A7
	
	move.l    (sp)+,a2
	rts

	.END

