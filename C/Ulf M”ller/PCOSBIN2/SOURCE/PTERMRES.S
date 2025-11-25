	.TEXT

          .globl Ptermres
Ptermres:
	move.w    D1,-(A7)
	move.l    D0,-(A7)
	move.w    #$0031,-(A7)
	trap	#1

	.END

