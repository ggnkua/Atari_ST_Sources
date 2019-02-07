
	cseg

;	signed scale by  sscale_by( unscaled, p, q)
	public	_sscale_by
_sscale_by:
	move.w 6(sp),d0
	move.w 8(sp),d1
	cmp.w d1,d0
	beq.s ssb_trivial
	muls 4(sp),d0
	divs d1,d0
	rts
ssb_trivial:
	move.w 4(sp),d0
	rts

;	unsigned scale by  uscale_by( unscaled, p, q)
	public	_uscale_by
_uscale_by:
	move.w 6(sp),d0
	move.w 8(sp),d1
	cmp.w d1,d0
	beq.s usb_trivial
	mulu 4(sp),d0
	divu d1,d0
	rts
usb_trivial:
	move.w 4(sp),d0
	rts

;	unsigned scale by  ruscale_by( unscaled, p, q)
	public	_ruscale_by
_ruscale_by:
	move.w 6(sp),d0
	move.w 8(sp),d1
	cmp.w d1,d0
	beq.s usb_trivial
	mulu 4(sp),d0
	move.w	d1,d2
	lsr.w	#1,d2
	ext.l	d2
	add.l	d2,d0
	divu d1,d0
	rts

	END

