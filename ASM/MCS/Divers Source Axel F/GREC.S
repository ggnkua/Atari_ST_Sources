*
*	DIDACTITIEL DE GREC  POUR M. GILLES DURAND
*	 PAR GUILLAUME AUDUC
*
*	  PREMIERE PARTIE : L'EDITEUR POUR LE PROFESSEUR
*
*	TEMPS	6H	



	MOVE.W	#$20,-(A7)
	TRAP	#1
	
	BSR	INIT
	BSR	MAIN_MENU
	
EXIT	MOVE.L	#0,-(A7)
	TRAP	#1
***************************************************************************
MAIN_MENU
	LEA	CLS,A0
	BSR	PRINT_GDOS
	LEA	ECRAN_MENU,A0
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
	BSR	SAUVE
	BRA	MAIN_MENU

PAS_F3	CMP.L	#$440000,D0
	BNE.S	PAS_F10
	RTS

PAS_F10	BRA	CONT
***************************************************************************
CHARGE
	RTS
***************************************************************************
EDITE	LEA	CLS,A0
	BSR	PRINT_GDOS
	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	AFFICHE_PARAGRAPHE_QUEST

LOOP	BSR	INPUT

	CMP.L	#$3B0000,D0
	BEQ	F1			* TOGGLE GREC/QUEST
	CMP.L	#$3C0000,D0
	BEQ	F2			* + 1 GREC
	CMP.L	#$3D0000,D0
	BEQ	F3			* - 1 GREC
	CMP.L	#$3E0000,D0
	BEQ	F4			* + 1 QUEST
	CMP.L	#$3F0000,D0
	BEQ	F5			* - 1 QUEST
	CMP.L	#$440000,D0
	BEQ	SORTIE			* F10 = SORTIE
	
	CMP.L	#$480000,D0
	BEQ	UP
	CMP.L	#$500000,D0
	BEQ	DOWN
	CMP.L	#$4B0000,D0
	BEQ	LEFT
	CMP.L	#$4D0000,D0
	BEQ	RIGHT
	
	CMP.L	#$53007F,D0
	BEQ	DELETE
	CMP.L	#$0E0008,D0
	BEQ	BACKSPACE
	
	CMP.B	#'A',D0
	BLT	PAS_CAPITAL
	CMP.B	#'Z',D0
	BGT	PAS_CAPITAL
	BRA	CHAR
	
PAS_CAPITAL
	CMP.B	#'a',D0
	BLT	PAS_MINUSCUL
	CMP.B	#'z',D0
	BGT	PAS_MINUSCUL
	BRA	CHAR
	
PAS_MINUSCUL
	CMP.B	#'0',D0
	BLT	PAS_CHIFFRE
	CMP.B	#'9',D0
	BGT	PAS_CHIFFRE
	BRA	CHAR
	
PAS_CHIFFRE	
	CMP.B	#" ",D0
	BEQ	CHAR
	CMP.B	#".",D0
	BEQ	CHAR
	CMP.B	#",",D0
	BEQ	CHAR
	CMP.B	#"'",D0
	BEQ	CHAR
	CMP.B	#";",D0
	BEQ	CHAR
	CMP.B	#"?",D0
	BEQ	CHAR
	CMP.B	#";",D0
	BEQ	CHAR
	CMP.B	#"Ç",D0
	BEQ	CHAR
	CMP.B	#"ê",D0
	BEQ	CHAR
	CMP.B	#"ä",D0
	BEQ	CHAR
	CMP.B	#"Ö",D0
	BEQ	CHAR
	CMP.B	#"∂",D0
	BEQ	CHAR
	CMP.B	#"ó",D0
	BEQ	CHAR
	CMP.B	#"(",D0
	BEQ	CHAR
	CMP.B	#")",D0
	BEQ	CHAR
	CMP.B	#"-",D0
	BEQ	CHAR
	CMP.B	#"+",D0
	BEQ	CHAR
	CMP.B	#"*",D0
	BEQ	CHAR
	
	BRA	LOOP
	
SORTIE	RTS
	
***************************************************************************
CHAR
	MOVEQ	#0,D2
	MOVEQ	#0,D1
	CMP.W	#11,Y
	BLT	CHAR_GREC
	BGT	CHAR_QUEST
	
	MOVE.L	CURENT_QUEST,A0
	ADD.W	#80-1,A0
	MOVE.W	X,D2
	CMP.W	#80-1,D2
	BEQ.S	Z4
	MOVE.W	#80-1,D1
	
.BCL4	MOVE.B	-1(A0),(A0)
	SUBQ.W	#1,D1
	SUBQ.W	#1,A0
	CMP.B	D2,D1
	BNE.S	.BCL4
Z4	MOVE.B	D0,(A0)
	
	BSR	AFFICHE_PARAGRAPHE_QUEST
	BSR	INC_ONE_X_CURSOR
	BRA	LOOP

	
CHAR_QUEST
	MOVE.W	X,D2
	MOVE.W	Y,D1
	SUB.W	#13,D1
	MULU	#82,D1
	ADD.W	#81,D1
	ADD.W	#80-1,D1
	MOVE.L	CURENT_QUEST,A0
	ADD.W	D1,A0
	CMP.W	#80-1,D2
	BEQ.S	Z3
	MOVE.W	#80-1,D1
	
.BCL5	MOVE.B	-1(A0),(A0)
	SUBQ.W	#1,D1
	SUBQ.W	#1,A0
	CMP.B	D2,D1
	BNE.S	.BCL5
Z3	MOVE.B	D0,(A0)
	
	BSR	AFFICHE_PARAGRAPHE_QUEST
	BSR	INC_ONE_X_CURSOR
	BRA	LOOP
	
	
CHAR_GREC
	MOVE.W	Y,D1
	SUBQ.W	#2,D1
	MULU	#80,D1
	ADD.W	X,D1
	
	MOVE.L	CURENT_GREC,A0
	ADD.W	#80*4-1,A0
	CMP.W	#5,Y
	BNE.S	Z1
	CMP.W	#79,X
	BEQ.S	Z2
	
Z1	MOVE.W	#80*4-1,D2
	
.BCL6	MOVE.B	-1(A0),(A0)
	SUBQ.W	#1,A0
	SUBQ.W	#1,D2
	CMP.W	D2,D1
	BNE.S	.BCL6
Z2	BSR	FIND
	MOVE.B	D0,(A0)
	
	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	INC_ONE_X_CURSOR
	BRA	LOOP
***************************************************************************
INC_ONE_X_CURSOR
	CMP.W	#11,Y
	BLT	TEST_CURS_GREC
	
	CMP.W	#79,X
	BEQ.S	C_PAS_BON
ICI_LA	BSR	INVERT_CURSOR
	ADDQ.W	#1,X
	BSR	INVERT_CURSOR
C_PAS_BON
	RTS
	
	
TEST_CURS_GREC
	CMP.W	#79,X
	BNE.S	ICI_LA
	CMP.W	#5,Y
	BEQ.S	C_PAS_BON
	BSR	INVERT_CURSOR
	MOVE.W	#0,X
	ADDQ.W	#1,Y
	BSR	INVERT_CURSOR
	RTS

***************************************************************************
BACKSPACE	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	CMP.W	#11,Y
	BLT	BACK_GREC
	BGT	BACK_QUEST


	CMP.W	#0,X
	BEQ	LOOP
	MOVE.L	CURENT_QUEST,A0
	MOVE.W	X,D0
	ADD.W	D0,A0
	SUBQ.W	#1,A0
	SUBQ.W	#1,D0
	
.BCL2	MOVE.B	1(A0),(A0)
	ADDQ.W	#1,A0
	ADDQ.W	#1,D0
	CMP.W	#79,D0
	BNE.S	.BCL2
	MOVE.B	#" ",(A0)
	BSR	AFFICHE_PARAGRAPHE_QUEST
	MOVE.W	X,D0
	MOVE.W	Y,D1
	SUBQ.W	#1,D0
	BSR	CURSOR
	BRA	LOOP

BACK_GREC
	CMP.W	#0,X
	BNE.S	Z6
	CMP.W	#2,Y
	BEQ	LOOP
Z6	MOVE.W	Y,D0
	SUBQ.W	#2,D0
	MULU	#80,D0
	ADD.W	X,D0
	MOVE.L	CURENT_GREC,A0
	ADD.W	D0,A0
	SUBQ.W	#1,A0
	
.BCL3	MOVE.B	1(A0),(A0)
	ADDQ.W	#1,A0
	ADDQ.W	#1,D0
	CMP.W	#80*4,D0
	BNE.S	.BCL3
	MOVE.B	#"_",(A0)
	
	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	INVERT_CURSOR
	SUBQ.W	#1,X
	CMP.W	#-1,X
	BNE.S	Z7
	MOVE.W	#79,X
	SUBQ.W	#1,Y
Z7	BSR	INVERT_CURSOR
	BRA	LOOP
	
BACK_QUEST
	CMP.W	#0,X
	BEQ	LOOP
	MOVE.W	Y,D0
	SUB.W	#13,D0
	MULU	#82,D0
	ADD.W	X,D0
	MOVE.L	CURENT_QUEST,A0
	ADD.W	#81,D0
	ADD.W	D0,A0
	SUBQ.W	#1,A0
	MOVE.W	X,D0
	SUBQ.W	#1,D0
	
.BCL4	MOVE.B	1(A0),(A0)
	ADDQ.W	#1,A0
	ADDQ.W	#1,D0
	CMP.W	#80-1,D0
	BNE.S	.BCL4
	MOVE.B	#" ",(A0)

	BSR	AFFICHE_PARAGRAPHE_QUEST
	MOVE.W	X,D0
	MOVE.W	Y,D1
	SUBQ.W	#1,D0
	BSR	CURSOR
	BRA	LOOP
***************************************************************************
DELETE	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	CMP.W	#11,Y
	BLT	DEL_GREC
	BGT	DEL_QUEST

	MOVE.L	CURENT_QUEST,A0
	MOVE.W	X,D0
	ADD.W	D0,A0
	
.BCL2	MOVE.B	1(A0),(A0)
	ADDQ.W	#1,A0
	ADDQ.W	#1,D0
	CMP.W	#79,D0
	BNE.S	.BCL2
	MOVE.B	#" ",(A0)
	BSR	AFFICHE_PARAGRAPHE_QUEST
	BRA	LOOP

DEL_GREC
	MOVE.W	Y,D0
	SUBQ.W	#2,D0
	MULU	#80,D0
	ADD.W	X,D0
	MOVE.L	CURENT_GREC,A0
	ADD.W	D0,A0
	
.BCL3	MOVE.B	1(A0),(A0)
	ADDQ.W	#1,A0
	ADDQ.W	#1,D0
	CMP.W	#80*4-1,D0
	BNE.S	.BCL3
	MOVE.B	#"_",(A0)
	BSR	AFFICHE_PARAGRAPHE_GREC
	BRA	LOOP
	
DEL_QUEST
	MOVE.W	Y,D0
	SUB.W	#13,D0
	MULU	#82,D0
	ADD.W	X,D0
	MOVE.L	CURENT_QUEST,A0
	ADD.W	#81,D0
	ADD.W	D0,A0
	
	MOVE.W	X,D0
	MOVE.W	Y,D1
	SUB.W	#13,D1
	
.BCL4	MOVE.B	1(A0),(A0)
	ADDQ.W	#1,A0
	ADDQ.W	#1,D0
	CMP.W	#80-1,D0
	BNE.S	.BCL4
	MOVE.B	#" ",(A0)
	
	BSR	AFFICHE_PARAGRAPHE_QUEST
	BRA	LOOP	
***************************************************************************
LEFT	MOVE.W	X,D0
	MOVE.W	Y,D1
	SUBQ.W	#1,D0
	CMP.W	#-1,D0
	BNE.S	LEFT1
	MOVE.W	#79,D0
LEFT1	BSR	CURSOR
	BRA	LOOP
***************************************************************************
RIGHT	MOVE.W	X,D0
	MOVE.W	Y,D1
	ADDQ.W	#1,D0
	CMP.W	#80,D0
	BNE.S	RIGHT1
	MOVE.W	#0,D0
RIGHT1	BSR	CURSOR
	BRA	LOOP
***************************************************************************
UP	MOVE.W	X,D0
	MOVE.W	Y,D1
	CMP.W	#8,D1
	BGE.S	UP_QUEST
	
	SUBQ.W	#1,D1
	CMP.W	#1,D1
	BNE.S	UP1
	MOVE.W	#5,D1
UP1	BSR	CURSOR
	BRA	LOOP
	
UP_QUEST
	SUBQ.W	#1,D1
	CMP.W	#10,D1
	BEQ.S	UP2
	CMP.W	#12,D1
	BEQ.S	UP3
	BRA	UP4
UP2	MOVE.W	#21,D1
	BRA	UP4
UP3	MOVE.W	#11,D1
UP4	BSR	CURSOR
	BRA	LOOP	
***************************************************************************
DOWN	MOVE.W	X,D0
	MOVE.W	Y,D1
	CMP.W	#8,D1
	BGE.S	DOWN_QUEST
	
	ADDQ.W	#1,D1
	CMP.W	#6,D1
	BNE.S	DOWN1
	MOVE.W	#2,D1
DOWN1	BSR	CURSOR
	BRA	LOOP
	
DOWN_QUEST
	ADDQ.W	#1,D1
	CMP.W	#12,D1
	BEQ.S	DOWN2
	CMP.W	#22,D1
	BEQ.S	DOWN3
	BRA.S	DOWN4
DOWN2	MOVE.W	#13,D1
	BRA.S	DOWN4
DOWN3	MOVE.W	#11,D1
DOWN4	BSR	CURSOR
	BRA	LOOP		
***************************************************************************
F1	CMP.W	#8,Y
	BLE.S	TO_QUEST
	
	MOVE.W	#0,D0
	MOVE.W	#2,D1
	BSR	CURSOR
	BRA	LOOP
	
TO_QUEST
	MOVE.W	#0,D0
	MOVE.W	#11,D1
	BSR	CURSOR
	BRA	LOOP
***************************************************************************
F2	ADDQ.W	#1,NU_GREC
	MOVE.W	NU_GREC,D1
	CMP.W	MAX_GREC,D1
	BLT.S	FF2
	MOVE.W	#0,NU_GREC
FF2	BSR	AFFICHE_PARAGRAPHE_GREC
	BRA	LOOP
***************************************************************************
F3	SUBQ.W	#1,NU_GREC
	CMP.W	#-1,NU_GREC
	BNE	FF3
	MOVE.W	MAX_GREC,NU_GREC
	SUBQ.W	#1,NU_GREC
FF3	BSR	AFFICHE_PARAGRAPHE_GREC
	BRA	LOOP
***************************************************************************
F4	ADDQ.W	#1,NU_QUEST
	MOVE.W	NU_QUEST,D1
	CMP.W	MAX_QUEST,D1
	BLT.S	FF4
	MOVE.W	#0,NU_QUEST
FF4	BSR	AFFICHE_PARAGRAPHE_QUEST
	BRA	LOOP
***************************************************************************
F5	SUBQ.W	#1,NU_QUEST
	CMP.W	#-1,NU_QUEST
	BNE	FF5
	MOVE.W	MAX_QUEST,NU_QUEST
	SUBQ.W	#1,NU_QUEST
FF5	BSR	AFFICHE_PARAGRAPHE_QUEST
	BRA	LOOP
***************************************************************************
CURSOR
	BSR	INVERT_CURSOR
	MOVE.W	D0,X
	MOVE.W	D1,Y
	BSR	INVERT_CURSOR
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
	
	CMP.W	#7,Y
	BGE	RET
	BSR	INVERT_CURSOR
	RTS
***************************************************************************
AFFICHE_PARAGRAPHE_QUEST
	LEA	L_9,A0
	BSR	PRINT_GDOS
	MOVEQ	#0,D0
	MOVE.W	NU_QUEST,D0
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
	
	CMP.W	#9,Y
	BLE.S	RET
	BSR	INVERT_CURSOR
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
SAUVE
	RTS
***************************************************************************
INPUT	MOVE.W	#7,-(A7)
	TRAP	#1
	ADDQ.W	#2,A7
	RTS
***************************************************************************
PRINT_GDOS
	*MOVE.L	A0,-(A7)
	*MOVE.W	#9,-(A7)
	*TRAP	#1
	*ADDQ.W	#6,A7

	MOVEQ	#0,D0	
	MOVEQ	#0,D1	
	MOVE.B	X1,D0
	MOVE.B	Y1,D1
	MOVE.L	$44E,A1
	MOVE.L	ADD_FONT,A2
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

	RTS
***************************************************************************
*	D0 = X	(0 - 79)
*	D1 = Y  (0 - 24)
*	A0 = ADD DU TXT   SE TERMINANT PAR 0
PRINT
	MOVE.L	$44E,A1
	MOVE.L	ADD_FONT,A2
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
	BSR	FIND
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
	BSR	FIND
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

FIN	RTS
***************************************************************************
ESC	MOVE.B	(A0)+,D0
	CMP.B	#'Y',D0
	BNE	_CLS
	MOVEQ	#0,D0
	MOVE.B	(A0)+,Y1
	SUB.B	#32,Y1
	MOVE.B	(A0)+,X1
	SUB.B	#32,X1
	BRA	PRINT_GDOS
	
_CLS	CMP.B	#"E",D0
	BNE	OCTET_11
	SUBQ	#2,A0
	MOVE.L	A0,-(A7)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.W	#6,A7
	MOVE.B	#0,X1
	MOVE.B	#0,Y1
	RTS
***************************************************************************
TO_LEFT
	ADDQ.W	#1,A0
	MOVE.B	#0,X1
	ADDQ.B	#1,Y1
	BRA	PRINT_GDOS
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
	BLT	FIN
	CMP.B	#'z',D0
	BGT	FIN
	
	LEA	TABLE_MIN,A5
.I2	MOVE.B	(A5)+,D5
	MOVE.B	(A5)+,D6
	BEQ	.OUT2
	CMP.B	D5,D0
	BNE.S	.I2
	MOVE.B	D6,D0
	
.OUT2	ADD.B	#127-8,D0
	RTS
***************************************************************************
TABLE_MAJ	DC.B	'A','A','B','B','C','V','D','D','E','E','F','U'
		DC.B	'G','C','H','G','I','I','J','H','K','J','L','K'
		DC.B	'M','L','N','M','O','O','P','P','Q','W','R','Q'
		DC.B	'S','R','T','S','U','Z','V','Y','W','X','X','N'
		DC.B	'Y','T','Z','F'
		DC.B	0,0
TABLE_MIN	DC.B	'a','a','b','b','c','v','d','d','e','e','f','u'
		DC.B	'g','c','h','g','i','i','j','h','k','j','l','k'
		DC.B	'm','l','n','m','o','o','p','p','q','w','r','q'
		DC.B	's','r','t','s','u','z','v','y','w','x','x','n'
		DC.B	'y','t','z','f'
		DC.B	0,0		
***************************************************************************
INIT	MOVE.L	$44E.W,A0
	MOVE.L	#32000/4-1,D0
ICI3	CLR.L	(A0)+
	DBF	D0,ICI3
	
	MOVE.W	#4,-(A7)
	TRAP	#14
	ADDQ.W	#2,A7
	CMP.B	#0,D0
	BNE.S	TEST_4
	MOVE.W	#7,OFFSET
	MOVE.W	#160*8,LEN_LINE
	MOVE.W	#4,LEN_PLAN
	MOVE.W	#1,CORRECT
	MOVE.L	#FONT_C+$25A,ADD_FONT
	MOVE.W	#40,COL
	MOVE.W	#8-1,NB_LINE
	MOVE.W	#160,OCT_LINE
	MOVE.W	#0,$FFFF8240+2
	RTS
TEST_4	CMP.B	#1,D0
	BNE.S	TEST_1
	MOVE.W	#3,OFFSET
	MOVE.W	#160*8,LEN_LINE
	MOVE.W	#2,LEN_PLAN
	MOVE.W	#1,CORRECT
	MOVE.L	#FONT_C+$25A,ADD_FONT
	MOVE.W	#80,COL
	MOVE.W	#8-1,NB_LINE
	MOVE.W	#160,OCT_LINE
	MOVE.W	#$0,$FFFF8240+2
	MOVE.W	#$0,$FFFF8240+4
	RTS
TEST_1	MOVE.W	#1,OFFSET
	MOVE.W	#80*16,LEN_LINE
	MOVE.W	#1,LEN_PLAN
	MOVE.W	#0,CORRECT
	MOVE.L	#FONT_M+$25A,ADD_FONT
	MOVE.W	#80,COL
	MOVE.W	#16-1,NB_LINE
	MOVE.W	#80,OCT_LINE
	RTS
***************************************************************************
		SECTION	DATA
X		DC.W	0
Y		DC.W	2
NU_GREC		DC.W	0
NU_SEQ		DC.W	0
NU_QUEST	DC.W	0
CURENT_GREC	DC.L	0
CURENT_QUEST	DC.L	0
CLS		DC.B	$1B,'E',0
ECRAN_MENU	DC.B	$D,$A
		DC.B	"                                     GRECO",$D,$A,$D,$A,$D,$A,$D,$A
		DC.B	" F1  - CHARGER UNE BANQUE",$D,$A,$D,$A
		DC.B	" F2  - EDITER  UNE BANQUE",$D,$A,$D,$A
		DC.B	" F3  - SAUVER  UNE BANQUE",$D,$A,$D,$A
		DC.B	" F10 - QUITTER",$D,$A
		DC.B	0
		EVEN
L_0		DC.B	$1B,'Y',32+0,32+0," PHRASE   N¯ ",0
		*               LINE COL
L_9		DC.B	$1B,'Y',32+9,32+0," QUESTION N¯ ",0
L_11		DC.B	$1B,'Y',32+11,32+0,0
L_13		DC.B	$1B,'Y',32+13,32+0,0
		EVEN		

FONT_M		INCBIN	GREC.FNT
FONT_C		INCBIN	GREC_C.FNT
		EVEN
MAX_GREC	DC.W	20
MAX_QUEST	DC.W	20
		DC.B	0
BNK_GREC	
		DC.B	"Sdm lnm Peiqaia nseividalem nm sotsx sx vqdmx___________________________________"
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________",0
		REPT	19
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________"
		DC.B	"________________________________________________________________________________",0
		ENDR

		DC.B	0
BNK_QUEST
		DC.B	" S'agit-il :                                                                    ",0
		DC.B	" 1 - d'un verbe                                                                 ",$D,$A
		DC.B	" 2 - d'un nom                                                                   ",$D,$A
		DC.B	" 3 - d'un adjectif                                                              ",$D,$A
		DC.B	" 4 - d'un pronom                                                                ",$D,$A
		DC.B	" 5 - d'une conjonction                                                          ",$D,$A
		DC.B	" 6 - d'un article                                                               ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",0
		DC.B	" ",0
		
		DC.B	" Est-ce                                                                         ",0
		DC.B	" 1 - un COD                                                                     ",$D,$A
		DC.B	" 2 - un CC temps                                                                ",$D,$A
		DC.B	" 3 - un CC lieu                                                                 ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",$D,$A
		DC.B	"                                                                                ",0
		DC.B	" ",0
		
		REPT	18
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
***************************************************************************
		SECTION	BSS
ADD_FONT	DS.L	1
OFFSET		DS.W	1
LEN_LINE	DS.W	1
LEN_PLAN	DS.W	1
CORRECT		DS.W	1
NB_LINE		DS.W	1
OCT_LINE	DS.W	1
COL		DS.W	1
X1		DS.B	1
Y1		DS.B	1
