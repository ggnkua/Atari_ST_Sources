; PLAY MUSIC MAD MAX
; CODE RIC/NAOS
;
; ZORRO II
; 10/08/2001
;
; DEVPAC v2
; PLAY.INC

MAIN:
; Recuperation des parametres en GFA dans la pile

; off_init%
	LEA	OF1(PC),A0
	MOVE.W	4(SP),2(A0)
; off_play%
	LEA	OF2(PC),A0
	MOVE.W	6(SP),2(A0)
; morceau%
	MOVEQ	#0,D5
	MOVE.W	8(SP),D5
; buffer_music%
	MOVE.L	10(SP),A4

; MODE SUPERVISEUR
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,-(SP)

; DESACTIVE CLICK DU CLAVIER
	AND.B	#$FE,$484.W	; ==> MOVE.B	#2,$484.w

; INITIALISATION DE LA MUSIQUE

Init:
	MOVE.L	D5,D0
	MOVE.L	A4,A0
	ADD.L	OF1(PC),A0
	JSR	(A0)

OneVbl:
	LEA	$4CE.W,A1
	MOVEQ	#7,D7
Search:
	TST.L	(A1)+
	BEQ.S	Found
	DBF	D7,Search
	LEA	-1,A1
	BRA.S	Exit
Found:
	LEA	-4(A1),A1
	MOVE.L	A4,A0
	ADD.L	OF2(PC),A0
	MOVE.L	A0,(A1)

; RETOUR AU GFA

Exit:
	LEA	RESULT(PC),A2
	MOVE.L	A1,(A2)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

; Retourne -1 si VBL non trouve
	MOVE.L	RESULT(PC),D0
	RTS

; Mes donnees

OF1	DC.L	0
OF2	DC.L	0
RESULT	DC.L	0

