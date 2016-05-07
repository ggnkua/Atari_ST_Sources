
;	:ts=12

	public	_blur_out
	public	_blbuf1
	public	_blbuf2
	public	_blbuf3

	;shatter_line(count)
	;	do a box-filter addition on blbuf1-3 into blur_out
	public	_shatter_line
firstp	set	3*4+4
count	set	firstp
_shatter_line
	movem.l	a2/a3/d2,-(sp)

	move.l	_blur_out,a0
	move.l	_blbuf1,a1
	move.l	_blbuf3,a3
	move.w	count(sp),d1
	lsr.w	#1,d1	; 2 at a time...
	add	#1,a1
	add	#1,a3
	bra	zbll_loop
bll_loop
	move.b	(a1)+,(a0)+
	add	#1,a3
	move.b	(a3)+,(a0)+
	add	#1,a1
zbll_loop	dbra	d1,bll_loop

	movem.l	(sp)+,a2/a3/d2
	rts

