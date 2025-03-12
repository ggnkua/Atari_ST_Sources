	output	a:\auto\toki.prg
	opt	o+,ow-
ecran = $80000-32000
largeur = 224
hauteur = 176
;
; animation d'un ‚cran largeur*hauteur
;
	offset	$140
sync:	ds.w	1
	section	text

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	lea	ecran,sp
	move.l	#ecran,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	jsr	debugger

	move.l	#vbl,$70.w

	move	#$2300,sr

	lea	bitmap,a0
	moveq	#0,d0
fill_it:move	d0,(a0)+
	addq	#1,d0
	bne.s	fill_it

	lea	blocks+128,a5		;d‚but datas blocks
	lea	bitmap,a6

	moveq	#hauteur/16-1,d7
0$
	moveq	#largeur/16-1,d6
1$
	move.l	a6,a0
	moveq	#16-1,d0
2$	move.l	(a5)+,(a0)+
	move.l	(a5)+,(a0)+
	lea	largeur/2-8(a0),a0
	dbra	d0,2$

	cmp.L	#endblocks,a5
	blo.s	3$
	lea	blocks+128,a5
3$
	addq	#8,a6
	dbra	d6,1$
	lea	largeur/2*15(a6),a6
	dbra	d7,0$

	clr	sync
oucle:	tst	sync
	beq.s	oucle
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	clr	sync
boucle:	tst	sync
	beq.s	boucle
	clr	$ffff8240.w
	clr	sync

	move.l	#retour,$10.w
;	and	#$dfff,sr
	move	#$300,sr			;gain=8 cycles
	lea	bitmap,a6
	lea	ecran+hauteur*160+largeur/2,a7

x	set	hauteur*largeur/2
	rept	hauteur
x	set	x-largeur/2
	movem.l	x+56(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	movem.l	x(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	ifne	x
	lea	-160+largeur/2(a7),a7
	endc
	endr
	illegal
retour:	addq	#6,sp
	move	#$777,$ffff8240.w
	bra	boucle

vbl:	addq	#1,sync
	rte
palette:
	DC.W	$000,$600,$400,$300,$110,$223,$445,$777
	DC.W	$322,$433,$544,$655,$767,$730,$331,$707

;	dc.w	0
;	dcb.w	15,$700
debugger:incbin	debugger.bin

blocks:	incbin	blockvar.blk
endblocks:
bitmap:
