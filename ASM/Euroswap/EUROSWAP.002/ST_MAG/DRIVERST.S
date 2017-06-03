;supexec
	PEA	MAIN(PC)
	MOVE.W	#$26,-(SP)
	TRAP	#14
	LEA	6(SP),SP
;exit
	CLR.W	-(SP)
	TRAP	#1

;programme qui doit etre execute en superviseur
MAIN
;init la musique et ses parametres
	LEA	STCONNEXION(PC),A0
;poke l'addresse de la musique
	LEA	MUSIC(PC),A1
	MOVE.L	A1,12(A0)
;sounchip:0
;st replay:1
;mv16:2
	MOVE.W	#0,16(A0)

	MOVE.W	#$2700,SR
	BSR	STCONNEXION
;lance la musique
	LEA	MY_VBL(PC),A0
	MOVE.L	A0,$70.W

	MOVE.W	#$2300,SR
DEMO	BSR	VSYNC
	CMP.B	#$39+$80,$FFFFFC02.W
	BNE.S	DEMO

;remet le st dans l'‚tat o— nous l'avons trouve
	MOVE.W	#$2700,SR
	BSR	STCONNEXION+$4
	MOVE.W	#$2300,SR
;wait mfp
	MOVE.W	#4000,D0
WAIT_MFP	NOP
	DBRA	D0,WAIT_MFP
;supexec fin
	RTS

MY_VBL	MOVE.L	A0,-(SP)
	LEA	SYNC(PC),A0
	ST	(A0)
	MOVE.L	(SP)+,A0
	BSR	STCONNEXION+$8
	RTE

VSYNC	MOVE.L	A0,-(SP)
	LEA	SYNC(PC),A0
	SF	(A0)
WAITVBL	TST.B	(A0)
	BEQ.S	WAITVBL
	MOVE.L	(SP)+,A0
	RTS

SYNC	DS.W	1

STCONNEXION	INCLUDE	\ST_MAG\ST_MAG.S
MUSIC	INCBIN	dforce_1.*