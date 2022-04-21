**********************************************************************
************** END PART HARDSCROLL TRUE COLOR - MARS 1995 ************
************** CODED BY ZANAK - (C) 1995 ATROCITY Corp.   ************
**********************************************************************  

LAR_ECR	EQU	320
HAU_ECR	EQU	200
NB_ECR	EQU	6
OFFSET	EQU	50

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

	MOVE.W	#%1100100,-(SP)	
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

	CLR.L	$FFFF9800.W

	BSR	IMAGES
;	BSR.S	RANGER_LES_IMAGES
;	BSR	HARDSCROLL
	
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
	
RANGER_LES_IMAGES
	LEA	BUFFER,A0
	ADDA.L	#2*LAR_ECR*HAU_ECR,A0
	
	LEA	IMAGE1,A1
	ADDA.L	#128,A1
	MOVE.W	#LAR_ECR*HAU_ECR,D0
COPY1	MOVE.W	(A1)+,(A0)+
	DBF	D0,COPY1

	LEA	IMAGE2,A1
	ADDA.L	#128,A1
	MOVE.W	#LAR_ECR*HAU_ECR,D0
COPY2	MOVE.W	(A1)+,(A0)+
	DBF	D0,COPY2

	LEA	IMAGE3,A1
	ADDA.L	#128,A1
	MOVE.W	#LAR_ECR*HAU_ECR,D0
COPY3	MOVE.W	(A1)+,(A0)+
	DBF	D0,COPY3

	LEA	IMAGE4,A1
	ADDA.L	#128,A1
	MOVE.W	#LAR_ECR*HAU_ECR,D0
COPY4	MOVE.W	(A1)+,(A0)+
	DBF	D0,COPY4
	
	RTS
		
HARDSCROLL
	MOVE.W	#HAU_ECR*2,D0
	MOVE.L	#BUFFER,D2
	ADD.B	#$FF,D2
	CLR.B	D2
	
MOVE	BSR	VBL0
	MOVE.L	D2,D1
	SWAP	D1
	MOVE.B	D1,$FFFF8201.W
	SWAP	D1	
	MOVE.B	D1,D3
	LSR.W	#8,D1
	MOVE.B	D1,$FFFF8203.W
	MOVE.B	D3,$FFFF820D.W
	BSR	VBL0
	ADD.L	#LAR_ECR*4,D2
	DBF	D0,MOVE
	RTS
	
IMAGES	LEA	BUF_IMAGE,A0
	MOVE.L	A0,D0
	ADD.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,D1
	MOVE.L	D0,A1
	
	LEA	IMAGE1+128,A0
;	LEA	BUF_IMAGE,A1
	MOVE.L	#2*92160,D0
IMAGESA	MOVE.L	(A0)+,(A1)+
	DBF	D0,IMAGESA
	

;	MOVE.L	D0,D1
	
;	MOVE.L	BUF_IMAGE,D0
;	AND.L	#-8,D0
;	MOVE.L	D0,BUF_IMAGE
	
	
IMAGESB	CLR.B	$FFFF820F.W
	CLR.B	$FFFF8265.W
	MOVE.W	#384,$FFFF8210.W
	SWAP	D1	
	MOVE.B	D1,D3
	SWAP	D1
	MOVE.B	D1,D2
	LSR.W	#8,D1
	MOVE.B	D3,$FFFF8201.W
	MOVE.B	D1,$FFFF8203.W
	MOVE.B	D2,$FFFF820D.W
	RTS
	
**********************************************************************
	SECTION DATA
**********************************************************************

TEXT	DC.B	$1B,"E"
	DC.B	0

IMAGE1	INCBIN	E:\DIAMONDS.TPI		; ECRAN JEU
	EVEN

IMAGE2	
;INCBIN	E:\ATROCITY.TPI		; LOGO 1
	EVEN

IMAGE3	
;INCBIN	E:\PRESENTS.TPI		; LOGO 2
	EVEN

IMAGE4	
;INCBIN	E:\DIAMOND2.TPI		; LOGO 3
	EVEN

IMAGE5	
;INCBIN	E:\PACMAN.TPI		; PRESENTATION
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
BUF_IMAGE	DS.W	384*240+256
BUFFER	DS.W	6*320*200+256

	END