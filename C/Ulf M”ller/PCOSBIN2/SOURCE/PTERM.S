	.TEXT

          .globl Pterm
Pterm:
	move.l    a2,-(sp)
	
	move.w    D0,-(A7)
	move.w    #$004C,-(A7)
	trap	#1

	.END

