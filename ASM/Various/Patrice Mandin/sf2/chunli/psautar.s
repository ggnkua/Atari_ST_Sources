; ----------------------------------
;	Saute en arriere
; ----------------------------------

vbl_sautarriere	move	last_bt(a3),d0
	beq.s	star_noimpact
	lsl	#2,d0
	move	energie(a6),d1
	sub	d0,d1
	bpl.s	star_nrjnot0
	moveq	#0,d1
star_nrjnot0	move	d1,energie(a6)
	clr	last_bt(a3)
star_noimpact	bra	sautar_nohk

sautar_coups	clr	saut(a6)
	tst	dn(a6)
	seq	saut(a6)

	move.l	lowpunchb(a4),a0
	tst.b	(a0)	; low punch ?
	beq.s	sautar_nolp
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#lowpunchdg
	SAMPLE	fx1
	bra	finjoueur
sautar_nolp	
	move.l	midpunchb(a4),a0
	tst.b	(a0)	; mid punch ?
	beq.s	sautar_nomp
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#midpunchdg
	SAMPLE	fx1
	bra	finjoueur
sautar_nomp	
	move.l	higpunchb(a4),a0
	tst.b	(a0)	; high punch ?
	beq.s	sautar_nohp
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#higpunchdg
	SAMPLE	fx2
	bra	finjoueur
sautar_nohp	
	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	sautar_nolk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#lowkickdg
	SAMPLE	fx2
	bra	finjoueur
sautar_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	sautar_nomk
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	btst.b	#1,(a5)
	bne.s	sautar_mk1
	SEQUENCE	#vbl_coupssautdg,#midkickdg
	SAMPLE	fx3
	bra	finjoueur
sautar_mk1	SEQUENCE	#vbl_coupssautdg,#midkicktodowndg
	bra	finjoueur
sautar_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq.s	sautar_nohk
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#higkickdg
	SAMPLE	fx4
	bra	finjoueur

sautar_nohk	tst	bord(a6)
	beq.s	sautar_nochgc
	moveq	#2,d0
	tst	dn(a6)
	beq.s	sautar_tstbrd
	moveq	#3,d0
sautar_tstbrd	btst.b	d0,(a5)	; opposite ?
	beq.s	sautar_nochgc
	cmp	#base_sautopp_y,yn(a6)
	bpl.s	sautar_nochgc
	cmp	#2,d0
	bne.s	sautar_oprigh
	move	maxecrx(a6),d0
	sub	#13,d0
	move	d0,xn(a6)
	bra.s	sautar_startop
sautar_oprigh	move	minecrx(a6),d0
	add	#13,d0
	move	d0,xn(a6)

sautar_startop	clr	seq_vbl(a6)
	clr	seq_cpt(a6)
	clr	touche(a6)
	SEQUENCE	#vbl_sautoppose,#saute_oppose
	SAMPLE	endjump
	bra	finjoueur
sautar_nochgc	

;	On se fait taper ?

	tst	touche(a6)
	bne	sautar_sequence

	tst	collision(a6)  ; si ya collision
	beq	sautar_sequence
	move	xn(a3),d0	  ; et je suis a
	sub	xn(a6),d0	  ; gauche de l'autre
	bpl.s	sautar_imp1
	tst	dn(a3)	  ; et il regarde
	bne.s	sautar_impact	  ; vers la gauche
	bra	sautar_sequence
sautar_imp1	tst	dn(a3)	  ; ou vers la droite
	bne	sautar_sequence	
	
sautar_impact	move.l	seq_spr(a3),a0 ; autre joueur
	move.b	4(a0),d0
	and	#$7f,d0
	beq.s	sautar_sequence	; frappe quelconque ?
	move	#14,seq_cpt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_sautarriere,#saute_arriere+16
	move	#-1,touche(a6)
	tst.l	snd_res(a6)
	bpl	finjoueur
	SAMPLE	fx7
	bra	finjoueur

;	Sequence

sautar_sequence	lea	sinus2,a0
	moveq	#0,d0
	add	seq_cpt(a6),a0
	move.b	(a0)+,d0
	ext	d0
	move	d0,d3
	add	d0,yn(a6)
	moveq	#0,d0
	move.b	(a0),d0
	ext	d0
	
	tst	dn(a6)
	beq.s	saut_arrigh
	sub	d0,xn(a6)
	bra.s	saut_arcont
saut_arrigh	add	d0,xn(a6)

saut_arcont	addq.w	#2,seq_cpt(a6)
	move.l	seq_spr(a6),a0
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne.s	sautar_limit
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	beq.s	sautar_limit1

sautar_limit	cmp	#base_y,yn(a6)
	bls.s	sautar_limit2
sautar_limit1	move	#base_y,yn(a6)
	SEQUENCE	#vbl_debout,#debout_rien
	SAMPLE	endjump
	clr	touche(a6)
sautar_limit2	
	tst	dn(a6)
	bne.s	sautar_minx
	move	maxecrx(a6),d0
	sub	#22,d0
	cmp	xn(a6),d0
	bpl	finjoueur
	move	d0,xn(a6)
	bra	finjoueur
sautar_minx	move	minecrx(a6),d0
	add	#22,d0
	cmp	xn(a6),d0
	bmi	finjoueur
	move	d0,xn(a6)
	bra	finjoueur
