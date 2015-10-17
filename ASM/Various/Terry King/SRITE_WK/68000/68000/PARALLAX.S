
	bra	setup_parallax
	bra	plot_parallax
	bra	move_parallax

	opt o+
		
move_parallax
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0
	move	62(a7),d1
	move	nstars(pc),d7
	lea	stars(pc),a4
	lea	limits(pc),a5
	and.l	#$ffff,d7
	divu	#3,d7
	subq	#1,d7
	move	d7,d6
	swap	d0
	swap	d1
	clr	d0
	clr	d1
	asr.l	#2,d0
	asr.l	#2,d1
.lp1	bsr.s	add
	dbf	d6,.lp1
	add.l	d0,d0
	add.l	d1,d1
	move	d7,d6
.lp2	bsr.s	add
	dbf	d6,.lp2
	add.l	d0,d0
	add.l	d1,d1
	move	d7,d6
.lp3	bsr.s	add
	dbf	d6,.lp3
	movem.l	(a7)+,d1-7/a0-6
	rts

add	move.l	(a4),d2
	swap	d2
	add.l	d0,d2
	swap	d2
	cmp	(a5),d2
	blt.s	.left
	cmp	4(a5),d2
	bgt.s	.right
.ret1	move.l	d2,(a4)+
	move.l	(a4),d2
	swap	d2
	add.l	d1,d2
	swap	d2
	cmp	2(a5),d2
	blt.s	.up
	cmp	6(a5),d2
	bgt.s	.down
.ret2	move.l	d2,(a4)+
	rts
.left	add	8(a5),d2
	bra.s	.ret1
.right	sub	8(a5),d2
	bra.s	.ret1
.up	add	10(a5),d2
	bra.s	.ret2
.down	sub	10(a5),d2
	bra.s	.ret2

plot_parallax
	movem.l	d1-7/a0-6,-(a7)
	move.l	60(a7),a1
	move	nstars(pc),d7
	lea	stars(pc),a4
	and.l	#$ffff,d7
	divu	#3,d7
	subq	#1,d7
	move	d7,d6
.lp1	move.l	(a4)+,d0
	move.l	(a4)+,d1
	moveq	#1,d2
	bsr.s	plot
	dbf	d6,.lp1
	move	d7,d6
.lp2	move.l	(a4)+,d0
	move.l	(a4)+,d1
	moveq	#2,d2
	bsr.s	plot
	dbf	d6,.lp2
	move	d7,d6
.lp3	move.l	(a4)+,d0
	move.l	(a4)+,d1
	moveq	#3,d2
	bsr.s	plot
	dbf	d6,.lp3
	movem.l	(a7)+,d1-7/a0-6
	rts

* d0=x d1=y d2=colour a0=screen

plot	move.l	a1,a0
	and.l	#$ffff,d0
	and.l	#$ffff,d1
	move	d1,d3
	asl	#2,d1
	add	d3,d1
	asl.l	#5,d1
	move	d0,d3
	lsr	#1,d3
	and	#$fff8,d3
	add	d3,a0
	add.l	d1,a0
	and	#$f,d0
	asl	#2,d0
	move.l	pixmask(pc,d0),d0
	cmp	#2,d2
	blt.s	colour1
	beq.s	colour2
colour3	or.l	d0,(a0)
	rts
colour1	or	d0,(a0)
	rts
colour2	or	d0,2(a0)
	rts
off_screen
	rts
	
pixmask	dc.l	$80008000,$40004000,$20002000,$10001000
	dc.l	$08000800,$04000400,$02000200,$01000100
	dc.l	$00800080,$00400040,$00200020,$00100010
	dc.l	$00080008,$00040004,$00020002,$00010001
	
setup_parallax
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7
	cmp	#200,d7
	ble.s	.ok
	move	#200,d7
.ok	movem	62(a7),d0-3
	lea	stars(pc),a4
	lea	limits(pc),a5
	movem	d0-3,(a5)	; xmin,ymin,xmax,ymax
	exg	d0,d2
	exg	d1,d3
	sub	d2,d0
	addq	#1,d0
	move	d0,8(a5)	; width
	sub	d3,d1
	addq	#1,d1
	move	d1,10(a5)	; height
	subq	#1,d0
	subq	#1,d1
	move.l	#65536,d3
	move.l	d3,d4
	divu	d0,d3		
	divu	d1,d4
	
	lea	nstars(pc),a0
	move	d7,(a0)+
	subq	#1,d7
.lp	move	d3,d5
	bsr.s	random
	and.l	#$ffff,d0
	add	(a5),d0
	move.l	d0,(a4)+
	move	d4,d5
	bsr.s	random
	and.l	#$ffff,d0
	add	2(a5),d0
	move.l	d0,(a4)+
	dbf	d7,.lp
	movem.l	(a7)+,d1-7/a0-6
	rts

random	move	#17,-(a7)
	trap	#14
	addq	#2,a7
	and.l	#$ffff,d0
	divu	d5,d0
	rts
	
nstars	ds.w	1	

limits	dc.w	16
	dc.w	16
	dc.w	159
	dc.w	99
	dc.w	160-16
	dc.w	100-16

stars	ds.b	200*8