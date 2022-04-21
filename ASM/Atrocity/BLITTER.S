**********************************************************************
************** TEST D'UN SCROLLING BLITTER ***************************
************** (C) 1994 , ZANAK FROM ATROCITY ************************
**********************************************************************

	SECTION TEXT
	
**********************************************************************
************** MEMOIRE - ECRANS **************************************
**********************************************************************
	MOVE.L	4(SP),A0
	
	MOVE.L	12(A0),D0	; TAILLE SECTION TEXT	
	ADD.L	20(A0),D0	; TAILLE SECTION DATA
	ADD.L	28(A0),D0	; TAILLE SECTION BSS
	ADDI.L	#256,D0	; TAILLE BASEPAGE
	ADDI.L	#256,D0	; TAILLE ERROR

	MOVE.L	D0,-(SP)	; TAILLE BLOCK ENTIER
	MOVE.L	A0,-(SP)	; ADRESSE BLOCK
	MOVE.W	#0,-(SP)
	MOVE.W	#$4A,-(SP)	; MSHRINK
	TRAP	#1	; CALL GEMDOS
	ADD.L	#12,SP
	
	TST.L	D0	; TESTE SI ERREUR ...
	BMI	BYE	; SI OUI FIN SINON
			; ON CONTINUE ...

**********************************************************************

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP	#1
	ADDQ.L	#6,SP

**********************************************************************
	
	MOVE.L	D0,-(SP)	; OLD REZ 
	LEA	VAR,A6	; VARIABLES

********* OVERSCAN PREPA ****************************************

	MOVE.W	$FFFF8288.W,D0
	MOVE.W	$FFFF828A.W,D1
	MOVE.W	D0,HBB(a6)
	MOVE.W	D1,HBL(a6)
	
**********************************************************************
	
	MOVE.W	#2,-(SP)	; OU EST L'ECRAN PHYSIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PSCR(A6)	; IL EST LA ...
	
	MOVE.W	#3,-(SP)	; OU EST L'ECRAN LOGIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LSCR(A6)	; IL EST LA AUSSI ...
	
	MOVE.W	#-1,-(SP)	; ET LA RESOLUTION ?
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,REZ(A6)	; ELLE EST LA ...

**********************************************************************

	MOVE.L	#SIZE1,D0		; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1(A6)	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0		; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2(A6)	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%1100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1(A6),-(SP)
	MOVE.L	ECRAN2(A6),-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.L	#MOUSOFF,-(SP)	; COUPE LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ	#8,SP
			
**********************************************************************
*********** ECRAN PRINCIPALE *****************************************
**********************************************************************
	
	MOVE.L	ECRAN1(A6),A1
	MOVE.L	#IMAGE,A2
	MOVE.L	#$10,D0
	MOVE.W	#200,$38(A0)
	MOVE.L	#320,$36(A0)

	LEA	$FFFF8A00.W,A0
SCROLL	MOVE.L	A2,$24(A0)
	MOVE.W	#16,$20(A0)
	MOVE.L	A1,$32(A0)
;	MOVE.B	#128,$3C(A0)
	
WAIT	BSET	#7,$3C(A0)
	NOP
	BNE.S	WAIT

	ADD.W	#320,A1
	BSR	VBL0
	BSR	SWAP
	
	DBF	D0,SCROLL

**********************************************************************

WAIT1	CMP.B	#$39,$FFFFFC02
	BNE	WAIT1	

BYE	MOVE.L	#MOUSON,-(SP)	; REMET LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	
	
**********************************************************************

	MOVE.W	REZ(A6),-(SP)	; REMET LA REZ
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR(A6),-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR(A6),-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
		
	MOVE.W	HBB(a6),D0
	MOVE.W	HBL(a6),D1
	MOVE.W	D0,$FFFF8288.W
	MOVE.W	D1,$FFFF828A.W
		
**********************************************************************

	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
	
**********************************************************************

VBL0	MOVE.L	$466.W,D6
VBL1	CMP.L	$466.W,D6
	BEQ.B	VBL1
	RTS

SWAP	MOVE.L	ECRAN1(A6),D0
	MOVE.L	ECRAN2(A6),ECRAN1(A6)
	MOVE.L	D0,ECRAN2(A6)
	MOVE.B	ECRAN1+1,$FFFF8201.W
	MOVE.B	ECRAN1+2,$FFFF8203.W
	MOVE.B	ECRAN1+3,$FFFF820D.W
	RTS
	
**********************************************************************
	SECTION DATA
**********************************************************************

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0

IMAGE	INCBIN	E:\CINDY.TPI
	EVEN
			
**********************************************************************
	SECTION BSS
**********************************************************************

SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128
VAR	DS.W	48
PSCR	RS.W	2
LSCR	RS.W	2
REZ	RS.W	1
ECRAN1	RS.W	2
ECRAN2	RS.W	2
HBB	RS.W	1
HBL	RS.W	1
	END