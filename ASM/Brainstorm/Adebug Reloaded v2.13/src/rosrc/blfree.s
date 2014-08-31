	include	rostruct.s
	output	.ro

	text
block_free:
	move.l	(a1),d1
	tst.l	d0
	bne.s	.param
	move.l	RO.w3(a0),d1
.param:	move.l	d1,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.w	#6,sp
	rts
