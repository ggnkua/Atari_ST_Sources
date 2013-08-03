; ----------------------------------
;	releve	OK
; ----------------------------------

vbl_releve	cmp	#2*50,seq_cpt(a6)
	bmi	releve_down
	btst.b	#0,(a5)	; up ?
	beq	releve_down
	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	releve_nolk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	move.l	#lowwhirltab,seq_spr2(a6)
	SEQUENCE	#vbl_whirlwind,#lowwhirlwind
	SAMPLE	whirlwind
	bra	finjoueur
releve_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	releve_nomk
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	move.l	#midwhirltab,seq_spr2(a6)
	SEQUENCE	#vbl_whirlwind,#midwhirlwind
	SAMPLE	whirlwind
	bra	finjoueur
releve_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq.s	releve_down
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	move.l	#higwhirltab,seq_spr2(a6)
	SEQUENCE	#vbl_whirlwind,#higwhirlwind
	SAMPLE	whirlwind
	bra	finjoueur
	
releve_down	btst.b	#1,(a5)	; down ?
	beq.s	releve_cont
	SEQUENCE	#vbl_baisse,#baisse
	bra	finjoueur
releve_cont	

;	On se fait taper ?

	tst	touche(a6)
	bne	releve_sequence

	tst	collision(a6)
	beq.s	releve_sequence
	SEQUENCE2	#vbl_debout,#debout_rien

	move	xn(a3),d0
	sub	xn(a6),d0
	bpl.s	releve_imp1	; le joueur doit frapper
	tst	dn(a3)	; en ‚tant tourn‚ vers
	bne.s	releve_impact	; l'autre joueur
	bra.s	releve_sequence
releve_imp1	tst	dn(a3)
	bne.s	releve_sequence	
	
releve_impact	move.l	seq_spr(a3),a0 ; autre joueur
	btst.b	#5,4(a0)	; frappe milieu ?
	beq.s	releve_sequence
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_bas
	move	#-1,touche(a6)
	SAMPLE	fx6
	bra	finjoueur

;	Sequence releve

releve_sequence	move.l	seq_spr(a6),a0
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne	finjoueur
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne	finjoueur
	SEQUENCE	#vbl_debout,#debout_rien
	bra	finjoueur
