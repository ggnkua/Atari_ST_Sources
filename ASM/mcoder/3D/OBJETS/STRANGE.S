
strange
	DC.L	pstrange
	DC.L	0
	DC.L	strange
pstrange
	DC.W	16
	DC.W	50,-30,0		;aile droite
	DC.W	-50,-50,-40
	DC.W	-50,-10,40
	DC.W	50,30,0			;aile gauche
	DC.W	-50,50,-40
	DC.W	-50,10,40
	DC.W	-50,-30,0		;reacteur droit
	DC.W	0,-30,0
	DC.W	-50,-15,10
	DC.W	0,-15,10
	DC.W	-50,0,-10		;dessous cockpit
	DC.W	0,0,-10
	DC.W	-50,30,0		;reacteur gauche
	DC.W	0,30,0
	DC.W	-50,15,10
	DC.W	0,15,10
	DC.W	70,0,0			;pointe
	DC.L	fstrange
fstrange
	;bouclier droit interne

	FACE	0,1,2,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	;bouclier gauche interne

	FACE	5,4,3,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	;entree d'air

	FACE	9,7,11,-1,-1,-1,-1,-1
	COUL	6
	DC.L	0

	FACE	13,15,11,-1,-1,-1,-1,-1
	COUL	6
	DC.L	0

	;pointe

	FACE	9,11,16,-1,-1,-1,-1,-1
	COUL	4
	DC.L	0

	FACE	15,16,11,-1,-1,-1,-1,-1
	COUL	4
	DC.L	0
	
	FACE	15,9,16,-1,-1,-1,-1,-1
	COUL	12
	DC.L	0



	;reacteur droit

	FACE	9,8,6,7,-1,-1,-1,-1
	COUL	4
	DC.L	0
	FACE	11,7,6,10,-1,-1,-1,-1
	COUL	2
	DC.L	0

	;reacteur gauche

	FACE	15,13,12,14,-1,-1,-1,-1
	COUL	4
	DC.L	0
	FACE	12,13,11,10,-1,-1,-1,-1
	COUL	2
	DC.L	0

	;dessus

	FACE	15,14,8,9,-1,-1,-1,-1
	COUL	2
	DC.L	0

	;arriere

	FACE	10,6,8,14,12,-1,-1,-1
	COUL	14
	DC.L	0




	;bouclier droit externe

	FACE	2,1,0,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	;bouclier gauche externe

	FACE	3,4,5,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	DC.W	-1

