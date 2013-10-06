;Gestion du clavier.
;
;Explications: cette routine est directement tirÇe du mini-jeu pour Keops
;qu'on devait terminer... Le ST ne peut pas dÇtecter un appui
;simultanÇ sur plus de 2 touches, en dehors des "touches mortes" que sont
;les 2 Shift, Alternate, etc...
;
;Dans le jeu, on dirige un personnage pouvant voler, et on teste ici les
;3 fleches haut, bas et droit. Le perso peut tirer, la touche de tir est
;Alternate - une touche morte pour pouvoir tirer tout en se dÇplacant en
;diagonale par exemple.
;
;Chaque appui exÇcute dans le jeu une procÇdure spÇcifique, remplacÇes ici
;par des RTS.
;
;Il n'y a rien Ö faire Ö part changer les codes Scan des 3 fleches par les
;codes correspondant aux touches qu'on veut tester.
;Rappel: pour tester un lachÇ de touche, c'est le code Scan de la touche
;        +$80. Exemple pour la barre d'espace: $39+$80
;
;
;Code by Elric/Holocaust.


MAIN	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.W	#6,SP

	MOVE.L	#BUFFER,D0
	CLR.B	D0
	MOVE.L	D0,SCREEN1
	
	MOVE.B	SCREEN1+1,$FFFF8201.W
	MOVE.B	SCREEN1+2,$FFFF8203.W

	MOVE.W	#$2700,SR
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BSET	#6,$FFFFFA09.W
	BSET	#6,$FFFFFA15.W
	BCLR	#3,$FFFFFA17.W
	MOVE.L	#IT_CLAVIER,$118.W
	MOVE.L	#VBLR,$70.W
	CLR.W	NB_VBL
	MOVE.W	#$2300,SR

IT_VBL	BSR	VSYNC

	MOVE.W	#$700,$FFFF8240.W
	BSR	EXAM_KEYBOARD
	LEA	TABLE_CLAVIER,A0
	MOVE.L	(A0,D0.W),A0
	JSR	(A0)	;ON AGIT SUR LE PLAYER
	CLR	$FFFF8240.W

	BRA	IT_VBL

VSYNC	CMPI.W	#1,NB_VBL
	BLT.S	VSYNC
	CLR.W	NB_VBL
	RTS

VBLR	ADDQ.W	#1,NB_VBL
	MOVEM.L	D0-A6,-(SP)

	MOVE.L	SCREEN1,A0
	MOVE.B	FIRE,(A0)
	LEA	BUF_CLAV,A1
	MOVE.B	(A1)+,1(A0)
	MOVE.B	(A1)+,8(A0)
	MOVE.B	(A1)+,9(A0)

	MOVEM.L	(SP)+,D0-A6
	RTE

IT_CLAVIER	MOVEM.L	D0/A0/A1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	$FFFFFC02.W,D0
	CMPI.W	#$F0,D0
	BGE.S	.ON_SORT
	CMPI.B	#$38,D0
	BNE.S	.TST2
	ST	FIRE
	BRA.S	.ON_SORT
.TST2	CMPI.B	#$80+$38,D0
	BNE.S	.TST3
	SF	FIRE
	BRA.S	.ON_SORT
.TST3	;ACTIVATION POTENTIELLE
	LEA	TST_CLAV(PC),A0
	LEA	BUF_CLAV(PC),A1
	CMP.B	(A0)+,D0
	BNE.S	.NOT_1
	ST	(A1)
	BRA.S	.ON_SORT
.NOT_1	CMP.B	(A0)+,D0
	BNE.S	.NOT_2
	ST	1(A1)
	BRA.S	.ON_SORT
.NOT_2	CMP.B	(A0)+,D0
	BNE.S	.NOT_3
	ST	2(A1)
	BRA.S	.ON_SORT
.NOT_3	;DESACTIVATION POTENTIELLE
	CMP.B	(A0)+,D0
	BNE.S	.NOT_4
	SF	(A1)
	BRA.S	.ON_SORT
.NOT_4	CMP.B	(A0)+,D0
	BNE.S	.NOT_5
	SF	1(A1)
	BRA.S	.ON_SORT
.NOT_5	CMP.B	(A0)+,D0
	BNE.S	.NOT_6
	SF	2(A1)
	BRA	.ON_SORT
.NOT_6
.ON_SORT	MOVEM.L	(SP)+,D0/A0/A1
	RTE

GO_DOWN	RTS

GO_LEFT	RTS

GO_UP	RTS

GO_UP_LEFT	RTS

GO_RIGHT	RTS

GO_UP_RIGHT	RTS

TABLE_CLAVIER	DC.L	GO_DOWN	;0
	DC.L	GO_LEFT	;1
	DC.L	GO_UP	;2
	DC.L	GO_UP_LEFT	;3
	DC.L	GO_RIGHT	;4
	DC.L	GO_DOWN	;5
	DC.L	GO_UP_RIGHT	;6
	DC.L	GO_DOWN	;7 (MOUI, BOF...)

	;CETTE PROCEDURE EXAMINE BUF_CLAV (3.B)
	;ET RENVOIE DANS D0 UNE VALEUR ENTRE 0 ET 7
	;0-->7:DIRECTIONS
	;0:AUCUN APPUI, TOUTES LES TOUCHES SONT RELACHêES
	;1:GAUCHE
	;2:HAUT
	;3:HAUT-GAUCHE
	;4:DROITE
	;5:RIEN A FAIRE, A IGNORER <--> COMME POUR 0
	;6:HAUT-DROITE
	;7:IMPOSSIBLE!!! (DANS LE DOUTE...COMME POUR 0...)

	;D0 EST PREMULTIPLIê PAR 4...
EXAM_KEYBOARD	LEA	BUF_CLAV(PC),A0
	MOVEQ	#0,D0
	CMPI.B	#-1,(A0)+
	BNE.S	.PAS_GAUCHE
	ADDQ.W	#1*4,D0
.PAS_GAUCHE	CMPI.B	#-1,(A0)+
	BNE.S	.PAS_HAUT
	ADDQ.W	#2*4,D0
.PAS_HAUT	CMPI.B	#-1,(A0)+
	BNE.S	.PAS_DROITE
	ADDI.W	#4*4,D0
.PAS_DROITE	RTS

	;CODES D'ACTIVATION DES 3 FLECHES,
	;SUIVI DES CODES DE DESACTIVATION DE CES MEME FLECHES.
TST_CLAV	DC.B	$4B,$48,$4D
	DC.B	$4B+$80,$48+$80,$4D+$80

	;FLAG GAUCHE, FLAG HAUT, FLAG_DROIT
	;-1=ACTIF, 0=INACTIF
BUF_CLAV	DS.B	3
FIRE	DS.B	1

	SECTION	BSS
NB_VBL	DS.W	1
SCREEN1	DS.L	1
	DS.B	256
BUFFER	DS.B	32000