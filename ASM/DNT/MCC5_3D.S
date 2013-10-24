	text
begin
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	move.l	d0,2(a7)
	bsr	main
	trap	#1
	clr.w	(a7)
	trap	#1
main	bsr	savest
	bsr	setst
loop	bsr	scrswap
	bsr	vsync
	bsr	changero
	bsr	cls
	bsr	setmatri
	lea	points3d,a0
	lea	rotatedp,a1
	bsr	rotate
	lea	rotatedp,a0
	lea	points2d,a1
	bsr	project
	lea	planes3d,a0
	lea	planes2d,a1
	lea	points2d,a2
	lea	points,a3
	bsr	makepoly
	lea	planes2d,a0
	lea	points,a1
	bsr	drawobje
	move.b	$fffffc02.w,d0
	cmp.b	#$39,d0
	beq	mexit
	cmp.b	#$4b,d0
	bne.s	l0002
	cmpi.b	#$1f,angleste
	bge	loop
	addq.b	#1,angleste
	bra	loop
l0002	cmp.b	#$4d,d0
	bne.s	l0003
	cmpi.b	#$e1,angleste
	ble	loop
	subq.b	#1,angleste
	bra	loop
l0003	cmp.b	#$48,d0
	bne.s	l0004
	cmpi.w	#$12c,zoffs
	bge	loop
	addq.w	#1,zoffs
	bra	loop
l0004	cmp.b	#$50,d0
	bne.s	l0005
	cmpi.w	#$14,zoffs
	ble	loop
	subq.w	#1,zoffs
	bra	loop
l0005	cmp.b	#$47,d0
	bne.s	l0006
	clr.b	angleste
	bra	loop
l0006	cmp.b	#$2a,d0
	bne.s	l0007
	cmpi.w	#$1e,pers
	ble	loop
	subq.w	#1,pers
	bra	loop
l0007	cmp.b	#$36,d0
	bne.s	l0008
	cmp.w	#$190,d0
	bge	loop
	addq.w	#1,pers
	bra	loop
l0008	cmp.b	#$2d,d0
	bne.s	l0009
	move.w	#2,axis
	bra	loop
l0009	cmp.b	#$2c,d0
	bne.s	l000a
	move.w	#1,axis
	bra	loop
l000a	cmp.b	#$15,d0
	bne.s	l000b
	move.w	#0,axis
	bra	loop
l000b	bra	loop
mexit	bsr	restores
	rts

setst	lea	$70000,a1
	lea	pict,a0
	bsr	unpc
	lea	$70000,a0
	lea	$78000,a1
	move.l	a0,scr1
	move.l	a1,scr2
	move.w	#$1f3f,d0
l000e	move.l	(a0)+,(a1)+
	dbf	d0,l000e
	move.b	#2,$ffff820a.w
	move.b	#0,$ffff8260.w
	movem.l	newpal,d0-d4
	movem.l	d0-d4,$ffff8240.w
ret	rts

unpc	cmpi.b	#$80,(a0)
	bne.s	ret
	move.l	a0,-(a7)
	lea	34(a0),a0
	clr.w	d0
	clr.w	d1
	clr.w	d2
	moveq	#1,d3
l81eea	move.b	(a0)+,d4
	bmi.s	l81f02
	ext.w	d4
	add.w	d4,d2
l81ef2	move.b	(a0)+,(a1)
	lea	0(a1,d3.w),a1
	eori.w	#6,d3
	dbf	d4,l81ef2
	bra.s	l81f18
l81f02	neg.b	d4
	ext.w	d4
	add.w	d4,d2
	move.b	(a0)+,d5
l81f0a	move.b	d5,(a1)
	lea	0(a1,d3.w),a1
	eori.w	#6,d3
	dbf	d4,l81f0a
l81f18	addq.w	#1,d2
	cmp.w	#$28,d2
	bne.s	l81f36
	clr.w	d2
	lea	-158(a1),a1
	addq.w	#1,d1
	cmp.w	#4,d1
	bne.s	l81f36
	clr.w	d1
	lea	152(a1),a1
	addq.w	#1,d0
l81f36	cmp.w	#$c8,d0
	bne.s	l81eea
	movea.l	(a7)+,a0
	movem.l	22(a0),d0-d2
	movem.l	d0-d2,$ffff8254.w
	rts

cls	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	move.w	#$59,d7
	movea.l	scr2,a0
	adda.l	#$5780,a0
l0018	movem.l	a1-a3/d0-d6,-(a0)
	movem.l	a1-a3/d0-d6,-(a0)
	movem.l	a1-a3/d0-d6,-(a0)
	movem.l	a1-a3/d0-d6,-(a0)
	dbf	d7,l0018
	rts

scrswap	movem.l	scr1,d0-d1
	move.l	d1,scr1
	move.l	d0,scr2
	lsr.w	#8,d1
	move.l	d1,$ffff8200.w
	rts

vsync	move.l	$466.w,d0
l001b	cmp.l	$466.w,d0
	beq.s	l001b
	rts

changero	move.w	anglez,d0
	add.b	angleste,d0
	move.w	d0,anglez
	rts

axis	dc.b	0,0
angleste	dc.b	0,0
anglez	dc.b	0,0
rotmtrx	dc.b	$10,0,0,0,0,0,0,0
	dc.b	$10,0,0,0,0,0,0,0
	dc.b	$10,0
xoffs	dc.b	0,0
yoffs	dc.b	0,0
zoffs	dc.b	0,$1e
setmatri	move.w	anglez,d0
	move.w	d0,d1
	addi.w	#$40,d1
	andi.w	#$ff,d1
	add.w	d0,d0
	add.w	d1,d1
	lea	sinus,a0
	move.w	0(a0,d0.w),d0
	move.w	0(a0,d1.w),d1
	lea	rotmtrx(pc),a0
	cmpi.w	#1,axis
	bmi	axx
	bgt	axz
	move.w	d1,(a0)+
	clr.w	(a0)+
	move.w	d0,(a0)+
	clr.w	(a0)+
	move.w	#$1000,(a0)+
	clr.w	(a0)+
	neg.w	d0
	move.w	d0,(a0)+
	clr.w	(a0)+
	move.w	d1,(a0)+
	rts

axx	move.w	d1,(a0)+
	move.w	d0,(a0)+
	clr.w	(a0)+
	neg.w	d0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	move.w	#$1000,(a0)+
	rts

axz	move.w	#$1000,(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	move.w	d1,(a0)+
	move.w	d0,(a0)+
	clr.w	(a0)+
	neg.w	d0
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	rts

rotate	move.w	numpoint,d7
	subq.w	#1,d7
	beq.s	rotexit
rotloop	lea	rotmtrx(pc),a2
	movem.w	(a0)+,d0-d2
	move.w	(a2)+,d3
	muls	d0,d3
	move.l	d3,d4
	move.w	(a2)+,d3
	muls	d1,d3
	add.l	d3,d4
	move.w	(a2)+,d3
	muls	d2,d3
	add.l	d3,d4
	asl.l	#4,d4
	swap	d4
	add.w	xoffs,d4
	move.w	(a2)+,d3
	muls	d0,d3
	move.l	d3,d5
	move.w	(a2)+,d3
	muls	d1,d3
	add.l	d3,d5
	move.w	(a2)+,d3
	muls	d2,d3
	add.l	d3,d5
	asl.l	#4,d5
	swap	d5
	add.w	yoffs,d5
	move.w	(a2)+,d3
	muls	d0,d3
	move.l	d3,d6
	move.w	(a2)+,d3
	muls	d1,d3
	add.l	d3,d6
	move.w	(a2)+,d3
	muls	d2,d3
	add.l	d3,d6
	asl.l	#4,d6
	swap	d6
	add.w	zoffs,d6
	move.w	d4,(a1)+
	move.w	d5,(a1)+
	move.w	d6,(a1)+
	dbf	d7,rotloop
rotexit	rts

pers	dc.b	0,'d'
project	move.w	numpoint,d7
	subq.w	#1,d7
	bmi.s	prjexit
	move.w	pers,d6
	move.w	#$a0,d3
	moveq	#$64,d4
prjloop	movem.w	(a0)+,d0-d2
	add.w	d6,d2
	muls	d6,d0
	muls	d6,d1
	divs	d2,d0
	divs	d2,d1
	add.w	d3,d0
	neg.w	d1
	add.w	d4,d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbf	d7,prjloop
prjexit	rts

makepoly	movem.w	(a0)+,d0-d1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	subq.w	#1,d1
	bmi.s	mpexit
mploop	move.w	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	movem.w	0(a2,d0.w),d2-d3
	move.w	d2,(a3)+
	move.w	d3,(a3)+
	dbf	d1,mploop
	bra	makepoly
mpexit	rts

drawobje	move.w	(a0)+,color
	move.w	(a0)+,d7
	bmi.s	l0032
	movem.l	a0-a1/d7,-(a7)
	bsr	drawpoly
	movem.l	(a7)+,a0-a1/d7
	add.w	d7,d7
	add.w	d7,d7
	adda.w	d7,a1
	bra.s	drawobje
l0032	rts

drawpoly	movem.w	(a1),d0-d5
	sub.w	d3,d5
	sub.w	d2,d4
	sub.w	d1,d3
	sub.w	d0,d2
	muls	d3,d4
	muls	d2,d5
	cmp.w	d4,d5
	bpl	dpexit
	subq.w	#1,d7
	bmi	dpexit
	suba.w	a4,a4
	lea	clipa,a0
	movem.w	(a1)+,d0-d1
	movem.w	d0-d1,-(a7)
clipxl	movem.w	(a1)+,d2-d3
	tst.w	d7
	bne.s	l0035
	movem.w	(a7)+,d2-d3
l0035	moveq	#0,d4
	moveq	#0,d5
	move.w	clipx1,d6
	cmp.w	d6,d0
	slt	d4
	cmp.w	d6,d2
	slt	d5
	ror.w	#8,d4
	ror.w	#8,d5
	move.w	clipx2,d6
	cmp.w	d6,d0
	sgt	d4
	cmp.w	d6,d2
	sgt	d5
	move.w	d4,d6
	or.w	d5,d6
	beq	xlinenot
	move.w	d4,d6
	and.w	d5,d6
	bne	nextclip
	tst.w	d4
	bne.s	xfirstcl
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.w	#1,a4
	move.w	clipx1,d6
	tst.b	d5
	beq.s	l0036
	move.w	clipx2,d6
l0036	move.w	d6,(a0)+
	sub.w	d0,d6
	move.w	d1,d5
	sub.w	d3,d1
	sub.w	d2,d0
	muls	d1,d6
	divs	d0,d6
	add.w	d5,d6
	move.w	d6,(a0)+
	addq.w	#1,a4
	bra	nextclip
xfirstcl	tst.w	d5
	bne	xbothcli
	move.w	clipx1,d6
	tst.b	d4
	beq.s	l0038
	move.w	clipx2,d6
l0038	move.w	d6,(a0)+
	sub.w	d0,d6
	move.w	d1,d5
	sub.w	d3,d1
	sub.w	d2,d0
	muls	d1,d6
	divs	d0,d6
	add.w	d5,d6
	move.w	d6,(a0)+
	addq.w	#1,a4
	bra	nextclip
xbothcli	moveq	#0,d6
	movea.w	d2,a2
	movea.w	d3,a3
	cmp.w	d0,d2
	bgt.s	l003a
	exg	d2,d0
	exg	d3,d1
	moveq	#$ff,d6
l003a	movea.w	d1,a5
	move.w	d3,d5
	move.w	d2,d4
	sub.w	d0,d4
	sub.w	d1,d5
	move.w	clipx1,d2
	move.w	d0,d3
	sub.w	d0,d2
	muls	d5,d2
	divs	d4,d2
	add.w	a5,d2
	move.w	clipx1,d0
	move.w	d2,d1
	move.w	clipx2,d2
	sub.w	d3,d2
	muls	d5,d2
	divs	d4,d2
	add.w	a5,d2
	move.w	d2,d3
	move.w	clipx2,d2
	tst.w	d6
	beq.s	l003b
	exg	d2,d0
	exg	d3,d1
l003b	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	addq.w	#2,a4
	move.w	a2,d2
	move.w	a3,d3
	bra	nextclip
xlinenot	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.w	#1,a4
nextclip	move.w	d2,d0
	move.w	d3,d1
	dbf	d7,clipxl
	move.w	a4,d7
	subq.w	#1,d7
	bmi	dpexit
	lea	clipa,a1
	suba.w	a4,a4
	lea	clipb,a0
	movem.w	(a1)+,d0-d1
	movem.w	d0-d1,-(a7)
clipyl	movem.w	(a1)+,d2-d3
	tst.w	d7
	bne.s	l003f
	movem.w	(a7)+,d2-d3
l003f	moveq	#0,d4
	moveq	#0,d5
	move.w	clipy1,d6
	cmp.w	d6,d1
	slt	d4
	cmp.w	d6,d3
	slt	d5
	ror.w	#8,d4
	ror.w	#8,d5
	move.w	clipy2,d6
	cmp.w	d6,d1
	sgt	d4
	cmp.w	d6,d3
	sgt	d5
	move.w	d4,d6
	or.w	d5,d6
	beq	ylinenot
	move.w	d4,d6
	and.w	d5,d6
	bne	l0047
	tst.w	d4
	bne.s	yfirstcl
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.w	#1,a4
	move.w	clipy1,d6
	tst.b	d5
	beq.s	l0040
	move.w	clipy2,d6
l0040	move.w	d6,2(a0)
	sub.w	d1,d6
	move.w	d0,d5
	sub.w	d3,d1
	sub.w	d2,d0
	muls	d0,d6
	divs	d1,d6
	add.w	d5,d6
	move.w	d6,(a0)
	addq.w	#4,a0
	addq.w	#1,a4
	bra	l0047
yfirstcl	tst.w	d5
	bne	ybothcli
	move.w	clipy1,d6
	tst.b	d4
	beq.s	l0042
	move.w	clipy2,d6
l0042	move.w	d6,2(a0)
	sub.w	d1,d6
	move.w	d0,d5
	sub.w	d3,d1
	sub.w	d2,d0
	muls	d0,d6
	divs	d1,d6
	add.w	d5,d6
	move.w	d6,(a0)
	addq.w	#4,a0
	addq.w	#1,a4
	bra	l0047
ybothcli	moveq	#0,d6
	movea.w	d2,a2
	movea.w	d3,a3
	cmp.w	d1,d3
	bgt.s	l0044
	exg	d2,d0
	exg	d3,d1
	moveq	#$ff,d6
l0044	movea.w	d0,a5
	move.w	d3,d5
	move.w	d2,d4
	sub.w	d0,d4
	sub.w	d1,d5
	move.w	clipy1,d2
	move.w	d1,d3
	sub.w	d1,d2
	muls	d4,d2
	divs	d5,d2
	add.w	a5,d2
	move.w	clipy1,d1
	move.w	d2,d0
	move.w	clipy2,d2
	sub.w	d3,d2
	muls	d4,d2
	divs	d5,d2
	add.w	a5,d2
	move.w	clipy2,d3
	tst.w	d6
	beq.s	l0045
	exg	d2,d0
	exg	d3,d1
l0045	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	addq.w	#2,a4
	move.w	a2,d2
	move.w	a3,d3
	bra	l0047
ylinenot	move.w	d0,(a0)+
	move.w	d1,(a0)+
	addq.w	#1,a4
l0047	move.w	d2,d0
	move.w	d3,d1
	dbf	d7,clipyl
	move.w	a4,d7
	lea	clipb,a1
	subq.w	#1,d7
	bmi	dpexit
	movea.w	#0,a2
	movea.w	#$c8,a3
	moveq	#0,d0
	moveq	#0,d1
	movem.w	(a1)+,d0-d1
	movem.w	d0-d1,-(a7)
dploop	movem.w	(a1)+,d2-d3
	tst.w	d7
	bne.s	l0049
	movem.w	(a7)+,d2-d3
l0049	move.l	d2,d5
	move.l	d3,d6
	lea	leftpts(pc),a0
	cmp.w	d1,d3
	beq	l004f
	bpl.s	l004a
	lea	rigtpts(pc),a0
	exg	d2,d0
	exg	d3,d1
l004a	cmpa.w	d1,a3
	bmi.s	l004b
	movea.w	d1,a3
l004b	cmpa.w	d3,a2
	bpl.s	l004c
	movea.w	d3,a2
l004c	moveq	#0,d4
	sub.w	d1,d3
	sub.w	d0,d2
	add.w	d1,d1
	adda.w	d1,a0
	ext.l	d2
	asl.l	#8,d2
	divs	d3,d2
	bvc.s	l004d
	asr.l	#2,d2
	divs	d3,d2
	ext.l	d2
	asl.l	#2,d2
l004d	ext.l	d2
	asl.l	#8,d2
	swap	d2
l004e	move.w	d0,(a0)+
	add.l	d2,d0
	addx.w	d4,d0
	dbf	d3,l004e
l004f	move.l	d5,d0
	move.l	d6,d1
	dbf	d7,dploop
	cmpa.w	#$c8,a3
	bge	dpexit
	cmpa.w	#0,a2
	bmi	dpexit
	move.w	color,d2
	lsl.w	#3,d2
	lea	ecolr,a0
	movem.l	0(a0,d2.w),d0-d1
	movem.l	d0-d1,nopi1
	movem.l	d0-d1,nopi2
	movem.l	d0-d1,nopi3
	move.w	d2,d6
	move.w	a3,d0
	move.w	a2,d1
	sub.w	d0,d1
	lea	leftpts,a0
	lea	rigtpts,a1
	movea.l	scr2,a2
	add.w	d0,d0
	adda.w	d0,a0
	adda.w	d0,a1
	mulu	#$50,d0
	adda.l	d0,a2
	lea	mcolr,a5
	movem.l	0(a5,d6.w),d6-d7
outdraw	move.w	(a0)+,d2
	move.w	(a1)+,d3
	move.w	d2,d4
	move.w	d3,d5
	andi.w	#$f,d5
	andi.w	#$f,d4
	andi.w	#$fff0,d2
	andi.w	#$fff0,d3
	lsr.w	#1,d2
	lsr.w	#1,d3
	lea	0(a2,d2.w),a3
	add.w	d5,d5
	lea	rend(pc),a4
	movea.w	0(a4,d5.w),a5
	add.w	d4,d4
	lea	lend(pc),a4
	move.w	0(a4,d4.w),d0
	sub.w	d2,d3
	beq	short
	bmi	cyc
	move.w	d0,d5
	not.w	d5
nopi2	nop
	nop
	nop
	nop
	neg.w	d3
	asr.w	#1,d3
	jmp	l0052(pc,d3.w)
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.l	d6,(a3)+
	move.l	d7,(a3)+
	move.w	a5,d0
	move.w	a5,d5
l0052	not.w	d5
nopi3	nop
	nop
	nop
	nop
cyc	lea	160(a2),a2
	dbf	d1,outdraw
dpexit	rts

short	move.w	a5,d5
	and.w	d5,d0
	move.w	d0,d5
	not.w	d5
nopi1	nop
	nop
	nop
	nop
	lea	160(a2),a2
	dbf	d1,outdraw
	rts

lend	dc.b	$ff,$ff,$7f,$ff,'?',$ff,$1f,$ff
	dc.b	$f,$ff,7,$ff,3,$ff,1,$ff
	dc.b	0,$ff,0,$7f,0,'?',0,$1f
	dc.b	0,$f,0,7,0,3,0,1
rend	dc.b	$80,0,$c0,0,$e0,0,$f0,0
	dc.b	$f8,0,$fc,0,$fe,0,$ff,0
	dc.b	$ff,$80,$ff,$c0,$ff,$e0,$ff,$f0
	dc.b	$ff,$f8,$ff,$fc,$ff,$fe,$ff,$ff
ecolr	dc.b	$cb,'[',$cb,'[',$cb,'[',$cb,'['
	dc.b	'Å[',$cb,'[',$cb,'[',$cb,'['
	dc.b	$cb,'[Å[',$cb,'[',$cb,'['
	dc.b	'Å[Å[',$cb,'[',$cb,'['
	dc.b	$cb,'[',$cb,'[Å[',$cb,'['
	dc.b	'Å[',$cb,'[Å[',$cb,'['
	dc.b	$cb,'[Å[Å[',$cb,'['
	dc.b	'Å[Å[Å[',$cb,'['
	dc.b	$cb,'[',$cb,'[',$cb,'[Å['
	dc.b	'Å[',$cb,'[',$cb,'[Å['
	dc.b	$cb,'[Å[',$cb,'[Å['
	dc.b	'Å[Å[',$cb,'[Å['
	dc.b	$cb,'[',$cb,'[Å[Å['
	dc.b	'Å[',$cb,'[Å[Å['
	dc.b	$cb,'[Å[Å[Å['
	dc.b	'Å[Å[Å[Å['
mcolr	dcb.w	4
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	$ff,$ff,$ff,$ff,0,0,0,0
	dcb.w	2
	dc.b	$ff,$ff,0,0,$ff,$ff,0,0
	dc.b	$ff,$ff,0,0,0,0,$ff,$ff
	dc.b	$ff,$ff,0,0,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,0,0,0,0,0,0
	dc.b	0,0,$ff,$ff,$ff,$ff,0,0
	dc.b	0,0,$ff,$ff,0,0,$ff,$ff
	dc.b	0,0,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	0,0,$ff,$ff,0,0,0,0
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,0,0
	dc.b	$ff,$ff,$ff,$ff,0,0,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff
savest	lea	safe,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.b	$ffff8260.w,(a0)+
	move.l	$70.w,oldvbl
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,palette
	rts

restores	move	#$2700,sr
	move.l	oldvbl,$70.w
	lea	safe,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa21.w
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820a.w
	move.b	(a0)+,$ffff8260.w
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move	#$2300,sr
	rts

	data
sinus	dc.b	0,0,0,'d',0,$c8,1,'-'
	dc.b	1,$91,1,$f5,2,'Y',2,$bc
	dc.b	3,$1f,3,$81,3,$e3,4,'D'
	dc.b	4,$a5,5,4,5,'c',5,$c2
	dc.b	6,$1f,6,'{',6,$d7,7,'1'
	dc.b	7,$8a,7,$e2,8,'9',8,$8f
	dc.b	8,$e3,9,'6',9,$87,9,$d7
	dc.b	$a,'&',$a,'s',$a,$be,$b,8
	dc.b	$b,'P',$b,$96,$b,$da,$c,$1d
	dc.b	$c,'^',$c,$9d,$c,$d9,$d,$14
	dc.b	$d,'M',$d,$84,$d,$b9,$d,$eb
	dc.b	$e,$1c,$e,'J',$e,'v',$e,$a0
	dc.b	$e,$c8,$e,$ed,$f,$10,$f,'1'
	dc.b	$f,'O',$f,'k',$f,$85,$f,$9c
	dc.b	$f,$b1,$f,$c3,$f,$d3,$f,$e1
	dc.b	$f,$ec,$f,$f4,$f,$fb,$f,$fe
	dc.b	$10,0,$f,$fe,$f,$fb,$f,$f4
	dc.b	$f,$ec,$f,$e1,$f,$d3,$f,$c3
	dc.b	$f,$b1,$f,$9c,$f,$85,$f,'k'
	dc.b	$f,'O',$f,'1',$f,$10,$e,$ed
	dc.b	$e,$c8,$e,$a0,$e,'v',$e,'J'
	dc.b	$e,$1c,$d,$eb,$d,$b9,$d,$84
	dc.b	$d,'M',$d,$14,$c,$d9,$c,$9d
	dc.b	$c,'^',$c,$1d,$b,$da,$b,$96
	dc.b	$b,'P',$b,8,$a,$be,$a,'s'
	dc.b	$a,'&',9,$d7,9,$87,9,'6'
	dc.b	8,$e3,8,$8f,8,'9',7,$e2
	dc.b	7,$8a,7,'1',6,$d7,6,'{'
	dc.b	6,$1f,5,$c2,5,'c',5,4
	dc.b	4,$a5,4,'D',3,$e3,3,$81
	dc.b	3,$1f,2,$bc,2,'Y',1,$f5
	dc.b	1,$91,1,'-',0,$c8,0,'d'
	dc.b	0,0,$ff,$9b,$ff,'7',$fe,$d2
	dc.b	$fe,'n',$fe,$a,$fd,$a6,$fd,'C'
	dc.b	$fc,$e0,$fc,'~',$fc,$1c,$fb,$bb
	dc.b	$fb,'Z',$fa,$fb,$fa,$9c,$fa,'='
	dc.b	$f9,$e0,$f9,$84,$f9,'(',$f8,$ce
	dc.b	$f8,'u',$f8,$1d,$f7,$c6,$f7,'p'
	dc.b	$f7,$1c,$f6,$c9,$f6,'x',$f6,'('
	dc.b	$f5,$d9,$f5,$8c,$f5,'A',$f4,$f7
	dc.b	$f4,$af,$f4,'i',$f4,'%',$f3,$e2
	dc.b	$f3,$a1,$f3,'b',$f3,'&',$f2,$eb
	dc.b	$f2,$b2,$f2,'{',$f2,'F',$f2,$14
	dc.b	$f1,$e3,$f1,$b5,$f1,$89,$f1,'_'
	dc.b	$f1,'7',$f1,$12,$f0,$ef,$f0,$ce
	dc.b	$f0,$b0,$f0,$94,$f0,'z',$f0,'c'
	dc.b	$f0,'N',$f0,'<',$f0,',',$f0,$1e
	dc.b	$f0,$13,$f0,$b,$f0,4,$f0,1
	dc.b	$f0,0,$f0,1,$f0,4,$f0,$b
	dc.b	$f0,$13,$f0,$1e,$f0,',',$f0,'<'
	dc.b	$f0,'N',$f0,'c',$f0,'z',$f0,$94
	dc.b	$f0,$b0,$f0,$ce,$f0,$ef,$f1,$12
	dc.b	$f1,'7',$f1,'_',$f1,$89,$f1,$b5
	dc.b	$f1,$e3,$f2,$14,$f2,'F',$f2,'{'
	dc.b	$f2,$b2,$f2,$eb,$f3,'&',$f3,'b'
	dc.b	$f3,$a1,$f3,$e2,$f4,'%',$f4,'i'
	dc.b	$f4,$af,$f4,$f7,$f5,'A',$f5,$8c
	dc.b	$f5,$d9,$f6,'(',$f6,'x',$f6,$c9
	dc.b	$f7,$1c,$f7,'p',$f7,$c6,$f8,$1d
	dc.b	$f8,'u',$f8,$ce,$f9,'(',$f9,$84
	dc.b	$f9,$e0,$fa,'=',$fa,$9c,$fa,$fb
	dc.b	$fb,'Z',$fb,$bb,$fc,$1c,$fc,'~'
	dc.b	$fc,$e0,$fd,'C',$fd,$a6,$fe,$a
	dc.b	$fe,'n',$fe,$d2,$ff,'7',$ff,$9b
newpal	dc.b	0,0,7,0,7,'3',5,0
	dc.b	4,0,3,'0',5,'U',3,'3'
	dc.b	0,'f',7,'w',0,'w',0,'p'
	dc.b	0,7,7,'p',7,7,7,'w'
clipx1	dc.b	0,0
clipx2	dc.b	1,'?'
clipy1	dc.b	0,'2'
clipy2	dc.b	0,$8b
numpoint	dc.b	0,$e
points3d	dc.b	$ff,$dd,0,$19,$ff,$ec,$ff,$dd
	dc.b	$ff,$e7,$ff,$ec,0,'#',$ff,$e7
	dc.b	$ff,$ec,0,'#',0,$19,$ff,$ec
	dc.b	$ff,$dd,0,$19,0,$14,0,'#'
	dc.b	0,$19,0,$14,0,'#',$ff,$e7
	dc.b	0,$14,$ff,$dd,$ff,$e7,0,$14
	dc.b	$ff,$e7,0,'-',0,0,0,$19
	dc.b	0,'-',0,0,$ff,$f6,0,$f
	dc.b	$ff,$ec,$ff,$f6,$ff,$fb,$ff,$ec
	dc.b	0,$a,$ff,$fb,$ff,$ec,0,$a
	dc.b	0,$f,$ff,$ec
planes3d	dc.b	0,1,0,4,0,0,0,1
	dc.b	0,2,0,3,0,2,0,4
	dc.b	0,3,0,2,0,6,0,5
	dc.b	0,3,0,4,0,4,0,5
	dc.b	0,6,0,7,0,4,0,4
	dc.b	0,4,0,7,0,1,0,0
	dc.b	0,5,0,4,0,1,0,7
	dc.b	0,6,0,2,0,6,0,4
	dc.b	0,8,0,0,0,3,0,9
	dc.b	0,7,0,4,0,8,0,9
	dc.b	0,5,0,4,0,7,0,3
	dc.b	0,8,0,4,0,0,0,9
	dc.b	0,3,0,9,0,3,0,5
	dc.b	0,8,0,4,0,$a,0,$b
	dc.b	0,$c,0,$d,$ff,$ff,$ff,$ff

pict	dc.b	$80,0,0,0,0,4,0,7
	dc.b	1,'A',4,'3',5,'0',6,'S'
	dc.b	7,'T',7,0,7,'P',3,' '
	dc.b	7,'t',6,'S',5,'A',7,'d'
	dc.b	7,'w',$d9,0,$da,0,0,1
	dc.b	$d9,0,$da,0,0,1,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$27,'q'
	dc.b	4,0,$f1,$c7,$a2,$f8,$c0,'>'
	dc.b	$89,$c7,$80,'y',$ef,'>',$fa,' '
	dc.b	$1c,'x',7,'"',3,$ef,$be,'s'
	dc.b	$cf,$80,$f9,$c0,'"q/',$80
	dc.b	'p',7,$9c,'s',$c0,0,0,$27
	dc.b	'q',4,0,$f1,$c7,$a2,$f8,$c0
	dc.b	'>',$89,$c7,$80,'y',$ef,'>',$fa
	dc.b	' ',$1c,'x',7,'"',3,$ef,$be
	dc.b	's',$cf,$80,$f9,$c0,'"q/'
	dc.b	$80,'p',7,$9c,'s',$c0,0,0
	dc.b	$27,'q',4,0,$f1,$c7,$a2,$f8
	dc.b	$c0,'>',$89,$c7,$80,'y',$ef,'>'
	dc.b	$fa,' ',$1c,'x',7,'"',3,$ef
	dc.b	$be,'s',$cf,$80,$f9,$c0,'"q'
	dc.b	'/',$80,'p',7,$9c,'s',$c0,0
	dc.b	0,$27,'q',4,0,$f1,$c7,$a2
	dc.b	$f8,$c0,'>',$89,$c7,$80,'y',$ef
	dc.b	'>',$fa,' ',$1c,'x',7,'"',3
	dc.b	$ef,$be,'s',$cf,$80,$f9,$c0,'"'
	dc.b	'q/',$80,'p',7,$9c,'s',$c0
	dc.b	0,0,$27,$89,4,0,$88,$88
	dc.b	'" ',$c0,8,$88,$88,0,$82
	dc.b	8,$a0,$83,' ',8,$80,8,$b2
	dc.b	2,8,' ',$8a,'"',0,'" '
	dc.b	'6',$89,'H',0,$88,8,'"',$8a
	dc.b	' ',0,0,$27,$89,4,0,$88
	dc.b	$88,'" ',$c0,8,$88,$88,0
	dc.b	$82,8,$a0,$83,' ',8,$80,8
	dc.b	$b2,2,8,' ',$8a,'"',0,'"'
	dc.b	' 6',$89,'H',0,$88,8,'"'
	dc.b	$8a,' ',0,0,$27,$89,4,0
	dc.b	$88,$88,'" ',$c0,8,$88,$88
	dc.b	0,$82,8,$a0,$83,' ',8,$80
	dc.b	8,$b2,2,8,' ',$8a,'"',0
	dc.b	'" 6',$89,'H',0,$88,8
	dc.b	'"',$8a,' ',0,0,$27,$89,4
	dc.b	0,$88,$88,'" ',$c0,8,$88
	dc.b	$88,0,$82,8,$a0,$83,' ',8
	dc.b	$80,8,$b2,2,8,' ',$8a,'"'
	dc.b	0,'" 6',$89,'H',0,$88
	dc.b	8,'"',$8a,' ',0,0,$27,$f9
	dc.b	4,0,$f0,$89,$be,' ',$c0,8
	dc.b	$f8,$87,0,'r',$f,'<',$f2,$a0
	dc.b	8,'p',$f,$aa,3,$cf,'<',$8b
	dc.b	$c2,0,'" *',$f9,$8f,0
	dc.b	$f8,9,$a2,$8a,' ',0,0,$27
	dc.b	$f9,4,0,$f0,$89,$be,' ',$c0
	dc.b	8,$f8,$87,0,'r',$f,'<',$f2
	dc.b	$a0,8,'p',$f,$aa,3,$cf,'<'
	dc.b	$8b,$c2,0,'" *',$f9,$8f
	dc.b	0,$f8,9,$a2,$8a,' ',0,0
	dc.b	$27,$f9,4,0,$f0,$89,$be,' '
	dc.b	$c0,8,$f8,$87,0,'r',$f,'<'
	dc.b	$f2,$a0,8,'p',$f,$aa,3,$cf
	dc.b	'<',$8b,$c2,0,'" *',$f9
	dc.b	$8f,0,$f8,9,$a2,$8a,' ',0
	dc.b	0,$27,$f9,4,0,$f0,$89,$be
	dc.b	' ',$c0,8,$f8,$87,0,'r',$f
	dc.b	'<',$f2,$a0,8,'p',$f,$aa,3
	dc.b	$cf,'<',$8b,$c2,0,'" *'
	dc.b	$f9,$8f,0,$f8,9,$a2,$8a,' '
	dc.b	0,0,$10,$89,4,0,$a0,$88
	dc.b	$a2,' ',$c0,8,$88,$80,$80,$a
	dc.b	$a,' ',$82,'`',$fe,8,$13,$a6
	dc.b	2,8,' ',$8a,$82,0,'" '
	dc.b	'"',$89,'H',0,$88,8,$a2,$8a
	dc.b	' ',0,0,$10,$89,4,0,$a0
	dc.b	$88,$a2,' ',$c0,8,$88,$80,$80
	dc.b	$a,$a,' ',$82,'`',$fe,8,$13
	dc.b	$a6,2,8,' ',$8a,$82,0,'"'
	dc.b	' "',$89,'H',0,$88,8,$a2
	dc.b	$8a,' ',0,0,$10,$89,4,0
	dc.b	$a0,$88,$a2,' ',$c0,8,$88,$80
	dc.b	$80,$a,$a,' ',$82,'`',$fe,8
	dc.b	$13,$a6,2,8,' ',$8a,$82,0
	dc.b	'" "',$89,'H',0,$88,8
	dc.b	$a2,$8a,' ',0,0,$10,$89,4
	dc.b	0,$a0,$88,$a2,' ',$c0,8,$88
	dc.b	$80,$80,$a,$a,' ',$82,'`',$fe
	dc.b	8,$13,$a6,2,8,' ',$8a,$82
	dc.b	0,'" "',$89,'H',0,$88
	dc.b	8,$a2,$8a,' ',0,0,$27,$89
	dc.b	$e7,$80,$99,$c7,$a2,' ',0,8
	dc.b	$89,$cf,0,$f1,$e9,$be,$fa,' '
	dc.b	$1c,$f0,8,$a2,3,$e8,' r'
	dc.b	'b',0,'!',$c0,'"',$89,'/',$80
	dc.b	$88,7,$9c,'s',$c0,0,0,$27
	dc.b	$89,$e7,$80,$99,$c7,$a2,' ',0
	dc.b	8,$89,$cf,0,$f1,$e9,$be,$fa
	dc.b	' ',$1c,$f0,8,$a2,3,$e8,' '
	dc.b	'rb',0,'!',$c0,'"',$89,'/'
	dc.b	$80,$88,7,$9c,'s',$c0,0,0
	dc.b	$27,$89,$e7,$80,$99,$c7,$a2,' '
	dc.b	0,8,$89,$cf,0,$f1,$e9,$be
	dc.b	$fa,' ',$1c,$f0,8,$a2,3,$e8
	dc.b	' rb',0,'!',$c0,'"',$89
	dc.b	'/',$80,$88,7,$9c,'s',$c0,0
	dc.b	0,$27,$89,$e7,$80,$99,$c7,$a2
	dc.b	' ',0,8,$89,$cf,0,$f1,$e9
	dc.b	$be,$fa,' ',$1c,$f0,8,$a2,3
	dc.b	$e8,' rb',0,'!',$c0,'"'
	dc.b	$89,'/',$80,$88,7,$9c,'s',$c0
	dc.b	0,0,$fa,0,0,$c0,$e1,0
	dc.b	$fa,0,0,$c0,$e1,0,$fa,0
	dc.b	0,$c0,$e1,0,$fa,0,0,$c0
	dc.b	$e1,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$27,'{',$ef,$80,'s',$e0
	dc.b	'<',$f0,$f,$1c,$8b,$e7,$80,$fa
	dc.b	'/',$bc,$f8,7,$1e,1,$e7,'"'
	dc.b	$f8,8,$9c,'y',$e7,'"y',$e0
	dc.b	$1c,$88,7,0,$89,$cf,'<',$fa
	dc.b	' ',0,0,$27,'{',$ef,$80,'s'
	dc.b	$e0,'<',$f0,$f,$1c,$8b,$e7,$80
	dc.b	$fa,'/',$bc,$f8,7,$1e,1,$e7
	dc.b	'"',$f8,8,$9c,'y',$e7,'"y'
	dc.b	$e0,$1c,$88,7,0,$89,$cf,'<'
	dc.b	$fa,' ',0,0,$27,'{',$ef,$80
	dc.b	's',$e0,'<',$f0,$f,$1c,$8b,$e7
	dc.b	$80,$fa,'/',$bc,$f8,7,$1e,1
	dc.b	$e7,'"',$f8,8,$9c,'y',$e7,'"'
	dc.b	'y',$e0,$1c,$88,7,0,$89,$cf
	dc.b	'<',$fa,' ',0,0,$27,'{',$ef
	dc.b	$80,'s',$e0,'<',$f0,$f,$1c,$8b
	dc.b	$e7,$80,$fa,'/',$bc,$f8,7,$1e
	dc.b	1,$e7,'"',$f8,8,$9c,'y',$e7
	dc.b	'"y',$e0,$1c,$88,7,0,$89
	dc.b	$cf,'<',$fa,' ',0,0,$27,$82
	dc.b	2,0,$8a,0,2,$88,8,$a2
	dc.b	$88,$88,0,'"("',$80,2
	dc.b	' ',2,8,$b6,$80,$d,$88,$82
	dc.b	2,'2',$82,0,8,$c8,8,$80
	dc.b	$88,$88,$a2,$83,' ',0,0,$27
	dc.b	$82,2,0,$8a,0,2,$88,8
	dc.b	$a2,$88,$88,0,'"("',$80
	dc.b	2,' ',2,8,$b6,$80,$d,$88
	dc.b	$82,2,'2',$82,0,8,$c8,8
	dc.b	$80,$88,$88,$a2,$83,' ',0,0
	dc.b	$27,$82,2,0,$8a,0,2,$88
	dc.b	8,$a2,$88,$88,0,'"("'
	dc.b	$80,2,' ',2,8,$b6,$80,$d
	dc.b	$88,$82,2,'2',$82,0,8,$c8
	dc.b	8,$80,$88,$88,$a2,$83,' ',0
	dc.b	0,$27,$82,2,0,$8a,0,2
	dc.b	$88,8,$a2,$88,$88,0,'"('
	dc.b	'"',$80,2,' ',2,8,$b6,$80
	dc.b	$d,$88,$82,2,'2',$82,0,8
	dc.b	$c8,8,$80,$88,$88,$a2,$83,' '
	dc.b	0,0,$27,'s',$c2,0,$8b,$c0
	dc.b	$1c,$89,$ef,'"',$88,$87,0,'#'
	dc.b	$ef,'<',$f0,2,$1c,1,$c8,$aa
	dc.b	$f0,$a,$88,'q',$c2,'*',$99,$c0
	dc.b	8,$a8,$f,$80,$f8,$88,$a2,$f2
	dc.b	$a7,$80,0,$27,'s',$c2,0,$8b
	dc.b	$c0,$1c,$89,$ef,'"',$88,$87,0
	dc.b	'#',$ef,'<',$f0,2,$1c,1,$c8
	dc.b	$aa,$f0,$a,$88,'q',$c2,'*',$99
	dc.b	$c0,8,$a8,$f,$80,$f8,$88,$a2
	dc.b	$f2,$a7,$80,0,$27,'s',$c2,0
	dc.b	$8b,$c0,$1c,$89,$ef,'"',$88,$87
	dc.b	0,'#',$ef,'<',$f0,2,$1c,1
	dc.b	$c8,$aa,$f0,$a,$88,'q',$c2,'*'
	dc.b	$99,$c0,8,$a8,$f,$80,$f8,$88
	dc.b	$a2,$f2,$a7,$80,0,$27,'s',$c2
	dc.b	0,$8b,$c0,$1c,$89,$ef,'"',$88
	dc.b	$87,0,'#',$ef,'<',$f0,2,$1c
	dc.b	1,$c8,$aa,$f0,$a,$88,'q',$c2
	dc.b	'*',$99,$c0,8,$a8,$f,$80,$f8
	dc.b	$88,$a2,$f2,$a7,$80,0,$27,$a
	dc.b	2,0,$8a,0,2,$88,$a,'"'
	dc.b	$88,$80,$8c,'"((',$80,2
	dc.b	2,0,'(',$a2,$80,8,$88,8
	dc.b	'"&',$88,' ',8,$98,8,$80
	dc.b	$88,$88,$a2,$82,'`',0,0,$27
	dc.b	$a,2,0,$8a,0,2,$88,$a
	dc.b	'"',$88,$80,$8c,'"((',$80
	dc.b	2,2,0,'(',$a2,$80,8,$88
	dc.b	8,'"&',$88,' ',8,$98,8
	dc.b	$80,$88,$88,$a2,$82,'`',0,0
	dc.b	$27,$a,2,0,$8a,0,2,$88
	dc.b	$a,'"',$88,$80,$8c,'"(('
	dc.b	$80,2,2,0,'(',$a2,$80,8
	dc.b	$88,8,'"&',$88,' ',8,$98
	dc.b	8,$80,$88,$88,$a2,$82,'`',0
	dc.b	0,$27,$a,2,0,$8a,0,2
	dc.b	$88,$a,'"',$88,$80,$8c,'"('
	dc.b	'(',$80,2,2,0,'(',$a2,$80
	dc.b	8,$88,8,'"&',$88,' ',8
	dc.b	$98,8,$80,$88,$88,$a2,$82,'`'
	dc.b	0,0,$27,$f3,$e2,0,'r',0
	dc.b	'<',$f0,9,$9c,'x',$8f,$c,'"'
	dc.b	'/',$a6,$f8,7,'<',3,$c7,'"'
	dc.b	$f8,8,$9c,$f3,$c7,'"{',$c0
	dc.b	$1c,$88,8,$80,$89,$cf,'<',$fa
	dc.b	' ',0,0,$27,$f3,$e2,0,'r'
	dc.b	0,'<',$f0,9,$9c,'x',$8f,$c
	dc.b	'"/',$a6,$f8,7,'<',3,$c7
	dc.b	'"',$f8,8,$9c,$f3,$c7,'"{'
	dc.b	$c0,$1c,$88,8,$80,$89,$cf,'<'
	dc.b	$fa,' ',0,0,$27,$f3,$e2,0
	dc.b	'r',0,'<',$f0,9,$9c,'x',$8f
	dc.b	$c,'"/',$a6,$f8,7,'<',3
	dc.b	$c7,'"',$f8,8,$9c,$f3,$c7,'"'
	dc.b	'{',$c0,$1c,$88,8,$80,$89,$cf
	dc.b	'<',$fa,' ',0,0,$27,$f3,$e2
	dc.b	0,'r',0,'<',$f0,9,$9c,'x'
	dc.b	$8f,$c,'"/',$a6,$f8,7,'<'
	dc.b	3,$c7,'"',$f8,8,$9c,$f3,$c7
	dc.b	'"{',$c0,$1c,$88,8,$80,$89
	dc.b	$cf,'<',$fa,' ',0,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,'#z'
	dc.b	'/>q',$ef,$80,$f3,$e8,$9c
	dc.b	$89,$c4,0,'q',7,$9c,$f2,'/'
	dc.b	$a2,$88,7,'"',$f0,7,$9c,$8b
	dc.b	$c4,'>',$88,$f,$1c,$f1,$cf,$9e
	dc.b	1,$cf,'>',$fd,0,'#z/'
	dc.b	'>q',$ef,$80,$f3,$e8,$9c,$89
	dc.b	$c4,0,'q',7,$9c,$f2,'/',$a2
	dc.b	$88,7,'"',$f0,7,$9c,$8b,$c4
	dc.b	'>',$88,$f,$1c,$f1,$cf,$9e,1
	dc.b	$cf,'>',$fd,0,'#z/>'
	dc.b	'q',$ef,$80,$f3,$e8,$9c,$89,$c4
	dc.b	0,'q',7,$9c,$f2,'/',$a2,$88
	dc.b	7,'"',$f0,7,$9c,$8b,$c4,'>'
	dc.b	$88,$f,$1c,$f1,$cf,$9e,1,$cf
	dc.b	'>',$fd,0,'#z/>q'
	dc.b	$ef,$80,$f3,$e8,$9c,$89,$c4,0
	dc.b	'q',7,$9c,$f2,'/',$a2,$88,7
	dc.b	'"',$f0,7,$9c,$8b,$c4,'>',$88
	dc.b	$f,$1c,$f1,$cf,$9e,1,$cf,'>'
	dc.b	$fd,0,'#',$82,'(',$a0,$8a,8
	dc.b	0,$8a,$d,$a2,$8a,'$',0,$89
	dc.b	8,'"',$8a,'""',$d8,8,$b2
	dc.b	$88,8,'"',$da,'$ P',8
	dc.b	$a2,$88,$88,' ',2,'(',$a0,$fd
	dc.b	0,'#',$82,'(',$a0,$8a,8,0
	dc.b	$8a,$d,$a2,$8a,'$',0,$89,8
	dc.b	'"',$8a,'""',$d8,8,$b2,$88
	dc.b	8,'"',$da,'$ P',8,$a2
	dc.b	$88,$88,' ',2,'(',$a0,$fd,0
	dc.b	'#',$82,'(',$a0,$8a,8,0,$8a
	dc.b	$d,$a2,$8a,'$',0,$89,8,'"'
	dc.b	$8a,'""',$d8,8,$b2,$88,8
	dc.b	'"',$da,'$ P',8,$a2,$88
	dc.b	$88,' ',2,'(',$a0,$fd,0,'#'
	dc.b	$82,'(',$a0,$8a,8,0,$8a,$d
	dc.b	$a2,$8a,'$',0,$89,8,'"',$8a
	dc.b	'""',$d8,8,$b2,$88,8,'"'
	dc.b	$da,'$ P',8,$a2,$88,$88
	dc.b	' ',2,'(',$a0,$fd,0,'#r'
	dc.b	'/<',$fa,$f,0,$f3,$ca,$a2
	dc.b	$8b,$e4,0,$f9,9,$a2,$f1,'B'
	dc.b	'>',$a8,$f,$aa,$88,8,'"',$ab
	dc.b	$c4,'< ',$f,'"',$88,$8f,$1c
	dc.b	3,$ef,'<',$fd,0,'#r/'
	dc.b	'<',$fa,$f,0,$f3,$ca,$a2,$8b
	dc.b	$e4,0,$f9,9,$a2,$f1,'B>'
	dc.b	$a8,$f,$aa,$88,8,'"',$ab,$c4
	dc.b	'< ',$f,'"',$88,$8f,$1c,3
	dc.b	$ef,'<',$fd,0,'#r/<'
	dc.b	$fa,$f,0,$f3,$ca,$a2,$8b,$e4
	dc.b	0,$f9,9,$a2,$f1,'B>',$a8
	dc.b	$f,$aa,$88,8,'"',$ab,$c4,'<'
	dc.b	' ',$f,'"',$88,$8f,$1c,3,$ef
	dc.b	'<',$fd,0,'#r/<',$fa
	dc.b	$f,0,$f3,$ca,$a2,$8b,$e4,0
	dc.b	$f9,9,$a2,$f1,'B>',$a8,$f
	dc.b	$aa,$88,8,'"',$ab,$c4,'< '
	dc.b	$f,'"',$88,$8f,$1c,3,$ef,'<'
	dc.b	$fd,0,'#',$a,'* ',$8a,8
	dc.b	0,$a2,8,$a2,'R$',0,$89
	dc.b	8,$a2,$a0,$82,'"',$88,8,$a6
	dc.b	$88,8,'"',$8a,4,' P',8
	dc.b	$a2,$88,$88,2,2,'* ',$fd
	dc.b	0,'#',$a,'* ',$8a,8,0
	dc.b	$a2,8,$a2,'R$',0,$89,8
	dc.b	$a2,$a0,$82,'"',$88,8,$a6,$88
	dc.b	8,'"',$8a,4,' P',8,$a2
	dc.b	$88,$88,2,2,'* ',$fd,0
	dc.b	'#',$a,'* ',$8a,8,0,$a2
	dc.b	8,$a2,'R$',0,$89,8,$a2
	dc.b	$a0,$82,'"',$88,8,$a6,$88,8
	dc.b	'"',$8a,4,' P',8,$a2,$88
	dc.b	$88,2,2,'* ',$fd,0,'#'
	dc.b	$a,'* ',$8a,8,0,$a2,8
	dc.b	$a2,'R$',0,$89,8,$a2,$a0
	dc.b	$82,'"',$88,8,$a6,$88,8,'"'
	dc.b	$8a,4,' P',8,$a2,$88,$88
	dc.b	2,2,'* ',$fd,0,'#',$f1
	dc.b	$e9,$a0,$89,$ef,$80,$9b,$e8,$9c
	dc.b	'"',$27,$80,$89,$e7,$9c,$98,$82
	dc.b	'"',$88,8,$a2,$f0,7,$9c,$8a
	dc.b	7,$be,$88,$f,$1c,$f1,$cf,$bc
	dc.b	2,')',$be,$fd,0,'#',$f1,$e9
	dc.b	$a0,$89,$ef,$80,$9b,$e8,$9c,'"'
	dc.b	$27,$80,$89,$e7,$9c,$98,$82,'"'
	dc.b	$88,8,$a2,$f0,7,$9c,$8a,7
	dc.b	$be,$88,$f,$1c,$f1,$cf,$bc,2
	dc.b	')',$be,$fd,0,'#',$f1,$e9,$a0
	dc.b	$89,$ef,$80,$9b,$e8,$9c,'"',$27
	dc.b	$80,$89,$e7,$9c,$98,$82,'"',$88
	dc.b	8,$a2,$f0,7,$9c,$8a,7,$be
	dc.b	$88,$f,$1c,$f1,$cf,$bc,2,')'
	dc.b	$be,$fd,0,'#',$f1,$e9,$a0,$89
	dc.b	$ef,$80,$9b,$e8,$9c,'"',$27,$80
	dc.b	$89,$e7,$9c,$98,$82,'"',$88,8
	dc.b	$a2,$f0,7,$9c,$8a,7,$be,$88
	dc.b	$f,$1c,$f1,$cf,$bc,2,')',$be
	dc.b	$fd,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,'$',$f1,$c7,$bc,'A',$c8
	dc.b	$be,$f0,7,'"',1,$c0,'"',$f1
	dc.b	$c8,$9e,2,$27,'"',0,$f,$a2
	dc.b	's',$e0,'"q',4,0,$f3,$e0
	dc.b	'>r/',$bc,1,$e7,$1c,$88
	dc.b	$fe,0,'$',$f1,$c7,$bc,'A',$c8
	dc.b	$be,$f0,7,'"',1,$c0,'"',$f1
	dc.b	$c8,$9e,2,$27,'"',0,$f,$a2
	dc.b	's',$e0,'"q',4,0,$f3,$e0
	dc.b	'>r/',$bc,1,$e7,$1c,$88
	dc.b	$fe,0,'$',$f1,$c7,$bc,'A',$c8
	dc.b	$be,$f0,7,'"',1,$c0,'"',$f1
	dc.b	$c8,$9e,2,$27,'"',0,$f,$a2
	dc.b	's',$e0,'"q',4,0,$f3,$e0
	dc.b	'>r/',$bc,1,$e7,$1c,$88
	dc.b	$fe,0,'$',$f1,$c7,$bc,'A',$c8
	dc.b	$be,$f0,7,'"',1,$c0,'"',$f1
	dc.b	$c8,$9e,2,$27,'"',0,$f,$a2
	dc.b	's',$e0,'"q',4,0,$f3,$e0
	dc.b	'>r/',$bc,1,$e7,$1c,$88
	dc.b	$fe,0,$ff,$88,'""B('
	dc.b	$a0,$88,2,'2',2,' "',$8a
	dc.b	',',$a0,2,'(',$a2,0,2,'"'
	dc.b	$88,$80,'"!',4,0,$8a,0
	dc.b	' !H"',2,8,$a2,$c8
	dc.b	$fe,0,$ff,$88,'""B('
	dc.b	$a0,$88,2,'2',2,' "',$8a
	dc.b	',',$a0,2,'(',$a2,0,2,'"'
	dc.b	$88,$80,'"!',4,0,$8a,0
	dc.b	' !H"',2,8,$a2,$c8
	dc.b	$fe,0,$ff,$88,'""B('
	dc.b	$a0,$88,2,'2',2,' "',$8a
	dc.b	',',$a0,2,'(',$a2,0,2,'"'
	dc.b	$88,$80,'"!',4,0,$8a,0
	dc.b	' !H"',2,8,$a2,$c8
	dc.b	$fe,0,$ff,$88,'""B('
	dc.b	$a0,$88,2,'2',2,' "',$8a
	dc.b	',',$a0,2,'(',$a2,0,2,'"'
	dc.b	$88,$80,'"!',4,0,$8a,0
	dc.b	' !H"',2,8,$a2,$c8
	dc.b	$fe,0,'$',$88,$87,'<C',$e5
	dc.b	'<',$88,2,'*',3,$e0,'*',$f2
	dc.b	'*',$a6,2,$af,$94,0,2,'>'
	dc.b	$f8,$80,'*!',4,0,$f3,$c0
	dc.b	'< ',$8f,'"',1,$c8,$a2,$a8
	dc.b	$fe,0,'$',$88,$87,'<C',$e5
	dc.b	'<',$88,2,'*',3,$e0,'*',$f2
	dc.b	'*',$a6,2,$af,$94,0,2,'>'
	dc.b	$f8,$80,'*!',4,0,$f3,$c0
	dc.b	'< ',$8f,'"',1,$c8,$a2,$a8
	dc.b	$fe,0,'$',$88,$87,'<C',$e5
	dc.b	'<',$88,2,'*',3,$e0,'*',$f2
	dc.b	'*',$a6,2,$af,$94,0,2,'>'
	dc.b	$f8,$80,'*!',4,0,$f3,$c0
	dc.b	'< ',$8f,'"',1,$c8,$a2,$a8
	dc.b	$fe,0,'$',$88,$87,'<C',$e5
	dc.b	'<',$88,2,'*',3,$e0,'*',$f2
	dc.b	'*',$a6,2,$af,$94,0,2,'>'
	dc.b	$f8,$80,'*!',4,0,$f3,$c0
	dc.b	'< ',$8f,'"',1,$c8,$a2,$a8
	dc.b	$fe,0,$27,$88,$80,$a0,'B"'
	dc.b	' ',$88,2,'&',2,' 6',$a2
	dc.b	')',$a2,3,'h',$88,'0',2,'"'
	dc.b	$88,$80,'6!',4,0,$8a,0
	dc.b	' !H"',0,'(',$a2,$98
	dc.b	$c3,$c,0,$27,$88,$80,$a0,'B'
	dc.b	'" ',$88,2,'&',2,' 6'
	dc.b	$a2,')',$a2,3,'h',$88,'0',2
	dc.b	'"',$88,$80,'6!',4,0,$8a
	dc.b	0,' !H"',0,'(',$a2
	dc.b	$98,$c3,$c,0,$27,$88,$80,$a0
	dc.b	'B" ',$88,2,'&',2,' '
	dc.b	'6',$a2,')',$a2,3,'h',$88,'0'
	dc.b	2,'"',$88,$80,'6!',4,0
	dc.b	$8a,0,' !H"',0,'('
	dc.b	$a2,$98,$c3,$c,0,$27,$88,$80
	dc.b	$a0,'B" ',$88,2,'&',2
	dc.b	' 6',$a2,')',$a2,3,'h',$88
	dc.b	'0',2,'"',$88,$80,'6!',4
	dc.b	0,$8a,0,' !H"',0
	dc.b	'(',$a2,$98,$c3,$c,0,$27,$f1
	dc.b	$cf,' z">',$f0,7,'"'
	dc.b	2,' "',$99,$c8,$9e,2,'('
	dc.b	$88,'0',2,'"',$88,$80,'"q'
	dc.b	$e7,$80,$f3,$e0,' r/',$bc
	dc.b	3,$c7,$1c,$88,$c3,$c,0,$27
	dc.b	$f1,$cf,' z">',$f0,7
	dc.b	'"',2,' "',$99,$c8,$9e,2
	dc.b	'(',$88,'0',2,'"',$88,$80,'"'
	dc.b	'q',$e7,$80,$f3,$e0,' r/'
	dc.b	$bc,3,$c7,$1c,$88,$c3,$c,0
	dc.b	$27,$f1,$cf,' z">',$f0
	dc.b	7,'"',2,' "',$99,$c8,$9e
	dc.b	2,'(',$88,'0',2,'"',$88,$80
	dc.b	'"q',$e7,$80,$f3,$e0,' r'
	dc.b	'/',$bc,3,$c7,$1c,$88,$c3,$c
	dc.b	0,$27,$f1,$cf,' z">'
	dc.b	$f0,7,'"',2,' "',$99,$c8
	dc.b	$9e,2,'(',$88,'0',2,'"',$88
	dc.b	$80,'"q',$e7,$80,$f3,$e0,' '
	dc.b	'r/',$bc,3,$c7,$1c,$88,$c3
	dc.b	$c,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$d9,0,$d9,0,$d9,0
	dc.b	$d9,0,$f2,0,0,4,$e9,0
	dc.b	$f4,0,$c,1,$ff,$80,0,0
	dc.b	3,$ff,$f0,$c,'p',0,0,$e0
	dc.b	$f3,0,$f4,0,8,1,$ff,$fc
	dc.b	0,0,7,$ff,$e0,7,$fe,$ff
	dc.b	0,$e0,$f3,0,$f4,0,8,1
	dc.b	$ff,$fc,0,0,7,$ff,$f0,$f
	dc.b	$fe,$ff,0,$e0,$f3,0,$f3,0
	dc.b	1,$a,6,$fe,0,1,$17,$90
	dc.b	$ee,0,$f4,0,$c,1,$ff,$e0
	dc.b	0,0,$1b,$ff,$c8,$f,$ff,$9c
	dc.b	$f,$f0,$f3,0,$f4,0,8,1
	dc.b	$f5,$fe,0,0,7,$e8,'p',$1f
	dc.b	$fe,$ff,0,$f8,$f3,0,$f4,0
	dc.b	8,1,$ff,$fe,0,0,$1f,$ff
	dc.b	$f8,$1f,$fe,$ff,0,$f8,$f3,0
	dc.b	$f3,0,1,5,$83,$fe,0,2
	dc.b	2,$98,3,$ef,0,$f4,0,8
	dc.b	1,$ff,$f0,$80,1,$e7,$ff,$c4
	dc.b	$f,$fe,$ff,0,$f0,$f3,0,$f4
	dc.b	0,8,1,$fa,$7f,0,0,$f
	dc.b	$fd,'x<',$fe,$ff,0,$fc,$f3
	dc.b	0,$f4,0,8,1,$ff,$ff,$80
	dc.b	1,$ef,$ff,$fc,'?',$fe,$ff,0
	dc.b	$fc,$f3,0,$f2,0,5,$c2,$c0
	dc.b	0,0,1,$96,$fd,0,0,$10
	dc.b	$f3,0,$f3,0,$b,$ef,$f9,' '
	dc.b	$e,7,$ff,$c9,$9f,$ff,$f8,$ff
	dc.b	$f8,$f3,0,$f4,0,8,1,$ff
	dc.b	'>',$c0,0,$f,$fe,'v',$7f,$fe
	dc.b	$ff,0,$ee,$f3,0,$f4,0,5
	dc.b	1,$ff,$ff,$e0,$e,$f,$fb,$ff
	dc.b	0,$fe,$f3,0,$f2,0,1,'p'
	dc.b	'0',$fe,0,5,$81,0,0,2
	dc.b	0,'8',$f3,0,$f3,0,$b,$ef
	dc.b	$fe,'H',$f0,7,$cf,$d2,'?',$fe
	dc.b	0,0,$fc,$f3,0,$f4,0,7
	dc.b	1,$ff,'é0',0,$1f,$ff,'a'
	dc.b	$fd,$ff,0,$c7,$f3,0,$f4,0
	dc.b	7,1,$ff,$fe,'x',$f0,$1f,$ff
	dc.b	$f3,$fc,$ff,$f3,0,$f2,0,1
	dc.b	'0',$c,$fe,0,5,1,0,0
	dc.b	$7f,0,$10,$f3,0,$f3,0,$b
	dc.b	$ee,$fe,$13,0,$f,$cf,$82,$ff
	dc.b	$c0,0,0,$7f,$f3,0,$f4,0
	dc.b	7,1,$ff,$ce,$c,0,$1f,$ff
	dc.b	$e1,$fd,$ff,0,$ef,$f3,0,$f4
	dc.b	0,7,1,$ff,$fe,$1f,0,$1f
	dc.b	$ff,$e3,$fc,$ff,$f3,0,$f2,0
	dc.b	1,8,2,$fe,0,4,$80,0
	dc.b	8,$18,3,$f2,0,$f3,0,$c
	dc.b	$ce,$ff,5,0,$f,$8f,$82,$ff
	dc.b	$96,'fL?',$80,$f4,0,$f4
	dc.b	0,$d,1,$ff,$f7,2,0,'?'
	dc.b	$ff,'a',$ff,$c8,$18,3,$ff,$80
	dc.b	$f4,0,$f4,0,$d,1,$ff,$ff
	dc.b	7,0,'?',$ff,$e3,$ff,$de,'~'
	dc.b	'O',$ff,$80,$f4,0,$f2,0,2
	dc.b	4,5,$80,$fd,0,$b,4,8
	dc.b	1,$80,0,0,'"',$fa,' <'
	dc.b	'r#',$fb,0,$f3,0,$c,$ce
	dc.b	$ff,2,'@',$1f,$8f,$c4,$ff,$8a
	dc.b	$10,'0',$1f,$80,$f4,0,$f4,0
	dc.b	$14,1,$ff,$fb,5,$80,'?',$ff
	dc.b	$e1,$ff,$84,8,1,$ff,$80,0
	dc.b	'"',$fa,' <r#',$fb,0
	dc.b	$f4,0,$d,1,$ff,$ff,7,$c0
	dc.b	'?',$ff,$e5,$ff,$8e,$18,'1',$ff
	dc.b	$80,$f4,0,$f2,0,3,2,4
	dc.b	'p@',$fe,0,$b,2,$10,0
	dc.b	$80,0,0,'"',$82,' "',$8a
	dc.b	'#',$fb,0,$f3,0,$c,$ee,$7f
	dc.b	$88,$88,$1f,$87,$c4,$fd,5,8
	dc.b	' ',$1f,$80,$f4,0,$f4,0,$14
	dc.b	1,$fe,$fd,$84,'p',$7f,$df,$e1
	dc.b	$ff,2,$10,0,$ff,$80,0,'"'
	dc.b	$82,' "',$8a,'#',$fb,0,$f4
	dc.b	0,$d,1,$fe,$ff,$8c,$f8,$7f
	dc.b	$df,$e5,$ff,7,$18,' ',$ff,$80
	dc.b	$f4,0,$f3,0,9,4,0,8
	dc.b	$1c,'@',0,$1a,0,1,$10,$fd
	dc.b	0,5,'>',$f1,'@<',$89,'C'
	dc.b	$fb,0,$f3,0,$b,$fe,'?Ñ'
	dc.b	'"',$9f,$87,$e4,'x',2,$80,'@'
	dc.b	$8e,$f3,0,$f4,0,$14,1,$fa
	dc.b	$ff,$88,$1c,$7f,$df,$fb,$fe,1
	dc.b	$10,0,$7f,$80,0,'>',$f1,'@'
	dc.b	'<',$89,'C',$fb,0,$f4,0,$d
	dc.b	1,$fe,$ff,$8c,'>',$ff,$df,$ff
	dc.b	$fe,3,$90,'@',$ff,$80,$f4,0
	dc.b	$f3,0,$13,4,0,8,$e,$80
	dc.b	0,1,2,0,$90,0,'@',0
	dc.b	0,'"',$80,$83,'"',$88,$83,$fb
	dc.b	0,$f3,0,$b,$fe,$1f,$d0,'Q'
	dc.b	'?',$83,$e4,'x',1,'`',$80,$8e
	dc.b	$f3,0,$f4,0,$14,1,$fa,$7f
	dc.b	$c8,$e,$ff,$9f,$e1,$fe,0,$90
	dc.b	0,$7f,$80,0,'"',$80,$83,'"'
	dc.b	$88,$83,$fb,0,$f4,0,$d,1
	dc.b	$fe,$7f,$d8,'_',$ff,$9f,$e5,$fe
	dc.b	1,$f0,$80,$ff,$80,$f4,0,$f3
	dc.b	0,$13,4,0,'0',7,$80,$10
	dc.b	1,0,0,'p',0,'`',$80,0
	dc.b	'"',$f8,$83,'<p',$80,$fb,0
	dc.b	$f3,0,8,'~',$1f,$c8,$88,'?'
	dc.b	$a3,$e4,'8',0,$fe,$80,$f3,0
	dc.b	$f4,0,$14,1,$fa,$7f,$f0,7
	dc.b	$ff,$9f,$e1,$fe,0,'p',0,$7f
	dc.b	$80,0,'"',$f8,$83,'<p',$80
	dc.b	$fb,0,$f4,0,$d,1,$fe,$7f
	dc.b	$f8,$8f,$ff,$bf,$e5,$fe,0,$f0
	dc.b	$80,$ff,$80,$f4,0,$f3,0,$c
	dc.b	4,0,$10,3,$80,$10,'A',$80
	dc.b	0,'0',0,$83,$80,$fe,0,3
	dc.b	6,0,0,3,$fb,0,$f3,0
	dc.b	$b,'~',$f,$e1,4,'?#',$e4
	dc.b	'=',0,'I',1,'p',$f3,0,$f4
	dc.b	0,$d,1,$fa,'?',$f0,3,$ff
	dc.b	$1f,$a1,$fe,0,'0',0,$83,$80
	dc.b	$fe,0,3,6,0,0,3,$fb
	dc.b	0,$f4,0,$d,1,$fe,'?',$f1
	dc.b	7,$ff,'?',$e5,$ff,0,'y',1
	dc.b	$f3,$80,$f4,0,$f4,0,4,1
	dc.b	4,0,$80,1,$fe,0,4,$80
	dc.b	0,'8',3,1,$f3,0,$f3,0
	dc.b	$b,'~',7,$e1,2,'?G',$e8
	dc.b	'|',$80,'B',4,$a0,$f3,0,$f4
	dc.b	0,$c,1,$fa,'?`',1,$ff
	dc.b	$1f,$e1,$fe,0,'8',3,1,$f3
	dc.b	0,$f4,0,$c,1,$fe,'?',$e1
	dc.b	3,$ff,'_',$e9,$fe,$80,'z',7
	dc.b	$a1,$f3,0,$f4,0,$1a,1,0
	dc.b	$10,0,2,0,0,'@',$80,0
	dc.b	'8',4,1,0,0,'>',$f2,' '
	dc.b	'<',$f3,$e7,$9e,'r',$27,$80,0
	dc.b	0,$f3,0,$b,'~',1,$f2,$80
	dc.b	'~G',$e8,'|A',$84,$a,' '
	dc.b	$f3,0,$f4,0,$1a,1,$fe,$1f
	dc.b	$f0,3,$fe,$1f,$a1,$fe,0,'8'
	dc.b	4,1,0,0,'>',$f2,' <'
	dc.b	$f3,$e7,$9e,'r',$27,$80,0,0
	dc.b	$f4,0,$c,1,$fe,$1f,$f2,$83
	dc.b	$fe,'_',$e9,$fe,'A',$bc,$e,'!'
	dc.b	$f3,0,$f4,0,$17,1,0,$18
	dc.b	'@',2,0,0,'@',0,0,'<'
	dc.b	8,1,0,0,8,$8a,' "'
	dc.b	$8a,8,' #(',$fe,0,$f3
	dc.b	0,$b,'<',1,$f4,$80,$fe,'O'
	dc.b	$e8,'|&',2,'0@',$f3,0
	dc.b	$f4,0,$17,1,$fe,$1f,$b0,3
	dc.b	$fe,$1f,$a1,$fe,0,'<',8,1
	dc.b	0,0,8,$8a,' "',$8a,8
	dc.b	' #(',$fe,0,$f4,0,$c
	dc.b	1,$fe,$1f,$f4,$83,$fe,'_',$e9
	dc.b	$fe,'&>8A',$f3,0,$f4
	dc.b	0,$1a,1,$80,8,' ',4,0
	dc.b	0,$e0,0,0,'>0',1,0
	dc.b	0,8,$f1,'@<',$f3,$c7,$1c
	dc.b	'"',$a9,$80,0,0,$f3,0,$b
	dc.b	'=',1,$f8,'@',$fc,'O',$e8,'|'
	dc.b	$18,'A',$c0,'@',$f3,0,$f4,0
	dc.b	$1a,1,$fe,$f,$d8,7,$fc,$1f
	dc.b	1,$fe,0,'>0',1,0,0
	dc.b	8,$f1,'@<',$f3,$c7,$1c,'"'
	dc.b	$a9,$80,0,0,$f4,0,$c,1
	dc.b	$ff,$f,$f8,'G',$fc,'_',$e9,$fe
	dc.b	$18,$7f,$f0,'A',$f3,0,$f4,0
	dc.b	$1a,1,$80,$c,' ',4,2,0
	dc.b	'@',0,0,'q',$e0,1,0,0
	dc.b	8,$a0,$80,' ',$a2,0,$82,'"'
	dc.b	'h',$80,0,0,$f3,0,$b,'='
	dc.b	1,$f8,'!',$fc,$8f,$ea,'~`'
	dc.b	$e,0,$a0,$f3,0,$f4,0,$1a
	dc.b	1,$fe,$f,$d8,7,$fe,$1f,$a1
	dc.b	$fe,0,'q',$e0,1,0,0,8
	dc.b	$a0,$80,' ',$a2,0,$82,'"h'
	dc.b	$80,0,0,$f4,0,$c,1,$ff
	dc.b	$f,$f8,$27,$fe,$9f,$eb,$fe,'`'
	dc.b	$7f,$e0,$a1,$f3,0,$f4,0,$ff
	dc.b	1,9,4,$10,8,4,0,'A'
	dc.b	0,0,'`',$c0,$fe,0,$b,8
	dc.b	$98,$80,' ',$9b,$ef,'<r',$27
	dc.b	$80,0,0,$f3,0,$b,'<',1
	dc.b	$fc,'!',$fa,$a7,$ea,'?',$c0,$11
	dc.b	' ',$a1,$f3,0,$f4,0,$b,1
	dc.b	$ff,7,$ec,$f,$fc,$1f,$a1,$fe
	dc.b	0,'`',$c0,$fe,0,$b,8,$98
	dc.b	$80,' ',$9b,$ef,'<r',$27,$80
	dc.b	0,0,$f4,0,$c,1,$ff,7
	dc.b	$fc,'/',$fe,$bf,$eb,$ff,$c0,'q'
	dc.b	$e0,$a1,$f3,0,$f4,0,$ff,1
	dc.b	$a,4,$10,8,4,0,3,0
	dc.b	0,'` ',1,$f3,0,$f3,0
	dc.b	$b,'<',0,$fc,$13,$fa,$c7,$f0
	dc.b	'>@',2,'Q ',$f3,0,$f4
	dc.b	0,$c,1,$ff,7,$ec,$f,$fc
	dc.b	$1f,$e3,$fe,0,'` ',1,$f3
	dc.b	0,$f4,0,$c,1,$ff,7,$fc
	dc.b	$1f,$fe,$df,$f3,$fe,'@bq'
	dc.b	'!',$f3,0,$f3,0,$a,1,2
	dc.b	0,$10,$a,0,'C',$80,0,'@'
	dc.b	$18,$f2,0,$f3,0,$b,'xÑ'
	dc.b	'~',3,$f4,$87,$f0,$1e,$80,'$'
	dc.b	'%!',$f3,0,$f4,0,$b,1
	dc.b	$ff,3,$fe,$1f,$fa,$1f,$a3,$fe
	dc.b	0,'@',$18,$f2,0,$f4,0,$c
	dc.b	1,$ff,$87,$fe,$1f,$fe,$9f,$f3
	dc.b	$fe,$80,'d=!',$f3,0,$f3
	dc.b	0,$ff,3,8,$88,$10,2,0
	dc.b	3,$80,0,'@',4,$fe,0,8
	dc.b	$1e,$8b,$c7,$9c,$f0,4,$be,$89
	dc.b	$e0,$fe,0,$f3,0,$b,$f8,$88
	dc.b	'>',3,$f1,3,$f4,$1e,$80,$88
	dc.b	2,' ',$f3,0,$f4,0,$b,1
	dc.b	$ff,3,$f6,$1f,$f2,$1f,$e3,$fe
	dc.b	0,'@',4,$fe,0,8,$1e,$8b
	dc.b	$c7,$9c,$f0,4,$be,$89,$e0,$fe
	dc.b	0,$f4,0,$c,1,$ff,$8b,$fe
	dc.b	$1f,$f3,$1f,$f7,$fe,$80,$c8,6
	dc.b	' ',$f3,0,$f3,0,$a,3,$81
	dc.b	$80,'0',$11,$10,7,$80,0,$c0
	dc.b	6,$fe,0,7,' ',$8a,'("'
	dc.b	$88,5,' ',$8a,$fd,0,$f3,0
	dc.b	$b,$f8,$10,'?',3,$e2,1,$f0
	dc.b	'?',1,$14,1,' ',$f3,0,$f4
	dc.b	0,$b,1,$ff,$81,$ff,'?',$f1
	dc.b	$1f,$e7,$fe,0,$c0,6,$fe,0
	dc.b	7,' ',$8a,'("',$88,5,' '
	dc.b	$8a,$fd,0,$f4,0,$c,1,$ff
	dc.b	$91,$ff,'?',$f3,$1f,$f7,$ff,1
	dc.b	$d4,7,' ',$f3,0,$f3,0,$16
	dc.b	2,$81,$80,'0',$11,$10,$1a,0
	dc.b	0,$c0,5,$80,0,0,' ',$8b
	dc.b	$c7,'"',$f0,6,'<Q',$c0,$fe
	dc.b	0,$f3,0,$b,'y`?',3
	dc.b	$e0,$81,$e4,'?',2,'$',2,'`'
	dc.b	$f3,0,$f4,0,$17,1,$fe,$81
	dc.b	$ff,'?',$f1,$1f,$fb,$fe,0,$c0
	dc.b	5,$80,0,0,' ',$8b,$c7,'"'
	dc.b	$f0,6,'<Q',$c0,$fe,0,$f4
	dc.b	0,$c,1,$ff,$e1,$ff,'?',$f1
	dc.b	$9f,$ff,$ff,2,$e4,7,$e0,$f3
	dc.b	0,$f3,0,$13,2,'@',$80,'`'
	dc.b	$10,$90,$10,0,0,$80,4,$c0
	dc.b	0,0,' ',$8a,$80,$a2,$a0,5
	dc.b	$fe,' ',$fe,0,$f3,0,$c,'y'
	dc.b	$a0,$1f,3,$81,1,$e2,'~',4
	dc.b	'B',1,$1f,$80,$f4,0,$f4,0
	dc.b	$14,1,$fe,'@',$ff,$ff,$d0,$9f
	dc.b	$f1,$fe,0,$80,4,$ff,$80,0
	dc.b	' ',$8a,$80,$a2,$a0,5,$fe,' '
	dc.b	$fe,0,$f4,0,$d,1,$ff,$e0
	dc.b	$ff,$ff,$d1,$9f,$f3,$fe,4,$c2
	dc.b	5,$ff,$80,$f4,0,$f4,0,$17
	dc.b	1,0,' ',$c0,0,$10,$90,$10
	dc.b	0,0,$80,4,3,0,0,$1e
	dc.b	'zo',$1c,$98,4,$be,'#',$c0
	dc.b	$fe,0,$f3,0,$c,'x@',$1f
	dc.b	7,$80,'A',$e0,'~',8,2,0
	dc.b	$9f,$80,$f4,0,$f4,0,$17,1
	dc.b	$fe,' ',$ff,$ff,$d0,$9f,$f1,$fe
	dc.b	0,$80,4,'|',$80,0,$1e,'z'
	dc.b	'o',$1c,$98,4,$be,'#',$c0,$fe
	dc.b	0,$f4,0,$d,1,$fe,'`',$ff
	dc.b	$ff,$d0,$df,$f1,$fe,8,$82,4
	dc.b	$ff,$80,$f4,0,$f4,0,6,1
	dc.b	$80,' ',$c0,0,$10,'X',$fe,0
	dc.b	2,$80,4,1,$f3,0,$f3,0
	dc.b	$c,'<',$11,$1f,$ff,8,$a1,$f0
	dc.b	'~',$11,5,0,$bf,$80,$f4,0
	dc.b	$f4,0,$d,1,$fe,' ',$ff,$ff
	dc.b	$90,'_',$e1,$fe,0,$80,4,'~'
	dc.b	$80,$f4,0,$f4,0,$d,1,$fe
	dc.b	'1',$ff,$ff,$98,$ff,$f1,$fe,$11
	dc.b	$85,4,$ff,$80,$f4,0,$f4,0
	dc.b	$b,1,0,$10,$e0,0,$18,'x'
	dc.b	0,0,1,0,4,$f2,0,$f3
	dc.b	0,$c,'|!',7,$ff,0,1
	dc.b	$f0,'~ ',$84,$80,'?',$80,$f4
	dc.b	0,$f4,0,$d,1,$fe,$10,$ff
	dc.b	$ff,$98,$7f,$e1,$ff,1,0,4
	dc.b	$ff,$80,$f4,0,$f4,0,$d,1
	dc.b	$fe,'1',$ff,$ff,$98,$7f,$f1,$ff
	dc.b	'!',$84,$84,$ff,$80,$f4,0,$f2
	dc.b	0,9,$11,' ',0,$18,'0',0
	dc.b	0,1,0,4,$fe,0,6,$1c
	dc.b	$8b,$c0,'"',2,' >',$fc,0
	dc.b	$f3,0,$c,'~H',$c3,$fe,0
	dc.b	'A',$f0,'?B',$88,$80,$ff,$80
	dc.b	$f4,0,$f4,0,$15,1,$fe,$11
	dc.b	'?',$ff,$18,'?',$e1,$ff,$81,0
	dc.b	5,$ff,$80,0,$1c,$8b,$c0,'"'
	dc.b	2,' >',$fc,0,$f4,0,$d
	dc.b	1,$fe,'Y',$ff,$ff,$18,$7f,$f1
	dc.b	$ff,$c3,$88,$85,$ff,$80,$f4,0
	dc.b	$f2,0,$13,9,'8',0,$10,'0'
	dc.b	0,0,'C',$80,4,'@',0,0
	dc.b	'"',$ca,' ',$14,2,' ',4,$fc
	dc.b	0,$f3,0,$b,$fe,$90,3,$fc
	dc.b	8,1,$f0,'?$HC',$fe
	dc.b	$f3,0,$f4,0,$15,1,$fe,9
	dc.b	'?',$ff,$10,'?',$e1,$ff,$c3,$80
	dc.b	7,$bf,$80,0,'"',$ca,' ',$14
	dc.b	2,' ',4,$fc,0,$f4,0,$d
	dc.b	1,$fe,$99,'?',$ff,$18,'?',$f1
	dc.b	$ff,$e7,$c8,'G',$ff,$80,$f4,0
	dc.b	$f2,0,$13,$f,$18,1,$10,$10
	dc.b	0,0,1,0,1,$c0,0,0
	dc.b	'>',$aa,' ',8,1,'@',8,$fc
	dc.b	0,$f3,0,$b,'~',$80,3,$fc
	dc.b	0,'#',$e8,$f,$80,$1f,$ff,$fe
	dc.b	$f3,0,$f4,0,7,1,$fe,$f
	dc.b	$1f,$ff,$10,$1f,$e0,$fe,$ff,$a
	dc.b	$fe,'?',0,0,'>',$aa,' ',8
	dc.b	1,'@',8,$fc,0,$f4,0,7
	dc.b	1,$fe,$8f,$1f,$ff,$10,'?',$e8
	dc.b	$fc,$ff,$f3,0,$f2,0,9,7
	dc.b	$1c,1,$80,$10,0,$c0,0,3
	dc.b	$c3,$fe,0,6,'"ö ',$14
	dc.b	'0',$83,$10,$fc,0,$f3,0,$b
	dc.b	$7f,8,1,$fc,$10,$c3,$e8,7
	dc.b	$fc,$7f,$ff,$fe,$f3,0,$f4,0
	dc.b	$15,1,$fe,7,$1f,$ff,$80,$1f
	dc.b	$e0,$ff,$ff,$fc,'<',$ff,0,0
	dc.b	'"ö ',$14,'0',$83,$10,$fc
	dc.b	0,$f4,0,7,1,$ff,$f,$1f
	dc.b	$ff,$90,$df,$e8,$fc,$ff,$f3,0
	dc.b	$f4,0,8,1,0,2,$c,3
	dc.b	0,$10,0,'p',$fb,0,6,'"'
	dc.b	$8b,$c0,'"0',$83,'>',$fc,0
	dc.b	$f3,0,7,'>',5,1,$fc,$91
	dc.b	1,$e8,$83,$fe,$ff,0,$fe,$f3
	dc.b	0,$f4,0,8,1,$fe,2,$f
	dc.b	$ff,0,$1f,$e0,$7f,$fe,$ff,9
	dc.b	$fe,0,0,'"',$8b,$c0,'"0'
	dc.b	$83,'>',$fc,0,$f4,0,7,1
	dc.b	$fe,7,$f,$ff,$91,$1f,$e8,$fd
	dc.b	$ff,0,$fe,$f3,0,$f4,0,8
	dc.b	1,0,6,$c,1,0,$10,0
	dc.b	'p',$f7,0,1,'`',6,$fb,0
	dc.b	$f3,0,$b,$1e,1,1,$fc,2
	dc.b	0,')',0,$7f,$e1,$ff,$fc,$f3
	dc.b	0,$f4,0,8,1,$fe,6,$f
	dc.b	$fd,0,$1f,$e0,$7f,$fe,$ff,0
	dc.b	$fc,$fb,0,1,'`',6,$fb,0
	dc.b	$f4,0,8,1,$fe,7,$f,$fd
	dc.b	2,$1f,$e9,$7f,$fe,$ff,0,$fc
	dc.b	$f3,0,$f4,0,$a,1,$80,7
	dc.b	0,1,0,$18,0,'>',0,$c
	dc.b	$f1,0,$f3,0,$b,2,0,0
	dc.b	$f8,$e,0,6,'@0',0,$1f
	dc.b	'8',$f3,0,$f4,0,8,1,$fe
	dc.b	7,7,$f9,0,$1f,$e0,'?',$fe
	dc.b	$ff,0,$f8,$f3,0,$f4,0,8
	dc.b	1,$fe,7,7,$f9,$e,$1f,$e6
	dc.b	$7f,$fe,$ff,0,$f8,$f3,0,$f4
	dc.b	0,$c,1,$c0,$b,0,1,0
	dc.b	$1c,0,'>',0,$ff,0,8,$f3
	dc.b	0,$f2,0,5,4,0,'x',$11
	dc.b	0,4,$fd,0,0,$10,$f3,0
	dc.b	$f4,0,8,1,$fe,$b,7,$f9
	dc.b	0,$1f,$e0,'?',$fe,$ff,0,$e8
	dc.b	$f3,0,$f4,0,8,1,$fe,$f
	dc.b	7,$f9,$11,$1f,$e4,'?',$fe,$ff
	dc.b	0,$f8,$f3,0,$f2,0,$a,$11
	dc.b	0,1,0,7,0,'0',0,'!'
	dc.b	$80,$10,$f3,0,$f3,0,$b,$10
	dc.b	2,$80,'B',$e0,$c8,$98,'K',0
	dc.b	2,'@',8,$f3,0,$f2,0,$a
	dc.b	$11,0,1,0,7,0,'0',0
	dc.b	'!',$80,$10,$f3,0,$f3,0,$b
	dc.b	$10,$13,$80,'C',$e0,$cf,$98,'{'
	dc.b	0,'#',$c0,$18,$f3,0,$f2,0
	dc.b	$a,'0',$80,1,0,2,0,'@'
	dc.b	0,' p',$10,$f3,0,$f3,0
	dc.b	$b,$10,1,1,$82,$80,'% '
	dc.b	$a0,$c0,'@',$88,' ',$f3,0,$f2
	dc.b	0,$a,'0',$80,1,0,2,0
	dc.b	'@',0,' p',$10,$f3,0,$f3
	dc.b	0,$b,$10,'1',$81,$83,$80,$27
	dc.b	' ',$e0,$c0,'`',$f8,'0',$f3,0
	dc.b	$f2,0,$a,'`',$80,3,$80,2
	dc.b	1,$80,0,$c0,$c,' ',$f3,0
	dc.b	$f3,0,$b,' ',$10,'F',4,0
	dc.b	$15,'B@1 ',$12,$10,$f3
	dc.b	0,$f2,0,$a,'`',$80,3,$80
	dc.b	2,1,$80,0,$c0,$c,' ',$f3
	dc.b	0,$f3,0,$b,' p',$c6,7
	dc.b	$80,$17,'C',$c0,'1',$e0,$1e,'0'
	dc.b	$f3,0,$f2,0,$a,$f0,$e0,7
	dc.b	$c0,7,7,0,3,0,3,$a0
	dc.b	$f3,0,$f3,0,$b,' ',0,$18
	dc.b	$18,0,8,$98,$80,$c,$80,4
	dc.b	'P',$f3,0,$f2,0,$a,$f0,$e0
	dc.b	7,$c0,7,7,0,3,0,3
	dc.b	$a0,$f3,0,$f3,0,$b,' ',$f0
	dc.b	$f8,$1f,$c0,$f,$9f,$80,$f,$80
	dc.b	7,$f0,$f3,0,$f4,0,5,6
	dc.b	0,0,$81,$e3,$80,$fb,0,0
	dc.b	$e0,$f3,0,$f4,0,$d,$1f,$dc
	dc.b	9,$f,$f0,'!',$8f,$ff,$87,$ff
	dc.b	$fc,$c,$1f,$f0,$f4,0,$f4,0
	dc.b	$d,$19,$ff,$f0,$fe,$1f,$c1,$ff
	dc.b	$ff,7,$ff,$fc,$1f,$ff,$f0,$f4
	dc.b	0,$f4,0,$d,$1f,$ff,$f9,$ff
	dc.b	$ff,$e1,$ff,$ff,$87,$ff,$fc,$1f
	dc.b	$ff,$f0,$f4,0,$ed,0,6,2
	dc.b	0,0,4,0,0,$10,$f4,0
	dc.b	$f4,0,$d,'?',$1f,$e1,'?<'
	dc.b	1,$fc,'g',$8f,$f8,$ce,$1f,$ff
	dc.b	$f8,$f4,0,$f4,0,$d,'?',$ff
	dc.b	$f8,$ff,$ff,$e3,$ff,$fd,$8f,$ff
	dc.b	$fa,'?',$ff,$e8,$f4,0,$f4,0
	dc.b	$d,'?',$ff,$f9,$ff,$ff,$e3,$ff
	dc.b	$ff,$8f,$ff,$fe,'?',$ff,$f8,$f4
	dc.b	0,$f3,0,$c,$c0,0,0,'@'
	dc.b	0,0,$11,0,0,2,0,$c
	dc.b	8,$f4,0,$f4,0,$d,'x',0
	dc.b	'x',$fc,7,$c3,$c0,3,$8f,' '
	dc.b	7,$7f,$80,'<',$f4,0,$f4,0
	dc.b	$d,$7f,$ff,$fd,$ff,$ff,$f7,$ff
	dc.b	$fe,$df,$ff,$fd,$7f,$ff,$f4,$f4
	dc.b	0,$f4,0,$d,$7f,$ff,$fd,$ff
	dc.b	$ff,$f7,$ff,$ff,$df,$ff,$ff,$7f
	dc.b	$ff,$fc,$f4,0,$f0,0,9,1
	dc.b	0,0,'q',0,1,$c2,0,0
	dc.b	8,$f4,0,$f4,0,$d,'p',0
	dc.b	'<',$f0,'@',$e3,$c1,$89,$e,2
	dc.b	$27,'z',8,$9c,$f4,0,$f4,0
	dc.b	$d,'|',0,'}',$f0,1,$f7,$c0
	dc.b	'v',$df,1,$dd,'|',0,'t',$f4
	dc.b	0,$f4,0,$d,'|',0,'}',$f0
	dc.b	'A',$f7,$c1,$ff,$df,3,$ff,'~'
	dc.b	8,$fc,$f4,0,$ef,0,8,' '
	dc.b	0,' ',0,0,$80,4,0,'H'
	dc.b	$f4,0,$f4,0,$d,'0',0,$1c
	dc.b	$e0,'@q',$80,'Q',$86,1,'C'
	dc.b	'z',$10,$9c,$f4,0,$f4,0,$d
	dc.b	'x',0,'=',$e0,0,$d7,$80,'#'
	dc.b	$de,0,$8f,'|',0,'t',$f4,0
	dc.b	$f4,0,$d,'x',0,'=',$e0,'@'
	dc.b	$f7,$80,'s',$de,1,$cf,'~',$10
	dc.b	$fc,$f4,0,$ef,0,8,' ',0
	dc.b	'@',0,1,0,2,0,$c0,$f4
	dc.b	0,$f4,0,$d,'8',0,0,$e1
	dc.b	$c0,'q',$80,'!',$87,$c0,$83,'<'
	dc.b	'`',$1c,$f4,0,$f4,0,$d,'x'
	dc.b	0,1,$e0,0,$d7,$80,'C',$de
	dc.b	1,$f,'z',0,$fc,$f4,0,$f4
	dc.b	0,$d,'x',0,1,$e1,$c0,$f7
	dc.b	$80,'c',$df,$c1,$8f,'~`',$fc
	dc.b	$f4,0,$ef,0,8,4,0,'@'
	dc.b	0,1,0,2,1,'@',$f4,0
	dc.b	$f4,0,$d,'8',0,0,'q',1
	dc.b	$f1,$f0,$81,$c4,$f2,7,'9',$80
	dc.b	$9c,$f4,0,$f4,0,$d,'x',0
	dc.b	1,$f0,1,$f7,$80,'C',$de,1
	dc.b	$f,'z',1,'|',$f4,0,$f4,0
	dc.b	$d,'x',0,1,$f1,1,$f7,$f0
	dc.b	$c3,$de,$f3,$f,'{',$81,$fc,$f4
	dc.b	0,$f0,0,8,$e0,4,0,$80
	dc.b	0,2,0,1,2,$f3,0,$f4
	dc.b	0,$d,'?',$ff,$e0,'?',$ff,$e1
	dc.b	$8f,'A',$c4,'}',3,':',0,'L'
	dc.b	$f4,0,$f4,0,$d,$7f,$ff,$f0
	dc.b	$ff,$1f,$e7,$80,$83,$de,2,$f
	dc.b	'y',2,'<',$f4,0,$f4,0,$d
	dc.b	$7f,$ff,$f0,$ff,$ff,$e7,$8f,$c3
	dc.b	$de,$7f,$f,'{',2,'|',$f4,0
	dc.b	$f2,0,$a,'@',0,0,4,1
	dc.b	0,0,2,0,'A',4,$f3,0
	dc.b	$f4,0,$d,$1e,$83,$e0,$7f,$c7
	dc.b	$c1,$80,$81,$c4,'L',3,'8',$80
	dc.b	$c,$f4,0,$f4,0,$d,$7f,$ff
	dc.b	$b8,$7f,$ff,$c7,$81,3,$de,2
	dc.b	$f,'y',4,'<',$f4,0,$f4,0
	dc.b	$d,$7f,$ff,$f8,$7f,$ff,$c7,$81
	dc.b	$83,$de,'N',$f,'yÑ<',$f4
	dc.b	0,$f4,0,$c,'@| ',0
	dc.b	$10,$80,1,0,0,4,0,'@'
	dc.b	$88,$f3,0,$f4,0,$d,$1c,0
	dc.b	$f0,$fc,3,$e3,$82,$c0,$8c,$82
	dc.b	3,$19,0,$c,$f4,0,$f4,0
	dc.b	$d,$7f,$ff,$dc,$ff,$ff,'g',$81
	dc.b	3,$de,4,$f,'x',$88,'<',$f4
	dc.b	0,$f4,0,$d,$7f,$ff,$fc,$ff
	dc.b	$ff,$e7,$83,$c3,$de,$86,$f,'y'
	dc.b	$88,'<',$f4,0,$f4,0,1,'@'
	dc.b	$10,$fe,0,7,'@',2,0,0
	dc.b	4,0,'@',$90,$f3,0,$f4,0
	dc.b	$d,$18,' ',$11,$fc,0,$f3,$81
	dc.b	'`',$8c,$88,6,$18,'@',$1c,$f4
	dc.b	0,$f4,0,$d,'|',$10,'}',$f0
	dc.b	1,$b7,$82,3,$de,4,$f,'x'
	dc.b	$90,'<',$f4,0,$f4,0,$d,'|'
	dc.b	'0}',$fc,1,$f7,$83,'c',$de
	dc.b	$8c,$f,'x',$d0,'<',$f4,0,$f4
	dc.b	0,1,'@ ',$fe,0,7,' '
	dc.b	2,0,0,$a,0,'@`',$f3
	dc.b	0,$f4,0,$d,$18,$10,$18,$e3
	dc.b	$c0,'qÑ0',$8f,$10,6,$18
	dc.b	$80,$1c,$f4,0,$f4,0,$d,'x'
	dc.b	' =',$e0,0,$d7,$82,3,$de
	dc.b	$a,$f,'x`<',$f4,0,$f4
	dc.b	0,$d,'x0=',$e3,$c0,$f7
	dc.b	$86,'3',$df,$1a,$f,'x',$e0,'<'
	dc.b	$f4,0,$f3,0,$ff,' ',$ff,0
	dc.b	7,'$',4,0,0,9,0,'@'
	dc.b	'@',$f3,0,$f4,0,$d,$18,$10
	dc.b	$1c,$e0,'<q',$82,$11,$87,$10
	dc.b	6,$18,$80,$1c,$f4,0,$f4,0
	dc.b	$d,'x =',$e0,0,$d7,$84
	dc.b	3,$de,9,$f,'x@<',$f4
	dc.b	0,$f4,0,$d,'x0=',$e0
	dc.b	'<',$f7,$86,$13,$df,$19,$f,'x'
	dc.b	$c0,'<',$f4,0,$f3,0,0,' '
	dc.b	$fe,0,$ff,4,$ff,0,3,$10
	dc.b	$80,0,$80,$f3,0,$f4,0,$d
	dc.b	'8P',$1c,'`',3,'a',$88,$1d
	dc.b	$86,' l9@<',$f4,0
	dc.b	$f4,0,$d,'x =',$e0,0
	dc.b	$f7,$84,3,$de,$10,$8f,'x',$80
	dc.b	'<',$f4,0,$f4,0,$d,'xp'
	dc.b	'=',$e0,3,$f7,$8c,$1f,$de,'0'
	dc.b	$ef,'y',$c0,'<',$f4,0,$f3,0
	dc.b	$b,'p',1,0,0,4,$1e,0
	dc.b	0,'8`',3,$80,$f3,0,$f4
	dc.b	0,$d,$1c,$88,'|p',1,$e1
	dc.b	$e1,$9f,$87,0,$9c,'<`|'
	dc.b	$f4,0,$f4,0,$d,'|p}'
	dc.b	$f0,1,$f7,$de,7,$df,'8',$7f
	dc.b	$7f,$80,'|',$f4,0,$f4,0,$d
	dc.b	'|',$f8,'}',$f0,1,$f7,$ff,$9f
	dc.b	$df,'8',$ff,$7f,$e0,'|',$f4,0
	dc.b	$f2,0,0,1,$f9,0,0,'@'
	dc.b	$f2,0,$f4,0,$d,$1f,$ff,$fc
	dc.b	'?',$fe,$e1,$ff,$ff,$c3,$ff,$fe
	dc.b	$1f,$ff,$fc,$f4,0,$f4,0,$d
	dc.b	$7f,$ff,$fd,$ff,$ff,$f7,$ff,$ff
	dc.b	$df,$ff,$ff,$7f,$ff,$fc,$f4,0
	dc.b	$f4,0,$d,$7f,$ff,$fd,$ff,$ff
	dc.b	$f7,$ff,$ff,$df,$ff,$ff,$7f,$ff
	dc.b	$fc,$f4,0,$f1,0,0,$80,$fa
	dc.b	0,0,' ',$f2,0,$f4,0,$d
	dc.b	7,$f1,$f8,'?',$c0,'@',$f8,7
	dc.b	$81,6,$e,3,$fc,$18,$f4,0
	dc.b	$f4,0,$d,'?',$ff,$f8,$ff,$ff
	dc.b	$e3,$ff,$ff,$8f,$ff,$fe,'?',$ff
	dc.b	$f8,$f4,0,$f4,0,$d,'?',$ff
	dc.b	$f8,$ff,$ff,$e3,$ff,$ff,$8f,$ff
	dc.b	$fe,'?',$ff,$f8,$f4,0,$f3,0
	dc.b	6,4,0,0,$1e,0,0,$e0
	dc.b	$fd,0,1,3,$80,$f4,0,$f4
	dc.b	0,5,7,0,$10,$e,0,'@'
	dc.b	$fb,0,0,'@',$f3,0,$f4,0
	dc.b	$d,$1f,$ff,$f0,$7f,$ff,$c1,$ff
	dc.b	$ff,7,$ff,$fc,$1f,$ff,$f0,$f4
	dc.b	0,$f4,0,$d,$1f,$ff,$f0,$7f
	dc.b	$ff,$c1,$ff,$ff,7,$ff,$fc,$1f
	dc.b	$ff,$f0,$f4,0
	bss
color	ds.w	1
scr1	ds.l	1
scr2	ds.l	1
rotatedp	ds.b	200
planes2d	ds.b	200
points2d	ds.b	200
points	ds.b	400
leftpts	ds.b	400
rigtpts	ds.b	400
clipa	ds.b	400
clipb	ds.b	400
palette	ds.b	32
oldvbl	ds.l	1
safe	ds.b	80
zuend	end
