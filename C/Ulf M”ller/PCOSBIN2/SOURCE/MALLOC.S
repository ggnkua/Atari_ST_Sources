	.TEXT

          .globl Malloc
Malloc:
	move.l    a2,-(sp)
	
	move.l    D0,-(A7)
	move.w    #$0048,-(A7)
	trap	#1
	addq.w    #6,A7
	movea.l   D0,A0
	
	move.l    (sp)+,a2
	rts

	.END

