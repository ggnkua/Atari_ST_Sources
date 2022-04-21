**********************************************************************
************** AKRYLIK SCREEN - JUILLET 94 - ZANAK *******************
**********************************************************************

TAILLE_BUF	EQU	100
VITESSE	EQU	2

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
	MOVE.L	IMAGE,D0
	AND.L	#-8,D0
	MOVE.L	D0,IMAGE	

	BSR.S	PAL_TPI
	BSR	VALID_PALETTE
	
	BSR	ARRIVER
	MOVE.L	#PRECALC2-$CA,A5
	MOVEQ.L	#0,D7
	BSR	BOUCLE1
	
	BSR	PARTIR	
	MOVE.L	#PRECALC1-$CA,A5
	MOVEQ.L	#0,D7
	BSR	BOUCLE2
	
PRESS	MOVE.W	#1,-(A7)
	TRAP	#1
	ADDA.L	#2,A7
	


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
	
**********************************************************************

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
	
;	SUBQ.L	#2,A5
	ADDQ.L	#2,A5
		
	ADDQ.L	#1,D7
	CMP.L	#TAILLE_BUF,D7
	BEQ.S	SUITE2
	BRA	BOUCLE2
SUITE2	NOP
	RTS	

**********************************************************************
	SECTION DATA
**********************************************************************

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0
IMAGE	INCBIN	F:\IMAGES\TPI.ZAK\ATROCITY.TPI
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