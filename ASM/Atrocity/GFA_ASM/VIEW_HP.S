***************************
***      ASCII -> HP    ***
***   (C) 1994 , ZANAK  ***
***       ATROCITY      ***
***************************

; RECUPERATION DES DONNEES
; ADRESSE DE DEPART

	LEA	ADR(PC),A0
	MOVE.L	4(SP),(A0)
; TAILLE DU FICHIER
	LEA	SIZE(PC),A0
	MOVE.L	8(SP),(A0)
	
SUPER	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,-(SP)

CONVERT	MOVE.L	SIZE(PC),D1
	MOVE.L	ADR(PC),A0
	MOVE.L	ADR(PC),A1
	CLR.L	D0
CONVERT2	MOVE.B	(A0)+,D2
	CMP.B	#13,D2
	BEQ.S	DELETE
	MOVE.B	D2,(A1)+
	DBF	D1,CONVERT2
	BRA	SUITE

DELETE	ADDQ.L	#1,D0
	BRA	CONVERT2
	
SUITE	LEA	RESULT(PC),A2
	MOVE.L	D0,(A2)
	
EXIT	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.L	RESULT(PC),D0
		
	RTS
			
ADR	DC.L	0
SIZE	DC.L	0
RESULT	DC.L	0