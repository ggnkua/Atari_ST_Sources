**********************************************************************
*********************** HARDSCROLL HORIZONTAL ************************
************** CODED BY ZANAK - (C) 1994 , ATROCITY Corp.  ***********
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
	BMI	FIN	; SI OUI FIN SINON
			; ON CONTINUE ...

**********************************************************************

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.B	$FFFF8900.W		; IT DMA OFF
	CLR.B	$FFFF8901.W		; DMA STOP

************** CLS ***************************************************

	PEA	TEXT(PC)
	MOVE.W	#$9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

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
	MOVE.L	#IMAGE2,IMAGE
	BSR	PREPARATION_DE_LA_PALETTE	
	BSR	AFFICHE_PALETTE
	BSR	PREPARATION_IMAGE

;	BSR	AFFICHE_ECRAN
	BSR	MOOOVE_YOUR_BODY
	
**********************************************************************	
*********** FIN DE LA DEMO *******************************************
**********************************************************************

FIN	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	FIN

	MOVE.B	#0,$FFFF8265.W
		
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

VBL0	MOVE.L	$466.W,D7
VBL1	CMP.L	$466.W,D7
	BEQ.B	VBL1
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

*********** AFFICHAGE DE LA LIGNE : A0 -> DEPART DE LA LIGNE

CALCUL_OFFSET
	MOVE.L	#384,D4
	SUB.L	D1,D4
	RTS
	
AFFICHE_UNE_LIGNE
	MOVE.L	#191,D6
	ADD.L	D1,A0
LIGNE	MOVE.W	(A0)+,(A1)+
	DBF	D6,LIGNE
	RTS

AFFICHE_UNE_IMAGE
	BSR	CALCUL_OFFSET			
	MOVE.L	#240,D5
AFF_IM1	BSR	AFFICHE_UNE_LIGNE
	ADD.L	D4,A0
	DBF	D5,AFF_IM1
	RTS
	
DECALAGE_0_F
	MOVE.B	#$F,D2
	MOVE.B	#0,D3
DECALAGE_F	ADD.B	#1,D3
	MOVE.B	D3,$FFFF8265.W
	DBF	D2,DECALAGE_F
	RTS
	
FIXE_ADRESSE_VIDEO
	MOVE.B	#$F,D3
	MOVE.B	#7,D4
FIXE	MOVE.L	ECRAN2,D2
	MOVE.L	ECRAN1,ECRAN2
	MOVE.L	D2,ECRAN1
	LSR.W	#8,D2
	MOVE.B	D2,$FFFF8203.W
	SWAP	D2
	MOVE.B	D2,$FFFF8201.W
	MOVE.L	#$F,D5
BOUCLE	MOVE.B	D5,$FFFF8265.W
	MOVE.W	#320,$FFFF820E.W
	DBF	D5,BOUCLE
	BSR	VBL0
	RTS
	
MOOOVE_YOUR_BODY
	MOVE.L	#BUFFER,A0
	MOVE.L	ECRAN2,A1
	MOVE.L	#24,D0
	MOVE.L	#0,D1
MO_YO_BO	BSR	AFFICHE_UNE_IMAGE
	BSR	FIXE_ADRESSE_VIDEO
	MOVE.L	#BUFFER,A0
	MOVE.L	ECRAN2,A1
	ADD.W	#16,D1	
	BSR	VBL0
	DBF	D0,MO_YO_BO
	RTS
	
		
**********************************************************************
	SECTION DATA
**********************************************************************

FORMAT_TPI	DC.W	128,140,146,164,152,170,158,176,182
	DC.W	188,194,212,200,218,206,1658,224,134

TEXT	DC.B	$1B,"E"
	DC.B	0

IMAGE1	INCBIN	E:\IMAGES2.TPI
	EVEN

IMAGE2	INCBIN	E:\IMAGES2.TPI
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
BUFFER_ADR	DS.W	2
PALETTE	DS.L	256
IMAGE	DS.L	1
ECRAN	DS.L	1
	END