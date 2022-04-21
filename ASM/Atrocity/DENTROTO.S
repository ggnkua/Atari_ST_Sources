**********************************************************************
************** AKRYLIK SCREEN - JUILLET 94 - ZANAK *******************
**********************************************************************

TAILLE_BUF	EQU	100
VITESSE	EQU	2
ZANAK	EQU	144
OFFSET	EQU	3824

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

	MOVE.W	#%10010010,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1,-(SP)
	MOVE.L	ECRAN2,-(SP)
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

PALETTE1	MOVE.L	#IMAGE+2,A0
	MOVE.L	#$FFFF8240,A1
	MOVE.L	#15,D0
PALETTE2	MOVE.W	(A0)+,(A1)+
	DBF	D0,PALETTE2

	MOVE.L	IMAGE,D0
	AND.L	#-8,D0
	MOVE.L	D0,IMAGE	
	
	BSR	ARRIVER

	MOVE.L	#PRECALC2-$CA,A5
	MOVEQ.L	#0,D7
	BSR	BOUCLE1

	BSR	AFFICHE_IMAGE
	
;	BSR	AFFICHE_TX
	
PRESS	MOVE.W	#1,-(A7)
	TRAP	#1
	ADDA.L	#2,A7
	
	BSR	PARTIR	
	MOVE.L	#PRECALC1-$CA,A5
	MOVEQ.L	#0,D7
	BSR	BOUCLE2
	
**********************************************************************
**********************************************************************

BYE	MOVE.L	#MOUSON,-(SP)	; REMET LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	
**********************************************************************

	MOVE.W	REZ,-(SP)	; REMET LA REZ
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR,-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR,-(SP)	; REMET ECRAN LOGIQUE
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
VBL	MOVE.L	$466.W,D7
VBL1	CMP.L	$466.W,D7
	BEQ.B	VBL1
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

PALETTE11	MOVE.L	#IMAGE+2,A0
	MOVE.L	#$FFFF8240,A1
	MOVE.L	#15,D0
PALETTE21	MOVE.W	(A0)+,(A1)+
	DBF	D0,PALETTE21

	MOVE.L	#IMAGE+34,D0
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

	MOVE.L	#IMAGE+34,D0
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

AFFICHE_TX	CLR.L	D0
	CLR.L	D6
	LEA	TEXTE,A5
TAILLE	MOVE.B	(A5)+,D0
	CMP.B	#0,D0
	BEQ.S	DEBUT
	ADDQ.W	#1,D6
	BRA	TAILLE
	

DEBUT	LEA	TEXTE,A5
	SUBQ.B	#1,D6
	MOVE.L	ECRAN1,A0
	SUB.L	#16180,A0
LETTRE	CLR.L	D0
	MOVE.B	(A5)+,D0
	SUB.B	#$41,D0

POINTE_LET	CMP.B	#9,D0
	BLE.S	LIGNE_1

	CMP.B	#19,D0
	BLE.S	LIGNE_2

	CMP.B	#29,D0
	BLE.S	LIGNE_3

	CMP.B	#39,D0
	BLE.S	LIGNE_4

LIGNE_5	SUB.L	#49,D0
	LSL.L	#4,D0
	ADD.L	#$2710,D0
	BRA.S	AFFICHE_LET

LIGNE_1	LSL.L	#4,D0
	BRA.S	AFFICHE_LET

LIGNE_2	SUB.L	#$14,D0
	LSL.L	#4,D0
	ADD.L	#$7D0,D0
	BRA.S	AFFICHE_LET

LIGNE_3	SUB.L	#$28,D0
	LSL.L	#4,D0
	ADD.L	#$FA0,D0
	BRA.S	AFFICHE_LET

LIGNE_4	SUB.L	#$3C,D0
	LSL.L	#4,D0
	ADD.L	#$1770,D0
	
AFFICHE_LET	MOVE.L	#23,D1
	LEA	M1+34,A1	
	ADDA.L	D0,A1
AFFICHE	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	
	ADD.W	#ZANAK,A0	
	ADD.W	#ZANAK,A1

	DBF	D1,AFFICHE
	ADDA.W	#-OFFSET,A0	
	BSR	VBL	
	DBF	D6,LETTRE

	RTS
	
AFFICHE_IMAGE
	BSR	VBL

	LEA	ECRAN1,A0
	MOVE.L	(A0),D0
	MOVE.L	D0,D1
	MOVE.B	D0,$FFFF820D.W
	LSR.W	#8,D0
	MOVE.B	D0,$FFFF8203.W
	SWAP	D0
	MOVE.B	D0,$FFFF8201.W

	MOVE.L	D1,D0
	MOVE.B	D0,$FFFF8209.W
	LSR.W	#8,D0
	MOVE.B	D0,$FFFF8207.W
	SWAP	D0
	MOVE.B	D0,$FFFF8205.W

	LEA	IMAGE+34,A0

	LEA	ECRAN1,A1
	MOVE.L	#32000,D0
AFFICHE_IMAGE_NOW
	MOVE.W	(A0)+,(A1)+
	DBF	D0,AFFICHE_IMAGE_NOW
	RTS
		
**********************************************************************
	SECTION DATA
**********************************************************************

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0

M1	INCBIN	D:\IMAGES\PI1.ZAK\M1.PI1
	EVEN

;M2	INCBIN	D:\IMAGES\PI1.ZAK\M2.PI1
;	EVEN

;M3	INCBIN	D:\IMAGES\PI1.ZAK\M3.PI1
;	EVEN
			
TABLE	DC.B	"ABCDEFGHIJ",$10
	DC.B	"KLMNOPQRST",$10
	DC.B	"UVWXYZ,.!?",$10
	DC.B	"1234567890",0

	
TEXTE	DC.B	"ABKLFF",0

IMAGE	INCBIN	D:\IMAGES\PI1.ZAK\ARTEK2\ATRO2.PI1

**********************************************************************
	SECTION BSS
**********************************************************************

SPACE_COWBOY	DS.B	32000
SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128
VIDEL	DS.L	256
PRECALC1	DS.L	100
PRECALC2	DS.L	100
PSCR	DS.W	2
LSCR	DS.W	2
REZ	DS.W	1
ECRAN1	DS.W	2
ECRAN2	DS.W	2

		
	END