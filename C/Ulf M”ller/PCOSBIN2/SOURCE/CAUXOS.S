	.TEXT

          .globl Cauxos
Cauxos:
	move.l    a2,-(sp)
	
	move.w    #$0013,-(A7)
	trap	#1
	addq.w    #2,A7
	
	move.l    (sp)+,a2
	rts

	.END

