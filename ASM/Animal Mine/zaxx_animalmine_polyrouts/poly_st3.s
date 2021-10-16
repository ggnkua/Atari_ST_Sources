
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	LEA	MY_STACK,A7
* CALC TEST POLY	
	MOVE.W	#0,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#12,SP	
	MOVE.L	#SCREENS+256,D0
	MOVE.B	#0,D0
	MOVE.L	D0,SCREEN1
	ADD.L	#32000,D0
	MOVE.L	D0,SCREEN2
	JSR	CALC_CODE
	MOVEM.L	PAL1,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	JSR	MUZAK
TESTA:
	MOVE.W	#$25,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP


	MOVE.L	TRANSED2,D0
	MOVE.L	TRANSED1,TRANSED2
	MOVE.L	D0,TRANSED1
	MOVE.L	SCREEN2,D0
	MOVE.L	SCREEN1,SCREEN2
	MOVE.L	D0,SCREEN1
	LSR.W	#8,D0
	MOVE.L	D0,$FFFF8200.W

	MOVE.W	#$113,$FFFF8240.W
	BSR	CLR_DELTA
	JSR	TRANSFORM
	BSR	TEST_CALC
	BSR	TEST_DRAW	
	BSR	CALC_WOBBLE
	MOVE.W	#$002,$FFFF8240.W

	MOVEQ	#0,D0
	MOVE.B	$FFFFFC02.W,D0
	CMPI.W	#$4B,D0
	BNE.S	NOK1
	SUBQ.W	#1,MOVE_X
NOK1:
	CMPI.W	#$4D,D0
	BNE.S	NOK2
	ADDQ.W	#1,MOVE_X
NOK2:
	CMPI.W	#$48,D0
	BNE.S	NOK3
	SUBQ.W	#1,MOVE_Y
NOK3:
	CMPI.W	#$50,D0
	BNE.S	NOK4
	ADDQ.W	#1,MOVE_Y
NOK4:
	CMPI.W	#$4A,D0
	BNE.S	NOK5
	SUBQ.W	#5,MOVE_Z
NOK5:
	CMPI.W	#$4E,D0
	BNE.S	NOK6
	ADDQ.W	#5,MOVE_Z
NOK6:
	
	

	CMPI.B	#$39+$80,D0
	BNE	TESTA
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	JSR	MUZAK+38
	MOVE.L	#$07770777,$FFFF8240.W
	MOVE.L	#$05550000,$FFFF8244.W
	
	CLR.W	-(SP)
	TRAP	#1

*==============================================================
* V1.0			 POLYGON L™SCHEN		10/6/93
*==============================================================
* BENUTZT D0-D7/A0-A4
*
*	A0 = ZEIGER AUF TRANSED-3D
*
*==============================================================

CLR_DELTA:
	MOVE.L	TRANSED1,A0
	MOVE.W	#199,D1
	MOVE.W	#0,D2
	REPT	8
	MOVE.L	(A0)+,D0
	CMP.W	D0,D1
	BLT.S	*+4
	MOVE.W	D0,D1
	CMP.W	D0,D2
	BGT.S	*+4
	MOVE.W	D0,D2
	ENDR
	NEG.W	D1
	ADD.W	D2,D1
	MOVE.L	SCREEN1,A0
	ADD.W	D2,D2
	LEA	MULU_Y(PC),A1
	ADDA.W	(A1,D2.W),A0
	LSL.W	#4,D1
	NEG.W	D1
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	D0,A4
	LEA	CLR_CODE(PC),A1
	JMP	(A1,D1.W)
	REPT	200
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	MOVEM.L	D0/D2-D7/A2-A4,-(A0)
	ENDR
CLR_CODE:
	RTS
*==============================================================
* V1.0			 POLYGON WOBBEL			23/8/93
*==============================================================
*
*	A0 = ZEIGER AUF SOURCE-3D
*	A1 = ZEIGER AUF SINTAB
*
*==============================================================
SIN_COUNT:
	DC.W	0
SIN_COUNT2:
	DC.W	0
CALC_WOBBLE:
	LEA	OBJ_DATA+14,A0
	LEA	SIN_180,A1
	MOVE.W	SIN_COUNT(PC),D0
	AND.W	#%1111111110,D0
	MOVE.W	(A1,D0.W),D0		; SIN HOLEN
	MOVE.W	D0,(A0)
	MOVE.W	D0,6(A0)
	MOVE.W	D0,12(A0)
	MOVE.W	D0,18(A0)		; SIN IN OBJ EINTRAGEN
	MOVE.W	D0,24(A0)
	MOVE.W	D0,30(A0)
	MOVE.W	SIN_COUNT2,D0
	AND.W	#%1111111110,D0
	MOVE.W	(A1,D0.W),D0		; SIN HOLEN
	ASR.W	#1,D0
	MOVE.W	D0,DREH_X
	NEG.W	D0
	ASR.W	D0
	MOVE.W	D0,DREH_Y
	ADDQ.W	#3,DREH_Z
	ADD.W	#4,SIN_COUNT
	ADD.W	#3,SIN_COUNT2
	RTS


*==============================================================
* V1.2			 POLYGON BERECHNEN		10/6/93
*==============================================================
* BENUTZT D0-D5/A0-A5
* MIT ADDX-TECHNIK
*	A0 = ZEIGER AUF POLY-STRUC
*	A1 = ZEIGER AUF TRANSED-3D
*	A3 = ZEIGER AUF POLY_X
*	A5 = POLYFASTTAB MIT 1/Y WERTEN FšR MULU
*	A6 = DRAW_INFO
*	
* DATA-STRUC DER POLYFLŽCHE
*	DC.W	0	; VISI FLAG
*	DC.W	0	; POLY-FARBE
*	DC.W	anz-1	; ANZ DER PUNKTE ( MIN 3-1!)	
*	DC.W	anz*4	; DIE PUNKTE
*
*==============================================================
X_MIN:	DC.W	0
X_MAX	DC.W	319		; SCREEN WERTE FšR CLIP + CALC
Y_MIN	DC.W	0
Y_MAX	DC.W	199
GENAU	DC.L	$7FFF0000	; 0.5

TEST_CALC:
		LEA	POLY_STRUC,A0
		MOVE.L	TRANSED1,A1
		LEA	POLY_X,A3
		LEA	POLY_FAST,A5	
		LEA	DRAW_INFO,A6
		MOVE.W	(A0)+,D7	
CALC_ALL_POLY:
		BSR	CALC_ONE_POLY	
		MOVE.W	(A0)+,(A6)+
		ADDQ.L	#2,A3		
		DBF	D7,CALC_ALL_POLY
		RTS
CALC_ONE_POLY:
		LEA	ECK_BUF(PC),A2
		MOVE.L	A2,A4
		MOVE.L	A2,D3
		MOVE.W	(A0)+,D2		; PUNKT HOLEN
		MOVE.L	(A1,D2.W),D2		
		MOVE.L	D2,(A2)+		; X/Y-WERT SAVE
		MOVE.W	(A0)+,D2		; PUNKT HOLEN
		MOVE.L	(A1,D2.W),D2		
		MOVE.L	D2,(A2)+		; X/Y-WERT SAVE
		MOVE.W	(A0)+,D2		; PUNKT HOLEN
		MOVE.L	(A1,D2.W),D2		
		MOVE.L	D2,(A2)+		; X/Y-WERT SAVE
		MOVE.L	(A4)+,(A2)+
		MOVE.L	(A4)+,(A2)+
		MOVE.L	(A4)+,(A2)+
		MOVE.L	D3,A4
		MOVE.W	#32000,D2		; MIN/MAX-Y SETZEN (INVERT)
		MOVE.W	D2,D3
		NEG.W	D3
		MOVE.L	(A4)+,D1
		CMP.W	D1,D2			; TEST Y-MIN ??
		BLT.S	NO_Y_MIN1
		MOVE.W	D1,D2			; NEW Y-MIN
		MOVE.L	A4,A2			; A2 = ZEIGER AUF Y-MIN		
NO_Y_MIN1:
		CMP.W	D1,D3			; TEST Y-MAX ??
		BGT.S	NO_Y_MAX1
		MOVE.W	D1,D3			; NEW Y-MAX
NO_Y_MAX1:
		MOVE.L	(A4)+,D1
		CMP.W	D1,D2			; TEST Y-MIN ??
		BLT.S	NO_Y_MIN2
		MOVE.W	D1,D2			; NEW Y-MIN
		MOVE.L	A4,A2			; A2 = ZEIGER AUF Y-MIN		
NO_Y_MIN2:
		CMP.W	D1,D3			; TEST Y-MAX ??
		BGT.S	NO_Y_MAX2
		MOVE.W	D1,D3			; NEW Y-MAX
NO_Y_MAX2:
		MOVE.L	(A4)+,D1
		CMP.W	D1,D2			; TEST Y-MIN ??
		BLT.S	NO_Y_MIN3
		MOVE.W	D1,D2			; NEW Y-MIN
		MOVE.L	A4,A2			; A2 = ZEIGER AUF Y-MIN		
NO_Y_MIN3:
		CMP.W	D1,D3			; TEST Y-MAX ??
		BGT.S	NO_Y_MAX3
		MOVE.W	D1,D3			; NEW Y-MAX
NO_Y_MAX3:
		LEA	8(A2),A4
		MOVE.L	A4,A_HELP
		SUBQ.L	#4,A2			; CORRECT POINTER
		MOVE.W	D2,(A6)+		; Y-START
		MOVE.W	D3,D0
		SUB.W	D2,D0
		MOVE.W	D0,(A6)+		; dY		
* D2 = Y-MIN
* D3 = Y-MAX
* A2 = ZEIGER Y-MIN (LOW-BUF)
* A4 = ZEIGER Y-MIN (HIGH-BUF)+4
* CALC RIGHT BUF
* JETZT DAS POLY VON Y-MIN NACH Y-MAX RECHTSRUM BERECHNEN
*
		MOVE.L	A3,(A6)+		; SAVE RIGTH IN DRAW_INFO
CALC_RIGHT:
		MOVEM.L	(A2)+,D0/D4
		MOVE.W	D4,D5
		SWAP	D4
		CMP.W	D3,D5
		BEQ.S	LAST_RIGHT_CALC
		BSR.S	CALC_STEPS
		MOVEM.L	-4(A2),D0/D4
		MOVE.W	D4,D5
		SWAP	D4
LAST_RIGHT_CALC:
		BSR.S	CALC_STEPS
* JETZT DAS POLY VON Y-MIN NACH Y-MAX LINKSRUM BERECHNEN
*
		ADDQ.L	#2,A3
		MOVE.L	A3,(A6)+		; SAVE LEFT IN DRAW_INFO
		MOVE.L	A_HELP(PC),A2
CALC_LEFT:
		MOVE.L	(A2),D0
		MOVE.L	-4(A2),D4
		MOVE.W	D4,D5
		SWAP	D4
		CMP.W	D3,D5
		BEQ.S	LAST_LEFT_CALC
		BSR.S	CALC_STEPS
		MOVE.L	-4(A2),D0
		MOVE.L	-8(A2),D4

		MOVE.W	D4,D5
		SWAP	D4
LAST_LEFT_CALC:
CALC_STEPS:
		MOVE.L	GENAU(PC),D2 
		SUB.W	D0,D5			; D5 = Y
		SWAP	D0
		SUB.W	D0,D4			; D4 = X
		TST.W	D4									
		BEQ	ZERO_CALC	
 		BGE	NACH_RECHTS
		NEG.W	D4			; CHANGE +-
		ADD.W	D5,D5
		MOVE.W	(A5,D5.W),D1
		ADD.W	D5,D5
		MULU.W	D1,D4
		SWAP	D4
		LEA	C_POLYLOOP(PC),A4
		NEG.W	D5
		SUB.L	D4,D2
		MOVE.W	D0,D2
		JMP	(A4,D5.W)		; JMP IN CALC-CODE..
		REPT	50
		SUBX.L	D4,D2
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		SUBX.L	D4,D2
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		SUBX.L	D4,D2
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		SUBX.L	D4,D2
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		ENDR
C_POLYLOOP:
		SUBX.L	D4,D2
		MOVE.W	D2,(A3)			; X-WERT SICHERN
		RTS
ZERO_CALC:
		ADD.W	D5,D5
		NEG.W	D5
		LEA	ZERO_SPEED(PC),A4
		JMP	(A4,D5.W)		
		REPT	50			
		MOVE.W	D0,(A3)+		; SENKRECHT ->NO CALC
		MOVE.W	D0,(A3)+		; SENKRECHT ->NO CALC
		MOVE.W	D0,(A3)+		; SENKRECHT ->NO CALC
		MOVE.W	D0,(A3)+		; SENKRECHT ->NO CALC
		ENDR
ZERO_SPEED:
		MOVE.W	D0,(A3)
		RTS
NACH_RECHTS:
		ADD.W	D5,D5
		MOVE.W	(A5,D5.W),D1
		ADD.W	D5,D5
		NEG.W	D5
		MULU.W	D1,D4
		SWAP	D4
		ADD.L	D4,D2
		MOVE.W	D0,D2
		LEA	C_POLYLOOP2(PC),A4
		JMP	(A4,D5.W)
		REPT	50
		ADDX.L	D4,D2			; NACHKOMMA OVERFLOW
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		ADDX.L	D4,D2			; NACHKOMMA OVERFLOW
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		ADDX.L	D4,D2			; NACHKOMMA OVERFLOW
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		ADDX.L	D4,D2			; NACHKOMMA OVERFLOW
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		ENDR
C_POLYLOOP2:
		ADDX.L	D4,D2			; NACHKOMMA OVERFLOW
		MOVE.W	D2,(A3)			; X-WERT SICHERN
		RTS
A_HELP:		DC.L	0
ECK_BUF:	DS.W	40
SCREEN1:	DC.L	0

;  CACHE H-LINES 1 PLANE 30/05/93
*****************************************************************
*		CACHE H-LINES 1-PLANE				*
*		ZAXX/ANIMAL MINE/INDEPENDENT			*
*****************************************************************						
Y_DIS		EQU	160	
MULU_Y:
OFFY		SET	0
		REPT	200
		DC.W	OFFY
OFFY		SET	OFFY+160
		ENDR
NO_DRAW2:
		RTS
TEST_DRAW:
		LEA	START_DATA,A2		; OR WERTE + LŽNGE
		LEA	END_DATA,A3
		LEA	MULU_Y(PC),A5
		MOVE.W	POLY_STRUC,D7
		LEA	DRAW_INFO,A6
		MOVEQ	#-1,D4			; DATA FšLLER
		MOVE.L	#Y_DIS,D3		; ZEILENSPRUNG
NEXT_POLY_DRAW:
		MOVE.L	SCREEN1(PC),A4		; SCREEN ADR
		BSR.S	UNTER_DRAW
		DBF	D7,NEXT_POLY_DRAW
		RTS
UNTER_DRAW:
		MOVEM.W	(A6)+,D0/D2
		MOVEM.L	(A6)+,A0-A1
		MOVE.W	(A6)+,D1
		SUBQ.W	#1,D2
		TST.W	D2
		BLE.S	NO_DRAW2		
		ADD.W	D0,D0
		ADDA.W	(A5,D0.W),A4	
		MOVEQ	#-2,D0
		AND.W	D2,D0
		MOVEQ	#-4,D5
		MOVEQ	#-4,D6
		AND.W	(A0,D0.W),D5		; CHECK SEITE....
		AND.W	(A1,D0.W),D6
		CMP.W	D5,D6
		BEQ.S	NO_DRAW2
		BLT.S	JUMP_LA
		EXG.L	A1,A0
		ADDQ.W	#4,D1
JUMP_LA:
		CMPI.W	#4,D1
		BGT.S	NO_DRAW2
		ADDA.W	D1,A4
JUMP_HERE:
		MOVEQ	#-4,D0
		MOVEQ	#-4,D1
		AND.W	(A1)+,D0		; STARTWERT
		AND.W	(A0)+,D1		; ENDWERT
		MOVE.L	(A2,D0.W),D0		
		MOVE.L	(A3,D1.W),D1		
		ADD.W	D0,D1			; CALC LŽNGE
		JMP	CODE_BUF(PC,D1.W)
CODE_BUF:
		DS.W	15200

* 20/8/93 ZAXX CANIBAL MINE
* H-LINE CODEGENERATOR
*
OFF_CODE	EQU	84		; 84 BYTES PRO H-LINE
					; =>  84*18*20 = 31000
CALC_CODE:
	LEA	CODE_BUF,A0
	MOVE.L	#JUMP_HERE,D7
	MOVEQ	#0,D0			; X OFFSET
	MOVE.W	#20-1,D1		; 20 WORDS
NEXT_X_CODE:
	MOVE.L	A0,A2
	MOVE.L	#$48404841,(A2)+	; "SWAP D0/D1"
	MOVE.L	#$C240836C,(A2)+	; "AND D0,D1" "OR.W D1,OFFX(A4)"
	MOVE.W	D0,(A2)+
	MOVE.L	#$D9C351CA,(A2)+	; "ADD.L D3,A4" "DBF D2,??"
	MOVE.L	D7,D6
	SUB.L	A2,D6
	MOVE.W	D6,(A2)+
	MOVE.W	#$4E75,(A2)+		; "RTS"
	REPT	17
	MOVE.L	#'NqNq',(A2)+
	ENDR
	ADD.L	#OFF_CODE,A0
	MOVE.L	A0,A2
	MOVE.L	#$48404841,(A2)+	; "SWAP D0/D1"
	MOVE.W	#$816C,(A2)+
	MOVE.W	D0,(A2)+
	MOVE.W	#$836C,(A2)+		; "OR.W D0/D1"
	MOVE.W	D0,D2
	ADDQ.W	#8,D2
	MOVE.W	D2,(A2)+
	MOVE.L	#$D9C351CA,(A2)+	; "ADD.L D3,A4" "DBF D2,??"
	MOVE.L	D7,D6
	SUB.L	A2,D6
	MOVE.W	D6,(A2)+
	MOVE.W	#$4E75,(A2)+		; "RTS"
	REPT	16
	MOVE.L	#'NqNq',(A2)+
	ENDR
	MOVEQ	#0,D3			;  
ALL_X_CODE:
	ADD.L	#OFF_CODE,A0
	MOVE.L	A0,A2
	MOVE.L	#$48404841,(A2)+	; "SWAP D0/D1"
	MOVE.W	#$816C,(A2)+
	MOVE.W	D0,(A2)+
	MOVE.W	D0,D2
	MOVE.W	D3,D4
CODE_LOPO:
	ADDQ.W	#8,D2
	MOVE.W	#$3944,(A2)+
	MOVE.W	D2,(A2)+
	DBF	D4,CODE_LOPO
	ADDQ.W	#8,D2
	MOVE.W	#$836C,(A2)+		; "OR.W D0/D1"
	MOVE.W	D2,(A2)+
	MOVE.L	#$D9C351CA,(A2)+	; "ADD.L D3,A4" "DBF D2,??"
	MOVE.L	D7,D6
	SUB.L	A2,D6
	MOVE.W	D6,(A2)+
	MOVE.W	#$4E75,(A2)+		; "RTS"
	REPT	15
	MOVE.L	#'NqNq',(A2)+
	ENDR
	ADDQ.W	#1,D3
	CMP.W	#16,D3
	BLT	ALL_X_CODE
	ADDQ.W	#8,D0
	ADD.L	#OFF_CODE,A0
	DBF	D1,NEXT_X_CODE
	RTS



TRANSFORM:
* CALC_MATRIX
	LEA	OBJ_DATA(PC),A0			; DATASTRUC VON OBJ

	LEA	SAVE_MATRIX+18(PC),A2		; SAVE TAB FšR MULU
	MOVEM.W	DREH_X(PC),D0-D2 
	AND.W	#%11111111110,D0
	AND.W	#%11111111110,D1		; AUF TABELLE KšRZEN 
	AND.W	#%11111111110,D2
	LEA	COS_TAB(PC),A3
	MOVE.W	(A3,D0.W),D3 
	MOVE.W	(A3,D1.W),D4			; SIN/COS WERTE HOLEN 
	MOVE.W	(A3,D2.W),D5 
	LEA	SIN_TAB(PC),A3
	MOVE.W	(A3,D0.W),D0 
	MOVE.W	(A3,D1.W),D1 
	MOVE.W	(A3,D2.W),D2 
	MOVE.W	D4,D6 
	MULS	D5,D6 
	ADD.L	D6,D6 
	SWAP	D6
	MOVE.W	D6,-(A2)			; 9 MATRIXWERTE AUSRECHNEN
	NEG.W	D1
	MOVE.W	D1,-(A2)
	NEG.W	D1
	MOVE.W	D4,D6 
	MULS	D2,D6 
	ADD.L	D6,D6 
	SWAP	D6
 	NEG.W	D6
	MOVE.W	D6,-(A2)
	MOVE.W	D1,D6 
	MULS	D5,D6 
	ADD.L	D6,D6 
	SWAP	D6
	MOVEA.W	D6,A3 
	MULS	D3,D6 
	MOVE.W	D0,D7 
	MULS	D2,D7 
	SUB.L	D7,D6 
	ADD.L	D6,D6 
	SWAP	D6
	MOVE.W	D6,-(A2)
	MOVE.W	D3,D6 
	MULS	D4,D6 
	ADD.L	D6,D6 
	SWAP	D6
	MOVE.W	D6,-(A2)
	MULS	D2,D1 
	ADD.L	D1,D1 
	SWAP	D1
	MOVE.W	D1,D6 
	MULS	D3,D6 
	MOVE.W	D0,D7 
	MULS	D5,D7 
	ADD.L	D7,D6 
	ADD.L	D6,D6 
	SWAP	D6
	NEG.W	D6
	MOVE.W	D6,-(A2)
	MOVE.W	A3,D6 
	MULS	D0,D6 
	MULS	D3,D2 
	ADD.L	D2,D6 
	ADD.L	D6,D6 
	SWAP	D6
	MOVE.W	D6,-(A2)
	MULS	D0,D4 
	ADD.L	D4,D4 
	SWAP	D4
	MOVE.W	D4,-(A2)
	MULS	D0,D1 
	MULS	D5,D3 
	SUB.L	D1,D3 
	ADD.L	D3,D3 
	SWAP	D3
	MOVE.W	D3,-(A2)


* 3-D TRANSFORM ( 9 MULS )

	MOVE.W	(A0)+,D7			; ANZ DER PUNKTE
	MOVE.L	TRANSED1,A2
CALC_3D:
	LEA	SAVE_MATRIX(PC),A1
	MOVEM.W	(A0)+,D0-D2 
	MOVE.W	D0,D3 
	MOVE.W	D1,D4 
	MOVE.W	D2,D5 
	MULS	(A1)+,D0			; DREHUNG UM ACHSEN
	MULS	(A1)+,D4
	MULS	(A1)+,D5
	ADD.L	D4,D0 
	ADD.L	D5,D0 
	MOVE.W	D3,D6 
	MOVE.W	D1,D4 
	MOVE.W	D2,D5 
	MULS	(A1)+,D3
	MULS	(A1)+,D1
	MULS	(A1)+,D5
	ADD.L	D3,D1 
	ADD.L	D5,D1 
	MULS	(A1)+,D6
	MULS	(A1)+,D4
	MULS	(A1)+,D2
	ADD.L	D6,D2 
	ADD.L	D4,D2 
	ADD.L	(A1)+,D0
	ADD.L	(A1)+,D1
	ADD.L	(A1)+,D2
	ASR.L	#6,D0 
	ASR.L	#8,D1			; 3-D ZENTRAL PROJEKTION 
	SWAP	D2
	DIVS	D2,D0 
	DIVS	D2,D1 
	ADD.W	MID_X(PC),D0		; IN DIE MITTE 
	ADD.W	MID_Y(PC),D1 
	MOVE.W	D0,(A2)+		; SAVE POINTS
	MOVE.W	D1,(A2)+		; X/Y
	DBF	D7,CALC_3D
	RTS


DREH_X:		DC.W	0			; DREHWINKEL X/Y/Z
DREH_Y:		DC.W	0
DREH_Z:		DC.W	0
MID_X:		DC.W	160*4			; MITTE VON SCREEN
MID_Y:		DC.W	140
SAVE_MATRIX:	DS.W	9			; BUF FšR MATRIX
MOVE_X:		DC.L	0
MOVE_Y:		DC.L	0
MOVE_Z:		DC.W	265			; 3-D WORLD MOVE
		DC.W	0
OBJ_DATA:
		DC.W	8-1
		DC.W	180,0,0
		DC.W	-180,0,0
		DC.W	0,60,0
		DC.W	0,30,52
		DC.W	0,-30,52
		DC.W	0,-60,0
		DC.W	0,-30,-52
		DC.W	0,30,-52

PAL1:
	DC.W	$002,$400,$600,$500,$000,$667,$777,$677
	DC.W	$000,$000,$000,$000,$000,$000,$000,$000


; GLENZ CUBE....

BIG1		EQU	110
BIG2		EQU	30
BIG3		EQU	110
		DC.W	14-1
		DC.W	-BIG1,-BIG2,-BIG3
		DC.W	BIG1,-BIG2,-BIG3
		DC.W	-BIG1,BIG2,-BIG3
		DC.W	BIG1,BIG2,-BIG3
		DC.W	-BIG1,-BIG2,BIG3
		DC.W	BIG1,-BIG2,BIG3
		DC.W	-BIG1,BIG2,BIG3
		DC.W	BIG1,BIG2,BIG3
		DC.W	0,0,-BIG3
		DC.W	0,-BIG2,0
		DC.W	0,0,BIG3
		DC.W	BIG1,0,0
		DC.W	-BIG1,0,0
		DC.W	0,BIG2,0
				
POLY_STRUC:
; GLENZ SYNERGY...
	DC.W	12-1
	DC.W	4*4,5*4,0*4
	DC.W	0
	DC.W	5*4,6*4,0*4
	DC.W	2
	DC.W	6*4,7*4,0*4
	DC.W	0
	DC.W	7*4,2*4,0*4
	DC.W	2
	DC.W	2*4,3*4,0*4
	DC.W	0
	DC.W	3*4,4*4,0*4
	DC.W	2
	DC.W	7*4,6*4,1*4
	DC.W	2
	DC.W	6*4,5*4,1*4
	DC.W	0
	DC.W	5*4,4*4,1*4
	DC.W	2
	DC.W	4*4,3*4,1*4
	DC.W	0
	DC.W	3*4,2*4,1*4
	DC.W	2
	DC.W	2*4,7*4,1*4
	DC.W	0



; GLENZ CUBE...
	DC.W	12-1
	DC.W	0*4,8*4,2*4
	DC.W	1*4,3*4,8*4
	DC.W	4*4,0*4,12*4
	DC.W	6*4,12*4,2*4
	DC.W	1*4,5*4,11*4
	DC.W	3*4,11*4,7*4
	DC.W	4*4,6*4,10*4
	DC.W	5*4,10*4,7*4
	DC.W	0*4,9*4,1*4
	DC.W	4*4,5*4,9*4
	DC.W	2*4,3*4,13*4
	DC.W	13*4,7*4,6*4


SIN_TAB:
      DC.B      $00,$00,$00,$C9,$01,$92,$02,'[' 
      DC.B      $03,'$',$03,$ED,$04,$B6,$05,'~' 
      DC.B      $06,'G',$07,$10,$07,$D9,$08,$A1 
      DC.B      $09,'j',$0A,'2',$0A,$FB,$0B,$C3 
      DC.B      $0C,$8B,$0D,'S',$0E,$1B,$0E,$E3 
      DC.B      $0F,$AB,$10,'r',$11,'9',$12,$00 
      DC.B      $12,$C7,$13,$8E,$14,'U',$15,$1B 
      DC.B      $15,$E1,$16,$A7,$17,'m',$18,'3' 
      DC.B      $18,$F8,$19,$BD,$1A,$82,$1B,'F' 
      DC.B      $1C,$0B,$1C,$CF,$1D,$93,$1E,'V' 
      DC.B      $1F,$19,$1F,$DC,' ',$9F,'!a'
      DC.B      '"#"',$E4,'#',$A6,'$g'
      DC.B      '%',$27,'%',$E7,'&',$A7,$27,'g' 
      DC.B      '(&(',$E5,')',$A3,'*a'
      DC.B      '+',$1E,'+',$DB,',',$98,'-T'
      DC.B      '.',$10,'.',$CC,'/',$86,'0A'
      DC.B      '0',$FB,'1',$B4,'2m3&'
      DC.B      '3',$DE,'4',$96,'5M6',$03 
      DC.B      '6',$B9,'7o8$8',$D8 
      DC.B      '9',$8C,':?:',$F2,';',$A4 
      DC.B      '<V=',$07,'=',$B7,'>g'
      DC.B      '?',$16,'?',$C5,'@sA '
      DC.B      'A',$CD,'ByC%C',$D0 
      DC.B      'DzE#E',$CC,'Ft'
      DC.B      'G',$1C,'G',$C3,'HiI',$0E 
      DC.B      'I',$B3,'JWJ',$FA,'K',$9D 
      DC.B      'L?L',$E0,'M',$80,'N '
      DC.B      'N',$BF,'O]O',$FA,'P',$97 
      DC.B      'Q3Q',$CE,'RhS',$01 
      DC.B      'SšT2T',$C9,'U_'
      DC.B      'U',$F4,'V',$89,'W',$1D,'W',$B0 
      DC.B      'XBX',$D3,'YcY',$F3 
      DC.B      'Z[',$0F,'[',$9C,'\('
      DC.B      '\',$B3,']=]',$C6,'^O'
      DC.B      '^',$D6,'_]_',$E2,'`g'
      DC.B      '`',$EB,'ana',$F0,'bq'
      DC.B      'b',$F1,'cpc',$EE,'dk'
      DC.B      'd',$E7,'ebe',$DD,'fV'
      DC.B      'f',$CE,'gEg',$BC,'h1'
      DC.B      'h',$A5,'i',$19,'i',$8B,'i',$FC 
      DC.B      'jlj',$DB,'kJk',$B7 
      DC.B      'l#lŽl',$F8,'ma'
      DC.B      'm',$C9,'n0n',$95,'n',$FA 
      DC.B      'o^o',$C0,'p"p',$82 
      DC.B      'p',$E1,'q@q',$9D,'q',$F9 
      DC.B      'rTr',$AE,'s',$06,'s^'
      DC.B      's',$B5,'t',$0A,'t^t',$B1 
      DC.B      'u',$03,'uTu',$A4,'u',$F3 
      DC.B      'v@v',$8D,'v',$D8,'w"'
      DC.B      'wkw',$B3,'w',$F9,'x?'
      DC.B      'x',$83,'x',$C6,'y',$08,'yI'
      DC.B      'y',$89,'y',$C7,'z',$04,'zA'
      DC.B      'z|z',$B5,'z',$EE,'{%'
      DC.B      '{\{',$91,'{',$C4,'{',$F7 
      DC.B      '|)|Y|',$88,'|',$B6 
      DC.B      '|',$E2,'}',$0E,'}8}a'
      DC.B      '}',$89,'}',$B0,'}',$D5,'}',$F9 
      DC.B      '~',$1C,'~>~^~~'
      DC.B      '~',$9C,'~',$B9,'~',$D4,'~',$EF 
      DC.B      $7F,$08,$7F,' ',$7F,'7',$7F,'L' 
      DC.B      $7F,'a',$7F,'t',$7F,$86,$7F,$96 
      DC.B      $7F,$A6,$7F,$B4,$7F,$C1,$7F,$CD 
      DC.B      $7F,$D7,$7F,$E0,$7F,$E8,$7F,$EF 
      DC.B      $7F,$F5,$7F,$F9,$7F,$FC,$7F,$FE 
COS_TAB:
      DC.B      $7F,$FF,$7F,$FE,$7F,$FC,$7F,$F9 
      DC.B      $7F,$F5,$7F,$EF,$7F,$E8,$7F,$E0 
      DC.B      $7F,$D7,$7F,$CD,$7F,$C1,$7F,$B4 
      DC.B      $7F,$A6,$7F,$96,$7F,$86,$7F,'t' 
      DC.B      $7F,'a',$7F,'L',$7F,'7',$7F,' ' 
      DC.B      $7F,$08,'~',$EF,'~',$D4,'~',$B9 
      DC.B      '~',$9C,'~~~^~>'
      DC.B      '~',$1C,'}',$F9,'}',$D5,'}',$B0 
      DC.B      '}',$89,'}a}8}',$0E 
      DC.B      '|',$E2,'|',$B6,'|',$88,'|Y'
      DC.B      '|){',$F7,'{',$C4,'{',$91 
      DC.B      '{\{%z',$EE,'z',$B5 
      DC.B      'z|zAz',$04,'y',$C7 
      DC.B      'y',$89,'yIy',$08,'x',$C6 
      DC.B      'x',$83,'x?w',$F9,'w',$B3 
      DC.B      'wkw"v',$D8,'v',$8D 
      DC.B      'v@u',$F3,'u',$A4,'uT'
      DC.B      'u',$03,'t',$B1,'t^t',$0A 
      DC.B      's',$B5,'s^s',$06,'r',$AE 
      DC.B      'rTq',$F9,'q',$9D,'q@'
      DC.B      'p',$E1,'p',$82,'p"o',$C0 
      DC.B      'o^n',$FA,'n',$95,'n0'
      DC.B      'm',$C9,'mal',$F8,'lŽ'
      DC.B      'l#k',$B7,'kJj',$DB 
      DC.B      'jli',$FC,'i',$8B,'i',$19 
      DC.B      'h',$A5,'h1g',$BC,'gE'
      DC.B      'f',$CE,'fVe',$DD,'eb'
      DC.B      'd',$E7,'dkc',$EE,'cp'
      DC.B      'b',$F1,'bqa',$F0,'an'
      DC.B      '`',$EB,'`g_',$E2,'_]'
      DC.B      '^',$D6,'^O]',$C6,']='
      DC.B      '\',$B3,'\([',$9C,'[',$0F 
      DC.B      'ZY',$F3,'YcX',$D3 
      DC.B      'XBW',$B0,'W',$1D,'V',$89 
      DC.B      'U',$F4,'U_T',$C9,'T2'
      DC.B      'SšS',$01,'RhQ',$CE 
      DC.B      'Q3P',$97,'O',$FA,'O]'
      DC.B      'N',$BF,'N M',$80,'L',$E0 
      DC.B      'L?K',$9D,'J',$FA,'JW'
      DC.B      'I',$B3,'I',$0E,'HiG',$C3 
      DC.B      'G',$1C,'FtE',$CC,'E#'
      DC.B      'DzC',$D0,'C%By'
      DC.B      'A',$CD,'A @s?',$C5 
      DC.B      '?',$16,'>g=',$B7,'=',$07 
      DC.B      '<V;',$A4,':',$F2,':?'
      DC.B      '9',$8C,'8',$D8,'8$7o'
      DC.B      '6',$B9,'6',$03,'5M4',$96 
      DC.B      '3',$DE,'3&2m1',$B4 
      DC.B      '0',$FB,'0A/',$86,'.',$CC 
      DC.B      '.',$10,'-T,',$98,'+',$DB 
      DC.B      '+',$1E,'*a)',$A3,'(',$E5 
      DC.B      '(&',$27,'g&',$A7,'%',$E7 
      DC.B      '%',$27,'$g#',$A6,'"',$E4 
      DC.B      '"#!a ',$9F,$1F,$DC 
      DC.B      $1F,$19,$1E,'V',$1D,$93,$1C,$CF 
      DC.B      $1C,$0B,$1B,'F',$1A,$82,$19,$BD 
      DC.B      $18,$F8,$18,'3',$17,'m',$16,$A7 
      DC.B      $15,$E1,$15,$1B,$14,'U',$13,$8E 
      DC.B      $12,$C7,$12,$00,$11,'9',$10,'r' 
      DC.B      $0F,$AB,$0E,$E3,$0E,$1B,$0D,'S' 
      DC.B      $0C,$8B,$0B,$C3,$0A,$FB,$0A,'2' 
      DC.B      $09,'j',$08,$A1,$07,$D9,$07,$10 
      DC.B      $06,'G',$05,'~',$04,$B6,$03,$ED 
      DC.B      $03,'$',$02,'[',$01,$92,$00,$C9 
      DC.B      $00,$00,$FF,'7',$FE,'n',$FD,$A5 
      DC.B      $FC,$DC,$FC,$13,$FB,'J',$FA,$82 
      DC.B      $F9,$B9,$F8,$F0,$F8,$27,$F7,'_' 
      DC.B      $F6,$96,$F5,$CE,$F5,$05,$F4,'=' 
      DC.B      $F3,'u',$F2,$AD,$F1,$E5,$F1,$1D 
      DC.B      $F0,'U',$EF,$8E,$EE,$C7,$EE,$00 
      DC.B      $ED,'9',$EC,'r',$EB,$AB,$EA,$E5 
      DC.B      $EA,$1F,$E9,'Y',$E8,$93,$E7,$CD 
      DC.B      $E7,$08,$E6,'C',$E5,'~',$E4,$BA 
      DC.B      $E3,$F5,$E3,'1',$E2,'m',$E1,$AA 
      DC.B      $E0,$E7,$E0,'$',$DF,'a',$DE,$9F 
      DC.B      $DD,$DD,$DD,$1C,$DC,'Z',$DB,$99 
      DC.B      $DA,$D9,$DA,$19,$D9,'Y',$D8,$99 
      DC.B      $D7,$DA,$D7,$1B,$D6,']',$D5,$9F 
      DC.B      $D4,$E2,$D4,'%',$D3,'h',$D2,$AC 
      DC.B      $D1,$F0,$D1,'4',$D0,'z',$CF,$BF 
      DC.B      $CF,$05,$CE,'L',$CD,$93,$CC,$DA 
      DC.B      $CC,'"',$CB,'j',$CA,$B3,$C9,$FD 
      DC.B      $C9,'G',$C8,$91,$C7,$DC,$C7,'(' 
      DC.B      $C6,'t',$C5,$C1,$C5,$0E,$C4,'\' 
      DC.B      $C3,$AA,$C2,$F9,$C2,'I',$C1,$99 
      DC.B      $C0,$EA,$C0,';',$BF,$8D,$BE,$E0 
      DC.B      $BE,'3',$BD,$87,$BC,$DB,$BC,'0' 
      DC.B      $BB,$86,$BA,$DD,$BA,'4',$B9,$8C 
      DC.B      $B8,$E4,$B8,'=',$B7,$97,$B6,$F2 
      DC.B      $B6,'M',$B5,$A9,$B5,$06,$B4,'c' 
      DC.B      $B3,$C1,$B3,' ',$B2,$80,$B1,$E0 
      DC.B      $B1,'A',$B0,$A3,$B0,$06,$AF,'i' 
      DC.B      $AE,$CD,$AE,'2',$AD,$98,$AC,$FF 
      DC.B      $AC,'f',$AB,$CE,$AB,'7',$AA,$A1 
      DC.B      $AA,$0C,$A9,'w',$A8,$E3,$A8,'P' 
      DC.B      $A7,$BE,$A7,'-',$A6,$9D,$A6,$0D 
      DC.B      $A5,$7F,$A4,$F1,$A4,'d',$A3,$D8 
      DC.B      $A3,'M',$A2,$C3,$A2,':',$A1,$B1 
      DC.B      $A1,'*',$A0,$A3,$A0,$1E,$9F,$99 
      DC.B      $9F,$15,$9E,$92,$9E,$10,$9D,$8F 
      DC.B      $9D,$0F,$9C,$90,$9C,$12,$9B,$95 
      DC.B      $9B,$19,$9A,$9E,'š#',$99,$AA
      DC.B      $99,'2',$98,$BB,$98,'D',$97,$CF 
      DC.B      $97,'[',$96,$E7,$96,'u',$96,$04 
      DC.B      $95,$94,$95,'%',$94,$B6,$94,'I' 
      DC.B      $93,$DD,$93,'r',$93,$08,$92,$9F 
      DC.B      $92,'7',$91,$D0,$91,'k',$91,$06 
      DC.B      $90,$A2,$90,'@',$8F,$DE,$8F,'~' 
      DC.B      $8F,$1F,$8E,$C0,'Žc',$8E,$07
      DC.B      $8D,$AC,$8D,'R',$8C,$FA,$8C,$A2 
      DC.B      $8C,'K',$8B,$F6,$8B,$A2,$8B,'O' 
      DC.B      $8A,$FD,$8A,$AC,$8A,'\',$8A,$0D 
      DC.B      $89,$C0,$89,'s',$89,'(',$88,$DE 
      DC.B      $88,$95,$88,'M',$88,$07,$87,$C1 
      DC.B      $87,'}',$87,':',$86,$F8,$86,$B7 
      DC.B      $86,'w',$86,'9',$85,$FC,$85,$BF 
      DC.B      $85,$84,$85,'K',$85,$12,$84,$DB 
      DC.B      $84,$A4,$84,'o„<',$84,$09 
      DC.B      $83,$D7,$83,$A7,$83,'x',$83,'J' 
      DC.B      $83,$1E,$82,$F2,$82,$C8,$82,$9F 
      DC.B      $82,'w',$82,'P',$82,'+',$82,$07 
      DC.B      $81,$E4,$81,$C2,$81,$A2,$81,$82 
      DC.B      $81,'dG,',$81,$11 
      DC.B      $80,$F8,$80,$E0,$80,$C9,$80,$B4 
      DC.B      $80,$9F,$80,$8C,$80,'z',$80,'j' 
      DC.B      $80,'Z',$80,'L',$80,'?',$80,'3' 
      DC.B      $80,')',$80,' ',$80,$18,$80,$11 
      DC.B      $80,$0B,$80,$07,$80,$04,$80,$02 
      DC.B      $80,$01,$80,$02,$80,$04,$80,$07 
      DC.B      $80,$0B,$80,$11,$80,$18,$80,' ' 
      DC.B      $80,')',$80,'3',$80,'?',$80,'L' 
      DC.B      $80,'Z',$80,'j',$80,'z',$80,$8C 
      DC.B      $80,$9F,$80,$B4,$80,$C9,$80,$E0 
      DC.B      $80,$F8,$81,$11,$81,',G' 
      DC.B      'd',$81,$82,$81,$A2,$81,$C2
      DC.B      $81,$E4,$82,$07,$82,'+',$82,'P' 
      DC.B      $82,'w',$82,$9F,$82,$C8,$82,$F2 
      DC.B      $83,$1E,$83,'J',$83,'x',$83,$A7 
      DC.B      $83,$D7,$84,$09,$84,'<„o' 
      DC.B      $84,$A4,$84,$DB,$85,$12,$85,'K' 
      DC.B      $85,$84,$85,$BF,$85,$FC,$86,'9' 
      DC.B      $86,'w',$86,$B7,$86,$F8,$87,':' 
      DC.B      $87,'}',$87,$C1,$88,$07,$88,'M' 
      DC.B      $88,$95,$88,$DE,$89,'(',$89,'s' 
      DC.B      $89,$C0,$8A,$0D,$8A,'\',$8A,$AC 
      DC.B      $8A,$FD,$8B,'O',$8B,$A2,$8B,$F6 
      DC.B      $8C,'K',$8C,$A2,$8C,$FA,$8D,'R' 
      DC.B      $8D,$AC,$8E,$07,'Žc',$8E,$C0
      DC.B      $8F,$1F,$8F,'~',$8F,$DE,$90,'@' 
      DC.B      $90,$A2,$91,$06,$91,'k',$91,$D0 
      DC.B      $92,'7',$92,$9F,$93,$08,$93,'r' 
      DC.B      $93,$DD,$94,'I',$94,$B6,$95,'%' 
      DC.B      $95,$94,$96,$04,$96,'u',$96,$E7 
      DC.B      $97,'[',$97,$CF,$98,'D',$98,$BB 
      DC.B      $99,'2',$99,$AA,'š#',$9A,$9E
      DC.B      $9B,$19,$9B,$95,$9C,$12,$9C,$90 
      DC.B      $9D,$0F,$9D,$8F,$9E,$10,$9E,$92 
      DC.B      $9F,$15,$9F,$99,$A0,$1E,$A0,$A3 
      DC.B      $A1,'*',$A1,$B1,$A2,':',$A2,$C3 
      DC.B      $A3,'M',$A3,$D8,$A4,'d',$A4,$F1 
      DC.B      $A5,$7F,$A6,$0D,$A6,$9D,$A7,'-' 
      DC.B      $A7,$BE,$A8,'P',$A8,$E3,$A9,'w' 
      DC.B      $AA,$0C,$AA,$A1,$AB,'7',$AB,$CE 
      DC.B      $AC,'f',$AC,$FF,$AD,$98,$AE,'2' 
      DC.B      $AE,$CD,$AF,'i',$B0,$06,$B0,$A3 
      DC.B      $B1,'A',$B1,$E0,$B2,$80,$B3,' ' 
      DC.B      $B3,$C1,$B4,'c',$B5,$06,$B5,$A9 
      DC.B      $B6,'M',$B6,$F2,$B7,$97,$B8,'=' 
      DC.B      $B8,$E4,$B9,$8C,$BA,'4',$BA,$DD 
      DC.B      $BB,$86,$BC,'0',$BC,$DB,$BD,$87 
      DC.B      $BE,'3',$BE,$E0,$BF,$8D,$C0,';' 
      DC.B      $C0,$EA,$C1,$99,$C2,'I',$C2,$F9 
      DC.B      $C3,$AA,$C4,'\',$C5,$0E,$C5,$C1 
      DC.B      $C6,'t',$C7,'(',$C7,$DC,$C8,$91 
      DC.B      $C9,'G',$C9,$FD,$CA,$B3,$CB,'j' 
      DC.B      $CC,'"',$CC,$DA,$CD,$93,$CE,'L' 
      DC.B      $CF,$05,$CF,$BF,$D0,'z',$D1,'4' 
      DC.B      $D1,$F0,$D2,$AC,$D3,'h',$D4,'%' 
      DC.B      $D4,$E2,$D5,$9F,$D6,']',$D7,$1B 
      DC.B      $D7,$DA,$D8,$99,$D9,'Y',$DA,$19 
      DC.B      $DA,$D9,$DB,$99,$DC,'Z',$DD,$1C 
      DC.B      $DD,$DD,$DE,$9F,$DF,'a',$E0,'$' 
      DC.B      $E0,$E7,$E1,$AA,$E2,'m',$E3,'1' 
      DC.B      $E3,$F5,$E4,$BA,$E5,'~',$E6,'C' 
      DC.B      $E7,$08,$E7,$CD,$E8,$93,$E9,'Y' 
      DC.B      $EA,$1F,$EA,$E5,$EB,$AB,$EC,'r' 
      DC.B      $ED,'9',$EE,$00,$EE,$C7,$EF,$8E 
      DC.B      $F0,'U',$F1,$1D,$F1,$E5,$F2,$AD 
      DC.B      $F3,'u',$F4,'=',$F5,$05,$F5,$CE 
      DC.B      $F6,$96,$F7,'_',$F8,$27,$F8,$F0 
      DC.B      $F9,$B9,$FA,$82,$FB,'J',$FC,$13 
      DC.B      $FC,$DC,$FD,$A5,$FE,'n',$FF,'7' 
      DC.B      $00,$00,$00,$C9,$01,$92,$02,'[' 
      DC.B      $03,'$',$03,$ED,$04,$B6,$05,'~' 
      DC.B      $06,'G',$07,$10,$07,$D9,$08,$A1 
      DC.B      $09,'j',$0A,'2',$0A,$FB,$0B,$C3 
      DC.B      $0C,$8B,$0D,'S',$0E,$1B,$0E,$E3 
      DC.B      $0F,$AB,$10,'r',$11,'9',$12,$00 
      DC.B      $12,$C7,$13,$8E,$14,'U',$15,$1B 
      DC.B      $15,$E1,$16,$A7,$17,'m',$18,'3' 
      DC.B      $18,$F8,$19,$BD,$1A,$82,$1B,'F' 
      DC.B      $1C,$0B,$1C,$CF,$1D,$93,$1E,'V' 
      DC.B      $1F,$19,$1F,$DC,' ',$9F,'!a'
      DC.B      '"#"',$E4,'#',$A6,'$g'
      DC.B      '%',$27,'%',$E7,'&',$A7,$27,'g' 
      DC.B      '(&(',$E5,')',$A3,'*a'
      DC.B      '+',$1E,'+',$DB,',',$98,'-T'
      DC.B      '.',$10,'.',$CC,'/',$86,'0A'
      DC.B      '0',$FB,'1',$B4,'2m3&'
      DC.B      '3',$DE,'4',$96,'5M6',$03 
      DC.B      '6',$B9,'7o8$8',$D8 
      DC.B      '9',$8C,':?:',$F2,';',$A4 
      DC.B      '<V=',$07,'=',$B7,'>g'
      DC.B      '?',$16,'?',$C5,'@sA '
      DC.B      'A',$CD,'ByC%C',$D0 
      DC.B      'DzE#E',$CC,'Ft'
      DC.B      'G',$1C,'G',$C3,'HiI',$0E 
      DC.B      'I',$B3,'JWJ',$FA,'K',$9D 
      DC.B      'L?L',$E0,'M',$80,'N '
      DC.B      'N',$BF,'O]O',$FA,'P',$97 
      DC.B      'Q3Q',$CE,'RhS',$01 
      DC.B      'SšT2T',$C9,'U_'
      DC.B      'U',$F4,'V',$89,'W',$1D,'W',$B0 
      DC.B      'XBX',$D3,'YcY',$F3 
      DC.B      'Z[',$0F,'[',$9C,'\('
      DC.B      '\',$B3,']=]',$C6,'^O'
      DC.B      '^',$D6,'_]_',$E2,'`g'
      DC.B      '`',$EB,'ana',$F0,'bq'
      DC.B      'b',$F1,'cpc',$EE,'dk'
      DC.B      'd',$E7,'ebe',$DD,'fV'
      DC.B      'f',$CE,'gEg',$BC,'h1'
      DC.B      'h',$A5,'i',$19,'i',$8B,'i',$FC 
      DC.B      'jlj',$DB,'kJk',$B7 
      DC.B      'l#lŽl',$F8,'ma'
      DC.B      'm',$C9,'n0n',$95,'n',$FA 
      DC.B      'o^o',$C0,'p"p',$82 
      DC.B      'p',$E1,'q@q',$9D,'q',$F9 
      DC.B      'rTr',$AE,'s',$06,'s^'
      DC.B      's',$B5,'t',$0A,'t^t',$B1 
      DC.B      'u',$03,'uTu',$A4,'u',$F3 
      DC.B      'v@v',$8D,'v',$D8,'w"'
      DC.B      'wkw',$B3,'w',$F9,'x?'
      DC.B      'x',$83,'x',$C6,'y',$08,'yI'
      DC.B      'y',$89,'y',$C7,'z',$04,'zA'
      DC.B      'z|z',$B5,'z',$EE,'{%'
      DC.B      '{\{',$91,'{',$C4,'{',$F7 
      DC.B      '|)|Y|',$88,'|',$B6 
      DC.B      '|',$E2,'}',$0E,'}8}a'
      DC.B      '}',$89,'}',$B0,'}',$D5,'}',$F9 
      DC.B      '~',$1C,'~>~^~~'
      DC.B      '~',$9C,'~',$B9,'~',$D4,'~',$EF 
      DC.B      $7F,$08,$7F,' ',$7F,'7',$7F,'L' 
      DC.B      $7F,'a',$7F,'t',$7F,$86,$7F,$96 
      DC.B      $7F,$A6,$7F,$B4,$7F,$C1,$7F,$CD 
      DC.B      $7F,$D7,$7F,$E0,$7F,$E8,$7F,$EF 
      DC.B      $7F,$F5,$7F,$F9,$7F,$FC,$7F,$FE 
	EVEN

WORDS	EQU	20
START_DATA:
OF_P	SET	0
	REPT	WORDS
	DC.W	%1111111111111111,OF_P
	DC.W	%0111111111111111,OF_P
	DC.W	%0011111111111111,OF_P
	DC.W	%0001111111111111,OF_P
	DC.W	%0000111111111111,OF_P
	DC.W	%0000011111111111,OF_P
	DC.W	%0000001111111111,OF_P
	DC.W	%0000000111111111,OF_P
	DC.W	%0000000011111111,OF_P
	DC.W	%0000000001111111,OF_P
	DC.W	%0000000000111111,OF_P
	DC.W	%0000000000011111,OF_P
	DC.W	%0000000000001111,OF_P
	DC.W	%0000000000000111,OF_P
	DC.W	%0000000000000011,OF_P
	DC.W	%0000000000000001,OF_P
OF_P	SET	OF_P+1428
	ENDR
END_DATA:
OF_P	SET	0
	REPT	WORDS
	DC.W	%1000000000000000,OF_P
	DC.W	%1100000000000000,OF_P
	DC.W	%1110000000000000,OF_P
	DC.W	%1111000000000000,OF_P
	DC.W	%1111100000000000,OF_P
	DC.W	%1111110000000000,OF_P
	DC.W	%1111111000000000,OF_P
	DC.W	%1111111100000000,OF_P
	DC.W	%1111111110000000,OF_P
	DC.W	%1111111111000000,OF_P
	DC.W	%1111111111100000,OF_P
	DC.W	%1111111111110000,OF_P
	DC.W	%1111111111111000,OF_P
	DC.W	%1111111111111100,OF_P
	DC.W	%1111111111111110,OF_P
	DC.W	%1111111111111111,OF_P
OF_P	SET	OF_P+84
	ENDR


POLY_FAST:
* TAB 1/Y * 65536 ( bis max 400 Y-ZEILEN )
 DC.W 65535		; FUCK DA BUG...
 DC.W 65535
 DC.W 32768,21845,16384,13107,10922,9362,8192,7281,6553
 DC.W 5957,5461,5041,4681,4369,4096,3855,3640,3449,3276
 DC.W 3120,2978,2849,2730,2621,2520,2427,2340,2259,2184
 DC.W 2114,2048,1985,1927,1872,1820,1771,1724,1680,1638
 DC.W 1598,1560,1524,1489,1456,1424,1394,1365,1337,1310
 DC.W 1285,1260,1236,1213,1191,1170,1149,1129,1110,1092
 DC.W 1074,1057,1040,1024,1008,992,978,963,949,936
 DC.W 923,910,897,885,873,862,851,840,829,819
 DC.W 809,799,789,780,771,762,753,744,736,728
 DC.W 720,712,704,697,689,682,675,668,661,655
 DC.W 648,642,636,630,624,618,612,606,601,595
 DC.W 590,585,579,574,569,564,560,555,550,546
 DC.W 541,537,532,528,524,520,516,512,508,504
 DC.W 500,496,492,489,485,481,478,474,471,468
 DC.W 464,461,458,455,451,448,445,442,439,436
 DC.W 434,431,428,425,422,420,417,414,412,409
 DC.W 407,404,402,399,397,394,392,390,387,385
 DC.W 383,381,378,376,374,372,370,368,366,364
 DC.W 362,360,358,356,354,352,350,348,346,344
 DC.W 343,341,339,337,336,334,332,330,329,327
 DC.W 326,324,322,321,319,318,316,315,313,312
 DC.W 310,309,307,306,304,303,302,300,299,297
 DC.W 296,295,293,292,291,289,288,287,286,284
 DC.W 283,282,281,280,278,277,276,275,274,273
 DC.W 271,270,269,268,267,266,265,264,263,262
 DC.W 261,260,259,258,257,256,255,254,253,252
 DC.W 251,250,249,248,247,246,245,244,243,242
 DC.W 241,240,240,239,238,237,236,235,234,234
 DC.W 233,232,231,230,229,229,228,227,226,225
 DC.W 225,224,223,222,222,221,220,219,219,218
 DC.W 217,217,216,215,214,214,213,212,212,211
 DC.W 210,210,209,208,208,207,206,206,205,204
 DC.W 204,203,202,202,201,201,200,199,199,198
 DC.W 197,197,196,196,195,195,194,193,193,192
 DC.W 192,191,191,190,189,189,188,188,187,187
 DC.W 186,186,185,185,184,184,183,183,182,182
 DC.W 181,181,180,180,179,179,178,178,177,177
 DC.W 176,176,175,175,174,174,173,173,172,172
 DC.W 172,171,171,170,170,169,169,168,168,168
 DC.W 167,167,166,166,165,165,165,164,164,163

SIN_180:
 DC.W  3,5,7,9,11,14,16
 DC.W  18,20,22,25,27,29,31
 DC.W  33,36,38,40,42,44,46
 DC.W  48,51,53,55,57,59,61
 DC.W  63,65,67,69,71,73,75
 DC.W  77,79,81,83,85,87,89
 DC.W  91,93,95,97,99,100,102
 DC.W  104,106,108,109,111,113,114
 DC.W  116,118,120,121,123,124,126
 DC.W  127,129,130,132,134,135,136
 DC.W  138,139,141,142,143,145,146
 DC.W  147,149,150,151,152,153,154
 DC.W  155,157,158,159,160,161,162
 DC.W  163,164,164,165,166,167,168
 DC.W  169,169,170,171,171,172,173
 DC.W  173,174,174,175,175,176,176
 DC.W  177,177,177,178,178,178,179
 DC.W  179,179,179,179,179,179,179
 DC.W  179,179,179,179,179,179,179
 DC.W  179,179,179,178,178,178,177
 DC.W  177,177,176,176,175,175,174
 DC.W  174,173,173,172,171,171,170
 DC.W  169,169,168,167,166,165,165
 DC.W  164,163,162,161,160,159,158
 DC.W  157,156,154,153,152,151,150
 DC.W  149,147,146,145,143,142,141
 DC.W  139,138,137,135,134,132,131
 DC.W  129,128,126,125,123,121,120
 DC.W  118,116,115,113,111,110,108
 DC.W  106,104,102,100,99,97,95
 DC.W  93,91,89,87,85,83,82
 DC.W  80,78,76,74,72,69,67
 DC.W  65,63,61,59,57,55,53
 DC.W  51,49,47,44,42,40,38
 DC.W  36,34,32,29,27,25,23
 DC.W  21,18,16,14,12,10,7
 DC.W  5,3,1,-1,-4,-6,-8
 DC.W  -10,-12,-15,-17,-19,-21,-23
 DC.W  -26,-28,-30,-32,-34,-37,-39
 DC.W  -41,-43,-45,-47,-49,-52,-54
 DC.W  -56,-58,-60,-62,-64,-66,-68
 DC.W  -70,-72,-74,-76,-78,-80,-82
 DC.W  -84,-86,-88,-90,-92,-94,-96
 DC.W  -98,-100,-101,-103,-105,-107,-109
 DC.W  -110,-112,-114,-115,-117,-119,-121
 DC.W  -122,-124,-125,-127,-128,-130,-131
 DC.W  -133,-135,-136,-137,-139,-140,-142
 DC.W  -143,-144,-146,-147,-148,-150,-151
 DC.W  -152,-153,-154,-155,-156,-158,-159
 DC.W  -160,-161,-162,-163,-164,-165,-165
 DC.W  -166,-167,-168,-169,-170,-170,-171
 DC.W  -172,-172,-173,-174,-174,-175,-175
 DC.W  -176,-176,-177,-177,-178,-178,-178
 DC.W  -179,-179,-179,-180,-180,-180,-180
 DC.W  -180,-180,-180,-180,-180,-180,-180
 DC.W  -180,-180,-180,-180,-180,-180,-180
 DC.W  -179,-179,-179,-178,-178,-178,-177
 DC.W  -177,-176,-176,-175,-175,-174,-174
 DC.W  -173,-172,-172,-171,-170,-170,-169
 DC.W  -168,-167,-166,-166,-165,-164,-163
 DC.W  -162,-161,-160,-159,-158,-157,-155
 DC.W  -154,-153,-152,-151,-150,-148,-147
 DC.W  -146,-144,-143,-142,-140,-139,-138
 DC.W  -136,-135,-133,-132,-130,-129,-127
 DC.W  -126,-124,-122,-121,-119,-117,-116
 DC.W  -114,-112,-111,-109,-107,-105,-103
 DC.W  -101,-100,-98,-96,-94,-92,-90
 DC.W  -88,-86,-84,-83,-81,-79,-77
 DC.W  -75,-73,-70,-68,-66,-64,-62
 DC.W  -60,-58,-56,-54,-52,-50,-48
 DC.W  -45,-43,-41,-39,-37,-35,-33
 DC.W  -30,-28,-26,-24,-22,-19,-17
 DC.W  -15,-13,-11,-8,-6,-4,-2,0
MUZAK:
	INCBIN	A:\BIGALEC.SND
	EVEN

TRANSED1:
	DC.L	TRANSED3D
TRANSED2:
	DC.L	TRANSED3D+200
TRANSED3D:
	DS.W	200

	SECTION	BSS
	
	DS.W	400
MY_STACK:
	DS.W	10
SCREEN2:
	DS.L	1
SCREENS:
	DS.W	65256
POLY_X:
	DS.W	2000				; BUF X-START/END
DRAW_INFO:
	DS.W	100				; FLEX-INFOBUF
	