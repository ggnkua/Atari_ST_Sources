eff_boum	move.l ad_bboum1,a0
	move.w (a0)+,d2
	beq.s eff_boums1
	subq.w #1,d2
	bra.s eff_persos0
eff_boums1	rts

eff_bomb	move.l ad_bbomb1,a0
	moveq #3,d2
	bra.s eff_persos0

eff_perso	move.l ad_bpers1,a0
	moveq #3,d2
eff_persos0	moveq #0,d0
	moveq #0,d1
eff_persos1	move.l (a0)+,d3
	bmi.s eff_persos2
	move.l d3,a1
	v_init offset,0
	rept 16
	movem.l d0-d1,offset(a1)
	v_inc offset,160
	endr
eff_persos2	dbra d2,eff_persos1
	rts

