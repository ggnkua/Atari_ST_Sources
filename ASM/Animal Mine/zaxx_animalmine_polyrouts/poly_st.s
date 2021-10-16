;==================================================================
;   POLYCALC fÅr falcon !!! mit 100% clipping
; 	DATE 1/6/93
;==================================================================

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
TESTA:
	MOVE.W	#$25,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP

	MOVE.L	SCREEN2,D0
	MOVE.L	SCREEN1,SCREEN2
	MOVE.L	D0,SCREEN1
	LSR.W	#8,D0
	MOVE.L	D0,$FFFF8200.W

	MOVE.L	SCREEN1,A0
	MOVEQ	#0,D0
	MOVE.W	#32000/160-1,D1
	MOVE.L	#160,A1
CLR:
	MOVE.L	D0,(A0)
	MOVE.L	D0,8(A0)
	MOVE.L	D0,16(A0)
	MOVE.L	D0,24(A0)
	MOVE.L	D0,32(A0)
	MOVE.L	D0,40(A0)
	MOVE.L	D0,48(A0)
	MOVE.L	D0,56(A0)
	MOVE.L	D0,64(A0)
	MOVE.L	D0,72(A0)
	MOVE.L	D0,80(A0)
	MOVE.L	D0,88(A0)
	MOVE.L	D0,96(A0)
	MOVE.L	D0,104(A0)
	MOVE.L	D0,112(A0)
	MOVE.L	D0,120(A0)
	MOVE.L	D0,128(A0)
	MOVE.L	D0,136(A0)
	MOVE.L	D0,144(A0)
	MOVE.L	D0,152(A0)
	ADD.L	A1,A0
	DBF	D1,CLR	

	BSR	TRANSFORM
	MOVE.W	#$744,$FFFF8240.W
	BSR	TEST_CALC
	MOVE.W	#$004,$FFFF8240.W
	BSR	TEST_DRAW	
 	ADD.W	#-6,DREH_X
	
	MOVE.W	#$777,$FFFF8240.W

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
	SUBQ.W	#1,MOVE_Z
NOK5:
	CMPI.W	#$4E,D0
	BNE.S	NOK6
	ADDQ.W	#1,MOVE_Z
NOK6:
	
	

	CMPI.B	#$39+$80,D0
	BNE	TESTA
	MOVE.W	#7,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	
	CLR.W	-(SP)
	TRAP	#1
	
	

*==============================================================
* V1.2			 POLYGON BERECHNEN		10/6/93
*==============================================================
* BENUTZT D0-D5/A0-A5
* MIT ADDX-TECHNIK
*	A0 = ZEIGER AUF POLY-STRUC
*	A1 = ZEIGER AUF TRANSED-3D
*	A3 = ZEIGER AUF POLY_X
*	A5 = POLYFASTTAB MIT 1/Y WERTEN FöR MULU
*	A6 = DRAW_INFO
*	
* DATA-STRUC DER POLYFLéCHE
*	DC.W	0	; VISI FLAG
*	DC.W	0	; POLY-FARBE
*	DC.W	anz-1	; ANZ DER PUNKTE ( MIN 3-1!)	
*	DC.W	anz*4	; DIE PUNKTE
*
*==============================================================
X_MIN:	DC.W	0
X_MAX	DC.W	319		; SCREEN WERTE FöR CLIP + CALC
Y_MIN	DC.W	0
Y_MAX	DC.W	199
GENAU	DC.L	$7FFF0000	; = 0.5
ALL_CLIP:
		MOVE.L	#-1,(A6)+
		MOVE.W	#$070,$FFFF8240.W
		RTS

TEST_CALC:
		LEA	POLY_STRUC,A0
		LEA	TRANSED_3D,A1
		LEA	POLY_X,A3
		LEA	POLY_FAST,A5	
		LEA	DRAW_INFO,A6
	
		TST.L	(A0)+			; ONLY BETA !!		

* 3-D PUNKTE HOLEN UND 2* HINTEREINANDER ABLEGEN... 
		MOVE.W	(A0)+,D0		; ANZ DER PUNKTE
		MOVE.W	D0,D1			; COUNTER LADEN
		LEA	ECK_BUF(PC),A2
		MOVE.L	A2,D3
		LEA	4(A2,D0.W*4),A4
FILL_ECK_BUF:				; PUNKTE IN DOUBLEBUFFER EINTRAGEN
		MOVE.W	(A0)+,D2		; PUNKT HOLEN
 		MOVE.L	(A1,D2.W*4),D2
		MOVE.L	D2,(A2)+		; X/Y-WERT SAVE
		MOVE.L	D2,(A4)+		; X/Y-WERT SAVE *2
		DBF	D1,FILL_ECK_BUF		; FAST LOOP

* BUFFER NACH MIN-MAX Y SCANNEN
		MOVE.L	D3,A4
		MOVE.W	#32000,D2		; MIN/MAX-Y SETZEN (INVERT)
		MOVE.W	#-32000,D3
		MOVE.W	D2,D4
		MOVE.W	D3,D5			; MIN/MAX-X SETZEN (INVERT)
		MOVE.W	D0,D6
SCAN_MIN_MAX_X_Y:
* SUCH GRôSTEN UND KLEINSTEN X/Y-WERT IN BUF
		MOVE.L	(A4)+,D1
		CMP.W	D1,D2			; TEST Y-MIN ??
		BLT.S	NO_Y_MIN
		MOVE.W	D1,D2			; NEW Y-MIN
		MOVE.L	A4,A2			; A2 = ZEIGER AUF Y-MIN		
NO_Y_MIN:
		CMP.W	D1,D3			; TEST Y-MAX ??
		BGT.S	NO_Y_MAX
		MOVE.W	D1,D3			; NEW Y-MAX
NO_Y_MAX:
		SWAP	D1
		CMP.W	D1,D4			; TEST X-MIN ??
		BLT.S	NO_X_MIN
		MOVE.W	D1,D4			; NEW X-MIN
NO_X_MIN:
		CMP.W	D1,D5			; TEST X-MAX ??
		BGT.S	NO_X_MAX
		MOVE.W	D1,D5			; NEW X-MAX
NO_X_MAX:
		DBF	D0,SCAN_MIN_MAX_X_Y	; FAST SCAN
		LEA	4(A2,D6.W*4),A4		; A4 = ZEIGER Y-MIN2
		SUBQ.L	#4,A2			; CORRECT POINTER
* TEST AUF FULL CLIP..
		CMP.W	X_MIN(PC),D5
		BLT	ALL_CLIP
		CMP.W	X_MAX(PC),D4		; LINKS RECHTS GANZ OUT ?
		BGT	ALL_CLIP
		CMP.W	Y_MIN(PC),D3
		BLT	ALL_CLIP
		CMP.W	Y_MAX(PC),D2		; OBEN UNTEN GANZ OUT ?
		BGT 	ALL_CLIP
* TEST AUF HALF CLIP
		CMP.W	Y_MIN(PC),D2
		BLT	HALF_CLIP
		CMP.W	Y_MAX(PC),D3
		BGT	HALF_CLIP
		CMP.W	X_MIN(PC),D4
		BLT	HALF_CLIP
		CMP.W	X_MAX(PC),D5
		BGT	HALF_CLIP
					
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
		MOVE.L	(A2)+,D0		; X/Y P1
		MOVE.L	(A2),D4			
		MOVE.W	D4,D5
		SWAP	D4
		CMP.W	D3,D5
		BEQ.S	LAST_RIGHT_CALC
		BSR.S	CALC_STEPS
		BRA.S	CALC_RIGHT
LAST_RIGHT_CALC:
		BSR.S	CALC_STEPS
* JETZT DAS POLY VON Y-MIN NACH Y-MAX LINKSRUM BERECHNEN
*
		MOVE.L	A3,(A6)+		; SAVE LEFT IN DRAW_INFO
CALC_LEFT:
		MOVE.L	-(A4),D0		; X/Y P1
		MOVE.L	-4(A4),D4			
		MOVE.W	D4,D5
		SWAP	D4
		CMP.W	D3,D5
		BEQ.S	LAST_LEFT_CALC
		BSR.S	CALC_STEPS
		BRA.S	CALC_LEFT
LAST_LEFT_CALC:

CALC_STEPS:
		MOVE.L	GENAU(PC),D2 
		SUB.W	D0,D5			; D5 = Y
		SWAP	D0
		SUB.W	D0,D4			; D4 = X
* TEST LINKS <-> RECHTS ??
		TST.W	D4									
		BEQ.S	ZERO_CALC	
 		BGE.S	NACH_RECHTS
		NEG.W	D4			; CHANGE +-
		MOVE.W	(A5,D5.W*2),D1
		MULU.W	D1,D4
		SWAP	D4
* D4 HIGH = NACHKOMMA				
* D4 LOW  = VORKOMMA
* D2 LOW  = X-START
* D2 HIGH = STEP-X OVERFLOW 
* D5	  = Y
		SUBQ.W	#1,D5
		BLT.S	SPECIAL	
		SUB.L	D4,D2
		MOVE.W	D0,D2
C_POLYLOOP:
		SUBX.L	D4,D2
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		DBF	D5,C_POLYLOOP
		RTS
SPECIAL:
		SUB.L	D4,D2
		MOVE.W	D0,D2
		SUBX.L	D4,D2
		MOVE.W	D2,(A3)			; X-WERT SICHERN
		RTS
ZERO_CALC:
		MOVE.W	D0,(A3)+		; SENKRECHT ->NO CALC
		SUBQ.W	#1,D5
		BGT.S	ZERO_CALC
		RTS
NACH_RECHTS:
		MOVE.W	(A5,D5.W*2),D1
		MULU.W	D1,D4
		SWAP	D4
	
* D4 HIGH = NACHKOMMA				
* D4 LOW  = VORKOMMA
* D2 LOW  = X-START
* D2 HIGH = STEP-X OVERFLOW 
* D5	  = Y
		SUBQ.W	#1,D5
		BLT.S	SPECIAL_C
		ADD.L	D4,D2
		MOVE.W	D0,D2
C_POLYLOOP2:
		ADDX.L	D4,D2			; NACHKOMMA OVERFLOW
		MOVE.W	D2,(A3)+		; X-WERT SICHERN
		DBF	D5,C_POLYLOOP2
		RTS
SPECIAL_C:
		ADD.L	D4,D2
		MOVE.W	D0,D2
		ADDX.L	D4,D2			; NACHKOMMA OVERFLOW
		MOVE.W	D2,(A3)			; X-WERT SICHERN
		RTS
CLIPED_CALC:
		MOVE.W	D2,(A6)+		; Y-START
		MOVE.W	D3,D0
		SUB.W	D2,D0
		MOVE.W	D0,(A6)+		; dY		

		MOVE.L	A3,(A6)+		; SAVE RIGTH IN DRAW_INFO
CALC_RIGHT_CLIP:
		MOVE.L	(A2)+,D0		; X/Y P1
		MOVE.L	(A2),D4			
		MOVE.W	D4,D5
		SWAP	D4
		CMP.W	D3,D5
		BEQ.S	LAST_RIGHT_CALC_CLIP
		BSR	CALC_STEPS
		BRA.S	CALC_RIGHT_CLIP
LAST_RIGHT_CALC_CLIP:
		BSR	CALC_STEPS

		MOVE.L	A3,(A6)+		; SAVE LEFT IN DRAW_INFO
CALC_LEFT_CLIP:
		MOVE.L	(A4)+,D0		; X/Y P1
		MOVE.L	(A4),D4			
		MOVE.W	D4,D5
		SWAP	D4
		CMP.W	D3,D5
		BEQ.S	LAST_LEFT_CALC_CLIP
		BSR	CALC_STEPS
		BRA.S	CALC_LEFT_CLIP
LAST_LEFT_CALC_CLIP:
		BRA	CALC_STEPS


*==============================================================
* V1.0			 POLYGON CLIP			26/6/93
*==============================================================
*
*	A2 = ZEIGER AUF Y-MIN (LEFT)
*	A4 = ZEIGER AUF Y-MIN (RIGHT)+4 !!
*	D6 = Y-MAX
*
*	A5 = POLYFASTTAB MIT 1/Y WERTEN FöR MULU
*
*==============================================================

HALF_CLIP:
* START MIT RIGHTCLIP...
		MOVEM.L	A0-A1/D7,-(SP)		; SAVE
		LEA	SAVER_MIN_MAX(PC),A0
		MOVEM.W	D2-D5,(A0)		; SAVE ALTE MIN/MAX
		LEA	ALL_CLIP_BUF(PC),A0	; BUFFER FöR RIGHT-CLIP
		MOVE.W	D3,D6			; D6 = Y-MAX
		MOVEQ	#0,D7			; POINTS COUNTER
		MOVE.W	#32000,D0			
		MOVE.W	D0,START_MEGA_LEFT
		MOVE.W	D0,START_MEGA_RIGHT
		NEG.W	D0
		MOVE.W	D0,END_MEGA_LEFT
		MOVE.W	D0,END_MEGA_RIGHT
RIGHT_CLIP_LOOP:
		MOVE.L	(A2)+,D0		; X/Y HOLEN
		MOVE.L	(A2),D2
		MOVE.W	D0,D1			; D1 = Y1 
		SWAP	D0			; D0 = X1
		MOVE.W	D2,D3			; D3 = Y2 
		SWAP	D2			; D2 = X2			
		CMP.W	D3,D6			; TEST OB ENDE ??
		BEQ.S	LAST_RIGHT_CLIP
		BSR	CLIP_POINTS
		BRA.S	RIGHT_CLIP_LOOP
LAST_RIGHT_CLIP:
		BSR	CLIP_POINTS
		SWAP	D7
		LEA	ALL_CLIP_BUF+200(PC),A0	; BUF LEFT CLIP
LEFT_CLIP_LOOP:
		MOVE.L	-(A4),D0
		MOVE.L	-4(A4),D2
		MOVE.W	D0,D1
		SWAP	D0
		MOVE.W	D2,D3
		SWAP	D2
		CMP.W	D3,D6
		BEQ.S	LAST_LEFT_CLIP
		BSR	CLIP_POINTS
		BRA.S	LEFT_CLIP_LOOP
LAST_LEFT_CLIP:
		BSR	CLIP_POINTS
		LEA	ALL_CLIP_BUF(PC),A2	; A2 = BUFFER FöR RIGHT-CLIP
		LEA	ALL_CLIP_BUF+200(PC),A4	; A4 = BUF LEFT-CLIP
		TST.L	D7
		BEQ	FUCK_CLIP		; KEINE PUNKTE ??
		MOVE.W	D7,D6			; D6 = COUNT LEFT
		MOVE.L	D7,D5
		SWAP	D5			; D5 = COUNT RIGHT
		MOVEM.L	(SP)+,A0-A1/D7		; REPLACE


* 
* NUN ERGENZEN DES LINKE  UND RECHTEN BUFS
*  
		TST.W	D6			; POINTS LEFT IN ??
		BGT.S	NO_BACK_OUT
		MOVE.W	2(A2),D2
		MOVE.W	D2,2(A4)		; D2 = Y-MIN
		MOVE.W	X_MIN(PC),(A4)

  		MOVE.W	-2(A2,D5.W*4),D3
		MOVE.W	D3,6(A4)		; D3 = Y-MAX
		MOVE.W	X_MIN(PC),4(A4)
		ADDQ.W	#2,D6
		BRA	MEGA_BUGY		
NO_BACK_OUT:				
		TST.W	D5			; POINTS RIGHT IN ??
		BGT	NO_BACK_OUT2
		MOVE.W	2(A4),D2
		MOVE.W	D2,2(A2)		; D2 = Y-MIN
		MOVE.W	X_MAX(PC),(A2)	

 		MOVE.L	-4(A4,D6.W*4),D3
		MOVE.W	D3,6(A2)		; D3 = Y-MAX
		MOVE.W	X_MAX(PC),4(A2)
		ADDQ.W	#2,D5
MEGA_BUGY:
		MOVE.W	START_MEGA_LEFT(PC),D0
		ADD.W	END_MEGA_LEFT(PC),D0
		BEQ	CLIPED_CALC	
		MOVE.W	START_MEGA_RIGHT(PC),D0
		ADD.W	END_MEGA_RIGHT(PC),D0
		BEQ	CLIPED_CALC	

		MOVE.W	START_MEGA_LEFT(PC),D0
		CMP.W	START_MEGA_RIGHT(PC),D0
		BGE.S	IS_MINI
		MOVE.W	START_MEGA_RIGHT,D0
IS_MINI:
		MOVE.W	END_MEGA_LEFT(PC),D1
		CMP.W	END_MEGA_RIGHT(PC),D1
		BLE.S	IS_MINI2
		MOVE.W	END_MEGA_RIGHT(PC),D1
IS_MINI2:
		CMP.W	D0,D1
		BLT	CLIPED_CALC

		CMP.W	2(A2),D0
		BGE.S	COR_MEGA
		SUBQ.L	#4,A2
		MOVE.W	D0,2(A2)
		MOVE.W	X_MAX(PC),(A2)
		ADDQ.W	#1,D5
		MOVE.W	D0,D2			; NEW Y-MIN
COR_MEGA:
		CMP.W	2(A4),D0
		BGE.S	COR_MEGA2
		SUBQ.L	#4,A4
		MOVE.W	D0,2(A4)
		MOVE.W	X_MIN(PC),(A4)
		ADDQ.W	#1,D6
		MOVE.W	D0,D2
COR_MEGA2:
		CMP.W	-2(A2,D5.W*4),D1
		BLE.S	COR_MEGA3
		MOVE.W	D1,2(A2,D5.W*4)
		MOVE.W	X_MAX(PC),(A2,D5.W*4)
		ADDQ.W	#1,D5
		MOVE.W	D1,D3
COR_MEGA3:
		CMP.W	-2(A4,D6.W*4),D1
		BLE.S	COR_MEGA4
		MOVE.W	D1,2(A4,D6.W*4)
		MOVE.W	X_MIN(PC),(A4,D6.W*4)
		ADDQ.W	#1,D6
		MOVE.W	D1,D3
COR_MEGA4:
		BRA	CLIPED_CALC
NO_BACK_OUT2:		
		MOVE.W	2(A2),D0		; Y-MIN RIGHT.. 
		CMP.W	2(A4),D0		; START-Y EQUAL ??	
		BEQ.S	NO_CHANGES
		BGT.S	MOVEX1
		SUBQ.L	#4,A4
		ADDQ.W	#1,D6			; INC POINTS-LEFT
		MOVE.W	2(A2),2(A4)								
		MOVE.W	X_MIN(PC),(A4)
		BRA.S	NO_CHANGES
MOVEX1:
		SUBQ.L	#4,A2
		ADDQ.W	#1,D5			; INC POINTS-RIGHT
		MOVE.W	2(A4),2(A2)			
		MOVE.W	X_MAX(PC),(A2)
NO_CHANGES:
		MOVE.W	2(A2),D2		; D2 = Y-MIN
		
		MOVE.W	-2(A2,D5.W*4),D3	; D3 = Y-MAX
		CMP.W	-2(A4,D6.W*4),D3
		BEQ	ALL_CHECK
		BLT.S	MOVEX2
		MOVE.W	-2(A2,D5.W*4),D3		; NEW Y-MAX
		MOVE.W	D3,2(A4,D6.W*4)
		MOVE.W	X_MIN(PC),(A4,D6.W*4)
		ADDQ.W	#1,D6
		BRA	ALL_CHECK
MOVEX2:
		MOVE.W	-2(A4,D6.W*4),D3		; NEW Y-MAX
		MOVE.W	D3,2(A2,D5.W*4)
		MOVE.W	X_MAX(PC),(A2,D5.W*4)
		ADDQ.W	#1,D5
ALL_CHECK:
		MOVE.W	START_MEGA_LEFT(PC),D0
		ADD.W	END_MEGA_LEFT(PC),D0
		BEQ	CLIPED_CALC	
		MOVE.W	START_MEGA_RIGHT(PC),D0
		ADD.W	END_MEGA_RIGHT(PC),D0
		BEQ	CLIPED_CALC	

		MOVE.W	START_MEGA_LEFT(PC),D0
		CMP.W	START_MEGA_RIGHT(PC),D0
		BGE.S	IS_MINI8
		MOVE.W	START_MEGA_RIGHT,D0
IS_MINI8:
		MOVE.W	END_MEGA_LEFT(PC),D1
		CMP.W	END_MEGA_RIGHT(PC),D1
		BLE.S	IS_MINI9
		MOVE.W	END_MEGA_RIGHT(PC),D1
IS_MINI9:
		CMP.W	D0,D1
		BLT	CLIPED_CALC

		CMP.W	2(A2),D0
		BGE.S	COR_MEGA5
		SUBQ.L	#4,A2
		MOVE.W	D0,2(A2)
		MOVE.W	X_MAX(PC),(A2)
		ADDQ.W	#1,D5
		MOVE.W	D0,D2			; NEW Y-MIN
COR_MEGA5:
		CMP.W	2(A4),D0
		BGE.S	COR_MEGA6
		SUBQ.L	#4,A4
		MOVE.W	D0,2(A4)
		MOVE.W	X_MIN(PC),(A4)
		ADDQ.W	#1,D6
		MOVE.W	D0,D2
COR_MEGA6:
		CMP.W	-2(A2,D5.W*4),D1
		BLE.S	COR_MEGA7
		MOVE.W	D1,2(A2,D5.W*4)
		MOVE.W	X_MAX(PC),(A2,D5.W*4)
		ADDQ.W	#1,D5
		MOVE.W	D1,D3
COR_MEGA7:
		CMP.W	-2(A4,D6.W*4),D1
		BLE.S	COR_MEGA8
		MOVE.W	D1,2(A4,D6.W*4)
		MOVE.W	X_MIN(PC),(A4,D6.W*4)
		ADDQ.W	#1,D6
		MOVE.W	D1,D3
COR_MEGA8:
		BRA	CLIPED_CALC
FUCK_CLIP:
		MOVE.W	START_MEGA_LEFT(PC),D0
		ADD.W	END_MEGA_LEFT(PC),D0
		BEQ	REAL_FUCK_CLIP	
		MOVE.W	START_MEGA_RIGHT(PC),D0
		ADD.W	END_MEGA_RIGHT(PC),D0
		BEQ	REAL_FUCK_CLIP	
		MOVE.W	START_MEGA_LEFT(PC),D2
		CMP.W	START_MEGA_RIGHT(PC),D2
		BGE.S	IS_MINI3
		MOVE.W	START_MEGA_RIGHT,D2
IS_MINI3:
		MOVE.W	END_MEGA_LEFT(PC),D3
		CMP.W	END_MEGA_RIGHT(PC),D3
		BLE.S	IS_MINI4
		MOVE.W	END_MEGA_RIGHT(PC),D3
IS_MINI4:
		CMP.W	D2,D3
		BLT.S	REAL_FUCK_CLIP
		MOVE.W	D2,2(A4)
		MOVE.W	X_MIN(PC),(A4)
		MOVE.W	D2,2(A2)
		MOVE.W	X_MAX(PC),(A2)
		MOVE.W	D3,6(A4)
		MOVE.W	X_MIN(PC),4(A4)
		MOVE.W	D3,6(A2)
		MOVE.W	X_MAX(PC),4(A2)
		MOVEM.L	(SP)+,A0-A1/D7		; REPLACE
		BRA	CLIPED_CALC
REAL_FUCK_CLIP:
		MOVE.L	#-1,(A6)
		MOVEM.L	(SP)+,A0-A1/D7		; REPLACE
		RTS				; -> PUNKTE SO UNGöNSTIG
						; DAS KEINER DRIN IST...				
			
CLIP_POINTS:
		CMP.W	Y_MIN(PC),D1		; TEST AUF CLIP ?? Y-OBEN...
		BGE.S	NO_CLIP_Y_MIN		; JUMP WENN PUNKT IN... 
		MOVE.W	Y_MIN(PC),D4		; NEUER Y-WERT
	 	SUB.W	D3,D4			; Y1 
		BMI.S	IN_LIM1			; JUMP WENN Y2 AUCH OUT 
		RTS
IN_LIM1:
		NEG.W	D1
		NEG.W	D0			; C +-
		ADD.W	D3,D1			; Y2 
		ADD.W	D2,D0			; X 
		MULS	D4,D0			; X / Y1 ( KURZ )  
		DIVS	D1,D0			; XNEU / Y2 (LANG)			 
		ADD.W	D2,D0			; ADD X2 TO X -> NEUER CLIP-X 
		MOVE.W	Y_MIN(PC),D1		; Y = CLIP - MIN
NO_CLIP_Y_MIN:
		CMP.W	Y_MAX(PC),D3		; TEST Y-MAX UNTEN OUT.. ??
		BLE.S	NO_CLIP_Y_MAX 
		MOVE.W	Y_MAX(PC),D4		; D4 = Y-CLIP 
      		SUB.W	D1,D4			; dY1 
		BPL.S	IN_LIM2			; ZWEITER PUNKT AUCH OUT ?? 
		RTS
IN_LIM2:
		NEG.W	D2			; C+-
		NEG.W	D3
		ADD.W	D0,D2 
		ADD.W	D1,D3			; CLIP STRAHLENSATZ 
		MULS	D4,D2 
		DIVS	D3,D2 
		ADD.W	D0,D2			; D2 = NEUER X 
		MOVE.W	Y_MAX(PC),D3		; Y = Y-CLIP MAX
NO_CLIP_Y_MAX:
		CMP.W	D0,D2 
		BLT	RIGHT_TO_LEFT 
		CMP.W	X_MIN(PC),D0 
		BGE.S	END_X_MIN_CLIP		; KOI CLIPEN 
		MOVE.W	X_MIN(PC),D4 
		SUB.W	D2,D4			; X 
		BMI.S	IN_LIM3			; X2 AUCH OUT ?? 

* ABFRAGE FöR öBERSCREENPOLY !!
* + SICHERN DER RANDBEREICHE

		CMP.W	START_MEGA_LEFT(PC),D1	; BEREICH GRôSSER 
		BGE.S	N_N_M1			; GEWORDEN ??
		MOVE.W	D1,START_MEGA_LEFT
N_N_M1:
		CMP.W	END_MEGA_LEFT(PC),D3
		BLE.S	N_N_M2
		MOVE.W	D3,END_MEGA_LEFT	
N_N_M2:
		RTS
IN_LIM3:
		MOVE.W	D1,D5
		NEG.W	D1
		ADD.W	D3,D1			; Y 
		SUB.W	D2,D0			; X 
		MULS	D4,D1 
		DIVS	D0,D1 
		NEG.W	D1
		ADD.W	D3,D1			; Y-NEU  
		MOVE.W	X_MIN(PC),D0		; X AUF X-MIN CLIP 
; megapoly marken...
		CMP.W	START_MEGA_LEFT(PC),D5	; BEREICH GRôSSER 
		BGE.S	C_N_M3			; GEWORDEN ??
		MOVE.W	D5,START_MEGA_LEFT
C_N_M3:
		CMP.W	END_MEGA_LEFT(PC),D1
		BLE.S	END_X_MIN_CLIP
		MOVE.W	D1,END_MEGA_LEFT	
END_X_MIN_CLIP:
		CMP.W	X_MAX(PC),D2		; TEST X2>X-MAX   -> CLIP IT
		BLE	NO_X_MAX_CLIP 
		MOVE.W	X_MAX(PC),D4		; D4 = CLIP X-MAX
		CMP.W	D4,D0			; RECHTS AUCH OUT ?? 
		BLT.S	IN_LIM6

* RECHTEN RAND VON MEGAPOLY MERKEN

		CMP.W	START_MEGA_RIGHT(PC),D1	; BEREICH GRôSSER 
		BGE.S	N_N_M5			; GEWORDEN ??
		MOVE.W	D1,START_MEGA_RIGHT
N_N_M5:
		CMP.W	END_MEGA_RIGHT(PC),D3
		BLE.S	N_N_M6
		MOVE.W	D3,END_MEGA_RIGHT	
N_N_M6:
		RTS
IN_LIM6:
		SUB.W	D2,D4 
		MOVE.W	D3,D5 
		SUB.W	D1,D3			; dY 
		NEG.W	D2			; dX
		ADD.W	D0,D2 
		MULS	D4,D3 
		DIVS	D2,D3 
		NEG.W	D3
		ADD.W	D5,D3			; D3 = Y-NEU 
		MOVE.W	X_MAX(PC),D2		 ; D2 = X-MAX
; megapoly marken...
		CMP.W	START_MEGA_RIGHT(PC),D3	; BEREICH GRôSSER 
		BGE.S	C_N_M4			; GEWORDEN ??
		MOVE.W	D3,START_MEGA_RIGHT
C_N_M4: 
		CMP.W	END_MEGA_RIGHT(PC),D5
		BLE.S	END_X_MAX_CLIPO
		MOVE.W	D5,END_MEGA_RIGHT	
END_X_MAX_CLIPO:
		TST.W	D7
		BEQ	START_SAVE		
		CMP.W	-4(A0),D0
		BNE	BOTH_SAVE
		CMP.W	-2(A0),D1
		BNE	BOTH_SAVE
		MOVE.W	D2,(A0)+		; SAVE NEW POINT					
		MOVE.W	D3,(A0)+					
		ADDQ.W	#1,D7			; INC POINTCOUNT
		RTS
RIGHT_TO_LEFT:
		CMP.W	X_MIN(PC),D2		; X1 LINKS OUT ??? 
		BGE.S	END_X_CLIP2 
		MOVE.W	X_MIN(PC),D5 
		CMP.W	D5,D0			; TEST OB BEIDE LINKS OUT ?? 
		BGE.S	IN_LIM4

		CMP.W	START_MEGA_LEFT(PC),D1	; BEREICH GRôSSER 
		BGE.S	N_N_M3			; GEWORDEN ??
		MOVE.W	D1,START_MEGA_LEFT
N_N_M3:
		CMP.W	END_MEGA_LEFT(PC),D3
		BLE.S	N_N_M4
		MOVE.W	D3,END_MEGA_LEFT	
N_N_M4:
		RTS
IN_LIM4:
		MOVE.W	D3,D4 
		SUB.W	D2,D5 
		SUB.W	D1,D3 
		NEG.W	D2
		ADD.W	D0,D2 
		MULS	D5,D3 
		DIVS	D2,D3 
		NEG.W	D3
		ADD.W	D4,D3			; D3 = NEUER Y-WERT 
		MOVE.W	X_MIN(PC),D2		; D2 = X-MIN 
; megapoly marken...
		CMP.W	START_MEGA_LEFT(PC),D3	; BEREICH GRôSSER 
		BGE.S	C_N_M1			; GEWORDEN ??
		MOVE.W	D3,START_MEGA_LEFT
C_N_M1:
		CMP.W	END_MEGA_LEFT(PC),D4
		BLE.S	END_X_CLIP2
		MOVE.W	D4,END_MEGA_LEFT	
END_X_CLIP2:
		CMP.W	X_MAX(PC),D0		; TEST X1 RECHTS OUT
		BLE.S	NO_X_MAX_CLIP 
		MOVE.W	X_MAX(PC),D4
		SUB.W	D2,D4 
		BPL.S	IN_LIM5

* RECHTEN RAND VON MEGAPOLY MERKEN

		CMP.W	START_MEGA_RIGHT(PC),D1	; BEREICH GRôSSER 
		BGE.S	N_N_M7			; GEWORDEN ??
		MOVE.W	D1,START_MEGA_RIGHT
N_N_M7:
		CMP.W	END_MEGA_RIGHT(PC),D3
		BLE.S	N_N_M8
		MOVE.W	D3,END_MEGA_RIGHT	
N_N_M8:
		RTS
IN_LIM5:
		MOVE.W	D1,D5 
		NEG.W	D1
		ADD.W	D3,D1 
		SUB.W	D2,D0 
		MULS	D4,D1  
		DIVS	D0,D1 
		NEG.W	D1
		ADD.W	D3,D1			; D1 = Y-NEU 
		MOVE.W	X_MAX(PC),D0		; D0 = X-MAX
; megapoly marken...
		CMP.W	START_MEGA_RIGHT(PC),D5	; BEREICH GRôSSER 
		BGE.S	C_N_M2			; GEWORDEN ??
		MOVE.W	D5,START_MEGA_RIGHT
C_N_M2:
		CMP.W	END_MEGA_RIGHT(PC),D1
		BLE.S	NO_X_MAX_CLIP
		MOVE.W	D1,END_MEGA_RIGHT	
NO_X_MAX_CLIP:
		TST.W	D7
		BEQ.S	START_SAVE		
		CMP.W	-4(A0),D0
		BNE.S	BOTH_SAVE		; SINNLOSER KOMMENTAR :-)
		CMP.W	-2(A0),D1
		BNE.S	BOTH_SAVE
		MOVE.W	D2,(A0)+		; SAVE NEW POINT					
		MOVE.W	D3,(A0)+					
		ADDQ.W	#1,D7			; INC POINTCOUNT
		RTS
BOTH_SAVE:
		MOVE.W	D0,(A0)+
		MOVE.W	D1,(A0)+
		MOVE.W	D2,(A0)+		; SAVE BOTH
		MOVE.W	D3,(A0)+
		ADDQ.W	#2,D7
		RTS
START_SAVE:
		MOVE.W	#2,D7			; SCHON 2 POINTS
		MOVE.W	D0,(A0)+
		MOVE.W	D1,(A0)+
		MOVE.W	D2,(A0)+		; SAVE BOTH...
		MOVE.W	D3,(A0)+
		RTS
SAVER_MIN_MAX:
		DS.W	4

		DS.B	32
ALL_CLIP_BUF:
		DS.B	400			; BUFF FöR CLIPPED POLY..
*
* HELP BUFS FöR 
*

START_MEGA_LEFT:	DC.W	0
END_MEGA_LEFT:		DC.W	0
START_MEGA_RIGHT:	DC.W	0
END_MEGA_RIGHT:		DC.W	0
				



NO_DRAW:
		RTS
TEST_DRAW:
;  CACHE H-LINES 1 PLANE 30/05/93
*****************************************************************
*		CACHE H-LINES 1-PLANE				*
*		ZAXX/ANIMAL MINE/INDEPENDENT			*
*****************************************************************						
Y_DIS		EQU	160	
WORDS		EQU	320/16
DIS_WORDS	EQU	8	( 16 COLORS )	

		
H_LINE:
		LEA	H_CODE,A0		; END OF H-CODE
		MOVE.L	SCREEN1,A1		; SCREEN ADR
		LEA	DRAW_INFO,A6
		MOVE.W	(A6)+,D0
		MULU	#160,D0
		ADD.L	D0,A1
		MOVE.W	(A6)+,D2
		TST.W	D2
		BLE.S	NO_DRAW		
		SUBQ.W	#1,D2
		MOVE.L	(A6)+,A3
		MOVE.L	(A6)+,A2
		LEA	START_DATA,A4		; OR WERTE + LéNGE
		LEA	END_DATA,A5
		MOVE.L	#Y_DIS,D3		; ZEILENSPRUNG
		MOVEQ	#-1,D4			; DATA FöLLER
; RESET CACHE
H_MAIN:
		MOVE.W	(A2)+,D0		; STARTWERT
		MOVE.W	(A3)+,D1		; ENDWERT
		MOVE.L	(A4,D0.W*4),D0		; START DATA
		MOVE.L	(A5,D1.W*4),D1		; END	DATA
		SUB.W	D0,D1			; CALC LéNGE
		BGT.S	BAD_LINE		; LINE >1 WORT ??
		AND.L	D0,D1
		SWAP	D1
		OR.W	D1,(A1,D0.W*2)		; SET LINE
		ADD.L	D3,A1			; JUMP Y-LINE
		SUBQ.W	#1,D2
		BPL.S	H_MAIN
		RTS
BAD_LINE:
		LEA	(A1,D0.W*2),A6		; SCREEN X-SET
		SWAP	D0
		OR.W	D0,(A6)			; SET START
		MOVE.W	D1,D5
		NEG.W	D1

		JMP	4(A0,D1.W)		
	
OFFX	SET	(WORDS-1)*DIS_WORDS
		REPT	WORDS-1
		MOVE.W	D4,OFFX(A6)		; 4 BYTES
OFFX	SET	OFFX-DIS_WORDS
		ENDR
H_CODE:
		SWAP	D1
		OR.W	D1,(A6,D5.W*2)		; SET END-DATA
		ADD.L	D3,A1
		DBF	D2,H_MAIN
		RTS


TRANSFORM:
* CALC_MATRIX
	LEA	OBJ_DATA(PC),A0			; DATASTRUC VON OBJ
 
	LEA	SAVE_MATRIX+18(PC),A2		; SAVE TAB FöR MULU
	MOVEM.W	DREH_X(PC),D0-D2 
	AND.W	#%11111111110,D0
	AND.W	#%11111111110,D1		; AUF TABELLE KöRZEN 
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
	LEA	TRANSED_3D(PC),A2
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
	ASR.L	#8,D0 
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


DREH_X:		DC.W	150			; DREHWINKEL X/Y/Z
DREH_Y:		DC.W	0
DREH_Z:		DC.W	0
MID_X:		DC.W	160			; MITTE VON SCREEN
MID_Y:		DC.W	100
SAVE_MATRIX:	DS.W	9			; BUF FöR MATRIX
MOVE_X:		DC.L	0 
MOVE_Y:		DC.L	0
MOVE_Z:		DC.W	80			; 3-D WORLD MOVE
		DC.W	0
OBJ_DATA:
		DC.W	4-1
		DC.W	-101,-100,0
		DC.W	100,-100,0
		DC.W	100,100,0
		DC.W	-101,100,0

SIN_TAB:    ; (equinox)
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
      DC.B      'SöT2T',$C9,'U_'
      DC.B      'U',$F4,'V',$89,'W',$1D,'W',$B0 
      DC.B      'XBX',$D3,'YcY',$F3 
      DC.B      'ZÅ[',$0F,'[',$9C,'\('
      DC.B      '\',$B3,']=]',$C6,'^O'
      DC.B      '^',$D6,'_]_',$E2,'`g'
      DC.B      '`',$EB,'ana',$F0,'bq'
      DC.B      'b',$F1,'cpc',$EE,'dk'
      DC.B      'd',$E7,'ebe',$DD,'fV'
      DC.B      'f',$CE,'gEg',$BC,'h1'
      DC.B      'h',$A5,'i',$19,'i',$8B,'i',$FC 
      DC.B      'jlj',$DB,'kJk',$B7 
      DC.B      'l#lél',$F8,'ma'
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
      DC.B      'm',$C9,'mal',$F8,'lé'
      DC.B      'l#k',$B7,'kJj',$DB 
      DC.B      'jli',$FC,'i',$8B,'i',$19 
      DC.B      'h',$A5,'h1g',$BC,'gE'
      DC.B      'f',$CE,'fVe',$DD,'eb'
      DC.B      'd',$E7,'dkc',$EE,'cp'
      DC.B      'b',$F1,'bqa',$F0,'an'
      DC.B      '`',$EB,'`g_',$E2,'_]'
      DC.B      '^',$D6,'^O]',$C6,']='
      DC.B      '\',$B3,'\([',$9C,'[',$0F 
      DC.B      'ZÅY',$F3,'YcX',$D3 
      DC.B      'XBW',$B0,'W',$1D,'V',$89 
      DC.B      'U',$F4,'U_T',$C9,'T2'
      DC.B      'SöS',$01,'RhQ',$CE 
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
      DC.B      $9B,$19,$9A,$9E,'ö#',$99,$AA
      DC.B      $99,'2',$98,$BB,$98,'D',$97,$CF 
      DC.B      $97,'[',$96,$E7,$96,'u',$96,$04 
      DC.B      $95,$94,$95,'%',$94,$B6,$94,'I' 
      DC.B      $93,$DD,$93,'r',$93,$08,$92,$9F 
      DC.B      $92,'7',$91,$D0,$91,'k',$91,$06 
      DC.B      $90,$A2,$90,'@',$8F,$DE,$8F,'~' 
      DC.B      $8F,$1F,$8E,$C0,'éc',$8E,$07
      DC.B      $8D,$AC,$8D,'R',$8C,$FA,$8C,$A2 
      DC.B      $8C,'K',$8B,$F6,$8B,$A2,$8B,'O' 
      DC.B      $8A,$FD,$8A,$AC,$8A,'\',$8A,$0D 
      DC.B      $89,$C0,$89,'s',$89,'(',$88,$DE 
      DC.B      $88,$95,$88,'M',$88,$07,$87,$C1 
      DC.B      $87,'}',$87,':',$86,$F8,$86,$B7 
      DC.B      $86,'w',$86,'9',$85,$FC,$85,$BF 
      DC.B      $85,$84,$85,'K',$85,$12,$84,$DB 
      DC.B      $84,$A4,$84,'oÑ<',$84,$09 
      DC.B      $83,$D7,$83,$A7,$83,'x',$83,'J' 
      DC.B      $83,$1E,$82,$F2,$82,$C8,$82,$9F 
      DC.B      $82,'w',$82,'P',$82,'+',$82,$07 
      DC.B      $81,$E4,$81,$C2,$81,$A2,$81,$82 
      DC.B      $81,'dÅGÅ,',$81,$11 
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
      DC.B      $80,$F8,$81,$11,$81,',ÅG' 
      DC.B      'Åd',$81,$82,$81,$A2,$81,$C2
      DC.B      $81,$E4,$82,$07,$82,'+',$82,'P' 
      DC.B      $82,'w',$82,$9F,$82,$C8,$82,$F2 
      DC.B      $83,$1E,$83,'J',$83,'x',$83,$A7 
      DC.B      $83,$D7,$84,$09,$84,'<Ño' 
      DC.B      $84,$A4,$84,$DB,$85,$12,$85,'K' 
      DC.B      $85,$84,$85,$BF,$85,$FC,$86,'9' 
      DC.B      $86,'w',$86,$B7,$86,$F8,$87,':' 
      DC.B      $87,'}',$87,$C1,$88,$07,$88,'M' 
      DC.B      $88,$95,$88,$DE,$89,'(',$89,'s' 
      DC.B      $89,$C0,$8A,$0D,$8A,'\',$8A,$AC 
      DC.B      $8A,$FD,$8B,'O',$8B,$A2,$8B,$F6 
      DC.B      $8C,'K',$8C,$A2,$8C,$FA,$8D,'R' 
      DC.B      $8D,$AC,$8E,$07,'éc',$8E,$C0
      DC.B      $8F,$1F,$8F,'~',$8F,$DE,$90,'@' 
      DC.B      $90,$A2,$91,$06,$91,'k',$91,$D0 
      DC.B      $92,'7',$92,$9F,$93,$08,$93,'r' 
      DC.B      $93,$DD,$94,'I',$94,$B6,$95,'%' 
      DC.B      $95,$94,$96,$04,$96,'u',$96,$E7 
      DC.B      $97,'[',$97,$CF,$98,'D',$98,$BB 
      DC.B      $99,'2',$99,$AA,'ö#',$9A,$9E
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
      DC.B      'SöT2T',$C9,'U_'
      DC.B      'U',$F4,'V',$89,'W',$1D,'W',$B0 
      DC.B      'XBX',$D3,'YcY',$F3 
      DC.B      'ZÅ[',$0F,'[',$9C,'\('
      DC.B      '\',$B3,']=]',$C6,'^O'
      DC.B      '^',$D6,'_]_',$E2,'`g'
      DC.B      '`',$EB,'ana',$F0,'bq'
      DC.B      'b',$F1,'cpc',$EE,'dk'
      DC.B      'd',$E7,'ebe',$DD,'fV'
      DC.B      'f',$CE,'gEg',$BC,'h1'
      DC.B      'h',$A5,'i',$19,'i',$8B,'i',$FC 
      DC.B      'jlj',$DB,'kJk',$B7 
      DC.B      'l#lél',$F8,'ma'
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
OF_P	SET	OF_P+4
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
OF_P	SET	OF_P+4
	ENDR

POLY_STRUC:
	DC.W	0				; VISI
	DC.W	0				; COLOR
	DC.W	4-1				; ANZ ECKPOINTS
	DC.W	0,1,2,3	

POLY_FAST:
* TAB 1/Y * 65536 ( bis max 400 Y-ZEILEN )
 DC.W 65535,32768,21845,16384,13107,10922,9362,8192,7281,6553
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

TRANSED_3D:
	DC.W	40,-20
	DC.W	200,100
	DC.W	40,180
	DC.W	-200,10	
	
	DS.W	20

	SECTION	BSS
	
	DS.W	400
MY_STACK:
	DS.W	10
ECK_BUF:
	DS.W	40
SCREEN1:
	DS.L	1
SCREEN2:
	DS.L	1
SCREENS:
	DS.W	65256
POLY_X:
	DS.W	2000				; BUF X-START/END
DRAW_INFO:
	DS.W	100				; FLEX-INFOBUF
	