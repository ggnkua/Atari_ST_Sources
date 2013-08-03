	output	a:\auto\toki.prg

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	lea	$78000,a0
	move.l	a0,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move	#200/16-1,d0
	lea	vignette(pc),a1
vertic:
	moveq	#320/16-1,d1
horiz:
	moveq	#16-1,d2
fill:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	lea	160-8(a0),a0
	dbra	d2,fill
	lea	-16*160+8(a0),a0
	cmp.l	#finvignette,a1
	blo.s	1$
	lea	vignette(pc),a1
1$
	dbra	d1,horiz
	lea	160*16-8*20(a0),a0
	dbra	d0,vertic

plante:
	bra	plante


palette:
	DC.W	$001,$004,$026,$047,$707,$707,$077,$555
	DC.W	$333,$733,$373,$773,$337,$737,$377,$337

vignette
	incbin	newvig.img
finvignette
