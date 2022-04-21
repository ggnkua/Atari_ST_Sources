**********************************************************************
************** ANTAGO SCREEN - JUILLET 94 - ZANAK *******************
**********************************************************************

TAILLE_BUF	EQU	100
VITESSE	EQU	2
FAD_COLOR	EQU	$FFFF9834
WAIT_VAR	EQU	$55

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

************** PROGRAMME PRINCIPAL ***********************************

	BSR	INIT_SHIP
	
	MOVE.L	#BIG,$4D2
			
	BSR	PAL_TPI
	BSR	VALID_PALETTE	
	
	MOVE.L	#0,FAD_COLOR.W	; NOIRE SUR LE LOGO
	MOVE.L	#0,$FFFF9800.W	; NOIRE SUR LE FOND


************** PREMIERE IMAGE ****************************************

	LEA	IMAGE1,A0	; 1ER IMAGE
	MOVEA.L	ECRAN1(A6),A1
	SUB.W	#1664,A1
	MOVE.W	#32000,D7
MOVE1	MOVE.W	(A0)+,(A1)+	; ON AFFICHE
	DBF	D7,MOVE1

	MOVE.L	$466.W,D0	
VBL1_1	CMP.L	$466.W,D0	; ON ATTEND L'IMAGE
	BEQ.B	VBL1_1
	
	MOVE.W	#$3C,D7	; UN FADE IN
FADEIN1	ADDI.L	#$4040004,FAD_COLOR.W

	MOVE.L	$466.W,D0
VBL1_2	CMP.L	$466.W,D0
	BEQ.B	VBL1_2

	DBF	D7,FADEIN1

	BSR	WAIT
	
	MOVE.W	#$3C,D7	; UN FADE OUT
FADEOUT1	SUBI.L	#$4040004,FAD_COLOR.W
	
	MOVE.L	$466.W,D0
VBL1_3	CMP.L	$466.W,D0
	BEQ.B	VBL1_3
	
	DBF	D7,FADEOUT1	

************** DEUXIEME IMAGE ****************************************

	LEA	IMAGE2,A0	; 2ER IMAGE
	MOVEA.L	ECRAN1(A6),A1
	SUB.W	#1664,A1
	MOVE.W	#32000,D7
MOVE2	MOVE.W	(A0)+,(A1)+	; ON AFFICHE
	DBF	D7,MOVE2

	MOVE.L	$466.W,D0	
VBL2_1	CMP.L	$466.W,D0	; ON ATTEND L'IMAGE
	BEQ.B	VBL2_1
	
	MOVE.W	#$3C,D7	; UN FADE IN
FADEIN2	ADDI.L	#$4040004,FAD_COLOR.W

	MOVE.L	$466.W,D0
VBL2_2	CMP.L	$466.W,D0
	BEQ.B	VBL2_2

	DBF	D7,FADEIN2

	BSR	WAIT
	
	MOVE.W	#$3C,D7	; UN FADE OUT
FADEOUT2	SUBI.L	#$4040004,FAD_COLOR.W
	
	MOVE.L	$466.W,D0
VBL2_3	CMP.L	$466.W,D0
	BEQ.B	VBL2_3
	
	DBF	D7,FADEOUT2	

	BSR	CLS
	
************** SCROLL IMAGE *****************************************

	MOVE.L	IMAGE,D0
	AND.L	#-8,D0
	MOVE.L	D0,IMAGE	

	BSR	ARRIVER
	MOVE.L	#PRECALC2-$CA,A5
	MOVEQ.L	#0,D7
	BSR	BOUCLE1
	
	BSR	WAIT
	
	BSR	PARTIR	
	MOVE.L	#PRECALC1-$CA,A5
	MOVEQ.L	#0,D7
	BSR	BOUCLE2

	BSR	CLS
	
************** TROISIEME IMAGE ****************************************

	MOVE.W	#0,FAD_COLOR.W
	
	LEA	IMAGE3,A0	; 3ER IMAGE
	ADD.L	#$300,A0
	MOVEA.L	ECRAN1(A6),A1
	SUB.W	#1664,A1
	MOVE.W	#32000,D7
MOVE3	MOVE.W	(A0)+,(A1)+	; ON AFFICHE
	DBF	D7,MOVE3

	MOVE.L	$466.W,D0	
VBL3_1	CMP.L	$466.W,D0	; ON ATTEND L'IMAGE
	BEQ.B	VBL3_1
	
	MOVE.W	#$3C,D7	; UN FADE IN
FADEIN3	ADDI.L	#$4040004,FAD_COLOR.W

	MOVE.L	$466.W,D0
VBL3_2	CMP.L	$466.W,D0
	BEQ.B	VBL3_2

	DBF	D7,FADEIN3

	BSR	WAIT
	
	MOVE.W	#$3C,D7	; UN FADE OUT
FADEOUT3	SUBI.L	#$4040004,FAD_COLOR.W
	
	MOVE.L	$466.W,D0
VBL3_3	CMP.L	$466.W,D0
	BEQ.B	VBL3_3
	
	DBF	D7,FADEOUT3	

;	MOVE.W	#0,FAD_COLOR.W	

PRESS	MOVE.W	#1,-(A7)
	TRAP	#1
	ADDA.L	#2,A7
	
	BSR	STOP_SHIP
	MOVE.L	#BIG,$4D2
	
**********************************************************************
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
	
**********************************************************************

	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
	
***********************************************************************	
************** SOUS ROUTINES ******************************************
***********************************************************************

************** DECODAGE COULEURS IMAGE TPI ****************************

PAL_TPI	LEA.L	VIDEL,A1
	LEA.L	IMAGE+128+0*6,A0
	BSR	COLOR	; 0
	LEA.L	IMAGE+128+2*6,A0
	BSR	COLOR	; 1
	LEA.L	IMAGE+128+3*6,A0
	BSR	COLOR	; 2
	LEA.L	IMAGE+128+6*6,A0
	BSR.S	COLOR	; 3
	LEA.L	IMAGE+128+4*6,A0
	BSR.S	COLOR	; 4
	LEA.L	IMAGE+128+7*6,A0
	BSR.S	COLOR	; 5
	LEA.L	IMAGE+128+5*6,A0
	BSR.S	COLOR	; 6
	LEA.L	IMAGE+128+8*6,A0
	BSR.S	COLOR	; 7
	LEA.L	IMAGE+128+9*6,A0
	BSR.S	COLOR	; 8
	LEA.L	IMAGE+128+10*6,A0
	BSR.S	COLOR	; 9
	LEA.L	IMAGE+128+11*6,A0
	BSR.S	COLOR	; 10
	LEA.L	IMAGE+128+14*6,A0
	BSR.S	COLOR	; 11
	LEA.L	IMAGE+128+12*6,A0
	BSR.S	COLOR	; 12
	LEA.L	IMAGE+128+15*6,A0
	BSR.S	COLOR	; 13
	LEA.L	IMAGE+128+13*6,A0
	BSR.S	COLOR	; 14
	LEA.L	IMAGE+128+255*6,A0
	BSR.S	COLOR	; 15

	LEA.L	IMAGE+128+16*6,A0	; 16 … 254
	MOVE.W	#238,D7
CONVERT	BSR.S	COLOR
	DBRA	D7,CONVERT

	LEA.L	IMAGE+128+1*6,A0
	BSR.S	COLOR	; COULEUR 255
	RTS

COLOR	MOVE.W	(A0)+,D0	; ROUGE
	LSR.W	#4,D0
	LSL.W	#2,D0
	MOVE.B	D0,(A1)+
	MOVE.W	(A0)+,D0	; VERT
	LSR.W	#4,D0
	LSL.W	#2,D0
	MOVE.B	D0,(A1)+
	CLR.B	(A1)+	; OCTET NUL
	MOVE.W	(A0)+,D0	; BLEU
	LSR.w	#4,D0
	LSL.w	#2,D0
	MOVE.B	D0,(A1)+
	RTS

VALID_PALETTE	MOVE.W	#256-1,D7
	LEA.L	VIDEL,A0
	LEA.L	$FFFF9800,A1
PALETTE2	MOVE.L	(A0)+,(A1)+
	DBRA	D7,PALETTE2
	RTS	

************** SCROLL VERTICAL IMAGE ********************************

PARTIR	MOVEA.L	#PRECALC1,A1
	MOVE.L	#$64,D1
	MOVE.L	#$C8,D2
DECAL1	MOVE.W	D2,-(A1)
	SUB.W	#VITESSE,D2
	DBF	D1,DECAL1
	RTS

ARRIVER	MOVEA.L	#PRECALC2,A1
	MOVE.L	#$64,D1
	MOVE.L	#0,D2
DECAL2	MOVE.W	D2,-(A1)
	ADD.W	#VITESSE,D2
	DBF	D1,DECAL2
	RTS

BOUCLE1	MOVE.W	#$25,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP

	MOVE.L	#IMAGE+1664,D0
	MOVE.L	(A5),D1
	MOVE.W	D1,D2
	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D2,D1
	LSL.W	#5,D1
	EXT.L	D1
	ADD.L	D1,D1
	ADD.L	D1,D0
	
	MOVE.L	D0,D1
	MOVE.L	D1,D2
	LSR.W	#8,D1
	SWAP.W	D0
	MOVE.B	D0,$FFFF8201.W
	MOVE.B	D1,$FFFF8203.W
	MOVE.B	D2,$FFFF820D.W
	MOVE.B	D0,$FFFF8205.W
	MOVE.B	D1,$FFFF8207.W
	MOVE.B	D2,$FFFF8209.W
	
	MOVEQ.L	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	
	ADDQ.L	#2,A5
	
	ADDQ.L	#1,D7
	CMP.L	#TAILLE_BUF,D7
	BEQ.S	SUITE1
	BRA	BOUCLE1
SUITE1	NOP
	RTS

BOUCLE2	MOVE.W	#$25,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP

	MOVE.L	#IMAGE+1664,D0
	MOVE.L	(A5),D1
	MOVE.W	D1,D2
	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D2,D1
	LSL.W	#5,D1
	EXT.L	D1
	ADD.L	D1,D1
	ADD.L	D1,D0
	
	MOVE.L	D0,D1
	MOVE.L	D1,D2
	LSR.W	#8,D1
	SWAP.W	D0
	MOVE.B	D0,$FFFF8201.W
	MOVE.B	D1,$FFFF8203.W
	MOVE.B	D2,$FFFF820D.W
	MOVE.B	D0,$FFFF8205.W
	MOVE.B	D1,$FFFF8207.W
	MOVE.B	D2,$FFFF8209.W
	
	MOVEQ.L	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	
	ADDQ.L	#2,A5
		
	ADDQ.L	#1,D7
	CMP.L	#TAILLE_BUF,D7
	BEQ.S	SUITE2
	BRA	BOUCLE2
SUITE2	NOP
	RTS	

CLS	MOVEA.L	ECRAN1(A6),A1
	SUB.W	#$600,A1
	MOVE.W	#$FA00,D0
CLS1	CLR.L	(A1)+
	DBF	D0,CLS1
	RTS

WAIT	MOVE.L	#WAIT_VAR,D0
	MOVE.L	#1,D1
WAIT1	SUB.W	#1,D0
WAIT2	SUB.W	#1,D1
	DBF	D1,WAIT2
	DBF	D0,WAIT1
	RTS	
	
INIT_SHIP	MOVEQ	#1,D0
	JSR	ALEC
	RTS
	
STOP_SHIP	MOVEQ	#0,D0
	JSR	ALEC
	
BIG	JSR	ALEC+8
	RTS
	
**********************************************************************
	SECTION DATA
**********************************************************************

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0
ALEC	INCBIN	E:\TOTF\BIGALEC.SND
	EVEN
IMAGE1	INCBIN	E:\TOTF\ATROCITY.TPI
	EVEN
IMAGE2	INCBIN	E:\TOTF\PRESENTS.TPI
	EVEN
IMAGE3	INCBIN	E:\TOTF\CODEDBYZ.TPI
	EVEN
IMAGE	INCBIN	E:\TOTF\ARNOLD.TPI
	EVEN			

	
**********************************************************************
	SECTION BSS
**********************************************************************

SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128
VIDEL	DS.L	256
PRECALC1	DS.L	100
PRECALC2	DS.L	100
VAR	DS.W	48
PSCR	RS.W	2
LSCR	RS.W	2
REZ	RS.W	1
ECRAN1	RS.W	2
ECRAN2	RS.W	2

		
	END