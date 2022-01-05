	movem.l	a0-a2/d0-d2,-(sp)
	lea	nombre(pc),a1
	tst.l	d0
	bne.s	.p_z
	move.b	#'0',(a1)+
	clr.b	(a1)
	bra.s	.sort
.p_z
	lea	nom_mem(pc),a0
	lea	table(pc),a2
	move.l	d0,(a0)
	move.w	#3,d2
.loop	
	move.b	(a0),d1
	lsr.b	#4,d1
	and.l	#$f,d1
	move.b	(a2,d1),(a1)+
	move.b	(a0)+,d1
	and.l	#$f,d1
	move.b	(a2,d1),(a1)+
	dbra	d2,.loop
	clr.b	(a1)

;suppression des zero de d‚buts
.test
	lea	nombre,a1
	move.l	a1,a0
	cmp.b	#'0',(a1)+
	bne.s	.sort
	rept 8
	move.b	(a1)+,(a0)+	
	endr
	bra.s	.test

	
	
.sort
	movem.l	(sp)+,d0-d2/a0-a2
	rts
nom_mem
	ds.l	1
table
	dc.b	'0123456789ABCDEF'
nombre::
	ds.b	100