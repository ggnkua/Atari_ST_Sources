	.TEXT

          .globl Fsnext
Fsnext:
	move.l    a2,-(sp)
	
	move.w    #$004F,-(A7)
	trap	#1
	addq.w    #2,A7
	
	move.l    (sp)+,a2
	rts

	.END

