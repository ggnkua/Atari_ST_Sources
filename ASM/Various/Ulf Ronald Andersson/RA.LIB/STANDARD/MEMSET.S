;----------------------------------------------------------------------------
;File name:	memset.s			Revision date:	2000.07.24
;Revised by:	Ronald Andersson		Revision start:	2000.07.24
;----------------------------------------------------------------------------
memset:
	move.l	a0,-(a7)
	adda.l	d1,a0
	move.l	a0,d2
	btst	#$00,d2
	beq.s	L79FC
	subq.l	#1,d1
	bcs.w	L7AA4
	move.b	d0,-(a0)
L79FC:
	move.b	d0,-(a7)
	move	(a7)+,d2
	move.b	d0,d2
	move	d2,d0
	swap	d2
	move	d0,d2
	move.l	d1,d0
	lsr.l	#8,d0
	lsr.l	#2,d0
	beq.s	L7A88
	movem.l	d1/d3-d7/a2-a6,-(a7)
	move.l	d2,d1
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5
	move.l	d2,d6
	move.l	d2,d7
	movea.l	d2,a1
	movea.l	d2,a2
	movea.l	d2,a3
	movea.l	d2,a4
	movea.l	d2,a5
	movea.l	d2,a6
L7A2C:
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a2,-(a0)
	subq.l	#1,d0
	bne.s	L7A2C
	movem.l	(a7)+,d1/d3-d7/a2-a6
	and	#$03FF,d1
L7A88:
	move	d1,d0
	lsr	#2,d0
	beq.s	L7A96
	subq	#1,d0
L7A90:
	move.l	d2,-(a0)
	dbf	d0,L7A90
L7A96:
	and	#$0003,d1
	beq.s	L7AA4
	subq	#1,d1
L7A9E:
	move.b	d2,-(a0)
	dbf	d1,L7A9E
L7AA4:
	movea.l	(a7)+,a0
	rts
;----------------------------------------------------------------------------
;End of file:	memset.s
;----------------------------------------------------------------------------
