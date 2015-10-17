*
*	DIDACTITIEL POUR M. GILLES DURAND
*	 PAR GUILLAUME AUDUC
*
*	  PREMIERE PARTIE : L'EDITEUR POUR LE PROFESSEUR
*
* 3 	TEMPS	2 H	



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
	BSR	CORRECT_ENTER

	LEA	CLS,A0
	BSR	PRINT_GDOS
	LEA	ASCII,A0
	BSR	PRINT_GDOS
	LEA	L_FONT,A0
	BSR	PRINT_GDOS
	MOVE.L	ADD_GDOS_FONT,A0
	SUB.W	#$25A-4,A0
	BSR	PRINT_GDOS

	BSR	CORRECT_EXIT

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
	BSR	CORRECT_ENTER

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

	BSR	WAITT
	BSR	FOND2
	MOVE.W	#0,OKP

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

PAS_F3	CMP.L	#$3E0000,D0
	BNE.S	PAS_F4
	BSR	NETTOYE
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
	BSR	NOMME
	BRA	MAIN_MENU

PAS_F8	CMP.L	#$430000,D0
	BNE.S	PAS_F9
	BSR	CHANGE_FONT
	BRA	MAIN_MENU

PAS_F9	CMP.L	#$440000,D0
	BNE.S	PAS_F10
	RTS

PAS_F10	LEA	MENU_G,A0
	LEA	MENU_D,A1
	BSR	POSMOUSE
	CMP.L	#-1,A2
	BEQ	CONT
	CMP.L	#SORTIE,A2
	BEQ	SORTIE

	JSR	(A2)
	BRA	MAIN_MENU
***************************************************************************
CHARGE	
	BSR	CORRECT_ENTER
	LEA	FILENAME,A2
	MOVE.L	#'    ',(A2)
	MOVE.L	#'    ',4(A2)
	MOVE.L	#'    ',8(A2)

	LEA	L_C_FILENAME,A0
	BSR	PRINT_GDOS
	MOVE.L	A2,A0
	BSR	PRINT_GDOS
	BSR	CORRECT_EXIT

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

.ICI	BSR	CORRECT_ENTER
	LEA	L_C_FILEN,A0
	BSR	PRINT_GDOS
	BSR	CORRECT_EXIT
	RTS


		DC.W	0
FILENAME	DC.B	'12345678.MCS',0,0
		EVEN
***************************************************************************
SAUVE
	BSR	CORRECT_ENTER
	LEA	FILENAME,A2
	MOVE.L	#'    ',(A2)
	MOVE.L	#'    ',4(A2)
	MOVE.L	#'    ',8(A2)

	LEA	L_S_FILENAME,A0
	BSR	PRINT_GDOS
	MOVE.L	A2,A0
	BSR	PRINT_GDOS
	BSR	CORRECT_EXIT

	MOVE.L	A2,A5
	LEA	8(A2),A6
	LEA	L_S_FILE,A4
	BSR	INPUT_2

	CMP.L	#'    ',(A5)
	BEQ.S	.LA

	MOVE.B	#'.',(A2)+
	MOVE.B	#'B',(A2)+
	MOVE.B	#'N',(A2)+
	MOVE.B	#'K',(A2)+
	MOVE.B	#0,(A2)+

	BSR	FCREATE
	LEA	DEBUT_FICHIER,A0
	MOVE.L	#FIN_FICHIER,D0
	SUB.L	A0,D0
	SUBQ.L	#1,D0
	BSR	FWRITE
	BSR	FCLOSE

.LA	BSR	CORRECT_ENTER
	LEA	L_S_FILEN,A0
	BSR	PRINT_GDOS
	BSR	CORRECT_EXIT
	RTS
***************************************************************************
FCREATE	MOVE.W	#0,-(A7)
	PEA	FILENAME
	MOVE.W	#$3C,-(A7)
	TRAP	#1
	ADDQ.W	#8,A7
	MOVE.W	D0,HANDLE
	RTS
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
FWRITE	MOVE.L	A0,-(A7)
	MOVE.L	D0,-(A7)
	MOVE.W	HANDLE,-(A7)
	MOVE.W	#$40,-(A7)
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
NETTOYE
	BSR	CORRECT_ENTER

	LEA	CLS,A0
	BSR	PRINT_GDOS
	LEA	NET_MENU,A0
	BSR	PRINT_GDOS

	BSR	CORRECT_EXIT

N1	BSR	INPUT
	CMP.L	#0,D0
	BEQ.S	NET_F10

	CMP.L	#$3B0000,D0
	BNE.S	NET_F1
	BSR	NET_PHRASE
	BRA	N1

NET_F1	CMP.L	#$3C0000,D0
	BNE.S	NET_F2
	BSR	NET_QUEST
	BRA	N1

NET_F2	CMP.L	#$3D0000,D0
	BNE.S	NET_F3
	BSR	NET_SEQ
	BRA	N1

NET_F3	CMP.L	#$3E0000,D0
	BNE.S	NET_F4
	BSR	NET_BNK
	BRA	N1

NET_F4	CMP.L	#$440000,D0
	BNE.S	NET_F10
	BRA	SORTIE

NET_F10	LEA	NET_G,A0
	LEA	NET_D,A1
	BSR	POSMOUSE
	CMP.L	#-1,A2
	BEQ	N1
	CMP.L	#SORTIE,A2
	BEQ	SORTIE

	JSR	(A2)
	BRA	N1

*---------------------------------------------------------------------------
NET_PHRASE
	LEA	ARE_YOU_SURE,A0
	BSR	PRINT_GDOS

NET1	BSR	INPUT
	CMP.B	#'O',D0
	BEQ.S	T_P
	CMP.B	#'o',D0
	BEQ.S	T_P
	CMP.B	#'N',D0
	BEQ	GG
	CMP.B	#'n',D0
	BEQ	GG
	BRA	NET1

T_P	BSR	NET_P
	BRA	GG
*---------------------------------------------------------------------------
NET_QUEST
	LEA	ARE_YOU_SURE,A0
	BSR	PRINT_GDOS

NET2	BSR	INPUT
	CMP.B	#'O',D0
	BEQ.S	T_Q
	CMP.B	#'o',D0
	BEQ.S	T_Q
	CMP.B	#'N',D0
	BEQ	GG
	CMP.B	#'n',D0
	BEQ	GG
	BRA	NET2

T_Q	BSR	NET_Q
	BRA	GG
*---------------------------------------------------------------------------
NET_SEQ
	LEA	ARE_YOU_SURE,A0
	BSR	PRINT_GDOS

NET3	BSR	INPUT
	CMP.B	#'O',D0
	BEQ.S	T_S
	CMP.B	#'o',D0
	BEQ.S	T_S
	CMP.B	#'N',D0
	BEQ	GG
	CMP.B	#'n',D0
	BEQ	GG
	BRA	NET3

T_S	BSR	NET_S
	BRA	GG
*---------------------------------------------------------------------------
NET_BNK
	LEA	ARE_YOU_SURE,A0
	BSR	PRINT_GDOS

NET4	BSR	INPUT
	CMP.B	#'O',D0
	BEQ.S	T_B
	CMP.B	#'o',D0
	BEQ.S	T_B
	CMP.B	#'N',D0
	BEQ	GG
	CMP.B	#'n',D0
	BEQ	GG
	BRA	NET4

T_B	BSR	NET_P
	BSR	NET_Q
	BSR	NET_S
	LEA	NOM_BANQUE,A0
	MOVE.L	#'PAS ',(A0)
	MOVE.L	#'DE B',4(A0)
	MOVE.L	#'ANQU',8(A0)
	MOVE.L	#'E EN',12(A0)
	MOVE.L	#' MEM',16(A0)
	MOVE.L	#'OIRE',20(A0)
	BRA	GG
*---------------------------------------------------------------------------
NET_P	LEA	BNK_GREC,A0
	MOVEQ	#0,D0
	MOVE.W	MAX_GREC,D0
	SUBQ.W	#1,D0

.O1	REPT	80*4
	MOVE.B	#'_',(A0)+
	ENDR
	MOVE.B	#0,(A0)+
	DBF	D0,.O1
	RTS

*---------------------------------------------------------------------------
NET_Q	LEA	BNK_QUEST,A0
	MOVEQ	#0,D0
	MOVE.W	MAX_QUEST,D0
	SUBQ.W	#1,D0

.O5	MOVEQ	#80-1,D1
.O2	MOVE.B	#' ',(A0)+
	DBF	D1,.O2
	MOVE.B	#0,(A0)+

	MOVEQ	#9-1,D2
.O4	MOVEQ	#80-1,D1
.O3	MOVE.B	#' ',(A0)+
	DBF	D1,.O3
	MOVE.B	#$D,(A0)+
	MOVE.B	#$A,(A0)+
	DBF	D2,.O4
	LEA	-2(A0),A0
	MOVE.B	#0,(A0)+
	MOVE.B	#' ',(A0)+
	MOVE.B	#0,(A0)+

	DBF	D0,.O5
	RTS

*---------------------------------------------------------------------------
NET_S	LEA	BNK_POS,A0
	MOVEQ	#0,D0
	MOVE.W	MAX_POS,D0
	MULU	#46,D0
	SUBQ.W	#1,D0

.O6	MOVE.B	#-1,(A0)+
	DBF	D0,.O6
	RTS
	
GG	BSR	CORRECT_ENTER
	LEA	N_YOU_SURE,A0
	BSR	PRINT_GDOS
	BSR	CORRECT_EXIT
	RTS
***************************************************************************
NOMME	BSR	CORRECT_ENTER
	LEA	NOM_BANQUE,A2
	MOVE.L	#'    ',(A2)
	MOVE.L	#'    ',4(A2)
	MOVE.L	#'    ',8(A2)
	MOVE.L	#'    ',12(A2)
	MOVE.L	#'    ',16(A2)
	MOVE.L	#'    ',20(A2)
	MOVE.B	#' ',24(A2)

	LEA	L_NOM,A0
	BSR	PRINT_GDOS
	MOVE.L	A2,A0
	BSR	PRINT_GDOS
	BSR	CORRECT_EXIT

	MOVE.L	A2,A5
	LEA	24(A2),A6
	LEA	L_NOM,A4
	BSR	INPUT_2
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

STOP	BSR	CORRECT_ENTER
	MOVE.L	A4,A0
	BSR	PRINT_GDOS
	MOVE.L	A5,A0
	BSR	PRINT_GDOS
	BSR	CORRECT_EXIT
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
ELEVE
	BSR	CORRECT_ENTER
	BSR	INVERT_CURSOR

	LEA	L_22,A0
	BSR	PRINT_GDOS
	
	LEA	L_24_ELEVE,A0
	BSR	PRINT_GDOS
	MOVE.W	#1,PAS_CURS
	BSR	FF7
	

LOOP_ELEVE
	BSR	INPUT
	CMP.L	#0,D0
	BEQ	PM_ELEVE

	CMP.L	#$3C0000,D0
	BNE	E_F2
	BSR	F2			* + 1 GREC
	BRA	LOOP_ELEVE

E_F2	CMP.L	#$3D0000,D0
	BNE	E_F3
	BSR	F3			* - 1 GREC
	BRA	LOOP_ELEVE

E_F3	CMP.L	#$3E0000,D0
	BNE	E_F4
	BSR	F4			* + 1 QUEST
	BRA	LOOP_ELEVE

E_F4	CMP.L	#$3F0000,D0
	BNE	E_F5
	BSR	F5			* - 1 QUEST
	BRA	LOOP_ELEVE

E_F5	CMP.L	#$400000,D0
	BNE	E_F6
	BSR	F6			* + 1 POS
	BRA	LOOP_ELEVE

E_F6	CMP.L	#$410000,D0
	BNE	E_F7
	BSR	F7			* - 1 POS
	BRA	LOOP_ELEVE

E_F7	CMP.L	#$440000,D0
	BNE	E_F10
	BEQ	SORTIE

E_F10	CMP.L	#$0E0008,D0
	BNE	E_BACK
	BSR	ERASE_REPONSE
	BRA	LOOP_ELEVE

E_BACK	CMP.L	#$53007F,D0
	BNE	E_DEL
	BSR	ERASE_REPONSE
	BRA	LOOP_ELEVE

E_DEL	CMP.B	#$D,D0
	BNE.S	E_RET
	BSR	RETU
	BRA	LOOP_ELEVE

E_RET	BSR	CH_REPONSE
	BRA	LOOP_ELEVE


PM_ELEVE
	LEA	ELEVE_G,A0
	LEA	ELEVE_D,A1
	BSR	POSMOUSE
	CMP.L	#-1,A2
	BEQ	LOOP_ELEVE

	CMP.L	#SORTIE,A2
	BEQ	.SORT
	CMP.L	#EDITE,A2
	BEQ	EDITE

	JSR	(A2)
	BRA	LOOP_ELEVE

.SORT	MOVE.W	#0,PAS_CURS
	RTS
***************************************************************************
RETU	BSR	INSERT_E
	BSR	CORRECT_ENTER

	ADDQ.W	#1,NU_POS
	MOVE.W	NU_POS,D1
	CMP.W	MAX_POS,D1
	BLT	FF8
	MOVE.W	#0,NU_POS
	BRA	FF8

FF8	LEA	L_POS,A0
	BSR	PRINT_GDOS
	MOVEQ	#0,D0
	MOVE.W	NU_POS,D0
	ADDQ.W	#1,D0
	BSR	CONVERT
	LEA	NOMBRE,A0
	BSR	PRINT_GDOS

	MOVE.W	NU_POS,D0
	MULU	#46,D0
	LEA	BNK_POS,A0
	LEA	(A0,D0.W),A0

	MOVE.W	(A0)+,D1
	CMP.W	#-1,D1
	BEQ.S	.P1
	MOVE.W	D1,NU_GREC

.P1	MOVE.W	(A0)+,D1
	CMP.W	#-1,D1
	BEQ.S	.P2
	MOVE.W	D1,NU_QUEST

.P2	MOVE.W	#'  ',REPONSE

	LEA	WORD_TAB,A1
	CMP.L	#-1,(A1)
	BEQ.S	.FILL

	MOVEQ	#9,D0
.O1	MOVE.L	(A0)+,(A1)+
	DBF	D0,.O1
	BRA	.SUM

.FILL	MOVEQ	#9,D0
.O2	MOVE.L	#-1,(A1)+
	DBF	D0,.O2

.SUM	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	AFFICHE_PARAGRAPHE_QUEST
	BSR	PRINT_REPONSE
	BSR	INVERT_FOUND_WORD
	BSR	CORRECT_EXIT
	RTS
***************************************************************************
INSERT_E
	BSR	CORRECT_ENTER
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	NU_POS,D0
	MOVE.W	MAX_POS,D1
	MOVE.W	MAX_POS,D2
	SUB.W	D0,D1
	SUBQ.W	#2,D1
	MULU	#46,D0
	MULU	#46,D2
	LEA	BNK_POS,A0
	LEA	BNK_POS,A2
	LEA	(A0,D0.W),A0
	LEA	(A2,D2.W),A2
	LEA	-46(A2),A1
	
.O2	REPT	11
	MOVE.L	-(A1),-(A2)
	ENDR
	MOVE.W	-(A1),-(A2)
	DBF	D1,.O2

	BRA.S	INSERT_E1
***************************************************************************
OVERSTRIKE_E
	BSR	CORRECT_ENTER

	MOVEQ	#0,D0
	MOVE.W	NU_POS,D0
	MULU	#46,D0
	LEA	BNK_POS,A0
	LEA	(A0,D0.W),A0

INSERT_E1
	MOVE.W	NU_GREC,(A0)+
	MOVE.W	NU_QUEST,(A0)+
	CMP.B	#'0',REPONSE
	BNE.S	.P1
	MOVE.B	#' ',REPONSE

.P1	MOVE.W	REPONSE,(A0)+
	LEA	WORD_TAB,A1
	MOVEQ	#9,D0
.O1	MOVE.L	(A1)+,(A0)+
	DBF	D0,.O1

	BSR	CORRECT_EXIT
	RTS
***************************************************************************
DELETE_E
	BSR	CORRECT_ENTER
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	NU_POS,D0
	MOVE.W	MAX_POS,D1
	SUB.W	D0,D1
	SUBQ.W	#2,D1
	MULU	#46,D0
	LEA	BNK_POS,A0
	LEA	(A0,D0.W),A0
	LEA	46(A0),A1
	
.O2	REPT	11
	MOVE.L	(A1)+,(A0)+
	ENDR
	MOVE.W	(A1)+,(A0)+
	DBF	D1,.O2
	BSR	CORRECT_EXIT
	RTS
***************************************************************************
ERASE_REPONSE
	BSR	CORRECT_ENTER
	MOVE.W	#'  ',REPONSE
	BSR	PRINT_REPONSE
	BSR	CORRECT_EXIT
	RTS
***************************************************************************
CH_REPONSE
	BSR	CORRECT_ENTER
	MOVE.B	REPONSE+1,REPONSE
	MOVE.B	D0,REPONSE+1
	BSR	PRINT_REPONSE
	BSR	CORRECT_EXIT
	RTS
***************************************************************************
PRINT_REPONSE
	LEA	L_REP,A0
	BSR	PRINT_GDOS
	LEA	REPONSE,A0
	BSR	PRINT_GDOS
	RTS
***************************************************************************
FIND_WORD
	BSR	CORRECT_ENTER

	MOVE.W	X,SX
	MOVE.W	Y,SY

	MOVEQ	#0,D2
	MOVE.W	XMOUSE,D0
	DIVU	#8,D0
	AND.L	#$FFFF,D0
	MOVE.W	NB_LINE,D2
	ADDQ.W	#1,D2
	MOVE.W	YMOUSE,D1
	DIVU	D2,D1
	AND.L	#$FFFF,D1
	MOVE.W	D0,X
	MOVE.W	D0,SX1
	MOVE.W	D1,Y
	MOVE.W	D1,SY1
	SUBQ.W	#2,D1

	MULU	#80,D1
	MOVE.L	CURENT_GREC,A0
	ADD.W	D1,A0
	ADD.W	D0,A0
	MOVE.L	A0,A2

A_DROITE
	MOVE.B	(A0),D0

	CMP.B	#'A',D0
	BLT.S	.MINUS
	CMP.B	#'Z',D0
	BGT.S	.MINUS
	BRA.S	GOOD

.MINUS	CMP.B	#'a',D0
	BLT.S	A_GAUCHE
	CMP.B	#'z',D0
	BGT.S	A_GAUCHE

GOOD	BSR	INVERT_CURSOR
	ADDQ.W	#1,A0
	ADDQ.W	#1,X
	CMP.W	#80,X
	BNE.S	A_DROITE
	MOVE.W	#0,X
	ADDQ.W	#1,Y
	BRA.S	A_DROITE

A_GAUCHE
	MOVE.W	SX1,X
	MOVE.W	SY1,Y

GAUCH	MOVE.B	(A2),D0
	CMP.B	#'A',D0
	BLT.S	.MINUS1
	CMP.B	#'Z',D0
	BGT.S	.MINUS1
	BRA.S	GOOD1

.MINUS1	CMP.B	#'a',D0
	BLT.S	WORD_FOUND
	CMP.B	#'z',D0
	BGT.S	WORD_FOUND

GOOD1	BSR	INVERT_CURSOR
	SUBQ.W	#1,A2
	SUBQ.W	#1,X
	CMP.W	#-1,X
	BNE	GAUCH
	MOVE.W	#79,X
	SUBQ.W	#1,Y
	BRA	GAUCH

WORD_FOUND
	CMP.L	A0,A2
	BEQ	FIN_WORD

	MOVE.W	SX1,X
	MOVE.W	SY1,Y
	BSR	INVERT_CURSOR

	MOVE.W	#0,CONTE

CONT_CHAR
	MOVE.B	(A2),D0
	CMP.B	#0,D0
	BEQ.S	CONTE_FOUND
	CMP.B	#'A',D0
	BLT.S	.MINUS2
	CMP.B	#'Z',D0
	BGT.S	.MINUS2
	BRA.S	IT_S_A_CHAR

.MINUS2	CMP.B	#'a',D0
	BLT.S	OTHER
	CMP.B	#'z',D0
	BGT.S	OTHER
	BRA.S	IT_S_A_CHAR
	
OTHER	ADDQ.W	#1,CONTE

IT_S_A_CHAR
	SUBQ.W	#1,A2
	BRA	CONT_CHAR

CONTE_FOUND
	LEA	WORD_TAB,A0
	MOVEQ	#40-1,D0
	MOVE.W	CONTE,D1
	*SUBQ.W	#2,D1

.O1	CMP.B	(A0)+,D1
	BEQ.S	DEJA_DANS_LA_TABLE
	DBF	D0,.O1

	MOVEQ	#40-1,D0
	LEA	WORD_TAB,A0

.O2	CMP.B	#-1,(A0)+
	BEQ.S	OK_KAY
	DBF	D0,.O2

OK_KAY	MOVE.B	D1,-1(A0)
	BRA	FIN_WORD
	
DEJA_DANS_LA_TABLE
	MOVE.B	(A0),-1(A0)
	ADDQ.W	#1,A0
	DBF	D0,DEJA_DANS_LA_TABLE
	MOVE.B	#-1,-2(A0)

FIN_WORD
	MOVE.W	SX,X
	MOVE.W	SY,Y
	BSR	CORRECT_EXIT
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
WAITT	MOVE.W	#1,WAIT
.WW1	CMP.W	#1,WAIT
	BEQ.S	.WW1
	RTS
***************************************************************************
EDITE	
	BSR	CORRECT_ENTER

	MOVE.W	#0,PAS_CURS
	LEA	CLS,A0
	BSR	PRINT_GDOS
	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	AFFICHE_PARAGRAPHE_QUEST

	LEA	L_24_EDIT,A0
	BSR	PRINT_GDOS

	BSR	WAITT
	BSR	FOND2
	MOVE.W	#0,OKP

LOOP	BSR	INPUT
	CMP.L	#0,D0
	BEQ	PM

	CMP.L	#$3B0000,D0
	BNE	N_F1
	BSR	F1			* TOGGLE GREC/QUEST
	BRA	LOOP

N_F1	CMP.L	#$3C0000,D0
	BNE	N_F2
	BSR	F2			* + 1 GREC
	BRA	LOOP

N_F2	CMP.L	#$3D0000,D0
	BNE	N_F3
	BSR	F3			* - 1 GREC
	BRA	LOOP

N_F3	CMP.L	#$3E0000,D0
	BNE	N_F4
	BSR	F4			* + 1 QUEST
	BRA	LOOP

N_F4	CMP.L	#$3F0000,D0
	BNE	N_F5
	BSR	F5			* - 1 QUEST
	BRA	LOOP

N_F5	CMP.L	#$440000,D0
	BNE	N_F10
	BEQ	SORTIE			* F10 = SORTIE
	
N_F10	CMP.L	#$480000,D0
	BNE	N_UP
	BSR	UP
	BRA	LOOP

N_UP	CMP.L	#$500000,D0
	BNE	N_DOWN
	BSR	DOWN
	BRA	LOOP

N_DOWN	CMP.L	#$4B0000,D0
	BNE	N_LEFT
	BSR	LEFT
	BRA	LOOP

N_LEFT	CMP.L	#$4D0000,D0
	BNE	N_RIGHT
	BSR	RIGHT
	BRA	LOOP
	
N_RIGHT	CMP.L	#$53007F,D0
	BNE	N_DELETE
	BSR	DELETE
	BRA	LOOP

N_DELETE
	CMP.L	#$0E0008,D0
	BNE	N_BACKSPACE
	BSR	BACKSPACE
	BRA	LOOP
	
N_BACKSPACE
	CMP.W	#$D,D0
	BNE	N_RETURN
	BSR	RETURN
	BRA	LOOP

N_RETURN
	BSR	CHAR

*	CMP.B	#'A',D0
*	BLT	PAS_CAPITAL
*	CMP.B	#'Z',D0
*	BGT	PAS_CAPITAL
*	BSR	CHAR
*	BRA	LOOP
*	
*PAS_CAPITAL
*	CMP.B	#'a',D0
*	BLT	PAS_MINUSCUL
*	CMP.B	#'z',D0
*	BGT	PAS_MINUSCUL
*	BSR	CHAR
*	BRA	LOOP
*	
*PAS_MINUSCUL
*	CMP.B	#'0',D0
*	BLT	PAS_CHIFFRE
*	CMP.B	#'9',D0
*	BGT	PAS_CHIFFRE
*	BSR	CHAR
*	BRA	LOOP
*	
*PAS_CHIFFRE	
*	CMP.B	#" ",D0
*	BEQ	CHAR
*	CMP.B	#".",D0
*	BEQ	CHAR
*	CMP.B	#",",D0
*	BEQ	CHAR
*	CMP.B	#"'",D0
*	BEQ	CHAR
*	CMP.B	#";",D0
*	BEQ	CHAR
*	CMP.B	#"?",D0
*	BEQ	CHAR
*	CMP.B	#";",D0
*	BEQ	CHAR
*	CMP.B	#"Ç",D0
*	BEQ	CHAR
*	CMP.B	#"ê",D0
*	BEQ	CHAR
*	CMP.B	#"ä",D0
*	BEQ	CHAR
*	CMP.B	#"Ö",D0
*	BEQ	CHAR
*	CMP.B	#"∂",D0
*	BEQ	CHAR
*	CMP.B	#"ó",D0
*	BEQ	CHAR
*	CMP.B	#"(",D0
*	BEQ	CHAR
*	CMP.B	#")",D0
*	BEQ	CHAR
*	CMP.B	#"-",D0
*	BEQ	CHAR
*	CMP.B	#"+",D0
*	BEQ	CHAR
*	CMP.B	#"*",D0
*	BEQ	CHAR

PM	LEA	EDIT_G,A0
	LEA	EDIT_D,A1
	BSR	POSMOUSE
	CMP.L	#-1,A2
	BEQ	LOOP

	CMP.L	#SORTIE,A2
	BEQ.S	SORTIE
	CMP.L	#ELEVE,A2
	BEQ	ELEVE

	JSR	(A2)
	BRA	LOOP
	
SORTIE	RTS
	
***************************************************************************
CORRECT_EXIT
	BSR	WAITT
	BSR	FOND2
	MOVE.W	#0,OKP
	RTS
CORRECT_ENTER
	MOVE.W	#1,OKP
	BSR	WAITT
	BSR	RESTITU
	RTS
***************************************************************************
CHAR
	BSR	CORRECT_ENTER

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

	BRA	CORRECT_EXIT

	
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
	BRA	CORRECT_EXIT
	
	
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
Z2	*BSR	FIND
	MOVE.B	D0,(A0)
	
	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	INC_ONE_X_CURSOR
	BRA	CORRECT_EXIT
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

	BSR	CORRECT_ENTER

	MOVEQ	#0,D0
	MOVEQ	#0,D1
	CMP.W	#11,Y
	BLT	BACK_GREC
	BGT	BACK_QUEST


	CMP.W	#0,X
	BEQ	CORRECT_EXIT
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
	BRA	CORRECT_EXIT

BACK_GREC
	CMP.W	#0,X
	BNE.S	Z6
	CMP.W	#2,Y
	BEQ	CORRECT_EXIT
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
	BRA	CORRECT_EXIT
	
BACK_QUEST
	CMP.W	#0,X
	BEQ	CORRECT_EXIT
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
	BRA	CORRECT_EXIT
***************************************************************************
DELETE	
	BSR	CORRECT_ENTER

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
	BRA	CORRECT_EXIT

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
	BRA	CORRECT_EXIT
	
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
	BRA	CORRECT_EXIT
***************************************************************************
LEFT	
	BSR	CORRECT_ENTER

	MOVE.W	X,D0
	MOVE.W	Y,D1
	SUBQ.W	#1,D0
	CMP.W	#-1,D0
	BNE.S	LEFT1
	MOVE.W	#79,D0
LEFT1	BSR	CURSOR
	BRA	CORRECT_EXIT
***************************************************************************
RIGHT	
	BSR	CORRECT_ENTER

	MOVE.W	X,D0
	MOVE.W	Y,D1
	ADDQ.W	#1,D0
	CMP.W	#80,D0
	BNE.S	RIGHT1
	MOVE.W	#0,D0
RIGHT1	BSR	CURSOR
	BRA	CORRECT_EXIT
***************************************************************************
UP	
	BSR	CORRECT_ENTER

	MOVE.W	X,D0
	MOVE.W	Y,D1
	CMP.W	#8,D1
	BGE.S	UP_QUEST
	
	SUBQ.W	#1,D1
	CMP.W	#1,D1
	BNE.S	UP1
	MOVE.W	#5,D1
UP1	BSR	CURSOR
	BRA	CORRECT_EXIT
	
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
	BRA	CORRECT_EXIT
***************************************************************************
DOWN	
	BSR	CORRECT_ENTER

	MOVE.W	X,D0
	MOVE.W	Y,D1
	CMP.W	#8,D1
	BGE.S	DOWN_QUEST
	
	ADDQ.W	#1,D1
	CMP.W	#6,D1
	BNE.S	DOWN1
	MOVE.W	#2,D1
DOWN1	BSR	CURSOR
	BRA	CORRECT_EXIT
	
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
	BRA	CORRECT_EXIT
***************************************************************************
RETURN	
	BSR	CORRECT_ENTER

	MOVE.W	X,D0
	MOVE.W	Y,D1
	CMP.W	#8,D1
	BGE.S	RDOWN_QUEST
	
	ADDQ.W	#1,D1
	CMP.W	#6,D1
	BNE.S	RDOWN1
	MOVE.W	#5,D1
RDOWN1	MOVE.W	#0,D0
	BSR	CURSOR
	BRA	CORRECT_EXIT
	
RDOWN_QUEST
	ADDQ.W	#1,D1
	CMP.W	#12,D1
	BEQ.S	RDOWN2
	CMP.W	#22,D1
	BEQ.S	RDOWN3
	BRA.S	RDOWN4
RDOWN2	MOVE.W	#13,D1
	BRA.S	RDOWN4
RDOWN3	MOVE.W	#21,D1
RDOWN4	MOVE.W	#0,D0
	BSR	CURSOR
	BRA	CORRECT_EXIT
***************************************************************************
PLACE_CURSOR
	BSR	CORRECT_ENTER

	MOVE.W	XMOUSE,D0
	DIVU	#8,D0
	AND.L	#$FFFF,D0
	MOVE.W	NB_LINE,D2
	ADDQ.W	#1,D2
	MOVE.W	YMOUSE,D1
	DIVU	D2,D1
	AND.L	#$FFFF,D1
	BSR	CURSOR
	BRA	CORRECT_EXIT
***************************************************************************
F1	
	BSR	CORRECT_ENTER

	CMP.W	#7,Y
	BLE.S	TO_QUEST
	
	MOVE.W	#0,D0
	MOVE.W	#2,D1
	BSR	CURSOR
	BRA	CORRECT_EXIT
	
TO_QUEST
	MOVE.W	#0,D0
	MOVE.W	#11,D1
	BSR	CURSOR
	BRA	CORRECT_EXIT
***************************************************************************
F2	
	BSR	CORRECT_ENTER
	ADDQ.W	#1,NU_GREC
	MOVE.W	NU_GREC,D1
	CMP.W	MAX_GREC,D1
	BLT.S	FF2
	MOVE.W	#0,NU_GREC
FF2	BSR	AFFICHE_PARAGRAPHE_GREC
	BRA	CORRECT_EXIT
***************************************************************************
F3	
	BSR	CORRECT_ENTER
	SUBQ.W	#1,NU_GREC
	CMP.W	#-1,NU_GREC
	BNE	FF3
	MOVE.W	MAX_GREC,NU_GREC
	SUBQ.W	#1,NU_GREC
FF3	BSR	AFFICHE_PARAGRAPHE_GREC
	BRA	CORRECT_EXIT
***************************************************************************
F4
	BSR	CORRECT_ENTER
	ADDQ.W	#1,NU_QUEST
	MOVE.W	NU_QUEST,D1
	CMP.W	MAX_QUEST,D1
	BLT.S	FF4
	MOVE.W	#0,NU_QUEST
FF4	BSR	AFFICHE_PARAGRAPHE_QUEST
	BRA	CORRECT_EXIT
***************************************************************************
F5
	BSR	CORRECT_ENTER
	SUBQ.W	#1,NU_QUEST
	CMP.W	#-1,NU_QUEST
	BNE	FF5
	MOVE.W	MAX_QUEST,NU_QUEST
	SUBQ.W	#1,NU_QUEST
FF5	BSR	AFFICHE_PARAGRAPHE_QUEST
	BRA	CORRECT_EXIT
***************************************************************************
F6	
	BSR	CORRECT_ENTER
	ADDQ.W	#1,NU_POS
	MOVE.W	NU_POS,D1
	CMP.W	MAX_POS,D1
	BLT	FF7
	MOVE.W	#0,NU_POS
	BRA	FF7
***************************************************************************
F7
	BSR	CORRECT_ENTER
	SUBQ.W	#1,NU_POS
	CMP.W	#-1,NU_POS
	BNE	FF7
	MOVE.W	MAX_POS,NU_POS
	SUBQ.W	#1,NU_POS

FF7	LEA	L_POS,A0
	BSR	PRINT_GDOS
	MOVEQ	#0,D0
	MOVE.W	NU_POS,D0
	ADDQ.W	#1,D0
	BSR	CONVERT
	LEA	NOMBRE,A0
	BSR	PRINT_GDOS

	MOVE.W	NU_POS,D0
	MULU	#46,D0
	LEA	BNK_POS,A0
	LEA	(A0,D0.W),A0
	MOVE.W	(A0)+,NU_GREC
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
.P3	LEA	WORD_TAB,A1
	MOVEQ	#9,D0
.O1	MOVE.L	(A0)+,(A1)+
	DBF	D0,.O1

	BSR	AFFICHE_PARAGRAPHE_GREC
	BSR	AFFICHE_PARAGRAPHE_QUEST
	BSR	PRINT_REPONSE
	BSR	INVERT_FOUND_WORD
	BRA	CORRECT_EXIT
PAS_CURS	DC.W	0
***************************************************************************
AFFICHE_POS		* GREC + QUEST
	RTS
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

	CMP.W	#1,PAS_CURS
	BEQ.S	.PP
	BSR	INVERT_CURSOR
.PP	RTS
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

	CMP.W	#1,PAS_CURS
	BEQ.S	.OO
	BSR	INVERT_CURSOR
.OO	RTS
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
	BEQ	CAPS_LOCK
	CMP.B	#$38,D0
	BEQ	ALTERNATE_D
	CMP.B	#$38+128,D0
	BEQ	ALTERNATE_U
	CMP.B	#$1D,D0
	BEQ	CONTROLE_D
	CMP.B	#$1D+128,D0
	BEQ	CONTROLE_U

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


	CMP.W	#0,CONTRO
	BEQ.S	N_CONTROLE
	LEA	CONTROLE,A1
	BRA	ENC

N_CONTROLE
	CMP.W	#0,ALTERN
	BEQ.S	N_ALTERNATE
	CMP.W	#0,SHIFT
	BNE.S	ALT_SHIFT
	LEA	ALTERNATE_MIN,A1
	BRA	ENC
ALT_SHIFT
	LEA	ALTERNATE_MAJ,A1
	BRA	ENC

N_ALTERNATE
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
ALTERN		DC.W	0
CONTRO		DC.W	0
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
CAPS_LOCK
	BCHG	#0,SHIFT
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	BRA	FINDESCODES
***************************************************************************
ALTERNATE_U
	MOVE.W	#0,ALTERN
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	BRA	FINDESCODES
***************************************************************************
ALTERNATE_D
	MOVE.W	#1,ALTERN
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	BRA	FINDESCODES
***************************************************************************
CONTROLE_U
	MOVE.W	#0,CONTRO
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	BRA	FINDESCODES
***************************************************************************
CONTROLE_D
	MOVE.W	#1,CONTRO
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
FIND	RTS

	CMP.B	#'A',D0
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
	
.OUT1	*ADD.B	#127,D0
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
	
.OUT2	*ADD.B	#127-8,D0
FINO	RTS
***************************************************************************
TABLE_MAJ	DC.B	'A','A','B','B','C','C','D','D','E','E','F','F'
		DC.B	0,0
TABLE_MIN	DC.B	'a','a','b','b','c','c','d','d','e','e','f','f'
		DC.B	0,0		
***************************************************************************
*	Table of scancode to AZERTY
SCANCODE_MAJ
	DC.B	$3B,0,$3C,0,$3D,0,$3E,0,$3F,0,$40,0,$41,0,$42,0,$43,0,$44,0,$48,0,$4B,0,$4D,0,$50,0,$53,$7F
	DC.B	$02,'®',$03,'ê',$04,'"',$05,"'",$06,'(',$08,'ä',$09,'≠',$0A,'Ä',$0B,'∂',$0C,')',$0D,'_',$0E,8

	DC.B	$10,'A',$11,'Z',$12,'E',$13,'R',$14,'T',$15,'Y',$16,'U',$17,'I',$18,'O',$19,'P',$1A,'•',$1B,'û'
	DC.B    $1E,'Q',$1F,'S',$20,'D',$21,'F',$22,'G',$23,'H',$24,'J',$25,'K',$26,'L',$27,'M',$28,'ó'
	DC.B	$2C,'W',$2D,'X',$2E,'C',$2F,'V',$30,'B',$31,'N',$32,'?',$33,'.',$34,'/',$35,'+'
	
	DC.B	$6D,'1',$6E,'2',$6F,'3',$6A,'4',$6B,'5',$6C,'6',$67,'7',$68,'8',$69,'9',$70,'0',$66,'*'
	DC.B	$4A,'-',$4E,'+',$63,'(',$64,')',$65,'/',$66,'/'
	DC.B	$1C,$D,$72,$D,$71,'.',$33,'.',$39,' ',$28,'\'
	DC.B	-1,-1
	
SCANCODE_MIN
	DC.B	$3B,0,$3C,0,$3D,0,$3E,0,$3F,0,$40,0,$41,0,$42,0,$43,0,$44,0,$48,0,$4B,0,$4D,0,$50,0,$53,$7F
	DC.B	$02,'&',$03,'Ç',$04,'"',$05,"'",$06,'(',$08,'ä',$09,'!',$0A,'á',$0B,'Ö',$0C,')',$0D,'-',$0E,8
	
	DC.B	$10,'a',$11,'z',$12,'e',$13,'r',$14,'t',$15,'y',$16,'u',$17,'i',$18,'o',$19,'p',$1A,'§',$1B,'ü'
	DC.B    $1E,'q',$1F,'s',$20,'d',$21,'f',$22,'g',$23,'h',$24,'j',$25,'k',$26,'l',$27,'m',$28,'ó'
	DC.B	$2C,'w',$2D,'x',$2E,'c',$2F,'v',$30,'b',$31,'n',$32,',',$33,';',$34,':',$35,'='
	
	DC.B	$6D,'1',$6E,'2',$6F,'3',$6A,'4',$6B,'5',$6C,'6',$67,'7',$68,'8',$69,'9',$70,'0',$66,'*'
	DC.B	$4A,'-',$4E,'+',$63,'(',$64,')',$65,'/',$66,'/'
	DC.B	$1C,$D,$72,$D,$71,'.',$33,'.',$39,' ',$28,'\'
	DC.B	-1,-1

ALTERNATE_MIN
	DC.B	$09,'≠'
	DC.B	$10,'Ñ',$12,'â',$15,'ò',$16,'Å',$17,'ã',$18,'î'
	DC.B	$21,'ü'
	DC.B	$30,'û',$31,'§'
	DC.B	$32,'®'
	DC.B	-1,-1

ALTERNATE_MAJ
	DC.B	$09,'≠'
	DC.B	$10,'é',$12,'â',$15,'ò',$16,'ö',$17,'ã',$18,'ô'
	DC.B	$21,'ü'
	DC.B	$30,'û',$31,'•'
	DC.B	$32,'®'
	DC.B	-1,-1

CONTROLE
	DC.B	$10,'É',$11,'Ü',$12,'à',$13,'å',$14,'ç',$15,'è',$16,'ë',$17,'í',$18,'ì',$19,'ï'
	DC.B    $1E,'ï',$1F,'ñ',$20,'ó',$21,'†',$22,'°',$23,'¢',$24,'£',$25,'∞',$26,'±',$27,'≤',$28,'≥'
	DC.B	$2C,'¥',$2D,'µ',$2E,'∂',$2F,'∑',$30,'∏',$31,'¿',$32,'¡'
	DC.B	-1,-1
***************************************************************************
POSMOUSE
	CMP.B	#4,KM			*Bouton gauche
	BEQ.S	.ZA3
	CMP.B	#2,KM			*Bouton droit
	BEQ.S	.ZA2
	BRA.S	.FINITO

.ZA2	MOVE.L	A1,A0
.ZA3	MOVE.B	#0,KM
	MOVE.W	XMOUSE,D4
	DIVU	#8,D4
	AND.L	#$FFFF,D4		* D4 = X (EN CARACTERE)
	MOVE.W	YMOUSE,D5
	MOVE.W	NB_LINE,D6
	ADDQ.W	#1,D6
	DIVU	D6,D5
	AND.L	#$FFFF,D5		* D5 = Y (EN CARACTERE)

.SUITE	MOVE.L	(A0)+,D0		*X min
	MOVE.L	(A0)+,D1		*Y min
	MOVE.L	(A0)+,D2		*X max
	MOVE.L	(A0)+,D3		*Y max
	MOVE.L	(A0)+,A2		*JUMP
	CMP.W	#-1,d0
	BEQ.S	.FINITO
	CMP.W	D4,D0
	BGT.S	.non
	CMP.W	D4,D2
	BLT.S	.non
	CMP.W	D5,D1
	BGT.S	.non
	CMP.W	D5,D3
	BLT.S	.non
	RTS
	
.non	BRA	.SUITE

.FINITO	MOVE.L	#-1,A2
	RTS


MENU_G	DC.L	0,7,80,7,CHARGE
	DC.L	0,9,80,9,EDITE
	DC.L	0,11,80,11,SAUVE
	DC.L	0,13,80,13,NETTOYE
	DC.L	0,17,80,17,NOMME
	DC.L	0,19,80,19,CHANGE_FONT
	DC.L	0,21,80,21,SORTIE
	DC.L	-1

MENU_D	DC.L	0,7,80,7,CHARGE
	DC.L	0,9,80,9,EDITE
	DC.L	0,11,80,11,SAUVE
	DC.L	0,13,80,13,NETTOYE
	DC.L	0,17,80,17,NOMME
	DC.L	0,19,80,19,CHANGE_FONT
	DC.L	0,21,80,21,SORTIE
	DC.L	-1

EDIT_G	DC.L	0,0,15,0,F3
	DC.L	0,9,15,9,F5
	DC.L	0,2,79,5,PLACE_CURSOR
	DC.L	0,11,79,11,PLACE_CURSOR
	DC.L	0,13,79,21,PLACE_CURSOR
	DC.L	0,24,5,24,SORTIE
	DC.L	9,24,17,24,ELEVE
	DC.L	-1

EDIT_D	DC.L	0,0,15,0,F2
	DC.L	0,9,15,9,F4
	DC.L	0,2,79,5,PLACE_CURSOR
	DC.L	0,11,79,11,PLACE_CURSOR
	DC.L	0,13,79,21,PLACE_CURSOR
	DC.L	0,24,5,24,SORTIE
	DC.L	9,24,17,24,ELEVE
	DC.L	-1

ELEVE_G	DC.L	0,0,15,0,F3
	DC.L	0,9,15,9,F5
	DC.L	38,24,52,24,F7
	DC.L	0,2,79,5,FIND_WORD
	DC.L	0,24,5,24,SORTIE
	DC.L	9,24,13,24,EDITE
	DC.L	18,24,24,24,INSERT_E
	DC.L	26,24,35,24,DELETE_E
	DC.L	-1

ELEVE_D	DC.L	0,0,15,0,F2
	DC.L	0,9,15,9,F4
	DC.L	38,24,52,24,F6
	DC.L	0,2,79,5,FIND_WORD
	DC.L	0,24,5,24,SORTIE
	DC.L	9,24,13,24,EDITE
	DC.L	18,24,24,24,OVERSTRIKE_E
	DC.L	26,24,35,24,DELETE_E
	DC.L	-1

NET_G	DC.L	0,7,80,7,NET_PHRASE
	DC.L	0,9,80,9,NET_QUEST
	DC.L	0,11,80,11,NET_SEQ
	DC.L	0,13,80,13,NET_BNK
	DC.L	0,15,80,15,SORTIE
	DC.L	-1

NET_D	DC.L	0,7,80,7,NET_PHRASE
	DC.L	0,9,80,9,NET_QUEST
	DC.L	0,11,80,11,NET_SEQ
	DC.L	0,13,80,13,NET_BNK
	DC.L	0,15,80,15,SORTIE
	DC.L	-1
***************************************************************************
INIT	MOVE.L	$44E.W,A0
	MOVE.L	#32000/4-1,D0
ICI3	CLR.L	(A0)+
	DBF	D0,ICI3
	
	MOVE.L	$42E.W,LIMIT
	SUB.L	#160,LIMIT

	
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
	BSR	FOND2
	MOVE.L	#MY_70,$70.W
	MOVE.L	#MY_118,$118.W
	MOVE.L	#MY_134,$134.W
	MOVE.W	(A7)+,SR	
	RTS
	
MY_134	RTE
***************************************************************************
MY_70	MOVEM.L	D0-A6,-(A7)
	MOVE.B	#$D,$FFFFFC02.W
	
	CMP.W	#0,OKP
	BNE.S	FIN_70
	BSR	RESTITU
	BSR	FOND2
	BSR	AFFMOUSE
	
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
FOND2
	MOVEM.L	D0-D1/A0-A1,-(A7)
	CMP.W	#1,OFFSET
	BEQ	FOND_MONO
	
	MOVEQ	#0,D1
	LEA	FOND,A0
	MOVE.W	XMOUSE,D0
	MOVE.W	D0,X2
	MOVE.W	YMOUSE,D1
	MOVE.W	D0,X_OFFS
	AND.W	#$F,X_OFFS
	AND.L	#$3F0,D0
	LSR.W	#2,D0
	MULU	#160,D1
	MOVE.L	D1,Y2
	MOVE.L	$44E.W,A1
	ADD.W	D0,A1
	ADD.L	D1,A1
	MOVE.L	A1,(A0)+
	MOVEQ	#14,D0
.SAUVE	
	MOVE.W	(A1),(A0)+
	MOVE.W	2(A1),(A0)+
	MOVE.W	4(A1),(A0)+
	MOVE.W	6(A1),(A0)+
	ADD.W	#160,A1
	CMP.L	LIMIT,A1
	BGT.S	.EX3
	DBF	D0,.SAUVE
.EX3	MOVEM.L	(A7)+,D0-D1/A0-A1
	RTS
	
FOND_MONO
	MOVEQ	#0,D1
	LEA	FOND,A0
	MOVE.W	XMOUSE,D0
	MOVE.W	D0,X2
	MOVE.W	YMOUSE,D1
	MOVE.W	D0,X_OFFS
	AND.W	#$F,X_OFFS
	AND.L	#$3F0,D0
	LSR.W	#3,D0
	MULU	#80,D1
	MOVE.L	D1,Y2
	MOVE.L	$44E.W,A1
	ADD.W	D0,A1
	ADD.L	D1,A1
	MOVE.L	A1,(A0)+
	MOVEQ	#14,D0
.SAUVE2
	MOVE.W	(A1),(A0)+
	MOVE.W	2(A1),(A0)+
	ADD.W	#80,A1
	CMP.L	LIMIT,A1
	BGT.S	.EX7
	DBF	D0,.SAUVE2
.EX7	MOVEM.L	(A7)+,D0-D1/A0-A1
	RTS	
***************************************************************************
RESTITU
	MOVEM.L	D0/A0-A1,-(A7)
	CMP.W	#1,OFFSET
	BEQ	RESTITU_MONO
	
	LEA	FOND,A0
	MOVE.L	(A0)+,A1		* ADDR
	MOVEQ	#14,D0
.REST	MOVE.W	(A0)+,(A1)
	MOVE.W	(A0)+,2(A1)
	MOVE.W	(A0)+,4(A1)
	MOVE.W	(A0)+,6(A1)
	ADD.W	#160,A1

	CMP.L	LIMIT,A1
	BGT.S	.EX2

	DBF	D0,.REST
.EX2	MOVEM.L	(A7)+,D0/A0-A1
	RTS

RESTITU_MONO
	LEA	FOND,A0
	MOVE.L	(A0)+,A1
	MOVEQ	#14,D0
.REST2	MOVE.W	(A0)+,(A1)
	MOVE.W	(A0)+,2(A1)
	ADD.W	#80,A1
	CMP.L	LIMIT,A1
	BGT.S	.EX6
	DBF	D0,.REST2
.EX6	MOVEM.L	(A7)+,D0/A0-A1
	RTS
***************************************************************************
AFFMOUSE
	MOVEM.L	D4/D6/D7/A1/A3,-(A7)
	CMP.W	#1,OFFSET
	BEQ	AFFMOUSE_MONO

	LEA	MOUSEDAT,A3
	MOVE.L	FOND,A1
	MOVE.W	X_OFFS,D7
	MOVEQ	#14,D6
.AFF1	MOVEQ	#0,D4
	MOVE.L	(A3)+,D4
	ROR.L	D7,D4
	AND.W	D4,(A1)
	AND.W	D4,2(A1)
	NOT.W	D4
	OR.W	D4,(A1)
	OR.W	D4,2(A1)
	SWAP	D4
	AND.W	D4,4(A1)
	AND.W	D4,6(A1)
	NOT.W	D4
	OR.W	D4,4(A1)
	OR.W	D4,6(A1)
	ADD.W	#160,A1

	CMP.L	LIMIT,A1
	BGT.S	.EX1

	DBRA	D6,.AFF1
.EX1	MOVEM.L	(A7)+,D4/D6/D7/A1/A3
	RTS
	
AFFMOUSE_MONO
	LEA	MOUSEDAT,A3
	MOVE.L	FOND,A1
	MOVE.W	X_OFFS,D7
	MOVEQ	#14,D6
.AFF2	MOVEQ	#0,D4
	MOVE.L	(A3)+,D4
	ROR.L	D7,D4
	AND.W	D4,(A1)
	NOT.W	D4
	OR.W	D4,(A1)
	SWAP	D4
	AND.W	D4,2(A1)
	NOT.W	D4
	OR.W	D4,2(A1)
	ADD.W	#80,A1
	CMP.L	LIMIT,A1
	BGT.S	.EX4
	DBRA	D6,.AFF2
.EX4	MOVEM.L	(A7)+,D4/D6/D7/A1/A3
	RTS
***************************************************************************
		SECTION	DATA
MOUSEDAT	INCBIN	MOUSE.MSK
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
		DC.B	"  F2  - EDITER   UNE BANQUE",$D,$A,$D,$A
		DC.B	"  F3  - SAUVER   UNE BANQUE",$D,$A,$D,$A
		DC.B	"  F4  - NETTOYER LA  BANQUE",$D,$A,$D,$A
		DC.B	"                           ",$D,$A,$D,$A
		DC.B	"  F8  - NOMMER   LA  BANQUE       ACTUELLEMENT : ",$D,$A,$D,$A
		DC.B	"  F9  - CHANGER  LA  POLICE       ACTUELLEMENT : ",$D,$A,$D,$A
		DC.B	"  F10 - QUITTER",$D,$A
		DC.B	0
		EVEN
NET_MENU	DC.B	"        DIDACTITIEL    V1.0                         C.E.F.E.       Janvier 1994",$D,$A
		DC.B	"                                                13, rue Copernic               ",$D,$A
		DC.B	"        PAR GUILLAUME AUDUC                       44000 NANTES                 ",$D,$A,$D,$A,$D,$A,$D,$A,$D,$A
		DC.B	"  F1  - NETTOYER LES PHRASES",$D,$A,$D,$A
		DC.B	"  F2  - NETTOYER LES QUESTIONS",$D,$A,$D,$A
		DC.B	"  F3  - NETTOYER LA  SEQUENCE",$D,$A,$D,$A
		DC.B	"  F4  - NETTOYER TOUTE LA BANQUE",$D,$A,$D,$A
		DC.B	"  F10 - SORTIR",$D,$A
		DC.B	0
		EVEN

L_0		DC.B	$1B,'Y',32+0,32+0," PHRASE   N¯ ",0
		*               LINE COL
L_9		DC.B	$1B,'Y',32+9,32+0," QUESTION N¯ ",0
L_11		DC.B	$1B,'Y',32+11,32+0,0
L_13		DC.B	$1B,'Y',32+13,32+0,0
L_22		DC.B	$1B,'Y',32+22,32+0,'     REPONSE : ',0
L_REP		DC.B	$1B,'Y',32+22,32+15,0
L_24_EDIT	DC.B	$1B,'Y',32+24,32+0,"SORTIR   SEQUENCE",0
L_24_ELEVE	DC.B	$1B,'Y',32+24,32+0,"SORTIR   EDITE    AJOUTE   SUPPRIME   POSITION : ",0
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
