;	:ts=12

	;_do_deltas(s, d)
	public _do_deltas
ddregs	reg d2/d3
firstp	set 4+4*2
s	set firstp
d	set firstp+4
_do_deltas
	movem.l	ddregs,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	add.w	#32,a0	;skip over color map
	move.w	(a0)+,d2
	move.w	d2,d3
	asr.w	#3,d3
	bra	zbddlp
bddlp	
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
zbddlp	dbra	d3,bddlp
	and.w	#7,d2
	bra	zddlp
ddlp	add.w	(a0)+,a1
	move.l	(a0)+,(a1)
zddlp	dbra	d2,ddlp
ddl_return	movem.l	(sp)+,ddregs
	rts


	;make_deltas(screen, last_screen, deltas)
	public _make_deltas
mdregs	 reg	a2/d2/d3/d4
firstp	set	4+4*4
screen	set	firstp
last_screen	set	firstp+4
deltas	set	firstp+8
_make_deltas
	movem.l	mdregs,-(sp)
	move.l	screen(sp),a0
	move.l	last_screen(sp),a1
	move.l	deltas(sp),a2

	clr.w	d2	;clear delta count
	clr.w	d3	;clear screen index
	move.w	#7999,d1	;init longword counter
	add	#2,a2	;skip over delta count in output array
mdloop	move.l	(a0)+,d4
	cmp.l	(a1)+,d4
	bne	mdgot
mdskip	add.w	#4,d3
	dbra	d1,mdloop
	bra	mdend
mdgot
	move.w	d3,(a2)+
	move.l	d4,(a2)+
	add.w	#1,d2
	move.w	#4,d3
	dbra	d1,mdloop

mdend	move.l	deltas(sp),a0
	move.w	d2,(a0)
	move.l	a2,d0
	movem.l	(sp)+,mdregs
	rts


	;calc_dlt_size(screen, last_screen);
	public _calc_dlt_size
_calc_dlt_size
	clr.l	d0
	move.w	#7999,d1	; # of longs in screen minus 1
	move.l	4(sp),a0
	move.l	8(sp),a1
cdlp	cmp.l	(a0)+,(a1)+
	dbne	d1,cdlp
	cmp.w	#-1,d1
	beq	end_cdl
	addq.l	#6,d0
	dbra	d1,cdlp
end_cdl	addq.l	#2,d0
	rts


