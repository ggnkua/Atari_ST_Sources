	.TEXT

          .globl Pterm0
Pterm0:
	move.w    #$0000,-(A7)
	trap	#1
	
	.END

