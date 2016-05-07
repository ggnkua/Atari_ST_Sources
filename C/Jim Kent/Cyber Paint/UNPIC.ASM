
;	:ts=12


	;unpack_screen(s, d, linebytes, planes, lines)
	public _unpack_screen
_unpack_screen
upregs	reg	a0/a1/a2/a3/a4/a5/d1/d2/d3/d4/d5/d6/d7
firstp	set	4+4*13
s	set	firstp
d	set	firstp+4
linebytes	set	firstp+8
planes	set	firstp+10
lines	set	firstp+12
	movem.l	upregs,-(sp) ;save the world!
	move.l	s(sp),a0
	move.l	d(sp),a5
	move.w	linebytes(sp),d7
	move.w	planes(sp),d6
	move.w	lines(sp),d5
	sub.w	d7,sp	;make us a buffer
	move.l	sp,a3
	add.w	d7,a3	;point a3 to end of buffer
	move.w	d6,d4
	add.w	d4,d4	;next word in d4
	move.w	d6,d3
	mulu	d7,d3	;next line in d3


	bra 	zloop1
loop1
	move.l	a5,a4; start of this line of screen
	move.w	d6,d2; plane count in d3
	bra	zloop2
loop2

;get ready to un-run-length encode one line of one bitplane
	move.l	sp,a1
oploop	clr.w	d1	
	move.b	(a0)+,d1	;get next op
	bmi	repeatop	;if it's minus repeat value...
opcplp	move.b	(a0)+,(a1)+	;if it's plus copy data (op+1) times
	dbra	d1,opcplp
	cmp.l	a3,a1	;go until run out of line buffer
	blt	oploop
	bra	zoploop
repeatop	neg.b	d1
	move.b	(a0)+,d0
oprptlp	move.b	d0,(a1)+
	dbra	d1,oprptlp
	cmp.l	a3,a1	;go until run out of line buffer
	blt	oploop
zoploop	

;Now do that interleave for the twisted ST screen, copying from little
;line buffer on stack to the screen itself.
	move.l	sp,a1
	move.l	a4,a2
	move.w	d7,d0
	lsr.w	#1,d0
	bra 	zurvloop
urvloop	move.w	(a1)+,(a2)
	add.w	d4,a2
zurvloop	dbra	d0,urvloop
	add.w	#2,a4	;go to next plane of dest
zloop2	dbra	d2,loop2
	add.w	d3,a5
zloop1	dbra	d5,loop1

	add.w	d7,sp	;buffer off of stack.

	movem.l	(sp)+,upregs
	rts



