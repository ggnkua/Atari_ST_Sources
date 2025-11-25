	.TEXT

          .globl Fgetdta
Fgetdta:
	move.l    a2,-(sp)
	
	move.w    #$002F,-(A7)
	trap	#1
	addq.w    #2,A7
	movea.l   D0,A0
	
	move.l    (sp)+,a2
	rts

	.END

