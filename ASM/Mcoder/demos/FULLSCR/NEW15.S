	OPT	O+
;
; AMELIORER :
;
;	- COULEURS DU FOND
;	- COULEURS DE L'AVANT PLAN
;	- OPTIMISATION DES REGISTRES VERTICALEMENT...
;
ECRAN0		EQU	$61000
ECRAN1		EQU	$70800
TIMEX		EQU	59+4		;TEMPS RESTANT SUR LIGNE 312
COMPDIGIT	EQU	0		;0=COMPRESSE TABLE DE DIGIT
COMPFNT		EQU	0		;0=FONTE OPTIMISEE (cf MESS.S)
INCL		EQU	1		;0=PAS D'INCLUDE
TEST		EQU	1		;1=PAS DE TEST D'ERREUR
CMPCOURBE	EQU	0		;0=COURBE COMPACTEE
PRG		EQU	0		;0=PRG 1=BIN
TRILOC		EQU	1		;TRI VERTICAL POUR OPTIMISATION DU CODE
nbstarsin	EQU	22*4
NOSTAR		EQU	15		;optimisation pour ‚toiles
intstar		EQU	276*4/nbstarsin	;intervalle entre les ‚toiles
nbstarsout	EQU	nbstarsin-NOSTAR
cycstar		EQU	440-24-2	;largeur de l'‚cran
;
; EXEMPLES DE TIMINGS SUR ST
;
;	MOVEP	D0,$FFFF8800(A0)	=+4 CYCLES
;	MOVE.B	$FFFFFC02.W,D0		=+8 CYCLES
;	LEA	(A0,D0),A0		=+4 CYCLES
;
CHANGE	EQU	2
ESPC	EQU	4
FIRST	EQU	1			;PREMIERE LIGNE DEGRADE
HAUT	EQU	260-16			;HAUTEUR DEGRADE
LINE270	EQU	270
L312	EQU	312
TIMING1	EQU	356/4			;gauche
TIMING2	EQU	(356-8)/4		;gauche2
TIMING3	EQU	(512-92)/4		;digit
;
;LE PROGRAMME SUIVANT NE MARCHE PAS :
;
;SETPAT	MACRO
;PATTERN	SET	PATTERN<X>
;	ENDM
;	SETPAT
;	IFEQ	X
;	ENDC
;
;DCB.W 0,$4E71 GENERE 64K DE CODE !!!
;
NOLOGO	EQU	1		;0=PAS DE LOGO
LENGTH	EQU	28950
;TIMING4	EQU	512/4
;
; VERSION 2.0 :
;	GESTION DE LA DIGIT...
; VERSION 2.1 :
;	RAJOUT DU SPRITE
; VERSION 3.0 :
;	TOUT REFAIT PAR GENERATION DE CODE !!!
;	‡a a march‚ le jour meme !!!
; VERSION 3.1 :
;	AMELIORATION AFFICHAGE DES SPRITES (ON N'AFFICHE PLUS LES BLANCS)
; VERSION 3.2 :
;	OPTIMISATION DES REGISTRES COLONNE PAR COLONNE !!!!
;
NBLIG	EQU	10		;NB LIGNES
NBCOL	EQU	26		;NB COLONNES
;
; CE QU'IL FAUT RETENIR :
;
;	- POUR ALLER AUSSI VITE QUE LE SPOT, IL FAUT EXECUTER 512 CYCLES
;	   PAR LIGNE.
;	- NB MAXIMUM DE LIGNES AFFICHEES : 313-13
;	- LA MACRO BORD1 DOIT ETRE UTILISEE POUR TOUTES LES LIGNES
;	   SAUF CELLES UTILISANT BORD2
;	- LA MACRO BORD2 DOIT ETRE UTILISEE POUR LES LIGNES 199 ET 299
;	- RESOLUTION MAXIMALE : 440*276 ($E6*276=63480 OCTETS)
;	- VERTICALEMENT, IL Y A 313 LIGNES
;
; description de l'overscan :
;
; lignes 1 … 199 : BORD1
; ligne 200 : BORD2
; lignes 201 … 270 : BORD1
; lignes 271 … 299 : RIEN
; lignes 300 : BORD2
; lignes 301 … 313 : BORD1
;
;
; 4 registres constants :
;	A0=$FFFF8260
;	A1=$FFFF820A
;	A7=POINTEUR DIGIT
;	D0=0
;	D1=2
;
;
; SUPER MACRO DE BOUCLE AU CYCLE PRES !!!
;
WAIT	MACRO
N3	SET	(\1-7)-((\1-7)/5)*5
BEST	SET	3
MIN	SET	N3		;RECORD A BATTRE

N2	SET	(\1-6)&3
	IFLE	N2-MIN
BEST	SET	2
MIN	SET	N2
	ENDC

N1	SET	(\1-5)-((\1-5)/3)*3
	IFLE	N1-MIN
BEST	SET	1
MIN	SET	N1
	ENDC

	IFEQ	BEST-1
	MOVEQ	#(\1-5)/3,\2
\@	DBRA	\2,\@
	IFNE	N1
	DCB.W	N1,$4E71
	ENDC
	ENDC

	IFEQ	BEST-2
	MOVEQ	#(\1-6)/4,\2
\@	NOP
	DBRA	\2,\@
	IFNE	N2
	DCB.W	N2,$4E71
	ENDC
	ENDC

	IFEQ	BEST-3
	MOVEQ	#(\1-7)/5,\2
\@	NOP
	NOP
	DBRA	\2,\@
	IFNE	N3
	DCB.W	N3,$4E71
	ENDC
	ENDC

	ENDM

	IFNE	PRG
	IFEQ	COMPFNT
	ORG	$10000
	ELSEIF
	ORG	$10000-$80
	ENDC
	ENDC

	IFNE	COMPFNT
;
; transforme les codes ascii du message en code DEXION
;
	lea	MESSAGE(PC),A0
	MOVE	#NBCOL*NBLIG-1,D7
	LEA	CONVERT-$20(PC),A1
	MOVEQ	#0,D0
TRANSG
	MOVE.B	(A0),D0
	MOVE.B	(A1,D0.W),(A0)+
	DBRA	D7,TRANSG
	IFNE	PRG
	ILLEGAL
CONVERT
	DC.B	0		;' '
	DC.B	38		;!
	DC.B	0,0,0,0,0,0
	DC.B	41		;(
	DC.B	42		;)
	DC.B	0,0
	DC.B	37		;,
	DC.B	0
	DC.B	37		;.
	DC.B	40		;/
	DC.B	27,28,29,30,31	;01234
	DC.B	32,33,34,35,36	;56789
	DC.B	43		;:
	DC.B	0,0,0,0
	DC.B	39		;?
	DC.B	0
	DC.B	1,2,3,4,5	;ABCDE
	DC.B	6,7,8,9,10	;FGHIJ
	DC.B	11,12,13,14,15	;KLMNO
	DC.B	16,17,18,19,20	;PQRST
	DC.B	21,22,23,24,25	;UVWXY
	DC.B	26		;Z
	EVEN
	OPT	T-
	DS.B	$10000-*	;CODE COMMENCE EN $10000
	OPT	T+
	ENDC
	ENDC

	IFEQ	PRG
;
; CHARGE LA DIGIT
;
	CLR	-(SP)
	PEA	FILE(PC)
	MOVE	#$3D,-(SP)
	TRAP	#1
	ADDQ	#8,SP
	MOVE	D0,D7
	BMI.S	ERREUR
	PEA	TRAVAIL
	PEA	(LENGTH).W
	MOVE	D7,-(SP)
	MOVE	#$3F,-(SP)
	TRAP	#1
	LEA	12(SP),SP
	TST.L	D0
	BMI.S	ERREUR
	MOVE	D7,-(SP)
	MOVE	#$3E,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	BRA.S	NOERR
ERREUR	ILLEGAL
NOERR
	ELSEIF
	BRA	NOWELCOME
	DC.B	"VERSION 1.0 15/12/89 "
	DC.B	"CONTACT ME IF : "
	DC.B	"1) IT DOESN'T WORK ON YOUR SHIFTER, "
	DC.B	"2) YOU FIND ANY IMPROVEMENT IN THE CODE, "
	DC.B	"3) YOU HAVE GOOD IDEAS OF DEMO, "
	DC.B	"4) YOU ARE A GOOD DEMO CODER, "
	DC.B	"5) OR A GOOD GRAPHIST, "
	DC.B	"6) OR A GOOD MUSICIAN, "
	DC.B	"7) OR A GOOD SCROLLTEXT WRITER, "
	DC.B	"8) OR A PRETTY GIRL... "
	DC.B	"IF YOU ARE IN ONE OF THESE CASES, CALL ME AT 60296219 "
	DC.B	"(SEINE-ET-MARNE,FRANCE) ASK FOR JEAN-CHARLES "
	DC.B	"I'M NOT AN HACKER : I'M A PROFESSIONAL "
	DC.B	"GAME DESIGNER (DON'T BOTHER ME WITH GAMES) "
	DC.B	"DON'T LOOK FORWARD, THERE IS NOTHING INTERESTING "
	DC.B	"(IT'S TOO MUCH COMPLEX FOR YOU, AH AH !)"
	DC.B	0
	EVEN
NOWELCOME
	LEA	DIGISND(PC),A0
	LEA	TRAVAIL,A1
	MOVE	#(LENGTH+3)/4-1,D0
MOVDIG	MOVE.L	(A0)+,(A1)+
	DBRA	D0,MOVDIG
	ENDC
;
; transforme un son digit 10Khz en 15 Khz !!!
;
	lea	TRAVAIL,a0
	lea	TRAVAIL+LENGTH,a1
	IFEQ	PRG
	lea	DIGISND,a2
	ELSEIF
	lea	DIGISND(PC),a2
	ENDC
	moveq	#10,d7		;fr‚quence d‚part
	moveq	#15,d6		;fr‚quence arriv‚e
	move.l	d6,d4
	neg.l	d4		;accumulateur
	moveq	#0,d3		;latch last mesure
rallonge:
	add	d7,d4
	bcc.s	nxtbyte
	sub	d6,d4
	moveq	#0,d0
	move.b	(a0),d0
	add	d0,d3
	lsr	#1,d3
	MOVE	D3,D0
	ADD	D0,D0
	ADD	D3,D0
	ADD	D0,D0		;*6
	move	d0,(a2)+
nxtbyte:
	move.b	(a0)+,d3
	MOVE	D3,D0
	ADD	D0,D0
	ADD	D3,D0
	ADD	D0,D0
	move	D0,(a2)+
	cmp.l	a1,a0
	blo.s	rallonge

	IFEQ	TEST
	CMP.L	#ENDDIGIT,A2
	BEQ.S	1$
	ILLEGAL
1$
	ENDC

	IFEQ	COMPDIGIT
	LEA	GENDIG(PC),A0
	LEA	NEWDIG,A1
	MOVE	#3*256-1,D0
	MOVEQ	#8,D1
	MOVEQ	#4,D2
GENERETABLE
	MOVE.B	D1,(A1)+	;POKE NUMERO DE REGISTRE
	ADDQ	#1,D1
	CMP	#11,D1
	BLO.S	1$
	MOVEQ	#8,D1
1$
	MOVE.B	(A0),D3
	LSR	D2,D3
	AND	#$F,D3
	MOVE.B	D3,(A1)+
	EOR	#4,D2
	BEQ.S	2$
	ADDQ	#1,A0
2$
	DBRA	D0,GENERETABLE
	IFEQ	TEST
	CMP.L	#ENDNEWDIG,A1
	BEQ.S	3$
	ILLEGAL
3$
	ENDC
	ENDC

	IFEQ	PRG
	MOVE	SR,D0
	AND	#$2000,D0
	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
SUPER:
	MOVE	#$2700,SR
	LEA	PILE,SP
	ENDC

	IFNE	PRG
;
; EFFACEMENT DE TOUTE LA MEMOIRE
;
	LEA	STARTCLR,A0
	MOVEQ	#0,D0
	opt	t-
	MOVE	#(TRAVAIL-STARTCLR+7)/8-1,D1
	opt	t+
CLMEM	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	DBRA	D1,CLMEM
	ENDC
;
; DEBUGGAGE DU PROGRAMME POUR QU'IL MARCHE SUR LES ANCIENS SHIFTERS
;
	CMP.L	#$FC0000,4.W
	BLO.S	NEWSHIFTER
	MOVE.L	#$4E711081,D0	;NOP MOVE.B D1,(A0)
	MOVE.L	D0,SHIFTER1
	MOVE.L	D0,SHIFTER2
	MOVE.L	D0,SHIFTER3
	MOVE.L	D0,SHIFTER4
	MOVE.L	D0,SHIFTER5
NEWSHIFTER
;
; 1) PRECALCUL DES SPRITES VERTICAUX
;
	LEA	MESSAGE(PC),A0
	LEA	BANDES,A1
	MOVEQ	#NBCOL-1,D7
	MOVEQ	#0,D5
VERTIC:
	REPT	8
	MOVE.L	D5,(A1)+
	ENDR
	MOVEQ	#NBLIG-1,D6
CAL1:
	MOVEQ	#16-1,D1
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	BNE.S	PASPC1
CLEAR:	MOVE.L	D5,(A1)+
	DBRA	D1,CLEAR
	BRA.S	FINM1
PASPC1:
	ASL	#6,D0		;*64
	LEA	FONTE-64(PC),A2
	ADD	D0,A2
COPY:
	MOVE.L	(A2)+,(A1)+
	DBRA	D1,COPY
FINM1:
	REPT	4
	MOVE.L	D5,(A1)+
	ENDR
	LEA	NBCOL(A0),A0
	DBRA	D6,CAL1
	REPT	8-4
	MOVE.L	D5,(A1)+
	ENDR
	LEA	-NBCOL*NBLIG+1(A0),A0
	DBRA	D7,VERTIC

	IFEQ	TEST
	CMP.L	#FINBANDES,A1
	BEQ.S	1$
	ILLEGAL
1$
	ENDC
;
; calcul des longs les plus fr‚quents <>0 !!!
;
	IFEQ	TRILOC

	MOVE.L	A1,A6
	LEA	BANDES,A5
	LEA	TRIONS,A3
	MOVE.L	A3,A4
GETTRI
	CMP.L	A6,A5
	BHS.S	TRI2
	MOVE.L	(A5)+,D0
	BEQ.S	GETTRI
	BSR	INSERT
	BRA.S	GETTRI
TRI2:
	BSR	GETMAX
	MOVE.L	D0,MAX1
	BSR	GETMAX
	MOVE.L	D0,MAX2
	BSR	GETMAX
	MOVE.L	D0,MAX3
;	BSR	GETMAX
;	MOVE.L	D0,MAX4
	BSR	GETMAX
	MOVE.L	D0,MAX5

	ENDC
;
; 2) CALCUL DES DEPLACEMENTS EN Y
;
	LEA	DEBPTR(PC),A6
	LEA	YDEP,A5
CALY1
	MOVE.L	A6,A0
	MOVEQ	#NBCOL-1,D7
	MOVEQ	#0,D6		;OFFSET EN X
CALY2
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	MULU	#$E6,D0
	ADD	D6,D0
	ADDQ	#8,D6
	MOVE	D0,(A5)+

	ADDQ	#8,A0
	CMP.L	#FINPTR,A0
	BLO.S	CALY3
	LEA	DEBPTR-FINPTR(A0),A0
CALY3
	DBRA	D7,CALY2
	ADDQ	#4,A6
	CMP.L	#FINPTR,A6
	BLO.S	CALY1
	IFEQ	TEST
	CMP.L	#FINYDEP,A5
	BEQ.S	1$
	ILLEGAL
1$
	ENDC
;
; 3) DECALAGE DU LOGO
;
	LEA	LOGO(PC),A0
	LEA	PRELOGO,A1
	MOVE	#(FINLOGO-LOGO)/4-1,D0
COPLOG	MOVE.L	(A0)+,(A1)+
	DBRA	D0,COPLOG

	MOVEQ	#15-1,D7
	LEA	PRELOGO,A6
DECLOG
	LEA	FINLOGO-LOGO(A6),A0
	MOVE	#(FINLOGO-LOGO)/4-1,D0
CLO1	MOVE.L	(A6)+,(A0)+
	DBRA	D0,CLO1
	MOVE.L	A6,A0
	LSR	(A0)
	MOVE	#(FINLOGO-LOGO)/4-2,D0
CLO2
	ADDQ	#4,A0
	ROXR	(A0)
	DBRA	D0,CLO2

	LEA	2(A6),A0
	LSR	(A0)
	MOVE	#(FINLOGO-LOGO)/4-2,D0
CLO3
	ADDQ	#4,A0
	ROXR	(A0)
	DBRA	D0,CLO3
	DBRA	D7,DECLOG
	IFEQ	TEST
	LEA	FINLOGO-LOGO(A6),A0
	CMP.L	#FINPRELOGO,A0
	BEQ.S	1$
	ILLEGAL
1$
	ENDC
;
; 4) PRECALCUL DES POSITIONS POUR LE SPRITE
;
	LEA	COURBE(PC),A6
	LEA	COURS,A0
CALCOUR
	IFEQ	CMPCOURBE
	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0	;X COMPACTE
	BNE.S	.XOK
	MOVE	#$100,D0
	MOVE.B	(A6)+,D0
.XOK
	MOVEQ	#0,D1
	MOVE.B	(A6)+,D1	;Y COMPACTE
	BNE.S	.YOK
	MOVE	#$100,D1
	MOVE.B	(A6)+,D1
.YOK
	ELSEIF
	MOVE	(A6)+,D0	;X NORMAL
	MOVE	(A6)+,D1	;Y NORMAL
	ENDC

	MULU	#$E6,D1
	MOVEQ	#-$10,D2	;FFF0
	AND	D0,D2
	EOR	D2,D0
	LSR	#1,D2
	ADD	D2,D1
;	ADDQ	#4,D1		;RAJOUT POUR SAUTER LES PLANS
;	SUBQ	#8,D1		;POUR EVITER SORTIE A DROITE (CA PUE!)
	SUBQ	#4,D1		;CORRECTION
	MOVE	D1,(A0)+
	MULU	#FINLOGO-LOGO,D0
	ADD.L	#PRELOGO,D0
	MOVE.L	D0,(A0)+

	IFEQ	CMPCOURBE
	CMP.L	#FINCOURS,A0
	BLO.S	CALCOUR
	ELSEIF
	CMP.L	#FINCOURBE,A6
	BLO.S	CALCOUR
	IFEQ	TEST
	CMP.L	#FINCOURS,A0
	BEQ.S	0$
	ILLEGAL
0$
	ENDC
	ENDC
;
; 5) DECALAGE DU SPRITE MCODER
;
	LEA	MCODER(PC),A0
	LEA	PREMCODER,A1
	BSR	PRESHIFT
	IFEQ	TEST
	CMP.L	#FINMCODER,A0
	BEQ.S	1$
	ILLEGAL
1$
	ENDC
	LEA	FIFIRE(PC),A0
	LEA	PREMFIF,A1
	BSR	PRESHIFT
	IFEQ	TEST
	CMP.L	#FINFIF,A0
	BEQ.S	2$
	ILLEGAL
2$
	ENDC
	LEA	GLOOSH(PC),A0
	LEA	PREMGLOO,A1
	BSR	PRESHIFT
	IFEQ	TEST
	CMP.L	#FINGLOO,A0
	BEQ.S	3$
	ILLEGAL
3$
	ENDC
;
; 6) PRECALCUL DES POSITIONS POUR LE SPRITE MCODER
;
	LEA	COURMCODER(PC),A6
	LEA	COURBE2,A0
CALCOUR2
	IFEQ	CMPCOURBE
	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0	;X COMPACTE
	BNE.S	.XOK
	MOVE	#$100,D0
	MOVE.B	(A6)+,D0
.XOK
	MOVEQ	#0,D1
	MOVE.B	(A6)+,D1	;Y COMPACTE
	BNE.S	.YOK
	MOVE	#$100,D1
	MOVE.B	(A6)+,D1
.YOK
	ELSEIF
	MOVE	(A6)+,D0	;X NORMAL
	MOVE	(A6)+,D1	;Y NORMAL
	ENDC
	MULU	#$E6,D1
	MOVEQ	#-$10,D2	;FFF0
	AND	D0,D2
	EOR	D2,D0
	LSR	#1,D2
	ADD	D2,D1
	ADDQ	#4,D1		;RAJOUT POUR SAUTER LES PLANS
	MOVE	D1,(A0)+
	MULU	#3*7*4,D0
	MOVE	D0,(A0)+
	IFEQ	CMPCOURBE
	CMP.L	#FINCOURBE2,A0
	BLO.S	CALCOUR2
	ELSEIF
	CMP.L	#FINCOURMCODER,A6
	BLO.S	CALCOUR2
	IFEQ	TEST
	CMP.L	#FINCOURBE2,A0
	BEQ.S	2$
	ILLEGAL
2$
	ENDC
	ENDC
;
; CALCULE LE DEGRADE
;
	BSR	CALCDEG

	BSR	GENERESTAR

	BSR	GENERECODE		;GENERE LE CODE DU PRG
	IFEQ	TEST
	CMP.L	#ECRAN0,A6
	BLO.S	1$
	ILLEGAL
1$
	ENDC
;
; EFFACEMENT DES ECRANS
;
	LEA	ECRAN0,A0
	MOVEQ	#0,D0
	MOVE	#($80000-ECRAN0)/4-1,D1
FILL:
	MOVE.L	D0,(A0)+
	DBRA	D1,FILL
;
; 8) INIT VARIABLES
;
	MOVE.L	#DEBPAL,PTRPAL\W
	CLR	COMPTRAM\W

	LEA	DEBSTAR,A0
	MOVE.L	A0,STAR1\W
	MOVE.L	A0,STAR2\W
	MOVE.L	A0,PTRSTAR\W

	CLR	LAST1\W
	CLR	LAST2\W
	CLR	ANC1\W
	CLR	ANC2\W
	CLR	ANC3\W
	CLR	ANC4\W
	CLR	ANC5\W
	CLR	ANC6\W
	MOVE.L	#COURBE2,PTRMCOD\W
	MOVE.L	#COURBE2+(1024/3)*4,PTRFIF\W
	MOVE.L	#COURBE2+(1024/3)*2*4,PTRGLOO\W

	MOVE.L	#COURS,PTRSP\W
	MOVE.L	#YDEP,PTR\W
	MOVE.L	#ECRAN1,ECRAN\W

	MOVE	#$80,$FFFF8606.W
MOTOR:	MOVE	$FFFF8604.W,D0
	TST.B	D0
	BMI.S	MOTOR

	MOVE.B	#$06,$FFFF8201.W
	MOVE.B	#$00,$FFFF8203.W

	MOVEM.L	PALETTE(PC),D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

	MOVEQ	#$D,D0
L4000A:	MOVE.B	D0,$FFFF8800.W
	CLR.B	$FFFF8802.W
	DBRA	D0,L4000A
	MOVE.L	#$0707FFFF,$FFFF8800.W
	MOVE.L	#$0E0E0707,$FFFF8800.W
;
; INITIALISATION DES CONSTANTES :
;
; A0,A1,A7,D0,D1
;
SYNCHRO	MACRO
	TST.B	$FFFFFC00.W	;22 CYCLES !!!!
	TST.B	$FFFFFC00.W	;22 CYCLES !!!!
\@0	TST.B	(A0)
	BEQ.S	\@0
\@1	MOVEQ	#50,D2
\@2	TST.B	(A0)
	DBNE	D2,\@2
	BNE.S	\@1
	ENDM

	LEA	$FFFF8209.W,A0
	IFEQ	1
	SYNCHRO
	CLR.B	$FFFF820A.W	;PASSE EN 60 HZ POUR UNE TRAME
	MOVE	#1000,D2
WAI0	DBRA	D2,WAI0
	ENDC
	SYNCHRO
	MOVE.B	#2,$FFFF820A.W	;REPASSE EN 50 HZ
	MOVE	#1000,D2
WAI1	DBRA	D2,WAI1
	SYNCHRO
	MOVEQ	#0,D0
WAIT3:	MOVE.B	(A0),D0
	BEQ.S	WAIT3
	NOT	D0
	LSR	D0,D0
;
;	D0    nb cycles
;	 8	120
;	16	104
;	24	 88
;	32	 72
;	40	 56
;	48	 40
;	56	 24
;
	LEA	$FFFF8260.W,A0	;8
	LEA	$FFFF820A.W,A1	;8
	LEA	NEWDIG,A7	;12
	MOVEQ	#0,D4		;4 POIDS FORT=0
	MOVEQ	#0,D0		;4
	MOVEQ	#2,D1		;4
	LEA	DIGISND,A6	;12
	LEA	DEGRADE,A4	;12

	WAIT	63,D2
	JMP	CODE		;12
;
; SOUS-PROGRAMMES
;
INSERT
	CMP.L	A4,A3
	BEQ.S	INSERE

	MOVE.L	A3,A0
TRI1:	CMP.L	(A0)+,D0
	BEQ.S	SAMETRI
	ADDQ	#6-4,A0
	CMP.L	A4,A0
	BLO.S	TRI1
INSERE:
	MOVE.L	D0,(A4)+
	CLR	(A4)+
	RTS
SAMETRI:
	ADDQ	#1,(A0)
	RTS
GETMAX:
	MOVEQ	#0,D7		;MAXIMUM OBTENU
	LEA	4(A3),A0
	CMP.L	A4,A0
	BHS.S	FINMAX
GETMAX1:
	CMP	(A0),D7
	BHS.S	PIRE
	MOVE	(A0),D7		;NOUVEAU RECORD
	MOVE.L	A0,A1
PIRE:
	ADDQ	#6,A0
	CMP.L	A4,A0
	BLO.S	GETMAX1
FINMAX:
	MOVE.L	D7,D0
	BEQ.S	PAMEIL
	CLR	(A1)		;CLeare compteur
	MOVE.L	-(A1),D0	;VALEUR LA MEILLEURE OBTENUE
PAMEIL:
	RTS

timing	equr	d6
colonne	equr	d5
nblig	equr	d4
lines	equr	d3
space	equr	d2
; d7=compteur de cycles
;
;
; g‚n‚ration automatique de code assembleur
;
GENERECODE:
	MOVEQ	#TIMING1,timing
	MOVEQ	#3,d7
	clr	lines

	LEA	CODE,A6
	BSR.S	GENEREFOND	;GENERE LE CODE DU FOND
	BSR	EFFACESTAR
	BSR	GENEREEFFACE	;GENERE EFFACEMENT DES SPRITES ET DU LOGO
	BSR	AFFICHESTAR
	BSR	GENERELOGO	;GENERE AFFICHAGE DU LOGO
	BSR	GENERESPRITE	;GENERE AFFICHAGE DU SPRITE

	IFEQ	TEST
	lea	libre(pc),a0
	lea	finlibre(pc),a1
	bsr	genere
	ENDC

	IFEQ	TEST
	cmp	#L312,lines
	bhs.s	ok312
	ENDC
1$
	lea	itsnop(pc),a0
	lea	finnop(pc),a1
	bsr	genere
	cmp	#L312,lines
	blo.s	1$
ok312:
	IFEQ	TEST
	cmp	#L312,lines
	beq.s	ok311
	illegal
ok311:
	ENDC

	CMP	#TIMEX,D7
	IFEQ	TEST
	BLS.S	1$
	ILLEGAL
1$
	ENDC
	BEQ.S	OKD7
PAOKD7
	lea	itsnop(pc),a0
	lea	finnop(pc),a1
	bsr	genere
	CMP	#TIMEX,D7
	BNE.S	PAOKD7
OKD7
	lea	lstlin(pc),a2
	lea	finlst(pc),a3
	bra	copie		;g‚nŠre derniŠre ligne

itsnop
	DC.B	1,1
	NOP
finnop

GENEREFOND:
	IFEQ	TRILOC
	lea	initfond(pc),a0
	lea	finfond(pc),a1
	bsr	genere			;g‚nŠre en-tete
	ELSEIF
	lea	initfond2(pc),a0
	lea	finfond(pc),a1
	bsr	genere			;g‚nŠre en-tete
	ENDC

	LEA	BANDES,A5

	clr	colonne
genfond:
	IFNE	TRILOC
;
; TRI LIGNE PAR LIGNE
;
	MOVEM.L	D0-D7/A0-A6,-(SP)

	LEA	ECRAN1,A3
	MOVE.L	A3,A4
	LEA	NBLIG2*4(A5),A6
GETTRI
	CMP.L	A6,A5
	BHS.S	TRI2
	MOVE.L	(A5)+,D0
	BEQ.S	GETTRI
	BSR	INSERT
	BRA.S	GETTRI
TRI2:
	BSR	GETMAX
	MOVE.L	D0,MAX1
	BSR	GETMAX
	MOVE.L	D0,MAX2
	BSR	GETMAX
	MOVE.L	D0,MAX3
;	BSR	GETMAX
;	MOVE.L	D0,MAX4
	BSR	GETMAX
	MOVE.L	D0,MAX5

	MOVEM.L	(SP)+,D0-D7/A0-A6

	lea	initfond(pc),a0
	lea	initfond2(pc),a1
	bsr	genere			;g‚nŠre en-tete

	ENDC
	cmp	#5,colonne
	bne.s	pacol5
	lea	setscr(pc),a0
	lea	finscr(pc),a1
	bsr	genere
pacol5:
	lea	entete1(pc),a0
	tst	colonne
	bne.s	pacol0
	lea	entete2(pc),a0
pacol0:
	lea	finentet(pc),a1
	bsr	genere

	bsr.S	generecol
	addq	#1,colonne
	cmp	#NBCOL,colonne
	blo	genfond
	lea	queue1(pc),a0
	lea	finqueue1(pc),a1
	bsr	genere
	rts

;off1	dc.w	0		;A4=seul registre dispo ???
NBLIG2	EQU	20*10+12		;208 ????
NBEFF	EQU	7
generecol:
	clr	space
	clr	nblig
	clr	off1\w
gen1:
	cmp	#123*$E6,off1\w
	bne.s	painc
	sub	#123*$E6,off1\w
	lea	incscr(pc),a0
	lea	finincscr(pc),a1
	bsr	genere
painc:
	move.l	(a5)+,d0
	beq	zero
	cmp.l	MAX1,d0
	bne.s	gen2
	lea	move1(pc),a0
	lea	finmove1(pc),a1
	move	off1\w,AUTO1+2
	bne.s	paop1
	lea	opt1(pc),a0
	lea	finopt1(pc),a1
paop1
	bsr	genere
	moveq	#NBEFF,space
nxtlig:
	add	#$E6,off1\w
	addq	#1,nblig
	cmp	#NBLIG2,nblig
	blo.s	gen1
	rts
gen2:
	cmp.l	MAX2,d0
	bne.s	gen3
	lea	move2(pc),a0
	lea	finmove2(pc),a1
	move	off1\w,AUTO2+2
	bne.s	paop2
	lea	opt2(pc),a0
	lea	finopt2(pc),a1
paop2
	bsr	genere
	moveq	#NBEFF,space
	bra.s	nxtlig
gen3:
	cmp.l	MAX3,d0
	bne.s	gen4
	lea	move12(pc),a0
	lea	finmove12(pc),a1
	move	off1\w,AUTO5+2
	bne.s	paop12
	lea	opt12(pc),a0
	lea	finopt12(pc),a1
paop12
	bsr	genere
	moveq	#NBEFF,space
	bra.s	nxtlig
gen4:
	IFEQ	1
	cmp.l	MAX4,d0
	bne.s	gen5
	lea	move13(pc),a0
	lea	finmove13(pc),a1
	move	off1\w,AUTO6+2
	bne.s	paop13
	lea	opt13(pc),a0
	lea	finopt13(pc),a1
paop13
	bsr	genere
	moveq	#NBEFF,space
	bra	nxtlig
gen5:
	ENDC
	cmp.l	MAX5,d0
	bne.s	gen6
	lea	move14(pc),a0
	lea	finmove14(pc),a1
	move	off1\w,AUTO8+2
	bne.s	paop14
	lea	opt14(pc),a0
	lea	finopt14(pc),a1
paop14
	bsr	genere
	moveq	#NBEFF,space
	bra	nxtlig
gen6
	move.l	d0,AUTO3+2
	MOVE.L	D0,AUTO7+2
	lea	move3(pc),a0
	lea	finmove3(pc),a1
	move	off1\w,AUTO3+6
	bne.s	paop3
	lea	opt3(pc),a0
	lea	finopt3(pc),a1
paop3
	bsr	genere
	moveq	#NBEFF,space
	bra	nxtlig
zero:
	tst	space
	beq.s	zero1
	lea	move4(pc),a0
	lea	finmove4(pc),a1
	move	off1\w,AUTO4+2
	bne.s	paop4
	lea	opt4(pc),a0
	lea	finopt4(pc),a1
paop4:
	bsr	genere
	subq	#1,space
	bra	nxtlig
zero1:
	MOVE.L	A5,A0
	move	#NBLIG2-1,d0
	sub	nblig,d0
	moveq	#0,d1
zero2:	addq	#1,d1
	tst.l	(a0)+
	dbne	d0,zero2
	beq	nxtlig		;si derniŠres lignes -> rien !!!

	cmp	#NBEFF,d1
	bhi	nxtlig
	lea	move4(pc),a0
	lea	finmove4(pc),a1
	MOVE	off1\w,AUTO4+2
	bne.s	paop5
	lea	opt4(pc),a0
	lea	finopt4(pc),a1
paop5
	bsr	genere
	bra	nxtlig

	OPT	O-
initfond
	DC.B	3,3
MAX1	EQU	*+2
	MOVE.L	#0,D2		;12
	DC.B	3,3
MAX2	EQU	*+2
	MOVE.L	#0,D3		;12
	DC.B	3,3
MAX3	EQU	*+2
	MOVE.L	#0,A3		;12
;	DC.B	3,3
;MAX4	EQU	*+2
;	MOVE.L	#0,A4		;12
	DC.B	3,3
MAX5	EQU	*+2
	MOVE.L	#0,D5		;12
	OPT	O+
initfond2
	DC.B	4,2
	MOVE.L	PTR\W,A2	;16
	DC.B	4,2
	MOVE.L	ECRAN\W,A5	;16 ADRESSE ECRAN...
	DC.B	1,1
	MOVE.L	A5,USP		;4  DANS USP+OPTIMISATION AVEC A5...
finfond
;
; USP CONTIENT MAINTENANT L'ADRESSE ECRAN JUSQU'A LA FIN
;
setscr:
	DC.B	5,3
	MOVE.B	ECRAN+1\W,$FFFF8201.W	;20
	DC.B	5,3
	MOVE.B	ECRAN+2\W,$FFFF8203.W	;20
finscr:

entete1:
	DC.B	1,1
	MOVE.L	USP,A5		;4
entete2:
	DC.B	2,1
	MOVE	(A2)+,D4	;8
	DC.B	2,1
	ADD.L	D4,A5		;8
finentet:

move1:
	dc.b	4,2		;nb cycles/4,nb octets/2
AUTO1	move.l	d2,8(a5)	;16
finmove1:
opt1	DC.B	3,1
	move.l	d2,(a5)		;12
finopt1

move2:
	dc.b	4,2
AUTO2	move.l	d3,8(a5)	;16
finmove2:
opt2	DC.B	3,1
	MOVE.L	D3,(A5)		;12
finopt2

move12:
	dc.b	4,2
AUTO5	move.l	A3,8(a5)	;16
finmove12:
opt12	DC.B	3,1
	move.l	A3,(a5)		;12
finopt12

;move13:
;	dc.b	4,2
;AUTO6	move.l	A4,8(a5)	;16
;finmove13:
;opt13	DC.B	3,1
;	MOVE.L	A4,(A5)		;12
;finopt13

move14	dc.b	4,2
AUTO8	move.l	D5,8(a5)	;16
finmove14
opt14	DC.B	3,1
	MOVE.L	D5,(A5)		;12
finopt14

move3:
	dc.b	6,4
AUTO3	move.l	#0,8(a5)	;24
finmove3:
opt3	DC.B	5,3
AUTO7	MOVE.L	#0,(A5)		;20
finopt3

move4:
	dc.b	4,2
AUTO4	move.l	D0,8(a5)	;16
finmove4:
opt4	DC.B	3,1
	MOVE.L	D0,(A5)		;12
finopt4

incscr
	DC.B	2,2
	LEA	123*$E6(A5),A5	;8 CYCLES
finincscr

queue1:
	DC.B	36/4,(CX1-*-2)/2
	CMP.L	#FINYDEP,A2
	BHS.S	CX2
	BRA.S	CX1
CX2	LEA	YDEP,A2
CX1
	DC.B	4,2
	MOVE.L	A2,PTR\W	;16
finqueue1:

GENEREEFFACE:
;
; EFFACEMENT DU LOGO PRECEDENT
;
	lea	glogo1(pc),a0
	lea	glogo2(pc),a1
	bsr	genere		;entete effact logo

	LEA	PRELOGO,A5
	clr	nblig
geneff0:
	clr	colonne
geneff1:
	MOVE.L	(A5),D0
X	SET	1
	REPT	15
	OR.L	X*9*38*4(A5),D0
X	SET	X+1
	ENDR
	BEQ.S	VIDE1
	lea	glogo3(pc),a0
	lea	glogo4(pc),a1
	move	nblig,d0
	mulu	#$E6,d0
	add	colonne,d0
	move	d0,AUTO10+2
	bne.s	geneff2
	lea	glogo4(pc),a0
	lea	glogo5(pc),a1
geneff2:
	bsr	genere
VIDE1:
	ADDQ	#4,A5
	addq	#8,colonne
	cmp	#9*8,colonne
	blo.s	geneff1
	addq	#1,nblig
	cmp	#38,nblig
	blo.S	geneff0
;
; EFFACEMENT DU SPRITE MCODER PRECEDENT
;
	lea	gspr1(pc),a0
	lea	gspr2(pc),a1
	bsr	genere		;entete effact logo

	LEA	PREMCODER,A5
	BSR.S	GENEFF

	lea	gspr6(pc),a0
	lea	gspr7(pc),a1
	bsr	genere		;entete effact logo

	LEA	PREMFIF,A5
	BSR.S	GENEFF

	lea	gspr7(pc),a0
	lea	gspr8(pc),a1
	bsr	genere		;entete effact logo

	LEA	PREMGLOO,A5
;	BRA.S	GENEFF

GENEFF:
	clr	nblig
geneff4:
	clr	colonne
geneff5:
	MOVE.L	(A5),D0
X	SET	1
	REPT	15
	OR.L	X*3*4*7(A5),D0
X	SET	X+1
	ENDR
	BEQ.S	VIDE2
	lea	gspr3(pc),a0
	lea	gspr4(pc),a1
	move	nblig,d0
	mulu	#$E6,d0
	add	colonne,d0
	move	d0,AUTO11+2
	bne.s	geneff6
	lea	gspr4(pc),a0
	lea	gspr5(pc),a1
geneff6:
	bsr	genere
VIDE2:
	ADDQ	#4,A5
	addq	#8,colonne
	cmp	#3*8,colonne
	blo.s	geneff5
	addq	#1,nblig
	cmp	#7,nblig
	blo.S	geneff4
	RTS

EFFACESTAR:
	LEA	effc1(pc),a0
	lea	effc2(pc),a1
	bsr	genere
;
; poids fort D4=0 !!!
;
	MOVEQ	#nbstarsout-1,nblig
effx1:
	lea	effc2(pc),a0
	lea	effc3(pc),a1
	bsr	genere

	dbra	nblig,effx1
	rts

effc1:
	DC.B	1,1
	MOVE.L	USP,A5		;4 ADRESSE ECRAN
	DC.B	4,2
	MOVE.L	STAR1\W,A2	;16
effc2:
	DC.B	2,1
	MOVE	(A2)+,D4	;8 OFFSET ECRAN
	DC.B	5,2
	MOVE.L	D0,(A5,D4.L)	;20
effc3:

glogo1:
	DC.B	1,1
	MOVE.L	USP,A5		;4
	DC.B	3,2
	MOVE	LAST1\W,D4	;12
	DC.B	2,1
	ADD.L	D4,A5		;8
glogo2:

glogo3:
	DC.B	4,2
AUTO10	MOVE.L	D0,8(A5)	;16
glogo4:
	DC.B	3,1
	MOVE.L	D0,(A5)		;12
glogo5:
gspr1
	DC.B	1,1
	MOVE.L	USP,A5		;4
	DC.B	3,2
	MOVE	ANC1\W,D4	;12
	DC.B	2,1
	ADD.L	D4,A5		;8
gspr2
gspr3
	DC.B	4,2
AUTO11	move.l	D0,8(A5)	;16
gspr4
	DC.B	3,1
	move.l	D0,(A5)		;12
gspr5


gspr6
	DC.B	1,1
	MOVE.L	USP,A5		;4
	DC.B	3,2
	MOVE	ANC3\W,D4	;12
	DC.B	2,1
	ADD.L	D4,A5		;8
gspr7
	DC.B	1,1
	MOVE.L	USP,A5		;4
	DC.B	3,2
	MOVE	ANC5\W,D4	;12
	DC.B	2,1
	ADD.L	D4,A5		;8
gspr8

GENERELOGO
;
; AFFICHAGE DU LOGO
;
	lea	logog1(pc),a0
	lea	logog2(pc),a1
	bsr	genere

	LEA	PRELOGO,A5
	MOVE.L	A5,A4
	clr	nblig
genaff0:
	clr	colonne
genaff1:
	MOVE.L	(A5),D0
	MOVE.L	A5,A0
	MOVEQ	#15-1,D1
TST1
	LEA	9*38*4(A0),A0
	CMP.L	(A0),D0
	DBNE	D1,TST1

	BNE	NOTREG1

	TST.L	D0
	BEQ	NXTRG1

	cmp.l	#$FFFF0000,D0
	BNE.S	PAD2
	lea	logog6(pc),a0
	lea	logog7(pc),a1
	move	nblig,d0
	mulu	#$E6,d0
	add	colonne,d0
	move	d0,AUT1+2
	bne.s	genaff3
	lea	logog7(pc),a0
	lea	logog8(pc),a1
genaff3
	bsr	genere
	bra	NXTRG1
PAD2
	cmp.l	#$0000FFFF,D0
	BNE.S	PAD3
	lea	logog10(pc),a0
	lea	logog11(pc),a1
	move	nblig,d0
	mulu	#$E6,d0
	add	colonne,d0
	move	d0,AUT2+2
	bne.s	genaff4
	lea	logog11(pc),a0
	lea	logog12(pc),a1
genaff4
	bsr	genere
	bra	NXTRG1
PAD3
	IFEQ	TEST
	cmp.l	#$FFFFFFFF,D0
	BNE.S	PAD5
	ENDC
	lea	logog13(pc),a0
	lea	logog14(pc),a1
	move	nblig,d0
	mulu	#$E6,d0
	add	colonne,d0
	move	d0,AUT3+2
	bne.s	genaff5
	lea	logog14(pc),a0
	lea	logog15(pc),a1
genaff5
	bsr	genere
	bra	NXTRG1
	IFEQ	TEST
PAD5	illegal
	ENDC

NOTREG1
	lea	logog3(pc),a0
	lea	logog4(pc),a1
	move	nblig,d0
	mulu	#$E6,d0
	add	colonne,d0
	move	d0,AUTO12+2
	bne.s	genaff2
	lea	logog4(pc),a0
	lea	logog5(pc),a1
genaff2:
	bsr	genere

X	SET	0
	REPT	16
	MOVE.L	X*9*38*4(A5),X*9*38*4(A4)
X	SET	X+1
	ENDR
	ADDQ	#4,A4

NXTRG1
	ADDQ	#4,A5

	addq	#8,colonne
	cmp	#9*8,colonne
	blo	genaff1
	addq	#1,nblig
	cmp	#38,nblig
	blo	genaff0
	rts

logog1
	DC.B	1,1
	MOVE.L	USP,A5		;4 ADRESSE ECRAN
	DC.B	4,2
	MOVE.L	PTRSP\W,A2	;16
	DC.B	5,3
	MOVE	LAST2\W,LAST1\W	;20
	DC.B	2,1
	MOVE	(A2)+,D4	;8 OFFSET ECRAN
	DC.B	3,2
	MOVE	D4,LAST2\W	;12
	DC.B	2,1
	ADD.L	D4,A5		;8
	DC.B	3,1
	MOVE.L	(A2)+,A3	;12 ADRESSE BITMAP

	DC.B	36/4,(X11-*-2)/2
	CMP.L	#FINCOURS,A2
	BHS.S	X22
	BRA.S	X11
X22:	LEA	COURS,A2
X11
	DC.B	4,2
	MOVE.L	A2,PTRSP\W	;16

	DC.B	1,1
	MOVEQ	#-1,D2
	DC.B	1,1
	CLR	D2
;	DC.B	3,3
;	MOVE.L	#$FFFF0000,D2
	DC.B	1,1
	MOVEQ	#0,D3
	DC.B	1,1
	NOT	D3
;	DC.B	3,3
;	MOVE.L	#$0000FFFF,D3
	DC.B	1,1
	MOVEQ	#-1,D5
logog2

logog3
	DC.B	6,2
AUTO12	MOVE.L	(A3)+,8(A5)	;24
logog4
	DC.B	5,1
	MOVE.L	(A3)+,(A5)	;20
logog5


logog6
	DC.B	4,2
AUT1	MOVE.L	D2,8(A5)	;16
logog7
	DC.B	3,1
	MOVE.L	D2,(A5)		;12
logog8

logog10
	DC.B	4,2
AUT2	MOVE.L	D3,8(A5)	;16
logog11
	DC.B	3,1
	MOVE.L	D3,(A5)		;12
logog12

logog13
	DC.B	4,2
AUT3	MOVE.L	D5,8(A5)	;16
logog14
	DC.B	3,1
	MOVE.L	D5,(A5)		;12
logog15

GENERESPRITE
;
; AFFICHAGE DU SPRITE MCODER
;
	lea	spr1(pc),a0
	lea	spr2(pc),a1
	bsr	genere

	LEA	PREMCODER,A5
	BSR.S	GENSPR

	lea	spr6(pc),a0
	lea	spr7(pc),a1
	bsr	genere

	LEA	PREMFIF,A5
	BSR.S	GENSPR

	lea	spr7(pc),a0
	lea	spr8(pc),a1
	bsr	genere

	LEA	PREMGLOO,A5
;	BRA.S	GENSPR

GENSPR:
	MOVE.L	A5,A4
	clr	nblig
genspr0:
	clr	colonne
genspr1:
	MOVE.L	(A5),D0
X	SET	1
	REPT	15
	OR.L	X*3*4*7(A5),D0
X	SET	X+1
	ENDR
	BEQ	VIDE3

	lea	spr3(pc),a0
	lea	spr4(pc),a1
	move	nblig,d0
	mulu	#$E6,d0
	add	colonne,d0
	move	d0,AUTO13+2
	bne.s	genspr2
	lea	spr4(pc),a0
	lea	spr5(pc),a1
genspr2:
	bsr	genere
X	SET	0
	REPT	16
	MOVE.L	X*3*4*7(A5),X*3*4*7(A4)
X	SET	X+1
	ENDR
	ADDQ	#4,A4
VIDE3:
	ADDQ	#4,A5
	addq	#8,colonne
	cmp	#3*8,colonne
	blo	genspr1
	addq	#1,nblig
	cmp	#7,nblig
	blo	genspr0
	RTS
;
; AFFICHAGE DU SPRITE MCODER
;
spr1
	DC.B	1,1
	MOVE.L	USP,A5		;4 ADRESSE ECRAN
	DC.B	4,2
	MOVE.L	PTRMCOD\W,A2	;16
	DC.B	5,3
	MOVE	ANC2\W,ANC1\W	;20
	DC.B	2,1
	MOVE	(A2)+,D4	;8 OFFSET ECRAN
	DC.B	3,2
	MOVE	D4,ANC2\W	;12
	DC.B	2,1
	ADD.L	D4,A5		;8

	DC.B	3,3
	LEA	PREMCODER,A3
	DC.B	3,1
	ADD	(A2)+,A3

;	DC.B	3,1
;	MOVE.L	(A2)+,A3	;12 ADRESSE BITMAP

	DC.B	36/4,(X110-*-2)/2
	CMP.L	#FINCOURBE2,A2
	BHS.S	X220
	BRA.S	X110
X220:	LEA	COURBE2,A2
X110
	DC.B	4,2
	MOVE.L	A2,PTRMCOD\W	;16
spr2

;
; affichage d'un sprite 7 pixels de haut 2 words de large
;

spr3
	DC.B	3,1
	move.l	(A3)+,d2	;12
	DC.B	6,2
AUTO13	or.l	d2,8(A5)	;24
spr4
	DC.B	3,1
	move.l	(A3)+,d2	;12
	DC.B	5,1
	or.l	d2,(A5)		;20
spr5


spr6
	DC.B	1,1
	MOVE.L	USP,A5		;4 ADRESSE ECRAN
	DC.B	4,2
	MOVE.L	PTRFIF\W,A2	;16
	DC.B	5,3
	MOVE	ANC4\W,ANC3\W	;20
	DC.B	2,1
	MOVE	(A2)+,D4	;8 OFFSET ECRAN
	DC.B	3,2
	MOVE	D4,ANC4\W	;12
	DC.B	2,1
	ADD.L	D4,A5		;8
;	DC.B	3,1
;	MOVE.L	(A2)+,A3	;12 ADRESSE BITMAP

	DC.B	3,3
	LEA	PREMFIF,A3
	DC.B	3,1
	ADD	(A2)+,A3

	DC.B	36/4,(X1100-*-2)/2
	CMP.L	#FINCOURBE2,A2
	BHS.S	X2200
	BRA.S	X1100
X2200:	LEA	COURBE2,A2
X1100
	DC.B	4,2
	MOVE.L	A2,PTRFIF\W	;16
spr7
	DC.B	1,1
	MOVE.L	USP,A5		;4 ADRESSE ECRAN
	DC.B	4,2
	MOVE.L	PTRGLOO\W,A2	;16
	DC.B	5,3
	MOVE	ANC6\W,ANC5\W	;20
	DC.B	2,1
	MOVE	(A2)+,D4	;8 OFFSET ECRAN
	DC.B	3,2
	MOVE	D4,ANC6\W	;12
	DC.B	2,1
	ADD.L	D4,A5		;8
;	DC.B	3,1
;	MOVE.L	(A2)+,A3	;12 ADRESSE BITMAP

	DC.B	3,3
	LEA	PREMGLOO,A3
	DC.B	3,1
	ADD	(A2)+,A3

	DC.B	36/4,(X1101-*-2)/2
	CMP.L	#FINCOURBE2,A2
	BHS.S	X2201
	BRA.S	X1101
X2201:	LEA	COURBE2,A2
X1101
	DC.B	4,2
	MOVE.L	A2,PTRGLOO\W	;16
spr8

AFFICHESTAR:
	lea	affc1(pc),a0
	lea	affc2(pc),a1
	bsr	genere
	moveq	#nbstarsout-1,nblig
affx1:
	lea	affc2(pc),a0
	lea	affc3(pc),a1
	bsr	genere
	dbra	nblig,affx1

	lea	affc3(pc),a0
	lea	affc4(pc),a1
	bra	genere

affc1:
	DC.B	1,1
	MOVE.L	USP,A5		;4 ADRESSE ECRAN
	DC.B	4,2
	MOVE.L	PTRSTAR\W,A2	;16
	DC.B	7,3
	MOVE.L	STAR2\W,STAR1\W	;28
	DC.B	4,2
	MOVE.L	A2,STAR2\W	;16
	DC.B	2,2
	LEA	nbstarsout*2(A2),A3
affc2:
	DC.B	2,1
	MOVE	(A2)+,D4	;OFFSET ECRAN
	DC.B	3,1
	MOVE.L	(A3)+,D2
	DC.B	7,2
	OR.L	D2,(A5,D4.L)	;28
affc3:
	DC.B	36/4,(AX110-*-2)/2
	CMP.L	#FINSTAR,A3
	BHS.S	AX220
	BRA.S	AX110
AX220:	LEA	DEBSTAR,A3
AX110
	DC.B	4,2
	MOVE.L	A3,PTRSTAR\W
affc4:

	IFEQ	TEST
libre
	IFEQ	1
	DC.B	3,2
	MOVE	COMPTRAM\W,D3	;12
	DC.B	1,1
	ADDQ	#1,D3		;4
	DC.B	1,1
	MOVE	D3,D2

	DC.B	12/4,6/2
	SUB	#100,D2		;8
	SUBX	D2,D2		;4

	DC.B	1,1
	AND	D2,D3
	DC.B	3,2
	MOVE	D3,COMPTRAM\W

	DC.B	1,1
	NOT	D2
	DC.B	2,2
	AND	#2,D2		;8

	DC.B	4,2
	MOVE.L	PTRPAL\W,A2	;16

	DC.B	2,1
	ADD	D2,A2		;8

	DC.B	36/4,(1$-*-2)/2
	CMP.L	#FINPAL,A2
	BHS.S	2$
	BRA.S	1$
2$	LEA	DEBPAL,A2
1$
	DC.B	4,2
	MOVE.L	A2,PTRPAL\W	;16

	DC.B	2,1
	MOVE	(A2),D2		;8

	DC.B	3,2
	MOVE	D2,$FFFF8248.W	;12
	DC.B	3,2
	MOVE	D2,$FFFF824A.W
	DC.B	3,2
	MOVE	D2,$FFFF824C.W
	DC.B	3,2
	MOVE	D2,$FFFF824E.W

	DC.B	2,2
	ADD	#$111,D2
	DC.B	3,2
	MOVE	D2,$FFFF8250.W
	DC.B	3,2
	MOVE	D2,$FFFF8252.W
	DC.B	3,2
	MOVE	D2,$FFFF8254.W
	DC.B	3,2
	MOVE	D2,$FFFF8256.W
	DC.B	2,2
	ADD	#$222,D2
	DC.B	3,2
	MOVE	D2,$FFFF8258.W
	DC.B	3,2
	MOVE	D2,$FFFF825A.W
	DC.B	3,2
	MOVE	D2,$FFFF825C.W
	DC.B	3,2
	MOVE	D2,$FFFF825E.W
	ENDC

	dc.b	4,3
	MOVE	#$777,$FFFF8240.W	;16
finlibre
	ENDC

DEBPAL
;	DC.W	$000,$111

;	DC.W	$001,$112
;	DC.W	$010,$121
;	DC.W	$100,$211

;	DC.W	$011,$122
;	DC.W	$101,$212
;	DC.W	$110,$221

;	DC.W	$012,
	DC.W	$123
;	DC.W	$113
;	DC.W	$021,$132
;	DC.W	$102,$213
;	DC.W	$120,$231
;	DC.W	$201,$312
;	DC.W	$210,$321

;	DC.W	$013,$124
;	DC.W	$031,$142
;	DC.W	$103,$214
;	DC.W	$130,$241
;	DC.W	$301,$412
;	DC.W	$310,$421
FINPAL

lstlin
;	WAIT	TIMEX,D2
;	MOVE	#$000,$FFFF8240.W		;16
	CMP.L	#FINDEGRADE,A4		;16
	BHS.S	XXX4			;8
	BRA.S	XXX3			;12
XXX4	LEA	DEGRADE,A4		;12
XXX3
	EOR.L	#ECRAN0^ECRAN1,ECRAN\W	;32
;	EOR.B	#1,ECRAN+1\W		;20
;	DC.B	(4+3+2+3),XX3-*-2
;
; NB CYCLES ICI : 36 CYCLES
;
	CMP.L	#ENDDIGIT-313*2,A6	;16
	BHS.S	XX4			;8
	BRA.S	XX3			;12
XX4:	LEA	DIGISND,A6		;12
XX3
;
; NB CYCLES ICI : 156+356=512
;		
;
	MOVE.B	D0,(A1)
	MOVE.B	D1,(A1)
	MOVE	(A6)+,D7		;8
	MOVE.L	(A7,D7.W),D6		;20
	MOVE	4(A7,D7.W),D7		;16
	NOP
	NOP
	MOVE.B	D1,(A0)			;8
	NOP				;4
	MOVE.B	D0,(A0)			;8
	MOVEP.L	D6,$FFFF8800-$FFFF8260(A0)	;28
	MOVEP	D7,$FFFF8800-$FFFF8260(A0)	;20
SHIFTER1
	MOVE.B	D1,(A0)			;8
	NOP
	MOVE.B	D0,(A0)			;8

	JMP	CODE			;=3 NOP
finlst

genere:
	moveq	#0,d0
	move.b	(a0)+,d0	;nb cycles
	add	d0,d7
	cmp	timing,d7
	bls.s	1$
	bsr.S	inc
1$
	clr	d0
	move.b	(a0)+,d0
	subq	#1,d0
copy:
	move	(a0)+,(a6)+
	dbra	d0,copy
	cmp.l	a1,a0
	blo.s	genere
	rts
;
; MACRO POUR COMPTAGE DES CYCLES !!!
;
inc
	move	timing,d1
	add	d0,d1
	sub	d7,d1
	beq.s	nonop
	subq	#1,d1
GENNOP	MOVE	#$4E71,(A6)+
	DBRA	D1,GENNOP
nonop:
	move	d0,d7

	addq	#1,lines

	cmp	#199,lines
	beq.s	gauchex2
	cmp	#299,lines
	beq.s	gauche2
	CMP	#283,lines
	beq.s	gauche2
	bhi.s	gauche

	cmp	#LINE270,lines
	blo.s	gauche
;	bra	digit
digit
	MOVEQ	#TIMING3,timing
	lea	codedigit(pc),a2
	lea	findigit(pc),a3
	bra.s	copie
gauchex2
	MOVEQ	#TIMING2-2,timing
	lea	codegau4(pc),a2
	lea	fingau4(pc),a3
	bra.s	copie
gauche2
	MOVEQ	#TIMING2,timing
	lea	codegau2(pc),a2
	lea	fingau2(pc),a3
	bra.s	copie
gauche:
	MOVEQ	#TIMING1,timing
	CMP	#199-1,lines
	beq.s	chti3
	cmp	#FIRST+HAUT,lines
	bhi.s	normal
	beq.s	nochti
	CMP	#FIRST,lines
	blo.s	normal
	beq.s	chtim
	subq	#2,timing
nochti	lea	codegau3(pc),a2
	lea	fingau3(pc),a3
	bra.s	copie
chti3:	subq	#6,timing
	BRA.S	nochti
chtim:	subq	#2,timing
normal:
	lea	codegau(pc),a2
	lea	fingau(pc),a3
;	bra.s	copie
copie:
	MOVE	(A2)+,(A6)+
	CMP.L	A3,A2
	BLO.S	copie
	RTS

codedigit
	MOVE	(A6)+,D7			;8
	MOVE.L	(A7,D7.W),D6			;20
	MOVE	4(A7,D7.W),D7			;16
	MOVEP.L	D6,$FFFF8800-$FFFF8260(A0)	;28
	MOVEP	D7,$FFFF8800-$FFFF8260(A0)	;20
findigit

codegau
	MOVE.B	D0,(A1)
	MOVE.B	D1,(A1)
	MOVE	(A6)+,D7		;8
	MOVE.L	(A7,D7.W),D6		;20
	MOVE	4(A7,D7.W),D7		;16
	NOP
	NOP
	MOVE.B	D1,(A0)			;8
	NOP				;4
	MOVE.B	D0,(A0)			;8
	MOVEP.L	D6,$FFFF8800-$FFFF8260(A0)	;28
	MOVEP	D7,$FFFF8800-$FFFF8260(A0)	;20
SHIFTER2
	MOVE.B	D1,(A0)			;8
	NOP
	MOVE.B	D0,(A0)			;8
fingau

codegau3
	MOVE	(A6)+,D7		;8
	MOVE.B	D0,(A1)
	MOVE.B	D1,(A1)
	MOVE.L	(A7,D7.W),D6		;20
	MOVE	4(A7,D7.W),D7		;16
	MOVE	(A4)+,$FFFF8240.W	;16
	MOVE.B	D1,(A0)			;8
	NOP				;4
	MOVE.B	D0,(A0)			;8
	MOVEP.L	D6,$FFFF8800-$FFFF8260(A0)	;28
	MOVEP	D7,$FFFF8800-$FFFF8260(A0)	;20
SHIFTER3
	MOVE.B	D1,(A0)			;8
	NOP
	MOVE.B	D0,(A0)			;8
fingau3

codegau2
	MOVE.B	D0,(A1)
	MOVE.B	D1,(A1)

	MOVE	(A6)+,D7		;8
	MOVE.L	(A7,D7.W),D6		;20
	MOVE	4(A7,D7.W),D7		;16
	MOVE.B	D0,(A1)				;8

	MOVE.B	D1,(A0)
	NOP
	MOVE.B	D0,(A0)
	MOVEP.L	D6,$FFFF8800-$FFFF8260(A0)	;28
	MOVEP	D7,$FFFF8800-$FFFF8260(A0)	;20
SHIFTER4
	MOVE.B	D1,(A0)
	NOP
	MOVE.B	D0,(A0)
	MOVE.B	D1,(A1)				;8
fingau2

codegau4
	MOVE	(A6)+,D7		;8
	MOVE	4(A7,D7.W),D6		;16

	MOVE.B	D0,(A1)
	MOVE.B	D1,(A1)
	MOVE.L	(A7,D7.W),D7		;20
	NOP
	NOP
	MOVE	(A4)+,$FFFF8240.W	;16
	MOVE.B	D0,(A1)				;8

	MOVE.B	D1,(A0)
	NOP
	MOVE.B	D0,(A0)
	MOVEP.L	D7,$FFFF8800-$FFFF8260(A0)	;28
	MOVEP	D6,$FFFF8800-$FFFF8260(A0)	;20
SHIFTER5
	MOVE.B	D1,(A0)
	NOP
	MOVE.B	D0,(A0)
	MOVE.B	D1,(A1)				;8
fingau4
;
; DEPLACEMENT DE DEGRADES DE COULEUR
;
; AMPLITUDE :
;	116 PIXELS DE HAUT !!!
;
; CHANGE=4 -> 180 TRANSITIONS
;
CALCDEG
	LEA	DEGRADE,A0
	LEA	FINDEGRADE,A1
CLEARD	CLR	(A0)+
	CMP.L	A1,A0
	BLO.S	CLEARD

	LEA	DEGRADE,A6
	LEA	SINMOVE(PC),A0
	LEA	FOND1(PC),A5
	LEA	FOND2(PC),A4
BCLDEG
	CLR	D0
	MOVE.B	(A0),D0
	ADD	D0,D0
	MOVE.L	A6,A2
	ADD	D0,A2

	ADDQ	#CHANGE,A0
	CMP.L	#ENDMOVE,A0
	BLO.S	ROUL1
	LEA	SINMOVE-ENDMOVE(A0),A0
ROUL1
	MOVE.L	A5,A1
	MOVEQ	#(FOND2-FOND1)/2-1,D0
ROULON
	MOVE	(A1)+,(A2)+

	CMP.L	A4,A1
	BLO.S	3$
	LEA	FOND1(PC),A1
3$
	DBRA	D0,ROULON

	ADDQ	#2,A5
	CMP.L	A4,A5
	BLO.S	2$
	LEA	FOND1(PC),A5
2$
	LEA	HAUT*2(A6),A6
	CMP.L	#SINMOVE,A0
	BNE.S	BCLDEG

	IFEQ	TEST
	CMP.L	#FINDEGRADE,A6
	BEQ.S	1$
	ILLEGAL
1$
	ENDC
	RTS

pattern:dc.l	$80008000,$40004000,$20002000,$10001000
	dc.l	$08000800,$04000400,$02000200,$01000100
	dc.l	$00800080,$00400040,$00200020,$00100010
	dc.l	$00080008,$00040004,$00020002,$00010001

	IFEQ	TEST
RECORD	equr	A2
	ENDC

GENERESTAR
	IFEQ	TEST
	move	#-1,RECORD
	ENDC
	LEA	pattern(pc),a4	;constante
	lea	DEBSTAR,a6
	move	#cycstar/2-1,d7	;nb tables
moveit:
	lea	nbstarsout*2(a6),a5
	lea	stars(pc),a0	;on d‚place toutes les ‚toiles
				;1 fois vers la gauche
	moveq	#nbstarsin/4-1,d6	;nb ‚toiles
	moveq	#4,d5		;offset vertical ‚cran
	SUB.L	A3,A3
nxtstar:
	move	(a0)+,d0	;d‚placement
	move	(a0),d1		;coordonn‚e X

	addq	#2,d1
	tst	d0
	beq.s	okmov		;0=d‚placement de 2 pixels
	addq	#4-2,d1
	cmp	#1,d0
	bls.s	okmov		;1=d‚placement de 4 pixels
	addq	#8-4,d1
okmov:
	cmp	#cycstar,d1
	blo.s	posit
	sub	#cycstar,d1
posit:
	move	d1,(a0)+	;d1=coordonn‚e X

	MOVEQ	#$F,D2
	AND	d1,d2
	eor	d2,d1
	lsr	#1,d1

	add	d5,d1

	add	d2,d2
	add	d2,d2
	move.l	(a4,d2.w),D2

COLSTAR	MACRO
;	CMP	#2,d0
;	beq.s	\@
;	clr	\1
;	TST	d0
;	beq.s	\@
;	swap	\1
;\@
	ENDM

	MOVE.L	D2,D3
	ROR.L	#1,D2
	BCC.S	POSIT1
	ADD	#$E6,D1
	MOVE	D1,(A6)+	;PIXEL GAUCHE
	COLSTAR	D3
	MOVE.L	D3,(A5)+
	SUB	#$E6-8,D1
	MOVE	D1,(A6)+	;PIXEL HAUT
	MOVE.L	D2,D3
	COLSTAR	D3
	MOVE.L	D3,(A5)+
	ADD	#$E6*2,D1
	MOVE	D1,(A6)+
	MOVE.L	D3,(A5)+	;PIXEL BAS=PIXEL HAUT !!!!
	SUB	#$E6,D1
	MOVE.L	D2,D3
	ROR.L	#1,D2
	OR.L	D2,D3
	COLSTAR	D3
	MOVE	D1,(A6)+
	MOVE.L	D3,(A5)+	;PIXEL MILIEU
	BRA.S	NEXTPI
POSIT1
	MOVE.L	D2,D4
	MOVE	D1,(A6)+	;PIXEL HAUT
	ADD	#$E6*2,D1
	COLSTAR	D4
	MOVE.L	D4,(A5)+
	MOVE	D1,(A6)+
	MOVE.L	D4,(A5)+	;PIXEL BAS
	SUB	#$E6,D1

	OR.L	D2,D3
	ROR.L	#1,D2
	BCC.S	POSIT2
	MOVE	D1,(A6)+	;PIXELS GAUCHE ET MILIEU
	COLSTAR	D3
	MOVE.L	D3,(A5)+
	ADDQ	#8,D1
	MOVE	D1,(A6)+	;PIXEL DROITE
	COLSTAR	D2
	MOVE.L	D2,(A5)+
	BRA.S	NEXTPI
POSIT2
	OR.L	D2,D3
	MOVE	D1,(A6)+
	COLSTAR	D3
	MOVE.L	D3,(A5)+	;PIXELS GAUCHE,MILIEU ET DROITE
;	CLR	(A6)+
;	CLR.L	(A5)+
	ADDQ	#1,A3
NEXTPI:
	add	#$e6*intstar,d5	;incr‚mente offset en Y

	dbra	d6,nxtstar

	IFEQ	TEST
	CMP	RECORD,A3
	BHS.S	NONEWREC
	MOVE	A3,RECORD
NONEWREC:
	ENDC

	MOVE	A3,D0
	IFNE	NOSTAR
	IFLE	NOSTAR-8
	SUBQ	#NOSTAR,D0
	ELSEIF
	SUB	#NOSTAR,D0
	ENDC
	ENDC
	BEQ.S	1$
	SUBQ	#1,D0
2$	CLR	(A6)+
	CLR.L	(A5)+
	DBRA	D0,2$
1$
	lea	nbstarsout*4(a6),a6
	dbra	d7,moveit	;on boucle pour toutes les positions

	IFEQ	TEST
	cmp	#NOSTAR,RECORD
	BEQ.S	8$
	ILLEGAL
8$
	CMP.L	#FINSTAR,A6
	BEQ.S	9$
	illegal
9$
	ENDC
	RTS
;
; ROUTINE DE PREDECALAGE DE SPRITE
;
PRESHIFT
	MOVE.L	A1,A6
	MOVEQ	#7-1,D0
COPMCO
	MOVE	(A0)+,D1
	MOVE	D1,(A1)+
	MOVE	D1,(A1)+
	MOVE	(A0)+,D1
	MOVE	D1,(A1)+
	MOVE	D1,(A1)+
	CLR.L	(A1)+
	DBRA	D0,COPMCO

	MOVEQ	#15-1,D7
DECMCO
	LEA	3*4*7(A6),A0
	MOVEQ	#7*3*4/4-1,D0
COD1	MOVE.L	(A6)+,(A0)+
	DBRA	D0,COD1
	MOVE.L	A6,A0
	MOVEQ	#7*3*4/4-2,D0
	LSR	(A0)
COD2
	ADDQ	#4,A0
	ROXR	(A0)
	DBRA	D0,COD2

	LEA	2(A6),A0
	MOVEQ	#7*3*4/4-2,D0
	LSR	(A0)
COD3
	ADDQ	#4,A0
	ROXR	(A0)
	DBRA	D0,COD3
	DBRA	D7,DECMCO
	IFEQ	TEST
	LEA	3*4*7(A6),A0
	ENDC
	RTS

	SECTION	DATA
	IFEQ	COMPFNT
MESSAGE:IIF INCL INCBIN MESS.CMP
	ELSEIF
MESSAGE:
	DC.B	'       THE STARFIRES      '
	DC.B	' ARE VERY PROUD TO PRESENT'
	DC.B	'THEIR OVERSCAN DEMO CALLED'
	DC.B	'  GENIUS HAS NO BORDER... '
	DC.B	'IT WORKS ON ALL SHIFTERS !'
	DC.B	'  IDEA AND CODE BY MCODER '
;	DC.B	' THERE IS STILL TIME LEFT '
;	DC.B	' NOT ENOUGH FOR A SCROLLER'
;	DC.B	'TRY TO READ THE SPRITES !!'
	DC.B	' NO TIME FOR A SCROLLER...'
	DC.B	'WAIT FOR OUR NEXT DEMO !!!'
;	DC.B	'        WHAT ELSE ?       '
	DC.B	'      SEE YOU SOON..      '
	DC.B	'  TRY TO BEAT DIS TCB !!! '
	IFEQ	PRG
CONVERT
	DC.B	0		;' '
	DC.B	38		;!
	DC.B	0,0,0,0,0,0
	DC.B	41		;(
	DC.B	42		;)
	DC.B	0,0
	DC.B	37		;,
	DC.B	0
	DC.B	37		;.
	DC.B	40		;/
	DC.B	27,28,29,30,31	;01234
	DC.B	32,33,34,35,36	;56789
	DC.B	43		;:
	DC.B	0,0,0,0
	DC.B	39		;?
	DC.B	0
	DC.B	1,2,3,4,5	;ABCDE
	DC.B	6,7,8,9,10	;FGHIJ
	DC.B	11,12,13,14,15	;KLMNO
	DC.B	16,17,18,19,20	;PQRST
	DC.B	21,22,23,24,25	;UVWXY
	DC.B	26		;Z
	ENDC
	EVEN
	ENDC
stars:
	dc.w	2,281,1,60,2,129,1,221,1,324,1,194,0,128,0,125,0,156
	IFGE	nbstarsin-9*4
	dc.w	1,225,0,90,2,176,2,241,1,205,0,356,2,273,2,78,0,43
	ENDC
	IFGE	nbstarsin-9*4*2
	dc.w	0,183,0,57,1,174,2,162,1,174,2,19,2,67,1,400,0,289
	ENDC
	IFGE	nbstarsin-9*4*3
	dc.w	0,393,2,306,1,233,2,69,0,58,1,31,2,311,2,178,0,280
	ENDC
	IFGE	nbstarsin-9*4*4
	dc.w	2,272,1,40,2,418,0,90,0,209,2,1,1,393,2,26,0,34
	ENDC
	IFGE	nbstarsin-9*4*5
	dc.w	2,411,2,166,0,150,2,290,2,25,2,44,0,269,2,328,0,309
	ENDC
	IFGE	nbstarsin-9*4*6
	dc.w	0,351,2,159,0,293,2,388,1,334,2,217,2,17,1,342,1,138
	ENDC
	IFGE	nbstarsin-9*4*7
	dc.w	0,370,1,126,2,106,1,153,2,283,2,55
	ENDC
FOND1
	DC.W	$701,$702,$703,$704
	DC.W	$705,$706,$707,$717
	DC.W	$707,$607,$507,$407
	DC.W	$307,$207,$107,7
	DC.W	$17,$27,$37,$47
	DC.W	$57,$67,$77,$177
	DC.W	$77,$76,$75,$74
	DC.W	$73,$72,$71,$70
	DC.W	$170,$270,$370,$470
	DC.W	$570,$670,$770,$771
	DC.W	$770,$760,$750,$740
	DC.W	$730,$720,$710,$700
;	DC.W	$222,$223,$233,$333
;	DC.W	$334,$344,$444,$445
;	DC.W	$455,$555

	IFEQ	1
	REPT	2
	DC.W	$100,$200,$300,$400,$500,$600,$700
	DC.W	$700,$600,$500,$400,$300,$200,$100
	DC.W	$010,$020,$030,$040,$050,$060,$070
	DC.W	$070,$060,$050,$040,$030,$020,$010
	DC.W	$001,$002,$003,$004,$005,$006,$007
	DC.W	$007,$006,$005,$004,$003,$002,$001
	DC.W	$110,$220,$330,$440,$550,$660,$770
	DC.W	$770,$660,$550,$440,$330,$220,$110
	DC.W	$101,$202,$303,$404,$505,$606,$707
	DC.W	$707,$606,$505,$404,$303,$202,$101
	DC.W	$011,$022,$033,$044,$055,$066,$077
	DC.W	$077,$066,$055,$044,$033,$022,$011
	DC.W	$111,$222,$333,$444,$555,$666,$777
	DC.W	$777,$666,$555,$444,$333,$222,$111
	ENDR
	ENDC
FOND2
PALETTE:
	DC.W	$000,$555,$444,$222
	DC.W	$123,$123,$123,$123
	DC.W	$234,$234,$234,$234
	DC.W	$456,$456,$456,$456
;	DC.W	$000,$666,$555,$333
;	DC.W	$000,$641,$530,$320
;	DC.W	$203,$203,$203,$203
;	DC.W	$133,$133,$133,$133
;	DC.W	$055,$055,$055,$055
;
; LISTE DES DEPLACEMENTS
;
SINMOVE	IIF INCL INCBIN SIN.BIN
ENDMOVE
	EVEN

DEBPTR
	IIF INCL INCBIN SINUS.BIN
FINPTR:

FONTE:
	IFEQ	COMPFNT
	IIF INCL INCBIN FONTE.CMP
	ELSEIF
	IIF INCL INCBIN DEXION.FNT
	ENDC

	IFEQ	PRG
FILE:	DC.B	'TSONG3.SPL',0
	EVEN
	ENDC

	IFNE	NOLOGO
LOGO	IIF INCL INCBIN LOGO.BIN
FINLOGO
	ENDC
MCODER	IIF INCL INCBIN MCODER.BIN
FIFIRE	IIF INCL INCBIN FIFIRE.BIN
	DC.L	0,0
GLOOSH	IIF INCL INCBIN GLOOSH.BIN
	DC.L	0,0

COURBE
	IFEQ	CMPCOURBE
	IIF INCL INCBIN COURBE.CMP	;COURBE COMPACTEE
	ELSEIF
	IIF INCL INCBIN COURBE.BIN	;1024 POSITIONS
FINCOURBE
	ENDC
COURMCODER
	IFEQ	CMPCOURBE
	IIF INCL INCBIN SPRCOUR.CMP	;COURBE COMPACTEE
	ELSEIF
	IIF INCL INCBIN SPRCOUR.BIN	;1024 POSITIONS
FINCOURMCODER
	ENDC
	IFEQ	COMPDIGIT
GENDIG
;80-8F
	DC.B	$ED,$CF,$30
	DC.B	$F3,$0F,$30
	DC.B	$F3,$0F,$30
	DC.B	$F3,$0E,$DB
	DC.B	$ED,$BE,$DB
	DC.B	$ED,$BE,$DB
	DC.B	$ED,$BE,$DB
	DC.B	$ED,$AE,$DA
;90-9F
	DC.B	$ED,$AE,$DA
	DC.B	$EC,$CE,$D0
	DC.B	$DD,$DD,$DD
	DC.B	$DD,$DD,$DD
	DC.B	$DD,$DD,$DD
	DC.B	$EC,$BE,$CB
	DC.B	$EC,$BE,$CB
	DC.B	$EC,$BE,$CB
;A0-AF
	DC.B	$EC,$BE,$CB
	DC.B	$EC,$AE,$CA
	DC.B	$EC,$AE,$CA
	DC.B	$DD,$CD,$DC
	DC.B	$EC,$9E,$C9
	DC.B	$EC,$5E,$C0
	DC.B	$EC,$0E,$BB
	DC.B	$EB,$BE,$BB
;B0-BF
	DC.B	$EB,$BE,$BA
	DC.B	$EB,$AE,$BA
	DC.B	$DD,$BD,$DB
	DC.B	$DD,$BE,$B9
	DC.B	$EB,$9E,$B9
	DC.B	$DC,$CD,$DA
	DC.B	$EB,$7E,$B0
	DC.B	$EB,$0D,$D9
;C0-CF
	DC.B	$DD,$9E,$A9
	DC.B	$DD,$8D,$D7
	DC.B	$DD,$4D,$D0
	DC.B	$EA,$4E,$99
	DC.B	$E9,$9D,$CB
	DC.B	$E9,$8E,$98
	DC.B	$E9,$7E,$88
	DC.B	$E9,$1C,$CC
;D0-DF
	DC.B	$DC,$AE,$86
	DC.B	$E7,$7E,$80
	DC.B	$E7,$5E,$66
	DC.B	$DC,$9E,$55
	DC.B	$E4,$4D,$C8
	DC.B	$DB,$BE,$00
	DC.B	$DC,$6D,$C5
	DC.B	$DC,$2C,$CB
;E0-EF
	DC.B	$CC,$BD,$BA
	DC.B	$DB,$AD,$BA
	DC.B	$DB,$AC,$CA
	DC.B	$CC,$AC,$CA
	DC.B	$DB,$9D,$B9
	DC.B	$DA,$AD,$AA
	DC.B	$DA,$AC,$C9
	DC.B	$CC,$9C,$C9
;F0-FF
	DC.B	$DB,$6C,$BB
	DC.B	$CC,$8D,$B0
	DC.B	$DB,$0C,$C7
	DC.B	$CC,$6C,$C5
	DC.B	$CC,$3C,$C1
	DC.B	$CB,$AD,$A5
	DC.B	$DA,$4D,$A2
	DC.B	$D9,$8D,$98
;0-F
	DC.B	$CB,$9C,$B9
	DC.B	$D8,$8B,$BB
	DC.B	$D9,$5C,$B8
	DC.B	$D9,$2D,$86
	DC.B	$CB,$7D,$77
	DC.B	$CB,$6C,$A9
	DC.B	$BB,$AC,$B2
	DC.B	$CB,$0C,$A8
;10-1F
	DC.B	$D6,$4D,$55
	DC.B	$D5,$4C,$99
	DC.B	$D4,$3B,$B9
	DC.B	$CA,$5B,$AA
	DC.B	$C9,$8B,$B8
	DC.B	$CA,$0C,$A0
	DC.B	$C9,$7B,$B7
	DC.B	$C9,$6B,$B6
;20-2F
	DC.B	$BA,$9B,$B5
	DC.B	$AA,$AB,$B2
	DC.B	$BA,$8C,$77
	DC.B	$C8,$4C,$76
	DC.B	$B9,$9C,$66
	DC.B	$AA,$9C,$73
	DC.B	$BA,$5B,$98
	DC.B	$BA,$3A,$A8
;30-3F
	DC.B	$BA,$0B,$97
	DC.B	$B8,$8A,$A7
	DC.B	$A9,$9C,$11
	DC.B	$AA,$6B,$87
	DC.B	$AA,$5A,$98
	DC.B	$AA,$2A,$A1
	DC.B	$AA,$09,$99
	DC.B	$A8,$8B,$81
;40-4F
	DC.B	$A9,$6B,$74
	DC.B	$A9,$59,$98
	DC.B	$A9,$3A,$86
	DC.B	$A9,$09,$97
	DC.B	$98,$8A,$84
	DC.B	$99,$6A,$81
	DC.B	$99,$59,$87
	DC.B	$88,$89,$92
;50-5F
	DC.B	$98,$69,$90
	DC.B	$97,$78,$87
	DC.B	$97,$69,$82
	DC.B	$88,$69,$66
	DC.B	$87,$78,$84
	DC.B	$87,$68,$82
	DC.B	$77,$78,$66
	DC.B	$87,$47,$76
;60-6F
	DC.B	$86,$58,$64
	DC.B	$76,$67,$74
	DC.B	$85,$46,$66
	DC.B	$76,$47,$55
	DC.B	$66,$56,$64
	DC.B	$65,$56,$62
	DC.B	$65,$45,$55
	DC.B	$65,$25,$54
;70-7F
	DC.B	$54,$45,$52
	DC.B	$44,$44,$43
	DC.B	$44,$24,$33
	DC.B	$33,$33,$32
	DC.B	$32,$22,$22
	DC.B	$22,$11,$11
	DC.B	$21,$01,$10
	DC.B	$10,$00,$00
	EVEN
	ELSEIF
NEWDIG
;80-8F
	DC.W	$80E,$90D,$A0C,$80F,$903,$A00
	DC.W	$80F,$903,$A00,$80F,$903,$A00
	DC.W	$80F,$903,$A00,$80F,$903,$A00
	DC.W	$80F,$903,$A00,$80E,$90D,$A0B
	DC.W	$80E,$90D,$A0B,$80E,$90D,$A0B
	DC.W	$80E,$90D,$A0B,$80E,$90D,$A0B
	DC.W	$80E,$90D,$A0B,$80E,$90D,$A0B
	DC.W	$80E,$90D,$A0A,$80E,$90D,$A0A
;90-9F
	DC.W	$80E,$90D,$A0A,$80E,$90D,$A0A
	DC.W	$80E,$90C,$A0C,$80E,$90D,$A00
	DC.W	$80D,$90D,$A0D,$80D,$90D,$A0D
	DC.W	$80D,$90D,$A0D,$80D,$90D,$A0D
	DC.W	$80D,$90D,$A0D,$80D,$90D,$A0D
	DC.W	$80E,$90C,$A0B,$80E,$90C,$A0B
	DC.W	$80E,$90C,$A0B,$80E,$90C,$A0B
	DC.W	$80E,$90C,$A0B,$80E,$90C,$A0B
;A0-AF
	DC.W	$80E,$90C,$A0B,$80E,$90C,$A0B
	DC.W	$80E,$90C,$A0A,$80E,$90C,$A0A
	DC.W	$80E,$90C,$A0A,$80E,$90C,$A0A
	DC.W	$80D,$90D,$A0C,$80D,$90D,$A0C
	DC.W	$80E,$90C,$A09,$80E,$90C,$A09
	DC.W	$80E,$90C,$A05,$80E,$90C,$A00
	DC.W	$80E,$90C,$A00,$80E,$90B,$A0B
	DC.W	$80E,$90B,$A0B,$80E,$90B,$A0B
;B0-BF
	DC.W	$80E,$90B,$A0B,$80E,$90B,$A0A
	DC.W	$80E,$90B,$A0A,$80E,$90B,$A0A
	DC.W	$80D,$90D,$A0B,$80D,$90D,$A0B
	DC.W	$80D,$90D,$A0B,$80E,$90B,$A09
	DC.W	$80E,$90B,$A09,$80E,$90B,$A09
	DC.W	$80D,$90C,$A0C,$80D,$90D,$A0A
	DC.W	$80E,$90B,$A07,$80E,$90B,$A00
	DC.W	$80E,$90B,$A00,$80D,$90D,$A09
;C0-CF
	DC.W	$80D,$90D,$A09,$80E,$90A,$A09
	DC.W	$80D,$90D,$A08,$80D,$90D,$A07
	DC.W	$80D,$90D,$A04,$80D,$90D,$A00
	DC.W	$80E,$90A,$A04,$80E,$909,$A09
	DC.W	$80E,$909,$A09,$80D,$90C,$A0B
	DC.W	$80E,$909,$A08,$80E,$909,$A08
	DC.W	$80E,$909,$A07,$80E,$908,$A08
	DC.W	$80E,$909,$A01,$80C,$90C,$A0C
;D0-DF
	DC.W	$80D,$90C,$A0A,$80E,$908,$A06
	DC.W	$80E,$907,$A07,$80E,$908,$A00
	DC.W	$80E,$907,$A05,$80E,$906,$A06
	DC.W	$80D,$90C,$A09,$80E,$905,$A05
	DC.W	$80E,$904,$A04,$80D,$90C,$A08
	DC.W	$80D,$90B,$A0B,$80E,$900,$A00
	DC.W	$80D,$90C,$A06,$80D,$90C,$A05
	DC.W	$80D,$90C,$A02,$80C,$90C,$A0B
;E0-EF
	DC.W	$80C,$90C,$A0B,$80D,$90B,$A0A
	DC.W	$80D,$90B,$A0A,$80D,$90B,$A0A
	DC.W	$80D,$90B,$A0A,$80C,$90C,$A0A
	DC.W	$80C,$90C,$A0A,$80C,$90C,$A0A
	DC.W	$80D,$90B,$A09,$80D,$90B,$A09
	DC.W	$80D,$90A,$A0A,$80D,$90A,$A0A
	DC.W	$80D,$90A,$A0A,$80C,$90C,$A09
	DC.W	$80C,$90C,$A09,$80C,$90C,$A09
;F0-FF
	DC.W	$80D,$90B,$A06,$80C,$90B,$A0B
	DC.W	$80C,$90C,$A08,$80D,$90B,$A00
	DC.W	$80D,$90B,$A00,$80C,$90C,$A07
	DC.W	$80C,$90C,$A06,$80C,$90C,$A05
	DC.W	$80C,$90C,$A03,$80C,$90C,$A01
	DC.W	$80C,$90B,$A0A,$80D,$90A,$A05
	DC.W	$80D,$90A,$A04,$80D,$90A,$A02
	DC.W	$80D,$909,$A08,$80D,$909,$A08
;0-F
	DC.W	$80C,$90B,$A09,$80C,$90B,$A09
	DC.W	$80D,$908,$A08,$80B,$90B,$A0B
	DC.W	$80D,$909,$A05,$80C,$90B,$A08
	DC.W	$80D,$909,$A02,$80D,$908,$A06
	DC.W	$80C,$90B,$A07,$80D,$907,$A07
	DC.W	$80C,$90B,$A06,$80C,$90A,$A09
	DC.W	$80B,$90B,$A0A,$80C,$90B,$A02
	DC.W	$80C,$90B,$A00,$80C,$90A,$A08
;10-1F
	DC.W	$80D,$906,$A04,$80D,$905,$A05
	DC.W	$80D,$905,$A04,$80C,$909,$A09
	DC.W	$80D,$904,$A03,$80B,$90B,$A09
	DC.W	$80C,$90A,$A05,$80B,$90A,$A0A
	DC.W	$80C,$909,$A08,$80B,$90B,$A08
	DC.W	$80C,$90A,$A00,$80C,$90A,$A00
	DC.W	$80C,$909,$A07,$80B,$90B,$A07
	DC.W	$80C,$909,$A06,$80B,$90B,$A06
;20-2F
	DC.W	$80B,$90A,$A09,$80B,$90B,$A05
	DC.W	$80A,$90A,$A0A,$80B,$90B,$A02
	DC.W	$80B,$90A,$A08,$80C,$907,$A07
	DC.W	$80C,$908,$A04,$80C,$907,$A06
	DC.W	$80B,$909,$A09,$80C,$906,$A06
	DC.W	$80A,$90A,$A09,$80C,$907,$A03
	DC.W	$80B,$90A,$A05,$80B,$909,$A08
	DC.W	$80B,$90A,$A03,$80A,$90A,$A08
;30-3F
	DC.W	$80B,$90A,$A00,$80B,$909,$A07
	DC.W	$80B,$908,$A08,$80A,$90A,$A07
	DC.W	$80A,$909,$A09,$80C,$901,$A01
	DC.W	$80A,$90A,$A06,$80B,$908,$A07
	DC.W	$80A,$90A,$A05,$80A,$909,$A08
	DC.W	$80A,$90A,$A02,$80A,$90A,$A01
	DC.W	$80A,$90A,$A00,$809,$909,$A09
	DC.W	$80A,$908,$A08,$80B,$908,$A01
;40-4F
	DC.W	$80A,$909,$A06,$80B,$907,$A04
	DC.W	$80A,$909,$A05,$809,$909,$A08
	DC.W	$80A,$909,$A03,$80A,$908,$A06
	DC.W	$80A,$909,$A00,$809,$909,$A07
	DC.W	$809,$908,$A08,$80A,$908,$A04
	DC.W	$809,$909,$A06,$80A,$908,$A01
	DC.W	$809,$909,$A05,$809,$908,$A07
	DC.W	$808,$908,$A08,$809,$909,$A02
;50-5F
	DC.W	$809,$908,$A06,$809,$909,$A00
	DC.W	$809,$907,$A07,$808,$908,$A07
	DC.W	$809,$907,$A06,$809,$908,$A02
	DC.W	$808,$908,$A06,$809,$906,$A06
	DC.W	$808,$907,$A07,$808,$908,$A04
	DC.W	$808,$907,$A06,$808,$908,$A02
	DC.W	$807,$907,$A07,$808,$906,$A06
	DC.W	$808,$907,$A04,$807,$907,$A06
;60-6F
	DC.W	$808,$906,$A05,$808,$906,$A04
	DC.W	$807,$906,$A06,$807,$907,$A04
	DC.W	$808,$905,$A04,$806,$906,$A06
	DC.W	$807,$906,$A04,$807,$905,$A05
	DC.W	$806,$906,$A05,$806,$906,$A04
	DC.W	$806,$905,$A05,$806,$906,$A02
	DC.W	$806,$905,$A04,$805,$905,$A05
	DC.W	$806,$905,$A02,$805,$905,$A04
;70-7F
	DC.W	$805,$904,$A04,$805,$905,$A02
	DC.W	$804,$904,$A04,$804,$904,$A03
	DC.W	$804,$904,$A02,$804,$903,$A03
	DC.W	$803,$903,$A03,$803,$903,$A02
	DC.W	$803,$902,$A02,$802,$902,$A02
	DC.W	$802,$902,$A01,$801,$901,$A01
	DC.W	$802,$901,$A00,$801,$901,$A00
	DC.W	$801,$900,$A00,$800,$900,$A00
	ENDC

	IFEQ	PRG
	SECTION	BSS
	DS.L	20
PILE:
DIGISND	DS.W	48250
ENDDIGIT
	ELSEIF
	SECTION	DATA
DIGISND	IIF INCL INCBIN TSONG3.SPL
	SECTION	BSS
	DS.B	48250*2-LENGTH
ENDDIGIT
	ENDC
	IFEQ	COMPDIGIT
NEWDIG	DS.B	6*256		;TABLE DE DIGIT
ENDNEWDIG
	ENDC

STARTCLR:			;DEBUT MEMOIRE A EFFACER
TRIONS:					;OCTETS LIBRES AU DEBUT !!!
PREMCODER	DS.B	3*4*7*16	;16 MCODERS PREDECALES 3*7
FINMCODER
PREMFIF		DS.B	3*4*7*16
FINFIF
PREMGLOO	DS.B	3*4*7*16
FINGLOO
PRELOGO	DS.B	9*38*4*16		;16 LOGOS PREDECALES 9*38
FINPRELOGO
COURS	DS.B	6*1024			;6 OCTETS PAR POSITION...
FINCOURS
COURBE2	DS.B	4*1024
FINCOURBE2
YDEP	DS.W	NBCOL*256/4
FINYDEP
DEGRADE	DS.W	HAUT*45*2
MIDEGRADE	EQU	DEGRADE+HAUT*45*2	;MOITIE DU DEGRADE
FINDEGRADE
DEBSTAR		DS.B	cycstar/2*nbstarsout*6
FINSTAR
CODE

TRAVAIL		EQU	ECRAN0
BANDES		EQU	ECRAN0
FINBANDES	EQU	NBLIG2*4*NBCOL+BANDES

	OFFSET	$300		;EVITONS UN CONFLIT AVEC VIRUS...
off1			;ok
PTR	DS.L	1	;ok
PTRSP	DS.L	1	;ok
PTRMCOD	DS.L	1	;ok
PTRFIF	DS.L	1	;ok
PTRGLOO	DS.L	1	;ok
PTRSTAR	DS.L	1	;ok
STAR1	DS.L	1	;ok
STAR2	DS.L	1	;ok

ECRAN	DS.L	1	;ok
LAST1	DS.W	1	;ok
LAST2	DS.W	1	;ok
ANC1	DS.W	1	;ok
ANC2	DS.W	1	;ok
ANC3	DS.W	1	;ok
ANC4	DS.W	1	;ok
ANC5	DS.W	1	;ok
ANC6	DS.W	1	;ok

PTRPAL	DS.L	1	;ok
COMPTRAM DS.W	1	;ok
