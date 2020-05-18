DECOMPACTER_LIGNES: ;-----------------------------------------------------------
;paramˆtres entr‚e:
;  4(SP).L = adresse de la source
;  8(SP).L = adresse de la destination
; 12(SP).L = taille d'une ligne en octets (y compris les bits inutiles)
; 16(SP).L = nombre de lignes
; 20(SP).W = nombre de bits inutiles … droite

;registres:
 ;     D6.L = taille d'une ligne (copie)
 ;     D7.L = reste en lignes
 ;     A3.L = adresse de la partie 32b
 ;     A4.L = adresse de la partie 16b
 ;     A5.L = adresse de la partie  8b
 ;     A6.L = adresse de la destination

;paramˆtre  sortie:
 ;     D0.B = erreur

	MOVEA.L SP,A0
	MOVEM.L D3-D7/A3-A6,-(SP)
	MOVEA.L 4(A0),A3
	MOVEA.L A3,A4
	ADDA.L	(A3)+,A4
	MOVEA.L A4,A5
	ADDA.L	(A3)+,A5
	MOVEA.L  8(A0),A6
	MOVE.L	12(A0),D6
	MOVE.L	16(A0),D7

EXTRAIRE_L:
	TST.L	D7
	BNE.S	.1
       ;effacer la portion inutile droite
	MOVEM.L (SP)+,D3-D7/A3-A6
	MOVE	20(SP),D0
	BEQ.S	.2
	MOVEQ	#-1,D1
	LSL.L	D0,D1
	MOVEA.L  8(SP),A0
	MOVE.L	12(SP),D0
	LEA	-4(A0,D0.L),A0
	MOVE.L	16(SP),D2
.3	AND.L	D1,(A0)
	ADDA.L	D0,A0
	SUBQ.L	#1,D2
	BNE	.3
.2	SF	D0
	RTS
.1	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0
	BPL.S	DLQQ
	MOVE	D0,D1
	ANDI	#%01111000,D1
	LSR	#1,D1
	LEA	TABCOD_L(PC),A0
	ANDI	#%111,D0 ;^Z
	JMP	(A0,D1)

ERREUR_L:
	MOVEM.L (SP)+,D3-D7/A3-A6
	ST	D0
	RTS

TABCOD_L:
	JMP	DLCN(PC)
	JMP	DLCR(PC)
	JMP	DLU0(PC)
	JMP	DLU1(PC)
	JMP	DLE1P(PC)
	JMP	DLE1W(PC)
	JMP	DLE1L(PC)
	JMP	DLENP(PC)
	JMP	DLENW(PC)
	JMP	DLENL(PC)
	JMP	DLI1P(PC)
	JMP	DLI1W(PC)
	JMP	DLI1L(PC)
	JMP	DLINP(PC)
	JMP	DLINW(PC)
	JMP	DLINL(PC)

DLQQ:  ;D0.L=nombre
	BNE.S	.1
	MOVE	(A4)+,D0
	ADDI	#127,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVEA.L A3,A0
	MOVEA.L A6,A1
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.2	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.2
	ADDA.L	D0,A3
	ADDA.L	D0,A6
	BSR	COPIER
	BRA	EXTRAIRE_L

DLCN:  ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	MOVE.L	D0,-(SP)
	MOVEM.L A3-A6,-(SP)
	ADDA.L	D0,A6
	BSR	DECOMPACTER
	ADDA	#20,SP
	TST.B	D0
	BMI	ERREUR_L
	MOVEA.L A0,A3
	MOVEA.L A1,A4
	MOVEA.L A2,A5
	BRA	EXTRAIRE_L

DLCR:  ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	MOVE.L	D0,-(SP)
	MOVEM.L A3-A6,-(SP)
	ADDA.L	D0,A6
	BSR	DECOMPACTER_R
	ADDA	#20,SP
	TST.B	D0
	BMI	ERREUR_L
	MOVEA.L A0,A3
	MOVEA.L A1,A4
	MOVEA.L A2,A5
	BRA	EXTRAIRE_L

DLU0:  ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVEA.L A6,A0
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	ADDA.L	D0,A6
	BSR	UNI_0
	BRA	EXTRAIRE_L

DLU1:  ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVEA.L A6,A0
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	ADDA.L	D0,A6
	BSR	UNI_1
	BRA	EXTRAIRE_L

DLE1P: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D5
	MOVE.L	A6,D4
	SUB.L	D6,D4
.3	MOVEA.L D4,A0
	MOVEA.L A6,A1
	MOVE.L	D6,D0
	BSR	COPIER
	ADDA.L	D6,A6
	SUBQ.L	#1,D5
	BNE	.3
	BRA	EXTRAIRE_L

DLE1W: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D5
	MOVEA.L A6,A0
	ADDA	(A4)+,A0
	MOVE.L	A0,D4
.3	MOVEA.L D4,A0
	MOVEA.L A6,A1
	MOVE.L	D6,D0
	BSR	COPIER
	ADDA.L	D6,A6
	SUBQ.L	#1,D5
	BNE	.3
	BRA	EXTRAIRE_L

DLE1L: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D5
	MOVE.L	A6,D4
	ADD.L	(A3)+,D4
.3	MOVEA.L D4,A0
	MOVEA.L A6,A1
	MOVE.L	D6,D0
	BSR	COPIER
	ADDA.L	D6,A6
	SUBQ.L	#1,D5
	BNE	.3
	BRA	EXTRAIRE_L

DLENP: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
       ;calcul de l'adresse et du nombre en octets
	MOVE.L	D0,D1
	MOVEA.L A6,A0
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	SUBA.L	D0,A0
	MOVEA.L A6,A1
	ADDA.L	D0,A6
	BSR	COPIER
	BRA	EXTRAIRE_L

DLENW: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVEA.L A6,A0
	ADDA	(A4)+,A0
       ;calcul du nombre en octets
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	MOVEA.L A6,A1
	ADDA.L	D0,A6
	BSR	COPIER
	BRA	EXTRAIRE_L

DLENL: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVEA.L A6,A0
	ADDA.L	(A3)+,A0
       ;calcul du nombre en octets
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	MOVEA.L A6,A1
	ADDA.L	D0,A6
	BSR	COPIER
	BRA	EXTRAIRE_L

DLI1P: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D5
	MOVE.L	A6,D4
	SUB.L	D6,D4
.3	MOVEA.L D4,A0
	MOVEA.L A6,A1
	MOVE.L	D6,D0
	BSR	COPIER_I
	ADDA.L	D6,A6
	SUBQ.L	#1,D5
	BNE	.3
	BRA	EXTRAIRE_L

DLI1W: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D5
	MOVEA.L A6,A0
	ADDA	(A4)+,A0
	MOVE.L	A0,D4
.3	MOVEA.L D4,A0
	MOVEA.L A6,A1
	MOVE.L	D6,D0
	BSR	COPIER_I
	ADDA.L	D6,A6
	SUBQ.L	#1,D5
	BNE	.3
	BRA	EXTRAIRE_L

DLI1L: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVE.L	D0,D5
	MOVE.L	A6,D4
	ADD.L	(A3)+,D4
.3	MOVEA.L D4,A0
	MOVEA.L A6,A1
	MOVE.L	D6,D0
	BSR	COPIER_I
	ADDA.L	D6,A6
	SUBQ.L	#1,D5
	BNE	.3
	BRA	EXTRAIRE_L

DLINP: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
       ;calcul de l'adresse et du nombre en octets
	MOVE.L	D0,D1
	MOVEA.L A6,A0
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	SUBA.L	D0,A0
	MOVEA.L A6,A1
	ADDA.L	D0,A6
	BSR	COPIER_I
	BRA	EXTRAIRE_L

DLINW: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVEA.L A6,A0
	ADDA	(A4)+,A0
       ;calcul du nombre en octets
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	MOVEA.L A6,A1
	ADDA.L	D0,A6
	BSR	COPIER_I
	BRA	EXTRAIRE_L

DLINL: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#7,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#7+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_L
	MOVEA.L A6,A0
	ADDA.L	(A3)+,A0
       ;calcul du nombre en octets
	MOVE.L	D0,D1
	MOVEQ	#0,D0
.3	ADD.L	D6,D0
	SUBQ.L	#1,D1
	BNE	.3
	MOVEA.L A6,A1
	ADDA.L	D0,A6
	BSR	COPIER_I
	BRA	EXTRAIRE_L

DECOMPACTER: ;------------------------------------------------------------------
;paramˆtres entr‚e:
 ;  4(SP).L = adresse de la partie 32b
 ;  8(SP).L = adresse de la partie 16b
 ; 12(SP).L = adresse de la partie  8b
 ; 16(SP).L = adresse de la destination
 ; 20(SP).L = taille de la destination

;registres:
 ;     D6.L = adresse en bit de la destination
 ;     D7.L = reste en bits
 ;     A3.L = adresse de la partie 32b
 ;     A4.L = adresse de la partie 16b
 ;     A5.L = adresse de la partie  8b
 ;     A6.L = adresse de la destination

;paramˆtres sortie:
 ;     D0.B = erreur
 ;     A0.L = adresse de la partie 32b actualis‚e
 ;     A1.L = adresse de la partie 16b actualis‚e
 ;     A2.L = adresse de la partie  8b actualis‚e

	LEA	4(SP),A0
	MOVEM.L D3-D7/A3-A6,-(SP)
	MOVEM.L (A0)+,A3-A6
	MOVEQ	#7,D6
	MOVE.L	(A0),D7
	LSL.L	#3,D7
       ;brouillon … prot‚ger pour mode superviseur
	SUBQ	  #4,SP

EXTRAIRE:	TST.L D7
	BNE.S	.1
	MOVEA.L A3,A0
	MOVEA.L A4,A1
	MOVEA.L A5,A2
	ADDQ	#4,SP ;brouillon
	MOVEM.L (SP)+,D3-D7/A3-A6
	SF	D0
	RTS
.1	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0
	MOVE	#%11000000,D1
	MOVE	D1,D2
	AND	D0,D1
	LSR	#4,D1
	LEA	TABCOD(PC),A0
	NOT	D2
	AND	D2,D0 ;^Z
	JMP	(A0,D1)

ERREUR: ADDQ	#4,SP ;brouillon
	MOVEM.L (SP)+,D3-D7/A3-A6
	ST	D0
	RTS

TABCOD: JMP	DMQ(PC)
	JMP	DM0(PC)
	JMP	DM1(PC)
	JMP	DMR(PC)

DMQ:  ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDI	#63,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#63+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR
	CMPI	#7,D6
	BEQ	.3
      ;on aura:
      ;D0=nbre octets … lire
      ;D1=nbre octets … ‚crire
      ;D2=nbre bits partie pleine
      ;D3=nbre bits partie vide
	MOVE	D0,D4
	MOVE.L	D0,D5
	ADDQ.L	#7,D0
	LSR.L	#3,D0
	MOVE	D0,D1
	ADDQ	#1,D1
	MOVE	D6,D3
	ADDQ	#1,D3
	MOVEQ	#8,D2
	SUB	D3,D2
	ANDI	#%111,D4
	BEQ.S	.4
	SUB	D3,D4
	BHI.S	.4
	SUBQ	#1,D1
.4	MOVEA.L A6,A0
	SUB.L	D5,D6
	BPL.S	.5
	NEG.L	D6
	SUBQ.L	#1,D6
	MOVE	D6,D4
	LSR.L	#3,D6
	LEA	1(A6,D6),A6
	MOVEQ	#7,D6
	ANDI	#%111,D4
	SUB	D4,D6
.5	MOVE	D0,D4
	LSR	#2,D4
	BEQ.S	.16B
	SUBQ	#1,D4

.32B	MOVE.B	(A3),D5
	LSR.B	D2,D5
	OR.B	D5,(A0)+
	SUBQ	#1,D1
	MOVE.L	(A3)+,D5
	LSL.L	D3,D5
	MOVEA.L SP,A1
	MOVE.L	D5,(A1)
	MOVE.B	(A1)+,(A0)+
	MOVE.B	(A1)+,(A0)+
	MOVE.B	(A1)+,(A0)+
	SUBQ	#3,D1
	BEQ	EXTRAIRE
	MOVE.B	(A1),(A0)
	DBRA	D4,.32B

.16B	BTST	#1,D0
	BEQ.S	.8B
	MOVE.B	(A4),D5
	LSR.B	D2,D5
	OR.B	D5,(A0)+
	SUBQ	#1,D1
	MOVE	(A4)+,D5
	LSL	D3,D5
	MOVEA.L SP,A1
	MOVE	D5,(A1)
	MOVE.B	(A1)+,(A0)+
	SUBQ	#1,D1
	BEQ	EXTRAIRE
	MOVE.B	(A1),(A0)

.8B	BTST	#0,D0
	BEQ	EXTRAIRE
	MOVE.B	(A5)+,D5
	LSR.B	D2,D5
	OR.B	D5,(A0)+
	SUBQ	#1,D1
	BEQ	EXTRAIRE
	MOVE.B	-1(A5),D5
	LSL.B	D3,D5
	MOVE.B	D5,(A0)
	BRA	EXTRAIRE

.3	MOVEA.L A6,A0
	SUB.L	D0,D6
	BPL.S	.6
	NEG.L	D6
	SUBQ.L	#1,D6
	MOVE	D6,D4
	LSR.L	#3,D6
	LEA	1(A6,D6),A6
	MOVEQ	#7,D6
	ANDI	#%111,D4
	SUB	D4,D6
.6	ADDQ.L	#7,D0
	LSR.L	#3,D0 ;nbre octets … lire
	MOVE	D0,D4
	LSR	#2,D4
	BEQ.S	.2O
	SUBQ	#1,D4

.4O	MOVE.B	(A3)+,(A0)+
	MOVE.B	(A3)+,(A0)+
	MOVE.B	(A3)+,(A0)+
	MOVE.B	(A3)+,(A0)+
	DBRA	D4,.4O

.2O	BTST	#1,D0
	BEQ.S	.1O
	MOVE.B	(A4)+,(A0)+
	MOVE.B	(A4)+,(A0)+

.1O	BTST	#0,D0
	BEQ	EXTRAIRE
	MOVE.B	(A5)+,(A0)
	BRA	EXTRAIRE

DM0:  ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDI	#63,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#63+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR
	CMPI	#7,D6
	BNE.S	.3
	CLR.B	(A6)
.3	SUB.L	D0,D6
	BPL	EXTRAIRE
	ADDQ	#1,A6
	MOVEA.L A6,A0
	NEG.L	D6
	SUBQ.L	#1,D6
	MOVE.L	D6,D0
	MOVE	D6,D1
	MOVE.L	D6,D2
	LSR.L	#3,D0
	ADDA	D0,A6
	MOVEQ	#7,D6
	ANDI	#%111,D1
	SUB	D1,D6
	SUBQ.L	#1,D2
	BMI	EXTRAIRE
	LSR.L	#3,D2 ;#octets-1 … 0
.4	CLR.B	(A0)+
	DBRA	D2,.4
	BRA	EXTRAIRE

DM1:  ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDI	#63,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#63+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR
	CMPI	#7,D6
	BNE.S	.3
	CLR.B	(A6)
.3	MOVE	D6,D1
	SUB.L	D0,D6
	BPL.S	.RP
      ;remplissage total
	MOVEQ	#-1,D0
	LSL	D1,D0
	LSL	#1,D0
	NOT	D0
	OR.B	D0,(A6)+
	MOVEA.L A6,A0
	NEG.L	D6
	SUBQ.L	#1,D6
	MOVE.L	D6,D0
	MOVE	D6,D1
	MOVE.L	D6,D2
	LSR.L	#3,D0
	ADDA	D0,A6
	MOVEQ	#7,D6
	ANDI	#%111,D1
	SUB	D1,D6
	SUBQ.L	#1,D2
	BMI	EXTRAIRE
	LSR.L	#3,D2 ;#octets-1 … 1
	MOVEQ	#-1,D0
.4	MOVE.B	D0,(A0)+
	DBRA	D2,.4
	CMPI	#7,D6
	BEQ	EXTRAIRE
	LSL	D6,D0
	LSL	#1,D0
	AND.B	D0,-(A0)
	BRA	EXTRAIRE

.RP   ;remplissage partiel
	MOVEQ	#-1,D2
	LSL	D0,D2
	NOT	D2
	LSL	D6,D2
	LSL	#1,D2
	OR.B	D2,(A6)
	BRA	EXTRAIRE

DMR:  ;D0.L=taille+nombre
	MOVE	D0,D1
	ANDI	#%111100,D1
	LSR	#1,D1
	LEA	TABMR(PC),A0
	MOVE	(A0,D1),D2
	ANDI	#%11,D0
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDQ	#3,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#3+255,D0
.1	ADDQ.L	#1,D0
	MOVE	D2,D3
	MULU	D0,D3
	SUB.L	D3,D7
	BMI	ERREUR
	LEA	EXTM(PC),A0
	LSL	#1,D1
	JMP	(A0,D1)

TABMR:	DC.W	  8, 9,10,11,12,13,14,15
	DC.W	 16,17,19,23,24,29,31,32

EXTM:	JMP	 .8(PC) ; 8
	JMP	 .16(PC) ; 9
	JMP	 .16(PC) ;10
	JMP	 .16(PC) ;11
	JMP	 .16(PC) ;12
	JMP	 .16(PC) ;13
	JMP	 .16(PC) ;14
	JMP	 .16(PC) ;15
	JMP	 .16(PC) ;16
	JMP	 .24(PC) ;17
	JMP	 .24(PC) ;19
	JMP	 .24(PC) ;23
	JMP	 .24(PC) ;24
	JMP	 .32(PC) ;29
	JMP	 .32(PC) ;31
	JMP	 .32(PC) ;32

.8	MOVEA.L SP,A0
	CLR	(A0)
	MOVE.B	(A5)+,(A0)
	MOVE.L	(A0),D1
	BRA.S	DMR2

.16	MOVEQ	#0,D1
	MOVE	(A4)+,D1
	SWAP	D1
	BRA.S	DMR2

.24	MOVEA.L SP,A0
	MOVE	(A4)+,(A0)+
	MOVE.B	(A5)+,(A0)+
	CLR.B	(A0)
	MOVE.L	(SP),D1
	BRA.S	DMR2

.32	MOVE.L	(A3)+,D1

DMR2  ;D0=nombre
      ;D1=motif
      ;D2=taille en bits
      ;D3=d‚but motif
      ;D4=fin motif
	MOVE.L	D1,D3
	ROL.L	#8,D3
	MOVE.L	D1,D4
	LSL.L	D6,D4
	LSL.L	#1,D4
	MOVEQ	#7,D5
	SUB	D6,D5
	BEQ.S	.1
	LSR.B	D5,D3
	OR.B	D3,(A6)
.2	SUB	D2,D6
	BPL.S	.F
	ADDQ	#1,A6
	MOVEA.L SP,A1
	MOVE.L	D4,(A1)
	MOVE.B	(A1)+,(A6)
	ADDQ	#8,D6
	BPL.S	.F
	ADDQ	#1,A6
	MOVE.B	(A1)+,(A6)
	ADDQ	#8,D6
	BPL.S	.F
	ADDQ	#1,A6
	MOVE.B	(A1)+,(A6)
	ADDQ	#8,D6
	BPL.S	.F
	ADDQ	#1,A6
	MOVE.B	(A1),(A6)
	ADDQ	#8,D6
	BPL.S	.F
	ADDQ	#1,A6
	ADDQ	#8,D6
.F	SUBQ.L	#1,D0
	BNE	DMR2
	BRA	EXTRAIRE

.1	MOVE.B	D3,(A6)
	BRA	.2

DECOMPACTER_R: ;----------------------------------------------------------------
;paramˆtres entr‚e:
 ;  4(SP).L = adresse de la partie 32b
 ;  8(SP).L = adresse de la partie 16b
 ; 12(SP).L = adresse de la partie  8b
 ; 16(SP).L = adresse de la destination
 ; 20(SP).L = taille de la destination

;registres:
 ;     D7.L = reste en octets
 ;     A3.L = adresse de la partie 32b
 ;     A4.L = adresse de la partie 16b
 ;     A5.L = adresse de la partie  8b
 ;     A6.L = adresse de la destination

;paramˆtres sortie:
 ;     D0.B = erreur
 ;     A0.L = adresse de la partie 32b actualis‚e
 ;     A1.L = adresse de la partie 16b actualis‚e
 ;     A2.L = adresse de la partie  8b actualis‚e

	LEA	4(SP),A0
	MOVEM.L D3-D7/A3-A6,-(SP)
	MOVEM.L (A0)+,A3-A6
	MOVE.L	(A0),D7

EXTRAIRE_R:
	TST.L D7
	BNE.S	.1
	MOVEA.L A3,A0
	MOVEA.L A4,A1
	MOVEA.L A5,A2
	MOVEM.L (SP)+,D3-D7/A3-A6
	SF	D0
	RTS
.1	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0
	MOVE	#%11000000,D1
	MOVE	D1,D2
	AND	D0,D1
	LSR	#4,D1
	LEA	TABCOD_R(PC),A0
	NOT	D2
	AND	D2,D0 ;^Z
	JMP	(A0,D1)

ERREUR_R:
	MOVEM.L (SP)+,D3-D7/A3-A6
	ST D0
	RTS

TABCOD_R:
	JMP	DMQ_R(PC)
	JMP	DM0_R(PC)
	JMP	DM1_R(PC)
	JMP	DMR_R(PC)

DMQ_R: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDI	#63,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#63+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_R
	MOVE.L	D0,D1
	LSR.L	#2,D1
	BEQ.S	.2O
	SUBQ	#1,D1

.4O	MOVE.B	(A3)+,(A6)+
	MOVE.B	(A3)+,(A6)+
	MOVE.B	(A3)+,(A6)+
	MOVE.B	(A3)+,(A6)+
	DBRA	D1,.4O

.2O	BTST	#1,D0
	BEQ.S	.1O
	MOVE.B	(A4)+,(A6)+
	MOVE.B	(A4)+,(A6)+

.1O	BTST	#0,D0
	BEQ	EXTRAIRE_R
	MOVE.B	(A5)+,(A6)+
	BRA	EXTRAIRE_R

DM0_R: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDI	#63,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#63+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_R
.3	CLR.B	(A6)+
	SUBQ.L	#1,D0
	BNE	.3
	BRA	EXTRAIRE_R

DM1_R: ;D0.L=nombre
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDI	#63,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#63+255,D0
.1	SUB.L	D0,D7
	BMI	ERREUR_R
	MOVEQ	#-1,D1
.3	MOVE.B	D1,(A6)+
	SUBQ.L	#1,D0
	BNE	.3
	BRA	EXTRAIRE_R

DMR_R: ;D0.L=taille+nombre
	MOVE	D0,D1
	ANDI	#%110000,D1
	LSR	#2,D1
	ANDI	#%1111,D0
	BNE.S	.1
	MOVE.B	(A5)+,D0
	BEQ.S	.2
	ADDI	#15,D0
	BRA.S	.1
.2	MOVE	(A4)+,D0
	ADDI.L	#15+255,D0
.1	ADDQ.L	#1,D0
	LEA	EXTM_R(PC),A0
	JMP	(A0,D1)

EXTM_R: JMP	DMR8_R(PC)
	JMP	DMR16_R(PC)
	JMP	DMR24_R(PC)
	JMP	DMR32_R(PC)

DMR8_R	SUB.L	D0,D7
	BMI	ERREUR_R
	MOVE.B	(A5)+,D1
.1	MOVE.B	D1,(A6)+
	SUBQ.L	#1,D0
	BNE	.1
	BRA	EXTRAIRE_R

DMR16_R SUB.L	D0,D7
	SUB.L	D0,D7
	BMI	ERREUR_R
	MOVE.B	(A4)+,D1
	MOVE.B	(A4)+,D2
.1	MOVE.B	D1,(A6)+
	MOVE.B	D2,(A6)+
	SUBQ.L	#1,D0
	BNE	.1
	BRA	EXTRAIRE_R

DMR24_R SUB.L	D0,D7
	SUB.L	D0,D7
	SUB.L	D0,D7
	BMI	ERREUR_R
	MOVE.B	(A4)+,D1
	MOVE.B	(A4)+,D2
	MOVE.B	(A5)+,D3
.1	MOVE.B	D1,(A6)+
	MOVE.B	D2,(A6)+
	MOVE.B	D3,(A6)+
	SUBQ.L	#1,D0
	BNE	.1
	BRA	EXTRAIRE_R

DMR32_R SUB.L	D0,D7
	SUB.L	D0,D7
	SUB.L	D0,D7
	SUB.L	D0,D7
	BMI	ERREUR_R
	MOVE.B	(A3)+,D1
	MOVE.B	(A3)+,D2
	MOVE.B	(A3)+,D3
	MOVE.B	(A3)+,D4
.1	MOVE.B	D1,(A6)+
	MOVE.B	D2,(A6)+
	MOVE.B	D3,(A6)+
	MOVE.B	D4,(A6)+
	SUBQ.L	#1,D0
	BNE	.1
	BRA	EXTRAIRE_R

UNI_0: ;------------------------------------------------------------------------
;paramˆtres entr‚e:
 ; A0=destination
 ; D0=taille

	MOVE.L	D0,D1
	LSR.L	#5,D1
	BEQ.S	.1
	MOVEM.L D3-D6/A3-A6,-(SP)
	MOVEQ	#32,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEA	D3,A3
	MOVEA	D4,A4
	MOVEA	D5,A5
	MOVEA	D6,A6
.2	MOVEM.L D3-D6/A3-A6,(A0)
	ADDA	D2,A0
	SUBQ.L	#1,D1
	BNE	.2
	MOVEM.L (SP)+,D3-D6/A3-A6
.1	ANDI	#$1F,D0
	LSR	#2,D0
	BEQ.S	.F
	SUBQ	#1,D0
.3	CLR.L	(A0)+
	DBRA	D0,.3
.F	RTS

UNI_1: ;------------------------------------------------------------------------
;paramˆtres entr‚e:
 ; A0=destination
 ; D0=taille

	MOVE.L	D0,D1
	LSR.L	#5,D1
	BEQ.S	.1
	MOVEM.L D3-D6/A3-A6,-(SP)
	MOVEQ	#32,D2
	MOVEQ	#-1,D3
	MOVEQ	#-1,D4
	MOVEQ	#-1,D5
	MOVEQ	#-1,D6
	MOVEA	D3,A3
	MOVEA	D4,A4
	MOVEA	D5,A5
	MOVEA	D6,A6
.2	MOVEM.L D3-D6/A3-A6,(A0)
	ADDA	D2,A0
	SUBQ.L	#1,D1
	BNE	.2
	MOVEM.L (SP)+,D3-D6/A3-A6
.1	ANDI	#$1F,D0
	LSR	#2,D0
	BEQ.S	.F
	SUBQ	#1,D0
	MOVEQ	#-1,D1
.3	MOVE.L	D1,(A0)+
	DBRA	D0,.3
.F	RTS

COPIER: ;-----------------------------------------------------------------------
;paramˆtres entr‚e:
 ; A0=source
 ; A1=destination
 ; D0=taille

	MOVE.L	D0,D1
	LSR.L	#5,D1
	BEQ.S	.1
	MOVEM.L D3-D6/A3-A6,-(SP)
	MOVEQ	#32,D2
.2	MOVEM.L (A0)+,D3-D6/A3-A6
	MOVEM.L D3-D6/A3-A6,(A1)
	ADDA	D2,A1
	SUBQ.L	#1,D1
	BNE	.2
	MOVEM.L (SP)+,D3-D6/A3-A6
.1	ANDI	#$1F,D0
	LSR	#2,D0
	BEQ.S	.F
	SUBQ	#1,D0
.3	MOVE.L	(A0)+,(A1)+
	DBRA	D0,.3
.F	RTS

COPIER_I: ;---------------------------------------------------------------------
;paramˆtres entr‚e:
 ; A0=source
 ; A1=destination
 ; D0=taille

	MOVE.L	D0,D1
	LSR.L	#5,D1
	BEQ.S	.1
	MOVEM.L D3-D6,-(SP)
	MOVEQ	#16,D2
.2	MOVEM.L (A0)+,D3-D6
	NOT.L	D3
	NOT.L	D4
	NOT.L	D5
	NOT.L	D6
	MOVEM.L D3-D6,(A1)
	ADDA	D2,A1
	MOVEM.L (A0)+,D3-D6
	NOT.L	D3
	NOT.L	D4
	NOT.L	D5
	NOT.L	D6
	MOVEM.L D3-D6,(A1)
	ADDA	D2,A1
	SUBQ.L	#1,D1
	BNE	.2
	MOVEM.L (SP)+,D3-D6
.1	ANDI	#$1F,D0
	LSR	#2,D0
	BEQ.S	.F
	SUBQ	#1,D0
.3	MOVE.L	(A0)+,D2
	NOT.L	D2
	MOVE.L	D2,(A1)+
	DBRA	D0,.3
.F	RTS

EP16I: ;------------------------------------------------------------------------
;Enchevˆtrer les plans pour le VIDEL (Ex: 4 plans: LO ML MH HI)
;paramˆtres entr‚e:

 ;  4(SP).L=source
 ;  8(SP).L=destination
 ; 12(SP).L=taille d'un plan
 ; 16(SP).W=nombre de plan
 ; 18(SP).L=taille totale (surabondant mais ...)

	MOVEM.L 4(SP),A0-A1
	MOVE.L	18(SP),D0
	NEG.L	D0
	MOVEA.L D0,A2
	MOVE	16(SP),D0
	MOVE	D0,D2
	LSL	#1,D2 ;incr‚ment destination
	LEA	-2(A1,D2),A1
	SUBQ	#1,D0
.2	MOVE.L	12(SP),D1
.1	MOVE	(A0)+,(A1)
	ADDA	D2,A1
	SUBQ.L	#2,D1
	BNE	.1
	LEA	-2(A1,A2),A1
	DBRA	D0,.2
	RTS
