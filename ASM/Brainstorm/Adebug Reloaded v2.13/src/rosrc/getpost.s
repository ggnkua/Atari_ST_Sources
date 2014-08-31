	;GETPOST routine for Adebug
	;get all POST MORTEM information
	include	rostruct.s
	output	.ro
clrregs:
	lea	$380.w,a3
	moveq	#0,d0
	cmp.l	#$12345678,(a3)+
	bne.s	.end
	lea	RO.d0_reg(a0),a2
	moveq	#15-1,d1
.l1:	move.l	(a3)+,(a2)+
	dbf	d1,.l1
	move.l	(a3)+,RO.ssp_reg(a0)
	addq.w	#4,a3
	move.l	(a3)+,RO.a7_reg(a0)
	moveq	#-1,d0
.end:	rts

