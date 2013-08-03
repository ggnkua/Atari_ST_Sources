; ----------------------------------
;	bas
; ----------------------------------

vbl_coupsdown	move	#-1,attack(a6)

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
	clr	attack(a6)
	SEQUENCE	#vbl_baisse,#baisse+8
	bra	finjoueur
