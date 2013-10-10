; bigshit pour avoir le gem en overscan ...
; bidouille: charger le gem en 80 cols/16 cols/NON entrelace
; puis executer ce prog ... repasser en 80 cols ....	

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PHYSIC


	MOVE.W	#3,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LOGIC

 	MOVE.W	#%0000000001100010,-(SP)
;		  XXXXXXXFSOPV8NNN : flags pour rezs
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP

	PEA	TEXTE
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP	

	BSR	SORTIE

*****************FIN ET SHITS********************************

SORTIE	

	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	
	CLR.L	-(SP)
	TRAP	#1

		SECTION	DATA	
TEXTE	DC.B	27,"EBIG SHIT BY Cristalion/Hydroxid ... PRESS SPACE ...",0
PHYSIC:	DC.W	1
LOGIC:	DC.W	1

