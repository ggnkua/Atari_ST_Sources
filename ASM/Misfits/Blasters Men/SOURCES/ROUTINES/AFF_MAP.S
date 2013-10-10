aff_carte	move.l ad_map,a0
	move.l ad_atb,a1
	lea decors+34,a2
	move.l screen1,a3
	lea tmp_atb,a5
	lea players,a6
	moveq #0,d6
	moveq #0,d4
	moveq #11,d0		12 blk de hauts
aff_cartes1	moveq #19,d1		20 blk de large
	moveq #0,d5
aff_cartes2	move.w (a0)+,d2
	moveq #0,d3
	move.b (a1)+,d3
	cmp.w #128,d3		perso 1 ?
	blt.s aff_cartes3
	cmp.w #131,d3		perso 4 ?
	bhi.s aff_cartes3
	sub.w #128,d3
	mulu #lg_play,d3
	move.w d5,crd_x(a6,d3.w)
	move.w d4,crd_y(a6,d3.w)
	moveq #0,d2
	moveq #0,d3
	bra.s aff_cartes5
aff_cartes3	cmp.w #2,d3		blk destructible ?
	bne.s aff_cartes5
	addq.w #1,d6
aff_cartes5	move.b d3,(a5)+
	mulu #128,d2
	lea (a2,d2.w),a4
	v_init offset,0
	rept 16
	move.l (a4)+,offset+0(a3)
	move.l (a4)+,offset+4(a3)
	v_inc offset,160
	endr
	addq.w #8,a3
	addq.w #1,d5
	dbra d1,aff_cartes2
	lea 15*160(a3),a3
	addq.w #1,d4
	dbra d0,aff_cartes1
	move.w d6,nb_blk
	rts
