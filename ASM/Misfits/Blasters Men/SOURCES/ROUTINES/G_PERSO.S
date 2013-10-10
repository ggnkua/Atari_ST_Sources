move_perso	lea tmp_atb,a0
	lea players,a6
	moveq #3,d7
move_ps0	tst.b dead(a6)	perso mort ?
	bne.s move_p2		alors pas de deplacements.
	move.w crd_x(a6),d0	crd x perso 1
	move.w crd_y(a6),d1	crd y perso 1
	move.w crd_bx(a6),d3	crd x bombe 1
	move.w crd_by(a6),d4	crd y bombe 1
	move.l ad_rout(a6),a1
	move.b (a1),d2	flag joystick
	bsr.s move_ps1	deplacements.
	move.w d0,crd_x(a6)
	move.w d1,crd_y(a6)
	move.w d3,crd_bx(a6)
	move.w d4,crd_by(a6)
move_p2	lea lg_play(a6),a6
	dbra d7,move_ps0
	rts

move_ps1	move.w d1,d5
	mulu #20,d5
	add.w d0,d5
	lea (a0,d5.w),a1
	btst #0,d2		up ?
	beq.s move_ps2
	tst.b -20(a1)
	bne.s move_ps2
	subq.w #1,d1
	sub.w #20,a1
move_ps2	btst #1,d2		down ?
	beq.s move_ps3
	tst.b 20(a1)
	bne.s move_ps3
	addq.w #1,d1
	add.w #20,a1
move_ps3	btst #2,d2		left ?
	beq.s move_ps4
	tst.b -1(a1)
	bne.s move_ps4
	subq.w #1,d0
	subq.w #1,a1
move_ps4	btst #3,d2		right ?
	beq.s move_ps5
	tst.b 1(a1)
	bne.s move_ps5
	addq.w #1,d0
	addq.w #1,a1
move_ps5	btst #7,d2		fire ?
	beq.s move_ps6
	tst.w d3		pas de bombes deja
	bpl.s move_ps6	posee ?
	move.w d0,d3		alors crd bombe=crd perso
	move.w d1,d4
move_ps6	rts
