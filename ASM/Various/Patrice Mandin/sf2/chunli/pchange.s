; ----------------------------------
;	changement cote	OK
; ----------------------------------

vbl_change	move.l	seq_spr(a6),a0 ; continue debout
	move.b	5(a0),d0
	addq.w	#1,seq_vbl(a6)
	cmp.b	1+seq_vbl(a6),d0
	bne	finjoueur
	clr	seq_vbl(a6)
	addq	#8,a0
	move.l	a0,seq_spr(a6)
	tst.l	(a0)
	bne	finjoueur
	not	dn(a6)
	SEQUENCE	seq_cur2(a6),seq_spr2(a6)
	bra	finjoueur
