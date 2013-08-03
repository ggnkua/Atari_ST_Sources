; ----------------------------------
;	saut haut
; ----------------------------------

vbl_coupshaut	move	#-1,attack(a6)

;	On se fait taper ?
; si il y a collision entre les deux joueurs
; et si lui fait un certain coup

	tst	touche(a6)
	bne	coupsh_sequence

	tst	collision(a6)
	beq	coupsh_sequence

	move	xn(a3),d0
	sub	xn(a6),d0
	bpl.s	coupsh_imp1	; le joueur doit frapper
	tst	dn(a3)	; en ‚tant tourn‚ vers
	bne.s	coupsh_impact	; l'autre joueur
	bra.s	coupsh_sequence
coupsh_imp1	tst	dn(a3)
	bne.s	coupsh_sequence	
	
coupsh_impact	move.l	seq_spr(a3),a0 ; autre joueur
	btst.b	#4,4(a0)	; frappe debout milieu ?
	beq.s	coupsh_sequence
	clr	seq_vbl(a6)
	move	#-1,touche(a6)
	SEQUENCE	#vbl_sautarriere,#saute_arriere+8
	SAMPLE	fx6
	bra	finjoueur

;	Sequence

coupsh_sequence	lea	sinus,a0
	moveq	#0,d0
	add	seq_cpt(a6),a0
	move.b	(a0),d0
	ext	d0
	add	d0,yn(a6)
	addq.w	#1,seq_cpt(a6)

	move.l	seq_spr2(a6),a1	; sequence saut
	move.b	5(a1),d1
	addq.w	#1,seq_vbl2(a6)
	cmp.b	1+seq_vbl2(a6),d1
	bne	coupshaut_seq2
	clr	seq_vbl2(a6)
	addq	#8,a1
	move.l	a1,seq_spr2(a6)

coupshaut_seq2	cmp	#30,seq_cpt(a6)
	bmi.s	coupshaut_cont
	tst	d0
	beq.s	coupshaut_stop
	
coupshaut_cont	move.l	seq_spr(a6),a0	; sequence coup
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne	finjoueur
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne	finjoueur

coupshaut_stop	move	seq_vbl2(a6),seq_vbl(a6)
	SEQUENCE	#vbl_sauth,seq_spr2(a6)
	move	#-1,saut(a6)
	clr	attack(a6)
	bra	finjoueur
