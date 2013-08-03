; ----------------------------------
;	baisse	OK
; ----------------------------------

vbl_baisse	btst.b	#1,(a5)	; down ?
	bne.s	baisse_cont
	SEQUENCE	#vbl_releve,#releve
	bra	finjoueur

;	Changement de cote ?

baisse_cont	SEQUENCE2	#vbl_baisse,#baisse+8
	
	move	xn(a6),d0
	sub	xn(a3),d0
	bpl.s	baisse_cdroit

	tst	dn(a6)
	bne.s	baisse_testdir
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_change,#chg_cote_bas
	bra	finjoueur

baisse_cdroit	tst	dn(a6)
	beq.s	baisse_testdir
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_change,#chg_cote_bas
	bra	finjoueur
baisse_testdir	

;	test protection

	btst.b	#2,(a5)
	beq.s	baisse_noleft
	tst	dn(a6)	; si oppos‚e
	beq.s	baisse_noleft
	tst	attack(a3)	; et l'autre attaque
	beq.s	baisse_noleft
	move	#2,bt_nmb(a6) ; nb dir a tester
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_protect,#protection_bas
	bra	finjoueur	
baisse_noleft
	btst.b	#3,(a5)
	beq.s	baisse_noright
	tst	dn(a6)	; si oppos‚e
	bne.s	baisse_noright
	tst	attack(a3)	; et l'autre attaque
	beq.s	baisse_noright
	move	#3,bt_nmb(a6) ; nb dir a tester
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_protect,#protection_bas
	bra	finjoueur	
baisse_noright

;	On se fait taper ?
; si il y a collision entre les deux joueurs
; et si lui fait un certain coup

	tst	touche(a6)
	bne	baisse_sequence

	tst	collision(a6)
	beq	baisse_sequence
	SEQUENCE2	#vbl_baisse,#baisse+8

	move	xn(a3),d0
	sub	xn(a6),d0
	bpl.s	baisse_imp1	; le joueur doit frapper
	tst	dn(a3)	; en ‚tant tourn‚ vers
	bne.s	baisse_impact	; l'autre joueur
	bra.s	baisse_sequence
baisse_imp1	tst	dn(a3)
	bne.s	baisse_sequence	
	
baisse_impact	move.l	seq_spr(a3),a0 ; autre joueur
	btst.b	#5,4(a0)	; frappe debout milieu ?
	beq.s	baisse_ihaut
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_bas
	move	#-1,touche(a6)
	SAMPLE	fx6
	bra	finjoueur
baisse_ihaut
	btst.b	#4,4(a0)	; frappe debout haut ?
	beq.s	baisse_sequence
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_impacts,#imp_bas
	move	#-1,touche(a6)
	SAMPLE	fx6
	bra	finjoueur

;	Sequence

baisse_sequence	addq.w	#1,seq_cpt(a6)
	move.l	seq_spr(a6),a0
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne.s	baisse_coups
	clr	seq_vbl(a6)
	addq	#8,a0
	tst.l	(a0)
	bne.s	baisse_seq1
	subq	#8,a0
baisse_seq1	move.l	a0,seq_spr(a6)
	
;	Coups

baisse_coups	move.l	lowpunchb(a4),a0
	tst.b	(a0)	; low punch ?
	beq.s	baisse_nolp
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupsdown,#lowpunchdown
	SAMPLE	fx1
	bra	finjoueur
baisse_nolp	
	move.l	midpunchb(a4),a0
	tst.b	(a0)	; middle punch ?
	beq.s	baisse_nomp
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupsdown,#midpunchdown
	SAMPLE	fx1
	bra	finjoueur
baisse_nomp	
	move.l	higpunchb(a4),a0
	tst.b	(a0)	; high punch ?
	beq.s	baisse_nohp
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupsdown,#higpunchdown
	SAMPLE	fx2
	bra	finjoueur
baisse_nohp	
	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	baisse_nolk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupsdown,#lowkickdown
	SAMPLE	fx2
	bra	finjoueur
baisse_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	baisse_nomk
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupsdown,#midkickdown
	SAMPLE	fx3
	bra	finjoueur
baisse_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq	finjoueur
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupsdown,#higkickdown
	SAMPLE	fx4
	bra	finjoueur
