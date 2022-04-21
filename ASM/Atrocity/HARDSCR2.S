**********************************************************************
*********************** HARDSCROLL HORIZONTAL ************************
************** CODED BY ZANAK - (C) 1994 , ATROCITY Corp.  ***********
**********************************************************************  

PAS_X	EQU	32
PAS_Y	EQU	8

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
	BMI	FIN	; SI OUI FIN SINON
			; ON CONTINUE ...

**********************************************************************

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP	#1
	ADDQ.L	#6,SP

;	CLR.B	$FFFF8900.W		; IT DMA OFF
;	CLR.B	$FFFF8901.W		; DMA STOP

************** CLS ***************************************************

	PEA	TEXXT
	MOVE.W	#$9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

;SPACE_WAIT	CMP.B	#$39+$80,$FFFFFC02.W
;	BNE	SPACE_WAIT
	
;	CLR.B	$FFFFFC02.W
	
**********************************************************************
	
	MOVE.L	D0,-(SP)	; OLD REZ 

********* OVERSCAN PREPA ****************************************

;	MOVE.W	$FFFF8288.W,D0
;	MOVE.W	$FFFF828A.W,D1
;	MOVE.W	D0,HBB(a6)
;	MOVE.W	D1,HBL(a6)
	
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

	MOVE.L	#SIZE1,D0		; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0		; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%1100011,-(SP)	
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
*********** ROUTINE PRINCIPALE ***************************************
**********************************************************************
	
	MOVE.L	#IMAGE1,IMAGE
	BSR	PREPARATION_DE_LA_PALETTE	
	BSR	AFFICHE_PALETTE
	BSR	PREPARATION_IMAGE                                                                         

;	BSR	AFFICHE_ECRAN
;	BSR	MOVE_YOUR_BODY
	BSR	KEY
	
**********************************************************************	
*********** FIN DE LA DEMO *******************************************
**********************************************************************

FIN	MOVE.B	#0,$FFFF8265.W
		
	DC.W	$A009
	MOVE.B	#8,$FFFFFC02.W
	MOVE.B	KEYBOARD,$484.W

	MOVE.W	REZ,-(SP)
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR,-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR,-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
		
;	MOVE.W	HBB(a6),D0
;	MOVE.W	HBL(a6),D1
;	MOVE.W	D0,$FFFF8288.W
;	MOVE.W	D1,$FFFF828A.W

	CLR.L	-(SP)
	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP

	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
	
**********************************************************************
*********** SOUS-ROUTINES ********************************************
**********************************************************************
	
************** LA VBL*************************************************

VBL0	MOVE.L	D0,-(SP)
	MOVE.L	$466.W,D0
VBL1	CMP.L	$466.W,D0
	BEQ.S	VBL1
	MOVE.L	D0,(SP)+
	RTS

WAIT	BSR	VBL0
	DBF	D0,WAIT
	RTS
	
PREPARATION_IMAGE
	MOVE.L	#IMAGE1+1664,A0
	MOVE.L	#IMAGE2+1664,A1
	MOVE.L	#BUFFER,A2
	MOVE.L	#240,D0
ENTRELACEMENT
	MOVE.W	#191,D1
ENTRELACEMENT1
	MOVE.W	(A0)+,(A2)+
	DBF	D1,ENTRELACEMENT1
	MOVE.W	#191,D1
ENTRELACEMENT2
	MOVE.W	(A1)+,(A2)+
	DBF	D1,ENTRELACEMENT2
	DBF	D0,ENTRELACEMENT
	RTS
	
AFFICHE_ECRAN
	MOVE.L	#BUFFER,A0
	MOVE.L	ECRAN1,A1
	MOVE.W	#240,D0
AAFFICHE	MOVE.W	#191,D1
AAFFICHE1	MOVE.W	(A0)+,(A1)+
	DBF	D1,AAFFICHE1
	ADD.W	#384,A0
	DBF	D0,AAFFICHE
	RTS
	
************** CONVERSION DE LA PALETTE ******************************
		
POINTAGE	MOVE.L	IMAGE,A1
	MOVE.W	(A2)+,D5
	ADDA.W	D5,A1
	RTS
	
CONVERTION	BSR.S	CONVERTION1	; ROUGE
	BSR.S	CONVERTION1	; VERT
	CLR.B	(A0)+	; NUL
	BSR.S	CONVERTION1	; BLEU
	RTS
	
CONVERTION1	MOVE.W	(A1)+,D5
	LSR.W	#4,D5
	LSL.W	#2,D5
	MOVE.B	D5,(A0)+
	RTS

PREPARATION_DE_LA_PALETTE
	LEA.L	PALETTE,A0
	LEA.L	FORMAT_TPI,A2
	MOVE.L	#$F,D1
	CLR.L	D5
	CLR.B	D2
	BSR	VBL0
STOCK	BSR	POINTAGE
	BSR	CONVERTION
	CMP.B	#1,D2
	BEQ.S	SORTIR1
	DBF	D1,STOCK
	BSR	POINTAGE
	MOVE.W	#$EE,D1
STOCK2	BSR	CONVERTION
	DBF	D1,STOCK2
	BSR.S	POINTAGE
	MOVE.B	#1,D2
	BRA	STOCK
SORTIR1	RTS	

AFFICHE_PALETTE
	LEA	PALETTE,A0
	LEA	$FFFF9800.W,A1
	MOVE.L	#$3F,D5
	BSR	VBL0
COLOR	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBF	D5,COLOR
	RTS

*********** CONTROLE DU CLAVIER

KEY	MOVE.B	$FFFFFC02.W,D0
	CMP.B	#$39+$80,D0
	BEQ	FIN
	
	CMP.B	#$48,D0
	BEQ.S	HAUT
	
	CMP.B	#$50,D0
	BEQ.S	BAS
	
	CMP.B	#$4B,D0
	BEQ.S	GAUCHE
	
	CMP.B	#$4D,D0
	BEQ.S	DROITE
	
	BRA	KEY
	
*********** HAUT

HAUT	SUBQ.W	#PAS_Y,Y
	BPL	SCROLL
	CLR.W	Y
	BRA	SCROLL
	
*********** BAS

BAS	ADDQ.W	#PAS_Y,Y
	CMP.W	#199,Y
	BLE	SCROLL
	MOVE.W	#199,Y
	BRA	SCROLL
	
*********** DROITE

DROITE	ADD.W	#PAS_X,X
	CMP.W	#383,X
	BLE	SCROLL
	MOVE.W	#383,X
	BRA	SCROLL
	
*********** GAUCHE

GAUCHE	SUB.W	#PAS_X,X
	BPL	SCROLL
	CLR.W	X
	BRA	SCROLL
	
*********** SCROLL

SCROLL	BSR	MOVE_YOUR_BODY
	BRA	KEY
	
*********** AFFICHAGE DE LA LIGNE : A0 -> DEPART DE LA LIGNE

MOVE_YOUR_BODY
	BSR	VBL0
	MOVE.W	X,D0
	MOVE.W	D0,D1
	LSR	#1,D0
	AND.L	#$FFF8,D0
	AND.W	#$F,D1
	
	MOVE.W	Y,D2
	MULU	#384,D2
	ADD.L	D0,D2

	MOVE.L	#BUFFER,D0
	ADD.L	D2,D0
	MOVE.L	D0,STOCK_ADR
	MOVE.L	#STOCK_ADR,A0

	TST.W	D1
	BNE	HARDSCROLL_PIXELS
	BSR	HARDSCROLL_BLOCS
	RTS		
	
HARDSCROLL	BSR	VBL0
	MOVE.B	1(A0),$FFFF8205.W
	MOVE.B	2(A0),$FFFF8207.W
	MOVE.B	3(A0),$FFFF8209.W
	MOVE.B	1(A0),$FFFF8201.W
	MOVE.B	2(A0),$FFFF8203.W
	MOVE.B	3(A0),$FFFF820D.W
	RTS
	
HARDSCROLL_BLOCS
	MOVE.B	#192,$FFFF820F.W
	MOVE.B	#192,$FFFF8211.W
	MOVE.B	#0,$FFFF8265.W
	BSR	HARDSCROLL
	RTS
		
HARDSCROLL_PIXELS
	MOVE.B	#192-8,$FFFF820F.W
	MOVE.B	#192,$FFFF8211.W
	MOVE.B	D1,$FFFF8265.W
	BSR	HARDSCROLL
	RTS
	
**********************************************************************
	SECTION DATA
**********************************************************************

FORMAT_TPI	DC.W	128,140,146,164,152,170,158,176,182
	DC.W	188,194,212,200,218,206,1658,224,134

	
TEXXT	DC.B	$1B,"E",10,13,10,13
	DC.B	"*** TEST HARDSCROLL SUR FALCON 030 ***",10,13,10,13
	DC.B	" 'FLECHES' DROITES GAUCHE HAUT BAS / 'SPACE' QUIT",10,13,10,13
	DC.B	"(C) 1995 , ZANAK    ATROCITY / ATLANTIDE ",0			

IMAGE1	INCBIN	F:\BORDEL\IMAGES1.TPI
	EVEN

IMAGE2	INCBIN	F:\BORDEL\IMAGES2.TPI
	EVEN
	
**********************************************************************
	SECTION BSS
**********************************************************************

TEXTE	DS.W	2
SIZE1	DS.W	384*240+128
SIZE2	DS.W	384*240+128
PSCR	DS.W	2
LSCR	DS.W	2
REZ	DS.W	1
ECRAN1	DS.W	2
ECRAN2	DS.W	2
HBB	DS.W	1
HBL	DS.W	1
KEYBOARD	DS.B	1
BUFFER	DS.W	184320
SPACE_COWBOY	
	DS.B	64000
BUFFER_ADR	DS.W	2
PALETTE	DS.L	256
IMAGE	DS.L	1
ECRAN	DS.L	1
STOCK_ADR	DS.L	1
X	DS.W	1
Y	DS.W	1

	END