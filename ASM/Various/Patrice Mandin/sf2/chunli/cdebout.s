; ----------------------------------
;	debout
; ----------------------------------

vbl_coups	move	#-1,attack(a6)

;	On se fait taper ?
; si il y a collision entre les deux joueurs
; et si lui fait un certain coup

	tst	touche(a6)
	bne	coupsd_sequence

	tst	collision(a6)
	beq.s	coupsd_sequence
	SEQUENCE2	#vbl_debout,#debout_rien

	move	xn(a3),d0
	sub	xn(a6),d0
	bpl.s	coupsd_imp1	; le joueur doit frapper
	tst	dn(a3)	; en ‚tant tourn‚ vers
	bne.s	coupsd_impact	; l'autre joueur
	bra.s	coupsd_sequence
coupsd_imp1	tst	dn(a3)
	bne.s	coupsd_sequence	
	
coupsd_impact	move.l	seq_spr(a3),a0 ; autre joueur
	btst.b	#5,4(a0)	; frappe milieu ?
	beq.s	coupsd_ihaut
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_debmilieu
	move	#-1,touche(a6)
	bra	finjoueur
coupsd_ihaut	btst.b	#4,4(a0)	; frappe haut ?
	beq.s	coupsd_sequence
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_debhaut
	move	#-1,touche(a6)
	bra	finjoueur

;	Coups

coupsd_sequence	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	coups_nolk
	clr.b	(a0)
	addq.w	#1,seq_cpt(a6)
	move.l	#lowspeedkick,seq_spr2(a6)
	bra.s	coups_cont
coups_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	coups_nomk
	clr.b	(a0)
	addq.w	#1,seq_cpt(a6)
	move.l	#midspeedkick,seq_spr2(a6)
	bra.s	coups_cont
coups_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq	coups_cont
	clr.b	(a0)
	addq.w	#1,seq_cpt(a6)
	move.l	#higspeedkick,seq_spr2(a6)

;	Sequence

coups_cont	move.l	seq_spr(a6),a0
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
	cmp	#2,seq_cpt(a6)
	bmi	finjoueur
	clr	seq_cpt(a6)
	SEQUENCE	#vbl_coups,seq_spr2(a6)
	SAMPLE	speed
	bra	finjoueur
