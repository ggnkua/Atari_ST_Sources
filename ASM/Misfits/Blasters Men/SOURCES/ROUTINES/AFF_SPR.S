aff_boum	move.l ad_bboum1,a6
	lea 2(a6),a0
	clr.w (a6)		aucunes explosion aff.
	lea tmp_boum,a4
	lea boum,a5
	moveq #3,d6
aff_boums3	move.l a4,a3
	bsr.s aff_boums0
	lea 14*4(a4),a4
	dbra d6,aff_boums3
	rts
aff_boums0	move.l (a3)+,d7	nb explos.
	add.w d7,(a6)		nb total a effacer.
aff_boums1	subq.w #1,d7
	bmi.s aff_boums2
	move.w (a3)+,d0	crd x explo.
	move.w (a3)+,d1	crd y
	move.l a5,a1
	jsr aff_persos2
	bra.s aff_boums1
aff_boums2	rts

aff_bomb	move.l ad_bbomb1,a0
	lea players,a6
	moveq #3,d7
aff_bombs1	move.l #-1,(a0)
	move.w crd_bx(a6),d0
	bmi.s aff_bombs2
	move.w crd_by(a6),d1
	lea bombes,a1
	move.w num_b(a6),d2
	mulu #8*16,d2
	add.w d2,a1
	jsr aff_persos2
aff_bombs2	lea lg_play(a6),a6
	dbra d7,aff_bombs1
	rts

aff_perso	move.l ad_bpers1,a0
	lea mecs,a5
	lea players,a6
	moveq #3,d7
aff_persos0	move.w crd_x(a6),d0
	move.w crd_y(a6),d1
	move.b dead(a6),d2
	move.l #-1,(a0)
	move.l a5,a1
	bsr.s aff_persos1
	lea 8*16(a5),a5
	lea lg_play(a6),a6
	dbra d7,aff_persos0
	rts
aff_persos1	tst.b d2
	beq.s aff_persos2
	bmi aff_persos3
	lea rip,a1
aff_persos2	lsl.w #3,d0
	lsl.w #4,d1
	mulu #160,d1
	add.w d0,d1
	move.l screen2,a2
	add.w d1,a2
	move.l a2,(a0)
	v_init offset,0
	rept 16
	move.l (a1)+,0+offset(a2)
	move.l (a1)+,4+offset(a2)
	v_inc offset,160
	endr
aff_persos3	addq.w #4,a0
	rts
