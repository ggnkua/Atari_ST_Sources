* a0=texte, d0=x, d1=y

aff_texte	movem.l screen1,a5-a6
	lea fonte,a3
	mulu #160,d1
	move.w d0,d2
	and.w #$fff0,d0
	lsr.w #1,d0
	add.w d0,d1
	addq.w #4,d1
	add.w d1,a5
	add.w d1,a6
	move.l #$00070001,d7
	move.l d7,d6
	move.w d2,d5
aff_ts0	btst #3,d2
	beq.s aff_ts4
	add.w d7,a5
	add.w d7,a6
	swap d7
aff_ts4	move.l a5,a1
	move.l a6,a2
aff_ts1	moveq #0,d0
	move.b (a0)+,d0
	bne.s aff_ts2
	rts
aff_ts2	cmp.w #$0a,d0
	bne.s aff_ts3
	lea 8*160(a5),a5
	lea 8*160(a6),a6
	move.l d6,d7
	move.w d5,d2
	bra.s aff_ts0
aff_ts3	cmp.w #31,d0
	ble.s aff_ts1
	sub.w #32,d0
	move.w d0,d1
	add.w d0,d0
	add.w d0,d0
	add.w d0,d0
	sub.w d1,d0
	lea (a3,d0.w),a4
	v_init offset,0
	rept 7
	move.b (a4),offset+0(a1)
	move.b (a4)+,offset+0(a2)
	v_inc offset,160
	endr
	add.w d7,a1
	add.w d7,a2
	swap d7
	bra.s aff_ts1

