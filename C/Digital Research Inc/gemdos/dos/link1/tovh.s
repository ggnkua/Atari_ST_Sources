
* overlay module for simple test
.globl	foobaz
.globl	junk
*
foobaz:	move.l	#mess,d1
	move.w	#9,d0
	trap	#2
	rts
	.data
	.even
mess:	.dc.b	13,10,'THIS IS FOOBAZ!$'
	.bss
junk:	.ds.b	1
	.end
