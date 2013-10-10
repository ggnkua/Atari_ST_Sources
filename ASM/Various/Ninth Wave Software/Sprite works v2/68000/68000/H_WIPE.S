;
; ~C:h_wipe%(barheight,L:source,L:destination)
;
h_wipe	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7
	beq	.our
	movem.l	62(a7),a0-1
	moveq	#19,d5
	move	#156,d1		; right margin
	moveq	#0,d2		; left margin
.mainlp	movem.l	d7/a0-1,-(a7)
	move	#200,d6
	sub	d7,d6
.lp	move	d7,-(a7)
	subq	#1,d7
.lp2	lea	156(a0),a0
	moveq	#38-1,d0
.lp1	move.l	-8(a0),(a0)
	subq	#4,a0
	dbf	d0,.lp1
	subq	#4,a0
	move.l	(a1,d1),4(a0)
	move.l	-4(a1,d1),(a0)
	lea	160(a0),a0
	lea	160(a1),a1
	dbf	d7,.lp2
	move	(a7)+,d7
	tst	d6
	beq.s	.end
	sub	d7,d6
	bgt.s	.ok1
	add	d6,d7
	clr	d6
.ok1	move	d7,-(a7)
	subq	#1,d7
.lp4	moveq	#38-1,d0
.lp3	move.l	8(a0),(a0)+
	dbf	d0,.lp3
	move.l	(a1,d2),(a0)+
	move.l	4(a1,d2),(a0)+
	lea	160(a1),a1
	dbf	d7,.lp4
	move	(a7)+,d7
	tst	d6
	beq.s	.end
	sub	d7,d6
	bgt.s	.ok2
	add	d6,d7
	clr	d6
.ok2	bra.s	.lp
.end	movem.l	(a7)+,d7/a0-1
	subq	#8,d1
	addq	#8,d2
	dbf	d5,.mainlp
.our	movem.l	(a7)+,d1-7/a0-6
	rts
