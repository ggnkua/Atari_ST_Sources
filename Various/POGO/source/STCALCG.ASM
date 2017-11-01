
	cseg



	public _calc_grav
	;calc_grav(sposition, dspeed, mass1)
	;sposition and dspeed are both pointers to 16 bit x,y coordinates
_calc_grav
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	(a0),d0
	muls	d0,d0
	move.w	2(a0),d1
	muls	d1,d1
	add.l	d1,d0
	swap	d0
	move.w	12(sp),d1
	ext.l	d1
	tst.w	d0	;strength of gravity here
	beq		maxgrav
	divu	d0,d1
cg
	move.w	(a0),d0
	muls	d1,d0
	bpl		cgp1
	add.l	#$fff,d0	; make +- shifts symmetrical
cgp1
	asr.l	#8,d0
	asr.l	#4,d0
	move.w	d0,(a1)+
	move.w	2(a0),d0
	muls	d1,d0
	bpl		cgp2
	add.l	#$fff,d0	; make +- shifts symmetrical
cgp2
	asr.l	#8,d0
	asr.l	#4,d0
	move.w	d0,(a1)+
	rts

maxgrav	move.w	#5,d1
	bra	cg

	END

