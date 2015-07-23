colorin	move.w #0,d7

bo_in	rept 3
	vsync
	endr
	move.w d7,d0
	move.l a6,a0
	bsr.s fade
	addq.w #1,d7
	cmp.w #8,d0
	ble.s bo_in
	
	rts

colorout	move.w #8,d7

bo_out	rept 3
	vsync
	endr
	move.w d7,d0
	move.l a6,a0
	bsr.s fade
	subq.w #1,d7
	tst.w d0
	bge.s bo_out

	rts

fade	lea $ffff8240.w,a1
	move.w #15,d1

loopf	move.w (a0)+,d2
	move.w d2,d3
	lsr.w #8,d3
	and.w #15,d3
	move.w d2,d4
	lsr.w #4,d4
	and.w #15,d4
	move.w d2,d5
	and.w #15,d5
	muls d0,d3
	divs #8,d3
	lsl.w #8,d3
	muls d0,d4
	divs #8,d4
	lsl.w #4,d4
	muls d0,d5
	divs #8,d5
	move.w d3,d2
	add.w d4,d2
	add.w d5,d2
	move.w d2,(a1)+
	dbf d1,loopf
	rts
