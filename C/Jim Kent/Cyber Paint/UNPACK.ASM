
;	:ts=12

	;unpack_line(s, d, linebytes)
	public _unpack_line
_unpack_line
firstp	set	4+4*1
s	set	firstp
d	set	firstp+4
linebytes	set	firstp+8
	movem.l	upregs,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.l	a1,a2
	adda.w	linebytes(sp),a2
	bra	oploop

	;unpack(s, d, linebytes, lines)
	public _unpack
_unpack	
upregs	reg	a2
firstp	set	4+4*1
s	set	firstp
d	set	firstp+4
linebytes	set	firstp+8
lines	set 	firstp+10
	movem.l	upregs,-(sp)

	move.l	s(sp),a0
	move.l	d(sp),a1
	move.w	linebytes(sp),d0
	mulu	lines(sp),d0
	move.l	a1,a2
	adda.l	d0,a2	;a2 is the end ... 

oploop	clr.w	d1
	move.b	(a0)+,d1
	bmi	repeatop
opcplp	move.b	(a0)+,(a1)+
	dbra	d1,opcplp
	cmp.l	a2,a1
	blt	oploop
	bra	end_unpack
repeatop	neg.b	d1
	move.b	(a0)+,d0
oprptlp	move.b	d0,(a1)+
	dbra	d1,oprptlp
	cmp.l	a2,a1
	blt	oploop

end_unpack	
	move.l	a0,d0
	movem.l	(sp)+,upregs
	rts




	;unravel_line(s, d, linebytes)
	public _unravel_line
_unravel_line
firstp	set 4
s	set firstp
d	set firstp+4
linebytes	set firstp+8
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.w	linebytes(sp),d0
	lsr.w	#1,d0	;byte to word count
	bra	zurvloop
urvloop	move.w	(a0)+,(a1)
	add.w	#8,a1
zurvloop	dbra	d0,urvloop
	rts


	;unravelst(s, d, linebytes, lines, depth);
	public _unravelst
_unravelst
urregs	reg	a2/a3/d2/d4/d5/d6
firstp	set	4+4*6
s	set	firstp
d	set	firstp+4
linebytes	set	firstp+8
lines	set 	firstp+10
depth	set	firstp+12
	movem.l	urregs,-(sp)

	move.l	s(sp),a0
	move.l	d(sp),a1
	move.w	linebytes(sp),d0
	move.w	lines(sp),d1
	move.w	depth(sp),d2
	move.w	d0,d4
	add.w	d4,d4
	add.w	d4,d4	; offset to next line of dest in d4
	asr.w	#1,d0	; convert linebytes to linewords
	bra	zlineloop
lineloop	move.l	a1,a2	; peel off another copy of dest
	move.w	d2,d5	; a plane counter
	bra	zplanelp
planelp	move.l	a2,a3
	move.w	d0,d6
	bra	zwordlp
wordlp	move.w	(a0)+,(a3)
	add.w	#8,a3
zwordlp	dbra	d6,wordlp
	add.w	#2,a2
zplanelp	dbra	d5,planelp
	adda.w	d4,a1
zlineloop	dbra	d1,lineloop

	movem.l	(sp)+,urregs
	rts


