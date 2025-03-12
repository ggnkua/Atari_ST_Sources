	opt	o+
	OPT	D+,X+
COTES	EQU	5
TEST
	MOVE	SR,D0
	AND	#$2000,D0
	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
SUPER
	MOVE	#$2700,SR
	BSR.S	initpoly
GAME
;	BRA.S	NORAND
	LEA	CARRE(PC),A0
	MOVEQ	#COTES-1,D1
TIRE
	BSR.S	RANDOM
	DIVU	#320,D0
	SWAP	D0
	MOVE	D0,(A0)+
	BSR.S	RANDOM
	DIVU	#200,D0
	SWAP	D0
	MOVE	D0,(A0)+
	DBRA	D1,TIRE
NORAND
	BSR.S	RANDOM
	AND	#$F,D0
	SWAP	D0
	MOVE	#COTES,D0	;ET PAS MOVEQ
	LEA	CARRE(PC),A0
	LEA	$78000,A6
	BSR	polyfill
	SUBQ	#1,CPT
	BNE.S	GAME
	ILLEGAL
;
; GETKEY
;
	MOVE	#7,-(SP)
	TRAP	#1
	ADDQ	#2,SP
	BRA.S	GAME
CPT	DC.W	10000
CARRE
;	DC.W	$96,$69
;	DC.W	$0A,$9B
;	DC.W	$6D,$3F
	DS.L	COTES
RANDOM
	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE	#17,-(SP)
	TRAP	#14
	ADDQ	#2,SP
	SWAP	D0
	CLR	D0
	SWAP	D0
	MOVEM.L	(SP)+,D1-D7/A0-A6
	RTS
;
; LISTE DES AMELIORATIONS POSSIBLES :
;
; - QUAND LES 2 Y SONT HORS DE L'ECRAN, INUTILE DE CALCULER QUOI
;      QUE CE SOIT
; - AMELIORER PLOT SUIVANT LE CAS
; - TRAVAILLER SUR L'AFFICHAGE
;
; algorithme de remplissage de polygones convexes
;
; version 1.0
;  le 06/04/89 par M‚m‚ l'Optimiseur Fou
;   (incompr‚hensible n'est-ce pas ??)
;
; entr‚e :
;
; avant d'utiliser polyfill,
;   il faut faire bsr initpoly une fois au d‚but du programme !!!
;
; A0=pointe sur les coordonn‚es des segments
; D0.w=nb de points
; D0.h=couleur du polygone
;
; liste des  registres utilis‚s !!!
;
ylow	equ	0
yhigh	equ	199

coords		equr	a0
ptr1		equr	a1
ptr2		equr	a2
maxy		equr	a3
miny		equr	a4
bufcor		equr	a5

ecran		equr	a6
raster		equr	a4
masques		equr	a5
plan1		equr	a2

nbpoints	equr	d0	;sert pour comptage de segments
x0		equr	d1
y0		equr	d2	;nb points … afficher
x1		equr	d3
y1		equr	d4
residu		equr	d5	;r‚sidu pour algorithme de Bresenham
pasx		equr	d6	;pas en x quand pente<90
const		equr	d7

coef1		equr	d5
coef2		equr	d6
borne		equr	d7

scratch		equr	d5
plan2		equr	d6
bit4		equr	d0
;
; routine de stockage de la coordonn‚e x0,y0/2
;
plot	macro
	cmp	(ptr2)+,const
	beq.s	\@1		;si bit 15=1 -> pas de coord m‚moris‚e
	move	x0,coordy2-coordy1-2(ptr2)
	bra.s	\@2
\@1	move	x0,-2(ptr2)	;m‚morise le premier point
\@2
	endm

plot2	macro
	cmp	-(ptr2),const
	beq.s	\@1		;si bit 15=1 -> pas de coord m‚moris‚e
	move	x0,coordy2-coordy1(ptr2)
	bra.s	\@2
\@1	move	x0,(ptr2)	;m‚morise le premier point
\@2
	endm

initpoly
	moveq	#200/2-1,d0
	move.l	#$80008000,d1
	lea	coordy1(PC),a0	;efface coordy1 et coordy2
clrpoly	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,clrpoly
	rts
onepoint
	move	(coords)+,x0
	cmp	#320,x0
	bhs.s	nopoint
	move	(coords),y0
	cmp	#200,y0
	bhs.s	nopoint

	add	y0,y0
	add	y0,y0
	add	y0,ecran
	asl	#5,y0
	add	y0,ecran

	move	x0,scratch
	and	#$0F,x0
	eor	x0,scratch
	lsr	#1,scratch
	add	scratch,ecran

	ADD	x0,x0
	ADD	x0,x0
	lea	masks(PC),masques
	MOVE.L	mskpoint-masks(masques,x0.w),x0

;	eor	bit4,x0
;	moveq	#-1,scratch
;	bclr	x0,scratch
;	move	scratch,x0
;	swap	x0
;	move	scratch,x0

	and.l	x0,(ecran)
	and.l	x0,4(ecran)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(ecran)+
	and.l	plan2,x0
	or.l	x0,(ecran)+
nopoint
finpoly
nothing
	rts

polyfill
	tst	nbpoints
	beq.s	nothing		;si aucun point … afficher -> on sort

	subq	#1,nbpoints	;-1 pour dbra
	beq.s	onepoint	;si 0 -> un seul point … afficher

	move.l	coords,bufcor
	subq	#1,nbpoints
	beq.s	oneseg
;
; premiŠre phase : calcul des coordonn‚es
;
	move	#-1,maxy	;on fixe le Ymax et le Ymin
	move	#200,miny	; en dehors de l'‚cran
	move	#$8000,const
	lea	coordy1(pc),ptr1
boucle
	movem	(coords),x0/y0/x1/y1	;on lit les deux premiers points
	bsr	drawlin
oneseg
	addq	#4,coords		;saute le premier point
	dbra	nbpoints,boucle
;
; traitement du dernier segment
;
	move	(coords)+,x0
	move	(coords),y0
	move	(bufcor)+,x1
	move	(bufcor),y1
	bsr	drawlin
;
; deuxiŠme phase : affichage des lignes et effacement du buffer
;
	move	maxy,y0
	bmi.s	finpoly

	sub	miny,y0
	bmi.s	finpoly

	swap	nbpoints
	lsr	#1,nbpoints
	scs	x0
	ext	x0
	swap	x0
	lsr	#1,nbpoints
	scs	x0
	ext	x0
	move.l	x0,plan1
	lsr	#1,nbpoints
	scs	plan2
	ext	plan2
	swap	plan2
	lsr	#1,nbpoints
	scs	plan2
	ext	plan2

	move	miny,nbpoints
	add	nbpoints,nbpoints
	add	nbpoints,ptr1
	asl	#4,nbpoints		;(y*32)
	add	nbpoints,ecran
	add	nbpoints,nbpoints	;+(y*128)
	add	nbpoints,nbpoints
	add	nbpoints,ecran		;=y*160
	moveq	#$0F,bit4		;ici bit4=$000F (ruse)
	lea	masks(pc),masques
nxtlin
	move	(ptr1),x0
	move	const,(ptr1)+		;efface les flags
	move	coordy2-coordy1-2(ptr1),x1
	cmp	const,x1
	beq	hplot
	move	const,coordy2-coordy1-2(ptr1)
;
; HLINE
;
	moveq	#0,scratch
	cmp	#320,x0
	blo.s	x0320
	slt	x0
	ext	x0
	and	#319,x0
	moveq	#1,scratch
x0320
	cmp	#320,x1
	blo.s	x1320
	slt	x1
	ext	x1
	and	#319,x1
	tst	scratch
	beq.s	x1320
	cmp	x0,x1
	beq	nohline
x1320
	sub	x0,x1
	bge.s	paswap
	add	x1,x0
	neg	x1
paswap
;
; x1 devient … partir de maintenant deltax
;
	move	x0,scratch
	and	bit4,x0
	eor	x0,scratch
	lsr	#1,scratch
	lea	(ecran,scratch.w),raster
	add	x0,x1
	add	x0,x0
	add	x0,x0
	move.l	mskgau-masks(masques,x0.w),x0
	cmp	bit4,x1
	bls.s	onelong
	and.l	x0,(raster)
	and.l	x0,4(raster)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(raster)+
	and.l	plan2,x0
	or.l	x0,(raster)+
	move	x1,x0
	and	bit4,x1
	eor	x1,x0
	lsr	#2,x0
	neg	x0
	jmp	fastfill+20*4(pc,x0.w)
fastfill
	rept	19
	move.l	plan1,(raster)+
	move.l	plan2,(raster)+
	endr
	moveq	#0,x0
onelong	add	x1,x1
	add	x1,x1
	or.l	mskdro-masks(masques,x1.W),x0
	and.l	x0,(raster)
	and.l	x0,4(raster)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(raster)+
	and.l	plan2,x0
	or.l	x0,(raster)+
nohline
	lea	160(ecran),ecran
	dbra	y0,nxtlin
	rts
hplot
	cmp	#320,x0
	bhs.s	point0

	move	x0,scratch
	and	bit4,x0
	eor	x0,scratch
	lsr	#1,scratch
	lea	(ecran,scratch.w),raster

	ADD	x0,x0
	ADD	x0,x0
	MOVE.L	mskpoint-masks(masques,x0.w),x0

;	eor	bit4,x0
;	moveq	#-1,scratch
;	bclr	x0,scratch
;	move	scratch,x0
;	swap	x0
;	move	scratch,x0

	and.l	x0,(raster)
	and.l	x0,4(raster)
	not.l	x0
	move.l	plan1,scratch
	and.l	x0,scratch
	or.l	scratch,(raster)+
	and.l	plan2,x0
	or.l	x0,(raster)+

point0
	lea	160(ecran),ecran
	dbra	y0,nxtlin
	rts
;
; cas deltax n‚gatif et deltax>deltay
;
; donc deltax<>0
;
cas2
	ext.l	x1		;efface les bits 16 … 31 (bit 15=0)
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division
; ici x1<y1
	move	y1,residu
	lsr	#1,residu
cas20
	plot
	sub	x1,residu
	bhi.s	cas21
	add	y1,residu
	subq	#1,x0
cas21
	sub	pasx,x0
	dbra	y0,cas20
	rts
drawlin
	cmp	#200,y0
	bhs	clip1
	cmp	#200,y1
	bhs	clip2
noclip
	cmp	y0,y1		;si les 2 Y sont ‚gaux,
	beq.s	ploton		; on n'affiche que le point (x0,y0)

	cmp	maxy,y0
	ble.s	drawl1
	move	y0,maxy
drawl1	cmp	miny,y0
	bgt.s	drawl2
	move	y0,miny
drawl2
;
; … partir d'ici x1 et y1 repr‚sentent deltax et deltay
;  (grosse ruse !!!!)
;
	sub	y0,y1		;calcule valeur absolue de deltay
	blt	setdy		;ici y1 est diff‚rent de 0 !!!!

	add	y0,y0
	lea	0(ptr1,y0.w),ptr2

	move	y1,y0		;nb de points … calculer
	subq	#1,y0		;(on n'affiche pas le dernier point !!!)
	beq.s	plotone

	sub	x0,x1		;calcule valeur absolue de deltax
	bge.s	positif
;
; cas deltax n‚gatif
;
	neg	x1		;abs(deltax)
	cmp	y1,x1
	bhi.s	cas2
;
; cas deltax n‚gatif et deltay>=deltax
;
cas1
; ici x1<=y1
	move	y1,residu
	lsr	#1,residu
cas10
	plot
	sub	x1,residu
	bhi.s	cas11
	add	y1,residu
	subq	#1,x0
cas11
	dbra	y0,cas10
	rts
ploton	add	y0,y0
	lea	0(ptr1,y0.w),ptr2
plotone
	plot
	rts
plotone2
	plot2
	rts
positif
;
; cas deltax positif
;
	cmp	y1,x1
	bhi.s	cas4
;
; cas deltax positif et deltay>=deltax
;
cas3
	move	y1,residu
	lsr	#1,residu
; ici x1<=y1
cas30
	plot
	sub	x1,residu
	bhi.s	cas31
	add	y1,residu
	addq	#1,x0
cas31
	dbra	y0,cas30
	rts
;
; cas deltax positif et deltax>deltay
;
; donc deltax<>0
;
cas4
	ext.l	x1		;voir plus haut
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division

	move	y1,residu
	lsr	#1,residu
; ici x1<y1
cas40
	plot
	sub	x1,residu
	bhi.s	cas41
	add	y1,residu
	addq	#1,x0
cas41
	add	pasx,x0
	dbra	y0,cas40
	rts
;
; cas deltax n‚gatif et deltax>deltay
;
; donc deltax<>0
;
cas6
	ext.l	x1		;efface les bits 16 … 31 (bit 15=0)
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division

	move	y1,residu
	lsr	#1,residu
; ici x1<y1
cas60
	plot2
	sub	x1,residu
	bhi.s	cas61
	add	y1,residu
	subq	#1,x0
cas61
	sub	pasx,x0
	dbra	y0,cas60
	rts
;
;
setdy
	neg	y1		;inverse le signe de deltay
	add	y0,y0
	lea	2(ptr1,y0.w),ptr2

	move	y1,y0		;nb de points … calculer
	subq	#1,y0		;(on n'affiche pas le dernier point !!!)
	beq	plotone2

	sub	x0,x1		;calcule valeur absolue de deltax
	bge.s	negatif
;
; cas deltax n‚gatif
;
	neg	x1		;abs(deltax)
	cmp	y1,x1
	bhi.s	cas6
;
; cas deltax n‚gatif et deltay>=deltax
;
cas5
	move	y1,residu
	lsr	#1,residu
; ici x1<=y1
cas50
	plot2
	sub	x1,residu
	bhi.s	cas51
	add	y1,residu
	subq	#1,x0
cas51
	dbra	y0,cas50
	rts
negatif
;
; cas deltax positif
;
	cmp	y1,x1
	bhi.s	cas8
;
; cas deltax positif et deltay>=deltax
;
cas7
	move	y1,residu
	lsr	#1,residu
; ici x1<=y1
cas70
	plot2
	sub	x1,residu
	bhi.s	cas71
	add	y1,residu
	addq	#1,x0
cas71
	dbra	y0,cas70
	rts
;
; cas deltax positif et deltax>deltay
;
; donc deltax<>0
;
cas8
	ext.l	x1		;voir plus haut
	divu	y1,x1
	move	x1,pasx		;pasx=int(deltay/deltax)
	swap	x1		;x1=reste de la division

	move	y1,residu
	lsr	#1,residu
; ici x1<y1
cas80
	plot2
	sub	x1,residu
	bhi.s	cas81
	add	y1,residu
	addq	#1,x0
cas81
	add	pasx,x0
	dbra	y0,cas80
	rts

	SECTION	BSS
coordy1	ds.w	200	;ces 2 buffers doivent se suivre !!!
coordy2	ds.w	200

	SECTION	TEXT

mskpoint
	dc.l	$7FFF7FFF,$BFFFBFFF,$DFFFDFFF,$EFFFEFFF
	dc.l	$F7FFF7FF,$FBFFFBFF,$FDFFFDFF,$FEFFFEFF
	dc.l	$FF7FFF7F,$FFBFFFBF,$FFDFFFDF,$FFEFFFEF
	dc.l	$FFF7FFF7,$FFFBFFFB,$FFFDFFFD,$FFFEFFFE
masks
mskgau	dc.l	$00000000,$80008000,$C000C000,$E000E000
	dc.l	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	dc.l	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	dc.l	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
mskdro	dc.l	$7FFF7FFF,$3FFF3FFF,$1FFF1FFF,$0FFF0FFF
	dc.l	$07FF07FF,$03FF03FF,$01FF01FF,$00FF00FF
	dc.l	$007F007F,$003F003F,$001F001F,$000F000F
	dc.l	$00070007,$00030003,$00010001,$00000000

nodraw	
	move	#$8000,const
nodraw2
	rts
clip1
	cmp	y0,y1
	beq.S	nodraw2
	moveq	#ylow,borne
	cmp	borne,y0
	bge.s	clip3
	cmp	borne,y1
	blt.s	nodraw
	neg	y0
	move	borne,coef2
	add	y0,coef2
	add	y1,y0
	move	x1,coef1
	sub	x0,coef1
	muls	coef1,coef2
	divs	y0,coef2
	add	coef2,x0
	move	borne,y0
	bra.s	clip2
clip3	cmp	borne,y1
	bge.s	clip2
	neg	y1
	move	borne,coef2
	add	y1,coef2
	add	y0,y1
	move	x0,coef1
	sub	x1,coef1
	muls	coef1,coef2
	divs	y1,coef2
	add	coef2,x1
	move	borne,y1
clip2	move	#yhigh,borne
	cmp	borne,y0
	ble.s	clip4
	cmp	borne,y1
	bgt.s	nodraw
	neg	y0
	move	borne,coef2
	add	y0,coef2
	add	y1,y0
	move	x1,coef1
	sub	x0,coef1
	muls	coef1,coef2
	divs	y0,coef2
	add	coef2,x0
	move	borne,y0
	bra.s	clip5
clip4	cmp	borne,y1
	ble.s	clip5
	neg	y1
	move	borne,coef2
	add	y1,coef2
	add	y0,y1
	move	x0,coef1
	sub	x1,coef1
	muls	coef1,coef2
	divs	y1,coef2
	add	coef2,x1
	move	borne,y1
clip5	move	#$8000,const
	bra	noclip
