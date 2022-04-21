**************************
*** TEST COMMUNICATION ***
**** PROTOCOLE KERMIT ****
*****  POUR HP 48 GX *****
**** (C) 1994 , ZANAK **** 
***      ATROCITY      ***
**************************

****************************************
	SECTION TEXT
****************************************	

	PEA	0.W
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.L	#$A2F6,A0
	MOVE.L	#ZANAK,A1
	CLR.L	D0
	MOVE.B	(A1),D0
TOTOF	MOVE.B	(A1)+,(A0)+
	DBF	D0,TOTOF

	BRA	KERMIT
	
	CLR.L	-(SP)
	TRAP	#1
	
****************************************
	SECTION DATA
****************************************
	
ZANAK	DC.B	$C,"ATROCITY.TTP",0
	EVEN
	
KERMIT	INCBIN	E:\PLAY_FLI.TTP
	END	
	