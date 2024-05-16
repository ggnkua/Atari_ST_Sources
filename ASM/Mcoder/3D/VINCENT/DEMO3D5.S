; The maxi optimyzed 3D Z-rout
; (C) 1989-90 Vincent PENNE (Ziggy Stardust).

NECR	equ	8

; Variable pour les calculs 3D
TSINUS	equ	1024
DISTEC	equ	32

; Organisation de la palette (Pour l'instant 1 plan par couleur)
COLFOND	equ	$000
TAILPAL	equ	16 ; (Jusqu'a 512!!)
MINCOL	equ	0
MAXCOL	equ	3

; Parametre pour le tracage des lignes horizontales
NBLIG	equ	200
LECRAN	equ	320
DEPASSE	equ	1024
MINX	equ	0
MAXX	equ	320

; Au boulots, Genst!!
	opt	o+,o2+
	opt	c-
	opt	m+

debut:
	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#4,a7

	bsr	init
	
	jmp	main
	
initobj:
	move.l	#tobj,cobj
	move.w	#0,nobj
	rts
	
addobj:
	move.l	a1,-(a7)
	move.l	cobj,a1
	move.l	-16(a6),(a1)+
	move.w	-12(a6),(a1)+
	move.w	-10(a6),(a1)+
	move.w	-8(a6),(a1)+
	move.w	-6(a6),(a1)+
	move.w	-4(a6),(a1)+
	move.w	-2(a6),(a1)+
	move.l	a1,cobj
	addq.w	#1,nobj
	move.l	(a7)+,a1
	rts
	
affobj:
	movem.l	d0-d7/a0-a6,-(a7)
	
	lea	tobj,a0
	lea	trieobj,a1
	lea	dobj,a2
	move.w	nobj,d0
	
	move.w	d0,d1
	subq.w	#1,d1
loopfilld:
	move.w	d1,(a1)+
	move.w	d1,d2
	lsl.w	#4,d2
	move.w	4(a0,d2.w),d3	; Calcul de la distance de l'objet
	sub.w	ox,d3
	muls	d3,d3
	move.w	6(a0,d2.w),d4
	sub.w	oy,d4
	muls	d4,d4
	add.l	d4,d3
	move.w	8(a0,d2.w),d4
	sub.w	oz,d4
	muls	d4,d4
	add.l	d4,d3
	move.l	d3,(a2)+	; On la m‚morise pour le triage
	dbra	d1,loopfilld
	
	lea	trieobj,a1
	lea	dobj,a2
	move.w	d0,d1
	subq.w	#2,d1		; Triage des objets --->
	tst.w	d1
	blt.s	notrieobj
triobj1:
	move.w	d1,d2
	move.l	(a2)+,d3	; On r‚cupere la distance 1
	lea	2(a1),a3
	move.l	a2,a4
triobj2:
	cmp.l	(a4)+,d3	; On compare les distances 1 et 2
	bge.s	noswapobj
	move.l	-4(a4),-4(a2)
	move.l	d3,-4(a4)
	move.l	-4(a2),d3
	move.w	(a1),d4
	move.w	(a3),(a1)
	move.w	d4,(a3)

noswapobj:
	addq.l	#2,a3
	dbra	d2,triobj2

	addq.l	#2,a1
	dbra	d1,triobj1
	
notrieobj:
	lea	trieobj,a1
	move.w	d0,d1
	subq.w	#1,d1
loopaffobj:
	move.w	(a1)+,d2
	lsl.w	#4,d2
	lea	16(a0,d2.w),a6
	bsr.s	afforme

	dbra	d1,loopaffobj
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
cab	ds.w	1
cbb	ds.w	1
cgb	ds.w	1
sab	ds.w	1
n2:
sbb	ds.w	1
sgb	ds.w	1

obx	ds.w	1
oby	ds.w	1
obz	ds.w	1

m1	ds.w	1
m2	ds.w	1
m3	ds.w	1
n1	ds.w	1
n3	ds.w	1
o1	ds.w	1
o2	ds.w	1
o3	ds.w	1

limx1	ds.w	1
limx2	ds.w	1
limy1	ds.w	1
limy2	ds.w	1

zoom	dc.w	192	* Valeur du zoom

afforme:
	tst.b	tcol
	beq.s	.nc2
	move.w	#$500,$ffff8240.w
.nc2:
	
	movem.l	d0-d7/a0-a6,-(a7)
	
	move.w	-12(a6),obx
	move.w	-10(a6),oby
	move.w	-8(a6),obz
	move.w	ox,d0
	sub.w	d0,obx
	move.w	oy,d0
	sub.w	d0,oby
	move.w	oz,d0
	sub.w	d0,obz

	lea	table,a1		; Table des sinus...
	lea	table+TSINUS*2,a2	; et des cosinus
	
	move.w	-6(a6),d0
	add.w	d0,d0
	move.w	(a1,d0.w),sab
	move.w	(a2,d0.w),cab

	move.w	-4(a6),d0
	add.w	d0,d0
	move.w	(a1,d0.w),sbb
	move.w	(a2,d0.w),cbb

	move.w	-2(a6),d0
	add.w	d0,d0
	move.w	(a1,d0.w),sgb
	move.w	(a2,d0.w),cgb
	
			; Preparation matrice
	move.w	sab(pc),d0
	muls	cgb(pc),d0
	move.w	cab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	sgb(pc),d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move.w	d0,m1
	
	move.w	cab(pc),d0
	muls	cbb(pc),d0
	add.l	d0,d0
	swap	d0
	move.w	d0,m2
	
	move.w	sab(pc),d0
	muls	sgb(pc),d0
	move.w	cab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	cgb(pc),d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move.w	d0,m3
	
	move.w	cbb(pc),d0
	muls	sgb(pc),d0
	add.l	d0,d0
	swap	d0
	neg.w	d0
	move.w	d0,n1
	
	move.w	cbb(pc),d0
	muls	cgb(pc),d0
	add.l	d0,d0
	swap	d0
	move.w	d0,n3
	
	move.w	cab(pc),d0
	muls	cgb(pc),d0
	move.w	sab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	sgb(pc),d1
	sub.l	d1,d0
	add.l	d0,d0
	swap	d0
	move.w	d0,o1
	
	move.w	sab(pc),d0
	muls	cbb(pc),d0
	add.l	d0,d0
	swap	d0
	neg.w	d0
	move.w	d0,o2
	
	move.w	cab(pc),d0
	muls	sgb(pc),d0
	move.w	sab(pc),d1
	muls	sbb(pc),d1
	add.l	d1,d1
	swap	d1
	muls	cgb(pc),d1
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move.w	d0,o3
	
	lea	plot,a0
	move.l	-16(a6),a1
	move.w	(a1)+,d0		; Nombre de points
	subq.w	#1,d0
	lea	tdplot,a2
	lea	tplot,a3
	
	move.w	max(pc),limx1
	move.w	mix(pc),limx2
	move.w	may(pc),limy1
	move.w	miy(pc),limy2
	
	tst.b	tcol
	beq.s	.nc
	move.w	#$50,$ffff8240.w	
.nc:
	
calcplot:
	movem.w	(a1)+,d2-d4
	
			; Rotation autour du centre de l'objet
	; Rotation X
	move.w	d2,d6
	muls	m1(pc),d6
	move.w	d3,d5
	muls	m2(pc),d5
	add.l	d5,d6
	move.w	d4,d5
	muls	m3(pc),d5
	add.l	d5,d6
	add.l	d6,d6
	swap	d6
	
	; Rotation Y
	move.w	d3,d7
	muls	n2(pc),d7
	move.w	d2,d5
	muls	n1(pc),d5
	add.l	d5,d7
	move.w	d4,d5
	muls	n3(pc),d5
	add.l	d5,d7
	add.l	d7,d7
	swap	d7

	; Rotation Z
	muls	o3(pc),d4
	move.w	d2,d5
	muls	o1(pc),d5
	add.l	d5,d4
	move.w	d3,d5
	muls	o2(pc),d5
	add.l	d5,d4
	add.l	d4,d4
	swap	d4
	
	move.w	d6,d2
	move.w	d7,d3
		
				; On ramene aux coordon‚e de l'obs	
	add.w	obx(pc),d2
	add.w	oby(pc),d3
	add.w	obz(pc),d4
	neg.w	d3
	
	move.w	d4,(a2)+	; M‚morisation distance et points
	move.w	d2,(a3)+
	move.w	d3,(a3)+
	move.w	d4,(a3)+
	
	cmpi.w	#distec,d4	; Z inf‚rieur … distec?
	bgt.s	ok3d		; Oui
	
	addq.l	#4,a0
	bra.s	c3d
	
ok3d:				; 3D vers 2D --->	
	; Avec ZOOM = 192
	; (X * ZOOM) / Z + CX
	
	ext.l	d2
	asl.l	#6,d2
	move.l	d2,d7
	add.l	d2,d7
	add.l	d7,d2
	divs	d4,d2
	add.w	cx,d2
	move.w	d2,(a0)+
	
	cmp.w	limx1(pc),d2
	bge.s	.1
	move.w	d2,limx1
.1:
	cmp.w	limx2(pc),d2
	ble.s	.2
	move.w	d2,limx2
.2:
	
	; (Y * ZOOM) / Z + CY
	
	ext.l	d3
	asl.l	#6,d3
	move.l	d3,d7
	add.l	d3,d7
	add.l	d7,d3
	divs	d4,d3
	add.w	cy,d3
	move.w	d3,(a0)+
	
	cmp.w	limy1(pc),d3
	bge.s	.3
	move.w	d3,limy1
.3:
	cmp.w	limy2(pc),d3
	ble.s	.4
	move.w	d3,limy2
.4:
	
c3d:
	tst.b	tcol
	beq.s	.nt
	not.w	$ffff8240.w
.nt
	dbra	d0,calcplot
	
	move.l	curlim,a0
	
	move.w	limx1,d0
	cmp.w	mix(pc),d0
	bge.s	.1
	move.w	mix(pc),d0
.1:
	move.w	d0,(a0)+
	
	move.w	limx2,d0
	cmp.w	max(pc),d0
	ble.s	.2
	move.w	max(pc),d0
.2:
	move.w	d0,(a0)+
	
	move.w	limy1,d0
	cmp.w	miy(pc),d0
	bge.s	.3
	move.w	miy(pc),d0
.3:
	move.w	d0,(a0)+
	
	move.w	limy2,d0
	cmp.w	may(pc),d0
	ble.s	.4
	move.w	may(pc),d0
.4:
	move.w	d0,(a0)+
	
	tst.b	tcol
	beq.s	.nt2
	move.w	#$550,$ffff8240.w
.nt2:
	
	; On construit la table des faces initial
	; A enleve (plus besoin)
	lea	tdplot,a3
	lea	tdist,a4
	lea	tplot,a5
	lea	tface,a0
	move.l	a1,a2
	move.w	(a2)+,d0
	move.w	d0,d1
	subq.w	#1,d1
	moveq.w	#0,d0
loopmemface:
	move.l	a2,(a0)+
	move.w	(a2)+,d7
	add.w	d7,d7
	addq.w	#4,d7
	adda.w	d7,a2
	addq.w	#1,d0		; Contage nombre de face valable
	
	dbra	d1,loopmemface

	lea	plot,a0
	lea	tface,a3
	tst.w	d0
	subq.w	#1,d0
	blt	noforme
	
	moveq	#MINCOL-1,d6
	lea	dispal,a6
	rept	TAILPAL
	move.b	#-1,(a6)+
	endr
	move.l	affpal,a6
	move.w	#COLFOND,(a6)+	; Couleur 0 = couleur de fond
	
loopface:
	move.l	(a3)+,a1
	move.w	(a1)+,d1	; Nombre de points dans face N
	subq.w	#1,d1
	
	move.w	(a1)+,colorpoly	; Couleur de la face N
	
	move.w	(a1)+,d2	; Attribut de la face (ligne/rempli,etc...)
	lea	tplot,a4
	lea	2(a1),a5
	moveq.w	#0,d7
	lea	pxy,a2
	
loopplot:
	move.w	(a1)+,d2	; --> No points
	move.w	d2,d3
	add.w	d2,d3
	add.w	d2,d3
	lsl.w	#1,d3		; Nbr point * 6 dans D3
	
	cmpi.w	#distec,4(a4,d3.w)	; Point derriere ecran?
	bgt	okscreen	; Non
			; Oui --> calcul intersection avec ‚cran
	
	move.w	-4(a1),d4
	cmpa.l	a5,a1		; Premier point?
	bne.s	nofirstp	; Non
	move.w	d1,d4
	lsl.w	#1,d4
	move.w	-2(a1,d4.w),d4
nofirstp:
	move.w	d4,d2
	add.w	d4,d2
	add.w	d4,d2
	lsl.w	#1,d2		; * 6
	cmpi.w	#distec,4(a4,d2.w)
	ble.s	badp1
	
		; cx + zoom * (x + ((xx - x) * (DISTEC - z)) / (zz - z)) / 10
	move.w	(a4,d3.w),d4
	sub.w	(a4,d2.w),d4
	move.w	#distec,d5
	sub.w	4(a4,d2.w),d5
	muls	d5,d4
	move.w	4(a4,d3.w),d5
	sub.w	4(a4,d2.w),d5
	divs	d5,d4
	add.w	(a4,d2.w),d4
	muls	zoom,d4
	divs	#distec,d4
	add.w	cx,d4
	move.w	d4,(a2)+
		; cy + zoom * (y + ((yy - y) * (DISTEC - z) / (zz - z)) / 10
	move.w	2(a4,d3.w),d4
	sub.w	2(a4,d2.w),d4
	move.w	#distec,d5
	sub.w	4(a4,d2.w),d5
	muls	d5,d4
	move.w	4(a4,d3.w),d5
	sub.w	4(a4,d2.w),d5
	divs	d5,d4
	add.w	2(a4,d2.w),d4
	muls	zoom,d4
	divs	#distec,d4
	add.w	cy,d4
	move.w	d4,(a2)+
	
	addq.w	#1,d7
	
badp1:
	move.w	(a1),d5
	tst.w	d1		; Dernier point?
	bgt.s	nolastp		; Non
	move.w	-2(a5),d5
nolastp:
	move.w	d5,d2
	add.w	d5,d2
	add.w	d5,d2
	lsl.w	#1,d2		; * 6
	cmpi.w	#distec,4(a4,d2.w)
	ble.s	badp2
	
		; cx + zoom * (x + ((xx - x) * (DISTEC - z)) / (zz - z)) / 10
	move.w	(a4,d3.w),d4
	sub.w	(a4,d2.w),d4
	move.w	#distec,d5
	sub.w	4(a4,d2.w),d5
	muls	d5,d4
	move.w	4(a4,d3.w),d5
	sub.w	4(a4,d2.w),d5
	divs	d5,d4
	add.w	(a4,d2.w),d4
	muls	zoom,d4
	divs	#distec,d4
	add.w	cx,d4
	move.w	d4,(a2)+
		; cy + zoom * (y + ((yy - y) * (DISTEC - z) / (zz - z)) / 10
	move.w	2(a4,d3.w),d4
	sub.w	2(a4,d2.w),d4
	move.w	#distec,d5
	sub.w	4(a4,d2.w),d5
	muls	d5,d4
	move.w	4(a4,d3.w),d5
	sub.w	4(a4,d2.w),d5
	divs	d5,d4
	add.w	2(a4,d2.w),d4
	muls	zoom,d4
	divs	#distec,d4
	add.w	cy,d4
	move.w	d4,(a2)+
	
	addq.w	#1,d7
	
badp2:
	bra.s	cscreen
	
okscreen:
	lsl.w	#2,d2
	move.l	(a0,d2.w),d2
	move.w	d2,d3
	swap	d2
	
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	addq.w	#1,d7

cscreen:
	dbra	d1,loopplot
	move.l	pxy,(a2)+
	move.w	d2,pxy-4
	move.w	d3,pxy-2

	lea	pxy,a2
	move.w	-4(a2),d3
	move.w	4(a2),d1
	
	sub.w	(a2),d3
	sub.w	(a2),d1
	
	move.w	6(a2),d2
	sub.w	2(a2),d2
	muls	d2,d3
	
	move.w	-2(a2),d2
	sub.w	2(a2),d2
	muls	d2,d1
	
	cmp.l	d3,d1		; Face visible?
	ble.s	nopoly2		; Oui.
	
	move.w	d7,-(a7)

	move.w	colorpoly(pc),d7	
	lea	dispal(pc),a2
	tst.b	(a2,d7.w)
	bge.s	.okcol
	
	cmpi.w	#MAXCOL,d6
	blt.s	.nomaxcol
	
	move.b	#MAXCOL,(a2,d7.w)
	bra.s	.okcol
	
.nomaxcol:
	addq.w	#1,d6
	move.b	d6,(a2,d7.w)
	move.w	d6,d2
	
	cmpi.w	#4-1,d2
	bne.s	.col1
	move.w	#8-1,d2
.col1:
	
	cmpi.w	#3-1,d2
	bne.s	.col2
	move.w	#4-1,d2
.col2:

	move.l	curpal,a2
	move.w	d7,d3
	add.w	d3,d3
	adda.w	d3,a2
.copal:
	move.w	(a2),(a6)+
	dbra	d2,.copal
	
	lea	dispal(pc),a2
.okcol:
	move.b	(a2,d7.w),d2
	ext.w	d2
	move.w	d2,colorpoly
	
	move.w	(a7)+,d7
	cmpi.w	#3,d7
	blt.s	nopoly2
	
	movem.l	d0/d6/a0/a3/a6,-(a7)
	lea	pxy,a6
	bsr.s	affpoly
	movem.l	(a7)+,d0/d6/a0/a3/a6

nopoly2:
	dbra	d0,loopface

noforme:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

		* Fenetre de clipping --->
mix	dc.w	MINX
miy	dc.w	8
max	dc.w	MAXX-1
may	dc.w	199-8

		* Centre de l'‚cran   --->
cx	dc.w	160
cy	dc.w	99

curcol	dc.w	0
curpal	dc.l	palette
palette	dc.w	0,$333,$444,$555,$666,$330,$550,$770,$700,$500,$007,$005
dispal	ds.b	TAILPAL
affpal	dc.l	palette
	
affpoly:
	tst.b	tcol
	beq.s	.nt
	move.w	#$005,$ffff8240.w
.nt:
	move.w	d7,d0
	move.l	a6,a0
	move.w	#32000,d1
	subq.w	#1,d0
searchight:
	addq.l	#2,a0
	move.w	(a0)+,d2
	cmp.w	d1,d2
	bgt.s	toolow
	move.w	d0,d6
	move.w	d2,d1
toolow:
	dbra	d0,searchight
	
	neg.w	d6
	add.w	d7,d6		* Dans D6, No du point le plus haut.
	subq.w	#1,d6
	
	lsl.w	#2,d6
	lea	(a6,d6.w),a0	* Dans A0, adresse du point le plus haut.
	move.w	2(a0),miny	* Dans miny, point le plus haut
	
	move.w	d7,d0
	lsl.w	#2,d0
	lea	(a6,d0.w),a5	* Dans A5, Adresse du dernier point.
	
	lea	tpxy1,a1		* tbxy1, table des points gauches.
	lea	tpxy2,a2		* tbxy1, table des points droits.
*	bra	rightplot.s
*leftplot:
*	lea	tpxy2,a1		* tbxy1, table des points droits.
*	lea	tpxy1,a2		* tbxy1, table des points gauches.
rightplot:

	move.w	#-32767,d1
	move.l	a0,a4
	move.w	d7,d6
copleft:
	move.w	(a4)+,(a2)+
	move.w	(a4)+,d0		* Valeur y du point.
	cmp.w	d1,d0
	blt.s	fcopleft
	move.w	d0,d1
	move.w	d0,(a2)+
	
	subq.w	#1,d6
	blt	nopoly
	cmp.l	a5,a4
	blt.s	copleft
	
	move.l	a6,a4
	
	bra.s	copleft
fcopleft:
	move.w	#32000,-2(a2)
	move.w	#32000,(a2)
	
	move.w	#-32767,d1
	lea	4(a0),a4
copright:
	move.w	-(a4),d0	* Valeur y du point.
	move.w	-(a4),(a1)+
	cmp.w	d1,d0
	blt.s	fcopright
	move.w	d0,d1
	move.w	d0,(a1)+
	
	cmp.l	a6,a4
	bgt.s	copright

	move.l	a5,a4
	
	bra.s	copright
	
fcopright:
	move.w	#32000,-2(a1)
	move.w	#32000,(a1)
	move.w	-4(a1),maxy
	
	lea	tpxy1,a0
	lea	tpxy2,a1
	
	move.w	miny,d0		* miny-->D0
	move.w	miy,d2		* miy-->D2
	cmp.w	d2,d0		* Miny plus petit que miy?
	bge.s	cnegaplot		* Non
	move.w	d2,d0
	move.w	d2,miny
	
cnegaplot:
	cmp.w	maxy,d0
	bge	nopoly

	move.w	d0,d7
	lsl.w	#1,d7
	lea	tlx1,a2
	lea	(a2,d7.w),a2	* A2 = adresse du premier point gauche
	lea	tlx2,a3
	lea	(a3,d7.w),a3	* A3 = adresse du premier point droit
	move.l	a2,a4
	move.l	a3,a5
	move.w	may,d7
	cmp.w	miny,d7
	blt.s	nopoly
	
	bsr.s	new_plot

	move.l	a1,a0
	move.l	a3,a2
	move.w	miny,d0
	
	bsr.s	new_plot
	
	move.w	d0,d7
	sub.w	miny,d7
	move.w	colorpoly,d2
	move.l	ec1(pc),a6
	add.w	d2,d2
	adda.w	d2,a6
	move.w	miny,d0
	
	asl.w	#5,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0		; --> D0 * 160
	
	lea	(a6,d0.w),a6
	lsl.w	#2,d2
	lea	hline(pc),a3
	lea	ldecal+DEPASSE*4,a1
	lea	rdecal,a2
	move.w	#$f,d2
	tst.b	tcol
	beq.s	.nc
	move.w	#$050,$ffff8240.w
.nc
	jsr	(a3)

nopoly:
	tst.b	tcol
	beq.s	.nc2
	move.w	#$500,$ffff8240.w
.nc2
	rts
	
new_plot:
	movem.w	(a0),d1-d4	; X1 Y1 X2 Y2
	add.w	d1,d1
	add.w	d1,d1
	add.w	d3,d3
	add.w	d3,d3
	addq	#4,a0
	cmp.w	d0,d4		; Y2 superieur a D0?
	blt.s	new_plot
	cmp.w	d4,d2		; Pour eviter la division par 0...
	bge.s	new_plot
	move.w	d4,d6
	cmp.w	d7,d6		; Point plus bas que may?
	blt.s	oklow		; Non
	move.w	d7,d6
	addq.w	#1,d6
oklow:
	cmpi.w	#32000,d4		; Dernier point?
	beq	fin_plot		; On sort
	cmp.w	d7,d0		; Depasser may?
	bgt	fin_plot		; On sort.
	
	sub.w	d1,d3
	sub.w	d2,d4

	move.w	d0,d5		; On cherche X de d‚part par rapport … D0
	sub.w	d2,d5
	cmp.w	miy(pc),d2
	bge.s	noclip
	muls	d3,d5
	divs	d4,d5
noclip:
	add.w	d5,d1

	ext.l	d3
	lsl.l	#6,d3
	divs	d4,d3
	ext.l	d3
	asl.l	#8,d3
	asl.l	#2,d3
	
	sub.w	d6,d0
	bge	noline
	addi.w	#NBLIG,d0
	add.w	d0,d0	; * 4
	swap	d1
	move.w	d3,d1
	beq	fast_plot
	addi.w	#$8000,d1
	swap	d1
	swap	d3
	add.w	d0,d0
	jmp	calc_plot(pc,d0.w)
	
calc_plot:
	rept	NBLIG
	move.w	d1,(a2)+
	addx.l	d3,d1
	endr
	
noline:
	move.w	d6,d0
	
	bra	new_plot
	
fin_plot:
	rts
	
fast_plot:
	swap	d1
	swap	d3
	
	beq	fast_plot2
	
	add.w	d0,d0
	jmp	calc_fplot(pc,d0.w)
	
calc_fplot:
	rept	NBLIG
	move.w	d1,(a2)+
	add.w	d3,d1
	endr
	
	move.w	d6,d0
	
	bra	new_plot
	
fast_plot2:

	jmp	calc_fplot2(pc,d0.w)
	
calc_fplot2:
	rept	NBLIG
	move.w	d1,(a2)+
	endr
	
	move.w	d6,d0
	
	bra	new_plot
	
init3d:
	lea	phline,a1		; Pregenere les lignes horizontales
	move.w	#NBLIG-1,d0
lphline:
	lea	hline2,a0
	move.w	#(hline1-hline2)/2-1,d1
lphline2:
	move.w	(a0)+,(a1)+

	dbra	d1,lphline2

	dbra	d0,lphline
	
	move.w	#$4e75,(a1)+

	lea	ldecal+DEPASSE*4,a0	; Precalcul le bord des lignes H
	lea	rdecal,a2
	move.w	#0,d2
	move.w	#0,d3
	move.w	#LECRAN/16-1,d0
decal1:
	lea	bord,a1
	move.w	#15,d1
decal2:
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	move.w	d2,(a0)+
	
	not.w	d7
	move.w	d7,(a2)+
	move.w	d3,(a2)+
	
	dbra	d1,decal2
	addq.w	#4,d2
	addq.w	#4,d3

	dbra	d0,decal1
	
	lea	ldecal,a0		; Precalcul pour le cliping en X
	move.w	#DEPASSE+MINX-1,d0
.ld:
	move.l	#$7fff0000+MINX/4,(a0)+
	dbra	d0,.ld

	lea	rdecal+MAXX*4,a0
	move.w	#DEPASSE+(LECRAN-MAXX)-1,d0
.rd:
	move.l	#$ffff0000+MAXX/4-4,(a0)+
	dbra	d0,.rd
	
	move.l	#trap15,$bc.w		; Passage en superviseur
	rts
	
trap15:	; Trap pour passer en superviseur rapidement (Merci M-coder!)
	rtr
	
init:
	bsr	init3d

	dc.w	$a00a
	
	move.l	$44e.w,oldec
	
	move.l	#ecran+256,d0
	andi.l	#$ffff00,d0
	lea	ec,a0
	rept	NECR
	move.l	d0,NECR*4(a0)
	move.l	d0,(a0)+
	addi.l	#32000,d0
	endr
	move.l	ec,ec1
	
	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	move.w	d0,oldrez
	move.w	#-1,-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7

	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	clr.b	$ffff8260.w
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	
	movem.l	$8.w,d0-d7
	movem.l	d0-d7,oldbomb
	
	lea	$8.w,a0		; Redirection des bombes
	move.l	#fin,d0
	rept	8
	move.l	d0,(a0)+
	endr
	
	rts

uninit:	
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	move.b	oldrez+1,$ffff8260.w
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#-1,-(a7)
	move.l	oldec,-(a7)
	move.l	oldec,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	
	dc.w	$a009
	
	rts

bord:
	dc.w	%111111111111111,%11111111111111,%1111111111111,%111111111111,%11111111111,%1111111111,%111111111,%11111111,%1111111,%111111,%11111,%1111,%111,%11,%1,0
	
curec	dc.l	ec+3*4
affec	dc.l	ec
cvbl	dc.w	0
cvbl1	dc.w	0
cvbl2	dc.w	0
cvbl3	dc.w	0

curlim	ds.l	1
ec1	ds.l	1

ec:
	ds.l	NECR*2

tlim:
N	set	0
	rept	NECR
	dc.l	lim+N
N	set	N+8
	endr
N	set	0
	rept	NECR
	dc.l	lim+N
N	set	N+8
	endr
	
tpal:
N	set	0
	rept	NECR
	dc.l	pal+N
N	set	N+32
	endr
N	set	0
	rept	NECR
	dc.l	pal+N
N	set	N+32
	endr
	
lim:
	rept	NECR*2
	dc.w	10,30,20,30
	endr
	
	section	bss
	
pal:	ds.w	16*NECR
	
	section	text

hline2:	
	moveq	#-4,d0
	and.w	(a4)+,d0
	moveq	#-4,d1
	and.w	(a5)+,d1
	
	move.l	(a1,d0.w),d0
	move.l	(a2,d1.w),d1
	
	sub.w	d1,d0
	bge.s	little_line
	
	move.l	a6,a0
	add.w	d1,d1
	adda.w	d1,a0
	swap	d1
	or.w	d1,(a0)
	
	jmp	loopline+4(pc,d0.w)
	
little_line:
	bgt.s	nohline
	
	move.l	a6,a0
	add.w	d1,d1
;	adda.w	d1,a0
	
;	swap	d0
;	swap	d1
;	and.w	d0,d1
;	or.w	d1,(a0)
	and.l	d1,d0
	swap	d0
	or	d0,(a0,d1.w)
	bra.s	nohline
	
N	set	-LECRAN/2
	rept	LECRAN/16
	move.w	d5,N(a0)
N	set	N+8
	endr
loopline:
	add.w	d0,d0
	adda.w	d0,a0
	swap	d0
	or.w	d0,(a0)
nohline:
	lea	160(a6),a6
	
hline1:

	section	bss

oldbomb	ds.l	8
oldrez	ds.w	1
oldec	ds.l	1
ecran	ds.b	32000*NECR+256

phline:
	ds.b	(hline1-hline2)*NBLIG
phline2:
	ds.w	1

	section	text
	
			* Tracage de ligne horizontal.
hline:
	moveq	#$ffffffff,d5
	moveq	#0,d4

	add	d7,d7
	add	d7,d7
	add	d7,d7
	jmp	jmps(pc,d7.w)
jmps
N	set	0
	rept	201
	jmp	phline2-N
	nop
N	set	N+hline1-hline2
	endr
	dcb.w	10,$4e75
	
; Routine d'effacement
; D0: Min X
; D1: Max X
; D2: Min Y
; D3: Max Y
; A0: Adresse ecran
; retcls: Adresse retour du CLS
oa7	dc.l	0

cls:
	move.w	#$0300,sr
	move.l	a7,oa7
	move.l	a0,a7
	
	andi.w	#$fff0,d0
	addi	#16,d1
	andi.w	#$fff0,d1	; Multiple de 16 pixel
	move.w	d1,d5
	lsr.w	#1,d5
	
	sub.w	d0,d1	; Largeur
	lsr.w	#2,d1
	
	sub.w	d2,d3
	ble	cls0
	
	asl.w	#5,d2	; * 32
	move.w	d2,d4
	add.w	d2,d2
	add.w	d2,d2	; * 128
	add.w	d4,d2	; --> * 160
	
	add.w	d2,d5
	adda.w	d5,a7
	move.w	d3,d0
	
	addq	#2,d1
	ble	cls0
	move.w	d1,.ajmp+2
	
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	
.ajmp:
	bra.w	tcls
	
tcls:
	bra.w	cls0
	bra.w	cls1
	bra.w	cls2
	bra.w	cls3
	bra.w	cls4
	bra.w	cls5
	bra.w	cls6
	bra.w	cls7
	bra.w	cls8
	bra.w	cls9
	bra.w	cls10
	bra.w	cls11
	bra.w	cls12
	bra.w	cls13
	bra.w	cls14
	bra.w	cls15
	bra.w	cls16
	bra.w	cls17
	bra.w	cls18
	bra.w	cls19
	bra.w	cls20
	rept	20
	illegal
	endr
	
cls1:
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+8(a7),a7
	dbra	d0,cls1
	bra	fcls
	
cls2:
	movem.l	d1-d4,-(a7)
	lea	160+16(a7),a7
	dbra	d0,cls2
	bra	fcls
	
cls3:
	movem.l	d1-d6,-(a7)
	lea	160+24(a7),a7
	dbra	d0,cls3
	bra	fcls
	
cls4:
	movem.l	d1-a0,-(a7)
	lea	160+32(a7),a7
	dbra	d0,cls4
	bra	fcls
	
cls5:
	movem.l	d1-a2,-(a7)
	lea	160+40(a7),a7
	dbra	d0,cls5
	bra	fcls
	
cls6:
	movem.l	d1-a4,-(a7)
	lea	160+48(a7),a7
	dbra	d0,cls6
	bra	fcls
	
cls7:
	movem.l	d1-a6,-(a7)
	lea	160+56(a7),a7
	dbra	d0,cls7
	bra	fcls
	
cls8:
	movem.l	d1-a6,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+64(a7),a7
	dbra	d0,cls8
	bra	fcls
	
cls9:
	movem.l	d1-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	160+72(a7),a7
	dbra	d0,cls9
	bra.s	fcls
	
cls10:
	movem.l	d1-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	160+80(a7),a7
	dbra	d0,cls10
	bra.s	fcls
	
cls11:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a0,-(a7)
	lea	160+88(a7),a7
	dbra	d0,cls11
	bra.s	fcls
	
cls12:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a2,-(a7)
	lea	160+96(a7),a7
	dbra	d0,cls12
	bra.s	fcls
	
cls13:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a4,-(a7)
	lea	160+104(a7),a7
	dbra	d0,cls13
	bra.s	fcls
	
cls14:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	lea	160+112(a7),a7
	dbra	d0,cls14
	bra.s	fcls
	
cls15:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	lea	160+120(a7),a7
	dbra	d0,cls15
*	bra.s	fcls
	
cls0:
fcls:
	move.l	oa7(pc),a7
	trap	#15
	dc.w	$4ef9	; --> Jmp
retcls	dc.l	0
	
cls16:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	160+128(a7),a7
	dbra	d0,cls16
	bra.s	fcls
	
cls17:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	160+136(a7),a7
	dbra	d0,cls17
	bra.s	fcls
	
cls18:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a0,-(a7)
	lea	160+144(a7),a7
	dbra	d0,cls18
	bra.s	fcls
	
cls19:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a2,-(a7)
	lea	160+152(a7),a7
	dbra	d0,cls19
	bra.s	fcls
	
cls20:
	movem.l	d1-a6,-(a7)
	movem.l	d1-a6,-(a7)
	movem.l	d1-a4,-(a7)
	lea	160+160(a7),a7
	dbra	d0,cls20
	bra.s	fcls
	
main:
	moveq	#1,d0
*	lea	la2e,a0
*	jsr	initmus

	move.w	#$2700,sr
	move.b	$fffffa07.w,sava07
	move.b	$fffffa09.w,sava09
	move.l	$70.w,savvbl
	move.l	#vbl,$70.w
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	bclr	#3,$fffffa17.w
	move.w	#$2300,sr
	
	move.b	ec1+3*4-4+1,$ffff8201.w
	move.b	ec1+3*4-4+2,$ffff8203.w
	
mainloop:
*	move.w	#$700,$ff8240
	move.l	curec,a0
	sub.l	affec,a0
	cmpa.l	#NECR*4-1*4,a0
	bge.s	mainloop

	move.l	curec,a0
	addq.l	#4,a0
	cmpa.l	#ec+NECR*4*2,a0
	blt.s	okswap
	suba.w	#NECR*4,a0
	sub.l	#NECR*4,affec
	
okswap:
	move.l	(a0),ec1
	move.l	(NECR*2)*4*1(a0),curlim
	move.l	(NECR*2)*4*2(a0),affpal
	move.l	a0,curec
	
	move.l	ec1,a0
	move.l	curlim,a1
	movem.w	(a1),d0-d3
	move.l	#.ret,retcls
	bra	cls
.ret:

	tst.w	cz
	blt.s	.okcz
	
	addq.w	#2,oz
	subq.w	#1,cz
.okcz
	
	move.w	oba,d0
	add.w	va,d0
	andi.w	#TSINUS-1,d0
	move.w	d0,oba

	move.w	obb,d0
	add.w	vb,d0
	andi.w	#TSINUS-1,d0
	move.w	d0,obb
	
	move.w	obg,d0
	add.w	vg,d0
	andi.w	#TSINUS-1,d0
	move.w	d0,obg
	 
norot:
	move.l	curobj,a0
	move.w	oba,10(a0)
	move.w	obb,12(a0)
	move.w	obg,14(a0)
	
	lea	16(a0),a6
	jsr	afforme

	move.b	$fffffc02.w,d0
	ext.w	d0

	clr.b	tcol
	cmpi.b	#$f,d0
	bne.s	nocol	
	
	move.w	#$003,$ffff8240.w
	move.b	#1,tcol
nocol:

	cmpi.b	#$61,d0
	bne.s	zoomin
	
	addq.w	#1,oz
zoomin:

	cmpi.b	#$62,d0
	bne.s	zoomout
	
	subq.w	#1,oz
zoomout:

	cmpi.w	#$3b,d0
	blt.s	.nof
	cmpi.w	#$3b+10,d0
	bge.s	.nof
	
	move.w	d0,d1
	subi.w	#$3b,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	lobj,a0
	move.l	(a0,d1.w),curobj
.nof:
	
	cmpi.b	#$39,d0
	bne	mainloop

fin:
	move.w	#$2700,sr
	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w
	
	bset	#3,$fffffa17.w
	
	move.l	#$08000000,$ff8800
	move.l	#$09000000,$ff8800
	move.l	#$0a000000,$ff8800
	
	move.b	sava07,$fffffa07.w
	move.b	sava09,$fffffa09.w
	move.l	savvbl,$70.w
	move.w	#$2300,sr
	
	move.w	#$000,$ffff8240.w
	bsr	uninit

	illegal

nombre:
	incbin	zeroa99.bin
finnombre:
	rts
	
vbl:
	movem.l	d0-a6,-(a7)
	clr.w	$ffff8240.w
	move.l	#vbl2,$120.w
	clr.b	$fffffa1b.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w
	move.b	#220,$fffffa21.w
	move.b	#7,$fffffa1b.w
*	bsr	playmus
	movem.l	(a7)+,d0-a6
	rte
	
vbl2:
*	move.w	#$005,$ffff8240.w
	movem.l	a0-a1,-(a7)
	
	addq.w	#1,cvbl
	addq.w	#1,cvbl1
	cmpi.w	#50,cvbl1
	blt.s	okcvbl
	
	move.w	cvbl2,cvbl3
	clr.w	cvbl1
	clr.w	cvbl2
okcvbl:

	sub.l	a1,a1
	move.w	cvbl3,a1
	add.w	a1,a1
	add.w	a1,a1
	adda.l	#nombre,a1
	move.l	ec1,a0
	jsr	(a1)

	move.l	curec,a1
	sub.l	affec,a1
	cmpa.l	#2*4,a1
	blt.s	noswap
	
	addq.w	#1,cvbl2
	addq.l	#4,affec
	move.l	affec,a0
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w
	move.l	NECR*2*4*2(a0),a0
	move.l	a1,-(a7)
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	move.l	(a7)+,a1
	
noswap:
	adda.l	#nombre,a1
	move.l	ec1,a0
	lea	8*160(a0),a0
	jsr	(a1)
	
	movem.l	(a7)+,a0-a1
	rte

*	include	e:\musique.ovr\replay\replay.s
*music:	incbin	e:\musique.ovr\replay\coso\tera3*.*
	
table:
	incbin	table2

		* Position de l'observateur --->
ox	dc.w	0
oy	dc.w	0
oz	dc.w	-267
*cz	dc.w	800
cz	dc.w	0

oa	dc.w	0	* Angle Alpha
ob	dc.w	0	* Beta
og	dc.w	0	* et Gamma...
oba	dc.w	0
obb	dc.w	0
obg	dc.w	0

va	dc.w	6
vb	dc.w	2
vg	dc.w	4

		* Exemple de forme 3D ---> un cube
cube:
	dc.w	8		* 8 points
	dc.w	-100,-100,-100
	dc.w	100,-100,-100
	dc.w	100,100,-100
	dc.w	-100,100,-100
	dc.w	-100,-100,100
	dc.w	100,-100,100
	dc.w	100,100,100
	dc.w	-100,100,100
	
	dc.w	6		* 6 faces
	dc.w	4,1,1		* 4 points dans face No1, couleur 1, test visibilit‚e
	dc.w	4,5,6,7
	dc.w	4,2,1		* 4 points dans face No2
	dc.w	7,6,2,3
	dc.w	4,3,1		* 4 points dans face No3
	dc.w	0,1,5,4
	dc.w	4,4,1		* 4 points dans face No4
	dc.w	4,7,3,0
	dc.w	4,5,1		* 4 points dans face No5
	dc.w	1,2,6,5
	dc.w	4,6,1		* 4 points dans face No6, couleur 1
	dc.w	3,2,1,0
	
cube2:
	dc.w	8		* 8 points
	dc.w	-100,-100,-100
	dc.w	100,-100,-100
	dc.w	100,100,-100
	dc.w	-100,100,-100
	dc.w	-100,-100,100
	dc.w	100,-100,100
	dc.w	100,100,100
	dc.w	-100,100,100
	
	dc.w	8		* 8 faces
	
	dc.w	4,1,0
	dc.w	3,7,4,0
	dc.w	4,2,0
	dc.w	0,4,5,1
	dc.w	4,3,0
	dc.w	1,5,6,2
	dc.w	4,4,0
	dc.w	2,6,7,3
	
	dc.w	4,1,0
	dc.w	0,4,7,3
	dc.w	4,2,0
	dc.w	1,5,4,0
	dc.w	4,3,0
	dc.w	2,6,5,1
	dc.w	4,4,0
	dc.w	3,7,6,2

				* un tetraede
tri:
	dc.w	5
	dc.w	0,150,0
	dc.w	-100,0,-100
	dc.w	100,0,-100
	dc.w	100,0,100
	dc.w	-100,0,100
	
	dc.w	5
	dc.w	3,8,1
	dc.w	0,2,1
	dc.w	3,10,1
	dc.w	0,3,2
	dc.w	3,9,1
	dc.w	0,4,3
	dc.w	3,11,1
	dc.w	0,1,4
	dc.w	4,4,1
	dc.w	1,2,3,4
	
carre:
	dc.w	4
	dc.w	-300,-300,-300
	dc.w	-300,-300,300
	dc.w	300,-300,300
	dc.w	300,-300,-300
	dc.w	2
	dc.w	4,10,1
	dc.w	0,1,2,3
	dc.w	4,11,1
	dc.w	3,2,1,0
	
OBJET	MACRO
	dc.l	\1
	dc.w	\2,\3,\4,\5,\6,\7
	endm
	
alliance:
	dc.w	22		;22 points.
*********************
	dc.w	-32,80,-32	;Points No 0
	dc.w	-32,80,32		;Points No 1
	dc.w	32,80,-32		;Points No 2
	dc.w	32,80,32		;Points No 3
	dc.w	112,-80,-32	;Points No 4
	dc.w	112,-80,32	;Points No 5
	dc.w	48,-80,-32	;Points No 6
	dc.w	48,-80,32		;Points No 7
	dc.w	32,-48,-32	;Points No 8
	dc.w	32,-48,32		;Points No 9
	dc.w	-32,-48,-32	;Points No 10
	dc.w	-32,-48,32	;Points No 11
	dc.w	-48,-80,-32	;Points No 12
	dc.w	-48,-80,32	;Points No 13
	dc.w	-112,-80,-32	;Points No 14
	dc.w	-112,-80,32	;Points No 15
	dc.w	-16,-16,-32	;Points No 16
	dc.w	-16,-16,32	;Points No 17
	dc.w	16,-16,-32	;Points No 18
	dc.w	16,-16,32		;Points No 19
	dc.w	0,16,-32		;Points No 20
	dc.w	0,16,32		;Points No 21


	dc.w	17		;17 faces.
*********************
	dc.w	4,1,1	;4 points dans face 9
	dc.w	19,21,20,18

	dc.w	4,1,1	;4 points dans face 10
	dc.w	21,17,16,20
	
	dc.w	4,2,1	;4 points dans face 8
	dc.w	17,19,18,16

	dc.w	4,4,1	;4 points dans face 0
	dc.w	1,3,2,0
	
	dc.w	4,3,1	;4 points dans face 2
	dc.w	5,7,6,4
	
	dc.w	4,3,1	;4 points dans face 4
	dc.w	9,11,10,8
	
	dc.w	4,3,1	;4 points dans face 6
	dc.w	13,15,14,12

	dc.w	4,2,1	;4 points dans face 1
	dc.w	3,5,4,2
	
	dc.w	4,2,1	;4 points dans face 3
	dc.w	7,9,8,6

	dc.w	4,2,1	;4 points dans face 5
	dc.w	11,13,12,10

	dc.w	4,2,1	;4 points dans face 7
	dc.w	15,1,0,14

	dc.w	4,6,1	;4 points dans face 11
	dc.w	16,18,8,10

	dc.w	7,6,1	;7 points dans face 13
	dc.w	0,2,20,16,10,12,14

	dc.w	6,6,1	;6 points dans face 14
	dc.w	2,4,6,8,18,20
	
	dc.w	4,5,1	;4 points dans face 12
	dc.w	11,9,19,17

	dc.w	7,5,1	;7 points dans face 15
	dc.w	1,15,13,11,17,21,3

	dc.w	6,5,1	;6 points dans face 16
	dc.w	7,5,3,21,19,9
	
craft:
	dc.w	14		;14 points.
*********************
	dc.w	0,0,100		;Points No 0
	dc.w	0,10,10		;Points No 1
	dc.w	0,-10,10		;Points No 2
	dc.w	-21,0,10		;Points No 3
	dc.w	19,0,10		;Points No 4
	dc.w	0,19,-21		;Points No 5
	dc.w	0,12,-100		;Points No 6
	dc.w	0,-6,-100		;Points No 7
	dc.w	-12,0,-100	;Points No 8
	dc.w	12,0,-100		;Points No 9
	dc.w	-165,0,-61	;Points No 10
	dc.w	-168,0,-85	;Points No 11
	dc.w	168,0,-85		;Points No 12
	dc.w	168,0,-61		;Points No 13


	dc.w	15		;14 faces.
*********************
	dc.w	3,10,1	;3 points dans face 4
	dc.w	3,1,5

	dc.w	3,10,1	;3 points dans face 5
	dc.w	1,4,5
	
	dc.w	3,3,1	;3 points dans face 0
	dc.w	3,0,1

	dc.w	3,4,1	;3 points dans face 1
	dc.w	0,4,1

	dc.w	3,2,1	;3 points dans face 2
	dc.w	2,0,3

	dc.w	3,3,1	;3 points dans face 3
	dc.w	2,4,0

	dc.w	4,3,1	;4 points dans face 7
	dc.w	8,3,5,6

	dc.w	4,4,1	;4 points dans face 8
	dc.w	4,9,6,5

	dc.w	4,2,1	;4 points dans face 9
	dc.w	7,2,3,8

	dc.w	4,3,1	;4 points dans face 10
	dc.w	4,2,7,9

	dc.w	4,10,1	;4 points dans face 11
	dc.w	9,7,8,6

	dc.w	4,10,0	;4 points dans face 12
	dc.w	3,8,11,10

	dc.w	4,10,0	;4 points dans face 13
	dc.w	4,13,12,9
	
	dc.w	4,10,0	;4 points dans face 12
	dc.w	10,11,8,3

	dc.w	4,10,0	;4 points dans face 13
	dc.w	9,12,13,4


DODE	MACRO	
	DC.W	\1,\2,\3
	ENDM


dodecaedre
	DC.W	20

	DODE	283,631,390
	DODE	458,631,-149
	DODE	0,631,-482
	DODE	-458,631,-149
	DODE	-283,631,390
	DODE	-458,149,631
	DODE	0,-149,780
	DODE	458,149,631
	DODE	742,-149,241
	DODE	742,149,-241
	DODE	458,-149,-631
	DODE	0,149,-780
	DODE	-458,-149,-631
	DODE	-742,149,-241
	DODE	-742,-149,241
	DODE	-283,-631,-390
	DODE	-458,-631,149
	DODE	0,-631,482
	DODE	458,-631,149
	DODE	283,-631,-390


fdodecaedre
	DC.W	12	

	DC.W	5,1,0,0,1,2,3,4
	DC.W	5,2,0,0,4,5,6,7
	DC.W	5,3,0,0,7,8,9,1
	DC.W	5,4,0,1,9,10,11,2
	DC.W	5,1,0,2,11,12,13,3
	DC.W	5,2,0,3,13,14,5,4
	DC.W	5,3,0,12,15,16,14,13
	DC.W	5,4,0,14,16,17,6,5
	DC.W	5,1,0,6,17,18,8,7
	DC.W	5,2,0,8,18,19,10,9
	DC.W	5,3,0,11,10,19,15,12
	DC.W	5,4,0,17,16,15,19,18
	
obj1	OBJET	tri,0,0,-70,0,0,0
obj2	OBJET	cube,0,0,30,0,0,0
obj3	OBJET	cube2,0,0,30,0,0,0
obj4	OBJET	carre,0,0,400,0,0,0
obj5	OBJET	alliance,0,0,30,0,0,0
obj6	OBJET	craft,0,0,30,0,0,0
obj7	OBJET	dodecaedre,0,0,1975,0,0,0

lobj	dc.l	obj1,obj2,obj3,obj4,obj5
	dc.l	obj6,obj7,obj1,obj1,obj1
curobj	dc.l	obj2
	
colorpoly	ds.w	1		; couleur du polygone

maxy	ds.w	1
miny	ds.w	1

	section	bss
tface	ds.l	256	* Table des face apres triage (128 max)
tdist	ds.w	256	* Table des distances des faces pour triage.
tplot	ds.w	512*3	* Table des points apres calcul 3D
tdplot	ds.w	512	* Table distance points pour calcul dist. face

plot	ds.l	512	* 512 points max dans une forme 3D
	ds.w	2
pxy	ds.l	128	* Tableau du polygone

tpxy1	ds.l	128	* 128 points maximum pour les polygone remplis.
tpxy2	ds.l	128

tlx1	ds.w	NBLIG	* Table des lignes. X en fonction de Y.
tlx2	ds.w	NBLIG

tobj	ds.b	16*1000	* Table des objets … afficher. 1000 max!
cobj	ds.l	1
dobj	ds.l	1000	* Table distance pour triage des objets.
trieobj	ds.w	1000
nobj	ds.w	1

sava07	ds.b	1	
sava09	ds.b	1	
savvbl	ds.l	1
tcol	ds.w	1
oldpal	ds.w	16
	
ldecal	ds.l	DEPASSE
	ds.l	LECRAN

rdecal	ds.l	LECRAN
	ds.l	DEPASSE
