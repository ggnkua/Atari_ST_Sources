; ----------------------------------
;	Saut sur les bords
; ----------------------------------

vbl_sautoppose	clr	saut(a6)
	tst	dn(a6)
	sne	saut(a6)

	move.l	lowpunchb(a4),a0
	tst.b	(a0)	; low punch ?
	beq.s	sautop_nolp
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautop,#lowpunchdg
	SAMPLE	fx1
	bra	finjoueur
sautop_nolp	
	move.l	midpunchb(a4),a0
	tst.b	(a0)	; mid punch ?
	beq.s	sautop_nomp
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautop,#midpunchdg
	SAMPLE	fx1
	bra	finjoueur
sautop_nomp	
	move.l	higpunchb(a4),a0
	tst.b	(a0)	; high punch ?
	beq.s	sautop_nohp
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautop,#higpunchdg
	SAMPLE	fx2
	bra	finjoueur
sautop_nohp	
	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	sautop_nolk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautop,#lowkickdg
	SAMPLE	fx2
	bra	finjoueur
sautop_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	sautop_nomk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	btst.b	#1,(a5)
	bne.s	sautop_mk1
	SEQUENCE	#vbl_coupssautop,#midkickdg
	SAMPLE	fx3
	bra	finjoueur
sautop_mk1	SEQUENCE	#vbl_coupssautop,#midkicktodowndg
	bra	finjoueur
sautop_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq.s	sautop_nohk
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupssautop,#higkickdg
	SAMPLE	fx4
	bra	finjoueur

sautop_nohk	lea	sinus3,a0
	moveq	#0,d0
	add	seq_cpt(a6),a0
	move.b	(a0)+,d0
	ext	d0
	add	d0,yn(a6)
	moveq	#0,d0
	move.b	(a0),d0
	ext	d0
	tst	dn(a6)
	beq.s	saut_oprigh
	add	d0,xn(a6)
	bra.s	saut_opcont
saut_oprigh	sub	d0,xn(a6)

saut_opcont	addq.w	#2,seq_cpt(a6)
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
	move	#base_y,yn(a6)
	SEQUENCE	#vbl_debout,#debout_rien
	SAMPLE	endjump
	bra	finjoueur
