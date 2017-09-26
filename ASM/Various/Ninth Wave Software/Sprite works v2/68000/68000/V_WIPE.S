;
; ~C:v_wipe%(barwidth,L:source,L:destination)
;	
v_wipe	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7
	beq	.our
	movem.l	62(a7),a0-1
	move	#31840,d1
	moveq	#0,d2
	moveq	#24,d5
.mainlp	movem.l	a0-1,-(a7)
	moveq	#20,d3
	move	d7,d6
.lpa	movem.l	a0-1,-(a7)
	lea	(a1,d1),a3
	move	#192-1,d0
	lea	30560(a0),a0
	lea	1280(a0),a2
.lp1	move.l	(a0)+,(a2)+
	move.l	(a0),(a2)
	lea	-164(a0),a0
	lea	-164(a2),a2
	dbf	d0,.lp1
	moveq	#8-1,d0
.lp2	move.l	(a3)+,(a2)+
	move.l	(a3),(a2)
	lea	-164(a3),a3
	lea	-164(a2),a2
	dbf	d0,.lp2	
	movem.l	(a7)+,a0-1
	addq	#8,a0
	addq	#8,a1
	subq	#1,d3
	beq.s	.end
	subq	#1,d6
	bgt.s	.lpa
	move	d7,d6

.lpb	movem.l	a0-1,-(a7)
	lea	(a1,d2),a3
	move	#192-1,d0
	lea	1280(a0),a2
.lp3	move.l	(a2)+,(a0)+
	move.l	(a2),(a0)
	lea	156(a0),a0
	lea	156(a2),a2
	dbf	d0,.lp3
	moveq	#8-1,d0
.lp4	move.l	(a3)+,(a0)+
	move.l	(a3),(a0)
	lea	156(a0),a0
	lea	156(a3),a3
	dbf	d0,.lp4
	movem.l	(a7)+,a0-1
	addq	#8,a0
	addq	#8,a1
	subq	#1,d3
	beq.s	.end
	subq	#1,d6
	bgt.s	.lpb
	move	d7,d6
	bra	.lpa
.end	movem.l	(a7)+,a0-1
	sub	#1280,d1
	add	#1280,d2
	dbf	d5,.mainlp
.our	movem.l	(a7)+,d1-7/a0-6
	rts
