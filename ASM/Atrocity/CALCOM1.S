********************************
*** CALCOM 0.1 - ZANAK 1994  ***
***  - CONVERTION GROB -> ST ***
***         ATROCITY         ***
********************************

	PEA	0.W
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	LEA	GROB(PC),A0
	CMP.L	#$25254850,(A0)
	BEQ	ASCII
	CMP.L	#$48504850,(A0)
	BEQ	BINAIRE
	BRA	PASBON
ASCII	PEA	TEXT3(PC)
	BRA	AFFICHE
BINAIRE	PEA	TEXT2(PC)
	BRA	AFFICHE
PASBON	PEA	TEXT(PC)
AFFICHE	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.L	D1
	CLR.L	D2
	LEA	GROB(PC),A0
	LEA	26(A0),A0
ENCORE	MOVE.B	(A0)+,D0
	CMP.B	#$20,D0
	BEQ	SUITE
	SUB.W	#$30,D0
	ROL.W	#4,D1
	ADD.W	D0,D1
	BRA	ENCORE
SUITE	SWAP	D1
	CMP.B	#1,D2
	BEQ	BYE
	MOVE.B	#1,D2
	BRA	ENCORE
	
WAIT	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	WAIT	
		
BYE	CLR	-(SP)
	TRAP	#1
	
	SECTION DATA
		
GROB	INCBIN	F:\UTILS\HP48GX\48GX.PRG\GFX.ASC
	EVEN

GROB2	INCBIN	F:\UTILS\HP48GX\48GX.PRG\GFX.BIN
	EVEN
	
TEXT	DC.B	27,"E","Ceci n'est pas un Grob HP48 ...",0
	EVEN

TEXT2	DC.B	27,"E","FICHIER BINAIRE (PAS BON !!!)",0
	EVEN

TEXT3	DC.B	27,"E","FICHIER ASCII (VAS Y MIMILE !!)",0
	EVEN
	
	SECTION BSS
	