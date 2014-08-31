	;CLRREGS routine for Adebug
	;clears all registers, reset SR and PC
	output	.ro
	include	rostruct.s
clrregs:
	lea	RO.d0_reg(a0),a2
	moveq	#17-1,d1
.l1:	clr.l	(a2)+
	dbf	d1,.l1
	move.w	#$310,RO.sr_reg(a0)
	move.l	RO.text(a0),RO.pc_reg(a0)
	rts

