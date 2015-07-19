;
; d0
; d1
; d2
; d3
; d4
;
make_table2
	move	#NC*2,avail_mt

	move	#1<<12-1,d1
	moveq	#0,d0
	lea	c_table(pc),a0
.stos	move	d0,(a0)+
	dbra	d1,.stos

	moveq	#0,d4
	move	#$8000,d1
	moveq	#1,d3
.do200
	lea	c_len(pc),a4
	moveq	#NC-1,d2
.do2
	cmp.b	(a4)+,d3
	dbeq	d2,.do2
	bne	.mt1

	moveq	#NC+1,d0	;d0=NC-d2+1
	sub	d2,d0

	move	d2,-(sp)
	pea	(a4)
;
; d1=weight
; d4=code
; d3=len
;
	move	d4,d5
	lsr	#4,d5
	add	d5,d5
	lea	c_table(pc),a4
	add	d5,a4

	move	d1,-(sp)

	cmp	#12,d3
	bhi.s	.loc1
	lsr	#4,d1
	BEQ	BUG
	subq	#1,d1
.stosw1	move	d0,(a4)+
	dbra	d1,.stosw1
	bra.s	.loc2
.loc1
;
; a4=taddr
; d0=char
;
	move	d4,-(sp)
	move	#12,d2
	asl	d2,d4

	neg	d2
	add	d3,d2
	BEQ	BUG
	subq	#1,d2
.do3
	move	(a4),d1
	bne.s	.loo
	move	avail_mt(pc),d1
	lea	right(pc),a0
	clr	(a0,d1.w)
	lea	left(pc),a0
	clr	(a0,d1.w)

	move	d1,(a4)
	addq	#2,avail_mt
.loo
	lea	left(pc),a4
	ADD	D4,D4
	bcc.s	.noc1
	lea	right(pc),a4
.noc1
	add	d1,a4

	dbra	d2,.do3
	move	d0,(a4)

	move	(sp)+,d4
.loc2
	move	(sp)+,d1
	move.l	(sp)+,a4
	move	(sp)+,d2
	add	d1,d4
	bcs.s	.mt2

	dbra	d2,.do2
.mt1:
	addq	#1,d3
	lsr	#1,d1
	bcc	.do200
.mt2:
	rts
