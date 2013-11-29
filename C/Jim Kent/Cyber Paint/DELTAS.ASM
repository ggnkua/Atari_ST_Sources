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
	bmi	ddl_literal
	move.w	d2,d3
	asr.w	#3,d3
	bra	zbddlp
bddlp	
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
zbddlp	dbra	d3,bddlp
	and.w	#7,d2
	bra	zddlp
ddlp 	move.w	(a0)+,d0
	move.l	(a0)+,d1
	eor.l	d1,0(a1,d0)
zddlp	dbra	d2,ddlp
ddl_return	movem.l	(sp)+,ddregs
	rts

ddl_literal	move.w	#999,d0	; xor a screen basically... 
ddllbl	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	move.l	(a0)+,d1
	eor.l	d1,(a1)+
	dbra	d0,ddllbl
	bra	ddl_return

	; make_literal_xor(screen, last_screen, deltas)
	public _make_literal_xor
mlregs	 reg	a2
firstp	set	4+4*1
screen	set	firstp
last_screen	set	firstp+4
deltas	set	firstp+8
_make_literal_xor
	movem.l	mlregs,-(sp)
	move.l	screen(sp),a0
	move.l	last_screen(sp),a1
	move.l	deltas(sp),a2
	move.w	#7999,d0	; screen long word count - 1
	move.w	#$ffff,(a2)+
mlxorlp	move.l	(a0)+,d1
	move.l	(a1)+,d2
	eor.l	d1,d2
	move.l	d2,(a2)+
	dbra	d0,mlxorlp
	move.l	a2,d0
	movem.l	(sp)+,mlregs
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
	move.l	(a1)+,d0
	eor.l	d4,d0
	beq	mdskip
	move.w	d3,(a2)+
	move.l	d0,(a2)+
	add.w	#1,d2
mdskip	add.w	#4,d3
	dbra	d1,mdloop
	tst.w	d2
	bne	mdgotone
	clr.w	(a2)+
	clr.l	(a2)+
	move.w	#1,d2
mdgotone	move.l	deltas(sp),a0
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
end_cdl	tst.l	d0
	bne	gotone
	move.w	#6,d0
gotone	addq.l	#2,d0
	rts


	; exp_dlts(source, dest)
	;    expand a 32K "literal" delta to a normal delta
	public _exp_dlts
_exp_dlts
firstp	set	4+4*3
source	set	firstp
dest	set	firstp+4
expdregs	reg	d2/d3/d4
	movem.l	expdregs,-(sp)

	move.l	source(sp),a0
	move.l	dest(sp),a1
	clr.w	d0
	move.w	#8000-1,d1
	clr.w	d2
expdlp	move.l	(a0)+,d3
	beq	exskip
	move.w	d2,(a1)+
	move.l	d3,(a1)+
	addq.w	#1,d0
exskip	addq.w	#4,d2
	dbra	d1,expdlp

	movem.l	(sp)+,expdregs
	rts

	;ctr_dlts(dlt_pt, uscreen);
	;	"contract deltas"
	; transform from delta representation to "literal xor"
	; representation
	public _ctr_dlts
firstp	set	4+4*2
source	set	firstp
dest	set	firstp+4
ctrdregs	reg	d2/d3
_ctr_dlts
	movem.l	ctrdregs,-(sp)

	move.l	source(sp),a0
	move.l	dest(sp),a1
	move.w	(a0)+,d0	; get delta count
	bra	zctlp
ctlp	move.w	(a0)+,d1
	move.l	(a0)+,d2
	eor.l	d2,0(a1,d1.w)
zctlp	dbra	d0,ctlp
	movem.l	(sp)+,ctrdregs
	rts

