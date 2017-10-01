
* driver for simple overlay test
.globl	tmain
.xdef	foobaz
.xdef	foobz2
*
tmain:	move.l	#before,d1
	move.w	#9,d0
	trap	#2
	jsr	foobaz
	move.l	#after,d1
	move.w	#9,d0
	trap	#2
*
	move.l	#bef2,d1
	move.w	#9,d0
	trap	#2
	jsr	foobz2
	move.l	#aft2,d1
	move.w	#9,d0
	trap	#2
	jsr	foobaz
	jsr	foobz2
	jsr	foobaz
	jsr	foobz2
	rts
*
	.data
	.even
before:	.dc.b	13,10,'CALLING FOOBAZ$'
after:	.dc.b	13,10,'BACK FROM FOOBAZ$'
bef2:	.dc.b	13,10,'CALLING FOOBAZ2$'
aft2:	.dc.b	13,10,'BACK FROM FOOBAZ2$'
	.end
