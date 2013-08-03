; ---------------------------------------------------------
;	Protection
; ---------------------------------------------------------

vbl_protect	btst.b	#0,(a5)	; Haut: je saute ?
	beq	protect_noup	; sinon c'est + loin
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)

	btst.b	#2,(a5)	; Vers la gauche ?
	beq.s	protect_nouplef
	tst	dn(a6)	; Vers l'avant ?
	beq.s	protect_upleft
	SEQUENCE	#vbl_sautarriere,#saute_arriere
	bra	finjoueur
protect_upleft	SEQUENCE	#vbl_sautavant,#saute_avant
	bra	finjoueur

protect_nouplef	btst.b	#3,(a5)	; Vers la droite ?
	beq.s	protect_nouprig
	tst	dn(a6)	; Vers l'avant ?
	beq.s	protect_upright
	SEQUENCE	#vbl_sautavant,#saute_avant
	bra	finjoueur
protect_upright	SEQUENCE	#vbl_sautarriere,#saute_arriere
	bra	finjoueur

protect_nouprig	SEQUENCE	#vbl_sauth,#saute_haut	; Vers le haut
	clr	saut(a6)
	bra	finjoueur
protect_noup
	clr	touche(a6)
	tst	attack(a3)
	beq.s	protect_end
	move	bt_nmb(a6),d0 ; nb dir
	btst.b	d0,(a5)
	bne	finjoueur
protect_end	SEQUENCE	seq_cur2(a6),seq_spr2(a6)
	bra	finjoueur
