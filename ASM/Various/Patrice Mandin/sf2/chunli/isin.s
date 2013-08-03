; ----------------------------------
;	En arriere
; ----------------------------------

vbl_impact_sin	move	last_bt(a3),d0
	beq.s	no_impact_sin
	lsl	#1,d0
	move	energie(a6),d1
	sub	d0,d1
	bpl.s	impsin_nrjnot0
	moveq	#0,d1
impsin_nrjnot0	move	d1,energie(a6)
	clr	last_bt(a3)
no_impact_sin	
	tst	saut(a6)
	beq.s	impactsin
	addq	#1,seq_cpt(a6)   ; prise
	cmp	#20,seq_cpt(a6)
	bmi.s	impactsi_seq
	clr	saut(a6)
	clr	seq_cpt(a6)
	
impactsin	cmp	#64*2,seq_cpt(a6) ; fauchage
	bpl.s	impactsi_seq
	
impactsi_prise	tst	dn(a6)
	beq.s	impactsi_left
	
	sub	#2,xn(a6)
	move	minecrx(a6),d0
	add	#22,d0
	cmp	xn(a6),d0
	bmi.s	impactsi_cont
	move	d0,xn(a6)
	bra.s	impactsi_cont

impactsi_left	add	#2,xn(a6)
	move	maxecrx(a6),d0
	sub	#22,d0
	cmp	xn(a6),d0
	bpl.s	impactsi_cont
	move	d0,xn(a6)

impactsi_cont	lea	sinus3,a0
	add	seq_cpt(a6),a0
	move.b	(a0),d0
	asr.b	#1,d0
	ext	d0
	add	d0,yn(a6)
	addq.w	#2*2,seq_cpt(a6)
	move	yn(a6),d0
	bra.s	impactsi_seq1

impactsi_seq	move	yn(a6),d0
	addq	#2,d0
impactsi_seq1	cmp	#base_y,d0
	bmi.s	impactsi_seq2
	move	#base_y,d0
impactsi_seq2	move	d0,yn(a6)

	move.l	seq_spr(a6),a0	; continue debout
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne	finjoueur
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne	finjoueur
	SEQUENCE	#vbl_baisse,#baisse+8
	move	#base_y,yn(a6)
	bra	finjoueur
