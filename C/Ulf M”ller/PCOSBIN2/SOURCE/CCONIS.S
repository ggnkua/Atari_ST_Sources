	.TEXT

          .globl Cconis
Cconis:
	move.l    a2,-(sp)
	  
	move.w    #$000B,-(A7)
	trap	#1
	addq.w    #2,A7
	
	move.l    (sp)+,a2
	rts

	.END

