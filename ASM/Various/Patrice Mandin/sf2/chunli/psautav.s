; ----------------------------------
;	Saute en avant
; ----------------------------------

vbl_sautavant	moveq	#0,d7

	clr	saut(a6)
	tst	dn(a6)
	sne	saut(a6)

	move.l	lowpunchb(a4),a0
	tst.b	(a0)	; low punch ?
	beq.s	sautav_nolp
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#lowpunchdg
	SAMPLE	fx1
	bra	finjoueur
sautav_nolp	
	move.l	midpunchb(a4),a0
	tst.b	(a0)	; mid punch ?
	beq.s	sautav_nomp
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#midpunchdg
	SAMPLE	fx1
	bra	finjoueur
sautav_nomp	
	move.l	higpunchb(a4),a0
	tst.b	(a0)	; high punch ?
	beq.s	sautav_nohp
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#higpunchdg
	SAMPLE	fx2
	bra	finjoueur
sautav_nohp	
	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	sautav_nolk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#lowkickdg
	SAMPLE	fx2
	bra	finjoueur
sautav_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	sautav_nomk
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	btst.b	#1,(a5)
	bne.s	sautav_mk1
	SEQUENCE	#vbl_coupssautdg,#midkickdg
	SAMPLE	fx3
	bra	finjoueur
sautav_mk1	SEQUENCE	#vbl_coupssautdg,#midkicktodowndg
	bra	finjoueur
sautav_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq.s	sautav_nohk
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautdg,#higkickdg
	SAMPLE	fx4
	bra	finjoueur

sautav_nohk	tst	bord(a6)
	beq.s	sautav_nochgc
	moveq	#3,d0
	tst	dn(a6)
	beq.s	sautav_tstbrd
	moveq	#2,d0
sautav_tstbrd	btst.b	d0,(a5)	; opposite ?
	beq.s	sautav_nochgc
	cmp	#base_sautopp_y,yn(a6)
	bpl.s	sautav_nochgc
	cmp	#2,d0
	bne.s	sautav_oprigh
	move	maxecrx(a6),d0
	sub	#13,d0
	move	d0,xn(a6)
	bra.s	sautav_startop
sautav_oprigh	move	minecrx(a6),d0
	add	#13,d0
	move	d0,xn(a6)

sautav_startop	not	dn(a6)
	clr	seq_vbl(a6)
	clr	seq_cpt(a6)
	SEQUENCE	#vbl_sautoppose,#saute_oppose
	SAMPLE	endjump
	bra	finjoueur
sautav_nochgc

;	On se fait taper ?

	tst	touche(a6)
	bne	sautav_sequence

	tst	collision(a6)  ; si ya collision
	beq	sautav_sequence

	move.l	seq_spr(a6),a0 ; test contact
	move.l	(a0),a0
	move	16(a0),d0	; largeur du sprite 1
	lsr	#1,d0
	move.l	seq_spr(a3),a0
	move.l	(a0),a0
	move	16(a0),d1	; largeur du sprite 2
	move.l	seq_spr(a6),a0
	move.l	(a0),a0
	lsr	#1,d1
	cmp	d0,d1
	bmi.s	sautav_larg1d2
	move	d1,d0	; d0 le plus large
sautav_larg1d2
	move	xn(a3),d1
	sub	xn(a6),d1
	bmi.s	sautav_impact0
	cmp	d1,d0	; si trop ‚cart‚s
	bmi.s	sautav_impact0	
	move	#-1,d7

sautav_impact0	move	xn(a3),d0	  ; et je suis a
	sub	xn(a6),d0	  ; gauche de l'autre
	bpl.s	sautav_imp1
	tst	dn(a3)	  ; et il regarde
	bne.s	sautav_impact	  ; vers la gauche
	bra	sautav_sequence
sautav_imp1	tst	dn(a3)	  ; ou vers la droite
	bne	sautav_sequence	
	
sautav_impact	move.l	seq_spr(a3),a0 ; autre joueur
	move.b	4(a0),d0
	and	#$7f,d0
	beq.s	sautav_sequence	; frappe quelconque ?
	move	#14,seq_cpt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_sautarriere,#saute_arriere+16
	move	#-1,touche(a6)
	tst.l	snd_res(a6)
	bpl	finjoueur
	SAMPLE	fx7
	bra	finjoueur

;	Sequence saut en avant

sautav_sequence	lea	sinus2,a0
	moveq	#0,d0
	add	seq_cpt(a6),a0
	move.b	(a0)+,d0
	ext	d0
	move	d0,d3
	add	d0,yn(a6)
	moveq	#0,d0
	move.b	(a0),d0
	ext	d0

	tst	d7	; si pas contact
	bne.s	saut_avcont

	tst	dn(a6)
	beq.s	saut_avleft
	add	d0,xn(a6)
	bra.s	saut_avcont
saut_avleft	sub	d0,xn(a6)

saut_avcont	addq.w	#2,seq_cpt(a6)
	move.l	seq_spr(a6),a0
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne	sautav_limit
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne	sautav_limit
	SEQUENCE	#vbl_debout,#debout_rien
	SAMPLE	endjump
	move	#base_y,yn(a6)

sautav_limit	tst	dn(a6)
	beq.s	sautav_minx	
	move	maxecrx(a6),d0
	sub	#22,d0
	cmp	xn(a6),d0
	bpl	finjoueur
	move	d0,xn(a6)
	bra	finjoueur
sautav_minx	move	minecrx(a6),d0
	add	#22,d0
	cmp	xn(a6),d0
	bmi	finjoueur
	move	d0,xn(a6)
	bra	finjoueur
