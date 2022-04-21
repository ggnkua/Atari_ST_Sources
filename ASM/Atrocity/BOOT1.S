*** BOOT1 ATROCITY / ATLANTIDE ***
***        BY ZANAK           ***
	
FALCON_1	LEA	TEXTE_BOOT1(PC),A1	
	MOVE.L	A1,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.W	#64,-(SP)
	MOVE.W	#$1E,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	
	RTS
	
TEXTE_BOOT1	DC.B	'    *** ATLANTIDE Software ***',10,13,10,13,0
	EVEN
	
	