;----------------------------------------------------------------------------
;File name:	itoa.s				Revision date:	2000.08.31
;Revised by:	Ronald Andersson		Revision start:	2000.08.31
;----------------------------------------------------------------------------
itoa_dec:
	moveq	#10,d1
itoa:
	move.l	d3,-(a7)
	move.l	a0,-(a7)
	lea	-$0012(a7),a7
	move	d1,d2
	subq	#2,d2
	cmp	#$0022,d2
	bhi.s	.L3586
	tst	d0
	bpl.s	.L3554
	cmp.b	#$0A,d1
	bne.s	.L3554
	neg	d0
	move.b	#$2D,(a0)+
.L3554:
	lea	$0012(a7),a1
	moveq	#-$01,d2
	swap	d0
	clr	d0
	swap	d0
.L3560:
	divu	d1,d0
	move.l	d0,d3
	swap	d3
	move.b	.X3590(pc,d3),-(a1)
	addq	#1,d2
	swap	d0
	clr	d0
	swap	d0
	bne.s	.L3560
.L3574:
	move.b	(a1)+,(a0)+
	dbf	d2,.L3574
.L357A:
	clr.b	(a0)+
	lea	$0012(a7),a7
	movea.l	(a7)+,a0
	move.l	(a7)+,d3
	rts
;-------
.L3586:
	move	#$0021,errno.l
	bra.s	.L357A
;-------
.X3590:
	dc.b	'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
;----------------------------------------------------------------------------
;End of file:	itoa.s
;----------------------------------------------------------------------------
