
	bra	setup_stars
	bra	plot_stars
	bra	move_stars

perspective=2
stars=0
xmin=4
ymin=6
xmax=8
ymax=10
xcenter=12
ycenter=14
seed=16

	opt	o+
		
move_stars
	movem.l	d1-7/a0-6,-(a7)
	movem	60(a7),d4-6
	lea	vars(pc),a6
	move	stars(a6),d7
	lea	xyz(pc),a0

.lp	move	(a0),d2
	tst	d4
	beq.s	.noxinc
	bmi.s	.xdec
.xinc	add	d4,d2
	cmp	#1024,d2
	blt.s	.noxinc
	sub	#2048,d2
	bra.s	.noxinc
.xdec	add	d4,d2
	cmp	#-1024,d2
	bgt.s	.noxinc
	add	#2048,d2
.noxinc	move	d2,(a0)+

	move	(a0),d2
	tst	d5
	beq.s	.noyinc
	bmi.s	.ydec
.yinc	add	d5,d2
	cmp	#1024,d2
	blt.s	.noyinc
	sub	#2048,d2
	bra.s	.noyinc
.ydec	add	d5,d2
	cmp	#-1024,d2
	bgt.s	.noyinc
	add	#2048,d2
.noyinc	move	d2,(a0)+

	move	(a0),d2
	tst	d6
	beq.s	.nozinc
	bmi.s	.zdec
.zinc	add	d6,d2
	bmi.s	.nozinc
	bsr.s	random
	and	#2047,d0
	sub	#1024,d0
	move	d0,-4(a0)
	bsr.s	random
	and	#2047,d0
	sub	#1024,d0
	move	d0,-2(a0)
	sub	#4090,d2
	bra.s	.nozinc
	
.zdec	add	d6,d2
	cmp	#-4090,d2
	bgt.s	.nozinc
	bsr.s	random
	and	#2047,d0
	sub	#1024,d0
	move	d0,-4(a0)
	bsr.s	random
	and	#2047,d0
	sub	#1024,d0
	move	d0,-2(a0)
	add	#4090,d2
.nozinc	move	d2,(a0)+

	dbf	d7,.lp
	movem.l	(a7)+,d1-7/a0-6
	rts

random	move	seed(a6),d0
	addq	#1,d0
	move	d0,d1
	add	d0,d0
	add	d1,d0
	ror	#7,d0
	move	d0,seed(a6)
	rts
	
setup_stars
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7
	cmp	#200,d7
	ble.s	.ok
	move	#200,d7
.ok	move	62(a7),d0
	bsr	make_ztable
	lea	vars(pc),a6
	movem	64(a7),d0-5
	move	d0,xcenter(a6)
	move	d1,ycenter(a6)
	move	d2,xmin(a6)
	move	d3,ymin(a6)
	move	d4,xmax(a6)
	move	d5,ymax(a6)
	subq	#1,d7
	move	d7,stars(a6)
	lea	xyz(pc),a0
.lp	bsr.s	random
	and	#2047,d0
	sub	#1024,d0
	move	d0,(a0)+
	bsr.s	random
	and	#2047,d0
	sub	#1024,d0
	move	d0,(a0)+
	bsr.s	random
	and	#4095,d0
	neg	d0
	move	d0,(a0)+
	dbf	d7,.lp
	lea	xyz(pc),a0
	move.l	a0,d0
	movem.l	(a7)+,d1-7/a0-6
	rts

plot_stars
	movem.l	d1-7/a0-6,-(a7)
	move.l	60(a7),a0
	lea	ztable(pc),a4
	lea	vars(pc),a6
	move	stars(a6),d7
	lea	xyz(pc),a1
starlp	movem	(a1)+,d0-2
	neg	d2
	and	#$ffe,d2
	muls	(a4,d2.w),d0
	muls	(a4,d2.w),d1
	add.l	d0,d0
	add.l	d1,d1
	swap	d0
	swap	d1
	add	xcenter(a6),d0
	add	ycenter(a6),d1
	ext.l	d2
	lsl.l	#6,d2
	swap	d2

plot	cmp	ymin(a6),d1
	blt.s	off_screen
	cmp	ymax(a6),d1
	bgt.s	off_screen
	cmp	xmin(a6),d0
	blt.s	off_screen
	cmp	xmax(a6),d0
	bgt.s	off_screen
	and.l	#$ffff,d1
	move	d1,d3
	lsl	#2,d1
	add	d3,d1
	lsl.l	#5,d1
	move.l	a0,a2
	add.l	d1,a2
	move	d0,d3
	lsr	#1,d3
	and	#$fff8,d3
	add	d3,a2
	and	#$f,d0
	add	d0,d0
	add	d0,d0
	move.l	pixmask(pc,d0),d0
	cmp	#2,d2
	blt.s	fore
	beq.s	mid
back	or	d0,(a2)
	bra.s	off_screen
fore	or.l	d0,(a2)
	bra.s	off_screen
mid	or	d0,2(a2)

off_screen
	dbf	d7,starlp
	movem.l	(a7)+,d1-7/a0-6
	rts


pixmask	dc.l	$80008000,$40004000,$20002000,$10001000
	dc.l	$08000800,$04000400,$02000200,$01000100
	dc.l	$00800080,$00400040,$00200020,$00100010
	dc.l	$00080008,$00040004,$00020002,$00010001

make_ztable
	lea	ztable(pc),a0
	move.l	a0,a1
	and.l	#$ffff,d0
	move.l	d0,d1
	swap	d0
	asr.l	#1,d0
	moveq	#0,d2

.lp	move.l	d1,d3
	sub.l	d2,d3
	move.l	d0,d4
	divs	d3,d4
	move	d4,(a0)+
	
	subq	#2,d2
	cmp	#-4096,d2
	bgt.s	.lp
	move	2(a1),(a1)
	rts
	
ztable	ds.w	2048
vars	ds.w	2
	dc.w	0,0,319,199
	dc.w	160,100,31415
xyz	ds.w	200*3
