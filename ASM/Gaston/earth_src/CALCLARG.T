;----- Fichier : CalcLarg.T -----------------------------------------------

	SECTION TEXT

***************************************************************************

js	equr	d7
compt	equr	d6
a	equr	d5
j	equr	d3
comptpas	equr	d2

***************************************************************************

;----- For a=0 To 720 : Largeur de la sphäre dans tableau Largeur ---------

CALC_LARGEUR:
	move.w	4(sp),Diametre
	move.w	Diametre,d0	; Rayon=diametre/2
	lsr.w	#1,d0
	move.w	d0,Rayon

	move.l	#-1000,js
	move.w	Rayon,compt
	moveq.w	#1,comptpas
	move.w	#360,a
for1:	bsr.s	CALC
	subq.w	#1,a
	cmpi.w	#-2,a
	bne.s	for1	
	
	move.w	Rayon,compt
	subq.w	#1,compt
	move.w	#-1,comptpas
	move.w	#362,a
for2:	bsr.s	CALC
	addq.w	#1,a
	cmpi.w	#722,a
	bne.s	for2
	RTS

***************************************************************************

;----- Calcule la largeur de chaque ligne de la sphäre --------------------

CALC:
	* J=rayon*sin(a) *
	move.w	a,d0
	move.w	Rayon,d1
	bsr.s	SINUS
	move.l	d0,j	
	
	* Si j<>js : stocke la largeur de la ligne, js<=j *
	cmp.l	j,js
	beq.s	calc2

	move.w	a,d0	; I=rayon*cos(a)
	move.w	Rayon,d1
	bsr.s	COSINUS
	neg.w	d0
	lsl.w	#1,d0
	tst.w	d0
	bne.s	calc3
	moveq.w	#20,d0	; si largeur=0 : on la met Ö 20
calc3:	
	cmpi.w	#322,d0
	bne.s	calc32
	move.w	#324,d0
calc32:	
	move.w	d0,(largeur,compt*2)
	add.w	comptpas,compt
	move.l	j,js
calc2:	RTS

***************************************************************************
	
;----- d0.l= SIN(d0.w)*2^15 -----------------------------------------------

SINUS:	move.w	(sinustab,d0.w*2),d0
	muls	d1,d0
	lsl.w	#1,d0
	clr.w	d0
	swap	d0	
	roxl.w	#1,d0
	RTS

***************************************************************************

;----- d0.l= COS1(d0.w)*2^15 -----------------------------------------------

COS:	move.w	(mappetab,d0.w*2),d0
	muls	d1,d0
	lsl.w	#1,d0
	clr.w	d0
	swap	d0	
	roxl.w	#1,d0
	RTS

***************************************************************************

;----- d0.l= COS2(d0.w)*2^15 -----------------------------------------------

COSINUS:	move.w	(cosinustab,d0.w*2),d0
	muls	d1,d0
	lsl.w	#1,d0
	clr.w	d0
	swap	d0	
	roxl.w	#1,d0
	RTS

***************************************************************************

	SECTION DATA

mappetab:	incbin	mappe.tab
sinustab:	incbin	sinus.tab
cosinustab:	incbin	cosinus.tab

***************************************************************************

	SECTION BSS

largeur:	ds.w	1000
diametre:	ds.w	1
rayon:	ds.w	1

***************************************************************************

	SECTION TEXT