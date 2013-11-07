A:
******************************************************
******************************************************
*	ACT CRUNCHER V1.11 -A PICTURE CRUNCHER ONLY
******************************************************
*	UPDATED VERSION:
*		V1.11	-NO TRAPS
*			-TOTALY RELOCATABLE
*			-CAN SET INPUT CVALUES THROW ADDRESS
*			 REGISTER.
*			-THE FIND UNUSED ROUT HAS BEEN IMPROVED (FASTER)
*			-WORKS PERFECTLY WITH GFA-BASIC INLINE AND
*			 RCALL ADDR,REG%()
*			-GETS THE PAL FROM A USER-DEF. ADDR (NOT WITH SYSTEMS)
******************************************************
*	IN:	A0=SORCE		(ADDRESS TO THE PICTURE DATA
*					(NEO+128,DEGAS+36 32000 BYTES)
*		A1=DEST			(SHOULD BE ABOYT 32 KB)
*		A2=WORKAREA (SCREEN..)	(SHOULD BE ABOUT 32 KB)
*		A3=ADDR TO WHERE PAL EXISTS (32 BYTES)
*	OUT:	D7=LENGHT
******************************************************
CRUNCHER:	MOVEM.L	A0-A6/D0-D7,-(A7)
		LEA	SORCE(PC),A6
		MOVE.L	A0,(A6)
		LEA	DEST(PC),A6
		MOVE.L	A1,(A6)
		LEA	SCREEN(PC),A6
		MOVE.L	A2,(A6)
		LEA	PALADDR(PC),A6
		MOVE.L	A3,(A6)
		BSR.L	BIT_SPLIT		; BIT SPLIT
		BSR.L	SEARCH			; SEARCH FOR UNUSED WORDS
		MOVEQ	#13,D0			; BIT SPLIT,PALETTE,BYTE CRUNCH
		BSR.L	BYTE_CRUNCH		; BYTE CRUNCH
		LEA	CRUNCHLENGHT1(PC),A6
		MOVE.L	A0,(A6)
		SUB.L	DEST(PC),A0
		LEA	LENGHT1(PC),A6
		MOVE.L	A0,(A6)

****************************************************
*********** SECOND METHOD **************************
****************************************************

		BSR.S	SMART_SCREEN		; SMART SCREEN
		BSR.L	SEARCH			; SEARCH FOR UNUSED WORDS
		MOVEQ	#28,D0			; SMART,PALETTE,BYTE CRUNCH
		BSR.L	BYTE_CRUNCH
		LEA	CRUNCHLENGHT2(PC),A6
		MOVE.L	A0,(A6)
		SUB.L	DEST(PC),A0
		LEA	LENGHT2(PC),A6
		MOVE.L	A0,(A6)

		MOVE.L	LENGHT1(PC),D6
		MOVE.L	LENGHT2(PC),D7
		CMP.L	D6,D7
		BLO.S	SMART_BEST

					; RESPLIT ****************
		LEA	LENGHT2(PC),A6
		MOVE.L	LENGHT1(PC),(A6)
		BSR.L	BIT_SPLIT		; BIT SPLIT
		BSR.L	SEARCH		; SEARCH FOR UNUSED WORDS
		MOVEQ	#13,D0		; BIT SPLIT,PALETTE,BYTE CRUNCH
		BSR.L	BYTE_CRUNCH		; BYTE CRUNCH
		LEA	CRUNCHLENGHT2(PC),A6
		MOVE.L	A0,(A6)
SMART_BEST:
		MOVEM.L	(A7)+,D0-D7/A0-A6
		MOVE.L	LENGHT2(PC),D7
		RTS
***************************************************
**		BIT SPLIT
***************************************************
BIT_SPLIT:	MOVE.L	SORCE(PC),A0
		MOVE.L	SCREEN(PC),A1
		MOVE.W	#$F9F,D0
BIT_SPLIT1:	MOVE.W	(A0)+,(A1)
		MOVE.W	(A0)+,$1F40(A1)
		MOVE.W	(A0)+,$3E80(A1)
		MOVE.W	(A0)+,$5DC0(A1)
		ADDQ.L	#2,A1
		DBF	D0,BIT_SPLIT1
		RTS
****************************************************
***		SCREEN FORM 'SMART'
****************************************************
SMART_SCREEN:	MOVE.L	SORCE(PC),A0
		MOVE.L	SCREEN(PC),A1
		MOVE.W	#0,CCR
		MOVE.W	#3999,D5
BIG_SUMM:	MOVE.W	(A0)+,D0
		MOVE.W	(A0)+,D1
		MOVE.W	(A0)+,D2
		MOVE.W	(A0)+,D3
		MOVEQ	#3,D6
FOUR:		MOVEQ	#0,D4
		MOVEQ	#3,D7
FIFTEEN:	ROXL.W	#1,D0
		ROXL.L	#1,D4
		ROXL.W	#1,D1
		ROXL.L	#1,D4
		ROXL.W	#1,D2
		ROXL.L	#1,D4
		ROXL.W	#1,D3
		ROXL.L	#1,D4
		DBF	D7,FIFTEEN
		MOVE.W	D4,(A1)+
		DBF	D6,FOUR
		DBF	D5,BIG_SUMM
		RTS
****************************************************
**		SEARCH UNUSED
****************************************************
SEARCH:		MOVE.L	SCREEN(PC),A0
		MOVE.L	DEST(PC),A1
		MOVE.W	#7999,D0
RENSA:		CLR.L	(A1)+
		DBF	D0,RENSA
		MOVE.L	DEST(PC),A1
		MOVE.L	#32000,D6
		MOVEQ	#-1,D5
		MOVE.W	#15999,D0

LETA1:		MOVE.W	(A0),D1
		CMP.W	D6,D1
		BHI.S	TOO_HIGH1
		MOVE.B	D5,(A1,D1.W)
TOO_HIGH1:	MOVE.B	1(A0),D1
		LSL.W	#8,D1
		MOVE.B	2(A0),D1
		CMP.W	D6,D1
		BHI.S	TOO_HIGH2
		MOVE.B	D5,(A1,D1.W)
TOO_HIGH2:	ADDQ.L	#2,A0
		DBF	D0,LETA1
		
		LEA	ENDMARK(PC),A0
		MOVEQ	#0,D0
		MOVEQ	#3,D2
SEARCHING:	TST.B	(A1,D0.W)
		BNE.S	USED
		MOVE.W	D0,(A0)+
		ADDQ.W	#1,D0
		DBF	D2,SEARCHING
		BRA.S	ALL_FOUND
USED:		ADDQ.W	#1,D0
		BRA.S	SEARCHING		
ALL_FOUND:	RTS
****************************************************
**		BYTE CRUNCH		D0=LOWBYTE CONTAIN
****************************************************
BYTE_CRUNCH:	MOVE.L	SCREEN(PC),A1
		MOVE.L	DEST(PC),A0
		MOVE.L	A1,A6
		ADD.L	#$7D00,A6
		MOVE.B	#1,(A0)+			; VERSION
		MOVE.B	D0,(A0)+			; CONTAIN LOW BYTE

		MOVE.L	PALADDR(PC),A6		; SAVE PALETTE
		MOVEQ	#7,D7
COPYPALEN:	MOVE.L	(A6)+,(A0)+
		DBF	D7,COPYPALEN

		MOVE.B	#0,(A0)+		; CONTAIN MID BYTE
		MOVE.B	#0,(A0)+		; CONTAIN HIGH BYTE
		MOVE.W	ENDMARK(PC),(A0)+	; END MARK WORD
		MOVE.W	REPEATWORD(PC),(A0)+	; REPEAT WORD
		MOVE.W	FFWORD(PC),(A0)+	; FF REPEAT WORD
		MOVE.W	NULLWORD(PC),(A0)+	; NULL REPEAT WORD
CRUNCH_ALL2:
		MOVEQ	#1,D6
		MOVE.B	(A1),D0
		MOVE.L	A0,D1
		MOVE.B	1(A1),D1
		MOVE.B	2(A1),D2
		MOVE.B	3(A1),D3
		CMP.B	D0,D1
		BNE.S	CRUNCH_NOT2
		CMP.B	D0,D2
		BNE.S	CRUNCH_NOT2
		CMP.B	D0,D3
		BEQ.S	EQUAL2

CRUNCH_NOT2:	MOVE.B	D0,(A0)+		; NO CRUNCH
CRUNCH_MORE2:	ADD.L	D6,A1
		CMP.L	A6,A1
		BLO.S	CRUNCH_ALL2
		MOVE.W	A0,D0
		AND.L	#1,D0
		BEQ.S	OK
		MOVE.B	#0,(A0)+
OK:		MOVE.W	ENDMARK(PC),(A0)+
		RTS
****************************
EQUAL2:		CMP.B	#0,D0
		BNE.L	Q3
		MOVE.W	NULLWORD(PC),D7
		BSR.S	POKEW
		BRA.S	COUNTCRUNCH2
Q3:		CMP.B	#$FF,D0
		BNE.S	Q4
		MOVE.W	FFWORD(PC),D7
		BSR.S	POKEW
		BRA.S	COUNTCRUNCH2
Q4:		CMP.B	4(A1),D0
		BNE.S	CRUNCH_NOT2
 		CMP.B	5(A1),D0
		BNE.S	CRUNCH_NOT2
		MOVE.W	REPEATWORD(PC),D7
		BSR.S	POKEW
		MOVE.B	D0,(A0)+
**********************************

COUNTCRUNCH2:	MOVEQ	#0,D3
		MOVE.L	A1,A2
		ADD.L	D6,A2
TEST_MORE2:	CMP.B	(A2)+,D0
		BNE.S	NO_MORE2
		ADDQ.W	#1,D6
		ADDQ.W	#1,D3
		CMP.L	A6,A2
		BLO.S	TEST_MORE2
NO_MORE2:	MOVE.W	D3,D7
		BSR.S	POKEW
		BRA.S	CRUNCH_MORE2
***********************************
POKEW:		ROL.W	#8,D7
		MOVE.B	D7,(A0)+
		ROL.W	#8,D7
		MOVE.B	D7,(A0)+
		RTS
****************************************************
**		DATA
****************************************************
SORCE:		DC.L	0
DEST:		DC.L	0
SCREEN:		DC.L	0
PALADDR:	DC.L	0
CRUNCHLENGHT1:	DC.L	0
CRUNCHLENGHT2:	DC.L	0
LENGHT1:	DC.L	0
LENGHT2:	DC.L	0
ENDMARK:	DC.W	0
REPEATWORD:	DC.W	0
FFWORD:		DC.W	0
NULLWORD:	DC.W	0
B:
