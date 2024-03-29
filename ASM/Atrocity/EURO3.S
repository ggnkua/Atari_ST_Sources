**********************************************************************
************** PREVIEW MAIN MENU EUROPARK (350eme du nom !!) *********
************** MAIN CODE BY ZANAK - (C) 1994 ATROCITY Corp.  *********
**********************************************************************  

NB_ECRANS		EQU	8
LARGEUR		EQU	320		; ECRAN X
HAUTEUR		EQU	200		; ECRAN Y
LARGEUR_TOTAL	EQU	NB_ECRANS*LARGEUR		
LARGEUR_SP	EQU	45		; SPRITE X
HAUTEUR_SP	EQU	27		; SPRITE Y
SPA		EQU	252*LARGEUR+280	; OFFSET SUR ECRAN


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

	MOVE.W	#%100100,-(SP)	; True color
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
	
	MOVE.L	#IMAGE1+128,IMAGE
	BSR	PRE_CONVERT	; CONVERTION SPRITE
	
	BSR	PRE_CONVERT_SCREEN	; CONVERTION ECRAN
	
	CLR.L	$FFFF9800.W

	MOVE.L	#IMAGE2+128,IMAGE	
	BSR.S	AFFICHE_SCREEN

** JOYSTICK
	BSR	INIT_JOY
	BSR	BOUCLE_JOYSTICK
		
FIN	BSR	RETURN_JOY
	
**********************************************************************	
*********** FIN DE LA DEMO *******************************************
**********************************************************************

;FIN	CMP.B	#$39+$80,$FFFFFC02.W
;	BNE	FIN
		
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
* AFFICHAGE D'UN ECRAN

AFFICHE_SCREEN
	MOVEA.L	IMAGE,A0
	MOVEA.L	ECRAN1,A1		
	MOVE.W	#1,D2
AFFICHE	MOVE.W	#HAUTEUR/2,D1
AFFICHE_0	MOVE.W	#2*LARGEUR-1,D0
AFFICHE_1	MOVE.W	(A0)+,(A1)+
	DBF	D0,AFFICHE_1
	ADDA.L	#2*LARGEUR,A0
	ADDA.L	#2*LARGEUR,A1
	BSR	VBL0
	DBF	D1,AFFICHE_0
	MOVEA.L	IMAGE,A0
	MOVEA.L	ECRAN1,A1		
	ADDA.L	#2*LARGEUR,A0
	ADDA.L	#2*LARGEUR,A1
	DBF	D2,AFFICHE
	RTS

AFFICHE_SCREEN2
	MOVEA.L	IMAGE,A0
	MOVEA.L	ECRAN1,A1		
AFFICHE_00
	MOVE.W	#HAUTEUR*LARGEUR-1,D0
AFFICHE_11
	MOVE.W	(A0)+,(A1)+
	DBF	D0,AFFICHE_11
	RTS
	
**********************************************************************
* DEPLACE L'ECRAN

AFFICHE_SCREEN22	
	MOVE.W	OFFSET,D0
	CMP.W	#-1,D0
	BEQ	FIN_SPRITE
;	CMP.W	#BUF_END-BUF_IMAGE-LARGEUR
	BEQ	FIN_SPRITE
	MOVEA.L	ECRAN1,A1			; ADR ECRAN
	MOVEA.L	BUF_IMAGE,A0
	ADDA.L	OFFSET,A0			; ADR BUFFER IMAGE
	MOVE.W	#HAUTEUR,D1		; HAUTEUR IMAGE
AFFICHE0	MOVE.W	#LARGEUR,D0		; LARGEUR IMAGE
AFFICHE1	MOVE.W	(A1)+,(A0)+		; AFFICHE UNE LIGNE
	DBF	D0,AFFICHE1		; 1 LARGEUR
	ADDA.L	#LARGEUR_TOTAL,A1
	SUBA.L	#LARGEUR,A1
	SUBA.L	OFFSET,A1			; OFFSET POUR LIGNE D'APRES
	DBF	D1,AFFICHE0		; 1 IMAGE
FIN_SPRITE
	RTS
	
PRE_CONVERT_SCREEN
	MOVE.L	#IMAGE2+128,IMAGE	
	MOVEA.L	IMAGE,A0
	MOVEA.L	#BUF_IMAGE,A1
	MOVE.W	#NB_ECRANS,D0
	MOVE.W	#LARGEUR,D1
P_C_S	MOVE.W	(A0)+,(A1)+
	DBF	D1,P_C_S


	
**********************************************************************
* GESTION DU JOYSTICK

INIT_JOY	MOVE.B	#$12,D0
	BSR.S	SEND
	MOVE.B	#$14,D0
	BSR.S	SEND
	LEA	$118,A0
	MOVE.L	(A0),OLD_K_VEC
	MOVE.L	#K_VECT,(A0)
	RTS
	
RETURN_JOY
	MOVE.L	OLD_K_VEC,$118.W
	MOVE.B	#8,D0
	BSR.S	SEND
	RTS
	
SEND	BTST	#1,$FFFFFC00.W
	BEQ.S	SEND
	MOVE.B	D0,$FFFFFC02.W
	RTS
	
K_VECT	MOVE.W	D0,-(SP)
	MOVE.L	A0,-(SP)
	CLR.W	D0
	MOVE.B	$FFFFFC02.W,D0
	TST.W	PACKET
	BNE.S	DEPACKET
	CMPI.B	#$FE,D0
	BEQ.S	K_JOY0
	CMPI.B	#$FF,D0
	BEQ.S	K_JOY1
	LEA	KEYBOARD0,A0
	BTST	#7,D0
	BNE.S	SUPRIME
	ST.B	0(A0,D0.W)
THE_END	MOVE.L	(SP)+,A0
	MOVE.W	(SP)+,D0
	BCLR	#6,$FFFFFA11.W
	RTE
	
K_JOY0	ST.B	PACKET
	MOVE.L	#JOY0,KEL_JOY
	BRA.S	THE_END
	
K_JOY1	ST.B	PACKET
	MOVE.L	#JOY1,KEL_JOY
	BRA.S	THE_END
	
DEPACKET	CLR.W	PACKET
	MOVE.L	KEL_JOY,A0
	MOVE.B	D0,(A0)
	BRA.S	THE_END
	
SUPRIME	BCLR	#7,D0
	CLR.B	0(A0,D0.W)
	BRA.S	THE_END
	
BOUCLE_JOYSTICK
	BSR	VBL0
;	CLR.L	$FFFF9800.W
	
	MOVE.B	JOY1,D0
	CMPI.B	#%1,D0
	BEQ.S	HAUT

	MOVE.B	JOY1,D0
	CMPI.B	#%10,D0
	BEQ.S	BAS

	MOVE.B	JOY1,D0
	CMPI.B	#%100,D0
	BEQ.S	GAUCHE

	MOVE.B	JOY1,D0
	CMPI.B	#%1000,D0
	BEQ	DROITE

	MOVE.B	JOY1,D0
	CMPI.B	#%10000000,D0
	BEQ	FIN
	
	BRA	BOUCLE_JOYSTICK

HAUT
;	MOVE.L	#$FF,$FFFF9800.W
	BRA	BOUCLE_JOYSTICK
BAS
;	MOVE.L	#$FF0000,$FFFF9800.W
	BSR	AFFICHE_UN_MORCEAU
	BRA	BOUCLE_JOYSTICK
GAUCHE	
;	MOVE.L	#$FF000000,$FFFF9800.W
	BSR	AFFICHE_SCREEN2
	
	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_2,A1
	BSR	AFFICHE_SPRITE
	BSR	AFFICHE_SCREEN2


	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_4,A1
	BSR	AFFICHE_SPRITE
	BSR	AFFICHE_SCREEN2

	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_6,A1
	BSR	AFFICHE_SPRITE
	BSR	AFFICHE_SCREEN2

	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_4,A1
	BSR	AFFICHE_SPRITE
	BSR	AFFICHE_SCREEN2

	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_2,A1
	BSR	AFFICHE_SPRITE

	BRA	BOUCLE_JOYSTICK

DROITE	
;	MOVE.L	#$FFFF00FF,$FFFF9800.W
	BSR	AFFICHE_SCREEN2

	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_1,A1
	BSR.S	AFFICHE_SPRITE
	BSR	AFFICHE_SCREEN2

	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_3,A1
	BSR.S	AFFICHE_SPRITE
	BSR	AFFICHE_SCREEN2

	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_5,A1
	BSR.S	AFFICHE_SPRITE
	BSR	AFFICHE_SCREEN2
	
	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_3,A1
	BSR.S	AFFICHE_SPRITE
	
	BSR	AFFICHE_SCREEN2

	MOVEA.L	ECRAN1,A0
	ADDA.L	#SPA,A0
	LEA.L	SPRITE_1,A1
	BSR.S	AFFICHE_SPRITE

	BRA	BOUCLE_JOYSTICK
	
AFFICHE_SPRITE						
	BSR	VBL0
	MOVE.W	#HAUTEUR_SP,D0
SPRITE0	MOVE.W	#LARGEUR_SP,D1
SPRITE1	CMP.W	#0,(A1)
	BNE.S	SPRITE2
	ADDA.W	#2,A0
	ADDA.W	#2,A1
	DBF	D1,SPRITE1
	BRA.S	FIN_LIGNE
SPRITE2	MOVE.W	(A1)+,(A0)+
	DBF	D1,SPRITE1
FIN_LIGNE	ADDA.W	#2*LARGEUR-2*LARGEUR_SP-2,A0
	DBF	D0,SPRITE0
	RTS

PRE_CONVERT
	MOVEA.L	IMAGE,A0
	ADDA.L	#2*LARGEUR+2,A0
	LEA.L	SPRITE_1,A1
	BSR.S	CONVERT

	MOVEA.L	IMAGE,A0
	ADDA.L	#2*LARGEUR+2*LARGEUR_SP+6,A0
	LEA.L	SPRITE_2,A1
	BSR.S	CONVERT

	MOVEA.L	IMAGE,A0
	ADDA.L	#2*LARGEUR+2*2*LARGEUR_SP+10,A0
	LEA.L	SPRITE_3,A1
	BSR.S	CONVERT

	MOVEA.L	IMAGE,A0
	ADDA.L	#2*LARGEUR+2*3*LARGEUR_SP+14,A0
	LEA.L	SPRITE_4,A1
	BSR.S	CONVERT

	MOVEA.L	IMAGE,A0
	ADDA.L	#2*LARGEUR+2*4*LARGEUR_SP+18,A0
	LEA.L	SPRITE_5,A1
	BSR.S	CONVERT

	MOVEA.L	IMAGE,A0
	ADDA.L	#2*LARGEUR+2*5*LARGEUR_SP+22,A0
	LEA.L	SPRITE_6,A1
	BSR.S	CONVERT

	RTS
	
CONVERT	MOVE.W	#HAUTEUR_SP,D0
CONVERT1	MOVE.W	#LARGEUR_SP,D1
CONVERT2	MOVE.W	(A0)+,(A1)+
	DBF	D1,CONVERT2
	ADDA.W	#2*LARGEUR-2*LARGEUR_SP-2,A0
	DBF	D0,CONVERT1
	RTS
		
AFFICHE_UN_MORCEAU
	MOVEA.L	ECRAN1,A0
	MOVEA.L	#IMAGE1+128,A1
	MOVE.W	#HAUTEUR_SP,D0
ENCORE0	MOVE.W	#LARGEUR_SP,D1
ENCORE1	MOVE.W	(A1)+,(A0)+
	DBF	D1,ENCORE1
	ADDA.W	#2*LARGEUR-2*LARGEUR_SP-2,A0
	ADDA.W	#2*LARGEUR-2*LARGEUR_SP-2,A1
	DBF	D0,ENCORE0
	RTS
	
**********************************************************************
	SECTION DATA
**********************************************************************

TEXT	DC.B	$1B,"E"
	DC.B	0

IMAGE1	INCBIN	F:\BORDEL\ARTEK.TPI
	EVEN

IMAGE2	INCBIN	F:\BORDEL\ARTEK2.TPI
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
OFFSET	DS.L	1
BUF_IMAGE	DS.W	8*LARGEUR*HAUTEUR
BUF_END	DS.W	1
IMAGE	DS.L	1
PACKET	DS.W	1
KEL_JOY	DS.L	1
JOY0	DS.B	1
JOY1	DS.B	1
KEYBOARD0	DS.B	128
OLD_K_VEC	DS.L	1
SPRITE_1	DS.W	2*(LARGEUR_SP*HAUTEUR_SP)
SPRITE_2	DS.W	2*(LARGEUR_SP*HAUTEUR_SP)
SPRITE_3	DS.W	2*(LARGEUR_SP*HAUTEUR_SP)
SPRITE_4	DS.W	2*(LARGEUR_SP*HAUTEUR_SP)
SPRITE_5	DS.W	2*(LARGEUR_SP*HAUTEUR_SP)
SPRITE_6	DS.W	2*(LARGEUR_SP*HAUTEUR_SP)
	
	END