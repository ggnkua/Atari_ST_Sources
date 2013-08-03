; ----------------------------------
;	saut haut
; ----------------------------------

vbl_sauth	move	seq_vbl(a6),seq_vbl2(a6)
	move.l	seq_spr(a6),seq_spr2(a6)

	tst	saut(a6)
	bne	sauth_nohk

	move.l	lowpunchb(a4),a0
	tst.b	(a0)	; low punch ?
	beq.s	sauth_nolp
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupshaut,#lowpunchhaut
	SAMPLE	fx1
	bra	finjoueur
sauth_nolp	
	move.l	midpunchb(a4),a0
	tst.b	(a0)	; mid punch ?
	beq.s	sauth_nomp
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupshaut,#midpunchhaut
	SAMPLE	fx1
	bra	finjoueur
sauth_nomp	
	move.l	higpunchb(a4),a0
	tst.b	(a0)	; high punch ?
	beq.s	sauth_nohp
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupshaut,#higpunchhaut
	SAMPLE	fx2
	bra	finjoueur
sauth_nohp	
	move.l	lowkickb(a4),a0
	tst.b	(a0)	; low kick ?
	beq.s	sauth_nolk
	clr.b	(a0)
	move	#1,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupshaut,#lowkickhaut
	SAMPLE	fx2
	bra	finjoueur
sauth_nolk	
	move.l	midkickb(a4),a0
	tst.b	(a0)	; mid kick ?
	beq.s	sauth_nomk
	clr.b	(a0)
	move	#2,last_bt(a6)
	clr	seq_vbl(a6)
	btst.b	#1,(a5)
	bne.s	sauth_mk1
	SEQUENCE	#vbl_coupshaut,#midkickhaut
	SAMPLE	fx3
	bra	finjoueur
sauth_mk1	SEQUENCE	#vbl_coupshaut,#midkicktodownh
	bra	finjoueur
sauth_nomk	
	move.l	higkickb(a4),a0
	tst.b	(a0)	; high kick ?
	beq.s	sauth_nohk
	clr.b	(a0)
	move	#3,last_bt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_coupshaut,#higkickhaut
	SAMPLE	fx4
	bra	finjoueur
sauth_nohk

;	On se fait taper ?

	tst	touche(a6)
	bne	sauth_sequence

	tst	collision(a6)  ; si ya collision
	beq	sauth_sequence
	move	xn(a3),d0	  ; et je suis a
	sub	xn(a6),d0	  ; gauche de l'autre
	bpl.s	sauth_imp1
	tst	dn(a3)	  ; et il regarde
	bne.s	sauth_impact	  ; vers la gauche
	bra	sauth_sequence
sauth_imp1	tst	dn(a3)	  ; ou vers la droite
	bne	sauth_sequence	
	
sauth_impact	move.l	seq_spr(a3),a0 ; autre joueur
	move.b	4(a0),d0
	and	#$7f,d0
	beq.s	sauth_sequence	; frappe quelconque ?
	move	#14,seq_cpt(a6)
	clr	seq_vbl(a6)
	SEQUENCE	#vbl_sautarriere,#saute_arriere+16
	move	#-1,touche(a6)
	tst.l	snd_res(a6)
	bpl	finjoueur
	SAMPLE	fx7
	bra	finjoueur

;	Sequence saut haut

sauth_sequence	lea	sinus,a0
	moveq	#0,d0
	add	seq_cpt(a6),a0
	move.b	(a0),d0
	ext	d0
	add	d0,yn(a6)

	addq.w	#1,seq_cpt(a6)
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
