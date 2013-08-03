; ----------------------------------
;	whirlwind kick
; ----------------------------------

vbl_whirlwind	move	#-1,attack(a6)

	addq.w	#1,seq_cpt(a6)
	move	seq_cpt(a6),d0
	move.l	seq_spr2(a6),a0
	cmp	(a0),d0
	bmi.s	whirl_cont
	clr	seq_cpt(a6)
	add.l	#4,seq_spr2(a6)
	
whirl_cont	move.b	3(a0),d0
	ext	d0
	move	xn(a6),d1
	tst	dn(a6)
	beq.s	whirl_right

whirl_left	add	d0,d1
	move	maxecrx(a6),d0
	sub	#59,d0
	cmp	d0,d1
	bmi.s	whirl_end
	move	d0,d1
	bra.s	whirl_end

whirl_right	sub	d0,d1
	move	minecrx(a6),d0
	add	#59,d0
	cmp	d0,d1
	bpl.s	whirl_end
	move	d0,d1

whirl_end	move	d1,xn(a6)

	move.l	seq_spr(a6),a0
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne	finjoueur
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne	finjoueur
	clr	attack(a6)
	SEQUENCE	#vbl_debout,#debout_rien
	bra	finjoueur
