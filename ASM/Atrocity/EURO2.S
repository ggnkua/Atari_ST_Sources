**********************************************************************
************** TEST ROUTINE DE FADE 256 COULEURS - ZANAK *************
**********************************************************************

COL1	EQU	$5C
COL2	EQU	$3C
COL3	EQU	$1C
REG1	EQU	$FFFF9804
REG2	EQU	$FFFF9808
REG3	EQU	$FFFF9834
VAL	EQU	$4040004

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

	MOVE.L	#SIZE1,D0	; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1(A6)	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0	; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2(A6)	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%100010011,-(SP)	
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
**********************************************************************

************** FADE COULEUR 1
	MOVE.W	#$3C,D0
FADE	SUBI.L	#$4040004,$FFFF9800.W
	BSR	VBL
	DBF	D0,FADE
	
************** COULEURS NOIR POUR TOUS

;	CLR.L	$FFFF9800.W
	CLR.L	$FFFF9804.W
	CLR.L	$FFFF9808.W
	CLR.L	$FFFF9834.W
	
************** AFFICHAGE IMAGE 'ATROCITY' CYCLE 256C

	LEA	IMAGE,A0
	MOVEA.L	ECRAN1(A6),A1
	MOVE.W	#32000,D7
	SUB.W	#1664,A1
AFFICHE1	MOVE.W	(A0)+,(A1)+
	DBF	D7,AFFICHE1

************** FADE DU LOGO
	MOVE.L	#COL1,D0
	MOVE.L	#COL2,D1
	MOVE.L	#COL3,D2
	
BOUCLE0:	ADDI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ.S	BOUCLE1
	
	ADDI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ.S	BOUCLE2
	
	ADDI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ.S	BOUCLE3
	
	BSR	VBL
	BRA	BOUCLE0
	
BOUCLE1:	ADDI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ	BOUCLE4
	
	ADDI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ	BOUCLE5

	BSR	VBL
	BRA	BOUCLE1
	
BOUCLE2:	ADDI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ	BOUCLE6
	
	ADDI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ.S	BOUCLE4
	
	BSR	VBL
	BRA	BOUCLE2
	
BOUCLE3:	ADDI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ.S	BOUCLE6
	
	ADDI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ	BOUCLE2
	
	BSR	VBL
	BRA.S	BOUCLE5
	
BOUCLE4: 	ADDI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ.S	FIN 
	
	BSR	VBL
	BRA	BOUCLE4

BOUCLE5:	ADDI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ.S	FIN	
	
	BSR	VBL
	BRA	BOUCLE5
	
BOUCLE6:	ADDI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ.S	FIN
	
	BSR	VBL
	BRA	BOUCLE6

FIN	CMP.B	#$39,$FFFFFC02
	BNE	FIN	

************** FADE DU LOGO 2

	MOVE.L	#COL1,D0
	MOVE.L	#COL2,D1
	MOVE.L	#COL3,D2
	
BOUCLE00:	SUBI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ.S	BOUCLE11
	
	SUBI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ.S	BOUCLE22
	
	SUBI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ.S	BOUCLE33
	
	BSR	VBL
	BRA	BOUCLE00
	
BOUCLE11:	SUBI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ	BOUCLE44
	
	SUBI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ	BOUCLE55

	BSR	VBL
	BRA	BOUCLE11
	
BOUCLE22:	SUBI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ	BOUCLE66
	
	SUBI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ.S	BOUCLE44
	
	BSR	VBL
	BRA	BOUCLE22
	
BOUCLE33:	SUBI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ.S	BOUCLE66
	
	SUBI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ	BOUCLE22
	
	BSR	VBL
	BRA.S	BOUCLE55
	
BOUCLE44: 	SUBI.L	#VAL,REG3.W
	SUBI.L	#1,D2
	CMPI.L	#0,D2
	BEQ.S	BYE 
	
	BSR.S	VBL
	BRA	BOUCLE44

BOUCLE55:	SUBI.L	#VAL,REG2.W
	SUBI.L	#1,D1
	CMPI.L	#0,D1
	BEQ.S	BYE	
	
	BSR.S	VBL
	BRA	BOUCLE55
	
BOUCLE66:	SUBI.L	#VAL,REG1.W
	SUBI.L	#1,D0
	CMPI.L	#0,D0
	BEQ.S	BYE
	
	BSR.S	VBL
	BRA	BOUCLE66

**********************************************************************

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
	
VBL	MOVE.L	$466.W,D6
VBL1	CMP.L	$466.W,D6
	BEQ.B	VBL1
	RTS
		
**********************************************************************
	SECTION DATA
**********************************************************************

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0

IMAGE	INCBIN	D:\DIVERS\IMAGES\ATROCITY.TPI
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