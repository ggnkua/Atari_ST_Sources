* overlay module for simple test
.globl	foobz2
.globl	junk2
*
foobz2:	move.l	#mess,d1
	move.w	#9,d0
	trap	#2
	rts
	.data
	.even
mess:	.dc.b	13,10,'THIS IS FOOBAZ2!$'
	.bss
junk2:	.ds.b	1
	.end
