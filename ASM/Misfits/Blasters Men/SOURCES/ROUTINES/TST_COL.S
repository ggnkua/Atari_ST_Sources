tst_col	lea players,a6
	move.w (0*lg_play)+score(a6),d3
	move.w (1*lg_play)+score(a6),d4
	move.w (2*lg_play)+score(a6),d5
	move.w (3*lg_play)+score(a6),d6
	moveq #3,d7
tst_cols1	tst.b dead(a6)	il est deja mort !
	bne.s tst_cols2
	move.l crd_x(a6),d0
	movem.w d3-d6,-(sp)
	bsr.s tst_cols3	perso sous une explo ?
	movem.w (sp)+,d3-d6
	beq.s tst_cols2	non -> perso suivant
	move.b #30,dead(a6)	tempo tombe
	subq.w #1,vie(a6)	vie-1
	add.w #10,d4		incremente score
	add.w #10,d5		des autres joueurs
	add.w #10,d6
tst_cols2	move.w d3,d2
	move.w d4,d3
	move.w d5,d4
	move.w d6,d5
	move.w d2,d6
	lea lg_play(a6),a6
	dbra d7,tst_cols1
	lea players,a6

	tst.b (0*lg_play)+dead(a6)
	bmi.s tst_cols10
	move.w d3,(0*lg_play)+score(a6)

tst_cols10	tst.b (1*lg_play)+dead(a6)
	bmi.s tst_cols11
	move.w d4,(1*lg_play)+score(a6)

tst_cols11	tst.b (2*lg_play)+dead(a6)
	bmi.s tst_cols12
	move.w d5,(2*lg_play)+score(a6)

tst_cols12	tst.b (3*lg_play)+dead(a6)
	bmi.s tst_cols13
	move.w d6,(3*lg_play)+score(a6)

tst_cols13	rts
tst_cols3	lea tmp_boum,a1
	moveq #3,d6
tst_cols7	move.l a1,a0
	bsr.s tst_cols4
	bne.s tst_cols99
	lea 14*4(a1),a1
	dbra d6,tst_cols7
	bra.s tst_cols99
tst_cols4	move.l (a0)+,d1
	moveq #0,d2
	subq.w #1,d1
	bmi.s tst_cols99
tst_cols5	cmp.l (a0)+,d0
	beq.s tst_cols6
	dbra d1,tst_cols5
	bra.s tst_cols99
tst_cols6	moveq #1,d2
tst_cols99	tst.w d2
	rts

