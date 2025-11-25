	.TEXT

          .globl Nversion
Nversion:
	move.l    a2,-(sp)
	
	move.w    #$0060,-(A7)
	trap	#1
	addq.l    #2,A7
	
	move.l    (sp)+,a2
	rts

	.END

