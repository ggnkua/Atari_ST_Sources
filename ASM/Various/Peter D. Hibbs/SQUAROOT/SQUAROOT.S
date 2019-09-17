;Calculate square root of 32 bit Number in d0.l
;ENTRY d0.l holds longword to find square root of
;EXIT  d0.w holds 16 bit square root value

square_root	tst.l	d0
	beq	square_root2	if d0=0 then d0=square root 0

	movem.l	d1-d2,-(sp)
	move	#31,d2
square_root1	btst	d2,d0
	dbne	d2,square_root1
	lsr	#1,d2
	bset	d2,d2
	move.l	d0,d1
	divs	d2,d1
	add	d1,d2
	lsr	#1,d2
	move.l	d0,d1
	divs	d2,d1
	add	d1,d2
	
	lsr	#1,d2
	move.l	d0,d1
	divs	d2,d1
	add	d1,d2
	
	lsr	#1,d2
	clr.l	d0
	move	d2,d0
	movem.l	(sp)+,d1-d2
square_root2	rts
