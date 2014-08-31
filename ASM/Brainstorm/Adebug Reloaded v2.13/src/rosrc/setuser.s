	output	.ro

	cmp.w	#1,d0
	bne.s	.error
;user vector #
	move.l	(a1),a0
	add.l	#$100,a0
	move.l	$78.w,(a0)
	moveq	#-1,d0
	bra.s	.end
.error:
	moveq	#0,d0
.end:
	rts
