		BRA.L BEGIN
********************************************
**	DEMO
********************************************
DEMO:		
DEMO_LOOP:	JSR	VSYNC(PC)
		JSR	SWITCHA(PC)
		MOVE.W	#0,$FFFF8240.W
WAIT:		TST.B	$FFFF8209.W
		BEQ.S	WAIT
		MOVE.W	#$FFF,$FFFF8240.W
TESTAGAIN:	MOVE.B	$FFFFFC00.W,D0
		BTST	#1,D0
		BEQ.S	TESTAGAIN
		MOVE.B	#$16,$FFFFFC02.W

		MOVE.B	$FFFFFC02.W,D7
		MOVE.W	D7,$FFFF8240.W
		BRA.S	DEMO_LOOP
********************************************
**	SWITCH
********************************************
SWITCHA:	NOT.W	SWITCH
		BEQ.S	OTHER
		BRA.S	SWITCH_DONE
OTHER:
SWITCH_DONE:	RTS
********************************************
**	VSYNC
********************************************
VSYNC:		MOVE.W	#0,VSYNCFLAG
WAIT_SYNC:	TST.W	VSYNCFLAG
		BEQ.S	WAIT_SYNC
		RTS
********************************************
**	VBL
********************************************
VBL:		CMP.B	#$39,$FFFFFC02.W
		BEQ.L	BACK
		ADDQ.W	#1,VSYNCFLAG
		RTE
********************************************
**	STARTUP
********************************************
BEGIN:		MOVE.L	A7,SAVEA7
		MOVE.W	SR,D0
		BTST	#13,D0
		BNE.S	SUPERON
		MOVE.L	#0,-(A7)
		MOVE.W	#$20,-(A7)
		TRAP	#1
SUPERON:	LEA	STACK,A7
		MOVE.W	#$2700,SR
		MOVE.W	#0,-(A7)
		PEA -1
		PEA -1
		MOVE.W	#5,-(A7)
		TRAP	#14
		ADD.L	#12,A7
		MOVE.L	$70.W,SAVEVBL
		MOVE.L	#VBL,$70.W
		MOVE.W	#$2300,SR
		BRA.L	DEMO
********************************************
**	BACK
********************************************
BACK:		MOVE.W	#$2700,SR
		MOVE.L	SAVEVBL(PC),$70.W
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
*********************************************
**	DATA
*********************************************
VSYNCFLAG:	DC.W	0
SAVEVBL:	DC.L	0
SAVEA7:		DC.L	0
SCREEN:		DC.L	0
SWITCH:		DC.W	0
DATA
		BLK.L	100
STACK:
