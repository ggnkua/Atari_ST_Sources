	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	PEA	DEMO(PC)
	MOVE.W	#38,-(SP)
	TRAP	#14
	LEA	6(SP),SP
	CLR.W	-(SP)
	TRAP	#1


DEMO
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,save_colors

	bsr	Predecale_balles

loopi	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp

	move.w	anim,d0
	addq	#1,d0
	and	#127,d0
	move.w	d0,anim

	
	move.w	#$707,$ffff8240.w
	lea	$1f8000,a1
	moveq	#0,d0
burne	set	0
	rept	32
	move	d0,burne(a1)
burne	set	burne+160
	endr

	lea	buffer_mask,a0
	lea	$1f8000,a1
clito	set	0
	rept	16
	movem.w	(a0)+,d0-d5
	and.w	d0,clito(a1)
	and.w	d1,clito+8(a1)
	and.w	d2,clito+16(a1)
clito	set	clito+160
	and.w	d3,clito(a1)
	and.w	d4,clito+8(a1)
	and.w	d5,clito+16(a1)
clito	set	clito+160
	endr

	move.w	anim,d0
	mulu	#16*32*6,d0
	lea	buffer_dots,a0
	add.w	d0,a0
	lea	$1f8000,a1
anus	set	0
	rept	16
	movem.w	(a0)+,d0-d5
	move.w	d0,anus(a1)
	move.w	d1,anus+8(a1)
	move.w	d2,anus+16(a1)
anus	set	anus+160
	move.w	d3,anus(a1)
	move.w	d4,anus+8(a1)
	move.w	d5,anus+16(a1)
anus	set	anus+160
	endr
	move.w	#$777,$ffff8240.w

	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp

	cmpi.b	#$39,$fffffc02.w
	bne	loopi

	movem.l	save_colors,d0-d7
	movem.l	d0-d7,$ffff8240.w

	RTS
save_colors	ds.l	8

anim	dc.w	0

Predecale_balles
	lea	buffer_mask,a1
	move.w	#0,d7
nextm	lea	mask,a0
	move.w	#31,d6
linem	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0),d0
	move.w	8(a0),d1
	ror.l	d7,d0
	ror.l	d7,d1
	move.w	d0,(a1)
	not.w	(a1)+
	swap	d0
	or.w	d0,d1
	not.l	d1
	or.w	d1,(a1)+
	swap	d1
	move.w	d1,(a1)+
	lea	16(a0),a0
	dbra	d6,linem
	addq	#1,d7
	cmpi.w	#16,d7
	bne	nextm

	lea	dotsballs,a2
	lea	buffer_dots,a1
	move.w	#127,d5
nextanim
	move.w	#0,d7
nextb	move.l	a2,a0
	move.w	#31,d6
lineb	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0),d0
	move.w	2(a0),d1
	ror.l	d7,d0
	ror.l	d7,d1
	move.w	d0,(a1)+
	swap	d0
	move.w	d0,(a1)
	or.w	d1,(a1)+
	swap	d1
	move.w	d1,(a1)+
	lea	6(a0),a0
	dbra	d6,lineb
	addq	#1,d7
	cmp.w	#16,d7
	bne	nextb
	lea	6*32(a2),a2
	dbra	d5,nextanim
	rts

mask	incbin	a:mask.dat
dotsballs
	incbin	a:dotballs.dat
buffer_mask
	ds.b	16*32*6
buffer_dots

	end
