;----------------------------------------------------------------------------
;File name:	ultoa.s				Revision date:	2000.08.31
;Revised by:	Ronald Andersson		Revision start:	2000.08.31
;----------------------------------------------------------------------------
ultoa_dec:
	moveq	#10,d1
ultoa:
	move.l	d3,-(a7)
	move.l	a0,-(a7)
	suba	#$0022,a7
	move	d1,d2
	subq	#2,d2
	cmp	#$0022,d2
	bhi.s	.L3B52
	lea	$0022(a7),a1
	moveq	#-$01,d2
	move.l	d0,d3
	swap	d3
	tst	d3
	bne.s	.L3B1C
.L3B06:
	divu	d1,d0
	move.l	d0,d3
	swap	d3
	move.b	.X3B5C(pc,d3),-(a1)
	addq	#1,d2
	swap	d0
	clr	d0
	swap	d0
	bne.s	.L3B06
	bra.s	.L3B40
;-------
.L3B1C:
	move	d4,-(a7)
.L3B1E:
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
	move.b	.X3B5C(pc,d3),-(a1)
	addq	#1,d2
	tst.l	d0
	bne.s	.L3B1E
	move	(a7)+,d4
.L3B40:
	move.b	(a1)+,(a0)+
	dbf	d2,.L3B40
.L3B46:
	clr.b	(a0)+
	adda	#$0022,a7
	movea.l	(a7)+,a0
	move.l	(a7)+,d3
	rts
;-------
.L3B52:
	move	#$0021,errno.l
	bra.s	.L3B46
;-------
.X3B5C:
	dc.b	'0123456789abcdefghijklmnopqrstuvwxyz'
;----------------------------------------------------------------------------
;End of file:	ultoa.s
;----------------------------------------------------------------------------
