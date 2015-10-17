; sauve la rez de depart et addresses ecrans
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PHYSIC

	MOVE.W	#3,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LOGIC

	MOVE.W	#4,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,REZ
********************
;		  XXXXXXXFSOPV8NNN : flags pour rezs
	MOVE.W	#%0000000000100010,-(SP)
	MOVE.W	#3,-(SP)		; rez falcon
	MOVE.L	#0,-(SP)		; fonction xbios(5)
	MOVE.L	#0,-(SP)			
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP
				
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
********************
	MOVE.W	REZ,-(SP)
	MOVE.L	PHYSIC,-(SP)
	MOVE.L	LOGIC,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

	MOVE.W	#0,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP

		SECTION	BSS

PHYSIC	DC.L	0
LOGIC	DC.L	0
REZ	DC.W	0 	