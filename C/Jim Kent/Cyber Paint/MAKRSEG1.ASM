;	:ts=10

	; fill_sbuf(thread, segment)

	public _fill_sbuf
firstp	set	5*2+4
thread	set	firstp
segment	set	firstp+4
_fill_sbuf
	movem.w	d3/d4/d5/d6/d7,-(sp)
	move.l	thread(sp),a0
	move.l	segment(sp),a1
	move.w	(a0)+,d7	;get count of elt's in thread

sloop	
	subq.w	#1,d7
	beq	zfill_sbuf	; here there's nothing but horizontals.
	move.w	6(a0),d0
	cmp.w	2(a0),d0
	bne	past_hor
	adda.w	#4,a0
	bra 	sloop
past_hor
	move.w	(a0),(a1)		; set x of first point
	adda.w	#12,a1		; go to next segment
	bra	zfsloop

fsloop	; set up a "y-only" dda
	move.w	6(a0),d5	; set up dy in d5 and skip line if dy = 0
	sub.w	2(a0),d5
	beq	nextsource
	;bpl	dypos	; this line and next unnecessary since know
	;neg.w	d5	; going from low y to hi ... 
dypos	move.w	d5,d6		; keep dot count in d6
	move.w	#1,d1	; x step increment in d1
	move.w	4(a0),d4	; set up dx in d4
	move.w	0(a0),d0  ; keep x position in d0
	sub.w	d0,d4
	bpl	dxpos
	neg.w	d4
	neg.w	d1
dxpos	move.w	d5,d3	; d3 = error term = dx - dy/2
	asr.w	#1,d3
	neg.w	d3
	add.w	d4,d3
	bra	zydda
ydda
	tst.w	d3
xloop	ble	zxloop
	add.w	d1,d0	; increment x
	sub.w	d5,d3
	bra	xloop
zxloop	move.w	d0,(a1)
	adda.w	#12,a1
	add.w	d4,d3
zydda	dbra	d6,ydda

nextsource adda.w	#4,a0
zfsloop	dbra	d7,fsloop
zfill_sbuf
	movem.w	(sp)+,d3/d4/d5/d6/d7
	rts



