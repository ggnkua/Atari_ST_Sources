**********************************************************************
************** INTRODUCTION DEMO ATROCITY - FLI BY RAZORBACK *********
************** MAIN CODE BY ZANAK - (C) 1994 ATROCITY Corp.  *********
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

	MOVE.W	#%100011,-(SP)	
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
	
	LEA	IMG_GIF,A0
	MOVE.L	#BUF_POZ,A6
	
*********** ON TESTE LE DESCRIPTEUR DE GIF

	CMPI.L	#'GIF8',(A0)
	BNE	.FIN_DEC_GIF
	ADDQ.W	#4,A0
	CMPI.W	#'7a',(A0)
	BNE	.FIN_DEC_GIF
	ADDQ.W	#2,A0

*********** ON ANALYSE LE 'SCREEN DESCRIPTOR'
	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D0		;POIDS FAIBLE DE LA LONGUEUR
	MOVE.B	(A0)+,D1		;POIDS FORT DE LA LONGUEUR
	LSL.W	#8,D1
	OR.W	D1,D0		;D0=LONGUEUR SUR 16 BITS
	MOVEQ	#0,D2
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1		;POIDS FAIBLE DE LA HAUTEUR
	MOVE.B	(A0)+,D2		;POIDS FORT DE LA HAUTEUR
	LSL.W	#8,D2
	OR.W	D2,D1		;D1=HAUTEUR SUR 16 BITS
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D2
	MOVE.L	D2,D3
	LSR.W	#7,D3		;BIT M DU BYTE 5
	MOVE.W	D2,D4
	ANDI.W	#$7F,D4
	LSR.W	#4,D4
	ADDQ.W	#1,D4
	ANDI.W	#7,D2
	ADDQ.W	#1,D2		;D4='PIXEL+1'
	MOVE.B	(A0)+,D5		;D5=INDEX DES COULEURS
	ADDQ.W	#1,A0		;ON SAUTE LE BYTE A 0
	MOVE.W	D0,LONG_SCREEN
	MOVE.W	D1,HIGH_SCREEN

*********** ON PENETRE DANS LA GLOBAL COLOR MAP (GCM)

	CMPI.B	#1,D3
	BEQ.S	.SUITE		;SI M=1, LA GLOBAL COLOR MAP 
				;SUIT LE SCREEN DESCRIPTOR
				;SINON ON INDEXE...
	NOP
.SUITE	

*********** D'ABORD ON CALCULE LE COEFFICIENT POUR LA PALETTE 
*********** CAR LE FAL-CON NE SUPPORTE PAS LE 24 BITS

	MOVE.W	#64*8,D7		;D7=2^6, 6 BITS, ENFIN!
	DIVU.W	#256,D7
	
	MOVE.W	#$9800,A1
	MOVE.W	#255,D5
.MAKE_TB_COLOR	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D0		;INTENSITê ROUGE
	MOVE.B	(A0)+,D1		;INTENSITê VERTE
	MOVE.B	(A0)+,D2		;INTENSITê BLEUE
	MULS.W	D7,D0
	LSR.W	#1,D0		;LES 6 BITS SONT DANS LE POIDS FORT
	MULS.W	D7,D1
	LSR.W	#1,D1		;IDEM
	MULS.W	D7,D2
	LSR.W	#1,D2		;IDEM

*********** ON ASSEMBLE UNE COULEURS DANS 1 LONG

	LSL.W	#8,D0
	SWAP	D0
	SWAP	D1
	OR.L	D1,D0
	OR.W	D2,D0		;D0=COULEUR!
	MOVE.L	D0,(A1)+
	DBRA	D5,.MAKE_TB_COLOR

*********** ON ARRIVE A L'"IMAGE DESCRIPTOR"!!!

	CMPI.B	#$2C,(A0)+		;$2C=IMAGE SEPARATOR CHARACTER
	BNE	.FIN_DEC_GIF
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D0    	;POIDS FAIBLE DE L'OFFSET HORIZONTAL
	MOVE.B	(A0)+,D1    	;POIDS FORT DE L'OFFSET HORIZONTAL
	LSL.W	#8,D1
	OR.W	D1,D0		;D0=OFFSET HORIZONTAL SUR 16 BITS
	MOVEQ	#0,D2
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1		;POIDS FAIBLE DE L'OFFSET VERTICAL
	MOVE.B	(A0)+,D2		;POIDS FORT DE L'OFFSET VERTICAL
	LSL.W	#8,D2
	OR.W	D2,D1		;D1=OFFSET VERTICAL SUR 16 BITS
	MOVE.W	D0,OFFSET_H
	MOVE.W	D1,OFFSET_V
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D0		;POIDS FAIBLE DE LA LONGUEUR
	MOVE.B	(A0)+,D1		;POIDS FORT DE LA LONGUEUR
	LSL.W	#8,D1
	OR.W	D1,D0		;D0=LONGUEUR SUR 16 BITS
	MOVEQ	#0,D2
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1		;POIDS FAIBLE DE LA HAUTEUR
	MOVE.B	(A0)+,D2		;POIDS FORT DE LA HAUTEUR
	LSL.W	#8,D2
	OR.W	D2,D1		;D1=HAUTEUR SUR 16 BITS
	MOVE.W	D0,LONG
	MOVE.W	D1,HIGH
	MOVE.B	(A0)+,D0		;OCTET 10 DE L'IMAGE DESCRIPTOR
	BTST	#7,D0		;ON TESTE LE BIT 'M'
	BEQ.S	.IGNORE_PIXEL
	NOP
.IGNORE_PIXEL
	BTST	#6,D0		;ON TESTE LE BIT 'I'
	BEQ.S	.SEQUENTIAL
.INTERLACED	SF	FLAG_SEQUENTIAL
	BRA.S	.SUIT2
.SEQUENTIAL	ST	FLAG_SEQUENTIAL
.SUIT2	
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0		;TAILLE EN BITS DES DONNêES DE 
				;L'ACTUELLE RASTER DATA STREAM
	SUBQ.W	#1,D0
	MOVEQ	#0,D7
	MOVE.B	(A0)+,D7		;NB D'OCTETS A EXAMINER
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D2
	SUBQ.W	#1,D7
;	LSL.W	#8,D2
	MOVEQ	#8,D5
.CONT_TAKE	MOVE.W	D0,D1
.DECAL	ROR.L	#1,D2
	SUBQ.W	#1,D5
	BNE.S	.PAS_VIDE
	MOVE.B	(A0)+,D2
	SUBQ.W	#1,D7
;	LSL.W	#8,D2
	MOVEQ	#8,D5	
.PAS_VIDE	DBRA	D1,.DECAL
	SWAP	D2		;POIDS_FAIBLE=DATA
	LSR.W	#8,D2
	MOVE.W	D2,(A6)+
	CLR.W	D2
	SWAP	D2
	TST.W	D7
	BGT.S	.CONT_TAKE

.FIN_DEC_GIF

	MOVE.B	HIGH_SCREEN,$FFFF8201.W
	MOVE.B	LONG_SCREEN,$FFFF8203.W
	
**********************************************************************	
*********** FIN DE LA DEMO *******************************************
**********************************************************************

FIN	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	FIN
		
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
	
**********************************************************************
	SECTION DATA
**********************************************************************

TEXT	DC.B	$1B,"E"
	DC.B	0

IMG_GIF	INCBIN	E:\GIF.GIF
	EVEN
				
**********************************************************************
	SECTION BSS
**********************************************************************

TEXTE	DS.W	2
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
LONG_SCREEN	DS.W	1
HIGH_SCREEN	DS.W	1
LONG	DS.W	1
HIGH	DS.W	1
OFFSET_H	DS.W	1
OFFSET_V	DS.W	1
FLAG_SEQUENTIAL	
	DS.B	1
BUF_POZ	DS.B	150000

	END