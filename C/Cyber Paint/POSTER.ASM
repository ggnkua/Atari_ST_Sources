;:ts=10


	public _poster_screen	
	;	poster_screen()
firstp	set	3*4+4
screen	set	firstp
pregs	reg	a2/d2/d3
_poster_screen
	movem.l	pregs,-(sp)
	move.l	#post2_tab,a1
	move.l	_cscreen,a0
	move.l	#100-1,d2
	clr.w	d1

pline
	move.w	#160-1,d0
ploop
	move.b	(a0),d1
	move.b	0(a1,d1),d1
	move.b	d1,160(a0)
	move.b	d1,(a0)+
	dbra	d0,ploop

	add	#160,a0
	dbra	d2,pline

postret
	movem.l	(sp)+,pregs
	rts


	dseg

	public _cscreen

post2_tab
	dc.b $0,$0,$3,$3,$0,$0,$3,$3
	dc.b $c,$c,$f,$f,$c,$c,$f,$f
	dc.b $0,$0,$3,$3,$0,$0,$3,$3
	dc.b $c,$c,$f,$f,$c,$c,$f,$f
	dc.b $30,$30,$33,$33,$30,$30,$33,$33
	dc.b $3c,$3c,$3f,$3f,$3c,$3c,$3f,$3f
	dc.b $30,$30,$33,$33,$30,$30,$33,$33
	dc.b $3c,$3c,$3f,$3f,$3c,$3c,$3f,$3f
	dc.b $0,$0,$3,$3,$0,$0,$3,$3
	dc.b $c,$c,$f,$f,$c,$c,$f,$f
	dc.b $0,$0,$3,$3,$0,$0,$3,$3
	dc.b $c,$c,$f,$f,$c,$c,$f,$f
	dc.b $30,$30,$33,$33,$30,$30,$33,$33
	dc.b $3c,$3c,$3f,$3f,$3c,$3c,$3f,$3f
	dc.b $30,$30,$33,$33,$30,$30,$33,$33
	dc.b $3c,$3c,$3f,$3f,$3c,$3c,$3f,$3f
	dc.b $c0,$c0,$c3,$c3,$c0,$c0,$c3,$c3
	dc.b $cc,$cc,$cf,$cf,$cc,$cc,$cf,$cf
	dc.b $c0,$c0,$c3,$c3,$c0,$c0,$c3,$c3
	dc.b $cc,$cc,$cf,$cf,$cc,$cc,$cf,$cf
	dc.b $f0,$f0,$f3,$f3,$f0,$f0,$f3,$f3
	dc.b $fc,$fc,$ff,$ff,$fc,$fc,$ff,$ff
	dc.b $f0,$f0,$f3,$f3,$f0,$f0,$f3,$f3
	dc.b $fc,$fc,$ff,$ff,$fc,$fc,$ff,$ff
	dc.b $c0,$c0,$c3,$c3,$c0,$c0,$c3,$c3
	dc.b $cc,$cc,$cf,$cf,$cc,$cc,$cf,$cf
	dc.b $c0,$c0,$c3,$c3,$c0,$c0,$c3,$c3
	dc.b $cc,$cc,$cf,$cf,$cc,$cc,$cf,$cf
	dc.b $f0,$f0,$f3,$f3,$f0,$f0,$f3,$f3
	dc.b $fc,$fc,$ff,$ff,$fc,$fc,$ff,$ff
	dc.b $f0,$f0,$f3,$f3,$f0,$f0,$f3,$f3
	dc.b $fc,$fc,$ff,$ff,$fc,$fc,$ff,$ff
