*** BOOT2 ATROCITY / ATLANTIDE ***
***        BY ZANAK           ***
	
FALCON_2	LEA	TEXTE_BOOT2(PC),A1	
	MOVE.L	A1,-(SP)
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
;	MOVE.W	#64,-(SP)
;	MOVE.W	#$1E,-(SP)
;	TRAP	#14
;	ADDQ.L	#4,SP
	
	RTS
	
TEXTE_BOOT2	
	
	DC.B	27,"E"
	DC.B	"           - SUPREMACY -         ",10,13
	DC.B	"     BLA BLA CRACKED BY ZARMI    ",10,13,10,13,10,13,10,13
	DC.B	"    PLEASE WAIT -  LOADING ... ",10,13,10,13,0
	
	EVEN
	
	