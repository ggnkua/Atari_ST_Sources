	.TEXT

          .globl Floprate
Floprate:
	move.w    D1,-(A7)
	move.w    D0,-(A7)
	move.w    #$0029,-(A7)
	trap	#14
	addq.l    #6,A7
	rts

	.END

