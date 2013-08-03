; ----------------------------------
;	marche	OK
; ----------------------------------

vbl_marche	
	
;	Changement de cote
	
	SEQUENCE2	#vbl_debout,#debout_rien
	
	move	xn(a6),d0
	sub	xn(a3),d0
	bpl.s	marche_cdroit

	tst	dn(a6)
	bne.s	marche_testdir
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_change,#chg_cote_debout
	bra	finjoueur

marche_cdroit	tst	dn(a6)
	beq.s	marche_testdir
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_change,#chg_cote_debout
	bra	finjoueur

;	Test directions

marche_testdir	btst.b	#0,(a5)	; up ?
	beq	marche_noup
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)
	
	btst.b	#2,(a5)	; left ?
	beq.s	marche_noupleft
	tst	dn(a6)
	beq.s	marche_upleft
	SEQUENCE	#vbl_sautarriere,#saute_arriere
	bra	finjoueur
marche_upleft	SEQUENCE	#vbl_sautavant,#saute_avant
	bra	finjoueur

marche_noupleft	btst.b	#3,(a5)	; right ?
	beq	finjoueur
	tst	dn(a6)
	beq.s	marche_upright
	SEQUENCE	#vbl_sautavant,#saute_avant
	bra	finjoueur
marche_upright	SEQUENCE	#vbl_sautarriere,#saute_arriere
	bra	finjoueur

marche_noup	btst.b	#2,(a5)	; left ?
	beq	marche_noleft
	tst	dn(a6)	; si oppos‚e
	beq.s	marche_walkleft
	tst	attack(a3)	; et l'autre attaque
	beq.s	marche_walkleft
	move	#2,bt_nmb(a6) ; nb dir a tester
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_protect,#protection_deb
	bra	finjoueur	

marche_walkleft	move	minecrx(a6),d2
	add	#22,d2
	tst	dn(a6)     ; si sprite marche en avant gauche
	bne.s	marche_nocolri
	
	move.l	seq_spr(a6),a0
	move.l	(a0),a0
	move	16(a0),d0	; largeur du sprite 1
	lsr	#1,d0
	move.l	seq_spr(a3),a0
	move.l	(a0),a0
	move	16(a0),d1	; largeur du sprite 2
	lsr	#1,d1
	move.l	seq_spr(a6),a0
	move.l	(a0),a0
	move	yn(a6),d3
	sub	2(a0),d3	; pos hauteur sprite 1
	cmp	d0,d1
	bmi.s	marche_largd2
	move	d1,d0	; d0 le plus large
marche_largd2
	move	xn(a6),d1
	sub	xn(a3),d1
	bmi.s	marche_nocolri
	cmp	d1,d0
	bmi.s	marche_nocolri	
	cmp	yn(a3),d3
	bpl.s	marche_nocolri
	tst	collision(a6)
	beq.s	marche_nocolri
	
	sub	#1,xn(a6)
	sub	#1,xn(a3)
	cmp	xn(a3),d2
	bmi	marche_cont
	add	#1,xn(a6)
	add	#1,xn(a3)
	bra	marche_cont

marche_nocolri	sub	#2,xn(a6)
	cmp	xn(a6),d2
	bmi	marche_cont
	move	d2,xn(a6)
	bra	marche_cont

marche_noleft	btst.b	#3,(a5)	; right ?
	beq	marche_stop
	tst	dn(a6)	; si oppos‚e
	bne.s	marche_walkrigh
	tst	attack(a3)	; et l'autre attaque
	beq.s	marche_walkrigh
	move	#3,bt_nmb(a6) ; nb dir a tester
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_protect,#protection_deb
	bra	finjoueur	

marche_walkrigh	move	maxecrx(a6),d2
	sub	#22,d2
	tst	dn(a6)     ; si sprite marche en avant droite
	beq.s	marche_nocolle

	move.l	seq_spr(a6),a0
	move.l	(a0),a0
	move	16(a0),d0	; largeur du sprite 1
	lsr	#1,d0
	move.l	seq_spr(a3),a0
	move.l	(a0),a0
	move	16(a0),d1	; largeur du sprite 2
	move.l	seq_spr(a6),a0
	move.l	(a0),a0
	move	yn(a6),d3
	sub	2(a0),d3	; pos hauteur sprite 1
	lsr	#1,d1
	cmp	d0,d1
	bmi.s	marche_larg1d2
	move	d1,d0	; d0 le plus large
marche_larg1d2
	move	xn(a3),d1
	sub	xn(a6),d1
	bmi.s	marche_nocolle
	cmp	d1,d0	; si trop ‚cart‚s
	bmi.s	marche_nocolle	
	cmp	yn(a3),d3	; si sprite trop haut
	bpl.s	marche_nocolle
	tst	collision(a6)
	beq.s	marche_nocolle

	add	#1,xn(a6)
	add	#1,xn(a3)
	cmp	xn(a3),d2
	bpl.s	marche_cont
	sub	#1,xn(a6)
	sub	#1,xn(a3)
	bra.s	marche_cont

marche_nocolle	add	#2,xn(a6)
	cmp	xn(a6),d2
	bpl.s	marche_cont
	move	d2,xn(a6)
marche_cont
	
;	On se fait taper ?
; si il y a collision entre les deux joueurs
; et si lui fait un certain coup

	tst	touche(a6)
	bne	marche_sequence

	tst	collision(a6)
	beq	marche_sequence
	SEQUENCE2	#vbl_debout,#debout_rien

	move	xn(a3),d0
	sub	xn(a6),d0
	bpl.s	marche_imp1	; le joueur doit frapper
	tst	dn(a3)	; en ‚tant tourn‚ vers
	bne.s	marche_impact	; l'autre joueur
	bra	marche_sequence
marche_imp1	tst	dn(a3)
	bne	marche_sequence	
	
marche_impact	move.l	seq_spr(a3),a0 ; autre joueur
	btst.b	#5,4(a0)	; frappe milieu ?
	beq.s	marche_ihaut
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_debmilieu
	move	#-1,touche(a6)
	SAMPLE	fx7
	bra	finjoueur
marche_ihaut	
	btst.b	#4,4(a0)	; frappe haut ?
	beq.s	marche_ifauche
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_debhaut
	move	#-1,touche(a6)
	SAMPLE	fx6
	bra	finjoueur
marche_ifauche	
	btst.b	#6,4(a0)	; fauchage ?
	beq.s	marche_iprise
	sub	#32,yn(a6)
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)
	clr	saut(a6)
	SEQUENCE	#vbl_impact_sin,#fauchage
	SAMPLE	fx8
	bra	finjoueur
marche_iprise	
	btst.b	#3,4(a0)	; prise ?
	beq.s	marche_sequence
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)
	move	#-1,saut(a6)
	SEQUENCE2	#vbl_baisse,#baisse+8
	SEQUENCE	#vbl_impact_sin,#imp_deb_prise
	move	#-1,touche(a6)
	SAMPLE	fx8
	bra	finjoueur

;	Marche
;	> debout pour tester les boutons

marche_sequence	move	#-1,saut(a6)
	
	move.l	seq_spr(a6),a0
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne	debout_cont
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne	debout_cont
	move.l	#marche,seq_spr(a6)
	bra	debout_cont

marche_stop	SEQUENCE	#vbl_debout,#debout_rien
	bra	finjoueur
