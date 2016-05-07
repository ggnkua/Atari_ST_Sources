
;	:ts=12

	public	_blur_out
	public	_blbuf1
	public	_blbuf2
	public	_blbuf3

	;life_line(count)
	;	do a box-filter addition on blbuf1-3 into blur_out
	public	_life_line
firstp	set	2*4+4
count	set	firstp
_life_line
	movem.l	a2/a3,-(sp)

	move.l	_blur_out,a0
	move.l	_blbuf1,a1
	move.l	_blbuf2,a2
	move.l	_blbuf3,a3
	move.w	count(sp),d1
	add	#1,a1
	add	#1,a3
	bra	zbll_loop
bll_loop
	move.b	(a1)+,d0	;get to upper pixel
	add.b	(a3)+,d0	;add to lower pixel
	add.b	(a2)+,d0	; add to left pixel
	add.b	1(a2),d0	; add to right pixel
	and.b	#15,d0	;mask it down to 0-15
pass	move.b	d0,(a0)+
zbll_loop	dbra	d1,bll_loop

gohome

	movem.l	(sp)+,a2/a3
	rts

