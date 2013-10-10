*	OPT	X+
*************************************
* ROUTINE D'INTRO POUR CD.	    *
*				    *
* CODEE PAR FOX LE FOU DE TLF.	    *
*				    *
* SCROLL ROUTINE: TRAP 16  (TLF)    *
*				    *
* (C)2/12/1992 FOX LE FOU...	    *
*************************************

DECALAGE_MUSIQUE	EQU	4


	SECTION	DATA

	EVEN

IMAGE	INCBIN	"A:\SNATCHER.PI1"

	EVEN

MUZEXXE	INCBIN	"A:\ZAX1.THK."

	EVEN


	SECTION	TEXT

	EVEN
	opt	x+
debut	MOVE.L	A7,A5
	MOVE.L	#OURSTACK,A7
	MOVE.L	4(A5),A5
	MOVE.L	#quit-debut,-(SP)
	MOVE.L	A5,-(SP)
	CLR.W	-(A7)
	MOVE.W	#$4A,-(SP)
	TRAP	#1
	ADD.L	#12,SP
	TST.L	D0
	BNE	quit
	bra	okok
	ds.l	200
ourstack
	ds.l	10
	EVEN
NAME1	DC.B	"A:\1.DAT",0
	EVEN
NAME2	DC.B	"A:\2.DAT",0
	EVEN
NAME3	DC.B	"A:\3.DAT",0
	EVEN
NAME4	DC.B	"A:\4.DAT",0
	even

okok	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.L	D0,-(sp)
	dc.w	$a00a
	move.b	#$12,$fffffc02
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,palette


init_scroll
N_LIGNE	EQU	232
N_FONT	EQU	46
	lea	$ffff8240.w,a0
	rept	8
	clr.l	(a0)+
	endr
	move.l	$44e,ancien_ecran
	move.l	#ecran,d0
	andi.l	#$ffff00,d0
	addi.l	#$100,d0
	move.l	d0,save_scr1
	add.l	#43264,d0
	move.l	d0,save_scr2

	MOVE.L	#46,-(A7)	* ESPACE (NO DANS LA PI1)
	PEA	FONTES+34	* DEBUT FONTES"
	MOVE.W	#N_LIGNE,-(A7)	* NO DE LIGNE D'AFFICHAGE
	PEA	CONV_TABLE	* ADRESSE DE TABLE DE CONVERSION
	PEA	TEXTE	* ADRESSE DU TEXTE
	MOVE.W	#N_FONT,-(A7)	* NB FONTES (+ SPACE)
			* PAS RESTAURER A7,AUTOMATIK !
	BSR	start	
	BSR	start+4
	LEA	FONTES+32034,A1
	BSR	start+28
	MOVE.L	SAVE_SCR1,A0
	MOVE.W	#(40*200)-1,D0
F_LP	CLR.l	(A0)+		* EFFACER LES 2 ECRANS
	Dbf	D0,F_LP
	MOVE.L	SAVE_SCR1,start+32	* SCR1 A VOIR
	MOVE.L	#46,start+36		* ESPACE
	CLR.W	$FF8240
	move.l	#call1,call

****
	moveq	#1,d0
	jsr	muzexxe

	move.l	save_scr1,a0
	move.l	save_scr2,a1
	move.l	#entete+32,a2
	move.w	#(40*35)-1,d7
affiche_entete
	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf	d7,affiche_entete

	move.l	save_scr1,a0
	move.l	save_scr2,a1
	lea	35*160(a0),a0
	lea	35*160(a1),a1
	move.l	#image+34,a2
	move.w	#(40*194)-1,d7
affiche_le_fond
	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf	d7,affiche_le_fond
	jsr	init_vectors
	clr.w	game


*************************************
* SYNCRO, AVEC TEST DE TOUCHE.	    *
*				    *
* ENLEVER LES * SI IL Y A 3 OU 4    *
*				    *
* JEUX.				    *
*				    *
*************************************
sync	stop	#$2300
test_f1	cmp.b	#$3B,$fffffc02.w
	bne.s	test_f2
	move.w	#1,game
	bra	fin

test_f2	cmp.b	#$3c,$fffffc02.w
	bne.s	test_f3
	move.w	#2,game
	bra	fin

test_f3	
*	cmp.b	#$3d,$fffffc02.w
*	bne.s	test_f4
*	move.w	#3,game
*	bra	fin

test_f4
*	cmp.b	#$3e,$fffffc02.w
*	bne.s	test_espace
*	move.w	#4,game
*	bra	fin

test_espace
	cmp.b	#$39,$fffffc02.w
	bne	sync
	bra	fin



*************************************
* Routine de scroll … plusieurs     *
* appels et decalages multiples	    *
*************************************
call1	BSR	start+8		* D7 ECRAN VU
	MOVE.L	SAVE_SCR2,start+32	* D7 ECRAN A TRAVAILLER
	BSR	start+12		* 24-32 ET 0-8     ?
	move.l	#call2,call
	rts
	***
call2	BSR	start+8		* SCR2 A VOIR
	MOVE.L	SAVE_SCR1,start+32
	BSR	start+16		* 0-16
	move.l	#call3,call
	rts
	***
call3	BSR	start+8	* SCR1 A VOIR
	MOVE.L	SAVE_SCR2,start+32
	BSR	start+20		* 9-24
	move.l	#call4,call
	rts
	******
call4	BSR	start+8		* SCR2 A VOIR
	MOVE.L	SAVE_SCR1,start+32
	BSR	start+24		* 16-32
	move.l	#call1,call
	rts
	******
nullos	rte


fin	jsr	restaure_vectors
	moveq	#0,d0
	jsr	muzexxe
	move.l	#$080008000000,$ffff8800.w
	move.l	#$090009000000,$ffff8800.w
	move.l	#$0a000a000000,$ffff8800.w
	move.w	#$700,$484.w
	move.b	#8,$fffffc02.w
	dc.w	$a009
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240
	move.l	ancien_ecran,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

test_game1
	cmp.w	#1,game
	bne.s	test_game2
	MOVE.L	#0,-(A7)
	MOVE.L	#0,-(A7)
	MOVE.L	#NAME1,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$4B,-(A7)
	TRAP	#1
	ADDA.L	#$E,A7
	clr.w	-(sp)
	trap	#1


test_game2
	cmp.w	#2,game
	bne.s	test_game3
	MOVE.L	#0,-(A7)
	MOVE.L	#0,-(A7)
	MOVE.L	#NAME2,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$4B,-(A7)
	TRAP	#1
	ADDA.L	#$E,A7
	clr.w	-(sp)
	trap	#1

test_game3
	cmp.w	#3,game
	bne.s	test_game4
	MOVE.L	#0,-(A7)
	MOVE.L	#0,-(A7)
	MOVE.L	#NAME3,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$4B,-(A7)
	TRAP	#1
	ADDA.L	#$E,A7
	clr.w	-(sp)
	trap	#1

test_game4
	cmp.w	#4,game
	bne.s	quit
	MOVE.L	#0,-(A7)
	MOVE.L	#0,-(A7)
	MOVE.L	#NAME4,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$4B,-(A7)
	TRAP	#1
	ADDA.L	#$E,A7
	clr.w	-(sp)
	trap	#1


quit	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7

	CLR.W	-(A7)
	TRAP	#1


	EVEN
**************************************************************
**************************************************************
* ROUTINE DE SCROLLING
*
* BRA1:	INITIALISATION	... APPEL	PILE: ADR_FONTE    .L
*			      NO LIGNE     .W
*			      ADR_CONV_TAB .L
*			      ADR_TEXTE    .L
* BRA2:	INITIALISATION ....	APPEL A0:TEXTE
*	(CONVERTIR TEXTE)	      A1:TABLE
* BRA3:	CHANGER L'ECRAN ...
* BRA4:	1ER AFFICHAGE/DECALAGE ...
*	+ LETTRE SUIVANTE	
* BRA5:	2EME AFFICHAGE/DECALAGE ...
* BRA6:	3EME AFFICHAGE/DECALAGE ...
* BRA7:	4EME AFFICHAGE/DECALAGE ...
* BRA8:	DECOUPER LES FONTES...	APPEL A1:TAMPON 32 K

START	BRA	SCROLL_INIT
	BRA	TEXT_CONV
	BRA	SET_SCR
	BRA	AFFICHER_1
	BRA	AFFICHER_2
	BRA	AFFICHER_3
	BRA	AFFICHER_4
	BRA	FONT_CONV
UTIL_SCREEN	DS.L	1	* ECRAN A AFFICHER
SAVE_LETTER	DS.L	1	* LETTRE A AFFICHER
POS	DS.W	1
NOMB_FNT	DS.W	1
ADR_TEXTE	DS.L	1
ADR_CNV_TAB	DS.L	1
LIGNE	DS.W	1
ADR_FNT	DS.L	1	* FONTE+34 (DEGAS ELITE)
SPACE	DS.L	1	* CARACTERE ESPACE
	
	even

SCROLL_INIT	MOVEM.L	A0/A1,-(A7)
	LEA	POS(PC),A0
	CLR.W	(A0)
	LEA	12(A7),A0	* PARAMETRES
	LEA	NOMB_FNT(PC),A1
	MOVE.W	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+	* ADR_FONTES
	MOVE.L	(A0)+,(A1)+	* LIGNE
	MOVE.W	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVEM.L	(A7)+,A0/A1
	MOVE.L	(A7),20(A7)
	LEA	20(A7),A7
	RTS
****************************************
TEXT_CONV	MOVEM.L	A0/A1/D0/D1,-(A7)
	MOVE.L	ADR_TEXTE(PC),A0
	MOVE.L	ADR_CNV_TAB(PC),A1
	MOVE.L	A1,D0
RET_CONVER	MOVE.B	(A0),D1
	TST.B	D1
	BMI.S	END_CONVER		* FIN SCROLL
PAS_TROUVE	CMP.B	#-1,(A1)
	BEQ.S	INTROUVABLE
	CMP.B	(A1),D1
	BEQ.S	TROUVE
	ADDQ.L	#1,A1
	BRA.S	PAS_TROUVE
TROUVE	SUB.L	D0,A1
	MOVE.L	A1,D1
	MOVE.B	D1,(A0)+
	MOVE.L	D0,A1
	BRA.S	RET_CONVER
END_CONVER	MOVE.B	#-1,(A0)
	MOVEM.L	(A7)+,A0/A1/D0/D1
	RTS
INTROUVABLE	MOVE.B	#$20,(A0)
	MOVE.L	D0,A1
	BRA.S	RET_CONVER

	*****************
SET_SCR	MOVE.L	D0,-(A7)
	MOVE.L	UTIL_SCREEN(PC),D0
	LSR.W	#8,D0
	move.l	d0,$ffff8200.w
	MOVE.L	(A7)+,D0
	RTS
	*****************
	******************	
AFFICHER_1	* MET LES PIXELS 24-32 SUR L'ECRAN
	* PUIS 0 A 8 DE LA LETTRE SUIVANTE
	*
	* DETRUIT D0/D1/D2,A0/A1/A2/A3
	*
	* VITESSE: 32875 A 32888 CLK (SANS LE RTS)
	*
	MOVEM.L	A0-A3/D0-D2,-(A7)
	MOVE.L	SAVE_LETTER(PC),D0
	MULU	#512,D0		* D0+FONTES=LETTRE
	MOVE.L	UTIL_SCREEN(PC),A2		* A0 ECRAN
	****
	MOVE.W	LIGNE(PC),D2
	MULU	#160,D2
	ADDQ.L	#8,A2
	ADD.L	D2,A2		* A0 PLAN 1 PIXEL 312-320 
	MOVE.L	ADR_FNT(PC),A1
	ADD.L	D0,A1		* A1 DEBUT LETTRE
	MOVEQ	#7,D0
	ADD.L	D0,A1
	****
SET_LETTER	MOVEQ	#0,D0
	LEA	POS(PC),A3
	ADD.W	#1,(A3)
	MOVE.W	(A3),D0
	MOVE.L	ADR_TEXTE(PC),A0
	MOVEQ	#0,D1
	MOVE.B	(A0,D0.W),D1
	LEA	SAVE_LETTER(PC),A0
	CMP.B	#-1,D1
	BEQ.S	END_SCRL
	MOVE.L	D1,(A0)
	BRA.S	RET_SCRL
END_SCRL	CLR.W	(A3)
	MOVE.L	SPACE(PC),(A0)
	****
RET_SCRL	MOVE.L	SAVE_LETTER(PC),D0
	MULU	#512,D0
	MOVE.L	ADR_FNT(PC),A3
	ADD.L	D0,A3		* A1 DEBUT LETTRE
	MOVEQ	#2,D0
	ADD.L	D0,A1		* A1 DEBUT 1 PLAN 24-32
	MOVEQ	#31,D0
	MOVEQ	#8,D1
	MOVEQ	#16,D2		* FIN DE LIGNE
	MOVE.L	A2,A0
AFF_1A_L0	LEA	-8(A0),A2
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	SUB.L	D1,A0
	MOVE.B	(A1),(A0)+
	MOVE.B	(A3),(A0)+
	MOVE.B	2(A1),(A0)+
	MOVE.B	2(A3),(A0)+
	MOVE.B	4(A1),(A0)+
	MOVE.B	4(A3),(A0)+
	MOVE.B	6(A1),(A0)+
	MOVE.B	6(A3),(A0)+
	ADD.L	D2,A1
	ADD.L	D2,A3
	ADD.L	D1,A0
	DBRA	D0,AFF_1A_L0
	MOVEM.L	(A7)+,A0-A3/D0-D2
	RTS
	*************
	*************
AFFICHER_2	* DECALER DE 16 PIXELS
	* AFFICHER PIXELS 0-16
	*
	* DETRUIT D0/D1/D2,A0/A1/A2
	*
	* VITESSE: 29622 CLK (SANS LE RTS)
	*
	MOVEM.L	A0-A2/D0-D2,-(A7)
	MOVE.L	SAVE_LETTER(PC),D0
	MULU	#512,D0	* D0+FONTES=LETTRE
	****
	MOVE.L	UTIL_SCREEN(PC),A0		* A0 ECRAN
	MOVE.W	LIGNE(PC),D2
	MULU	#160,D2
	ADDQ.L	#8,A0
	ADD.L	D2,A0		* A0 PLAN 1 PIXEL 312-320 
	MOVE.L	ADR_FNT(PC),A1
	ADD.L	D0,A1		* A1 DEBUT LETTRE
	MOVEQ	#31,D0
	MOVEQ	#8,D2
	MOVE.L	#8,D1
AFF_2A_L0	LEA	-8(A0),A2
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	SUB.L	D2,A0
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	ADD.L	D1,A1
	ADD.L	D2,A0
	DBRA	D0,AFF_2A_L0
	MOVEM.L	(A7)+,A0-A2/D0-D2
	RTS
	**********************
	**********************
AFFICHER_3	* MET LES PIXELS 8-24 D'UNE LETTRE
	*
	* DETRUIT D0/D1/D2,A0/A1/A2/A3
	*
	* VITESSE: 32414 CLK (SANS LE RTS)
	*
	MOVEM.L	A0-A3/D0-D2,-(A7)
	MOVE.L	SAVE_LETTER(PC),D0
	MULU	#512,D0		* D0+FONTES=LETTRE
	****
	MOVE.L	UTIL_SCREEN(PC),A0		* A0 ECRAN
	MOVE.W	LIGNE(PC),D2
	MULU	#160,D2
	ADDQ.L	#8,A0
	ADD.L	D2,A0		* A0 PLAN 1 PIXEL 304-312
	MOVE.L	ADR_FNT(PC),A1
	ADD.L	D0,A1		* A1 DEBUT LETTRE
	MOVEQ	#1,D0
	ADD.L	D0,A1		* A1 PIXELS 8-16
	MOVE.L	A1,A2
	MOVEQ	#7,D0
	ADD.L	D0,A2		* A2 PIXELS 16-24
	MOVE.L	A2,A3
	MOVEQ	#31,D2
	MOVE.L	#16,D0
	MOVEQ	#8,D1
AFF_3A_L0	LEA	-8(A0),A2
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	SUB.L	D1,A0
	MOVE.B	(A1),(A0)+
	MOVE.B	(A3),(A0)+
	MOVE.B	2(A1),(A0)+
	MOVE.B	2(A3),(A0)+
	MOVE.B	4(A1),(A0)+
	MOVE.B	4(A3),(A0)+
	MOVE.B	6(A1),(A0)+
	MOVE.B	6(A3),(A0)+
	ADD.L	D0,A1
	ADD.L	D0,A3
	ADD.L	D1,A0
	DBRA	D2,AFF_3A_L0
	MOVEM.L	(A7)+,A0-A3/D0-D2
	RTS
	*************
	*************
AFFICHER_4	* DECALER DE 16 PIXELS
	* AFFICHER PIXELS 16-32
	*
	* DETRUIT D0/D1/D2,A0/A1/A2
	*
	* VITESSE: 29626 CLK (SANS LE RTS)
	*
	MOVEM.L	A0-A2/D0-D2,-(A7)
	MOVE.L	SAVE_LETTER(PC),D0
	MULU	#512,D0		* D0+FONTES=LETTRE
	*****
	MOVE.L	UTIL_SCREEN(PC),A0		* A0 ECRAN
	MOVE.W	LIGNE(PC),D2
	MULU	#160,D2
	ADDQ.L	#8,A0
	ADD.L	D2,A0		* A0 PLAN 1 PIXEL 312-320 
	MOVE.L	ADR_FNT(PC),A1
	ADD.L	D0,A1		* A1 DEBUT LETTRE
	MOVEQ	#8,D1
	ADD.L	D1,A1
	MOVEQ	#31,D2
	MOVE.L	#8,D0
AFF_4A_L0	LEA	-8(A0),A2
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	MOVE.L	(A0)+,(A2)+
	SUB.L	D1,A0
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	ADD.L	D1,A0
	ADD.L	D0,A1
	DBRA	D2,AFF_4A_L0
	MOVEM.L	(A7)+,A0-A2/D0-D2
	RTS
	***************************
	
* FONT CONVERT: MET LES FONTES BOUT A BOUT
*
*	APPEL:	A1=MEMOIRE TAMPON
* 
FONT_CONV	MOVEM.L	A0-A1/D0-D2,-(A7)
	MOVE.L	ADR_FNT(PC),A0
	MOVEM.L	A0/A1,-(A7)
	MOVEQ	#0,D0
	MOVE.W	NOMB_FNT(PC),D0
	DIVU	#10,D0
F_LOOP3	MOVEQ	#9,D2
F_LOOP2	MOVEQ	#31,D1
F_LOOP1	MOVE.L	(A0),(A1)+
	MOVE.L	4(A0),(A1)+
	MOVE.L	8(A0),(A1)+
	MOVE.L	12(A0),(A1)+
	ADD.L	#160,A0
	DBRA	D1,F_LOOP1
	SUB.L	#(160*32)-16,A0
	DBRA	D2,F_LOOP2
	ADD.L	#31*160,A0
	DBRA	D0,F_LOOP3
	MOVEM.L	(A7)+,A0/A1
	MOVE.W	#7999,D0
F_LOOP4	MOVE.L	(A1)+,(A0)+
	DBRA	D0,F_LOOP4
	MOVEM.L	(A7)+,A0-A1/D0-D2
	RTS


main_vbl
	movem.l	d0-d7/a0-a6,-(sp)
	nop
	nop
	nop
	MOVE	SR,-(A7)
	move.w	d0,-(sp)
	MOVE.W	#$2700,SR
	MOVE.W	#$586,D0
	DBF	D0,*
	CLR.B	$FFFF820A.W
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.B	#2,$FFFF820A.W
	movem.l	entete,d0-d7
	movem.l	d0-d7,$ff8240
	move.w	(sp)+,d0
	MOVE.W	(A7)+,SR
	CLR.B	$FFFFFA1B.W
	MOVE.B	#1,$FFFFFA21.W
	MOVE.L	#hbl1,$120.W
	MOVE.B	#8,$FFFFFA1B.W
	jsr	muzexxe+decalage_musique
	move.l	call,a0
	jsr	(a0)
	MOVEM.L	(A7)+,D0-d7/A0-a6
	RTE

hbl1	CLR.B	$FFFFFA1B.W
	MOVE.B	#$1B+8,$FFFFFA21.W
	MOVE.L	#hbl2,$120.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE

hbl2	CLR.B	$FFFFFA1B.W
	MOVE.B	#$C8-8,$FFFFFA21.W
	MOVE.L	#hbl3,$120.W
	MOVE.B	#8,$FFFFFA1B.W
	MOVEM.L	D0-d7,-(A7)
	MOVEM.L	image+2,D0-d7
	MOVEM.L	D0-d7,$FFFF8240.W
	MOVEM.L	(A7)+,D0-d7
	BCLR	#0,$FFFFFA0F.W
	RTE

hbl3	CLR.B	$FFFFFA1B.W
	MOVEM.L	D0/A0,-(A7)
	MOVEA.W	#$FA21,A0
	MOVE.B	#$C8,(A0)
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.B	(A0),D0
pas_encore
	CMP.B	(A0),D0
	BEQ	pas_encore
	CLR.B	$FFFF820A.W
	MOVEQ	#2,D0
boucle	NOP
	DBF	D0,boucle
	MOVE.B	#2,$FFFF820A.W
	MOVEM.L	(A7)+,D0/A0
	MOVEM.L	D0-d7,-(A7)
	MOVEM.L	fontes+2,D0-d7
	MOVEM.L	D0-d7,$FFFF8240.W
	MOVEM.L	(A7)+,D0-d7
*	MOVEM.L	D0-7,-(A7)
*	MOVEM.L	$15B52,D0-7
*	MOVEM.L	D0-7,$FFFF8240.W
*	MOVEM.L	(A7)+,D0-7
	BCLR	#0,$FFFFFA0F.W
	RTE

key_board
	rte

init_vectors
	move.w	sr,-(sp)
	move.w	#$2700,sr
	MOVE.L	$120.W,save_120
	MOVE.L	$70.W,save_70
	move.l	$68.w,save_68
	MOVE.L	$118.W,save_118
	MOVE.B	$FFFFFA07.W,save_a07
	MOVE.B	$FFFFFA09.W,save_a09
	MOVE.B	$FFFFFA0F.W,save_a0f
	MOVE.B	$FFFFFA11.W,save_a11
	MOVE.B	$FFFFFA13.W,save_a13
	MOVE.B	$FFFFFA1B.W,save_a1b
	MOVE.B	$FFFFFA17.W,save_a17
	ANDI.B	#$DF,$FFFFFA09.W
	ANDI.B	#$FE,$FFFFFA07.W
	MOVE.L	#main_vbl,$70.W
	move.l	#nul,$68.w
	ORI.B	#1,$FFFFFA07.W
	ORI.B	#1,$FFFFFA13.W
	BCLR	#6,$FFFFFA09.W
	MOVE.L	#key_board,$118.W
	BSET	#6,$FFFFFA09.W
	BCLR	#3,$FFFFFA17.W
	move.w	(sp)+,sr
	RTS

nul	rte

restaure_vectors
	MOVE	SR,-(A7)
	MOVE.W	#$2700,SR
	MOVE.B	save_a07,$FFFFFA07.W
	MOVE.B	save_a09,$FFFFFA09.W
	MOVE.B	save_a0f,$FFFFFA0F.W
	MOVE.B	save_a11,$FFFFFA11.W
	MOVE.B	save_a13,$FFFFFA13.W
	MOVE.B	save_a1b,$FFFFFA1B.W
	MOVE.B	save_a17,$FFFFFA17.W
	move.l	save_68,$68.w
	MOVE.L	save_70,$70.W
	MOVE.L	save_118,$118.W
	MOVE.L	save_120,$120.W
	LEA	$FFFF8800.W,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	MOVE.W	(A7)+,SR
	RTS

	SECTION	DATA

	EVEN

CONV_TABLE
	DC.B	'!',$27,'(),-.0123456789:?'
	DC.B	'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',-1

	EVEN

TEXTE	DS.B	1
	dc.b	"    YO FANS !!!  THE NEW FRENCH LEADER   SUPREMACY   BRINGS YOU THIS TIME THE COMPACT DISK 13 : WHICH CONTAINS THE FOLLOWING GAMES : TAP F1 FOR PUSH OVER  ( ALL BY THE REPLICANTS )  OR  TAP F2 FOR CYBERTYX  ( PACKED BY RAZAAC OF "
	DC.B	"SUPREMACY AND OF FUZION ) .... WARNING FOR PUSH OVER IF YOU WANT THE INTRO ( VERY GOOD BY THE WAY ) OF THIS GAMES DEMAND US THE MENU 12 ... HERE IS ONLY THE PROGRAM OF PUSH OVER ..... CREDITS FOR THIS MENU : CODE ( TRAP 16, FOX LE FOU )"
        DC.B    " - GFX ( TWIX ) - COMPIL ( RAZAAC ) ...."
        DC.B    "OUR BESTS REGARDS GO TO : FUZION - REPLICANTS - I.C.S -"
	DC.B    " OXBOW (CONTACT US) - RADIATION (CONTACT US) - PURE ENERGY - MAD VISION - TAL (CONTACT US) - BAD BOYS - T.L.B (CONTACT US)  AND TO ALL FRIENDS AND CONTACTS .... NO GREETS TO : BASTARD INTER. (YOU ARE A POOR MENTALITY) , BLACK TWINS "
        DC.B	"(EXEMPLE OF FRENCH LAMERS) ..... THE FAMOUS MEMBERS ARE : T.L.F ( FOX LE FOU , TWIX , TRAP 16 , CUSTODIAN , DR STEIN ) AND THE REBELS ( RAZAAC , THANOS , GILLIUS , ACHILLE , MIK , GREG , 9 DAN , ACROPOLE , PETER , THE REDEEMER ) .."
        DC.B    "... WE RESEARCH CODERS , CRACKERS , PACKERS , SUPPLIERS ... IN FRANCE OR ANYWHERE  OR IF YOU WANT ANY TITLES WRITE TO :  SUPREMACY   B.P 66   59420 MOUVAUX   FRANCE  .....  MERRY CHRISTMAS AND HAPPY NEW YEAR 1993  .........",-1

	even

entete	incbin	"A:\entete.dat"

	EVEN

FONTES	INCBIN	A:\MINDBOMB.PI1

	ds.b	32000

	even


	section	bss

	even

game	ds.w	1

	even

save_68	ds.l	1

	even

save_70	ds.l	1

	even

save_118
	ds.l	1

	even

save_120
	ds.l	1

	even

save_a07
	ds.l	1

	even

save_a09
	ds.l	1

	even

save_a0f
	ds.l	1

	even

save_a11
	ds.l	1

	even

save_a13
	ds.l	1

	even

save_a1b
	ds.l	1

	even


save_a17
	ds.l	1

	even

key	ds.w	1

	even

SAVE_SCR	DS.L	1		* ECRAN ORIGINEL
SAVE_SCR1	DS.L	1		* PHYSTOP-32768
SAVE_SCR2	DS.L	1		* PHYSTOP-768
PALETTE		DS.W	16		* PALETTE
SAVE_SUP	DS.L	1
SAVE_RES	DS.W	1


	even

ancien_ecran
	ds.l	1

	even

call	ds.l	1

	even

ecran	ds.b	87040

	even

	