	output	.ro

	text

malloc:
	move.l	window_2(a0),d7
	tst.l	d0
	beq.s	.no_params
	cmp.l	#1,d0
	bne.s	.abort
	move.l	(a1),d7
.no_params:
	move.l	d7,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.w	#6,sp
	bra.s	.end
.abort:
	moveq	#-1,d0
.end:
	rts

	include	rostruct.s
