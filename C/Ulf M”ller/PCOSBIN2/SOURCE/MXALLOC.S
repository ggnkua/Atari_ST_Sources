	.TEXT

          .globl Mxalloc
Mxalloc:
	move.l    a2,-(sp)
	
	move.l    D0,-(A7)
	move.w    D1,-(A7)
	move.w    #$0044,-(A7)
	trap	#1
	addq.w    #8,A7
	movea.l   D0,A0
	
	move.l    (sp)+,a2
	rts

	.END

