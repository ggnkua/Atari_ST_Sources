	output	a:\auto\toki.prg
	opt	o+,ow-
ecran0 = $80000-32000
ecran1 = ecran0-32000
ramtop = ecran1
hauteur = 176
largeur = 224
basemfp = $40
;
; animation d'un ‚cran largeur*hauteur
;
	offset	$140
ecran:	ds.l	1
sync:	ds.w	1
touche:	ds.b	1
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
	lea	ramtop,sp
	move.l	#ecran0,d0
	move.l	d0,ecran
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	jsr	debugger

	move.b	#$10,$fffffa17.w
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
	move.l	#kbd,basemfp+$18.w
	move.b	#$40,$fffffa09.w
	move.b	#$40,$fffffa15.w

	move.l	#vbl,$70.w

	move	#$2300,sr

	lea	bitmap,a0
	lea	endbitmap,a1
	move	#(largeur+16)*hauteur/2-1,d1
	moveq	#0,d0
clear_it:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	clear_it

	lea	ramtop,a0
	lea	$80000,a1
	moveq	#-1,d0
fill_mem:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	fill_mem

	moveq	#0,d0
	jsr	musique

	bsr	initrefresh

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
	move.l	ecran,a0
	lea	hauteur*160+largeur/2(a0),a0
	move.l	a0,usp
;	lea	bitmap,a6
	move.l	ptrbuf,a6

	move	#$300,sr			;gain=8 cycles

	bra	fastscroller

retour:	addq	#6,sp
	move	#$700,$ffff8240.w
	BSR	REFRESH

	move	#$777,$ffff8240.w
	clr	sync

	move.l	ecran,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	eor.l	#ecran0^ecran1,ecran

	bra	boucle

vbl:	addq	#1,sync
	jsr	musique+14
	rte
fastscroller
;
; la routine suivante fait 24 octets
;
x	set	hauteur*(largeur+16)/2
	rept	hauteur
x	set	x-(largeur+16)/2
	movem.l	x+56(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	movem.l	x(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	ifne	x
	lea	-160+largeur/2(a7),a7
	endc
	endr
	illegal

palette:
	DC.W	$000,$102,$213,$324,$435,$657,$776,$412
	DC.W	$762,$740,$612,$547,$300,$200,$070,$070

bug:	move	#$2700,sr
1$	addq	#7,$ffff8240.w
	bra.s	1$
kbd:
	tst.b	$fffffc00.w
	bpl.s	bug
	move	d0,-(sp)
	clr	d0
	move.b	$fffffc02.w,d0
	move.b	d0,touche
	move	(sp)+,d0
;	addq	#7,$ffff8240.w
	rte

compteur:dc.w	101
direction:dc.w	0
count:	dc.w	0
ptrbuf:	dc.l	0
;
; ptrbuf est un pointeur pour le haut … gauche
; PTR est le pointeur courant pour les vignettes
;
initrefresh:
	move.l	#bitmap,ptrbuf
	MOVE.L	#blocks,PTR
	rts

REFRESH:
	subq	#1,compteur
	bpl.s	.notnew
	not	direction
	move	#100,compteur
.notnew
	tst	direction
	bpl.s	.droite
	move	count,d0
	bne.s	.not01
	subq.l	#1,PTR
	subq.l	#8,ptrbuf
.not01
	subq	#1,d0
	and	#3,d0
	move	d0,count
	move.l	ptrbuf,a6
	subq	#8,a6
	bra.s	.display
.droite
	move	count,d0
	addq	#1,d0
	and	#3,d0
	move	d0,count
	bne.s	.not02
	addq.l	#1,PTR
	addq.l	#8,ptrbuf
.not02
	move.l	ptrbuf,a6
	lea	largeur/2-8(a6),a6
.display
	MOVE.L	PTR,A4
	MOVEQ	#(hauteur+16)/16-1,D7
;	lea	bitmap,a6
	lea	shifter(pc),a2
	add	2(a2),a2

shifte	macro
	lea	\@(pc),a3
	jmp	(a2)
\@
	endm

x	set	0
	rept	(hauteur+16)/16

;	addq	#7,$ffff8240.w
	MOVEQ	#0,D0
	MOVE.B	x(A4),D0
	ASL	#7,D0

	LEA	blocks+$DC,A5
	ADD	D0,A5		;a5=source bitmap
;
; d5-d7/a2-a4 non utilis‚s dans shift.bin
;
;	addq	#7,$ffff8240.w
	shifte
x	set	x+20
	endr
	rts

PTR:	DC.L	0

shifter:incbin	shift3.bin

debugger:incbin	debugger.bin

musique:incbin	dave.bin

blocks:	incbin	VIGN.IMG

	section	bss
	ds.b	8
bitmap:
	ds.b	(largeur+16)*hauteur/2		;d‚calage=0
	ds.b	(largeur+16)*hauteur/2		;d‚calage=4
	ds.b	(largeur+16)*hauteur/2		;d‚calage=8
	ds.b	(largeur+16)*hauteur/2		;d‚calage=12
endbitmap:
