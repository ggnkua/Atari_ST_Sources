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
	BMI	BYE	; SI OUI FIN SINON
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
	LEA	VAR,A6	; VARIABLES

********* OVERSCAN PREPA ****************************************

;	MOVE.W	$FFFF8288.W,D0
;	MOVE.W	$FFFF828A.W,D1
;	MOVE.W	D0,HBB(a6)
;	MOVE.W	D1,HBL(a6)
	
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
	
	BSR	PLAY_SAMPLE
	BSR	FADE_COULEUR_UN

	MOVE.L	#ANIMATION,BUFFER
	
	MOVE.L	#70,D0
	BSR	WAIT
	
	BSR	INTRO_FLI_PLAY	 	

BYE	MOVE.L	SAUVE_VBL,$70.W 

SUITE	LEA	VAR,A6	; VARIABLES
		
	MOVE.W	#%1100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1,-(SP)
	MOVE.L	ECRAN2,-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP
	CLR.L	$FFFF9800.W
	
	
	MOVE.B	#150,D0
	BSR	WAIT

	CLR.B	$FFFF8901.W			; DMA STOP

************** SOUNDTRACK START **************************************

	LEA	PLAYER,A0
	BSR	RELOC
	MOVEQ	#1,D0
	LEA	MODULE,A0
	BSR	PLAYER+28
	PEA	INIT_CODEC
	MOVE.W	#$26,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

***************************************************************

	CLR.L	D0
	LEA	TEXTE4,A0
	MOVE.L	A0,-(SP)
	LEA	TEXTE3,A0
	MOVE.L	A0,-(SP)
	LEA	TEXTE2,A0
	MOVE.L	A0,-(SP)
	LEA	TEXTE1,A0
	MOVE.L	A0,-(SP)
	LEA	IMAGE4,A0
	MOVE.L	A0,-(SP)
	LEA	IMAGE3,A0
	MOVE.L	A0,-(SP)
	LEA	IMAGE2,A0
	MOVE.L	A0,-(SP)
	LEA	IMAGE1,A0
	MOVE.L	A0,-(SP)
	
;	BSR	CLS
;	BSR	FADE_NOIR
;	BSR	VBL0
	
	MOVE.L	(SP)+,IMAGE
	BSR	BOUCLE
	
	MOVE.L	(SP)+,IMAGE
	BSR	BOUCLE
	
	MOVE.L	(SP)+,IMAGE
	BSR	BOUCLE

	BSR	CLS
	
	MOVE.L	(SP)+,IMAGE
	MOVE.L	(SP)+,TEXTE

	BSR	PREPARATION_DE_LA_PALETTE

	BSR	BOUCLE2
	
	MOVE.L	(SP)+,TEXTE
	BSR	BOUCLE2
	
	MOVE.L	(SP)+,TEXTE
	BSR.S	BOUCLE2
	
	MOVE.L	(SP)+,TEXTE
	BSR.S	BOUCLE2
	
;	BSR	FADE_BLANC
	
**********************************************************************	
*********** FIN DE LA DEMO *******************************************
**********************************************************************

FIN	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	FIN
		
	DC.W	$A009
	MOVE.B	#8,$FFFFFC02.W
	MOVE.B	KEYBOARD,$484.W

	MOVE.W	REZ(A6),-(SP)
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR(A6),-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR(A6),-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
		
;	MOVE.W	HBB(a6),D0
;	MOVE.W	HBL(a6),D1
;	MOVE.W	D0,$FFFF8288.W
;	MOVE.W	D1,$FFFF828A.W

************** SOUNDTRACK STOP ****************************************
	
	PEA	OFF
	MOVE.W	#$26,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	BSR	PLAYER+28+4

	CLR.L	-(SP)
	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP

	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
	
**********************************************************************
*********** SOUS-ROUTINES ********************************************
**********************************************************************

VBL_FLI	ADDQ.W	#1,TIME 
	RTE 

************** BOUCLE ENCHAINEMENT DES AFFICHAGES IMAGES *************

BOUCLE	BSR	NOIR
	BSR.S	PREPARATION_DE_LA_PALETTE
	BSR	AFFICHE_IMAGE
	BSR	FADE_NOIR_COULEURS
	BSR	PAUSE
	BSR	FADE_COULEURS_NOIR
	RTS

************** BOUCLE AFFICHAGE DU PRINTER ***************************

BOUCLE2	BSR	AFFICHAGE_DE_LA_PALETTE
	BSR	AFFICHAGE_DU_TEXTE
	BSR	VBL0
	BSR	FADE_COULEURS_NOIR
	BSR	CLS
	RTS
	
************** LA VBL*************************************************

VBL0	MOVE.L	$466.W,D7
VBL1	CMP.L	$466.W,D7
	BEQ.B	VBL1
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
	BSR.S	VBL0
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

************** AFFICHAGE DE L'IMAGE **********************************
	
AFFICHE_IMAGE	MOVE.L	IMAGE,A0
	MOVEA.L	ECRAN1,A1
	SUB.W	#1664,A1
	MOVE.W	#99,D7
AFFICHE_IM	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	MOVEM.L	(A0)+,D1-D6/A2-A5
	MOVEM.L	D1-D6/A2-A5,(A1)
	LEA.L	40(A1),A1
	DBF	D7,AFFICHE_IM
	RTS

************** AFFICHAGE DE LA PALETTE *******************************

AFFICHAGE_DE_LA_PALETTE
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

************** PALETTE EN NOIR ***************************************

NOIR	MOVE.L	#$3F,D5
	LEA	$FFFF9800.W,A0
NOIR1	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBF	D5,NOIR1
	RTS

************** PASSAGE NOIR -> COULEURS ******************************

FADE_NOIR_COULEURS	
	MOVE.L	#$3F,D4
FADE	LEA	PALETTE,A0
	LEA	$FFFF9800.W,A1
	MOVE.L	#$FF,D5
	CLR.L	D2
FADEON	MOVE.L	(A0),D6
	MOVE.L	(A1),D1
	MOVE.L	D1,D2
BLEU	CMP.B	D6,D1
	BEQ.S	VERT
	ADDQ.B	#4,D1
	MOVE.L	D1,D2
VERT	SWAP	D6
	SWAP	D1
	CMP.B	D6,D1
	BEQ.S	ROUGE
	ADD.L	#$40000,D2
ROUGE	ROR	#8,D6
	ROR	#8,D1
	CMP.B	D6,D1
	BEQ.S	SUITE_COL
	ADD.L	#$4000000,D2
SUITE_COL	MOVE.L	D2,(A1)+
	ADDA.L	#4,A0
	DBF	D5,FADEON
	BSR	VBL0
	DBF	D4,FADE			
	RTS

**************	PASSAGE BLANC -> NOIR *********************************
		
FADE_NOIR	LEA	$FFFF9800.W,A0
	MOVE.L	#$3C,D5
FADE_NOIR1	SUB.L	#$4040004,(A0)
	CMP.L	#0,(A0)
	BEQ.S	SORTIR
	BSR	VBL0
	DBF	D5,FADE_NOIR1
SORTIR	RTS

************** SAUVEGARDE DES VALEURS GAUCHE ET DROITE ***************
	
OVERSCAN	MOVE.W	$FFFF8288.W,D0
	MOVE.W	$FFFF828A.W,D1
	MOVE.W	D0,HBB
	MOVE.W	D1,HBL
	RTS

************** RESTAURATION DES VALEURS DROITE ET GAUCHE *************
	
OVERSCAN_FIN	MOVE.W	HBB,D0
	MOVE.W	HBL,D1
	MOVE.W	D0,$FFFF8288.W
	MOVE.W	D1,$FFFF828A.W
	RTS

************** PASSAGE COULEURS -> NOIR ******************************
	
FADE_COULEURS_NOIR
	MOVE.L	#$3F,D4
FADE2	LEA	$FFFF9800.W,A0
	MOVE.L	#$FF,D5
FADEOFF	MOVE.L	(A0),D6
	MOVE.L	D6,D1
BLEU2	CMP.B	#0,D6
	BEQ.S	VERT2
	SUBQ.B	#4,D1
	
VERT2	SWAP	D6
	CMP.B	#0,D6
	BEQ.S	ROUGE2
	SUB.L	#$40000,D1
	
ROUGE2	ROR	#8,D6
	CMP.B	#0,D6
	BEQ.S	SUITE2
	SUB.L	#$4000000,D1
	
SUITE2	MOVE.L	D1,(A0)+

	DBF	D5,FADEOFF
	BSR	VBL0
	DBF	D4,FADE2			
	RTS

************** ATTENDRE 100*(1/50HZ)=2s ******************************
	
PAUSE	MOVE.L	#$64,D5
PAUSE1	BSR	VBL0
	DBF	D5,PAUSE1
	RTS

************** AFFICHAGE DU TEXTE ************************************
	
AFFICHAGE_DU_TEXTE
	CLR.L	D4
	CLR.L	D5
	CLR.L	D6
	MOVE.L	TEXTE,A5
TAILLE	MOVE.B	(A5)+,D4
	CMP.B	#0,D4
	BEQ.S	DEBUT
	ADDQ.W	#1,D6
	BRA	TAILLE	

DEBUT	MOVE.L	TEXTE,A5
	SUBQ.B	#1,D6
	MOVE.L	ECRAN1,A0
	BSR	VBL0
LETTRE	CLR.L	D4
	MOVE.B	(A5)+,D4
	CMP.B	#$1E,D4
	BEQ	LIGNE_SUIVANTE
	SUB.B	#$20,D4
POINTE_LETTRE	CMP.B	#$14,D4
	BLT.S	LIGNE_1
	CMP.B	#$28,D4
	BLT.S	LIGNE_2
	CMP.B	#$3C,D4
	BLT.S	LIGNE_3
	CMP.B	#$50,D4
	BLT.S	LIGNE_4
LIGNE_5	SUB.L	#$50,D4
	LSL.L	#4,D4
	ADD.L	#$7800,D4
	BRA.S	AFFICHE_LETTRE
LIGNE_1	LSL.L	#4,D4
	BRA.S	AFFICHE_LETTRE
LIGNE_2	SUB.L	#$14,D4
	LSL.L	#4,D4
	ADD.L	#$1E00,D4
	BRA.S	AFFICHE_LETTRE
LIGNE_3	SUB.L	#$28,D4
	LSL.L	#4,D4
	ADD.L	#$3C00,D4
	BRA.S	AFFICHE_LETTRE
LIGNE_4	SUB.L	#$3C,D4
	LSL.L	#4,D4
	ADD.L	#$5A00,D4
	
AFFICHE_LETTRE	MOVE.L	#$18,D1
	LEA	IMAGE4+1664,A1	
	ADDA.L	D4,A1
AFFICHE	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	ADD.L	#368,A0	;184
	ADD.L	#304,A1
	DBF	D1,AFFICHE
	ADDA.L	#-9586,A0	;4792	
	BSR	VBL0
	DBF	D6,LETTRE
	RTS

LIGNE_SUIVANTE	ADD.L	#$1E00,A0
	MOVE.B	(A5)+,D4
	SUBQ.L	#1,D6	
	SUB.B	#$20,D4
	BRA	POINTE_LETTRE

************** EFFACER L'ECRAN ***************************************
	
CLS	MOVEA.L	ECRAN1,A0
	MOVE.W	#4000,D4
CLS1	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBF	D4,CLS1
	RTS

************** INITIALISATION DU CODEC POUR LE SOUNDTRACK ************

INIT_CODEC	LEA	SAVE,A0
	MOVE.L	$120.W,(A0)+
	MOVE.B	$FFFFFA1B.W,(A0)+
	MOVE.B	$FFFFFA1F.W,(A0)+
	MOVE.B	#246,$FFFFFA1F.W
	MOVE.B	#7,$FFFFFA1B.W
	MOVE.L	#TIMER_B,$120.W
	BSET	#0,$FFFFFA13.W
	BSET	#0,$FFFFFA07.W
	RTS
	
OFF	BCLR	#0,$FFFFFA07.W
	BCLR	#0,$FFFFFA13.W
	LEA	SAVE,A0
	MOVE.L	(A0)+,$120.W
	MOVE.B	(A0)+,$FFFFFA1B.W
	MOVE.B	(A0)+,$FFFFFA21.W
	RTS

TIMER_B	MOVEM.L	D0-A6,-(SP)
	BSR	PLAYER+28+8
	MOVEM.L	(SP)+,D0-A6
	BCLR	#0,$FFFFFA0F.W
	RTE
	
************** RELOCATION ********************************************

RELOC	MOVE.L	2(A0),D0
	ADD.L	6(A0),D0
	ADD.L	14(A0),D0
	ADDA.L	#$1C,A0
	MOVE.L	A0,D1
	MOVEA.L	A0,A1
	MOVEA.L	A1,A2
	ADDA.L	D0,A1
	MOVE.L	(A1)+,D0
	ADDA.L	D0,A2
	ADD.L	D1,(A2)
	CLR.L	D0
RELOC1	MOVE.B	(A1)+,D0
	BEQ.S	RELOC3
	CMP.B	#1,D0
	BEQ.S	RELOC2
	ADDA.L	D0,A2
	ADD.L	D1,(A2)
	BRA	RELOC1
RELOC2	ADDA.L	#$FE,A2
	BRA	RELOC1
RELOC3	RTS	

INIT_SIZE	MOVEA.L	#BUFFER,A0
	MOVEQ	#0,D0 
	MOVE.B	3(A0),D0
	LSL.W	#8,D0 
	MOVE.B	2(A0),D0
	LSL.L	#8,D0 
	MOVE.B	1(A0),D0
	LSL.L	#8,D0 
	MOVE.B	(A0),D0 
	MOVE.L	D0,SIZE 
	RTS 

READ_FLI_HEADER
	MOVEA.L	BUFFER,A0 
	MOVEQ	#0,D0 
	MOVE.B	7(A0),D0
	LSL.W	#8,D0 
	MOVE.B	6(A0),D0
	MOVE.W	D0,FRAMES 
	MOVEQ	#0,D0 
	MOVE.B	9(A0),D0
	LSL.W	#8,D0 
	MOVE.B	8(A0),D0
	MOVE.W	D0,WIDTH
	MOVEQ	#0,D0 
	MOVE.B	11(A0),D0 
	LSL.W	#8,D0 
	MOVE.B	10(A0),D0 
	MOVE.W	D0,HEIGHT 	
	MOVEQ	#0,D0 
	MOVE.B	19(A0),D0 
	LSL.L	#8,D0 
	MOVE.B	18(A0),D0 
	LSL.L	#8,D0 
	MOVE.B	17(A0),D0 
	LSL.W	#8,D0 
	MOVE.B	16(A0),D0 
	MOVE.L	D0,SPEED
	RTS 

READ_EXTRA_FLI_H
	MOVEA.L	A6,A0 
	MOVEQ	#0,D0 
	MOVE.B	3(A0),D0
	LSL.L	#8,D0 
	MOVE.B	2(A0),D0
	LSL.L	#8,D0 
	MOVE.B	1(A0),D0
	LSL.L	#8,D0 
	MOVE.B	(A0),D0 
	MOVE.L	D0,SIZE_FRAME 
	MOVEQ	#0,D0 
	MOVE.B	5(A0),D0
	LSL.W	#8,D0 
	MOVE.B	4(A0),D0
	MOVEQ	#0,D0 
	MOVE.B	7(A0),D0
	LSL.W	#8,D0 
	MOVE.B	6(A0),D0
	MOVE.W	D0,NBRE_SS_CHUNK
	MOVEA.L	A6,A5 
	ADDA.L	#$10,A5 
NEXT_CHUNK	TST.W	NBRE_SS_CHUNK 
	BEQ.S	END_CHUNK 
	BSR	READ_CHUNK
	SUBQ.W	#1,NBRE_SS_CHUNK
	BRA.S	NEXT_CHUNK
END_CHUNK	ADDA.L	SIZE_FRAME,A6 
	RTS 

READ_CHUNK	MOVEA.L	A5,A0 
	MOVEQ	#0,D0 
	MOVE.B	3(A0),D0
	LSL.L	#8,D0 
	MOVE.B	2(A0),D0
	LSL.L	#8,D0 
	MOVE.B	1(A0),D0
	LSL.L	#8,D0 
	MOVE.B	(A0),D0 
	MOVE.L	D0,SIZE_DATA_CHUNK
	MOVEQ	#0,D0 
	MOVE.B	5(A0),D0
	LSL.W	#8,D0 
	MOVE.B	4(A0),D0
	MOVE.W	D0,TYPE_CHUNK 
	CMPI.W	#$B,TYPE_CHUNK
	BEQ	READ_PALETTE
	CMPI.W	#$C,TYPE_CHUNK
	BEQ	READ_LC 
	CMPI.W	#$F,TYPE_CHUNK
	BEQ	READ_BRUN 
	CMPI.W	#$10,TYPE_CHUNK 
	BEQ	READ_COPY 
	RTS 

READ_COPY	DC.B	'A',$ED,$00,$06,'&|'
	DC.L	BUFFER_COLOR
	DC.B	'#',$FC,$00,$00,$00,$00 
	DC.L	LINE_MIN
	DC.B	'3',$FC,$00,$C8 
	DC.L	LINE_NBRE 
	DC.B	'"|'
	DC.L	ECRAN 
	DC.B	'><',$00,$C7,'<<',$01,'?' 
	DC.B	'p',$00,$10,$18,'2',$F3,$02,$00 
	DC.B	'Q',$CE,$FF,$F6,'Q',$CF,$FF,$EE 
	ADDA.L	SIZE_DATA_CHUNK,A5
	RTS 

READ_BRUN:        DC.B      'A',$ED,$00,$06,'&|'
                  DC.L      BUFFER_COLOR
                  DC.B      '#',$FC,$00,$00,$00,$00 
                  DC.L      LINE_MIN
                  DC.B      '3',$FC,$00,$C8 
                  DC.L      LINE_NBRE 
                  DC.B      '"|'
                  DC.L      ECRAN 
                  DC.B      '><',$00,$C7,'|',$00,$1C,$18
                  DC.B      'SFz',$00,$1A,$18,'J',$05 
                  DC.B      'm',$1E,'SEx',$00,$18,$18 
                  DC.B      '2',$F3,'B',$00,'Q',$CD,$FF,$FA 
                  DC.B      'Q',$CE,$FF,$E8,'Q',$CF,$FF,$DE 
                  ADDA.L    SIZE_DATA_CHUNK,A5
                  RTS 

                  DC.B      'H',$85,'DESEx',$00 
                  DC.B      $18,$18,'2',$F3,'B',$00,'Q',$CD 
                  DC.B      $FF,$F8,'`',$DC 
READ_LC:          DC.B      'A',$ED,$00,$06,'&|'
                  DC.L      BUFFER_COLOR
                  DC.B      'r',$00,'t',$00,'v',$00,$16,'(' 
                  DC.B      $00,$01,$E1,$8B,$16,$10,$C6,$FC 
                  DC.B      $02,$80,'#',$C3 
                  DC.L      LINE_MIN
                  DC.B      '~',$00,$1E,'(',$00,$03,$E1,$8F 
                  DC.B      $1E,'(',$00,$02,'SG3',$C7 
                  DC.L      LINE_NBRE 
                  DC.B      'X',$88,'"|'
                  DC.L      ECRAN 
                  DC.B      $D3,$C3 
LC_LINES:         DC.B      '|',$00,$1C,$18,'J',$06,'g"'
                  DC.B      'SF'
LC_PACK:          DC.B      'z',$00,$1A,$18,$D2,$C5,$D2,$C5 
                  DC.B      $1A,$18,'J',$05,'m,SE'
                  DC.B      'x',$00,$18,$18,'2',$F3,'B',$00 
                  DC.B      'Q',$CD,$FF,$F6 
RETOUR_LC:        DBF       D6,LC_PACK
                  ADDI.L    #$280,D3
                  MOVEA.L   #ECRAN,A1 
                  ADDA.L    D3,A1 
                  DBF       D7,LC_LINES 
                  ADDA.L    SIZE_DATA_CHUNK,A5
                  RTS 

                  EXT.W     D5
                  NEG.W     D5
                  SUBQ.W    #1,D5 
                  MOVEQ     #0,D4 
                  MOVE.B    (A0)+,D4
LC_POINTS2:       DC.B      '2',$F3 
                  CLR.B     D0
                  DBF       D5,LC_POINTS2 
                  BRA.S     RETOUR_LC 
READ_PALETTE:     MOVEA.L   #BUFFER_COLOR,A1
                  LEA       10(A0),A2 
                  MOVE.W    #$FF,D0 
INSTALLE_COLORS:  MOVEQ     #0,D1 
                  MOVEQ     #0,D2 
                  MOVE.B    (A2)+,D2
                  LSR.W     #1,D2 
                  LSL.W     #8,D2 
                  LSL.W     #3,D2 
                  MOVE.W    D2,D1 
                  MOVEQ     #0,D2 
                  MOVE.B    (A2)+,D2
                  LSR.W     #1,D2 
                  LSL.W     #6,D2 
                  OR.W      D2,D1 
                  MOVEQ     #0,D2 
                  MOVE.B    (A2)+,D2
                  LSR.W     #1,D2 
                  OR.W      D2,D1 
                  MOVE.W    D1,(A1)+
                  DBF       D0,INSTALLE_COLORS
                  ADDA.L    SIZE_DATA_CHUNK,A5
                  RTS 
	
PLAY_SAMPLE	MOVE.L	#SAMPLE+4000,D0
	MOVE.L	#SAMPLE_FIN,D1
	MOVE.B	D0,$FFFF8907.W
	LSR.W	#8,D0
	MOVE.B	D0,$FFFF8905.W
	SWAP	D0
	MOVE.B	D0,$FFFF8903.W
	MOVE.B	D1,$FFFF8913.W
	LSR.W	#8,D1
	MOVE.B	D1,$FFFF8911.W
	SWAP	D1
	MOVE.B	D1,$FFFF890F.W
	MOVE.B	#%10000010,$FFFF8921.W		; 25KHZ 8BITS MONO
	MOVE.B	#1,$FFFF8901.W		; DMA ON
	RTS

FADE_COULEUR_UN
	MOVE.W	#$3C,D0
FADE_COL	SUBI.L	#$4040004,$FFFF9800.W
	BSR	VBL0
	DBF	D0,FADE_COL
	RTS

INTRO_FLI_PLAY
	MOVE.W	#$24,-(A7)
	MOVE.W	#$58,-(A7)
	TRAP	#14
	ADDQ.L	#4,A7
END_MONITOR	MOVE.L	#ECRAN,D0 
	LSR.L	#8,D0 
	MOVE.B	D0,-$7DFD.W 
	LSR.L	#8,D0 
	MOVE.B	D0,-$7DFF.W 
	MOVE.L	#ECRAN,D0 
	MOVE.B	D0,-$7DF3.W 
	MOVE.L	$70.L,SAUVE_VBL 
	MOVE.L	#BYE,8.L 
	MOVE.L	#BYE,$C.L
	MOVE.L	#BYE,$10.L 
	MOVE.L	#BYE,$14.L 
	MOVE.L	#BYE,$18.L 
	MOVE.L	#BYE,$1C.L 
	MOVE.L	#VBL_FLI,$70.W
	BSR	READ_FLI_HEADER 
INIT_FILM	MOVE.W	FRAMES,D0 
	MOVE.W	D0,PAGE 
	MOVEA.L	BUFFER,A6 
	ADDA.L	#$80,A6 
READ_PAGE	MOVE.W	#0,TIME 
	BSR	READ_EXTRA_FLI_H
	MOVE.L	SPEED,D0
SUITE_VBL	CMP.W	TIME,D0 
	BGT.S	SUITE_VBL 
	CMPI.B	#$39,-$3FE.W
	BEQ	BYE
	SUBQ.W	#1,PAGE 
	TST.W	PAGE
	BNE.S	READ_PAGE 
	RTS

WAIT	BSR	VBL0
	DBF	D0,WAIT
	RTS
	
**********************************************************************
	SECTION DATA
**********************************************************************

PLAYER	INCBIN	D:\TOTF\TRACK

TEXT	DC.B	$1B,"E"
	DC.B	0
	
SAMPLE	INCBIN	E:\INTRO.AVR
SAMPLE_FIN
	
MODULE	INCBIN	E:\MODULES\TEKNO.MOD

TEXTE1	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	"   Coded by ZANAK   ",$1E
	DC.B	"                    ",0

TEXTE2	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	" Graphixxx by ARTEK ",$1E
	DC.B           "                    ",0

TEXTE3	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	"Musaxx by ZYGOMA/ADR",$1E
	DC.B           "                    ",0
	
TEXTE4	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	"                    ",$1E
	DC.B	" SoundTrack Rout by ",$1E
	DC.B	"  BITMASTER // BSW  ",$1E
	DC.B           "                    ",0
	
FORMAT_TPI	DC.W	128,140,146,164,152,170,158,176,182
	DC.W	188,194,212,200,218,206,1658,224,134

IMAGE1	INCBIN	D:\IMAGES\TPI.ZAK\ATROCITY.TPI
	EVEN

IMAGE2	INCBIN	e:\IMAGES1.TPI
	EVEN
	
IMAGE3	INCBIN	e:\IMAGES2.TPI
	EVEN
		
IMAGE4	INCBIN	D:\IMAGES\TPI.ZAK\FONTES.TPI
	EVEN

ANIMATION	INCBIN	D:\ATROCIT2.FLI
	EVEN
	
			
**********************************************************************
	SECTION BSS
**********************************************************************

TEXTE	DS.W	2
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
PALETTE	DS.L	256
KEYBOARD	DS.B	1
IMAGE	DS.L	1		
SAVE	DS.B	6
BUFFER_COLOR	
	DS.B      1024
BUFFER	DS.B      8
FRAMES	DS.W      1 
HEIGHT	DS.W      1 
LINE_MIN	DS.L      1 
LINE_NBRE	DS.B      102 
NBRE_SS_CHUNK
	DS.W      1 
PAGE	DS.W      1 
SAUVE_VBL	DS.L      1 
SIZE	DS.L      1 
SIZE_FRAME	DS.B      8 
SIZE_DATA_CHUNK
	DS.L      1 
SPEED	DS.L      1 
TIME	DS.W      1 
TYPE_CHUNK	DS.W      1 
WIDTH	DS.W      1 
SAVE_SCREEN	DS.L      1 
ECRAN	DS.B      121632

	END