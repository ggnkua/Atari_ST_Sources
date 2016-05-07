
;	:ts=12

	public	_blur_out
	public	_blbuf1
	public	_blbuf2
	public	_blbuf3

	;edge_line(count)
	;	do a box-filter edge detect on blbuf1-3 into blur_out
	public	_edge_line
firstp	set	2*4+4
count	set	firstp
_edge_line
	movem.l	a2/a3,-(sp)

	move.l	_blur_out,a0
	move.l	_blbuf1,a1
	move.l	_blbuf2,a2
	move.l	_blbuf3,a3
	move.w	count(sp),d1
	add	#1,a1
	add	#1,a2
	add	#1,a3
	bra	zbll_loop
bll_loop
	move.b	(a2)+,d0	; fetch center pixel
	cmp.b	(a1)+,d0	;compare to upper pixel
	bne	pass
	cmp.b	(a3),d0	;compare to lower pixel
	bne	pass
	cmp.b	-2(a2),d0	; compare to left pixel
	bne	pass
	cmp.b	(a2),d0	; compare to right pixel
	bne	pass
	clr.b	d0
pass	move.b	d0,(a0)+
	add	#1,a3
zbll_loop	dbra	d1,bll_loop

gohome

	movem.l	(sp)+,a2/a3
	rts

