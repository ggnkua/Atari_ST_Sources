objets:
	DC.L		interph
	DC.L		helice
	DC.L		nscarre
	DC.L		raie
	DC.L		dodecaedre
	DC.L		car
	DC.L		scareface
	DC.L		glider2
	DC.L		spider2
	DC.L		pyramide
	DC.L		deuxcube
	DC.L		mine
	DC.L		rcube
	DC.L		torus
	DC.L		dalle
	DC.L		lettrea
	DC.L		chiffre8
	DC.L		grille
	DC.L		vcube
	DC.L		0


FACE	MACRO
	DC.W	\1*4,\2*4,\3*4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM

spider2:

	DC.L	pspider2
	DC.L	0
	DC.L	spider2

pspider2


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


	DC.W	0

	DC.L	fspider2


fspider2

;	ailes dessous

	FACE4	5,-1,7,2,11,6
	FACE4	5,-1,4,10,3,5

;	cotes

	FACE3	4,-1,3,10,9
	FACE3	4,-1,11,2,8

;	dessous

	FACE4	3,-1,11,8,9,10

;	reacteurs

	FACE4	1,-1,10,0,1,11
	FACE3	2,-1,6,11,1
	FACE3	2,-1,4,0,10

;	dessus

	FACE4	4,-1,1,0,3,2

;	ailes dessus

	FACE4	3,-1,6,1,2,7
	FACE4	3,-1,3,0,4,5

;	cockpit

	FACE4	9,-1,2,3,9,8
	DC.W	-1

spiper2trapppe

	DC.W	-5,30,0
	DC.W	5,30,0
	DC.W	1,-10,0
	DC.W	0

	FACE3	1,-1,2,1,0
	DC.W	-1
	EVEN


vcube:
	DC.L	pvcube
	DC.L	0
	DC.L	vcube

pvcube

	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40
	DC.W	0

	DC.L	fvcube

fvcube


	;faces internes

	FACE4	3,-1,5,1,0,4
	FACE4	4,-1,0,3,7,4
	FACE4	5,-1,3,2,6,7
	FACE4	6,-1,2,1,5,6

	;faces externes

	FACE4	3,-1,5,4,0,1
	FACE4	4,-1,0,4,7,3
	FACE4	5,-1,3,7,6,2
	FACE4	6,-1,2,6,5,1

	DC.W	-1


	even


rcube:
	DC.L	prcube
	DC.L	0
	DC.L	rcube

prcube


	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40
	DC.W	0


	DC.L	frcube


frcube


	;faces externes

	FACE4	13,-1,1,0,3,2
	FACE4	15,-1,5,6,7,4
	FACE4	14,-1,5,4,0,1
	FACE4	13,-1,0,4,7,3
	FACE4	12,-1,3,7,6,2
	FACE4	11,-1,2,6,5,1
	DC.W	-1

	even

ZZCAR	MACRO
	DC.W	\1,\2+100,\3*2/3
	ENDM
ZZROU	MACRO
	DC.W	\1,\2+100,\3*3/4
	ENDM

cube

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

	; bas de caisse arriäre

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


;-----------------------------------------------------
mine:
	DC.L	pmine
	DC.L	0
	DC.L	mine
pmine
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	20,10,0
	DC.W	20,-10,0
	DC.W	10,-20,0
	DC.W	-10,-20,0
	DC.W	-20,-10,0
	DC.W	-20,10,0
	DC.W	1,1,30
	DC.W	0
	DC.L	fmine
fmine
	FACE3	10,-1,0,1,8
	FACE3	7,-1,2,3,8
	FACE3	10,-1,4,5,8
	FACE3	7,-1,6,7,8
	FACE3	3,-1,0,8,1
	FACE3	4,-1,2,8,3
	FACE3	3,-1,4,8,5
	FACE3	4,-1,6,8,7

	DC.W	-1


;---------------------------------------------------
torus

	DC.L	ptorus
	DC.L	0
	DC.L	torus

ptorus

	DC.W	-10,20,5
	DC.W	10,20,5
	DC.W	20,10,5
	DC.W	20,-10,5
	DC.W	10,-20,5
	DC.W	-10,-20,5
	DC.W	-20,-10,5
	DC.W	-20,10,5

	DC.W	-15,35,0
	DC.W	15,35,0
	DC.W	35,15,0
	DC.W	35,-15,0
	DC.W	15,-35,0
	DC.W	-15,-35,0
	DC.W	-35,-15,0
	DC.W	-35,15,0

	DC.W	-10,20,-5
	DC.W	10,20,-5
	DC.W	20,10,-5
	DC.W	20,-10,-5
	DC.W	10,-20,-5
	DC.W	-10,-20,-5
	DC.W	-20,-10,-5
	DC.W	-20,10,-5

	DC.W	0

	DC.L	ftorus

ftorus

	;faces internes

	FACE4	8,-1,16,0,7,23
	FACE4	9,-1,17,1,0,16
	FACE4	8,-1,18,2,1,17
	FACE4	9,-1,19,3,2,18
	FACE4	8,-1,20,4,3,19
	FACE4	9,-1,21,5,4,20
	FACE4	8,-1,22,6,5,21
	FACE4	9,-1,23,7,6,22
	FACE4	8,-1,16,0,7,23

	;faces dessus

	FACE4	4,-1,0,1,9,8
	FACE4	5,-1,1,2,10,9
	FACE4	4,-1,2,3,11,10
	FACE4	5,-1,3,4,12,11
	FACE4	4,-1,4,5,13,12
	FACE4	5,-1,5,6,14,13
	FACE4	4,-1,6,7,15,14
	FACE4	5,-1,7,0,8,15

	;faces dessous

	FACE4	5,-1,9,17,16,8
	FACE4	6,-1,10,18,17,9
	FACE4	5,-1,11,19,18,10
	FACE4	6,-1,12,20,19,11
	FACE4	5,-1,13,21,20,12
	FACE4	6,-1,14,22,21,13
	FACE4	5,-1,15,23,22,14
	FACE4	6,-1,8,16,23,15

	DC.W	-1


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


chiffre8:
	DC.L	pchiffre8
	DC.L	0
	DC.L	chiffre8

pchiffre8

	DC.W	-20,30,0
	DC.W	20,30,0
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	-10,5,0
	DC.W	10,5,0
	DC.W	-20,0,0
	DC.W	20,0,0
	DC.W	-10,-5,0
	DC.W	10,-5,0
	DC.W	-10,-20,0
	DC.W	10,-20,0
	DC.W	-20,-30,0
	DC.W	20,-30,0
	DC.W	0

	DC.L	fchiffre8

fchiffre8

	FACE4	9,-1,1,0,2,3
	FACE4	9,-1,0,6,4,2
	FACE4	9,-1,1,3,5,7
	FACE6	9,-1,5,4,6,8,9,7
	FACE4	9,-1,6,12,10,8
	FACE4	9,-1,9,11,13,7
	FACE4	9,-1,10,12,13,11
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

lettrea:

	DC.L	plettrea
	DC.L	0
	DC.L	lettrea

plettrea

	DC.W	-5,20,5
	DC.W	5,20,5
	DC.W	1,10,5
	DC.W	-8,-5,5
	DC.W	8,-5,5
	DC.W	-10,-10,5
	DC.W	10,-10,5
	DC.W	-25,-20,5
	DC.W	-15,-20,5
	DC.W	15,-20,5
	DC.W	25,-20,5

	DC.W	0

	DC.L	flettrea

flettrea

	FACE4	3,-1,0,7,8,1
	FACE4	3,-1,9,10,1,0
	FACE4	3,-1,3,5,6,4

	FACE4	8,-1,0,1,8,7
	FACE4	8,-1,9,0,1,10
	FACE4	8,-1,3,4,6,5

	DC.W	-1

;-----------------------------------------------------
dalle:
	DC.L	pdalle
	DC.L	0
	DC.L	dalle
pdalle


	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	-50,50,0
	DC.W	0

	DC.L	fdalle

fdalle

	FACE4	3,-1,3,2,1,0
	FACE4	7,-1,0,1,2,3
	DC.W	-1

;------------------------------------------------------
uncube
	DC.L	puncube
	DC.L	0
	DC.L	uncube
puncube
	DC.W	-35,35,15
	DC.W	-5,35,15
	DC.W	-5,5,15
	DC.W	-35,5,15
	DC.W	-35,35,-15
	DC.W	-5,35,-15
	DC.W	-5,5,-15
	DC.W	-35,5,-15

	DC.W	0

	DC.L	funcube

funcube

	FACE4	3,-1,1,2,6,5
	FACE4	2,-1,3,2,1,0
	FACE4	3,-1,1,5,4,0
	FACE4	4,-1,0,4,7,3
	FACE4	5,-1,3,7,6,2
	FACE4	2,-1,4,5,6,7

	DC.W	-1

;------------------------------------------------------
deuxcube
	DC.L	pdeuxcube
	DC.L	0
	DC.L	deuxcube
pdeuxcube



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

	DC.W	0
	DC.L	fdeuxcube
fdeuxcube



	FACE4	3,-1,1,2,6,5
	FACE4	4,-1,8,12,15,11
	FACE4	2,-1,3,2,1,0
	FACE4	3,-1,1,5,4,0
	FACE4	4,-1,0,4,7,3
	FACE4	5,-1,3,7,6,2
	FACE4	6,-1,4,5,6,7
	FACE4	2,-1,11,10,9,8
	FACE4	3,-1,9,13,12,8
	FACE4	5,-1,11,15,14,10
	FACE4	6,-1,12,13,14,15
	FACE4	3,-1,9,10,14,13

	DC.W	-1


pyramide
	DC.L	ppyramide
	DC.L	0
	DC.L	pyramide
ppyramide

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
	DC.W	1,0,60
	DC.W	0
	DC.L	fpyramide

fpyramide

	FACE4	12,-1,7,6,5,4
	FACE4	13,-1,8,9,10,11
	FACE4	5,-1,0,1,2,3
	FACE4	2,-1,12,9,8
	FACE4	2,-1,5,1,0,4
	FACE3	3,-1,12,10,9
	FACE4	3,-1,6,2,1,5
	FACE3	4,-1,12,11,10
	FACE4	4,-1,7,3,2,6
	FACE3	4,-1,12,8,11
	FACE4	4,-1,4,0,3,7

	DC.W	-1


glider2:
	DC.L	pglider2
	DC.L	0
	DC.L	glider2
pglider2


	DC.W	-20,40,0
	DC.W	20,40,0
	DC.W	-40,-40,0
	DC.W	40,-40,0
	DC.W	-20,-40,10
	DC.W	20,-40,10
	DC.W	-20,-40,-10
	DC.W	20,-40,-10
	DC.W	0
	DC.L	fglider2
fglider2

	FACE4	2,-1,0,4,5,1
	FACE3	3,-1,0,2,4
	FACE3	3,-1,1,5,3
	FACE4	4,-1,0,1,7,6
	FACE3	5,-1,0,6,2
	FACE3	5,-1,1,3,7
	FACE6	1,-1,4,2,6,7,3,5

	DC.W	-1


DODE	MACRO
	IFEQ	\1
	DC.W	1,\2/6,\3/6
	ELSEIF
	DC.W	\1/6,\2/6,\3/6
	ENDC
	ENDM


dodecaedre
	DC.L	pdodecaedre
	DC.L	0
	DC.L	dodecaedre


pdodecaedre:

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

	DC.W	0

	DC.L	fdodecaedre

fdodecaedre
	FACE5	3,-1,0,1,2,3,4
	FACE5	4,-1,0,4,5,6,7
	FACE5	5,-1,0,7,8,9,1
	FACE5	4,-1,1,9,10,11,2
	FACE5	5,-1,2,11,12,13,3
	FACE5	6,-1,3,13,14,5,4
	FACE5	3,-1,12,15,16,14,13
	FACE5	5,-1,14,16,17,6,5
	FACE5	2,-1,6,17,18,8,7
	FACE5	3,-1,8,18,19,10,9
	FACE5	6,-1,11,10,19,15,12
	FACE5	4,-1,17,16,15,19,18

	DC.W	-1


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


nscarre:
	DC.L	pnscarre
	DC.L	0
	DC.L	nscarre

pnscarre

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


	DC.W	0

	DC.L	fnscarre

fnscarre:

	FACE4	2,-1,3,2,1,0
	FACE4	3,-1,7,6,5,4
	FACE4	4,-1,11,10,9,8
	FACE4	5,-1,15,14,13,12
	FACE4	4,-1,19,18,17,16
	FACE4	3,-1,23,22,21,20
	FACE4	2,-1,27,26,25,24

	;faces autre cote

	FACE4	2,-1,24,25,26,27
	FACE4	3,-1,20,21,22,23
	FACE4	4,-1,16,17,18,19
	FACE4	5,-1,12,13,14,15
	FACE4	4,-1,8,9,10,11
	FACE4	3,-1,4,5,6,7
	FACE4	2,-1,0,1,2,3

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


icosaedre:
	DC.L	picosaedre
	DC.L	0
	DC.L	icosaedre

picosaedre
	DC.W	89,0,44
	DC.W	27,85,44
	DC.W	-72,52,44
	DC.W	-72,-52,44
	DC.W	27,-85,44
	DC.W	1,0,100
	DC.W	1,0,-100
	DC.W	72,52,-44
	DC.W	-27,85,-44
	DC.W	-89,0,-44
	DC.W	-27,-85,-44
	DC.W	72,-52,-44

	DC.W	0
	DC.L	ficosaedre

;
; BUG ICOSAEDRE :
;	SOUSTRAIRE 1 A CHAQUE NUMERO DE SOMMET !!!!
;
ficosaedre:
	FACE3	3,-1,1,2,6
	FACE3	4,-1,2,3,6
	FACE3	2,-1,3,4,6
	FACE3	5,-1,4,5,6
	FACE3	6,-1,5,1,6
	FACE3	7,-1,12,1,5
	FACE3	8,-1,12,8,1
	FACE3	9,-1,8,2,1
	FACE3	10,-1,9,2,8
	FACE3	11,-1,9,3,2
	FACE3	12,-1,9,10,3
	FACE3	13,-1,10,4,3
	FACE3	14,-1,10,11,4
	FACE3	15,-1,11,5,4
	FACE3	3,-1,11,12,5
	FACE3	4,-1,7,8,12
	FACE3	5,-1,7,9,8
	FACE3	6,-1,7,10,9
	FACE3	7,-1,7,11,10
	FACE3	8,-1,7,12,11

	DC.W	-1
