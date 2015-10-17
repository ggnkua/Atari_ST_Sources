gere_bomb	lea players,a6
	lea tmp_boum,a1
	moveq #3,d7
gere_bs1	move.w crd_bx(a6),d1	bombe active ?
	bmi.s gere_bs2	non -> fin
	eor.b #1,flag_b(a6)	tempo d'animation
	bne.s gere_bs2	25 img/sec.
	move.w crd_by(a6),d2
	move.w num_b(a6),d0	num d'animation.
	lea score(a6),a3
	movem.l d7/a1/a6,-(sp)
	bsr.s gere_bs3
	movem.l (sp)+,d7/a1/a6
	move.w d0,num_b(a6)
	move.w d1,crd_bx(a6)
gere_bs2	lea 14*4(a1),a1
	lea lg_play(a6),a6
	dbra d7,gere_bs1
	rts
gere_bs3	addq.w #1,d0		inc anim bombe
	and.w #7,d0		modulo 8 img
	bne.s gere_bs4	pas fini ?
	jsr init_boum		si alors explosion
	move.w #-1,d1		bombe off
	moveq #0,d0		anim a zero.
gere_bs4	rts

