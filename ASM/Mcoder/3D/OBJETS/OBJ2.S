objets:


	DC.L		interph
	DC.W		0,2,0
	DC.W		100	
	DC.B		$38,0,0,1
	DC.W		1000


	DC.L		helice
	DC.W		1,2,3
	DC.W		100	
	DC.B		0,0,0,1
	DC.W		1000

	DC.L		interph
	DC.W		0,2,0
	DC.W		100	
	DC.B		$38,0,0,1
	DC.W		1000

	DC.L		nscarre
	DC.W		1,2,3
	DC.W		100	
	DC.B		0,0,0,1
	DC.W		1000

	DC.L		raie
	DC.W		0,2,0
	DC.W		100	
	DC.B		$3A,0,0,1
	DC.W		500

	DC.L		dodecaedre
	DC.W		1,2,3
	DC.W		90
	DC.B		$0,0,0,1
	DC.W		500

	DC.L		car
	DC.W		0,1,0
	DC.W		120	
	DC.B		$38,$40,0,1
	DC.W		500

	DC.L		scareface
	DC.W		3,2,1
	DC.W		45
	DC.B		0,0,0,4
	DC.W		300

	DC.L		glider2
	DC.W		1,2,3
	DC.W		100 
	DC.B		0,0,0,4
	DC.W		200		


	DC.L		spider2
	DC.W		1,2,3 
	DC.W		70	
	DC.B		0,0,0,1
	DC.W		300


	DC.L		pyramide
	DC.W		1,2,3
	DC.W		50	
	DC.B		0,0,$80,4
	DC.W		50

	DC.L		deuxcube
	DC.W		1,2,3
	DC.W		40	
	DC.B		0,0,$80,4
	DC.W		200

	DC.L		mine
	DC.W		1,2,3
	DC.W		255	
	DC.B		0,0,$80,2
	DC.W		100

	DC.L		rcube
	DC.W		1,2,3
	DC.W		55	
	DC.B		0,0,$80,4
	DC.W		100


	DC.L		torus
	DC.W		1,2,3
	DC.W		30
	DC.B		0,0,0,4
	DC.W		300

	DC.L		dalle
	DC.W		0,1,0
	DC.W		70	
	DC.B		0,0,0,2
	DC.W		100

	DC.L		lettrea
	DC.W		1,2,3
	DC.W		40	
	DC.B		0,0,0,4
	DC.W		200

	DC.L		chiffre8
	DC.W		0,2,0
	DC.W		290	
	DC.B		$20,0,0,-8
	DC.W		100

	DC.L		scareface
	DC.W		1,2,3
	DC.W		45
	DC.B		0,0,0,4
	DC.W		300

	DC.L		dalle
	DC.W		1,2,3
	DC.W		60	
	DC.B		0,0,0,1
	DC.W		300

	DC.L		lettrea
	DC.W		1,2,3
	DC.W		30	
	DC.B		0,0,$80,1
	DC.W		400

	DC.L		mine
	DC.W		1,2,3
	DC.W		30	
	DC.B		0,0,$80,1
	DC.W		400


	DC.L		grille
	DC.W		1,2,3
	DC.W		40
	DC.B		0,0,0,1
	DC.W		250

	DC.L		scareface
	DC.W		1,3,2
	DC.W		45
	DC.B		0,0,0,1
	DC.W		300

	DC.L		torus
	DC.W		1,2,3
	DC.W		30
	DC.B		0,0,0,1
	DC.W		300

	DC.L		spider2
	DC.W		1,2,3
	DC.W		100
	DC.B		0,0,0,1
	DC.W		200

	DC.L		car
	DC.W		0,2,0
	DC.W		140	
	DC.B		$40,0,0,1
	DC.W		0

	DC.L		vcube
	DC.W		1,2,3
	DC.W		60
	DC.B		0,0,0,$F0
	DC.W		200

	DC.L		rcube
	DC.W		1,2,3
	DC.W		60
	DC.B		0,0,0,$FF
	DC.W		200

	DC.L		0


FACE	MACRO	
	DC.W	\1*4,\2*4,\3*4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM

ICOF	MACRO	
	DC.W	\1*4-4,\2*4-4,\3*4-4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM


fildemo:
	DC.W	-45,-15,-20
	DC.W	-45,15,-20
	DC.W	-25,0,-20
	DC.W	-20,-15,-20
	DC.W	-20,0,-20
	DC.W	-20,15,-20
	DC.W	-1,-15,-20
	DC.W	-1,0,-20
	DC.W	-1,15,-20
	DC.W	5,-15,-20
	DC.W	5,15,-20
	DC.W	15,0,-20
	DC.W	25,-15,-20
	DC.W	25,15,-20
	DC.W	30,15,-20
	DC.W	30,-15,-20
	DC.W	50,15,-20
	DC.W	50,-15,-20
	DC.W	0

	DC.B	1,0,1,2,2,0
	DC.B	3,5,3,6,4,7,5,8
	DC.B	9,10,9,11,11,12,12,13
	DC.B	14,16,15,17,14,15,16,17
	DC.B	0
	EVEN

filalgernon:
	DC.W	-85,-20,0
	DC.W	-80,0,0
	DC.W	-75,15,0
	DC.W	-70,0,0
	DC.W	-65,-20,0
	DC.W	-60,15,0
	DC.W	-60,-20,0
	DC.W	-45,-20,0
	DC.W	-40,15,0
	DC.W	-40,-20,0
	DC.W	-25,15,0
	DC.W	-25,0,0
	DC.W	-25,-20,0
	DC.W	-10,15,0
	DC.W	-10,0,0
	DC.W	-10,-20,0
	DC.W	5,15,0
	DC.W	5,0,0
	DC.W	5,-20,0
	DC.W	10,15,0
	DC.W	10,0,0
	DC.W	10,-20,0
	DC.W	25,15,0
	DC.W	25,0,0
	DC.W	25,-20,0
	DC.W    30,15,0
	DC.W	30,-20,0
	DC.W    45,15,0
	DC.W	45,-20,0
	DC.W	50,15,0
	DC.W	50,-20,0
	DC.W	65,15,0
	DC.W	65,-20,0
	DC.W	70,15,0
	DC.W	70,-20,0
	DC.W	85,15,0
	DC.W	85,-20,0

	
	DC.W	0
	
	DC.B	2,0,2,4,1,3			;A
	DC.B	5,6,6,7				;L
	DC.B	8,9,8,10,9,12,11,12		;G
	DC.B	13,16,14,17,15,18,13,15		;E
	DC.B	19,22,20,23,21,19,22,23,20,24	;R
	DC.B	25,26,27,28,25,28		;N
	DC.B	29,30,31,32,29,31,30,32		;O
	DC.B	33,34,35,36,33,36		;N
	DC.B	0
	EVEN


algenon:
	DC.W	-90,20,0
	DC.W	-90,-25,0
	DC.W	90,-25,0
	DC.W	90,20,0
	DC.W	-90,20,-20
	DC.W	-90,-25,-20
	DC.W	90,-25,-20
	DC.W	90,20,-20
	DC.W	0
	
	DC.B	$FF,2,3,0,1,0,0,0,0,0
	DC.W	2*8
	DC.L	fildemo

	DC.B	$FF,4,7,6,5,0,0,0,0,0
	DC.W	2*8
	DC.L	filalgernon

	DC.B	$FF,3,2,6,7,0,0,0,0,0
	DC.W	4*8
	DC.L	0
	
	DC.B	$FF,1,0,4,5,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,1,5,6,2,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$FF,4,0,3,7,0,0,0,0,0
	DC.W	5*8
	DC.L	0
	



	DC.W	0



filcube:
	DC.W	50,50,-50
	DC.W	50,-50,-50
	DC.W	-50,-50,-50
	DC.W	-50,50,-50
	DC.W	50,50,50
	DC.W	50,-50,50
	DC.W	-50,-50,50
	DC.W	-50,50,50
	DC.W	0
	DC.B	1,0,1,2,2,3,3,0
	DC.B	4,5,5,6,6,7,7,4
	DC.B	4,0,5,1,6,2,7,3
	DC.B	0
	EVEN
	
motifa
	DC.W	1,40,0
	DC.W	40,-40,0
	DC.W	-40,-40,0
	DC.W	0
	DC.B	2,0,1,0,0
	EVEN



	DC.W	-50,50,0
	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	0

	DC.B	$FF,1,0,3,2,0,0,0,0,0
	DC.W	5*8
	DC.L	motifa
	DC.B	$FF,3,0,1,2,0,0,0,0,0
	DC.W	6*8
	DC.L	0

	DC.W	0

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

	FACE	7,2,11,6,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,10,3,5,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

;       cotes      


	FACE	3,10,9,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	11,2,8,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

;	dessous

	FACE	11,8,9,10,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

;      reacteurs

	FACE	10,0,1,11,-1,-1,-1,-1
	DC.W	1*8
	DC.L	0

	FACE	6,11,1,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	4,0,10,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0



;	dessus
	
	FACE	1,0,3,2,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

;	ailes dessus

	FACE	6,1,2,7,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	3,0,4,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

;	cockpit

	FACE	2,3,9,8,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	DC.W	-1

spiper2trapppe

	DC.W	-5,30,0
	DC.W	5,30,0
	DC.W	1,-10,0
	DC.W	0

	FACE	2,1,0,-1,-1,-1,-1,-1
	DC.W	1*8
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

	FACE	5,1,0,4,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,3,7,4,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	3,2,6,7,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	2,1,5,6,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0

	;faces externes

	FACE	5,4,0,1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,4,7,3,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	3,7,6,2,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	2,6,5,1,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0

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

	FACE	1,0,3,2,-1,-1,-1,-1,-1,-1
	DC.W	13*8
	DC.L	0

	FACE	5,6,7,4,-1,-1,-1,-1,-1,-1
	DC.W	15*8
	DC.L	0

	FACE	5,4,0,1,-1,-1,-1,-1,-1,-1
	DC.W	14*8
	DC.L	0

	FACE	0,4,7,3,-1,-1,-1,-1,-1,-1
	DC.W	13*8
	DC.L	0

	FACE	3,7,6,2,-1,-1,-1,-1,-1,-1
	DC.W	12*8
	DC.L	0

	FACE	2,6,5,1,-1,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	
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

	FACE	6,0,12,15,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0


	; lunette arriere

	FACE	18,21,15,12,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	; flanc droit	
	
	FACE	5,0,1,2,3,4,-1,-1
	DC.W	2*8
	DC.L	roued

	; flanc gauche

	FACE	7,6,11,10,9,8,-1,-1
	DC.W	2*8
 	DC.L	roueg

	; capot

	FACE	11,5,4,10,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; calandre

	FACE	10,4,3,9,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; feux arriere

	FACE	1,0,6,7,-1,-1,-1,-1
	DC.W	4*8
	DC.L	feuxar

	; bas de caisse arriäre

	FACE	2,1,7,8,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	
	; pare brise 

	FACE	20,5,11,23,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	; pare brise droit

	FACE	20,14,5,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; pare brise gauche

	FACE	23,11,17,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; lunette droit

	FACE	18,12,13,19,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; lunette gauche

	FACE	21,22,16,15,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; lunette toit

	FACE	18,19,22,21,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	; toit cockpit

	FACE	19,20,23,22,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; cockpit droit

	FACE	13,14,20,19,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; cockpit gauche

	FACE	22,23,17,16,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; bas de caisse

;	FACE	3,2,8,9,-1,-1,-1,-1
;	DC.W	4*8
;	DC.L	0

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
	FACE	0,1,5,4,-1,-1,-1,-1
	DC.W	7*8
	FACE	6,7,3,2,-1,-1,-1,-1
	DC.W	7*8
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

	FACE	0,1,2,3,4,5,6,7
	DC.W	15*8
	FACE	8,9,10,11,12,13,14,15
	DC.W	15*8
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

	FACE	7,6,5,4,3,2,1,0
	DC.W	15*8
	FACE	15,14,13,12,11,10,9,8
	DC.W	15*8
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
	FACE	0,1,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	10*8
	DC.L	0

	FACE	2,3,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0

	FACE	4,5,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	10*8
	DC.L	0

	FACE	6,7,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0

	FACE	0,8,1,-1,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	2,8,3,-1,-1,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	4,8,5,-1,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	6,8,7,-1,-1,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

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

	FACE	16,0,7,23,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	17,1,0,16,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	18,2,1,17,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	19,3,2,18,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	20,4,3,19,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	21,5,4,20,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	22,6,5,21,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	23,7,6,22,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	16,0,7,23,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0

	;faces dessus

	FACE	0,1,9,8,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	1,2,10,9,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	2,3,11,10,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	3,4,12,11,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	4,5,13,12,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	5,6,14,13,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	6,7,15,14,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	7,0,8,15,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0

	;faces dessous

	FACE	9,17,16,8,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	10,18,17,9,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0
	FACE	11,19,18,10,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	12,20,19,11,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0
	FACE	13,21,20,12,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	14,22,21,13,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0
	FACE	15,23,22,14,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	8,16,23,15,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0



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

	FACE	1,0,4,5,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0
	FACE	2,6,7,3,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0
	FACE	8,1,5,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	9,6,2,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	10,0,1,8,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	3,11,9,2,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	8,5,6,9,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	12,10,8,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	13,9,11,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	;face

	FACE	4,14,15,7,-1,-1,-1,-1
	DC.W	5*8
	DC.L	scarebouche

	FACE	4,0,14,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	16,14,0,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0


	FACE	7,15,3,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	3,15,17,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0

	FACE	16,0,10,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	11,3,17,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	10,12,16,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	11,17,13,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	13,12,8,9,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	14,18,19,15,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	16,20,18,14,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	21,17,15,19,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	22,12,13,23,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	22,20,16,12,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	23,13,17,21,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	22,23,25,24,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	22,24,20,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	23,21,25,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	20,24,18,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	21,19,25,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	24,25,19,18,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	DC.W	$FFFF

scarebouche	
	DC.W	-10,-20,-10
	DC.W	10,-20,-10
	DC.W	10,-30,-15
	DC.W	-10,-30,-15
	DC.W	0
	FACE	3,2,1,0,-1,-1,-1,-1
	DC.W	0*8
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

	FACE	1,0,2,3,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	0,6,4,2,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	1,3,5,7,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	5,4,6,8,9,7,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	6,12,10,8,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	9,11,13,7,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	10,12,13,11,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0


	DC.W	-1


;------------------------------------------------------
grille:
	DC.L	pgrille
	DC.L	0
	DC.L	grille

pgrille	

        DC.W    -40,-40,0
        DC.W    -20,-40,0
        DC.W    1,-40,0
        DC.W    20,-40,0
        DC.W    40,-40,0
        DC.W    -40,-20,0
        DC.W    -20,-20,0
        DC.W    1,-20,0
        DC.W    20,-20,0
        DC.W    40,-20,0
        DC.W    -40,0,0
        DC.W    -20,0,0
        DC.W    1,0,0
        DC.W    20,0,0
        DC.W    40,0,0
        DC.W    -40,20,0
        DC.W    -20,20,0
        DC.W    1,20,0
        DC.W    20,20,0
        DC.W    40,20,0
        DC.W    -40,40,0
        DC.W    -20,40,0
        DC.W    1,40,0
        DC.W    20,40,0
        DC.W    40,40,0
        DC.W    0

	DC.L	fgrille

fgrille


        FACE    0,5,6,1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    1,6,7,2,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    2,7,8,3,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    3,8,9,4,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    5,10,11,6,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    6,11,12,7,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    7,12,13,8,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    8,13,14,9,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    10,15,16,11,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    11,16,17,12,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    12,17,18,13,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    13,18,19,14,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    15,20,21,16,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    16,21,22,17,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    17,22,23,18,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    18,23,24,19,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    6,5,0,1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    7,6,1,2,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    8,7,2,3,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    9,8,3,4,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    11,10,5,6,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    12,11,6,7,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    13,12,7,8,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    14,13,8,9,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    16,15,10,11,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    17,16,11,12,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    18,17,12,13,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    19,18,13,14,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    21,20,15,16,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    22,21,16,17,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    23,22,17,18,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    24,23,18,19,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        DC.W    -1


	IFEQ	1

;-----------------------------------------------------------
damier:
        DC.W    -90,-90,0
        DC.W    -70,-90,0
        DC.W    -50,-90,0
        DC.W    -30,-90,0
        DC.W    -10,-90,0
        DC.W    10,-90,0
        DC.W    30,-90,0
        DC.W    50,-90,0
        DC.W    70,-90,0
        DC.W    90,-90,0
        DC.W    -90,-70,0
        DC.W    -70,-70,0
        DC.W    -50,-70,0
        DC.W    -30,-70,0
        DC.W    -10,-70,0
        DC.W    10,-70,0
        DC.W    30,-70,0
        DC.W    50,-70,0
        DC.W    70,-70,0
        DC.W    90,-70,0
        DC.W    -90,-50,0
        DC.W    -70,-50,0
        DC.W    -50,-50,0
        DC.W    -30,-50,0
        DC.W    -10,-50,0
        DC.W    10,-50,0
        DC.W    30,-50,0
        DC.W    50,-50,0
        DC.W    70,-50,0
        DC.W    90,-50,0
        DC.W    -90,-30,0
        DC.W    -70,-30,0
        DC.W    -50,-30,0
        DC.W    -30,-30,0
        DC.W    -10,-30,0
        DC.W    10,-30,0
        DC.W    30,-30,0
        DC.W    50,-30,0
        DC.W    70,-30,0
        DC.W    90,-30,0
        DC.W    -90,-10,0
        DC.W    -70,-10,0
        DC.W    -50,-10,0
        DC.W    -30,-10,0
        DC.W    -10,-10,0
        DC.W    10,-10,0
        DC.W    30,-10,0
        DC.W    50,-10,0
        DC.W    70,-10,0
        DC.W    90,-10,0
        DC.W    -90,10,0
        DC.W    -70,10,0
        DC.W    -50,10,0
        DC.W    -30,10,0
        DC.W    -10,10,0
        DC.W    10,10,0
        DC.W    30,10,0
        DC.W    50,10,0
        DC.W    70,10,0
        DC.W    90,10,0
        DC.W    -90,30,0
        DC.W    -70,30,0
        DC.W    -50,30,0
        DC.W    -30,30,0
        DC.W    -10,30,0
        DC.W    10,30,0
        DC.W    30,30,0
        DC.W    50,30,0
        DC.W    70,30,0
        DC.W    90,30,0
        DC.W    -90,50,0
        DC.W    -70,50,0
        DC.W    -50,50,0
        DC.W    -30,50,0
        DC.W    -10,50,0
        DC.W    10,50,0
        DC.W    30,50,0
        DC.W    50,50,0
        DC.W    70,50,0
        DC.W    90,50,0
        DC.W    -90,70,0
        DC.W    -70,70,0
        DC.W    -50,70,0
        DC.W    -30,70,0
        DC.W    -10,70,0
        DC.W    10,70,0
        DC.W    30,70,0
        DC.W    50,70,0
        DC.W    70,70,0
        DC.W    90,70,0
        DC.W    -90,90,0
        DC.W    -70,90,0
        DC.W    -50,90,0
        DC.W    -30,90,0
        DC.W    -10,90,0
        DC.W    10,90,0
        DC.W    30,90,0
        DC.W    50,90,0
        DC.W    70,90,0
        DC.W    90,90,0
        DC.W    0

        FACE    1,11,12,2,-1,-1,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    3,13,14,4,-1,-1,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    5,15,16,6,-1,-1,-1,-1,-1,-1
        DC.W    8*7
        DC.L    0
        FACE    7,17,18,8,-1,-1,-1,-1,-1,-1
        DC.W    8*9
        DC.L    0
        FACE    10,20,21,11,-1,-1,-1,-1,-1,-1
        DC.W    8*11
        DC.L    0
        FACE    12,22,23,13,-1,-1,-1,-1,-1,-1
        DC.W    8*13
        DC.L    0
        FACE    14,24,25,15,-1,-1,-1,-1,-1,-1
        DC.W    8*15
        DC.L    0
        FACE    16,26,27,17,-1,-1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    18,28,29,19,-1,-1,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    21,31,32,22,-1,-1,-1,-1,-1,-1
        DC.W    8*6
        DC.L    0
        FACE    23,33,34,24,-1,-1,-1,-1,-1,-1
        DC.W    8*8
        DC.L    0
        FACE    25,35,36,26,-1,-1,-1,-1,-1,-1
        DC.W    8*10
        DC.L    0
        FACE    27,37,38,28,-1,-1,-1,-1,-1,-1
        DC.W    8*12
        DC.L    0
        FACE    30,40,41,31,-1,-1,-1,-1,-1,-1
        DC.W    8*14
        DC.L    0
        FACE    32,42,43,33,-1,-1,-1,-1,-1,-1
        DC.W    8*1
        DC.L    0
        FACE    34,44,45,35,-1,-1,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    36,46,47,37,-1,-1,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    38,48,49,39,-1,-1,-1,-1,-1,-1
        DC.W    8*7
        DC.L    0
        FACE    41,51,52,42,-1,-1,-1,-1,-1,-1
        DC.W    8*9
        DC.L    0
        FACE    43,53,54,44,-1,-1,-1,-1,-1,-1
        DC.W    8*11
        DC.L    0
        FACE    45,55,56,46,-1,-1,-1,-1,-1,-1
        DC.W    8*13
        DC.L    0
        FACE    47,57,58,48,-1,-1,-1,-1,-1,-1
        DC.W    8*15
        DC.L    0
        FACE    50,60,61,51,-1,-1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    52,62,63,53,-1,-1,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    54,64,65,55,-1,-1,-1,-1,-1,-1
        DC.W    8*6
        DC.L    0
        FACE    56,66,67,57,-1,-1,-1,-1,-1,-1
        DC.W    8*8
        DC.L    0
        FACE    58,68,69,59,-1,-1,-1,-1,-1,-1
        DC.W    8*10
        DC.L    0
        FACE    61,71,72,62,-1,-1,-1,-1,-1,-1
        DC.W    8*12
        DC.L    0
        FACE    63,73,74,64,-1,-1,-1,-1,-1,-1
        DC.W    8*14
        DC.L    0
        FACE    65,75,76,66,-1,-1,-1,-1,-1,-1
        DC.W    8*1
        DC.L    0
        FACE    67,77,78,68,-1,-1,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    70,80,81,71,-1,-1,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    72,82,83,73,-1,-1,-1,-1,-1,-1
        DC.W    8*7
        DC.L    0
        FACE    74,84,85,75,-1,-1,-1,-1,-1,-1
        DC.W    8*9
        DC.L    0
        FACE    76,86,87,77,-1,-1,-1,-1,-1,-1
        DC.W    8*11
        DC.L    0
        FACE    78,88,89,79,-1,-1,-1,-1,-1,-1
        DC.W    8*13
        DC.L    0
        FACE    81,91,92,82,-1,-1,-1,-1,-1,-1
        DC.W    8*15
        DC.L    0
        FACE    83,93,94,84,-1,-1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    85,95,96,86,-1,-1,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    87,97,98,88,-1,-1,-1,-1,-1,-1
        DC.W    8*6
        DC.L    0
        DC.W    -1


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

	FACE	0,7,8,1,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	9,10,1,0,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	3,5,6,4,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,1,8,7,-1,-1,-1,-1,-1,-1
	DC.W	8*8
	DC.L	0
	FACE	9,0,1,10,-1,-1,-1,-1,-1,-1
	DC.W	8*8
	DC.L	0
	FACE	3,4,6,5,-1,-1,-1,-1,-1,-1
	DC.W	8*8
	DC.L	0

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

	FACE	3,2,1,0,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,1,2,3,-1,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0
	DC.W	$FFFF

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

	FACE	1,2,6,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0


	FACE	3,2,1,0,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	1,5,4,0,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,4,7,3,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	3,7,6,2,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,5,6,7,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

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



	FACE	1,2,6,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	8,12,15,11,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0


	FACE	3,2,1,0,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	1,5,4,0,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,4,7,3,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	3,7,6,2,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,5,6,7,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0

	FACE	11,10,9,8,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	9,13,12,8,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	11,15,14,10,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	12,13,14,15,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0
	FACE	9,10,14,13,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

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

	FACE	7,6,5,4,-1,-1,-1,-1
	DC.W	12*8
	DC.L	0

	FACE	8,9,10,11,-1,-1,-1,-1
	DC.W	13*8
	DC.L	0


	FACE	0,1,2,3,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	12,9,8,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	5,1,0,4,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	12,10,9,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	6,2,1,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	12,11,10,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	7,3,2,6,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	12,8,11,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	4,0,3,7,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0


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

	FACE	0,4,5,1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	0,2,4,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	1,5,3,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,1,7,6,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	0,6,2,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	1,3,7,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,2,6,7,3,5,-1,-1
	DC.W	1*8
	DC.L	0
	
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
	FACE	0,1,2,3,4,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,4,5,6,7,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	0,7,8,9,1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	1,9,10,11,2,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	2,11,12,13,3,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	3,13,14,5,4,-1,-1,-1
	DC.W	6*8
	DC.L	0

	FACE	12,15,16,14,13,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	14,16,17,6,5,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	6,17,18,8,7,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	8,18,19,10,9,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	11,10,19,15,12,-1,-1,-1
	DC.W	6*8
	DC.L	0

	FACE	17,16,15,19,18,-1,-1,-1
	DC.W	4*8
	DC.L	0


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
        DC.W  50,5,0
        DC.W  50,-5,0
        DC.W  5,-50,0
        DC.W  -5,-50,0
        DC.W  -50,-5,0
        DC.W  -50,5,0
        DC.W  -5,50,0
        DC.W  5,50,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice3
        DC.W  49,10,0
        DC.W  50,0,0
        DC.W  10,-49,0
        DC.W  1,-50,0
        DC.W  -49,-10,0
        DC.W  -50,0,0
        DC.W  -10,49,0
        DC.W  1,50,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice5
        DC.W  47,15,0
        DC.W  49,5,0
        DC.W  15,-47,0
        DC.W  5,-49,0
        DC.W  -47,-15,0
        DC.W  -49,-5,0
        DC.W  -15,47,0
        DC.W  -5,49,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice7
        DC.W  46,20,0
        DC.W  49,10,0
        DC.W  20,-46,0
        DC.W  10,-49,0
        DC.W  -46,-20,0
        DC.W  -49,-10,0
        DC.W  -20,46,0
        DC.W  -10,49,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice9
        DC.W  43,24,0
        DC.W  47,15,0
        DC.W  24,-43,0
        DC.W  15,-47,0
        DC.W  -43,-24,0
        DC.W  -47,-15,0
        DC.W  -24,43,0
        DC.W  -15,47,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice11
        DC.W  40,29,0
        DC.W  45,20,0
        DC.W  29,-40,0
        DC.W  20,-45,0
        DC.W  -40,-29,0
        DC.W  -45,-20,0
        DC.W  -29,40,0
        DC.W  -20,45,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice13
        DC.W  37,33,0
        DC.W  43,25,0
        DC.W  33,-37,0
        DC.W  25,-43,0
        DC.W  -37,-33,0
        DC.W  -43,-25,0
        DC.W  -33,37,0
        DC.W  -25,43,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice15
        DC.W  33,37,0
        DC.W  40,29,0
        DC.W  37,-33,0
        DC.W  29,-40,0
        DC.W  -33,-37,0
        DC.W  -40,-29,0
        DC.W  -37,33,0
        DC.W  -29,40,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice17
        DC.W  29,40,0
        DC.W  37,33,0
        DC.W  40,-29,0
        DC.W  33,-37,0
        DC.W  -29,-40,0
        DC.W  -37,-33,0
        DC.W  -40,29,0
        DC.W  -33,37,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice19
        DC.W  25,43,0
        DC.W  33,37,0
        DC.W  43,-25,0
        DC.W  37,-33,0
        DC.W  -25,-43,0
        DC.W  -33,-37,0
        DC.W  -43,25,0
        DC.W  -37,33,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice21
        DC.W  20,45,0
        DC.W  29,40,0
        DC.W  45,-20,0
        DC.W  40,-29,0
        DC.W  -20,-45,0
        DC.W  -29,-40,0
        DC.W  -45,20,0
        DC.W  -40,29,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice23
        DC.W  15,47,0
        DC.W  24,43,0
        DC.W  47,-15,0
        DC.W  43,-24,0
        DC.W  -15,-47,0
        DC.W  -24,-43,0
        DC.W  -47,15,0
        DC.W  -43,24,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice25
        DC.W  10,49,0
        DC.W  20,46,0
        DC.W  49,-10,0
        DC.W  46,-20,0
        DC.W  -10,-49,0
        DC.W  -20,-46,0
        DC.W  -49,10,0
        DC.W  -46,20,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice27
        DC.W  5,49,0
        DC.W  15,47,0
        DC.W  49,-5,0
        DC.W  47,-15,0
        DC.W  -5,-49,0
        DC.W  -15,-47,0
        DC.W  -49,5,0
        DC.W  -47,15,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice29
        DC.W  1,50,0
        DC.W  10,49,0
        DC.W  50,0,0
        DC.W  49,-10,0
        DC.W  1,-50,0
        DC.W  -10,-49,0
        DC.W  -50,0,0
        DC.W  -49,10,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
fhelice:

	;helice interne

	FACE	1,8,0,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	7,8,6,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	5,8,4,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	3,8,2,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0

	;face internes

	FACE	9,8,10,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	11,8,12,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	12,8,9,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	10,8,11,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0



	;helice externe

	FACE	0,8,1,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	6,8,7,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	4,8,5,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	2,8,3,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0


	FACE	9,10,11,12,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0


	DC.W	-1


raie:
        DC.L  praie1
        DC.L  praie2
        DC.L  praie3
        DC.L  praie4
        DC.L  praie5
        DC.L  praie6
        DC.L  praie7
        DC.L  praie8
        DC.L  praie9
        DC.L  praie10
        DC.L  praie11
        DC.L  praie12
        DC.L  praie13
        DC.L  praie14
        DC.L  praie15
        DC.L  praie16
        DC.L  praie17
        DC.L  praie18
        DC.L  praie19
        DC.L  praie20
        DC.L  praie21
        DC.L  praie22
        DC.L  praie23
        DC.L  praie24
        DC.L  0
        DC.L  raie
praie1
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-22
        DC.W  -30,10,-9
        DC.W  -30,-10,-9
        DC.W  30,10,-9
        DC.W  30,-10,-9
        DC.W  50,0,-22
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie2
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-23
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-23
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie3
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-24
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-24
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie4
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-25
        DC.W  -30,10,-7
        DC.W  -30,-10,-7
        DC.W  30,10,-7
        DC.W  30,-10,-7
        DC.W  50,0,-25
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie5
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-24
        DC.W  -30,10,-6
        DC.W  -30,-10,-6
        DC.W  30,10,-6
        DC.W  30,-10,-6
        DC.W  50,0,-24
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie6
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-23
        DC.W  -30,10,-5
        DC.W  -30,-10,-5
        DC.W  30,10,-5
        DC.W  30,-10,-5
        DC.W  50,0,-23
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie7
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-22
        DC.W  -30,10,-4
        DC.W  -30,-10,-4
        DC.W  30,10,-4
        DC.W  30,-10,-4
        DC.W  50,0,-22
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie8
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-20
        DC.W  -30,10,-2
        DC.W  -30,-10,-2
        DC.W  30,10,-2
        DC.W  30,-10,-2
        DC.W  50,0,-20
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie9
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-17
        DC.W  -30,10,-1
        DC.W  -30,-10,-1
        DC.W  30,10,-1
        DC.W  30,-10,-1
        DC.W  50,0,-17
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie10
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-15
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-15
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie11
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-12
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-12
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie12
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-10
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-10
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie13
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-7
        DC.W  -30,10,1
        DC.W  -30,-10,1
        DC.W  30,10,1
        DC.W  30,-10,1
        DC.W  50,0,-7
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie14
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-6
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-6
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie15
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-5
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-5
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie16
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-5
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-5
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie17
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-5
        DC.W  -30,10,-1
        DC.W  -30,-10,-1
        DC.W  30,10,-1
        DC.W  30,-10,-1
        DC.W  50,0,-5
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie18
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-6
        DC.W  -30,10,-2
        DC.W  -30,-10,-2
        DC.W  30,10,-2
        DC.W  30,-10,-2
        DC.W  50,0,-6
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie19
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-7
        DC.W  -30,10,-3
        DC.W  -30,-10,-3
        DC.W  30,10,-3
        DC.W  30,-10,-3
        DC.W  50,0,-7
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie20
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-9
        DC.W  -30,10,-5
        DC.W  -30,-10,-5
        DC.W  30,10,-5
        DC.W  30,-10,-5
        DC.W  50,0,-9
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie21
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-12
        DC.W  -30,10,-6
        DC.W  -30,-10,-6
        DC.W  30,10,-6
        DC.W  30,-10,-6
        DC.W  50,0,-12
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie22
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-14
        DC.W  -30,10,-7
        DC.W  -30,-10,-7
        DC.W  30,10,-7
        DC.W  30,-10,-7
        DC.W  50,0,-14
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie23
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-17
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-17
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie24
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-19
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-19
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie


fraie:

	; ailes dessous

	FACE  0,3,6,5,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  7,8,2,1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  5,6,4,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  9,8,7,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0


	; corps


 	FACE  2,3,10,-1,-1,-1,-1,-1
	DC.W  1*8
	DC.L  0

	FACE  10,3,0,11,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  11,1,2,10,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  12,11,0,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  12,1,11,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  1,12,0,-1,-1,-1,-1,-1
	DC.W  8*8
	DC.L  0

	; dessus

	FACE  3,2,1,0,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  0,5,6,3,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  7,1,2,8,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  5,4,6,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  9,7,8,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0





	DC.W  -1


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

	DC.L  fnscarre

fnscarre:
	
	FACE  3,2,1,0,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  7,6,5,4,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  11,10,9,8,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  15,14,13,12,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  19,18,17,16,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  23,22,21,20,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  27,26,25,24,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	;faces autre cote

	FACE  24,25,26,27,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  20,21,22,23,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  16,17,18,19,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  12,13,14,15,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  8,9,10,11,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  4,5,6,7,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  0,1,2,3,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	DC.W  -1

interph
        DC.L  pinterph0
        DC.L  pinterph1
        DC.L  pinterph2
        DC.L  pinterph3
        DC.L  pinterph4
        DC.L  pinterph5
        DC.L  pinterph6
        DC.L  pinterph7
        DC.L  pinterph8
        DC.L  pinterph9
        DC.L  pinterph10
        DC.L  pinterph11
        DC.L  pinterph12
        DC.L  pinterph13
        DC.L  pinterph14
        DC.L  pinterph15
        DC.L  pinterph16
        DC.L  pinterph17
        DC.L  pinterph18
        DC.L  pinterph19
        DC.L  pinterph20
        DC.L  pinterph19
        DC.L  pinterph18
        DC.L  pinterph17
        DC.L  pinterph16
        DC.L  pinterph15
        DC.L  pinterph14
        DC.L  pinterph13
        DC.L  pinterph12
        DC.L  pinterph11
        DC.L  pinterph10
        DC.L  pinterph9
        DC.L  pinterph8
        DC.L  pinterph7
        DC.L  pinterph6
        DC.L  pinterph5
        DC.L  pinterph4
        DC.L  pinterph3
        DC.L  pinterph2
        DC.L  pinterph1
        DC.L  0
        DC.L  interph
pinterph0
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,10
        DC.W  20,0,10
        DC.W  0
        DC.L  finterph
pinterph1
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,12
        DC.W  20,0,12
        DC.W  0
        DC.L  finterph
pinterph2
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,14
        DC.W  20,0,14
        DC.W  0
        DC.L  finterph
pinterph3
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,16
        DC.W  20,0,16
        DC.W  0
        DC.L  finterph
pinterph4
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,18
        DC.W  20,0,18
        DC.W  0
        DC.L  finterph
pinterph5
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,20
        DC.W  20,0,20
        DC.W  0
        DC.L  finterph
pinterph6
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,22
        DC.W  20,0,22
        DC.W  0
        DC.L  finterph
pinterph7
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,24
        DC.W  20,0,24
        DC.W  0
        DC.L  finterph
pinterph8
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,26
        DC.W  20,0,26
        DC.W  0
        DC.L  finterph
pinterph9
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,28
        DC.W  20,0,28
        DC.W  0
        DC.L  finterph
pinterph10
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,30
        DC.W  20,0,30
        DC.W  0
        DC.L  finterph
pinterph11
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,32
        DC.W  20,0,32
        DC.W  0
        DC.L  finterph
pinterph12
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,34
        DC.W  20,0,34
        DC.W  0
        DC.L  finterph
pinterph13
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,36
        DC.W  20,0,36
        DC.W  0
        DC.L  finterph
pinterph14
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,38
        DC.W  20,0,38
        DC.W  0
        DC.L  finterph
pinterph15
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,40
        DC.W  20,0,40
        DC.W  0
        DC.L  finterph
pinterph16
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,42
        DC.W  20,0,42
        DC.W  0
        DC.L  finterph
pinterph17
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,44
        DC.W  20,0,44
        DC.W  0
        DC.L  finterph
pinterph18
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,46
        DC.W  20,0,46
        DC.W  0
        DC.L  finterph
pinterph19
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,48
        DC.W  20,0,48
        DC.W  0
        DC.L  finterph
pinterph20
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  0
        DC.L  finterph


finterph:
	FACE  3,2,1,0,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  3,7,6,2,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  1,5,4,0,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  0,4,7,3,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  2,6,5,1,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  3,0,8,-1,-1,-1,-1,-1
	DC.W  9*8
	DC.L  0

	FACE  1,2,9,-1,-1,-1,-1,-1
	DC.W  9*8
	DC.L  0


	FACE  10,12,11,-1,-1,-1,-1,-1
	DC.W  1*8
	DC.L  0

	FACE  11,12,10,-1,-1,-1,-1,-1
	DC.W  1*8
	DC.L  0

	FACE  8,0,3,-1,-1,-1,-1,-1
	DC.W  10*8
	DC.L  0

	FACE  9,2,1,-1,-1,-1,-1,-1
	DC.W  10*8
	DC.L  0



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


ficosaedre:
	ICOF  1,2,6,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0
	ICOF  2,3,6,-1,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0
	ICOF  3,4,6,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0
	ICOF  4,5,6,-1,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0
	ICOF  5,1,6,-1,-1,-1,-1,-1
	DC.W  6*8
	DC.L  0
	ICOF  12,1,5,-1,-1,-1,-1,-1
	DC.W  7*8
	DC.L  0
	ICOF  12,8,1,-1,-1,-1,-1,-1
	DC.W  8*8
	DC.L  0
	ICOF  8,2,1,-1,-1,-1,-1,-1
	DC.W  9*8
	DC.L  0
	ICOF  9,2,8,-1,-1,-1,-1,-1
	DC.W  10*8
	DC.L  0
	ICOF  9,3,2,-1,-1,-1,-1,-1
	DC.W  11*8
	DC.L  0
	ICOF  9,10,3,-1,-1,-1,-1,-1
	DC.W  12*8
	DC.L  0
	ICOF  10,4,3,-1,-1,-1,-1,-1
	DC.W  13*8
	DC.L  0
	ICOF  10,11,4,-1,-1,-1,-1,-1
	DC.W  14*8
	DC.L  0
	ICOF  11,5,4,-1,-1,-1,-1,-1
	DC.W  15*8
	DC.L  0
	ICOF  11,12,5,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0
	ICOF  7,8,12,-1,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0
	ICOF  7,9,8,-1,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0
	ICOF  7,10,9,-1,-1,-1,-1,-1
	DC.W  6*8
	DC.L  0
	ICOF  7,11,10,-1,-1,-1,-1,-1
	DC.W  7*8
	DC.L  0
	ICOF  7,12,11,-1,-1,-1,-1,-1
	DC.W  8*8
	DC.L  0

	DC.W  -1
