
bytes_same
	move.l	a0,a2
	move.w	d0,d1
	clr.l	d5
	move.b	(a2),d2
	bra	zasloop
asloop
	cmp.b	(a2)+,d2
	bne	zam_same
	addq.l	#1,d5
zasloop	dbra	d1,asloop
zam_same	rts

	; bytes_different - calculates # of words with no runs of 3 or more
	;	that are the same
bytes_different
	clr.l	d5
	move.l	a0,a2
	move.w	d0,d1
	move.b	(a2),d2
	not.b	d2	; make sure this != last to start loop
	bra	zad_loop
ad_loop	move.b	d3,d4
	move.b	d2,d3
	move.b	(a2)+,d2
	cmp.b	d2,d3
	bne	incad_ct
	cmp.b	d2,d4
	bne	incad_ct  ;takes three in a row to break out of "different"
	subq.l	#2,d5
	bra	zadiff
incad_ct	addq.l	#1,d5
zad_loop	dbra	d1,ad_loop
zadiff	 rts


	public _pack
_pack
firstp	set 4+4*5
s	set	firstp
d	set firstp+4
c	set	firstp+8
	movem.l	a2/d2/d3/d4/d5,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.w	c(sp),d0
plp	bsr	bytes_same
	cmp.w	#2,d5	; if run's less than 3 don't compress it
	blt	diffccl
	sub.w	d5,d0
	adda.w	d5,a0
	subq.w	#1,d5
	neg.w	d5
	move.b	d5,(a1)+
	move.b	d2,(a1)+
	tst.w	d0
	bgt		plp
	bra		zplp
diffccl
	bsr bytes_different
	sub.w	d5,d0
	subq.w	#1,d5
	move.b	d5,(a1)+
cpc move.b	(a0)+,(a1)+
	dbra	d5,cpc
	tst.w	d0
	bgt		plp
zplp
	move.l	a1,d0
	movem.l (sp)+,a2/d2/d3/d4/d5
	rts


	;ravel_line(s, d, linebytes)
	public _ravel_line
_ravel_line
firstp	set 4
s	set firstp
d	set firstp+4
linebytes	set firstp+8
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.w	linebytes(sp),d0
	lsr.w	#1,d0	;byte to word count
	bra	zrvloop
rvloop	move.w	(a0),(a1)+
	add.w	#8,a0
zrvloop	dbra	d0,rvloop
	rts

	;ravel_4line(s, d, linebyte)
	public _ravel_4line
_ravel_4line
rlregs	reg	d2/a2
firstp	set 4+4*2
s	set firstp
d	set firstp+4
linebytes	set firstp+8
	movem.l	rlregs,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.w	linebytes(sp),d0
	asr.w	#1,d0	; byte to word count
	move.w	#3,d2	; planecount - 1
rl_ploop	
	move.l	a0,a2	; scratch copy of source
	move.w	d0,d1	; scratch copy of linewords
	bra	zwordl
wordl	move.w	(a2),(a1)+
	adda	#8,a2
zwordl	dbra	d1,wordl
	adda	#2,a0	; inc source to next plane
	dbra	d2,rl_ploop

	movem.l	(sp)+,rlregs
	rts


