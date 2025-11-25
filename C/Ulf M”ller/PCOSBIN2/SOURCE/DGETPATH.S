	.TEXT

          .globl Dgetpath
Dgetpath:
	move.l    a2,-(sp)
	
	move.w    D0,-(A7)
	move.l    A0,-(A7)
	move.w    #$0047,-(A7)
	trap	#1
	addq.w    #8,A7
	
	move.l    (sp)+,a2
	rts

	.END

