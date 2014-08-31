	include	rostruct.s
	output	.ro

	text
malloc:	move.l	RO.w2(a0),d7
	tst.l	d0
	beq.s	.nopar
	cmp.l	#1,d0
	bne.s	.abort
	move.l	(a1),d7
.nopar:	move.l	d7,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.w	#6,sp
	bra.s	.end
.abort:	moveq	#-1,d0
.end:	rts

