*
*	DIDACTITIEL POUR M. GILLES DURAND
*	 PAR GUILLAUME AUDUC
*
*	  DEUXIEME PARTIE : LE DIDACTITIEL POUR L'ETUDIANT
*
* 4 	TEMPS	1 H	



	MOVE.W	#$20,-(A7)
	TRAP	#1
	
	BSR	INIT
	BSR	MAIN_MENU
	
EXIT	JSR	RESTORE
	MOVE.B	#8,$fffffc02.W
	DC.W	$A009
	MOVE.L	#0,-(A7)
	TRAP	#1
***************************************************************************
ASCII_MENU

	LEA	CLS,A0
	BSR	PRINT_GDOS
	LEA	ASCII,A0
	BSR	PRINT_GDOS
	LEA	L_FONT,A0
	BSR	PRINT_GDOS
	MOVE.L	ADD_GDOS_FONT,A0
	SUB.W	#$25A-4,A0
	BSR	PRINT_GDOS


ASC1	BSR	INPUT

	CMP.L	#$430000,D0
	BNE.S	ASC_F9
	BSR	CHANGE_FONT
	BRA	ASCII_MENU

ASC_F9	CMP.L	#$440000,D0
	BNE.S	ASC1
	RTS
***************************************************************************
MAIN_MENU

	LEA	CLS,A0
	BSR	PRINT_GDOS
	LEA	ECRAN_MENU,A0
	BSR	PRINT_GDOS
	LEA	L_FONT,A0
	BSR	PRINT_GDOS
	MOVE.L	ADD_GDOS_FONT,A0
	SUB.W	#$25A-4,A0
	BSR	PRINT_GDOS
	LEA	L_NOM,A0
	BSR	PRINT_GDOS
	LEA	NOM_BANQUE,A0
	BSR	PRINT_GDOS


CONT	BSR	INPUT
	CMP.L	#$3B0000,D0
	BNE.S	PAS_F1
	BSR	CHARGE
	BRA	MAIN_MENU
	
PAS_F1	CMP.L	#$3C0000,D0
	BNE.S	PAS_F2
	BSR	EDITE
	BRA	MAIN_MENU

PAS_F2	CMP.L	#$3D0000,D0
	BNE.S	PAS_F3
	BSR	NEW_EDITE
	BRA	MAIN_MENU

PAS_F3	CMP.L	#$3E0000,D0
	BNE.S	PAS_F4
	*BSR	NETTOYE
	BRA	MAIN_MENU

PAS_F4	CMP.L	#$3F0000,D0
	BNE.S	PAS_F5
	NOP
	BRA	CONT

PAS_F5	CMP.L	#$410000,D0
	BNE.S	PAS_F7
	BSR	ASCII_MENU
	BRA	MAIN_MENU

PAS_F7	CMP.L	#$420000,D0
	BNE.S	PAS_F8
	*BSR	NOMME
	BRA	MAIN_MENU

PAS_F8	CMP.L	#$430000,D0
	BNE.S	PAS_F9
	BSR	CHANGE_FONT
	BRA	MAIN_MENU

PAS_F9	CMP.L	#$440000,D0
	BNE.S	PAS_F10
	RTS

PAS_F10	BRA	CONT
***************************************************************************
CHARGE	
	LEA	FILENAME,A2
	MOVE.L	#'    ',(A2)
	MOVE.L	#'    ',4(A2)
	MOVE.L	#'    ',8(A2)

	LEA	L_C_FILENAME,A0
	BSR	PRINT_GDOS
	MOVE.L	A2,A0
	BSR	PRINT_GDOS

	MOVE.L	A2,A5
	LEA	8(A2),A6
	LEA	L_C_FILE,A4
	BSR	INPUT_2

	CMP.L	#'    ',(A5)
	BEQ.S	.ICI

	MOVE.B	#'.',(A2)+
	MOVE.B	#'B',(A2)+
	MOVE.B	#'N',(A2)+
	MOVE.B	#'K',(A2)+
	MOVE.B	#0,(A2)+

	BSR	FOPEN
	LEA	DEBUT_FICHIER,A0
	MOVE.L	#$150000,D0
	BSR	FREAD
	BSR	FCLOSE

.ICI	
	LEA	L_C_FILEN,A0
	BSR	PRINT_GDOS
	RTS


		DC.W	0
FILENAME	DC.B	'12345678.MCS',0,0
		EVEN
***************************************************************************
FOPEN	MOVE.W	#2,-(A7)
	PEA	FILENAME
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.W	#8,A7
	MOVE.W	D0,HANDLE
	RTS
HANDLE	DC.W	0
***************************************************************************
FREAD	MOVE.L	A0,-(A7)
	MOVE.L	D0,-(A7)
	MOVE.W	HANDLE,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADD.W	#12,A7
	RTS
***************************************************************************
FCLOSE	MOVE.W	HANDLE,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.W	#4,A7
	RTS
***************************************************************************
INPUT_2
	BSR	INPUT
	CMP.L	#0,D0
	BEQ.S	INPUT_2

	CMP.B	#$D,D0
	BEQ	SORTIE
	CMP.L	#$440000,D0
	BEQ	SORTIE_2

M_F10	CMP.L	#$0E0008,D0
	BNE.S	M_BACK
	MOVE.B	#' ',-1(A2)
	CMP.L	A2,A5
	BEQ.S	STOP
	SUBQ.W	#1,A2
	BRA	STOP

M_BACK	MOVE.B	D0,(A2)
	CMP.L	A2,A6
	BNE.S	STO
	MOVE.B	#' ',(A2)
	BRA	STOP	

STO	ADDQ.W	#1,A2

STOP	
	MOVE.L	A4,A0
	BSR	PRINT_GDOS
	MOVE.L	A5,A0
	BSR	PRINT_GDOS
	BSR	WAITT
	BSR	WAITT
	BSR	WAITT
	BSR	WAITT
	BSR	WAITT
	BSR	WAITT
	BSR	WAITT
	BSR	WAITT
	BRA	INPUT_2

SORTIE_2
	MOVE.L	#'    ',(A5)
	RTS
****************************************************************************
CHANGE_FONT
	CMP.W	#1,OFFSET
	BEQ.S	FONT_MONO

	ADDQ.L	#4,CURENT_FONT
	MOVE.L	CURENT_FONT,A0
	MOVE.L	(A0),A0
	CMP.L	#-1,A0
	BNE.S	FON1_OK
	MOVE.L	#FONT_COUL_TAB,CURENT_FONT
	MOVE.L	FONT_COUL_TAB,A0
FON1_OK	MOVE.L	A0,ADD_GDOS_FONT
	ADD.L	#$25A,ADD_GDOS_FONT
	RTS

FONT_MONO
	ADDQ.L	#4,CURENT_FONT
	MOVE.L	CURENT_FONT,A0
	MOVE.L	(A0),A0
	CMP.L	#-1,A0
	BNE.S	FONT_OK
	MOVE.L	#FONT_MONO_TAB,CURENT_FONT
	MOVE.L	FONT_MONO_TAB,A0

FONT_OK	MOVE.L	A0,ADD_GDOS_FONT
	ADD.L	#$25A,ADD_GDOS_FONT
	RTS
***************************************************************************
PRINT_REPONSE
	LEA	L_REP,A0
	BSR	PRINT_GDOS
	LEA	REPONSE_E,A0
	BSR	PRINT_GDOS
	RTS

WORD_TAB	DCB.B	40,-1
		DC.L	0
SX		DC.W	0
SY		DC.W	0
SX1		DC.W	0
SY1		DC.W	0
CONTE		DC.W	0
***************************************************************************
INVERT_FOUND_WORD
	MOVE.W	X,SX
	MOVE.W	Y,SY

	LEA	WORD_TAB,A0

ENCORE	MOVE.L	CURENT_GREC,A1
	MOVEQ	#0,D2
	MOVE.W	#0,X
	MOVE.W	#2,Y

	MOVE.B	(A0)+,D0
	CMP.B	#-1,D0
	BEQ	.FINI

	CMP.B	#0,D0
	BEQ.S	.LA

.ICI	MOVE.B	(A1),D1

	CMP.B	#'A',D1
	BLT.S	.MINUS3
	CMP.B	#'Z',D1
	BGT.S	.MINUS3

.DD	ADDQ.W	#1,A1
	ADDQ.W	#1,X
	CMP.W	#80,X
	BNE.S	.FOUT
	MOVE.W	#0,X
	ADDQ.W	#1,Y
.FOUT	BRA.S	.ICI

.MINUS3	CMP.B	#'a',D1
	BLT.S	.TROUVE
	CMP.B	#'z',D1
	BGT.S	.TROUVE
	BRA	.DD

.TROUVE	
	ADDQ.W	#1,A1
	ADDQ.W	#1,X
	CMP.W	#80,X
	BNE.S	.FOUT3
	MOVE.W	#0,X
	ADDQ.W	#1,Y

.FOUT3	ADDQ.W	#1,D2
	CMP.B	D0,D2
	BNE.S	.ICI


.LA	MOVE.B	(A1),D1

	CMP.B	#'A',D1
	BLT.S	.MINUS4
	CMP.B	#'Z',D1
	BGT.S	.MINUS4
	BRA.S	.CHARAC

.MINUS4	CMP.B	#'a',D1
	BLT.S	.OUT
	CMP.B	#'z',D1
	BGT.S	.OUT

.CHARAC	
	MOVEM.L	D0-A6,-(A7)
	BSR	INVERT_CURSOR
	MOVEM.L	(A7)+,D0-A6

	ADDQ.W	#1,A1
	ADDQ.W	#1,X
	CMP.W	#80,X
	BNE.S	.FOUT2
	MOVE.W	#0,X
	ADDQ.W	#1,Y
.FOUT2	BRA	.LA


.OUT	BRA	ENCORE

.FINI	MOVE.W	SX,X
	MOVE.W	SY,Y
	RTS

***************************************************************************
INVERT_CURSOR
	MOVE.L	$44E,A1
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVE.W	X,D3
	MOVE.W	Y,D4
	MOVE.L	D3,D2			* X
	CMP.W	#0,LEN_PLAN
	BEQ.S	OK
	DIVU	LEN_PLAN,D3
	AND.L	#$FFFF,D3
	MULU	LEN_PLAN,D3
OK	MULU	LEN_PLAN,D3
	MULU	LEN_LINE,D4		* Y
	ADD.L	D3,A1
	ADD.L	D4,A1
	BTST	#0,D2			* SAVOIR DANS QUELLE PARTIE DU MOT (DU PLAN) ON SE TROUVE
	BEQ.S	INV_1
	ADD.W	CORRECT,A1
INV_1	MOVE.W	NB_LINE,D5
INV_2   NOT.B	(A1)
	ADD.W	OCT_LINE,A1
	DBF	D5,INV_2
	RTS
***************************************************************************
WAITT	MOVE.W	#1,WAIT
.WW1	CMP.W	#1,WAIT
	BEQ.S	.WW1
	RTS
***************************************************************************
NEW_EDITE
	MOVE.W	#0,NU_POS
	MOVE.W	#0,ESSAI
	MOVE.W	#0,REP_EXACT
	MOVE.W	#0,FIN_ELEVE
***************************************************************************
EDITE	
	LEA	CLS,A0
	BSR	PRINT_GDOS
	LEA	L_22,A0
	BSR	PRINT_GDOS

	BSR	AFFICHE


LOOP	BSR	INPUT
	CMP.L	#0,D0
	BEQ.S	LOOP

N_F5	CMP.L	#$440000,D0
	BNE.S	N_F10
	BEQ	SORTIE			* F10 = SORTIE
	

N_F10	CMP.B	#$D,D0
	BNE.S	N_RETURN
	BSR	RETURN
	CMP.W	#1,FIN_ELEVE
	BNE	LOOP
	BRA	FIN_BANQUE

N_RETURN
	MOVE.B	REPONSE_E+1,REPONSE_E
	MOVE.B	D0,REPONSE_E+1
	BSR	PRINT_REPONSE
	BRA	LOOP
	
SORTIE	RTS
***************************************************************************
FIN_BANQUE
	LEA	CLS,A0
	BSR	PRINT_GDOS
	LEA	L_FIN,A0
	BSR	PRINT_GDOS

	MOVEQ	#0,D0
	MOVE.W	ESSAI,D0
	BSR	CONVERT2
	LEA	L_ESSAI,A0
	BSR	PRINT_GDOS
	LEA	NOMBRE2,A0
	BSR	PRINT_GDOS


	MOVEQ	#0,D0
	MOVE.W	REP_EXACT,D0
	BSR	CONVERT2
	LEA	L_REP_EXACT,A0
	BSR	PRINT_GDOS
	LEA	NOMBRE2,A0
	BSR	PRINT_GDOS

.O3	BSR	INPUT
	CMP.L	#0,D0
	BEQ.S	.O3

	MOVE.W	#0,NU_POS
	MOVE.W	#0,ESSAI
	MOVE.W	#0,REP_EXACT
	MOVE.W	#0,FIN_ELEVE
	RTS
***************************************************************************
CONVERT2
	LEA	NOMBRE2,A0
	DIVU	#1000,D0
	ADD.B	#'0',D0
	MOVE.B	D0,(A0)
	MOVE.W	#0,D0
	SWAP	D0
	DIVU	#100,D0
	ADD.B	#'0',D0
	MOVE.B	D0,1(A0)
	MOVE.W	#0,D0
	SWAP	D0
	DIVU	#10,D0
	ADD.B	#'0',D0
	MOVE.B	D0,2(A0)
	SWAP	D0
	ADD.B	#'0',D0
	MOVE.B	D0,3(A0)
	CMP.B	#'0',(A0)
	BNE.S	.RET2
	MOVE.B	#' ',(A0)
	CMP.B	#'0',1(A0)
	BNE.S	.RET2
	MOVE.B	#' ',1(A0)
	CMP.B	#'0',2(A0)
	BNE.S	.RET2
	MOVE.B	#' ',2(A0)
.RET2	RTS
NOMBRE2	DC.L	0
	DC.W	0
***************************************************************************
RETURN
	CMP.B	#'0',REPONSE_E
	BNE.S	.N_Y

	MOVE.B	#' ',REPONSE_E

.N_Y	MOVE.W	REPONSE,D0
	MOVE.W	REPONSE_E,D1
	CMP.W	D0,D1
	BEQ	EXACT

	LEA	L_INEXACT,A0
	BSR	PRINT_GDOS

.O1	BSR	INPUT
	CMP.L	#0,D0
	BEQ.S	.O1

	LEA	L_N_INEXACT,A0
	BSR	PRINT_GDOS
	MOVE.W	#' ',REPONSE_E
	BSR	PRINT_REPONSE
	ADDQ.W	#1,ESSAI
	RTS

EXACT	LEA	L_EXACT,A0
	BSR	PRINT_GDOS

.O2	BSR	INPUT
	CMP.L	#0,D0
	BEQ.S	.O2

	LEA	L_N_INEXACT,A0
	BSR	PRINT_GDOS
	ADDQ.W	#1,ESSAI
	ADDQ.W	#1,REP_EXACT

	ADDQ.W	#1,NU_POS
	MOVE.W	NU_POS,D1
	CMP.W	MAX_POS,D1
	BLT	AFFICHE
	MOVE.W	#1,FIN_ELEVE
	RTS
***************************************************************************
FF7
AFFICHE
	MOVE.W	NU_POS,D0
	MULU	#46,D0
	LEA	BNK_POS,A0
	LEA	(A0,D0.W),A0

	CMP.L	#-1,(A0)
	BNE.S	.O1

	MOVE.W	#1,FIN_ELEVE
	RTS

.O1	MOVE.W	(A0)+,NU_GREC
	CMP.W	#-1,NU_GREC
	BNE.S	.P1
	MOVE.W	#0,NU_GREC
.P1	MOVE.W	(A0)+,NU_QUEST
	CMP.W	#-1,NU_QUEST
	BNE.S	.P2
	MOVE.W	#0,NU_QUEST
.P2	MOVE.W	(A0)+,REPONSE
	CMP.W	#-1,REPONSE
	BNE.S	.P3
	MOVE.W	#'  ',REPONSE
.P3	MOVE.W	#'  ',REPONSE_E
	LEA	WORD_TAB,A1
	MOVEQ	#9,D0
.O4	MOVE.L	(A0)+,(A1)+
	DBF	D0,.O4

	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	AFFICHE_PARAGRAPHE_QUEST
	BSR	PRINT_REPONSE
	BSR	INVERT_FOUND_WORD
	RTS
***************************************************************************
AFFICHE_PARAGRAPHE_GREC
	LEA	L_0,A0
	BSR	PRINT_GDOS
	MOVEQ	#0,D0
	MOVE.W	NU_GREC,D0
	ADDQ.W	#1,D0
	BSR	CONVERT
	LEA	NOMBRE,A0
	BSR	PRINT_GDOS
	LEA	BNK_GREC,A0
	MOVEQ	#0,D0
	MOVE.W	NU_GREC,D0
	MULU	#(80*4)+1,D0
	ADD.L	D0,A0
	MOVE.L	A0,CURENT_GREC
	
	MOVEQ	#0,D0
	MOVEQ	#2,D1
       	BSR	PRINT
	
	RTS
***************************************************************************
AFFICHE_PARAGRAPHE_QUEST
	LEA	L_9,A0
	BSR	PRINT_GDOS
	MOVEQ	#0,D0
	MOVE.W	NU_POS,D0
	ADDQ.W	#1,D0
	BSR	CONVERT
	LEA	NOMBRE,A0
	BSR	PRINT_GDOS
	LEA	L_11,A0
	BSR	PRINT_GDOS
	LEA	BNK_QUEST,A0
	MOVEQ	#0,D0
	MOVE.W	NU_QUEST,D0
	MULU	#(80*10)+20,D0
	ADD.L	D0,A0
	MOVE.L	A0,CURENT_QUEST
	MOVE.L	A0,A5
	BSR	PRINT_GDOS		* LE 1e LIGNE EST UN PHRASE
	LEA	L_13,A0
	BSR	PRINT_GDOS		* ON SAUTE UNE LIGNE
	MOVE.L	A5,A0
	ADD.W	#81,A0
	BSR	PRINT_GDOS		* PUIS VIENNENT LES CHOIX
	
	RTS
***************************************************************************
CONVERT
	LEA	NOMBRE,A0
	DIVU	#100,D0
	ADD.B	#'0',D0
	MOVE.B	D0,(A0)
	MOVE.W	#0,D0
	SWAP	D0
	DIVU	#10,D0
	ADD.B	#'0',D0
	MOVE.B	D0,1(A0)
	SWAP	D0
	ADD.B	#'0',D0
	MOVE.B	D0,2(A0)
	CMP.B	#'0',(A0)
	BNE.S	RET
	MOVE.B	#' ',(A0)
	CMP.B	#'0',1(A0)
	BNE.S	RET
	MOVE.B	#' ',1(A0)
RET	RTS
NOMBRE	DC.L	0
***************************************************************************
INPUT:	*MOVE.W	#7,-(A7)
	*TRAP	#1
	*ADDQ.W	#2,A7
	*RTS
*	Simule la fonction   #7  du  trap #1
*	Retour : D0 = Caractere
INKEY	MOVEM.L	D1/A1,-(a7)
	MOVEQ	#0,D1
INPT	MOVEQ	#0,D0
	MOVE.B	KEY,D0
	BEQ	FINDESCODES
	
	CMP.B	#$2A,D0
	BEQ	SHIFT_D
	CMP.B	#$2A+128,D0
	BEQ	SHIFT_U
	CMP.B	#$36,D0
	BEQ	SHIFT_D
	CMP.B	#$36+128,D0
	BEQ	SHIFT_U
	CMP.B	#$3A,D0
	BEQ	ALTERNATE

	CMP.B	LAST,D0
	BNE.S	N_LAST
	BSR	WAITT
	SUBQ.W	#1,DELAY
	BNE	FINDESCODES
	MOVE.W	#1,DELAY
	BRA	N_DEL

N_LAST	MOVE.B	D0,LAST
	MOVE.W	#10,DELAY

N_DEL	MOVE.B	D0,D1
	SWAP	D0
	MOVE.B	D1,D0

	CMP.W	#0,SHIFT
	BNE.S	MAJUSC	
	LEA	SCANCODE_MIN,A1
	BRA	ENC
	
MAJUSC	LEA	SCANCODE_MAJ,A1
	
ENC	CMP.B	#-1,(A1)
	BEQ.S	FINDESCODES
	CMP.B	(A1)+,d0
	BEQ.S	.CA
	ADDQ.W	#1,a1
	BRA.S	ENC
	
.CA	MOVE.B	(A1),D0
	MOVEM.L	(A7)+,D1/A1
	RTS
	
FINDESCODES
	MOVEQ	#0,D0
	MOVEM.L	(A7)+,D1/A1
	RTS
SHIFT		DC.W	0
DELAY		DC.W	10
LAST		DC.B	0
		EVEN
***************************************************************************
SHIFT_D
	MOVE.W	#1,SHIFT
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	BRA	FINDESCODES
***************************************************************************
SHIFT_U
	MOVE.W	#0,SHIFT
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	BRA	FINDESCODES
***************************************************************************
ALTERNATE
	BCHG	#0,SHIFT
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	BRA	FINDESCODES
***************************************************************************
PRINT_GDOS:
	*MOVE.L	A0,-(A7)
	*MOVE.W	#9,-(A7)
	*TRAP	#1
	*ADDQ.W	#6,A7

	MOVEM.L	D0-A6,-(A7)
PRINT_GDOS1	
	MOVEQ	#0,D0	
	MOVEQ	#0,D1	
	MOVE.B	X1,D0
	MOVE.B	Y1,D1
	MOVE.L	$44E,A1
	MOVE.L	ADD_GDOS_FONT,A2
	MOVE.L	D0,D2			* X
	MULU	LEN_PLAN,D0
	MULU	LEN_LINE,D1		* Y
	ADD.L	D0,A1
	ADD.L	D1,A1
	BTST	#0,D2			* SAVOIR DANS QUELLE PARTIE DU MOT (DU PLAN) ON SE TROUVE
	BEQ.S	OCTET_11
	ADD.W	 CORRECT,A1
	BRA	OCTET_21
OCTET_11
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ	FIN
	CMP.B	#$1B,D0
	BEQ	ESC
	CMP.B	#$D,D0
	BEQ	TO_LEFT
	ADDQ.B	#1,X1
	LEA	(A2,D0.W),A3
	MOVE.W	NB_LINE,D3

	MOVE.L	A1,A4
ICI21	MOVE.B	(A3),(A4)
	ADD.W	OCT_LINE,A4
	ADD.W	#256,A3
	DBF	D3,ICI21
	
	ADDQ.W	#1,D2
	CMP.W	COL,D2
	BEQ	NEW_LINE
	ADDQ.W	#1,A1

OCTET_21
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ	FIN
	CMP.B	#$1B,D0
	BEQ	ESC
	CMP.B	#$D,D0
	BEQ	TO_LEFT
	ADDQ.B	#1,X1
	LEA	(A2,D0.W),A3
	MOVE.W	NB_LINE,D3

	MOVE.L	A1,A4
ICI11	MOVE.B	(A3),(A4)
	ADD.W	OCT_LINE,A4
	ADD.W	#256,A3
	DBF	D3,ICI11
	
	ADDQ.W	#1,D2
	CMP.W	COL,D2
	BEQ	NEW_LINE1		* 15 POUR 8 PLANS
	ADD.W	OFFSET,A1		* 7  POUR 4 PLANS
	BRA	OCTET_11		* 3  POUR 2 PLANS
					* 1  POUR 1 PLAN
NEW_LINE1
	ADD.W	LEN_LINE,A1
	ADD.W	OFFSET,A1
	SUB.W	OCT_LINE,A1
	MOVEQ	#0,D2
	BRA	OCTET_11

***************************************************************************
*	D0 = X	(0 - 79)
*	D1 = Y  (0 - 24)
*	A0 = ADD DU TXT   SE TERMINANT PAR 0
PRINT
	MOVEM.L	D0-A6,-(A7)
	MOVE.L	$44E,A1
	MOVE.L	ADD_GDOS_FONT,A2
	MOVE.L	D0,D2			* X
	MULU	LEN_PLAN,D0
	MULU	LEN_LINE,D1		* Y
	ADD.L	D0,A1
	ADD.L	D1,A1
	BTST	#0,D2			* SAVOIR DANS QUELLE PARTIE DU MOT (DU PLAN) ON SE TROUVE
	BEQ.S	OCTET_1
	ADD.W	 CORRECT,A1
	BRA	OCTET_2
OCTET_1
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ	FIN
	*BSR	FIND
	LEA	(A2,D0.W),A3
	MOVE.W	NB_LINE,D3

	MOVE.L	A1,A4
ICI2	MOVE.B	(A3),(A4)
	ADD.W	OCT_LINE,A4
	ADD.W	#256,A3
	DBF	D3,ICI2
	
	ADDQ.W	#1,D2
	CMP.W	COL,D2
	BEQ	NEW_LINE
	ADDQ.W	#1,A1

OCTET_2	
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ	FIN
	*BSR	FIND
	LEA	(A2,D0.W),A3
	MOVE.W	NB_LINE,D3

	MOVE.L	A1,A4
ICI1	MOVE.B	(A3),(A4)
	ADD.W	OCT_LINE,A4
	ADD.W	#256,A3
	DBF	D3,ICI1
	
	ADDQ.W	#1,D2
	CMP.W	COL,D2
	BEQ	NEW_LINE		* 15 POUR 8 PLANS
	ADD.W	OFFSET,A1		* 7  POUR 4 PLANS
	BRA	OCTET_1			* 3  POUR 2 PLANS
					* 1  POUR 1 PLAN
NEW_LINE
	ADD.W	LEN_LINE,A1
	ADD.W	OFFSET,A1
	SUB.W	OCT_LINE,A1
	MOVEQ	#0,D2
	BRA	OCTET_1

FIN	MOVEM.L	(A7)+,D0-A6
	RTS
***************************************************************************
ESC	MOVE.B	(A0)+,D0
	CMP.B	#'Y',D0
	BNE	_CLS
	MOVEQ	#0,D0
	MOVE.B	(A0)+,Y1
	SUB.B	#32,Y1
	MOVE.B	(A0)+,X1
	SUB.B	#32,X1
	BRA	PRINT_GDOS1
	
_CLS	CMP.B	#"E",D0
	BNE	OCTET_11
	SUBQ	#2,A0
	MOVE.L	A0,-(A7)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.W	#6,A7
	MOVE.B	#0,X1
	MOVE.B	#0,Y1
	BRA	FIN
***************************************************************************
TO_LEFT
	ADDQ.W	#1,A0
	MOVE.B	#0,X1
	ADDQ.B	#1,Y1
	BRA	PRINT_GDOS1
***************************************************************************
FIND	CMP.B	#'A',D0
	BLT	MINUS
	CMP.B	#'Z',D0
	BGT	MINUS
	
	LEA	TABLE_MAJ,A5
.I1	MOVE.B	(A5)+,D5
	MOVE.B	(A5)+,D6
	BEQ	.OUT1
	CMP.B	D5,D0
	BNE.S	.I1
	MOVE.B	D6,D0
	
.OUT1	ADD.B	#127,D0
	RTS
	
	
	
MINUS	CMP.B	#'a',D0
	BLT	FINO
	CMP.B	#'z',D0
	BGT	FINO
	
	LEA	TABLE_MIN,A5
.I2	MOVE.B	(A5)+,D5
	MOVE.B	(A5)+,D6
	BEQ	.OUT2
	CMP.B	D5,D0
	BNE.S	.I2
	MOVE.B	D6,D0
	
.OUT2	ADD.B	#127-8,D0
FINO	RTS
***************************************************************************
TABLE_MAJ	DC.B	'A','A','B','B','C','V','D','D','E','E','F','U'
		DC.B	'G','C','H','G','I','I','J','H','K','J','L','K'
		DC.B	'M','L','N','M','O','O','P','P','Q','W','R','Q'
		DC.B	'S','R','T','S','U','R','V','B','W','X','X','N'
		DC.B	'Y','T','Z','F'
		DC.B	0,0
TABLE_MIN	DC.B	'a','a','b','b','c','v','d','d','e','e','f','u'
		DC.B	'g','c','h','g','i','i','j','h','k','j','l','k'
		DC.B	'm','l','n','m','o','o','p','p','q','w','r','q'
		DC.B	's','r','t','s','u','z','v','y','w','x','x','n'
		DC.B	'y','t','z','f'
		DC.B	0,0		
***************************************************************************
*	Table of scancode to AZERTY
SCANCODE_MAJ
	DC.B	$3B,0,$3C,0,$3D,0,$3E,0,$3F,0,$40,0,$41,0,$42,0,$43,0,$44,0,$48,0,$4B,0,$4D,0,$50,0,$53,$7F
	DC.B	$02,'&',$03,'ê',$04,'"',$05,"'",$06,'(',$08,'ä',$09,'!',$0A,'Ä',$0B,'∂',$0C,')',$0D,'_',$0E,8

	DC.B	$10,'A',$11,'Z',$12,'E',$13,'R',$14,'T',$15,'Y',$16,'U',$17,'I',$18,'O',$19,'P',$1B,'*'
	DC.B    $1E,'Q',$1F,'S',$20,'D',$21,'F',$22,'G',$23,'H',$24,'J',$25,'K',$26,'L',$27,'M',$28,'ó'
	DC.B	$2C,'W',$2D,'X',$2E,'C',$2F,'V',$30,'B',$31,'N',$32,'?',$33,'.',$34,'/',$35,'+'
	
	DC.B	$6D,'1',$6E,'2',$6F,'3',$6A,'4',$6B,'5',$6C,'6',$67,'7',$68,'8',$69,'9',$70,'0',$66,'*'
	DC.B	$4A,'-',$4E,'+',$63,'(',$64,')',$65,'/',$66,'/'
	DC.B	$1C,$D,$72,$D,$71,'.',$33,'.',$39,' ',$28,'\'
	DC.B	-1,-1
	
SCANCODE_MIN
	DC.B	$3B,0,$3C,0,$3D,0,$3E,0,$3F,0,$40,0,$41,0,$42,0,$43,0,$44,0,$48,0,$4B,0,$4D,0,$50,0,$53,$7F
	DC.B	$02,'&',$03,'Ç',$04,'"',$05,"'",$06,'(',$08,'ä',$09,'!',$0A,'á',$0B,'Ö',$0C,')',$0D,'-',$0E,8
	
	DC.B	$10,'a',$11,'z',$12,'e',$13,'r',$14,'t',$15,'y',$16,'u',$17,'i',$18,'o',$19,'p',$1B,'*'
	DC.B    $1E,'q',$1F,'s',$20,'d',$21,'f',$22,'g',$23,'h',$24,'j',$25,'k',$26,'l',$27,'m',$28,'ó'
	DC.B	$2C,'w',$2D,'x',$2E,'c',$2F,'v',$30,'b',$31,'n',$32,',',$33,';',$34,':',$35,'='
	
	DC.B	$6D,'1',$6E,'2',$6F,'3',$6A,'4',$6B,'5',$6C,'6',$67,'7',$68,'8',$69,'9',$70,'0',$66,'*'
	DC.B	$4A,'-',$4E,'+',$63,'(',$64,')',$65,'/',$66,'/'
	DC.B	$1C,$D,$72,$D,$71,'.',$33,'.',$39,' ',$28,'\'
	DC.B	-1,-1	
***************************************************************************
INIT	MOVE.L	$44E.W,A0
	MOVE.L	#32000/4-1,D0
ICI3	CLR.L	(A0)+
	DBF	D0,ICI3
	
	MOVE.L	$42E.W,LIMIT
	SUB.L	#160,LIMIT

	MOVE.W	#0,NU_POS
	MOVE.W	#0,ESSAI
	MOVE.W	#0,REP_EXACT
	MOVE.W	#0,FIN_ELEVE

	MOVE.W	#4,-(A7)
	TRAP	#14
	ADDQ.W	#2,A7
	CMP.B	#0,D0
	BNE.S	TEST_4

	MOVE.W	#1,-(A7)
	PEA	-1
	PEA	-1
	MOVE.W	#5,-(A7)
	TRAP	#14
	ADD.W	#12,A7
	MOVEQ	#1,D0
	
TEST_4	CMP.B	#1,D0
	BNE.S	TEST_1
	MOVE.W	#3,OFFSET
	MOVE.W	#160*8,LEN_LINE
	MOVE.W	#2,LEN_PLAN
	MOVE.W	#1,CORRECT
	MOVE.L	#FONT_C+$25A,ADD_GREC_FONT
	MOVE.L	#FONT_C+$25A,ADD_GDOS_FONT
	MOVE.L	#FONT_COUL_TAB,CURENT_FONT
	MOVE.W	#80,COL
	MOVE.W	#8-1,NB_LINE
	MOVE.W	#160,OCT_LINE
	MOVE.W	#$0,$FFFF8240+2
	MOVE.W	#$0,$FFFF8240+4
	PEA	M640_200
	MOVE.W	#8,-(A7)
	MOVE.W	#25,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	BRA	INIT2
	
TEST_1	MOVE.W	#1,OFFSET
	MOVE.W	#80*16,LEN_LINE
	MOVE.W	#1,LEN_PLAN
	MOVE.W	#0,CORRECT
	MOVE.L	#FONT_M+$25A,ADD_GREC_FONT
	MOVE.L	#FONT_M+$25A,ADD_GDOS_FONT
	MOVE.L	#FONT_MONO_TAB,CURENT_FONT
	MOVE.W	#80,COL
	MOVE.W	#16-1,NB_LINE
	MOVE.W	#80,OCT_LINE
	PEA	M640_400
	MOVE.W	#8,-(A7)
	MOVE.W	#25,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	
INIT2	MOVE.W	SR,-(A7)
	JSR	STORE
	MOVE.W	#$2700,SR
	BCLR	#3,$FFFFFA17.W
	BSET	#5,$FFFFFA07.W
	BSET	#5,$FFFFFA13.W
	MOVE.B	#0,$FFFFFA19.W
	MOVE.B	#1,$FFFFFA1F.W
	MOVE.B	#8,$FFFFFA19.W
	MOVE.L	#MY_70,$70.W
	MOVE.L	#MY_118,$118.W
	MOVE.L	#MY_134,$134.W
	MOVE.W	(A7)+,SR	
	RTS
	
MY_134	RTE
***************************************************************************
MY_70	MOVEM.L	D0-A6,-(A7)
	MOVE.B	#$D,$FFFFFC02.W
	
	*CMP.W	#0,OKP
	*BNE.S	FIN_70
	*BSR	RESTITU
	*BSR	FOND2
	*BSR	AFFMOUSE
	
FIN_70	MOVE.W	#0,WAIT
	MOVEM.L	(A7)+,D0-A6
	RTE
***************************************************************************
MY_118	CMP.B	#$F7,$FFFFFC02.W
	BNE.S	.TSTKEY
	MOVE.L	#.IT2,$118.W
	RTE	
.TSTKEY	MOVE.B	$FFFFFC02.W,KEY
	RTE	
.IT2	MOVE.B	$FFFFFC02.W,KM
	MOVE.L	#.IT3,$118.W
	RTE
.IT3	MOVE.B	$FFFFFC02.W,XMOUSE
	MOVE.L	#.IT4,$118.W
	RTE
.IT4	MOVE.B	$FFFFFC02.W,XMOUSE+1
	MOVE.L	#.IT5,$118.W
	RTE
.IT5	MOVE.B	$FFFFFC02.W,YMOUSE
	MOVE.L	#.IT6,$118.W
	RTE
.IT6	MOVE.B	$FFFFFC02.W,YMOUSE+1
	MOVE.L	#MY_118,$118.W
	RTE
***************************************************************************
STORE	LEA	SAVE_REGISTER,A0
	MOVE.L	$70.W,(A0)+
	MOVE.L	$118.W,(A0)+
	MOVE.L	$134.W,(A0)+
	MOVE.L	$FFFFFA06.W,(A0)+
	MOVE.L	$FFFFFA12.W,(A0)+
	MOVE.L	$FFFFFA16.W,(A0)+
	MOVE.B	$FFFFFA1F.W,(A0)+
	MOVE.B	$FFFFFA25.W,(A0)+
	RTS
RESTORE LEA	SAVE_REGISTER,A0
	MOVE.W	#$2700,SR
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$118.W
	MOVE.L	(A0)+,$134.W
	MOVE.L	(A0)+,$FFFFFA06.W
	MOVE.L	(A0)+,$FFFFFA12.W
	MOVE.L	(A0)+,$FFFFFA16.W
	MOVE.B	(A0)+,$FFFFFA1F.W
	MOVE.B	(A0)+,$FFFFFA25.W
	MOVE.W	#$2300,SR
	RTS
***************************************************************************
		SECTION	DATA
M640_400	DC.B	9,02,$80-16,1,$90-1,0,0,0,0
M640_200	DC.B	9,02,$80-16,0,$C8-1,0,0,0,0
		EVEN
XMOUSE		DC.W	0
YMOUSE		DC.W	0
X2		DC.W	0
Y2		DC.L	0
KM		DC.B	0
KEY		DC.B	0
		
X		DC.W	0
Y		DC.W	2
NU_GREC		DC.W	0
NU_POS		DC.W	0
NB_POS		DC.W	0
NU_QUEST	DC.W	0
CURENT_GREC	DC.L	0
CURENT_QUEST	DC.L	0
CLS		DC.B	$1B,'E',0
ECRAN_MENU	DC.B	"        DIDACTITIEL    V1.0                         C.E.F.E.       Janvier 1994",$D,$A
		DC.B	"                                                13, rue Copernic               ",$D,$A
		DC.B	"        PAR GUILLAUME AUDUC                       44000 NANTES                 ",$D,$A,$D,$A,$D,$A,$D,$A,$D,$A
		DC.B	"  F1  - CHARGER  UNE BANQUE",$D,$A,$D,$A
		DC.B	"  F2  - RELANCER LA  BANQUE",$D,$A,$D,$A
		DC.B	"  F3  - LANCER   LA  BANQUE",$D,$A,$D,$A
		DC.B	"                           ",$D,$A,$D,$A
		DC.B	"                           ",$D,$A,$D,$A
		DC.B	"                              NOM DE LA BANQUE : ",$D,$A,$D,$A
		DC.B	"  F9  - CHANGER  LA  POLICE       ACTUELLEMENT : ",$D,$A,$D,$A
		DC.B	"  F10 - QUITTER",$D,$A
		DC.B	0
		EVEN

L_FIN		DC.B	$D,$A,$D,$A
		DC.B	" Vous venez d'atteindre la fin de la banque.",$d,$a,$d,$a
		DC.B	" Vous avez essayÇ 0000 reponses",$d,$a
		DC.B	"             dont 0000 etaient bonnes",0

L_0		DC.B	$1B,'Y',32+0,32+0," PHRASE   N¯ ",0
		*               LINE COL
L_9		DC.B	$1B,'Y',32+9,32+0," QUESTION N¯ ",0
L_11		DC.B	$1B,'Y',32+11,32+0,0
L_13		DC.B	$1B,'Y',32+13,32+0,0
L_22		DC.B	$1B,'Y',32+22,32+0,'     REPONSE : ',0
L_REP		DC.B	$1B,'Y',32+22,32+15,0
L_POS		DC.B	$1B,'Y',32+24,32+49,0
L_FONT		DC.B	$1B,'Y',32+19,32+49,0
L_NOM		DC.B	$1B,'Y',32+17,32+49,0
ARE_YOU_SURE	DC.B	$1B,'Y',32+20,32+28,'ETES VOUS SUR  (O/N) ?',0
N_YOU_SURE	DC.B	$1B,'Y',32+20,32+28,'                      ',0
L_C_FILENAME	DC.B	$1B,'Y',32+7,32+33,'NOM DU FICHIER : ',0
L_S_FILENAME	DC.B	$1B,'Y',32+11,32+33,'NOM DU FICHIER : ',0
L_C_FILE	DC.B	$1B,'Y',32+7,32+33+17,0
L_S_FILE	DC.B	$1B,'Y',32+11,32+33+17,0
L_C_FILEN	DC.B	$1B,'Y',32+7,32+33,'                               ',0
L_S_FILEN	DC.B	$1B,'Y',32+11,32+33,'                               ',0
L_INEXACT	DC.B	$1B,'Y',32+24,32+20,"C'EST INEXACT, RECOMMENCEZ",0
L_N_INEXACT	DC.B	$1B,'Y',32+24,32+20,'                          ',0
L_EXACT		DC.B	$1B,'Y',32+24,32+20,"C'EST LA BONNE REPONSE",0
L_ESSAI		DC.B	$1B,'Y',32+4,32+18,0
L_REP_EXACT	DC.B	$1B,'Y',32+5,32+18,0
		EVEN

ASCII		
		DC.B	1,' ',2,' ',3,' ',4,' ',5,' ',6,' ',7,' ',8,' ',9,' ',10,' ',11,' ',12,' ',14,' ',15,' ',16,' '
		DC.B	17,' ',18,' ',19,' ',20,' ',21,' ',22,' ',23,' ',24,' ',25,' ',26,' ',27,' ',28,' ',29,' ',30,' ',31,' ',32,$D,$A,$D,$A
		DC.B	33,' ',34,' ',35,' ',36,' ',37,' ',38,' ',39,' ',40,' ',41,' ',42,' ',43,' ',44,' ',45,' ',46,' ',47,' ',48,' '
		DC.B	49,' ',50,' ',51,' ',52,' ',53,' ',54,' ',55,' ',56,' ',57,' ',58,' ',59,' ',60,' ',61,' ',62,' ',63,' ',64,$D,$A,$D,$A
		DC.B	65,' ',66,' ',67,' ',68,' ',69,' ',70,' ',71,' ',72,' ',73,' ',74,' ',75,' ',76,' ',77,' ',78,' ',79,' ',80,' '
		DC.B	81,' ',82,' ',83,' ',84,' ',85,' ',86,' ',87,' ',88,' ',89,' ',90,' ',91,' ',92,' ',93,' ',94,' ',95,' ',96,$D,$A,$D,$A
		DC.B	97,' ',98,' ',99,' ',100,' ',101,' ',102,' ',103,' ',104,' ',105,' ',106,' ',107,' ',108,' ',109,' ',110,' ',111,' ',112,' '
		DC.B	113,' ',114,' ',115,' ',116,' ',117,' ',118,' ',119,' ',120,' ',121,' ',122,' ',123,' ',124,' ',125,' ',126,' ',127,' ',128,$D,$A,$D,$A
		DC.B	129,' ',130,' ',131,' ',132,' ',133,' ',134,' ',135,' ',136,' ',137,' ',138,' ',139,' ',140,' ',141,' ',142,' ',143,' ',144,' '
		DC.B	145,' ',146,' ',147,' ',148,' ',149,' ',150,' ',151,' ',152,' ',153,' ',154,' ',155,' ',156,' ',157,' ',158,' ',159,' ',160,$D,$A,$D,$A
		DC.B	161,' ',162,' ',163,' ',164,' ',165,' ',166,' ',167,' ',168,' ',169,' ',170,' ',171,' ',172,' ',173,' ',174,' ',175,' ',176,' '
		DC.B	177,' ',178,' ',179,' ',180,' ',181,' ',182,' ',183,' ',184,' ',185,' ',186,' ',187,' ',188,' ',189,' ',190,' ',191,' ',192,$D,$A,$D,$A
		DC.B	193,' ',194,' ',195,' ',196,' ',197,' ',198,' ',199,' ',200,' ',201,' ',202,' ',203,' ',204,' ',205,' ',206,' ',207,' ',208,' '
		DC.B	209,' ',210,' ',211,' ',212,' ',213,' ',214,' ',215,' ',216,' ',217,' ',218,' ',219,' ',220,' ',221,' ',222,' ',223,' ',224,$D,$A,$D,$A
		DC.B	225,' ',226,' ',227,' ',228,' ',229,' ',230,' ',231,' ',232,' ',234,' ',235,' ',236,' ',237,' ',238,' ',239,' ',240,' ',241,' '
		DC.B	242,' ',243,' ',244,' ',245,' ',246,' ',247,' ',248,' ',249,' ',250,' ',251,' ',252,' ',253,' ',254,' ',255,$D,$A
		DC.B	$1B,'Y',32+19,32,"  F9  - CHANGER  LA  POLICE       ACTUELLEMENT : ",$D,$A
		DC.B	"  F10 - SORTIR",0

FONT_COUL_TAB	DC.L	FONT_C,FONTC1,FONTC2,FONTC3,FONTC4,FONTC5,FONTC6,FONTC7,FONTC8
		DC.L	FONTC9,FONTC10,FONTC11,FONTC12,FONTC13,FONTC14,FONTC15
		DC.L	-1

FONT_MONO_TAB	DC.L	FONT_M,FONT1,FONT2,FONT3,FONT4,FONT5,FONT6,FONT7,FONT8
		DC.L	FONT9,FONT10,FONT11,FONT12,FONT13,FONT14,FONT15,FONT16
		DC.L	FONT17,FONT18,FONT19
		DC.L	-1

FONT_C		INCBIN	GREC_C.FNT
FONTC1		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\BATON6.FNT
FONTC2		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\BATON8.FNT
FONTC3		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\CURSIVEC.FNT
FONTC4		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\DUTCH_C.FNT
FONTC5		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GARALDE8.FNT
FONTC6		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GARAP8.FNT
FONTC7		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GARAP_C.FNT
FONTC8		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GOTH_C.FNT
FONTC9		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\HUGO_C.FNT
FONTC10		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\MERIDIEN.FNT
FONTC11		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\MOYEN6.FNT
FONTC12		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\RAZOR_C.FNT
FONTC13		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\RONDE_C.FNT
FONTC14		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\SUISSE_C.FNT
FONTC15		INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\VAHE_C.FNT

FONT_M		INCBIN	GREC.FNT
FONT1		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\BATON12.FNT
FONT2		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\CURSIVE.FNT
FONT3		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\DIDONE.FNT
FONT4		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\DUTCH.FNT
FONT5		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GARALDE.FNT
FONT6		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GARAP.FNT
FONT7		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GOTH.FNT
FONT8		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\GRAPHE.FNT
FONT9		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\HUGO.FNT
FONT10		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\LINEALE.FNT
FONT11		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\MERIDIE.FNT
FONT12		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\MEDIUM12.FNT
FONT13		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\REALE.FNT
FONT14		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\RAZOR.FNT
FONT15		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\RONDE.FNT
FONT16		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\SCRIPTE.FNT
FONT17		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\SUISSE.FNT
FONT18		*INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\VAHE.FNT
FONT19		INCBIN	D:\TEXTE\REDAC__4.02F\POLICES\ZAMENHOF.FNT
		EVEN

REPONSE		DC.B	'  ',0,0
REPONSE_E	DC.B	'  ',0,0
MAX_GREC	DC.W	50
MAX_QUEST	DC.W	50
MAX_POS		DC.W	500


DEBUT_FICHIER
		DC.B	0,0,0,0
NOM_BANQUE	DC.B	'PAS DE BANQUE EN MEMOIRE ',0,0
		EVEN

		DC.B	'BNK_GREC'
		DC.W	((80*4)+1)*50
		DC.W	0
BNK_GREC	REPT	50
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________",0
		ENDR
		EVEN


		DC.B	'BNK_QUES'
		DC.L	((80*10)+20)*50
BNK_QUEST	REPT	50
		DC.B	"                                                                                ",0
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",0
		DC.B	" ",0
		ENDR
		EVEN

		DC.B	'BNK_POS_'
		DC.L	500*46
BNK_POS		DCB.B	500*46,-1

FIN_FICHIER
***************************************************************************
		SECTION	BSS
SAVE_REGISTER	DS.L	10
FOND		DS.L	40
CURENT_FONT	DS.L	1
ADD_GREC_FONT	DS.L	1
ADD_GDOS_FONT	DS.L	1
OFFSET		DS.W	1
LEN_LINE	DS.W	1
LEN_PLAN	DS.W	1
CORRECT		DS.W	1
NB_LINE		DS.W	1
OCT_LINE	DS.W	1
COL		DS.W	1
X1		DS.B	1
Y1		DS.B	1
X_OFFS		DS.W	1
OKP		DS.W	1
WAIT		DS.W	1
LIMIT		DS.L	1
ANSWER		DS.W	1
ESSAI		DS.W	1
REP_EXACT	DS.W	1
FIN_ELEVE	DS.W	1
