; ----------------------------------
;	Debout
; ----------------------------------

vbl_impacts	move	last_bt(a3),d0
	beq.s	no_impact
	lsl	#2,d0
	move	energie(a6),d1
	sub	d0,d1
	bpl.s	impct_nrjnot0
	moveq	#0,d1
impct_nrjnot0	move	d1,energie(a6)
	clr	last_bt(a3)
no_impact	
	tst	dn(a6)
	beq.s	impacts_left
	
	sub	#2,xn(a6)
	move	minecrx(a6),d0
	add	#22,d0
	cmp	xn(a6),d0
	bmi.s	impacts_cont
	move	d0,xn(a6)
	bra.s	impacts_cont

impacts_left	add	#2,xn(a6)
	move	maxecrx(a6),d0
	sub	#22,d0
	cmp	xn(a6),d0
	bpl.s	impacts_cont
	move	d0,xn(a6)
impacts_cont
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
	SEQUENCE	seq_cur2(a6),seq_spr2(a6)
	bra	finjoueur
