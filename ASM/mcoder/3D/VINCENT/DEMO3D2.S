* The maxi optimyzed 3D Z-rout
* (C) 1989-90 Vincent PENNE.

NECR	equ	8

	opt	o+,o2+
	opt	c-

distec	equ	32

	include	\util.s
debut:
	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#4,a7

	move.w	#$333,$ffff8242.w
	move.w	#$555,$ffff8244.w
	move.w	#$777,$ffff8248.w
	move.w	#$700,$ffff8250.w
	
	bsr	init
	
*	move.b	#18,$fffc02
	
	move.w	#$777,$ffff8242.w
	move.w	#$666,$ffff8244.w
	move.w	#$555,$ffff8246.w
	
	movem.l	$8.w,d0-d7
	movem.l	d0-d7,oldbomb
	
	lea	$8.w,a0		; Redirection des bombes
	move.l	#fin,d0
	rept	8
	move.l	d0,(a0)+
	endr
	
	bclr	#5,$fffffa15.w
	
	jmp	main

oldbomb	ds.l	8
	
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
	
afforme:
*	move.w	#$500,$ffff8240.w
	
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

	lea	table,a1	* Table des sinus...
	lea	table+360*2,a2	* et des cosinus
	
	move.w	oa,d0
	lsl.w	#1,d0
	move.w	(a1,d0.w),sa
	move.w	(a2,d0.w),ca

	move.w	ob,d0
	lsl.w	#1,d0
	move.w	(a1,d0.w),sb
	move.w	(a2,d0.w),cb

	move.w	og,d0
	lsl.w	#1,d0
	move.w	(a1,d0.w),sg
	move.w	(a2,d0.w),cg
	
	move.w	-6(a6),d0
	lsl.w	#1,d0
	move.w	(a1,d0.w),sab
	move.w	(a2,d0.w),cab

	move.w	-4(a6),d0
	lsl.w	#1,d0
	move.w	(a1,d0.w),sbb
	move.w	(a2,d0.w),cbb

	move.w	-2(a6),d0
	lsl.w	#1,d0
	move.w	(a1,d0.w),sgb
	move.w	(a2,d0.w),cgb
	
	lea	plot,a0
	move.l	-16(a6),a1
	move.w	(a1)+,d0		; Nombre de points
	subq.w	#1,d0
	move.w	zoom,d1
	lea	tdplot,a2
	lea	tplot,a3
	
	clr.w	limx1
	clr.w	limx2
	clr.w	limy1
	clr.w	limy2
	
calcplot:
	movem.w	(a1)+,d2-d4
	
				; Rotation autour du centre de l'objet
	
				; rotation autour de Oy --->
	; XX = X * cos(ob) - Z * sin(ob)
	tst.w	-4(a6)
	beq.s	noy1
	move.w	d2,d5
	move.w	d4,d6
	muls	cbb,d5
	muls	sbb,d6
	sub.l	d6,d5
	moveq.w	#14,d6
	asr.l	d6,d5
	
	; ZZ = X * sin(ob) + Z * cos(ob)
	move.w	d2,d6
	move.w	d4,d7
	muls	sbb,d6
	muls	cbb,d7
	add.l	d7,d6
	moveq.w	#14,d7
	asr.l	d7,d6
	
	move.w	d5,d2
	move.w	d6,d4 
noy1:
	
				; rotation autour de Oz --->
	; XX = X * cos(og) + Y * sin(og)
	tst.w	-2(a6)
	beq.s	noz1
	move.w	d2,d5
	move.w	d3,d6
	muls	cgb,d5
	muls	sgb,d6
	add.l	d6,d5
	moveq.w	#14,d6
	asr.l	d6,d5
	
	; YY = Y * cos(og) - X * sin(og)
	move.w	d2,d6
	move.w	d3,d7
	muls	cgb,d7
	muls	sgb,d6
	sub.l	d6,d7
	moveq.w	#14,d6
	asr.l	d6,d7
	
	move.w	d5,d2
	move.w	d7,d3
noz1:
	
				; rotation autour de Ox --->
	; YY = Y * cos(oa) + Z * sin(oa)
	tst.w	-6(a6)
	beq.s	nox1
	move.w	d3,d5
	move.w	d4,d6
	muls	cab,d5
	muls	sab,d6
	add.l	d6,d5
	moveq.w	#14,d6
	asr.l	d6,d5
	
	; ZZ = Z * cos(oa) - Y * sin(oa)
	move.w	d3,d6
	move.w	d4,d7
	muls	cab,d7
	muls	sab,d6
	sub.l	d6,d7
	moveq.w	#14,d6
	asr.l	d6,d7
	
	move.w	d5,d3
	move.w	d7,d4 
nox1:
		
				; On ramene aux coordon‚e de l'obs	
	add.w	obx,d2
	add.w	oby,d3
	add.w	obz,d4
	neg.w	d3
	
	move.w	d4,(a2)+	; M‚morisation distance et points
	move.w	d2,(a3)+
	move.w	d3,(a3)+
	move.w	d4,(a3)+
	
	cmpi.w	#distec,d4	; Z inf‚rieur … distec?
	bgt.s	ok3d		; Non
	
	addq.l	#4,a0
	bra.s	c3d
	
ok3d:				; 3D vers 2D --->	
	; (X * ZOOM) / Z + CX
	
	muls	d1,d2
	divs	d4,d2
	add.w	cx,d2
	move.w	d2,(a0)+
	cmp.w	limx1,d2
	
	; (Y * ZOOM) / Z + CY
	
	muls	d1,d3
	divs	d4,d3
	add.w	cy,d3
	move.w	d3,(a0)+
	
c3d:
*	not.w	$ffff8240.w
	dbra	d0,calcplot
	
*	move.w	#$550,$ffff8240.w
	
				; On construit la table des faces initial
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
*	btst	#0,5(a2)	; Doit on v‚rifier la visibilit‚?
	bra	goodface	; Non

				; Verification visibilit‚e de la face --->
	movem.l	d0-d1,-(a7)

	move.w	6+2(a2),d0	; --> Point 1
	move.w	d0,d1
	add.w	d0,d1
	add.w	d0,d1		; fois 3
	lsl.w	#1,d1		; plus fois 2 --> fois 6
	move.w	(a5,d1.w),d2	; X1
	move.w	2(a5,d1.w),d3	; Y1
	move.w	4(a5,d1.w),d4	; Z1
	
	move.w	6+4(a2),d0	; --> Point 2
	move.w	d0,d1
	add.w	d0,d1
	add.w	d0,d1		; fois 3
	lsl.w	#1,d1		; plus fois 2 --> fois 6
	move.w	(a5,d1.w),d5	; X2
	move.w	2(a5,d1.w),d6	; Y2
	move.w	4(a5,d1.w),d7	; Z2
	
	move.w	6+0(a2),d0	; --> Point 0
	move.w	d0,d1
	add.w	d0,d1
	add.w	d0,d1		; fois 3
	lsl.w	#1,d1		; plus fois 2 --> fois 6
	sub.w	(a5,d1.w),d2	; X1-X0
	sub.w	2(a5,d1.w),d3	; Y1-Z0
	sub.w	4(a5,d1.w),d4	; Z1-Z0
	sub.w	(a5,d1.w),d5	; X2-X0
	sub.w	2(a5,d1.w),d6	; Y2-Z0
	sub.w	4(a5,d1.w),d7	; Z2-Z0
	
	move.w	d2,vx
	move.w	d3,vy
	move.w	d4,vz
	
		; x = vy * zz - vz * yy;
	muls	d7,d3
	muls	d6,d4
	asr.l	#5,d3
	asr.l	#5,d4
	sub.l	d4,d3
	move.l	d3,vvx
	
		; y = vz * xx - vx * zz;
	move.w	vz,d4
	muls	d5,d4
	muls	d7,d2
	asr.l	#5,d4
	asr.l	#5,d2
	sub.l	d2,d4
	move.l	d4,vvy
	
		; z = vx * yy - vy * xx;
	move.w	vx,d2
	move.w	vy,d3
	muls	d6,d2
	muls	d5,d3
	asr.l	#5,d2
	asr.l	#5,d3
	sub.l	d3,d2
	move.l	d2,d4
	move.l	vvx,d2
	move.l	vvy,d3

		; vvx * x0 + vvy * y0 + vvz * z0	
	muls	(a5,d1.w),d2	; x0 * vvx
	asr.l	#5,d2
	muls	2(a5,d1.w),d3	; y0 * vvy
	asr.l	#5,d3
	muls	4(a5,d1.w),d4	; z0 * vvz
	asr.l	#5,d4
	add.l	d3,d2
	add.l	d4,d2
	
	movem.l	(a7)+,d0-d1
	
	tst.l	d2		; Affichage face?
	bge.s	goodface	; Oui
	
	move.w	(a2),d2		; sinon on saute par dessus la face
	lsl.w	#1,d2
	lea	6(a2,d2.w),a2
	
	bra.s	badface

goodface:
	move.l	a2,(a0)+
	addq.w	#1,d0		; Contage nombre de face valable
	move.w	(a2),d2
	addq.l	#6,a2		; Pas besoins de la couleur de la face
	
	move.w	d2,d3		; Calcul de la distance de la face:
	subq.w	#1,d3
	moveq.w	#0,d4
loopcalcdist:			; on additionne les distance des points...
	move.w	(a2)+,d5
	lsl.w	#1,d5
	add.w	(a3,d5.w),d4
	
	dbra	d3,loopcalcdist
	
	ext.l	d4
	divs	d2,d4		; on divise par le nombre de points...
	move.w	d4,(a4)+	; et on m‚morise!

badface:	
	dbra	d1,loopmemface
	
	bra.s	notrie

	cmpi.w	#1,d0		; Triage. D0: nbr de face
	ble.s	notrie
	lea	tdist,a2	; A2: table des distances
	lea	tface,a3	; A3: table des adresses des faces
	move.w	d0,d1
	lsl.w	#1,d1
	lea	-2(a2,d1.w),a4	; fin table des distances
trie1:
	move.w	(a2)+,d5	; distance point 1
	move.l	(a3)+,d6
	move.l	a2,a5
	move.l	a3,a6
	
trie2:
	cmp.w	(a5)+,d5	; on compare avec distance point 2
	bge.s	oktrie
	
	move.w	-2(a5),-2(a2)	; on inverse les 2 faces
	move.w	d5,-2(a5)
	move.l	(a6),-4(a3)
	move.l	d6,(a6)
	move.w	-2(a2),d5
	move.l	-4(a3),d6
	
oktrie:
	addq.l	#4,a6
	cmp.l	a4,a5
	ble.s	trie2
	
	cmp.l	a4,a2
	blt.s	trie1
	
notrie:
	lea	plot,a0
	lea	tface,a3
	tst.w	d0
	ble	noforme
	subq.w	#1,d0
	
loopface:
	move.l	(a3)+,a1
	move.w	(a1)+,d1	; Nombre de points dans face N
	moveq.w	#0,d7
	subq.w	#1,d1
	lea	pxy,a2
	move.w	(a1)+,colorpoly	; Couleur de la face N
	move.w	(a1)+,d2	; Attribut de la face (ligne/rempli,etc...)
	lea	tplot,a4
	lea	2(a1),a5
	
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
	
		; cx + zoom * (x + ((xx - x) * (10 - z)) / (zz - z)) / 10
	move.w	(a4,d3.w),d4
	sub.w	(a4,d2.w),d4
	moveq.w	#distec,d5
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
		; cy + zoom * (y + ((yy - y) * (10 - z) / (zz - z)) / 10
	move.w	2(a4,d3.w),d4
	sub.w	2(a4,d2.w),d4
	moveq.w	#distec,d5
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
	
		; cx + zoom * (x + ((xx - x) * (10 - z)) / (zz - z)) / 10
	move.w	(a4,d3.w),d4
	sub.w	(a4,d2.w),d4
	moveq.w	#distec,d5
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
		; cy + zoom * (y + ((yy - y) * (10 - z) / (zz - z)) / 10
	move.w	2(a4,d3.w),d4
	sub.w	2(a4,d2.w),d4
	moveq.w	#distec,d5
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
	lea	pxy,a6
	
	cmpi.w	#3,d7
	blt.s	nopoly2
	
	movem.l	d0/a0/a3,-(a7)
	bsr.s	affpoly
	movem.l	(a7)+,d0/a0/a3

nopoly2:
	dbra	d0,loopface

noforme:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	
affpoly:
*	move.w	#$005,$ffff8240.w
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
	
	move.w	-4(a0),d0
	move.w	4(a0),d1
	
	sub.w	(a0),d0
	sub.w	(a0),d1
	
	move.w	6(a0),d2
	sub.w	2(a0),d2
	muls	d2,d0
	
	move.w	-2(a0),d2
	sub.w	2(a0),d2
	muls	d2,d1
	
	cmp.l	d0,d1		* Point venant apres a gauche?
	ble	nopoly		* Oui.
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
	move.w	(a4)+,d0	* Valeur y du point.
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
	
	move.w	miny,d0	* miny-->D0
	move.w	miy,d2	* miy-->D2
	cmp.w	d2,d0		* Miny plus petit que miy?
	bge.s	cnegaplot	* Non
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
	blt	nopoly
	
new_lplot:
	move.w	(a0)+,d1		* X1
	move.w	(a0)+,d2		* Y1
	move.w	(a0),d3		* X2
	move.w	2(a0),d4		* Y2
	cmp.w	d0,d4		* Y2 superieur a D0?
	blt.s	new_lplot
	cmp.w	d4,d2		* Pour eviter la division par 0...
	bge.s	new_lplot
	move.w	d4,d6
	cmp.w	d7,d6		* Points plus bas que may?
	blt.s	oklowl		* Non
	move.w	d7,d6
	addq.w	#1,d6
oklowl:
	cmpi.w	#32000,d4		* Dernier point?
	beq.s	fin_lplot		* On sort
	cmp.w	d7,d0		* Depasser may?
	bgt.s	fin_lplot		* On sort.
	
	sub.w	d1,d3
	sub.w	d2,d4
	
*	move.w	d0,d5		* On cherche X de d‚part par rapport … D0
*	sub.w	d2,d5
*	muls	d3,d5
*	divs	d4,d5
*	add.w	d5,d1

	moveq.w	#8,d5
	ext.l	d3
	swap	d1
	move.w	#0,d1
	lsl.l	d5,d3
	divs	d4,d3
	ext.l	d3
	asl.l	d5,d3
	
	sub.w	d6,d0
	neg.w	d0
	
calc_lplot:
	move.l	d1,d4
	swap	d4
	move.w	d4,(a2)+
	add.l	d3,d1
	
	dbra	d0,calc_lplot
	move.w	d6,d0
	
	bra.s	new_lplot
	
fin_lplot:

	move.w	miny,d0

new_rplot:
	move.w	(a1)+,d1	* X1
	move.w	(a1)+,d2	* Y1
	move.w	(a1),d3		* X2
	move.w	2(a1),d4	* Y2
	cmp.w	d0,d4		* Y2 superieur a D0?
	blt.s	new_rplot
	cmp.w	d4,d2		* Pour eviter la division par 0...
	bge.s	new_rplot
	move.w	d4,d6
	cmp.w	d7,d6		* Points plus bas que may?
	blt.s	oklowr		* Non
	move.w	d7,d6
	addq.w	#1,d6
oklowr:
	cmpi.w	#32000,d4	* Dernier point?
	beq.s	fin_rplot	* On sort
	cmp.w	d7,d0		* Depasser may?
	bgt.s	fin_rplot	* On sort.
	
	sub.w	d1,d3
	sub.w	d2,d4
	
*	move.w	d0,d5		* On cherche X de d‚part par rapport … D0
*	sub.w	d2,d5
*	muls	d3,d5
*	divs	d4,d5
*	add.w	d5,d1

	moveq	#8,d5
	swap	d1
	clr.w	d1
	ext.l	d3
	lsl.l	d5,d3
	divs	d4,d3
	ext.l	d3
	asl.l	d5,d3
	
	sub.w	d6,d0
	neg.w	d0

calc_rplot:
	move.l	d1,d4
	swap	d4
	move.w	d4,(a3)+
	add.l	d3,d1
	
	dbra	d0,calc_rplot
	move.w	d6,d0
	
	bra.s	new_rplot
	
fin_rplot:	
	
	move.w	d0,d7
	sub.w	miny,d7
	subq.w	#1,d7
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
	lea	hline(pc),a2
	lea	decal,a1
	move.w	#$f,d2
*	move.w	#$050,$ffff8240.w
	jsr	(a2)

nopoly:
*	move.w	#$500,$ffff8240.w
	rts
	
init:
	lea	decal,a2
	lea	decal,a0
	move.w	#0,d2
	move.w	#19,d0
decal1:
	lea	bord,a1
	move.w	#15,d1
decal2:
	move.w	(a1),(a0)+
	move.w	d2,(a0)+
	
	move.w	d2,-(a2)
	move.w	(a1)+,-(a2)

	dbra	d1,decal2
	addq.w	#4,d2

	dbra	d0,decal1

	dc.w	$a00a
	
	move.l	$44e.w,oldec
	
	move.l	#ecran+256,d0
	andi.l	#$ffff00,d0
	lea	ec,a0
	rept	NECR
	move.l	d0,(a0)+
	addi.l	#32000,d0
	endr
	move.l	ec,ec+NECR*4
	move.l	ec+4,ec+NECR*4+4
	move.l	ec+8,ec+NECR*4+8
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

	Vsync
	clr.b	$ffff8260.w

	rts
	
uninit:	
	Vsync
	move.b	oldrez+1,$ffff8260.w

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
	
curec	dc.l	ec1
affec	dc.l	ec1+3*4
cvbl	dc.w	0
cvbl1	dc.w	0
cvbl2	dc.w	0
cvbl3	dc.w	0

curlim	ds.l	1
ec1	ds.l	1

ec:
	ds.l	NECR+3

tlim:
N	set	0
	rept	NECR
	dc.l	lim+N
N	set	N+8
	endr
N	set	0
	rept	3
	dc.l	lim+N
N	set	N+8
	endr

	section	bss
lim:	ds.w	4*(NECR+3)

oldrez	ds.w	1
oldec	ds.l	1
ecran	ds.b	32000*NECR+256

	section	text
	
			* ligne horizontal. d0: X1, d1: X2, a0: Ad. ligne,
			* a2: Adresse de cntline, a3: Addresse de BORD
			* d0 a d6 (sauf d2), a0 et a1 sont perdus.
			
coucou	macro
	move.w	(a4)+,d0
	move.w	(a5)+,d1

*	cmp.w	d0,d1	
*	ble	nohline\@

	add.w	d0,d0
	add.w	d0,d0
	move.l	(a1,d0.w),d3
	move.w	d3,d0
	move.w	d0,d2
	swap	d3
	
	move.l	a6,a0
	add.w	d2,d2	
	adda.w	d2,a0
	
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a1,d1.w),d1
	move.l	d1,d2
	swap	d2
	
	sub.w	d1,d0
	addq	#4,d0
	bgt.s	little_line\@
	
	or.w	d3,(a0)
	jmp	loopline\@(pc,d0.w)
	
little_line\@:
	not	d2
	and.w	d3,d2
	or.w	d2,(a0)
	bra.s	nohline\@
	
	move.w	d5,8*20(a0)
	move.w	d5,8*19(a0)
	move.w	d5,8*18(a0)
	move.w	d5,8*17(a0)
	move.w	d5,8*16(a0)
	move.w	d5,8*15(a0)
	move.w	d5,8*14(a0)
	move.w	d5,8*13(a0)
	move.w	d5,8*12(a0)
	move.w	d5,8*11(a0)
	move.w	d5,8*10(a0)
	move.w	d5,8*9(a0)
	move.w	d5,8*8(a0)
	move.w	d5,8*7(a0)
	move.w	d5,8*6(a0)
	move.w	d5,8*5(a0)
	move.w	d5,8*4(a0)
	move.w	d5,8*3(a0)
	move.w	d5,8*2(a0)
	move.w	d5,8*1(a0)
loopline\@:
	not.w	d2
	neg.w	d0
	add.w	d0,d0
	or.w	d2,8(a0,d0.w)
nohline\@:
	lea	160(a6),a6
	endm
	
hline2:
	rept	200
	coucou
	endr
hline1:
	rts			
			
hline:
	moveq	#$ffffffff,d5
	moveq	#0,d4

	add	d7,d7
	add	d7,d7
	jmp	jmps(pc,d7.w)
jmps
N	set	0
	rept	200
	bra.w	hline1-N
N	set	N+(hline1-hline2)/200
	endr
	
main:
	move.w	#$2700,sr
	move.b	$fffffa07.w,sava07
	move.b	$fffffa09.w,sava09
	move.l	$70.w,savvbl
	move.l	#vbl,$70.w
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.w	#$2300,sr
	
	move.b	ec1+3*4-4+1,$ffff8201.w
	move.b	ec1+3*4-4+2,$ffff8203.w
	
mainloop:
*	move.w	#$700,$ff8240
	tst.w	cvbl
	beq.s	mainloop
	clr.w	cvbl

	addq.w	#1,cvbl2
	move.l	affec,a0
	addq.l	#4,a0
	cmpa.l	#ec+NECR*4+3*4,a0
	blt.s	okswap
	suba.w	#NECR*4,a0
	
okswap:
	move.l	(a0),ec1
	move.l	(NECR+3)*4(a0),curlim
	move.l	a0,affec
	
	move.l	ec1,a0
	adda.w	#32,a0
	bsr	cls2
	
	move.w	#$000,$ff8240

	cmpi.b	#1,$fffffc02.w
*	bne.s	norot
	move.w	oba,d0
	add.w	va,d0
	move.w	d0,d1
	ext.l	d1
	divs	#360,d1
	muls	#360,d1
	sub.w	d1,d0
	tst.w	d0
	bge.s	pos3
 	addi.w	#360,d0
pos3:
	move.w	d0,oba

	move.w	obb,d0
	add.w	vb,d0
	move.w	d0,d1
	ext.l	d1
	divs	#360,d1
	muls	#360,d1
	sub.w	d1,d0
	tst.w	d0
	bge.s	pos4
	addi.w	#360,d0
pos4:
	move.w	d0,obb
	
	move.w	obg,d0
	add.w	vg,d0
	move.w	d0,d1
	ext.l	d1
	divs	#360,d1
	muls	#360,d1
	sub.w	d1,d0
	tst.w	d0
	bge.s	pos5
	addi.w	#360,d0
pos5:
	move.w	d0,obg
	 
norot:
	lea	obj2,a0
	move.w	oba,10(a0)
	move.w	obb,12(a0)
	move.w	obg,14(a0)
	
	lea	16(a0),a6
	jsr	afforme

	move.b	$fffffc02.w,d0
	ext.w	d0

	cmpi.b	#$f,d0
	bne.s	nocol	
	
	move.w	#$003,$ffff8240.w
nocol:

	cmpi.b	#$61,d0
	bne.s	zoomin
	
	addq.w	#1,oz
zoomin:

	cmpi.b	#$62,d0
	bne.s	zoomout
	
	subq.w	#1,oz
zoomout:
	
	cmpi.b	#$39,d0
	bne	mainloop
	
fin:
	move.w	#$2300,sr
	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w
	
	bset	#5,$fffffa15.w
	move.b	sava07,$fffffa07.w
	move.b	sava09,$fffffa09.w
	move.l	savvbl,$70.w

	move.b	#$11,$fffffc02.w
	move.w	#$000,$ff8240
	bsr	uninit
	
	clr.w	-(a7)
	trap	#1

nombre:
	incbin	zeroa99.bin
finnombre:
	rts
	
vbl:
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

	move.l	affec,a0
	sub.l	curec,a0
	cmpa.l	#3*4,a0
	ble.s	noswap
	
	addq.l	#4,affec
	move.l	curec,a0
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w
	
noswap:
	movem.l	(a7)+,a0-a1
	rte
	
cls:
	move.l	#160,d1
	moveq.l	#-1,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#-1,d7
	move.l	d7,a1
	move.l	d7,a2
loopcls:
	movem.l	d2-d7/a1/a2,(a0)
	movem.l	d2-d7/a1/a2,32(a0)
	movem.l	d2-d7/a1/a2,64(a0)
	movem.l	d2-d7/a1/a2,96(a0)
	movem.l	d2-d7/a1/a2,128(a0)
	adda.l	d1,a0
	dbra	d0,loopcls
	rts
	
cls2:
	move.l	#160,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.l	d7,a1
	move.l	d7,a2
	move.l	d7,a3
	move.l	d7,a4
	move.l	d7,a5
	move.l	d7,a6
loopcls2:
	rept	200
	movem.l	d1-d7/a1-a6,(a0)
	movem.l	d2-d7/a1-a6,40(a0)
	adda.w	d0,a0
	endr
	rts
	
table:
	incbin	table2
	
		* Fenetre de clipping --->
mix	dc.w	0
miy	dc.w	0
max	dc.w	319
may	dc.w	199

		* Centre de l'‚cran   --->
cx	dc.w	160-8
cy	dc.w	99

		* Position de l'observateur --->
ox	dc.w	0
oy	dc.w	0
oz	dc.w	-525

oa	dc.w	0	* Angle Alpha
ob	dc.w	0	* Beta
og	dc.w	0	* et Gamma...
oba	dc.w	0
obb	dc.w	0
obg	dc.w	0

zoom	dc.w	235	* Valeur du zoom

va	dc.w	1
vb	dc.w	-2
vg	dc.w	3

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
	dc.w	4,3,1		* 4 points dans face No2
	dc.w	7,6,2,3
	dc.w	4,3,1		* 4 points dans face No3
	dc.w	0,1,5,4
	dc.w	4,2,1		* 4 points dans face No4
	dc.w	4,7,3,0
	dc.w	4,2,1		* 4 points dans face No5
	dc.w	1,2,6,5
	dc.w	4,1,1		* 4 points dans face No6, couleur 1
	dc.w	3,2,1,0
	
				* un tetraede
tri:
	dc.w	5
	dc.w	0,150,0
	dc.w	-100,0,-100
	dc.w	100,0,-100
	dc.w	100,0,100
	dc.w	-100,0,100
	
	dc.w	5
	dc.w	3,1,1
	dc.w	0,2,1
	dc.w	3,2,1
	dc.w	0,3,2
	dc.w	3,3,1
	dc.w	0,4,3
	dc.w	3,2,1
	dc.w	0,1,4
	dc.w	4,5,1
	dc.w	1,2,3,4
	
carre:
	dc.w	4
	dc.w	-300,-300,-300
	dc.w	-300,-300,300
	dc.w	300,-300,300
	dc.w	300,-300,-300
	dc.w	1
	dc.w	4,1,1
	dc.w	0,1,2,3
	
OBJET	MACRO
	dc.l	\1
	dc.w	\2,\3,\4,\5,\6,\7
	endm
	
obj1	OBJET	tri,0,0,-70,0,0,0
obj2	OBJET	cube,0,0,30,0,0,0
obj3	OBJET	carre,0,0,0,0,0,0
	
colorpoly	ds.w	1	; couleur du polygone

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

tlx1	ds.w	200	* Table des lignes. X en fonction de Y.
tlx2	ds.w	200

tobj	ds.b	16*1000	* Table des objets … afficher. 1000 max!
cobj	ds.l	1
dobj	ds.l	1000	* Table distance pour triage des objets.
trieobj	ds.w	1000
nobj	ds.w	1

ca	ds.w	1	; Cosinus et sinus pour rotations
cb	ds.w	1
cg	ds.w	1
sa	ds.w	1
sb	ds.w	1
sg	ds.w	1
cab	ds.w	1
cbb	ds.w	1
cgb	ds.w	1
sab	ds.w	1
sbb	ds.w	1
sgb	ds.w	1
vx	ds.w	1	; pour verification visibilit‚e face
vy	ds.w	1
vz	ds.w	1
vvx	ds.l	1
vvy	ds.l	1
vvz	ds.l	1
obx	ds.w	1
oby	ds.w	1
obz	ds.w	1
pdecal	ds.l	320
decal	ds.l	320
pdecal2	ds.l	320
sava07	ds.b	1	
sava09	ds.b	1	
savvbl	ds.l	1
limx1	ds.w	1
limx2	ds.w	1
limy1	ds.w	1
limy2	ds.w	1
