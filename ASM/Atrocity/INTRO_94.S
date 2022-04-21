**********************************************************************
************** INTRO DEMO ATROCITY - BETA FALCON VERSION *************
**************    AVEC ROUTINE SOUNDTRACKER BY BITMASTER *************
**************   (C) SEPTEMBRE 1994 , ZANAK / ATROCITY   *************
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

************** REGLAGE OFFSET OVERSCAN POUR TV ***********************

;	BSR	OVERSCAN
	
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
			
**********************************************************************
************** ROUTINE PRINCIPALE ************************************
**********************************************************************
	
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
	
	BSR	CLS
	BSR	FADE_NOIR
	BSR	VBL
	
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
	BSR.S	BOUCLE2
	
	MOVE.L	(SP)+,TEXTE
	BSR.S	BOUCLE2
	
	MOVE.L	(SP)+,TEXTE
	BSR.S	BOUCLE2
	
;	BSR	FADE_BLANC
		
**********************************************************************
************** FIN DE LA DEMO - RESTAURATION *************************
**********************************************************************

WAIT	CMP.B	#$39+$80,$FFFFFC02.W
	BNE	WAIT	

BYE	DC.W	$A009
	MOVE.B	#8,$FFFFFC02.W
	MOVE.B	KEYBOARD,$484.W

	MOVE.W	REZ,-(SP)	; REMET LA REZ
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR,-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR,-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
	
;	BSR	OVERSCAN_FIN

************** SOUNDTRACK STOP ****************************************
	
	PEA	OFF
	MOVE.W	#$26,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	BSR	PLAYER+28+4

***********************************************************************

	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
	
**********************************************************************
************** SUB ROUTINES ******************************************
**********************************************************************	

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
	BSR.S	VBL
	BSR	FADE_COULEURS_NOIR
	BSR	CLS
	RTS
	
************** LA VBL*************************************************

VBL	MOVE.L	$466.W,D7
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
	BSR	VBL
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
	BSR	VBL
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
	BEQ.S	SUITE
	ADD.L	#$4000000,D2
SUITE	MOVE.L	D2,(A1)+
	ADDA.L	#4,A0
	DBF	D5,FADEON
	BSR	VBL
	DBF	D4,FADE			
	RTS

**************	PASSAGE BLANC -> NOIR *********************************
		
FADE_NOIR	LEA	$FFFF9800.W,A0
	MOVE.L	#$3C,D5
FADE_NOIR1	SUB.L	#$4040004,(A0)
	CMP.L	#0,(A0)
	BEQ.S	SORTIR
	BSR	VBL
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
	BSR	VBL
	DBF	D4,FADE2			
	RTS

************** ATTENDRE 100*(1/50HZ)=2s ******************************
	
PAUSE	MOVE.L	#$64,D5
PAUSE1	BSR	VBL
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
	BSR	VBL
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
	ADD.L	#304,A0	;184
	ADD.L	#304,A1
	DBF	D1,AFFICHE
	ADDA.L	#-7984,A0	;4792	
	BSR	VBL
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
	BSR.S	PLAYER+28+8
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

**********************************************************************
	SECTION DATA
**********************************************************************

PLAYER	INCBIN	D:\TOTF\TRACK
	
MODULE	INCBIN	E:\MODULES\JINGLE8.MOD

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

IMAGE2	INCBIN	e:\cindy.TPI
	EVEN
	
IMAGE3	INCBIN	e:\claudia.TPI
	EVEN
		
IMAGE4	INCBIN	D:\IMAGES\TPI.ZAK\FONTES.TPI
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
PALETTE	DS.L	256
KEYBOARD	DS.B	1
IMAGE	DS.L	1		
SAVE	DS.B	6
	
	END