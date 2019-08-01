;----------------------------------------------------------------------------
;File name:	memcpy.s			Revision date:	2000.07.24
;Revised by:	Ronald Andersson		Revision start:	2000.07.24
;----------------------------------------------------------------------------
memcpy:
	tst.l	d0
	beq.w	L79E6
	move.l	a0,-(a7)
	cmpa.l	a0,a1
	bhi.w	L7902
	beq.w	L79E4
	adda.l	d0,a1
	adda.l	d0,a0
	move	a1,d1
	move	a0,d2
	btst	#$00,d1
	beq.s	L782E
	btst	#$00,d2
	bne.s	L7836
L7824:
	move.b	-(a1),-(a0)
	subq.l	#1,d0
	bne.s	L7824
	bra.w	L79E4

L782E:
	btst	#$00,d2
	bne.s	L7824
	bra.s	L783E

L7836:
	move.b	-(a1),-(a0)
	subq.l	#1,d0
	beq.w	L79E4
L783E:
	move.l	d0,d1
	lsr.l	#5,d1
	lsr.l	#4,d1
	beq.w	L78DC
	movem.l	d2-d7/a3-a6,-(a7)
L784C:
	movem.l	-$0028(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$0050(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$0078(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$00A0(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$00C8(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$00F0(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$0118(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$0140(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$0168(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$0190(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$01B8(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$01E0(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$0200(a1),d2-d7/a3-a4
	movem.l	d2-d7/a3-a4,-(a0)
	suba	#$0200,a1
	subq.l	#1,d1
	bne.w	L784C
	movem.l	(a7)+,d2-d7/a3-a6
L78DC:
	move	d0,d1
	and	#$01FF,d0
	lsr	#2,d0
	beq.s	L78EE
	subq	#1,d0
L78E8:
	move.l	-(a1),-(a0)
	dbf	d0,L78E8
L78EE:
	and	#$0003,d1
	beq.w	L79E4
	subq	#1,d1
L78F8:
	move.b	-(a1),-(a0)
	dbf	d1,L78F8
	bra.w	L79E4

L7902:
	move	a1,d1
	move	a0,d2
	btst	#$00,d1
	beq.s	L791C
	btst	#$00,d2
	bne.s	L7924
L7912:
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bne.s	L7912
	bra.w	L79E4

L791C:
	btst	#$00,d2
	bne.s	L7912
	bra.s	L7928

L7924:
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
L7928:
	move.l	d0,d1
	lsr.l	#5,d1
	lsr.l	#4,d1
	beq.w	L79C4
	movem.l	d2-d7/a3-a6,-(a7)
L7936:
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$0028(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$0050(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$0078(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$00A0(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$00C8(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$00F0(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$0118(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$0140(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$0168(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$0190(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$01B8(a0)
	movem.l	(a1)+,d2-d7/a3-a4
	movem.l	d2-d7/a3-a4,$01E0(a0)
	adda	#$0200,a0
	subq.l	#1,d1
	bne.w	L7936
	movem.l	(a7)+,d2-d7/a3-a6
L79C4:
	move	d0,d1
	and	#$01FF,d0
	lsr	#2,d0
	beq.s	L79D6
	subq	#1,d0
L79D0:
	move.l	(a1)+,(a0)+
	dbf	d0,L79D0
L79D6:
	and	#$0003,d1
	beq.s	L79E4
	subq	#1,d1
L79DE:
	move.b	(a1)+,(a0)+
	dbf	d1,L79DE
L79E4:
	movea.l	(a7)+,a0
L79E6:
	rts
;----------------------------------------------------------------------------
;End of file:	memcpy.s
;----------------------------------------------------------------------------
