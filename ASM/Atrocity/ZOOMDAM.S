**********************************************************************
************** ZOOM DAMIER *******************************************
************** (C) SEPTEMBRE 1994 , ZANAK / ATROCITY *****************
**********************************************************************

	OPT	O+
	
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

********* OVERSCAN PREPA ****************************************

;	MOVE.W	$FFFF8288.W,D0
;	MOVE.W	$FFFF828A.W,D1
;	MOVE.W	D0,HBB
;	MOVE.W	D1,HBL
	
**********************************************************************
	
	MOVE.W	#2,-(SP)	; OU EST L'ECRAN PHYSIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PSCR	; IL EST LA ...
	
	MOVE.W	#3,-(SP)	; OU EST L'ECRAN LOGIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LSCR	; IL EST LA AUSSI ...
	
	MOVE.W	#-1,-(SP)	; ET LA RESOLUTION ?
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,REZ	; ELLE EST LA ...

**********************************************************************

	MOVE.L	#SIZE1,D0	; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0	; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%1100010,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1,-(SP)
	MOVE.L	ECRAN2,-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.B	$484.W,KEYBOARD	; COUPE LE CLAVIER
	CLR.B	$484.W
	
	DC.W	$A00A
	MOVE.B	#$12,$FFFFFC02.W	; COUPE LA SOURIS

**********************************************************************
************** ROUTINE PRINCIPALE ************************************
**********************************************************************
			

**********************************************************************
**********************************************************************

WAIT	CMP.B	#$39,$FFFFFC02
	BNE	WAIT	

BYE	DC.W	$A009
	MOVE.B	#8,$FFFFFC02.W
	MOVE.B	KEYBOARD,$484.W
	
**********************************************************************

	MOVE.W	REZ,-(SP)	; REMET LA REZ
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR,-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR,-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
		
;	MOVE.W	HBB,D0
;	MOVE.W	HBL,D1
;	MOVE.W	D0,$FFFF8288.W
;	MOVE.W	D1,$FFFF828A.W
		
**********************************************************************

	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
	
VBL	MOVE.L	$466.W,D7
VBL1	CMP.L	$466.W,D7
	BEQ.B	VBL1
	RTS
		
**********************************************************************
	SECTION DATA
**********************************************************************
	
MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0
		
;IMAGE	INCBIN	"E:\DAMIER.PI1"

PIXEL1_1	DC.B	$F0,$FF,$00,$FF,$FF,$00,$00
	DC.B	$FF,$FF,$FF,$FF,$00,$00,$00,$00
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	
PIXEL2_2	DC.B	$F,$00,$FF,$00,$00,$FF,$FF
	DC.B	$00,$00,$00,$00,$FF,$FF,$FF,$FF
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$00,$00,$00,$00,$00,$00,$00,$00
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	DC.B	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	
**********************************************************************
	SECTION BSS
**********************************************************************

SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128
PSCR	DS.W	2
LSCR	DS.W	2
REZ	DS.W	1
ECRAN1	DS.W	2
ECRAN2	DS.W	2
HBB	DS.W	1
HBL	DS.W	1
KEYBOARD	DS.B	1
	
	END