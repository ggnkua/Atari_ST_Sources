;----------------------------------------------------------------------------
;File name:	ltoa.s				Revision date:	2000.08.31
;Revised by:	Ronald Andersson		Revision start:	2000.08.31
;----------------------------------------------------------------------------
ltoa_dec:
	moveq	#10,d1
ltoa:
	move.l	d3,-(a7)
	move.l	a0,-(a7)
	suba	#$0022,a7
	move	d1,d2
	subq	#2,d2
	cmp	#$0022,d2
	bhi.s	.L3630
	tst.l	d0
	bpl.s	.L35D6
	cmp.b	#$0A,d1
	bne.s	.L35D6
	move.b	#$2D,(a0)+
	neg.l	d0
.L35D6:
	lea	$0022(a7),a1
	moveq	#-$01,d2
	move.l	d0,d3
	swap	d3
	tst	d3
	bne.s	.L35FA
.L35E4:
	divu	d1,d0
	move.l	d0,d3
	swap	d3
	move.b	.X363A(pc,d3),-(a1)
	addq	#1,d2
	swap	d0
	clr	d0
	swap	d0
	bne.s	.L35E4
	bra.s	.L361E
;-------
.L35FA:
	move	d4,-(a7)
.L35FC:
	move.l	d0,d3
	move	d0,d4
	clr	d3
	swap	d3
	divu	d1,d3
	move	d3,d0
	move	d4,d3
	divu	d1,d3
	swap	d0
	move	d3,d0
	swap	d3
	move.b	.X363A(pc,d3),-(a1)
	addq	#1,d2
	tst.l	d0
	bne.s	.L35FC
	move	(a7)+,d4
.L361E:
	move.b	(a1)+,(a0)+
	dbf	d2,.L361E
.L3624:
	clr.b	(a0)+
	adda	#$0022,a7
	movea.l	(a7)+,a0
	move.l	(a7)+,d3
	rts
;-------
.L3630:
	move	#$0021,errno.l
	bra.s	.L3624
;-------
.X363A:
	dc.b	'0123456789abcdefghijklmnopqrstuvwxyz'
;----------------------------------------------------------------------------
;End of file:	ltoa.s
;----------------------------------------------------------------------------
