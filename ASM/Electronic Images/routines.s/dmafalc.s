
	tst.w	4(a7)
	beq	lF0D8A
	bset	#7,$FF8901
	bra	lF0D92
lF0D8A	bclr	#7,$FF8901
lF0D92	clr.w	d0
	move.b	9(a7),d0
	move.w	d0,$FF8906
	move.b	8(a7),d0
	move.w	d0,$FF8904
	move.b	7(a7),d0
	move.w	d0,$FF8902
	move.b	$D(a7),d0
	move.w	d0,$FF8912
	move.b	$C(a7),d0
	move.w	d0,$FF8910
	move.b	$B(a7),d0
	move.w	d0,$FF890E
	clr.l	d0
	rts
	move.w	4(a7),d0
