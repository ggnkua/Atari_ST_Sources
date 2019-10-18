** INTERFACE GFA/ASSEMBLEUR
** EXEMPLE : MUSIC PLAYER

* SOURCE ASM 1, JOUER LA MUSIQUE
*  Ö assembler sous MUSPLAY.INL
*             Code : Ric/NAOS


MAIN:
; RECUPERATION DES PARAMETRES
; Offset pour l'init.
	LEA	OF1(PC),A0
	MOVE.W	4(SP),2(A0)
; Offset pour jouer
	LEA	OF2(PC),A0
	MOVE.W	6(SP),2(A0)
; NumÇro du morceau
	MOVEQ	#0,D5
	MOVE.W	8(SP),D5
; Adresse de la musique
	MOVE.L	10(SP),A4

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,-(SP)
	
; DESACTIVE CLIC CLAVIER
	AND.B	#$FE,$484.W

; INSTALLE LA MUSIQUE
	
; Init. de la musique
	MOVE.L	D5,D0
	MOVE.L	A4,A0
	ADD.L	OF1(PC),A0
	JSR	(A0)

; Trouve et installe une VBL systäme
	LEA	$4CE.W,A1
	MOVEQ	#7,D7
.SEARCH	TST.L	(A1)+
	BEQ.S	.FOUND
	DBF	D7,.SEARCH
; Si aucun vecteur n'est libre...
	LEA	-1,A1
	BRA.S	EXIT

; A1 vecteur libre dans la VBL_List
.FOUND	LEA	-4(A1),A1
	MOVE.L	A4,A0
	ADD.L	OF2(PC),A0
	MOVE.L	A0,(A1)

EXIT:	LEA	RESULT(PC),A2
	MOVE.L	A1,(A2)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

; RETOUR AU GFA
; RÇsultat transmis : adresse du
; vecteur VBL systäme, -1 si erreur
	MOVE.L	RESULT(PC),D0
; Finir par un RTS
	RTS
	
OF1	DC.L	0
OF2	DC.L	0	
RESULT	DC.L	0

