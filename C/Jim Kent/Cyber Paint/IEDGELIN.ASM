
;	:ts=12

	public	_blur_out
	public	_blbuf1
	public	_blbuf2
	public	_blbuf3
	public	_ccolor
	public	_scolor

	;iedge_line(count)
	;	do a box-filter edge detect on blbuf1-3 into blur_out
	public	_iedge_line
firstp	set	4*4+4
count	set	firstp
_iedge_line
	movem.l	a2/a3/d2/d3,-(sp)

	move.l	_blur_out,a0
	move.l	_blbuf1,a1
	move.l	_blbuf2,a2
	move.l	_blbuf3,a3
	move.w	count(sp),d1
	move.w	_scolor,d2
	move.w	_ccolor,d3
	add	#1,a1
	add	#1,a2
	add	#1,a3
	bra	zbll_loop
bll_loop
	move.b	(a2)+,d0	; fetch center pixel
	cmp.b	d0,d2	; see if it's scolor
	bne	pass
	cmp.b	(a1),d0	;compare to upper pixel
	bne	edge
	cmp.b	(a3),d0	;compare to lower pixel
	bne	edge
	cmp.b	-2(a2),d0	; compare to left pixel
	bne	edge
	cmp.b	(a2),d0	; compare to right pixel
	bne	edge
	bra	pass
edge	move.b	d3,d0	; if on edge use edging color
pass	move.b	d0,(a0)+
	add	#1,a1
	add	#1,a3
zbll_loop	dbra	d1,bll_loop

gohome

	movem.l	(sp)+,d2/d3/a2/a3
	rts

