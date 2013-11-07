		BRA.L BEGIN
********************************************
**	DEMO
********************************************
DEMO:		MOVE.W	#$2300,SR
		MOVE.W	#33,LINES
		CLR.W	$FFFF8240.W
		MOVE.W	#0,VSYNCFLAG
		LEA	$FFFF8260.W,A6
		LEA	$FFFF820A.W,A5
		MOVEQ	#2,D6
		MOVEQ	#0,D5
		MOVEQ	#0,D0
		MOVE.W	#198+29,D7
TEST:		TST.W	VSYNCFLAG
		BEQ.S	TEST
		MOVE.W	#$2100,SR
STOP:		BRA.S	STOP
HEHEJ:
NEJ:		MOVE.B	$FFFF8209.W,D0
		BEQ.S	NEJ
		NOT.W	D0
		LSL.W	D0,D1

		BLK.W	48,$4E71
;		BLK.W	32,$4E71

LOOP:		BLK.W	7,$4E71		; 7
		MOVE.B	D6,(A6)		; 2		; LEFT BORDER
		NOP			; 1		; 28
		MOVE.B	D5,(A6)		; 2
		BLK.W	14,$4E71	; 14
		MOVE.B	D6,(A6)		; 2
		BLK.W	5,$4E71		; 5
		MOVE.B	D5,(A6)		; 2
		BLK.W	84,$4E71

		MOVE.B	D5,$FFFF820A.W	; 3		; RIGHT BORDER
		MOVE.B	D6,$FFFF820A.W	; 3		; 6
		DBF	D7,LOOP		; 3 (4 NŽR SLUT)
***************************
		MOVEQ	#32,D7		; 1
		BLK.W	5,$4E71		; 5
		MOVE.B	D6,(A6)		; 2		; LEFT BORDER
		NOP			; 1		; 28
		MOVE.B	D5,(A6)		; 2
		BLK.W	10,$4E71	; 10
		MOVE.B	D5,(A5)		; 2		; LOWER BORDER
		MOVE.B	D6,(A5)		; 2

		MOVE.B	D6,(A6)		; 2
		BLK.W	5,$4E71		; 5
		MOVE.B	D5,(A6)		; 2

		BLK.W	84,$4E71
		MOVE.B	D5,$FFFF820A.W	; 3		; RIGHT BORDER
		MOVE.B	D6,$FFFF820A.W	; 3		; 6
		BLK.W	3,$4E71

*************************************
LOOP2:		BLK.W	7,$4E71		; 7
		MOVE.B	D6,(A6)		; 2		; LEFT BORDER
		NOP			; 1		; 28
		MOVE.B	D5,(A6)		; 2
		BLK.W	14,$4E71	; 14
		MOVE.B	D6,(A6)		; 2
		BLK.W	5,$4E71		; 5
		MOVE.B	D5,(A6)		; 2
		BLK.W	84,$4E71

		MOVE.B	D5,$FFFF820A.W	; 3		; RIGHT BORDER
		MOVE.B	D6,$FFFF820A.W	; 3		; 6
		DBF	D7,LOOP2	; 3 (4 NŽR SLUT)

		BRA.L	DEMO
********************************************
**	HBL
********************************************
HBL:		MOVE.W	#$2700,SR
		SUBQ	#1,LINES
		BPL.L	NOTY

		BLK.W	82,$4E71
		MOVE.B	#0,$FFFF820A.W
		BLK.W	12,$4E71
		MOVE.B	#2,$FFFF820A.W
		MOVE.W	#$FF,LINES
		LEA	6(A7),A7
		BRA.L	HEHEJ
NOTY:		RTE
LINES:		DC.W	0
********************************************
**	VBL
********************************************
VBL:		CMP.B	#$39,$FFFFFC02.W
		BEQ.L	BACK
		ADD.W	#1,VSYNCFLAG
		RTE
********************************************
**	STARTUP
********************************************
BEGIN:		LEA	SAVEA7(PC),A0
		MOVE.L	A7,(A0)
		MOVE.W	SR,D0
		BTST	#13,D0
		BNE.S	SUPERON
		MOVE.L	#0,-(A7)
		MOVE.W	#$20,-(A7)
		TRAP	#1
SUPERON:	LEA	$7FFF0,A7
		MOVE.B	#0,$484.W
		MOVE.W	#$2700,SR

		LEA	$70000,A0
		LEA	$80000,A1
RENSA:		CLR.L	(A0)+
		CMP.L	A0,A1
		BHI.S	RENSA
		LEA	$70000+164,A0
		LEA	$80000,A1
MALA:		MOVEQ	#27,D1
LOOPA:		MOVE.W	#$0FF0,(A0)+
		MOVE.W	#$F0F0,(A0)+
		MOVE.W	#$FF00,(A0)+
		MOVE.W	#$FFF0,(A0)+
		DBF	D1,LOOPA
		LEA	6(A0),A0
		CMP.L	A0,A1
		BHI.S	MALA


		MOVE.B	#7,$FFFF8201.W
		MOVE.B	#0,$FFFF8203.W

		MOVEQ	#1,D0
		JSR	RASTERSETUP
		MOVE.L	$70.W,SAVEVBL
		MOVE.L	$68.W,SAVEHBL
		MOVE.L	#VBL,$70.W
		MOVE.L	#HBL,$68.W
		MOVE.W	#$2300,SR
		BRA.L	DEMO
********************************************
**	BACK
********************************************
BACK:		MOVE.W	#$2700,SR
		MOVE.B	#7,$484.W
		MOVE.L	SAVEVBL(PC),$70.W
		MOVE.L	SAVEHBL(PC),$68.W
		JSR	RASTERRESTORE(PC)
		MOVE.W	#255,D0
ACIA1:		MOVE.B	$FFFFFC02.W,D1
		MOVE.W	#255,D1
ACIA2:		DBF	D1,ACIA2
		DBF	D0,ACIA1
		MOVE.W	#$000,$FFFF8246.W
		MOVE.W	#$777,$FFFF8240.W
		MOVE.W	#1,-(A7)
		PEA	$F8000
		PEA	$F8000
		MOVE.W	#5,-(A7)
		TRAP	#14
		MOVE.L	SAVEA7(PC),A7
		RTS
********************************************
**	SAVE OLD AND SET NEW MFP VALUES
********************************************
RASTERSETUP:
	MOVE.L $120,SAVETIMERB
	MOVE.B $FFFFFA09.W,SPARARASTER1
	MOVE.B $FFFFFA07.W,SPARARASTER2
	MOVE.B $FFFFFA13.W,SPARARASTER3
	MOVE.B #0,$FFFFFA07.W
	MOVE.B #0,$FFFFFA09.W

	MOVE.B #0,$FFFFFA07.W
	MOVE.B #0,$FFFFFA13.W
	RTS
********************************************
**	RESTORE OLD MFP VALUES
********************************************
RASTERRESTORE:
	MOVE.B SPARARASTER1,$FFFFFA09.W
	MOVE.B SPARARASTER2,$FFFFFA07.W
	MOVE.B SPARARASTER3,$FFFFFA13.W
	MOVE.L SAVETIMERB,$120
	RTS
********************************************
**	SAVE VALUES (FOR MFP)
********************************************
SAVETIMERB:	DC.L 0
SPARARASTER1:	DC.B 0
SPARARASTER2:	DC.B 0
SPARARASTER3:	DC.B 0
	EVEN
*********************************************
**	DATA
*********************************************
VSYNCFLAG:	DC.W	0
SAVEVBL:	DC.L	0
SAVEHBL:	DC.L	0
SAVEA7:		DC.L	0
