INITDRAW:MACRO
	dc.w	prg_init
	ENDM

TEST	MACRO
	dc.w	prg_test
	dc.w	\1*4+segments,\3*4+segments,\2*4+segments
	dc.w	\5-*-2
	ENDM

DRAW	MACRO
	dc.w	prg_draw
	dc.w	\1*4+segments,\2*4+segments
	ENDM

SKIP	MACRO
	dc.w	prg_skip
	dc.l	\1
	ENDM

AFFPOLY:MACRO
	ifeq	\1
	ifeq	\2+1
	dc.w	prg_poly0
	elseif
	dc.w	prg_poly00
	dc.w	\2
	endc
	endc

	ifeq	\1-1
	ifeq	\2+1
	dc.w	prg_poly1
	elseif
	dc.w	prg_poly10
	dc.w	\2
	endc
	endc

	ifeq	\1-2
	ifeq	\2+1
	dc.w	prg_poly2
	elseif
	dc.w	prg_poly20
	dc.w	\2
	endc
	endc

	ifeq	\1-3
	ifeq	\2+1
	dc.w	prg_poly3
	elseif
	dc.w	prg_poly30
	dc.w	\2
	endc
	endc

	ENDM

RET	MACRO
	dc.w	prg_rts
	ENDM

AFF3	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
	ENDM

AFF4	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
	ENDM

FACE3	MACRO
	TEST	\3,\4,\5,-1,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
\@
	ENDM
FACE4	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE5	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE6	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE7	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE8	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\A
	DRAW	\A,\3
	AFFPOLY	\1,\2
\@
	ENDM

INV3	MACRO
	FACE3	\1,\2,\5,\4,\3
	ENDM
INV4	MACRO
	FACE4	\1,\2,\6,\5,\4,\3
	ENDM
INV5	MACRO
	FACE5	\1,\2,\7,\6,\5,\4,\3
	ENDM
INV6	MACRO
	FACE6	\1,\2,\8,\7,\6,\5,\4,\3
	ENDM
INV7	MACRO
	FACE7	\1,\2,\9,\8,\7,\6,\5,\4,\3
	ENDM
INV8	MACRO
	FACE8	\1,\2,\A,\9,\8,\7,\6,\5,\4,\3
	ENDM
;
; structure utilis‚e :
;
;	0.L=liste des coordonn‚es
;	4.L=adresse routine affichage
;	8.L=palette objet
;	12.L=fin
;
; … impl‚menter :
;	- sc‚nario (X,Y,Z) d‚part+arriv‚e+nb images
;	- zoom maximal … stocker
;
NBOBJETS = 13+14
all_objects:
	dc.l	coords_spider,spider,palette1
	dc.l	coords_cube,cube,palette2
	dc.l	coords_tetra,tetraedre,palette3
	dc.l	coords_grille,grille,palette4
	dc.l	coords_spacecraft,spacecraft,palette5

	dc.l	coords_cube2,cube2,palette6
	dc.l	coords_cube3,cube3,palette7
	dc.l	coords_pyramide,pyramide,palette8
	dc.l	coords_carre,carre,palette1
	dc.l	coords_alliance,alliance,palette2
	dc.l	coords_craft,craft,palette3
	dc.l	coords_dodecaedre,dodecaedre,palette4

	dc.l	pspider2,fspider2,palette5
	dc.l	pvcube,fvcube,palette6
	dc.l	prcube,frcube,palette7
	dc.l	pmine,fmine,palette8
	dc.l	ptorus,ftorus,palette1
	dc.l	pchiffre8,fchiffre8,palette2
	dc.l	plettrea,flettrea,palette3
	dc.l	pdalle,fdalle,palette4
	dc.l	puncube,funcube,palette5
	dc.l	pdeuxcube,fdeuxcube,palette6
	dc.l	ppyramide,fpyramide,palette7
	dc.l	pglider2,fglider2,palette8
	dc.l	pdodecaedre,fdodecaedre,palette1
	dc.l	pnscarre,fnscarre,palette2
	dc.l	picosaedre,ficosaedre,palette3

pspider2
	DC.W	12

	DC.W	-15,40,0
	DC.W	15,40,0
	DC.W	10,-20,0
	DC.W	-10,-20,0
	DC.W	-50,-30,-50
	DC.W	-50,-50,-50
	DC.W	50,-30,-50
	DC.W	50,-50,-50
	DC.W	5,-80,-20
	DC.W	-5,-80,-20
	DC.W	-10,40,-10
	DC.W	10,40,-10

fspider2

;	ailes dessous

	INV4	0,-1,7,2,11,6
	INV4	0,-1,4,10,3,5

;	cotes

	INV3	1,-1,3,10,9
	INV3	1,-1,11,2,8

;	dessous

	INV4	2,-1,11,8,9,10

;	reacteurs

	INV4	1,-1,10,0,1,11
	INV3	2,-1,6,11,1
	INV3	2,-1,4,0,10

;	dessus

	INV4	2,-1,1,0,3,2

;	ailes dessus

	INV4	3,-1,6,1,2,7
	INV4	3,-1,3,0,4,5

;	cockpit

	INV4	3,-1,2,3,9,8
	RET

pvcube
	DC.W	8
	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40

fvcube
	;faces internes

	INV4	0,-1,5,1,0,4
	INV4	0,-1,0,3,7,4
	INV4	1,-1,3,2,6,7
	INV4	1,-1,2,1,5,6

	;faces externes

	INV4	2,-1,5,4,0,1
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	3,-1,2,6,5,1
	RET

prcube
	DC.W	8
	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40

frcube
	;faces externes

	INV4	0,-1,1,0,3,2
	INV4	1,-1,5,6,7,4
	INV4	2,-1,5,4,0,1
	INV4	0,-1,0,4,7,3
	INV4	1,-1,3,7,6,2
	INV4	2,-1,2,6,5,1
	RET

BIG	MACRO
	DC.W	\1*2,\2*2,\3*2
	ENDM
pmine
	dc.w	9
	BIG	-10,20,0
	BIG	10,20,0
	BIG	20,10,0
	BIG	20,-10,0
	BIG	10,-20,0
	BIG	-10,-20,0
	BIG	-20,-10,0
	BIG	-20,10,0
	BIG	0,0,30
fmine
	INV3	0,-1,0,1,8
	INV3	1,-1,2,3,8
	INV3	0,-1,4,5,8
	INV3	1,-1,6,7,8
	INV3	2,-1,0,8,1
	INV3	3,-1,2,8,3
	INV3	2,-1,4,8,5
	INV3	3,-1,6,8,7
	RET

ptorus
	dc.w	24

	BIG	-10,20,5
	BIG	10,20,5
	BIG	20,10,5
	BIG	20,-10,5
	BIG	10,-20,5
	BIG	-10,-20,5
	BIG	-20,-10,5
	BIG	-20,10,5

	BIG	-15,35,0
	BIG	15,35,0
	BIG	35,15,0
	BIG	35,-15,0
	BIG	15,-35,0
	BIG	-15,-35,0
	BIG	-35,-15,0
	BIG	-35,15,0

	BIG	-10,20,-5
	BIG	10,20,-5
	BIG	20,10,-5
	BIG	20,-10,-5
	BIG	10,-20,-5
	BIG	-10,-20,-5
	BIG	-20,-10,-5
	BIG	-20,10,-5

ftorus

	;faces internes

	INV4	0,-1,16,0,7,23
	INV4	1,-1,17,1,0,16
	INV4	0,-1,18,2,1,17
	INV4	1,-1,19,3,2,18
	INV4	0,-1,20,4,3,19
	INV4	1,-1,21,5,4,20
	INV4	0,-1,22,6,5,21
	INV4	1,-1,23,7,6,22
	INV4	0,-1,16,0,7,23

	;faces dessus

	INV4	2,-1,0,1,9,8
	INV4	3,-1,1,2,10,9
	INV4	2,-1,2,3,11,10
	INV4	3,-1,3,4,12,11
	INV4	2,-1,4,5,13,12
	INV4	3,-1,5,6,14,13
	INV4	2,-1,6,7,15,14
	INV4	3,-1,7,0,8,15

	;faces dessous

	INV4	2,-1,9,17,16,8
	INV4	3,-1,10,18,17,9
	INV4	2,-1,11,19,18,10
	INV4	3,-1,12,20,19,11
	INV4	2,-1,13,21,20,12
	INV4	3,-1,14,22,21,13
	INV4	2,-1,15,23,22,14
	INV4	3,-1,8,16,23,15
	RET

pchiffre8
	dc.w	14

	BIG	-20,30,0
	BIG	20,30,0
	BIG	-10,20,0
	BIG	10,20,0
	BIG	-10,5,0
	BIG	10,5,0
	BIG	-20,0,0
	BIG	20,0,0
	BIG	-10,-5,0
	BIG	10,-5,0
	BIG	-10,-20,0
	BIG	10,-20,0
	BIG	-20,-30,0
	BIG	20,-30,0

fchiffre8
	INV4	0,-1,1,0,2,3
	INV4	0,-1,0,6,4,2
	INV4	0,-1,1,3,5,7
	INV6	0,-1,5,4,6,8,9,7
	INV4	0,-1,6,12,10,8
	INV4	0,-1,9,11,13,7
	INV4	0,-1,10,12,13,11
	RET

plettrea
	dc.w	11

	BIG	-5,20,5
	BIG	5,20,5
	BIG	0,10,5
	BIG	-8,-5,5
	BIG	8,-5,5
	BIG	-10,-10,5
	BIG	10,-10,5
	BIG	-25,-20,5
	BIG	-15,-20,5
	BIG	15,-20,5
	BIG	25,-20,5

flettrea
	INV4	0,-1,0,7,8,1
	INV4	0,-1,9,10,1,0
	INV4	0,-1,3,5,6,4

	INV4	1,-1,0,1,8,7
	INV4	1,-1,9,0,1,10
	INV4	1,-1,3,4,6,5
	RET

pdalle
	dc.w	4
	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	-50,50,0

fdalle
	INV4	0,-1,3,2,1,0
	INV4	1,-1,0,1,2,3
	RET

puncube
	dc.w	8

	DC.W	-35,35,15
	DC.W	-5,35,15
	DC.W	-5,5,15
	DC.W	-35,5,15
	DC.W	-35,35,-15
	DC.W	-5,35,-15
	DC.W	-5,5,-15
	DC.W	-35,5,-15

funcube
	INV4	0,-1,1,2,6,5
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	1,-1,4,5,6,7
	RET

pdeuxcube
	dc.w	16

	DC.W	-40,40,15
	DC.W	-10,40,15
	DC.W	-10,10,15
	DC.W	-40,10,15
	DC.W	-40,40,-15
	DC.W	-10,40,-15
	DC.W	-10,10,-15
	DC.W	-40,10,-15

	DC.W	10,40,15
	DC.W	40,40,15
	DC.W	40,10,15
	DC.W	10,10,15
	DC.W	10,40,-15
	DC.W	40,40,-15
	DC.W	40,10,-15
	DC.W	10,10,-15

fdeuxcube
	INV4	0,-1,1,2,6,5
	INV4	0,-1,8,12,15,11
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	0,-1,4,5,6,7		;6
	INV4	1,-1,11,10,9,8
	INV4	0,-1,9,13,12,8
	INV4	3,-1,11,15,14,10
	INV4	0,-1,12,13,14,15	;6
	INV4	0,-1,9,10,14,13
	RET

ppyramide
	dc.w	13

	DC.W	-30,30,0
	DC.W	30,30,0
	DC.W	30,-30,0
	DC.W	-30,-30,0
	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20
	DC.W	-15,15,30
	DC.W	15,15,30
	DC.W	15,-15,30
	DC.W	-15,-15,30
	DC.W	0,0,60

fpyramide

	INV4	0,-1,7,6,5,4
	INV4	0,-1,8,9,10,11
	INV4	1,-1,0,1,2,3
	INV3	2,-1,12,9,8
	INV4	2,-1,5,1,0,4
	INV3	3,-1,12,10,9
	INV4	3,-1,6,2,1,5
	INV3	1,-1,12,11,10	;4
	INV4	2,-1,7,3,2,6	;4
	INV3	3,-1,12,8,11	;4
	INV4	1,-1,4,0,3,7	;4
	RET

pglider2
	dc.w	8

	DC.W	-20,40,0
	DC.W	20,40,0
	DC.W	-40,-40,0
	DC.W	40,-40,0
	DC.W	-20,-40,10
	DC.W	20,-40,10
	DC.W	-20,-40,-10
	DC.W	20,-40,-10

fglider2
	INV4	0,-1,0,4,5,1
	INV3	1,-1,0,2,4
	INV3	1,-1,1,5,3
	INV4	2,-1,0,1,7,6
	INV3	3,-1,0,6,2
	INV3	3,-1,1,3,7
	INV6	2,-1,4,2,6,7,3,5
	RET

DODEC	MACRO
	DC.W	\1/6/2,\2/6/2,\3/6/2
	ENDM

pdodecaedre:
	DC.W	20

	DODEC	283,631,390
	DODEC	458,631,-149
	DODEC	0,631,-482
	DODEC	-458,631,-149
	DODEC	-283,631,390
	DODEC	-458,149,631
	DODEC	0,-149,780
	DODEC	458,149,631
	DODEC	742,-149,241
	DODEC	742,149,-241
	DODEC	458,-149,-631
	DODEC	0,149,-780
	DODEC	-458,-149,-631
	DODEC	-742,149,-241
	DODEC	-742,-149,241
	DODEC	-283,-631,-390
	DODEC	-458,-631,149
	DODEC	0,-631,482
	DODEC	458,-631,149
	DODEC	283,-631,-390

fdodecaedre
	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	1,-1,1,9,10,11,2
	INV5	2,-1,2,11,12,13,3
	INV5	3,-1,3,13,14,5,4
	INV5	0,-1,12,15,16,14,13
	INV5	2,-1,14,16,17,6,5
	INV5	3,-1,6,17,18,8,7
	INV5	0,-1,8,18,19,10,9
	INV5	3,-1,11,10,19,15,12
	INV5	1,-1,17,16,15,19,18
	RET

pnscarre
	DC.W	28

	DC.W	-10,10,-30
	DC.W	10,10,-30
	DC.W	10,-10,-30
	DC.W	-10,-10,-30

	DC.W	-20,20,-20
	DC.W	20,20,-20
	DC.W	20,-20,-20
	DC.W	-20,-20,-20

	DC.W	-30,30,-10
	DC.W	30,30,-10
	DC.W	30,-30,-10
	DC.W	-30,-30,-10

	DC.W	-40,40,0
	DC.W	40,40,0
	DC.W	40,-40,0
	DC.W	-40,-40,0

	DC.W	-30,30,10
	DC.W	30,30,10
	DC.W	30,-30,10
	DC.W	-30,-30,10

	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20

	DC.W	-10,10,30
	DC.W	10,10,30
	DC.W	10,-10,30
	DC.W	-10,-10,30

fnscarre:
	INV4	0,-1,3,2,1,0
	INV4	1,-1,7,6,5,4
	INV4	2,-1,11,10,9,8
	INV4	3,-1,15,14,13,12
	INV4	2,-1,19,18,17,16
	INV4	1,-1,23,22,21,20
	INV4	0,-1,27,26,25,24

	;faces autre cote

	INV4	0,-1,24,25,26,27
	INV4	1,-1,20,21,22,23
	INV4	2,-1,16,17,18,19
	INV4	3,-1,12,13,14,15
	INV4	2,-1,8,9,10,11
	INV4	1,-1,4,5,6,7
	INV4	0,-1,0,1,2,3
	RET
DIM	MACRO
	DC.W	\1/2,\2/2,\3/2
	ENDM

picosaedre
	DC.W	12

	DIM	89,0,44
	DIM	27,85,44
	DIM	-72,52,44
	DIM	-72,-52,44
	DIM	27,-85,44
	DIM	0,0,100
	DIM	0,0,-100
	DIM	72,52,-44
	DIM	-27,85,-44
	DIM	-89,0,-44
	DIM	-27,-85,-44
	DIM	72,-52,-44
;
; BUG ICOSAEDRE :
;	SOUSTRAIRE 1 A CHAQUE NUMERO DE SOMMET !!!!
;
FAC3	MACRO
	INV3	\1,\2,(\3-1),(\4-1),(\5-1)
	ENDM
ficosaedre:
	FAC3	0,-1,1,2,6
	FAC3	1,-1,2,3,6
	FAC3	2,-1,3,4,6
	FAC3	3,-1,4,5,6
	FAC3	0,-1,5,1,6
	FAC3	1,-1,12,1,5
	FAC3	2,-1,12,8,1
	FAC3	3,-1,8,2,1
	FAC3	0,-1,9,2,8
	FAC3	1,-1,9,3,2
	FAC3	2,-1,9,10,3
	FAC3	3,-1,10,4,3
	FAC3	0,-1,10,11,4
	FAC3	1,-1,11,5,4
	FAC3	0,-1,11,12,5
	FAC3	1,-1,7,8,12
	FAC3	3,-1,7,9,8
	FAC3	0,-1,7,10,9
	FAC3	1,-1,7,11,10
	FAC3	2,-1,7,12,11
	RET

	ifeq	1
objets:
	DC.L		interph
	DC.L		helice
	DC.L		raie
	DC.L		car
	DC.L		scareface
	DC.L		grille


FACE	MACRO
	DC.W	\1*4,\2*4,\3*4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM


;---------------------------------------------------

scareface

	DC.L	pscareface
	DC.L	0
	DC.L	scareface
pscareface

	DC.W	-35,10,0
	DC.W	-15,10,0
	DC.W	15,10,0
	DC.W	35,10,0
	DC.W	-25,0,0
	DC.W	-5,0,0
	DC.W	5,0,0
	DC.W	25,0,0
	DC.W	-10,15,5
	DC.W	10,15,5
	DC.W	-35,15,5
	DC.W	35,15,5
	DC.W	-20,30,-5
	DC.W	20,30,-5
	DC.W	-15,-40,-20
	DC.W	15,-40,-20
	DC.W	-40,10,-20
	DC.W	40,10,-20
	DC.W	-15,-40,-40
	DC.W	15,-40,-40
	DC.W	-40,10,-50
	DC.W	40,10,-50

	DC.W	-20,30,-50
	DC.W	20,30,-50

	DC.W	-15,5,-60
	DC.W	15,5,-60


	DC.W	0

	DC.L	fscareface

fscareface


	;yeux

	FACE4	9,-1,1,0,4,5
	FACE4	9,-1,2,6,7,3
	FACE3	2,-1,8,1,5
	FACE3	2,-1,9,6,2
	FACE4	3,-1,10,0,1,8
	FACE4	3,-1,3,11,9,2
	FACE4	4,-1,8,5,6,9
	FACE4	5,-1,12,10,8
	FACE4	5,-1,13,9,11

	;face

	FACE	4,14,15,7
	DC.W	5*8
	DC.L	scarebouche

	FACE3	4,-1,4,0,14
	FACE3	7,-1,16,14,0
	FACE3	4,-1,7,15,3
	FACE3	7,-1,3,15,17
	FACE3	3,-1,16,0,10
	FACE3	3,-1,11,3,17
	FACE3	4,-1,10,12,16
	FACE3	4,-1,11,17,13
	FACE4	3,-1,13,12,8,9
	FACE4	3,-1,14,18,19,15
	FACE4	3,-1,16,20,18,14
	FACE4	3,-1,21,17,15,19
	FACE4	4,-1,22,12,13,23
	FACE4	5,-1,22,20,16,12

	FACE4	5,-1,23,13,17,21
	FACE4	4,-1,22,23,25,24
	FACE3	3,-1,22,24,20
	FACE3	3,-1,23,21,25
	FACE3	2,-1,20,24,18
	FACE3	2,-1,21,19,25
	FACE4	3,-1,24,25,19,18

	DC.W	-1

scarebouche
	DC.W	-10,-20,-10
	DC.W	10,-20,-10
	DC.W	10,-30,-15
	DC.W	-10,-30,-15
	DC.W	0
	FACE4	0,-1,3,2,1,0
	DC.W	-1




;------------------------------------------------------
grille:
	DC.L	pgrille
	DC.L	0
	DC.L	grille

pgrille

	DC.W	-40,-40,0
	DC.W	-20,-40,0
	DC.W	1,-40,0
	DC.W	20,-40,0
	DC.W	40,-40,0
	DC.W	-40,-20,0
	DC.W	-20,-20,0
	DC.W	1,-20,0
	DC.W	20,-20,0
	DC.W	40,-20,0
	DC.W	-40,0,0
	DC.W	-20,0,0
	DC.W	1,0,0
	DC.W	20,0,0
	DC.W	40,0,0
	DC.W	-40,20,0
	DC.W	-20,20,0
	DC.W	1,20,0
	DC.W	20,20,0
	DC.W	40,20,0
	DC.W	-40,40,0
	DC.W	-20,40,0
	DC.W	1,40,0
	DC.W	20,40,0
	DC.W	40,40,0
	DC.W	0

	DC.L	fgrille

fgrille

	FACE4	4,-1,0,5,6,1
	FACE4	3,-1,1,6,7,2
	FACE4	4,-1,2,7,8,3
	FACE4	5,-1,3,8,9,4
	FACE4	3,-1,5,10,11,6
	FACE4	4,-1,6,11,12,7
	FACE4	5,-1,7,12,13,8
	FACE4	2,-1,8,13,14,9
	FACE4	4,-1,10,15,16,11
	FACE4	5,-1,11,16,17,12
	FACE4	2,-1,12,17,18,13
	FACE4	3,-1,13,18,19,14
	FACE4	5,-1,15,20,21,16
	FACE4	2,-1,16,21,22,17
	FACE4	3,-1,17,22,23,18
	FACE4	4,-1,18,23,24,19
	FACE4	2,-1,6,5,0,1
	FACE4	3,-1,7,6,1,2
	FACE4	4,-1,8,7,2,3
	FACE4	5,-1,9,8,3,4
	FACE4	3,-1,11,10,5,6
	FACE4	4,-1,12,11,6,7
	FACE4	5,-1,13,12,7,8
	FACE4	2,-1,14,13,8,9
	FACE4	4,-1,16,15,10,11
	FACE4	5,-1,17,16,11,12
	FACE4	2,-1,18,17,12,13
	FACE4	3,-1,19,18,13,14
	FACE4	5,-1,21,20,15,16
	FACE4	2,-1,22,21,16,17
	FACE4	3,-1,23,22,17,18
	FACE4	4,-1,24,23,18,19
	DC.W	-1


	IFEQ	1

;-----------------------------------------------------------
damier:
	DC.W	-90,-90,0
	DC.W	-70,-90,0
	DC.W	-50,-90,0
	DC.W	-30,-90,0
	DC.W	-10,-90,0
	DC.W	10,-90,0
	DC.W	30,-90,0
	DC.W	50,-90,0
	DC.W	70,-90,0
	DC.W	90,-90,0
	DC.W	-90,-70,0
	DC.W	-70,-70,0
	DC.W	-50,-70,0
	DC.W	-30,-70,0
	DC.W	-10,-70,0
	DC.W	10,-70,0
	DC.W	30,-70,0
	DC.W	50,-70,0
	DC.W	70,-70,0
	DC.W	90,-70,0
	DC.W	-90,-50,0
	DC.W	-70,-50,0
	DC.W	-50,-50,0
	DC.W	-30,-50,0
	DC.W	-10,-50,0
	DC.W	10,-50,0
	DC.W	30,-50,0
	DC.W	50,-50,0
	DC.W	70,-50,0
	DC.W	90,-50,0
	DC.W	-90,-30,0
	DC.W	-70,-30,0
	DC.W	-50,-30,0
	DC.W	-30,-30,0
	DC.W	-10,-30,0
	DC.W	10,-30,0
	DC.W	30,-30,0
	DC.W	50,-30,0
	DC.W	70,-30,0
	DC.W	90,-30,0
	DC.W	-90,-10,0
	DC.W	-70,-10,0
	DC.W	-50,-10,0
	DC.W	-30,-10,0
	DC.W	-10,-10,0
	DC.W	10,-10,0
	DC.W	30,-10,0
	DC.W	50,-10,0
	DC.W	70,-10,0
	DC.W	90,-10,0
	DC.W	-90,10,0
	DC.W	-70,10,0
	DC.W	-50,10,0
	DC.W	-30,10,0
	DC.W	-10,10,0
	DC.W	10,10,0
	DC.W	30,10,0
	DC.W	50,10,0
	DC.W	70,10,0
	DC.W	90,10,0
	DC.W	-90,30,0
	DC.W	-70,30,0
	DC.W	-50,30,0
	DC.W	-30,30,0
	DC.W	-10,30,0
	DC.W	10,30,0
	DC.W	30,30,0
	DC.W	50,30,0
	DC.W	70,30,0
	DC.W	90,30,0
	DC.W	-90,50,0
	DC.W	-70,50,0
	DC.W	-50,50,0
	DC.W	-30,50,0
	DC.W	-10,50,0
	DC.W	10,50,0
	DC.W	30,50,0
	DC.W	50,50,0
	DC.W	70,50,0
	DC.W	90,50,0
	DC.W	-90,70,0
	DC.W	-70,70,0
	DC.W	-50,70,0
	DC.W	-30,70,0
	DC.W	-10,70,0
	DC.W	10,70,0
	DC.W	30,70,0
	DC.W	50,70,0
	DC.W	70,70,0
	DC.W	90,70,0
	DC.W	-90,90,0
	DC.W	-70,90,0
	DC.W	-50,90,0
	DC.W	-30,90,0
	DC.W	-10,90,0
	DC.W	10,90,0
	DC.W	30,90,0
	DC.W	50,90,0
	DC.W	70,90,0
	DC.W	90,90,0
	DC.W	0

	FACE4	3,-1,1,11,12,2
	FACE4	5,-1,3,13,14,4
	FACE4	7,-1,5,15,16,6
	FACE4	9,-1,7,17,18,8
	FACE4	11,-1,10,20,21,11
	FACE4	13,-1,12,22,23,13
	FACE4	15,-1,14,24,25,15
	FACE4	2,-1,16,26,27,17
	FACE4	4,-1,18,28,29,19
	FACE4	6,-1,21,31,32,22
	FACE4	8,-1,23,33,34,24
	FACE4	10,-1,25,35,36,26
	FACE4	12,-1,27,37,38,28
	FACE4	14,-1,30,40,41,31
	FACE4	1,-1,32,42,43,33
	FACE4	3,-1,34,44,45,35
	FACE4	5,-1,36,46,47,37
	FACE4	7,-1,38,48,49,39
	FACE4	9,-1,41,51,52,42
	FACE4	11,-1,43,53,54,44
	FACE4	13,-1,45,55,56,46
	FACE4	15,-1,47,57,58,48
	FACE4	2,-1,50,60,61,51
	FACE4	4,-1,52,62,63,53
	FACE4	6,-1,54,64,65,55
	FACE4	8,-1,56,66,67,57
	FACE4	10,-1,58,68,69,59
	FACE4	12,-1,61,71,72,62
	FACE4	14,-1,63,73,74,64
	FACE4	1,-1,65,75,76,66
	FACE4	3,-1,67,77,78,68
	FACE4	5,-1,70,80,81,71
	FACE4	7,-1,72,82,83,73
	FACE4	9,-1,74,84,85,75
	FACE4	11,-1,76,86,87,77
	FACE4	13,-1,78,88,89,79
	FACE4	15,-1,81,91,92,82
	FACE4	2,-1,83,93,94,84
	FACE4	4,-1,85,95,96,86
	FACE4	6,-1,87,97,98,88
	DC.W	-1


	ENDC



palette
	DC.W	$000,$777,$770,$777,$504,$777,$770,$777
	DC.W	$007,$777,$770,$777,$504,$777,$770,$777
palette2:
	DC.W	$000,$FF0,$013,$024,$035,$046,$057,$700
	DC.W	$720,$740,$760,$770,$212,$434,$656,$777

;--------------------------------------------------------


	EVEN

helice:
	DC.L	phelice1
	DC.L	phelice3
	DC.L	phelice5
	DC.L	phelice7
	DC.L	phelice9
	DC.L	phelice11
	DC.L	phelice13
	DC.L	phelice15
	DC.L	phelice17
	DC.L	phelice19
	DC.L	phelice21
	DC.L	phelice23
	DC.L	phelice25
	DC.L	phelice27
	DC.L	phelice29
	DC.L	0
	DC.L	helice
phelice1
	DC.W	50,5,0
	DC.W	50,-5,0
	DC.W	5,-50,0
	DC.W	-5,-50,0
	DC.W	-50,-5,0
	DC.W	-50,5,0
	DC.W	-5,50,0
	DC.W	5,50,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice3
	DC.W	49,10,0
	DC.W	50,0,0
	DC.W	10,-49,0
	DC.W	1,-50,0
	DC.W	-49,-10,0
	DC.W	-50,0,0
	DC.W	-10,49,0
	DC.W	1,50,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice5
	DC.W	47,15,0
	DC.W	49,5,0
	DC.W	15,-47,0
	DC.W	5,-49,0
	DC.W	-47,-15,0
	DC.W	-49,-5,0
	DC.W	-15,47,0
	DC.W	-5,49,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice7
	DC.W	46,20,0
	DC.W	49,10,0
	DC.W	20,-46,0
	DC.W	10,-49,0
	DC.W	-46,-20,0
	DC.W	-49,-10,0
	DC.W	-20,46,0
	DC.W	-10,49,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice9
	DC.W	43,24,0
	DC.W	47,15,0
	DC.W	24,-43,0
	DC.W	15,-47,0
	DC.W	-43,-24,0
	DC.W	-47,-15,0
	DC.W	-24,43,0
	DC.W	-15,47,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice11
	DC.W	40,29,0
	DC.W	45,20,0
	DC.W	29,-40,0
	DC.W	20,-45,0
	DC.W	-40,-29,0
	DC.W	-45,-20,0
	DC.W	-29,40,0
	DC.W	-20,45,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice13
	DC.W	37,33,0
	DC.W	43,25,0
	DC.W	33,-37,0
	DC.W	25,-43,0
	DC.W	-37,-33,0
	DC.W	-43,-25,0
	DC.W	-33,37,0
	DC.W	-25,43,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice15
	DC.W	33,37,0
	DC.W	40,29,0
	DC.W	37,-33,0
	DC.W	29,-40,0
	DC.W	-33,-37,0
	DC.W	-40,-29,0
	DC.W	-37,33,0
	DC.W	-29,40,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice17
	DC.W	29,40,0
	DC.W	37,33,0
	DC.W	40,-29,0
	DC.W	33,-37,0
	DC.W	-29,-40,0
	DC.W	-37,-33,0
	DC.W	-40,29,0
	DC.W	-33,37,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice19
	DC.W	25,43,0
	DC.W	33,37,0
	DC.W	43,-25,0
	DC.W	37,-33,0
	DC.W	-25,-43,0
	DC.W	-33,-37,0
	DC.W	-43,25,0
	DC.W	-37,33,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice21
	DC.W	20,45,0
	DC.W	29,40,0
	DC.W	45,-20,0
	DC.W	40,-29,0
	DC.W	-20,-45,0
	DC.W	-29,-40,0
	DC.W	-45,20,0
	DC.W	-40,29,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice23
	DC.W	15,47,0
	DC.W	24,43,0
	DC.W	47,-15,0
	DC.W	43,-24,0
	DC.W	-15,-47,0
	DC.W	-24,-43,0
	DC.W	-47,15,0
	DC.W	-43,24,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice25
	DC.W	10,49,0
	DC.W	20,46,0
	DC.W	49,-10,0
	DC.W	46,-20,0
	DC.W	-10,-49,0
	DC.W	-20,-46,0
	DC.W	-49,10,0
	DC.W	-46,20,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice27
	DC.W	5,49,0
	DC.W	15,47,0
	DC.W	49,-5,0
	DC.W	47,-15,0
	DC.W	-5,-49,0
	DC.W	-15,-47,0
	DC.W	-49,5,0
	DC.W	-47,15,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice29
	DC.W	1,50,0
	DC.W	10,49,0
	DC.W	50,0,0
	DC.W	49,-10,0
	DC.W	1,-50,0
	DC.W	-10,-49,0
	DC.W	-50,0,0
	DC.W	-49,10,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
fhelice:

	;helice interne

	FACE3	11,-1,1,8,0
	FACE3	11,-1,7,8,6
	FACE3	11,-1,5,8,4
	FACE3	11,-1,3,8,2

	;face internes

	FACE3	4,-1,9,8,10
	FACE3	4,-1,11,8,12
	FACE3	5,-1,12,8,9
	FACE3	5,-1,10,8,11

	;helice externe

	FACE3	11,-1,0,8,1
	FACE3	11,-1,6,8,7
	FACE3	11,-1,4,8,5
	FACE3	11,-1,2,8,3

	FACE4	6,-1,9,10,11,12

	DC.W	-1


raie:
	DC.L	praie1
	DC.L	praie2
	DC.L	praie3
	DC.L	praie4
	DC.L	praie5
	DC.L	praie6
	DC.L	praie7
	DC.L	praie8
	DC.L	praie9
	DC.L	praie10
	DC.L	praie11
	DC.L	praie12
	DC.L	praie13
	DC.L	praie14
	DC.L	praie15
	DC.L	praie16
	DC.L	praie17
	DC.L	praie18
	DC.L	praie19
	DC.L	praie20
	DC.L	praie21
	DC.L	praie22
	DC.L	praie23
	DC.L	praie24
	DC.L	0
	DC.L	raie
praie1
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-22
	DC.W	-30,10,-9
	DC.W	-30,-10,-9
	DC.W	30,10,-9
	DC.W	30,-10,-9
	DC.W	50,0,-22
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie2
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-23
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-23
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie3
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-24
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-24
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie4
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-25
	DC.W	-30,10,-7
	DC.W	-30,-10,-7
	DC.W	30,10,-7
	DC.W	30,-10,-7
	DC.W	50,0,-25
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie5
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-24
	DC.W	-30,10,-6
	DC.W	-30,-10,-6
	DC.W	30,10,-6
	DC.W	30,-10,-6
	DC.W	50,0,-24
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie6
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-23
	DC.W	-30,10,-5
	DC.W	-30,-10,-5
	DC.W	30,10,-5
	DC.W	30,-10,-5
	DC.W	50,0,-23
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie7
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-22
	DC.W	-30,10,-4
	DC.W	-30,-10,-4
	DC.W	30,10,-4
	DC.W	30,-10,-4
	DC.W	50,0,-22
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie8
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-20
	DC.W	-30,10,-2
	DC.W	-30,-10,-2
	DC.W	30,10,-2
	DC.W	30,-10,-2
	DC.W	50,0,-20
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie9
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-17
	DC.W	-30,10,-1
	DC.W	-30,-10,-1
	DC.W	30,10,-1
	DC.W	30,-10,-1
	DC.W	50,0,-17
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie10
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-15
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-15
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie11
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-12
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-12
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie12
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-10
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-10
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie13
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-7
	DC.W	-30,10,1
	DC.W	-30,-10,1
	DC.W	30,10,1
	DC.W	30,-10,1
	DC.W	50,0,-7
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie14
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-6
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-6
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie15
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-5
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-5
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie16
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-5
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-5
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie17
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-5
	DC.W	-30,10,-1
	DC.W	-30,-10,-1
	DC.W	30,10,-1
	DC.W	30,-10,-1
	DC.W	50,0,-5
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie18
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-6
	DC.W	-30,10,-2
	DC.W	-30,-10,-2
	DC.W	30,10,-2
	DC.W	30,-10,-2
	DC.W	50,0,-6
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie19
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-7
	DC.W	-30,10,-3
	DC.W	-30,-10,-3
	DC.W	30,10,-3
	DC.W	30,-10,-3
	DC.W	50,0,-7
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie20
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-9
	DC.W	-30,10,-5
	DC.W	-30,-10,-5
	DC.W	30,10,-5
	DC.W	30,-10,-5
	DC.W	50,0,-9
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie21
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-12
	DC.W	-30,10,-6
	DC.W	-30,-10,-6
	DC.W	30,10,-6
	DC.W	30,-10,-6
	DC.W	50,0,-12
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie22
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-14
	DC.W	-30,10,-7
	DC.W	-30,-10,-7
	DC.W	30,10,-7
	DC.W	30,-10,-7
	DC.W	50,0,-14
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie23
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-17
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-17
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie24
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-19
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-19
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie


fraie:

	; ailes dessous

	FACE4	3,-1,0,3,6,5
	FACE4	3,-1,7,8,2,1
	FACE3	2,-1,5,6,4
	FACE3	2,-1,9,8,7

	; corps

 	FACE3	1,-1,2,3,10
	FACE4	3,-1,10,3,0,11
	FACE4	3,-1,11,1,2,10
	FACE3	2,-1,12,11,0
	FACE3	2,-1,12,1,11
	FACE3	8,-1,1,12,0

	; dessus

	FACE4	5,-1,3,2,1,0
	FACE4	4,-1,0,5,6,3
	FACE4	4,-1,7,1,2,8
	FACE3	3,-1,5,4,6
	FACE3	3,-1,9,7,8

	DC.W	-1



interph
	DC.L	pinterph0
	DC.L	pinterph1
	DC.L	pinterph2
	DC.L	pinterph3
	DC.L	pinterph4
	DC.L	pinterph5
	DC.L	pinterph6
	DC.L	pinterph7
	DC.L	pinterph8
	DC.L	pinterph9
	DC.L	pinterph10
	DC.L	pinterph11
	DC.L	pinterph12
	DC.L	pinterph13
	DC.L	pinterph14
	DC.L	pinterph15
	DC.L	pinterph16
	DC.L	pinterph17
	DC.L	pinterph18
	DC.L	pinterph19
	DC.L	pinterph20
	DC.L	pinterph19
	DC.L	pinterph18
	DC.L	pinterph17
	DC.L	pinterph16
	DC.L	pinterph15
	DC.L	pinterph14
	DC.L	pinterph13
	DC.L	pinterph12
	DC.L	pinterph11
	DC.L	pinterph10
	DC.L	pinterph9
	DC.L	pinterph8
	DC.L	pinterph7
	DC.L	pinterph6
	DC.L	pinterph5
	DC.L	pinterph4
	DC.L	pinterph3
	DC.L	pinterph2
	DC.L	pinterph1
	DC.L	0
	DC.L	interph
pinterph0
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,10
	DC.W	20,0,10
	DC.W	0
	DC.L	finterph
pinterph1
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,12
	DC.W	20,0,12
	DC.W	0
	DC.L	finterph
pinterph2
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,14
	DC.W	20,0,14
	DC.W	0
	DC.L	finterph
pinterph3
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,16
	DC.W	20,0,16
	DC.W	0
	DC.L	finterph
pinterph4
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,18
	DC.W	20,0,18
	DC.W	0
	DC.L	finterph
pinterph5
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,20
	DC.W	20,0,20
	DC.W	0
	DC.L	finterph
pinterph6
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,22
	DC.W	20,0,22
	DC.W	0
	DC.L	finterph
pinterph7
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,24
	DC.W	20,0,24
	DC.W	0
	DC.L	finterph
pinterph8
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,26
	DC.W	20,0,26
	DC.W	0
	DC.L	finterph
pinterph9
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,28
	DC.W	20,0,28
	DC.W	0
	DC.L	finterph
pinterph10
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,30
	DC.W	20,0,30
	DC.W	0
	DC.L	finterph
pinterph11
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,32
	DC.W	20,0,32
	DC.W	0
	DC.L	finterph
pinterph12
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,34
	DC.W	20,0,34
	DC.W	0
	DC.L	finterph
pinterph13
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,36
	DC.W	20,0,36
	DC.W	0
	DC.L	finterph
pinterph14
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,38
	DC.W	20,0,38
	DC.W	0
	DC.L	finterph
pinterph15
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,40
	DC.W	20,0,40
	DC.W	0
	DC.L	finterph
pinterph16
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,42
	DC.W	20,0,42
	DC.W	0
	DC.L	finterph
pinterph17
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,44
	DC.W	20,0,44
	DC.W	0
	DC.L	finterph
pinterph18
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,46
	DC.W	20,0,46
	DC.W	0
	DC.L	finterph
pinterph19
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,48
	DC.W	20,0,48
	DC.W	0
	DC.L	finterph
pinterph20
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	0
	DC.L	finterph


finterph:
	FACE4	3,-1,3,2,1,0
	FACE4	4,-1,3,7,6,2
	FACE4	4,-1,1,5,4,0
	FACE4	5,-1,0,4,7,3
	FACE4	5,-1,2,6,5,1
	FACE3	9,-1,3,0,8
	FACE3	9,-1,1,2,9
	FACE3	1,-1,10,12,11
	FACE3	1,-1,11,12,10
	FACE3	10,-1,8,0,3
	FACE3	10,-1,9,2,1
	DC.W	-1


;
; objet plus durs … impl‚menter (sous-facettes)
;
ZZCAR	MACRO
	DC.W	\1,\2+100,\3*2/3
	ENDM
ZZROU	MACRO
	DC.W	\1,\2+100,\3*3/4
	ENDM

car:
	DC.L	pcar
	DC.L	0
	DC.L	car

pcar
	; points flanc droit

	ZZCAR	-60,-25,30
	ZZCAR	-60,-25,10
	ZZCAR	-50,-25,3
	ZZCAR	65,-25,3
	ZZCAR	65,-25,10
	ZZCAR	30,-25,30

	; points flanc gauche

	ZZCAR	-60,25,30
	ZZCAR	-60,25,10
	ZZCAR	-50,25,3
	ZZCAR	65,25,3
	ZZCAR	65,25,10
	ZZCAR	30,25,30


	; point cockpit droit bas

	ZZCAR	-45,-25,30
	ZZCAR	-25,-25,30
	ZZCAR	-5,-25,30

	; point cockpit gauche bas

	ZZCAR	-45,25,30
	ZZCAR	-25,25,30
	ZZCAR	-5,25,30

	; point cockpit droit haut

	ZZCAR	-30,-20,45
	ZZCAR	-20,-20,45
	ZZCAR	-10,-20,45

	; point cockpit gauche haut

	ZZCAR	-30,20,45
	ZZCAR	-20,20,45
	ZZCAR	-10,20,45

	DC.W	0

	DC.L	fcar

fcar

	; coffre arriere

	FACE4	3,-1,6,0,12,15

	; lunette arriere

	FACE4	5,-1,18,21,15,12

	; flanc droit

	FACE	5,0,1,2,3,4
	DC.W	2*8
	DC.L	roued

	; flanc gauche

	FACE	7,6,11,10,9,8
	DC.W	2*8
 	DC.L	roueg

	; capot

	FACE4	3,-1,11,5,4,10

	; calandre

	FACE4	4,-1,10,4,3,9

	; feux arriere

	FACE	1,0,6,7
	DC.W	4*8
	DC.L	feuxar

	; bas de caisse arriŠre

	FACE4	5,-1,2,1,7,8

	; pare brise

	FACE4	5,-1,20,5,11,23

	; pare brise droit

	FACE3	4,-1,20,14,5

	; pare brise gauche

	FACE3	4,-1,23,11,17

	; lunette droit

	FACE4	4,-1,18,12,13,19

	; lunette gauche

	FACE4	4,-1,21,22,16,15

	; lunette toit

	FACE4	5,-1,18,19,22,21

	; toit cockpit

	FACE4	3,-1,19,20,23,22

	; cockpit droit

	FACE4	3,-1,13,14,20,19

	; cockpit gauche

	FACE4	3,-1,22,23,17,16

	; bas de caisse

;	FACE4	4,-1,3,2,8,9

	DC.W	-1

feuxar
	ZZCAR	-60,-22,15
	ZZCAR	-60,-22,25
	ZZCAR	-60,22,15
	ZZCAR	-60,22,25
	ZZCAR	-60,-15,15
	ZZCAR	-60,-15,25
	ZZCAR	-60,15,15
	ZZCAR	-60,15,25
	DC.W	0

	FACE4	7,-1,0,1,5,4
	FACE4	7,-1,6,7,3,2
	DC.W	-1


roued
	; roues arriere droite

	ZZROU	-45,-25,0
	ZZROU	-35,-25,0
	ZZROU	-30,-25,5
	ZZROU	-30,-25,15
	ZZROU	-35,-25,20
	ZZROU	-45,-25,20
	ZZROU	-50,-25,15
	ZZROU	-50,-25,5

	ZZROU	-45+70,-25,0
	ZZROU	-35+70,-25,0
	ZZROU	-30+70,-25,5
	ZZROU	-30+70,-25,15
	ZZROU	-35+70,-25,20
	ZZROU	-45+70,-25,20
	ZZROU	-50+70,-25,15
	ZZROU	-50+70,-25,5
	DC.W	0

	FACE8	15,-1,0,1,2,3,4,5,6,7
	FACE8	15,-1,8,9,10,11,12,13,14,15
	DC.W	-1

roueg
	; roues arriere droite

	ZZROU	-45,25,0
	ZZROU	-35,25,0
	ZZROU	-30,25,5
	ZZROU	-30,25,15
	ZZROU	-35,25,20
	ZZROU	-45,25,20
	ZZROU	-50,25,15
	ZZROU	-50,25,5

	ZZROU	-45+70,25,0
	ZZROU	-35+70,25,0
	ZZROU	-30+70,25,5
	ZZROU	-30+70,25,15
	ZZROU	-35+70,25,20
	ZZROU	-45+70,25,20
	ZZROU	-50+70,25,15
	ZZROU	-50+70,25,5
	DC.W	0

	FACE8	15,-1,7,6,5,4,3,2,1,0
	FACE8	15,-1,15,14,13,12,11,10,9,8
	DC.W	-1


	endc


spider:
	FACE3	0,-1,2,0,3
	FACE4	1,-1,0,1,4,3
	FACE3	2,-1,1,5,4
	FACE4	3,-1,2,3,7,6
	FACE4	0,-1,3,4,8,7
	FACE4	1,-1,4,5,9,8
	FACE3	2,-1,6,7,10
	FACE4	3,-1,7,8,11,10
	FACE3	0,-1,8,9,11
	FACE4	1,-1,12,0,2,14
	FACE4	2,-1,12,13,1,0
	FACE4	3,-1,5,1,13,15
	FACE4	0,-1,9,5,15,17
	FACE4	1,-1,11,9,17,19
	FACE4	2,-1,10,11,19,18
	FACE4	3,-1,6,10,18,16
	FACE4	0,-1,2,6,16,14
	FACE4	1,-1,20,21,13,12
	FACE3	2,-1,12,14,20
	FACE3	3,-1,20,14,16
	FACE3	0,-1,20,16,18
	FACE4	1,-1,18,19,21,20
	FACE3	2,-1,21,19,17
	FACE3	3,-1,15,21,17
	FACE3	0,-1,13,21,15
	RET

spacecraft
	FACE4	0,-1,0,1,4,3	;ABED
	FACE3	1,-1,1,5,4,-1	;BFE
	FACE3	1,-1,0,3,2,-1	;ADC
	FACE3	2,-1,5,1,7,-1	;FBH
	FACE3	2,-1,6,0,2,-1	;GAC
	FACE4	0,-1,6,7,1,0	;GHBA
	FACE4	3,-1,3,4,7,6	;DEHG
	FACE3	0,-1,2,3,6,-1	;CDG
	FACE3	0,-1,4,5,7,-1	;EFH
	RET
;
; affichage d'un cube
;
cube:
	TEST	0,1,2,3,not0

	AFF4	0,$055,0,1,2,3
	SKIP	not1
not0
	FACE4	0,$022,7,6,5,4
not1
	TEST	0,3,7,4,not2
	AFF4	1,$066,0,3,7,4
	SKIP	not3
not2
	FACE4	1,$033,2,1,5,6
not3
	TEST	3,2,6,7,not4
	AFF4	2,$077,3,2,6,7
	SKIP	not5
not4
	FACE4	2,$044,0,4,5,1
not5
	RET
;
; affichage d'un t‚traŠdre
;
tetraedre:
	FACE3	0,-1,0,2,1
	FACE3	1,-1,0,3,2
	FACE3	2,-1,0,1,3
	FACE3	3,-1,1,2,3
	RET
grille:
	INITDRAW
;	TEST	0,5,6,1,laba0
	TEST	0,20,24,4,laba0

;	AFF4	0,$700,0,20,24,4

	AFF4	0,$700,0,5,6,1
	AFF4	0,-1,8,13,14,9
	AFF4	0,-1,12,17,18,13
	AFF4	0,-1,16,21,22,17

	AFF4	1,$070,1,6,7,2
	AFF4	2,$007,2,7,8,3
	AFF4	3,$777,3,8,9,4
	AFF4	1,-1,5,10,11,6
	AFF4	2,-1,6,11,12,7
	AFF4	3,-1,7,12,13,8
	AFF4	2,-1,10,15,16,11
	AFF4	3,-1,11,16,17,12
	AFF4	1,-1,13,18,19,14
	AFF4	3,-1,15,20,21,16
	AFF4	1,-1,17,22,23,18
	AFF4	2,-1,18,23,24,19
	RET
laba0:
;	AFF4	0,$777,0,4,24,20

	AFF4	0,$777,0,1,6,5
	AFF4	0,-1,8,9,14,13
	AFF4	0,-1,12,13,18,17
	AFF4	0,-1,16,17,22,21

	AFF4	1,$007,1,2,7,6
	AFF4	2,$070,2,3,8,7
	AFF4	3,$700,3,4,9,8
	AFF4	1,-1,5,6,11,10
	AFF4	2,-1,6,7,12,11
	AFF4	3,-1,7,8,13,12
	AFF4	2,-1,10,11,16,15
	AFF4	3,-1,11,12,17,16
	AFF4	1,-1,13,14,19,18
	AFF4	3,-1,15,16,21,20
	AFF4	1,-1,17,18,23,22
	AFF4	2,-1,18,19,24,23
	RET

RED	MACRO
	DC.W	\1/2,\2/2,\3/2
	ENDM
		* Exemple de forme 3D ---> un cube
coords_cube2:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
cube2:
	INV4	0,-1,4,5,6,7
	INV4	1,-1,7,6,2,3
	INV4	2,-1,0,1,5,4
	INV4	0,-1,4,7,3,0
	INV4	1,-1,1,2,6,5
	INV4	2,-1,3,2,1,0
	RET

coords_cube3:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
cube3:
	INV4	0,-1,3,7,4,0
	INV4	1,-1,0,4,5,1
	INV4	0,-1,1,5,6,2
	INV4	1,-1,2,6,7,3
	INV4	2,-1,0,4,7,3
	INV4	3,-1,1,5,4,0
	INV4	2,-1,2,6,5,1
	INV4	3,-1,3,7,6,2
	RET

coords_pyramide:
	dc.w	5
	RED	0,150,0
	RED	-100,0,-100
	RED	100,0,-100
	RED	100,0,100
	RED	-100,0,100
pyramide:
	INV3	0,-1,0,2,1
	INV3	1,-1,0,3,2
	INV3	2,-1,0,4,3
	INV3	3,-1,0,1,4
	INV4	0,-1,1,2,3,4
	RET

coords_carre:
	dc.w	4
	RED	-100,-100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,-100,-100
carre:
	INV4	0,-1,0,1,2,3
	INV4	0,-1,3,2,1,0
	RET

coords_alliance:
	dc.w	22		;22 points.
	RED	-32,80,-32	;Points No 0
	RED	-32,80,32	;Points No 1
	RED	32,80,-32	;Points No 2
	RED	32,80,32	;Points No 3
	RED	112,-80,-32	;Points No 4
	RED	112,-80,32	;Points No 5
	RED	48,-80,-32	;Points No 6
	RED	48,-80,32	;Points No 7
	RED	32,-48,-32	;Points No 8
	RED	32,-48,32	;Points No 9
	RED	-32,-48,-32	;Points No 10
	RED	-32,-48,32	;Points No 11
	RED	-48,-80,-32	;Points No 12
	RED	-48,-80,32	;Points No 13
	RED	-112,-80,-32	;Points No 14
	RED	-112,-80,32	;Points No 15
	RED	-16,-16,-32	;Points No 16
	RED	-16,-16,32	;Points No 17
	RED	16,-16,-32	;Points No 18
	RED	16,-16,32	;Points No 19
	RED	0,16,-32	;Points No 20
	RED	0,16,32		;Points No 21

alliance:
	INV4	0,-1,19,21,20,18
	INV4	1,-1,21,17,16,20
	INV4	0,-1,17,19,18,16
	INV4	1,-1,1,3,2,0
	INV4	1,-1,5,7,6,4
	INV4	1,-1,9,11,10,8
	INV4	1,-1,13,15,14,12
	INV4	0,-1,3,5,4,2
	INV4	0,-1,7,9,8,6
	INV4	0,-1,11,13,12,10
	INV4	0,-1,15,1,0,14
	INV4	2,-1,16,18,8,10
;	INV7	2,-1,0,2,20,16,10,12,14
	FACE7	2,-1,20,2,0,14,12,10,16

;	INV6	2,-1,2,4,6,8,18,20
	FACE6	2,-1,6,4,2,20,18,8

	INV4	3,-1,11,9,19,17
;	INV7	3,-1,1,15,13,11,17,21,3
	FACE7	3,-1,13,15,1,3,21,17,11

;	INV6	3,-1,7,5,3,21,19,9
	FACE6	3,-1,3,5,7,9,19,21
	RET

coords_craft:
	dc.w	14		;14 points.
	RED	0,0,100		;Points No 0
	RED	0,10,10		;Points No 1
	RED	0,-10,10	;Points No 2
	RED	-21,0,10	;Points No 3
	RED	19,0,10		;Points No 4
	RED	0,19,-21	;Points No 5
	RED	0,12,-100	;Points No 6
	RED	0,-6,-100	;Points No 7
	RED	-12,0,-100	;Points No 8
	RED	12,0,-100	;Points No 9
	RED	-165,0,-61	;Points No 10
	RED	-168,0,-85	;Points No 11
	RED	168,0,-85	;Points No 12
	RED	168,0,-61	;Points No 13

craft:
	INV3	0,-1,3,1,5
	INV3	0,-1,1,4,5
	INV3	1,-1,3,0,1
	INV3	2,-1,0,4,1
	INV3	3,-1,2,0,3
	INV3	1,-1,2,4,0
	INV4	1,-1,8,3,5,6
	INV4	2,-1,4,9,6,5
	INV4	3,-1,7,2,3,8
	INV4	1,-1,4,2,7,9
	INV4	0,-1,9,7,8,6
	INV4	0,-1,3,8,11,10
	INV4	0,-1,4,13,12,9
	INV4	0,-1,10,11,8,3
	INV4	0,-1,9,12,13,4
	RET

DODE	MACRO
	DC.W	\1/8/2,\2/8/2,\3/8/2
	ENDM

coords_dodecaedre
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

dodecaedre:
	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	3,-1,1,9,10,11,2
	INV5	0,-1,2,11,12,13,3
	INV5	1,-1,3,13,14,5,4
	INV5	2,-1,12,15,16,14,13
	INV5	3,-1,14,16,17,6,5
	INV5	0,-1,6,17,18,8,7
	INV5	1,-1,8,18,19,10,9
	INV5	2,-1,11,10,19,15,12
	INV5	3,-1,17,16,15,19,18
	RET

;
NEWPAL	MACRO
	DC.W	$0,\1,\2,\2,\3,\3,\3,\3
	DCB.W	8,\4
	ENDM

palette1:
	NEWPAL	$756,$645,$534,$423
palette2:
	NEWPAL	$456,$345,$234,$123
palette3:
	NEWPAL	$565,$454,$343,$232
palette4:
	NEWPAL	$656,$545,$434,$323

palette5:
	NEWPAL	$067,$057,$047,$037
palette6:
	NEWPAL	$766,$755,$744,$733
palette7:
	NEWPAL	$762,$752,$742,$732
palette8:
	NEWPAL	$666,$555,$444,$333
palette9:
	NEWPAL	$457,$346,$235,$124

;palette1:DC.W	$000
;	DC.W	$700		;0001
;	DC.W	$070		;0010
;	DC.W	$770		;0011
;	DC.W	$007		;0100
;	DC.W	$707		;0101
;	DC.W	$077		;0110
;	DC.W	$777		;0111
;
;	DCB.W	8,$555

bugpal:	DC.W	$000
	DC.W	$200		;0001
	DC.W	$020		;0010
	DC.W	$770		;0011
	DC.W	$002		;0100
	DC.W	$707		;0101
	DC.W	$077		;0110
	DC.W	$777		;0111

	dc.w	$222
	DCB.W	7,$555
XYZ	MACRO
	DC.W	\1*10,\2*10,\3*20
	ENDM

coords_spacecraft
	DC.W	8
	XYZ	-2,5,0
	XYZ	2,5,0
	XYZ	-6,-5,0
	XYZ	-2,-5,1
	XYZ	2,-5,1
	XYZ	6,-5,0
	XYZ	-2,-5,-1
	XYZ	2,-5,-1

coords_spider
	DC.W	22
	DC.W	-15,  25,  0
	DC.W	 25,  30,  0
	DC.W	-65,  10,  0
	DC.W	-15,  10,  5
	DC.W	 25,  10,  5
	DC.W	 40,  10,  0
	DC.W	-65, -10,  0
	DC.W	-15, -10,  5
	DC.W	 25, -10,  5
	DC.W	 40, -10,  0
	DC.W	-15, -25,  0
	DC.W	 25, -30,  0
	DC.W	-15,  25, -5
	DC.W	 25,  30, -5
	DC.W	-75,   5, -5
	DC.W	 40,  10, -5
	DC.W	-75,  -5, -5
	DC.W	 40, -10, -5
	DC.W	-15, -25, -5
	DC.W	 25, -30, -5
	DC.W	-10,   0,-15
	DC.W	 20,   0,-15

coords_cube
	DC.W	8
	DC.W	-50,50,-50	;1
	DC.W	-50,-50,-50	;2
	DC.W	50,-50,-50	;3
	DC.W	50,50,-50	;4

	DC.W	-50,50,50	;5
	DC.W	-50,-50,50	;6
	DC.W	50,-50,50	;7
	DC.W	50,50,50	;8

coords_tetra:
	dc.w	4
	dc.w	0,50,0
	dc.w	43,-25,0
	dc.w	-43,-25,0
	dc.w	0,0,50

;	dc.w	0,50,0
;	dc.w	-50,-50,-50
;	dc.w	50,-50,-50
;	dc.w	0,-50,50

;	dc.w	50,0,0
;	dc.w	-25,37,-22
;	dc.w	-26,-37,21
;	dc.w	0,0,-50

;	dc.w	100/2,0,0
;	dc.w	14/2,-99/2,0
;	dc.w	-7/2,-99/2,12/2
;	dc.w	-7/2,-99/2,-12/2

;	dc.w	0,50,0
;	dc.w	-43,-25,-25
;	dc.w	43,-25,-25
;	dc.w	0,-25,25

coords_grille:
	DC.W	25
	DC.W	-50,-50,0
	DC.W	-25,-50,0
	DC.W	0,-50,0
	DC.W	25,-50,0
	DC.W	50,-50,0
	DC.W	-50,-25,0
	DC.W	-25,-25,0
	DC.W	0,-25,0
	DC.W	25,-25,0
	DC.W	50,-25,0
	DC.W	-50,0,0
	DC.W	-25,0,0
	DC.W	0,0,0
	DC.W	25,0,0
	DC.W	50,0,0
	DC.W	-50,25,0
	DC.W	-25,25,0
	DC.W	0,25,0
	DC.W	25,25,0
	DC.W	50,25,0
	DC.W	-50,50,0
	DC.W	-25,50,0
	DC.W	0,50,0
	DC.W	25,50,0
	DC.W	50,50,0

