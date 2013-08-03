; ----------------------------------
;	debout	OK
; ----------------------------------

vbl_debout	clr	saut(a6)	; flag si vient de marche

;	Changement de cote ?

	SEQUENCE2	#vbl_debout,#debout_rien	; retour
	
	move	xn(a6),d0	; si je suis
	sub	xn(a3),d0	; a droite de l'autre
	bpl.s	debout_cdroit	; alors c'est + loin

	tst	dn(a6)	; si je le regarde
	bne.s	debout_testdir	; c'est ok
	clr	seq_vbl(a6)	; sinon je me tourne
	SEQUENCE	#vbl_change,#chg_cote_debout
	bra	finjoueur

debout_cdroit	tst	dn(a6)	; si je le regarde
	beq.s	debout_testdir	; c'est ok
	clr	seq_vbl(a6)	; sinon je me tourne
	SEQUENCE	#vbl_change,#chg_cote_debout
	bra	finjoueur

;	Attend les directions

debout_testdir	SEQUENCE2	#vbl_debout,#debout_rien	; retour

	btst.b	#0,(a5)	; Haut: je saute ?
	beq	debout_noup	; sinon c'est + loin
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)

	btst.b	#2,(a5)	; Vers la gauche ?
	beq.s	debout_noupleft
	tst	dn(a6)	; Vers l'avant ?
	beq.s	debout_upleft
	SEQUENCE	#vbl_sautarriere,#saute_arriere
	bra	finjoueur
debout_upleft	SEQUENCE	#vbl_sautavant,#saute_avant
	bra	finjoueur

debout_noupleft	btst.b	#3,(a5)	; Vers la droite ?
	beq.s	debout_nouprigh
	tst	dn(a6)	; Vers l'avant ?
	beq.s	debout_upright
	SEQUENCE	#vbl_sautavant,#saute_avant
	bra	finjoueur
debout_upright	SEQUENCE	#vbl_sautarriere,#saute_arriere
	bra	finjoueur

debout_nouprigh	SEQUENCE	#vbl_sauth,#saute_haut	; Vers le haut
	clr	saut(a6)
	bra	finjoueur

debout_noup	btst.b	#1,(a5)	; Vers le bas ?
	beq.s	debout_nodown
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_baisse,#baisse
	bra	finjoueur
debout_nodown	
	btst.b	#2,(a5)	; Debout : vers la gauche ?
	beq.s	debout_noleft
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_marche,#marche
	bra	finjoueur
debout_noleft	
	btst.b	#3,(a5)	; Vers la droite ?
	beq.s	debout_noright
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_marche,#marche
	bra	finjoueur
debout_noright	

;	On se fait taper ?

	tst	collision(a6)  ; si ya collision
	beq	debout_sequence
	move	xn(a3),d0	  ; et je suis a
	sub	xn(a6),d0	  ; gauche de l'autre
	bpl.s	debout_imp1
	tst	dn(a3)	  ; et il regarde
	bne.s	debout_impact	  ; vers la gauche
	bra	debout_sequence
debout_imp1	tst	dn(a3)	  ; ou vers la droite
	bne	debout_sequence	
	
debout_impact	tst	touche(a6)
	bne	debout_sequence
	move.l	seq_spr(a3),a0 ; autre joueur
	btst.b	#5,4(a0)	; frappe milieu ?
	beq.s	debout_ihaut
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_debmilieu
	move	#-1,touche(a6)
	SAMPLE	fx6
	bra	finjoueur
debout_ihaut	
	btst.b	#4,4(a0)	; frappe haut ?
	beq.s	debout_ifauche
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_debhaut
	move	#-1,touche(a6)
	SAMPLE	fx6
	bra	finjoueur
debout_ifauche	
	btst.b	#6,4(a0)	; fauchage ?
	beq.s	debout_iprise
	sub	#32,yn(a6)
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)
	clr	saut(a6)
	SEQUENCE	#vbl_impact_sin,#fauchage
	move	#-1,touche(a6)
	SAMPLE	fx7
	bra	finjoueur
debout_iprise	
	btst.b	#3,4(a0)	; prise ?
	beq.s	debout_sequence
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)
	move	#-1,saut(a6)
	SEQUENCE2	#vbl_baisse,#baisse+8
	SEQUENCE	#vbl_impact_sin,#imp_deb_prise
	move	#-1,touche(a6)
	SAMPLE	fx8
	bra	finjoueur
	
;	Gere la sequence

debout_sequence	move.l	seq_spr(a6),a0 ; continue debout
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne.s	debout_cont
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne.s	debout_cont
	move.l	#debout_rien,seq_spr(a6)

;	Teste les boutons

debout_cont	move.l	lowpunchb(a4),a0
	tst.b	(a0)	; low punch ?
	beq.s	debout_nolp
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	tst	saut(a6)
	beq.s	debout_nmlp
	tst	collision(a6)
	beq.s	debout_nmlp
	SEQUENCE	#vbl_coups,#pousse
	SAMPLE	fx2
	bra	finjoueur
debout_nmlp	SEQUENCE	#vbl_coups,#lowpunch
	SAMPLE	fx1
	bra	finjoueur
debout_nolp	
	move.l	midpunchb(a4),a0
	tst.b	(a0)	; middle punch ?
	beq.s	debout_nomp
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	tst	saut(a6)
	beq.s	debout_nmmp
	tst	collision(a6)
	beq.s	debout_nmmp
	SEQUENCE	#vbl_coups,#pousse
	SAMPLE	fx2
	bra	finjoueur
debout_nmmp	SEQUENCE	#vbl_coups,#midpunch
	SAMPLE	fx1
	bra	finjoueur
debout_nomp	
	move.l	higpunchb(a4),a0
	tst.b	(a0)	; high punch ?
	beq.s	debout_nohp
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	tst	saut(a6)
	beq.s	debout_nmhp
	tst	collision(a6)
	beq.s	debout_nmhp
	SEQUENCE	#vbl_coups,#prise
	SAMPLE	speed
	bra	finjoueur
debout_nmhp	SEQUENCE	#vbl_coups,#higpunch
	SAMPLE	fx2
	bra	finjoueur
debout_nohp	
	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	debout_nolk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coups,#lowkick
	SAMPLE	fx2
	bra	finjoueur
debout_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	debout_nomk
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coups,#midkick
	SAMPLE	fx3
	bra	finjoueur
debout_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq	finjoueur
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_cpt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coups,#higkick
	SAMPLE	fx4
	bra	finjoueur
