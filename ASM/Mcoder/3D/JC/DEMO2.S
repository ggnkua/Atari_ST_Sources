	opt	o+
DEBUG = 1		;0=debugger
ecran1 = $80000-32000
ecran0 = ecran1-32000
plans = 1		;nb plans … effacer
nbseg = 4		;3
;
; 07/06/90 fait en 30 minutes !!!
; 09/06/90 affichage d'un polygone rempli en 1 plan
;
;  attention, on doit OBLIGATOIREMENT calculer tous les points de chaque
;   segment parce que ‡a merderait quand ‡a clippe
;  en plus ‡a permet d'‚viter d'avoir … effacer le tableau des Y !!!
;
; manquent :
;	- un clipping en Y
;	- on peut enlever les divisions en calculant les points de la maniŠre
;	  suivante :
;			add.l	PENTE,x
;			swap	x
;			move	(a6)+,(a6)+
;			move	x,-4(a6)
;			swap	x
;	avec PENTE lu dans une table
;
PLOT	MACRO
	move	(a6)+,(a6)+
	move	d0,-4(a6)
	ENDM
PLOT2	MACRO
	cmp	a5,d7
	bne.s	.\@
	move	(a6)+,(a6)+
	move	d0,-4(a6)
.\@
	ENDM
;
; remarques :
;	- au lieu de :
;			move	(a6)+,(a6)+
;			move	d0,-4(a6)
;	  on peut mettre :
;			move	2(a6),(a6)+
;			move	d0,(a6)+
;
; entr‚e :
;	SEGMENTS contient les coordonn‚es des points projet‚s
; sortie :
;	d6 = Y minimum du polygone
;	d7 = Y maximum
;	CALCULES contient les coordonn‚es X pour chaque Y
;

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	ifeq	DEBUG
	jsr	debugger
	endc

	lea	ecran0,sp		;super stack

	move.l	#ecran0,d0
	move.l	d0,ecran
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	lea	ecran0,a0
	move	#($80000-ecran0)/4-1,d0
	moveq	#0,d1
.cls
	move.l	d1,(a0)+
	dbra	d0,.cls

	move.l	#vbl,$70.w
	move	#$2300,sr
	clr	sync
.vbl1	tst	sync
	beq.s	.vbl1
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	ifeq	plans-1
;
; routine de Fastcls en code g‚n‚r‚
;
	lea	fastcls,a0
	move	#$3080,(a0)+	;move d0,(a0)
	move.l	#$31400008,d0
setup:
	move.l	d0,(a0)+
	addq	#8,d0
	cmp	#32000,d0
	blo.s	setup
	move	#$4e75,(a0)+
	endc

	ifeq	plans-4
	move.l	#retr,$80.w
	endc
demo
	clr	sync
.vbl	tst	sync
	beq.s	.vbl

	ifeq	plans-4

	move	#$300,sr
	move.l	ecran,a7
	lea	32000(a7),a7

	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6

x	set	0
	rept	32000/15/4
	movem.l	d0-d7/a0-a6,-(a7)
x	set	x+15*4
	endr
	movem.l	d0-d4,-(a7)
x	set	x+5*4

	trap	#0
	elseif
	moveq	#0,d0
	move.l	ecran,a0
;	move	d0,(a0)
	jsr	fastcls
	endc

	bsr	polycalc

	move	vit1,d0
	add	coord1,d0
	cmp	#320,d0
	blo.s	1$
	sub	vit1,d0
	neg	vit1
1$
	move	d0,coord1

	move	vit2,d0
	add	coord2,d0
	cmp	#200,d0
	blo.s	2$
	sub	vit2,d0
	neg	vit2
2$
	move	d0,coord2

	move.l	ecran,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	eor.l	#ecran0^ecran1,ecran
	bra	demo
vit1	dc.w	1
vit2	dc.w	1
ecran:	dc.l	0
sync:	dc.w	0
vbl:	addq	#1,sync
	rte
retr:	rtr
palette:dc.w	0
	dcb.w	15,$700

polycalc
	move	#$777,$ffff8240.w
	move	#199,d6		;Y minimum
	moveq	#0,d7		;Y maximum
	lea	segments,a0
	move	#nbseg-1,-(sp)
1$	movem	(a0),d0/d1/d2/d3
	addq	#4,a0
	bsr.s	drawline
	subq	#1,(sp)
	bne.s	1$
	addq	#2,sp
	movem	(a0),d0/d1
	movem	segments,d2/d3
	bsr.s	drawline
;
; d6=Ymin
; d7=Ymax
;
	move	#$070,$ffff8240.w
	lea	calcules,a6
	move	d6,d0
	mulu	#160,d0
	move.l	ecran,a5
	add	d0,a5
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	add	d6,d6
	add	d6,a6		;ptr d‚but
	bsr	draw_all
	clr	$ffff8240.w
	rts
	section	text
;
; entr‚e :
;	d0=X0
;	d1=Y0
;	d2=X1
;	d3=Y1
;
; registres utilis‚s :
;	d4,d5
;	d6=ymin
;	d7=ymax
;	a6,a0
;	a5=y bas
;
noline:	rts
drawline:
	cmp	d1,d3		;du haut vers le bas
	beq.s	noline		;pas 2 Y pareils !!!!
	bhs.s	1$
	exg	d0,d2
	exg	d1,d3
1$
	cmp	d6,d1
	bhs.s	.notmin
	move	d1,d6		;nouveau Y minimum
.notmin
	cmp	d7,d3
	bls.s	.notmax
	move	d3,d7		;nouveau Y maximum
.notmax
	move	d3,a5

	sub	d1,d3
;
; on peut aussi utiliser le code suivant (gain de 4 cycles … la fin)
;
	ifeq	1
;
; on se base sur le fait que chaque Y passe une fois par ici...
;
	cmp	d6,d1
	bhs.s	.notmin
	move	d1,d6		;nouveau Y minimum
.notmin
	cmp	d7,d1
	bls.s	.notmax
	move	d1,d7		;nouveau Y maximum
.notmax
	sub	d1,d3		;du haut vers le bas
	bhs.s	1$
	exg	d0,d2
	neg	d3
	add	d3,d1
1$
	endc

;
; ici d1=Y haut
;     d3=nb pixels verticalement=pente en Y
;
; calcul des pointeurs pour ‚criture donn‚es
;
	add	d1,d1
	add	d1,d1		;Y*4
	lea	calcules,a6
	add	d1,a6

	move	d3,d4
	lsr	#1,d4		;d4=cumul
	move	d3,d1
	subq	#1,d1		;d1=nb lignes-1

	sub	d0,d2
;
; d0=X d‚part
; d2=delta X
; d3=delta Y
;
	bpl.s	pente_droite
pente_gauche
	neg	d2
	cmp	d2,d3
	bhs.s	.dysupdx
.dxsupdy
	ext.l	d2		;bit 15=0->cleare poids fort
	divu	d3,d2		;d2.h=reste
	move	d2,d5
	swap	d2		;nouveau deltax
.dx1
	PLOT
	sub	d2,d4
	bhs.s	.dx2
	add	d3,d4
	subq	#1,d0
.dx2
	sub	d5,d0
	dbra	d1,.dx1
	PLOT2
	rts
.dysupdx
.dy1
	PLOT
	sub	d2,d4
	bhs.s	.dy2
	add	d3,d4
	subq	#1,d0
.dy2
	dbra	d1,.dy1
	PLOT2
	rts
pente_droite
	cmp	d2,d3
	bhs.s	.dysupdx
.dxsupdy
	ext.l	d2		;clear poids fort
	divu	d3,d2
	move	d2,d5
	swap	d2
.dx1
	PLOT
	sub	d2,d4
	bhs.s	.dx2
	add	d3,d4
	addq	#1,d0
.dx2
	add	d5,d0
	dbra	d1,.dx1
	PLOT2
	rts
.dysupdx
.dy1
	PLOT
	sub	d2,d4
	bhs.s	.dy2
	add	d3,d4
	addq	#1,d0
.dy2
	dbra	d1,.dy1
	PLOT2
	rts
;
; affichage des lignes horizontales
;
; entr‚e :
;	d7=nb lignes-1 … afficher
;	a5=ptr ‚cran 1Šre ligne
;	a6=ptr coords 1Šre ligne
;
clipgau
	cmp	d4,d1
	bls.s	1$
	move	d1,d2
	eor	d0,d2
	bpl.s	noaff
	cmp	d4,d1
	sge	d1
	ext	d1
	and	d4,d1
1$	cmp	d4,d0
	sge	d0
	ext	d0
	and	d4,d0
	bra.s	noclip
clipdro
	sge	d1
	ext	d1
	and	d4,d1
	bra.s	noclip

noaff:	lea	160(a5),a5
	dbra	d7,draw_all2
	rts
draw_all:
	lea	masques(pc),a1
	moveq	#-1,d5
	move	#319,d4
draw_all2
	movem	(a6)+,d0/d1
	cmp	d4,d0
	bhi.s	clipgau
	cmp	d4,d1
	bhi.s	clipdro
noclip
	cmp	d0,d1
	bhs.s	1$		;d0=Xgauche
	exg	d0,d1		;d1=Xdroite
1$
	moveq	#$f,d2
	and	d1,d2
	eor	d2,d1
	lsr	#1,d1
	move.l	a5,a0
	add	d1,a0
	ADD	D2,D2
	move	masque1-masques(a1,d2.w),d6	;masque droit
	add	d1,d1
	sub	d0,d1
	ble.s	.less16

	or	d6,(a0)
	moveq	#$f,d2
	and	d1,d2
	eor	d2,d1
	asr	#1,d1
	sub	d1,a0
	asr	#1,d1
	neg	d1
	jmp	.last(pc,d1.w)
	opt	o-
x	set	19
	rept	19
	move	d5,x*8-8(a0)
x	set	x-1
	endr
	opt	o+
.last
	add	d2,d2
	move	masque2-2-masques(a1,d2.w),d6
	or	d6,-8(a0)
	lea	160(a5),a5
	dbra	d7,draw_all2
	rts
.less16
	ADD	D1,D1
	and	masque2-masques+32-2(a1,d1.w),d6
	or	d6,(a0)
	lea	160(a5),a5
	dbra	d7,draw_all2
	rts
masques
	dc.w	0
masque2
	DC.W	$0001,$0003,$0007,$000F
	DC.W	$001F,$003F,$007F,$00FF
	DC.W	$01FF,$03FF,$07FF,$0FFF
	DC.W	$1FFF,$3FFF,$7FFF,$FFFF
masque1
	DC.W	$8000,$C000,$E000,$F000
	DC.W	$F800,$FC00,$FE00,$FF00
	DC.W	$FF80,$FFC0,$FFE0,$FFF0
	DC.W	$FFF8,$FFFC,$FFFE,$FFFF

	ifeq	DEBUG
debugger:incbin	debugger.bin
	endc

	section	data
segments:
coord1:	dc.w	200,0		;triangle d‚mo

	dc.w	0
coord2:	dc.w	100

	ifeq	nbseg-3
	dc.w	319,199
	endc
	ifeq	nbseg-4
	dc.w	160,199
	dc.w	319,100
	endc

;	ds.b	4*nbseg		;entr‚e
	section	bss
calcules:
	ds.l	200		;sortie

	section	bss
	ifeq	plans-1
fastcls:ds.b	16000
	endc
