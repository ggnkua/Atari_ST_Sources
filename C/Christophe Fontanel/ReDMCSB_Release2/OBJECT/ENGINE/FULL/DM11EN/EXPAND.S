CODE SEG "memory"
F466_rzzz_:/* global */
	LINK	A6,L$0
	MOVEM.L	A6-A2/D7-D4,-(A7)
	MOVE.L	8(A6),A0
	MOVE.L	12(A6),A1
	MOVE	16(A6),D5
	MOVE	18(A6),D4
	MOVE	(A0)+,D7
	MOVE	(A0)+,D6
	ADD	#15,D7
	LSR	#1,D7
	AND	#-8,D7
	CMPA.L	#0,A1
	BNE.S	L0T466_001
	MOVE.L	A0,-(A7)
	MOVE	#2,-(A7)
	TRAP	#14
	ADDQ.L	#2,A7
	MOVE.L	D0,A1
	MOVE.L	(A7)+,A0
	MOVE	#160,D0
	CMP	D0,D7
	BEQ.S	L0T466_001
	LSR	#1,D5
	AND	#-8,D5
	ADDA	D5,A1
	MULU	D0,D4
	ADDA	D4,A1
	MOVE.L	A1,A3
	ADDA	D7,A3
	SUBQ	#1,D6
	MULU	D0,D6
	ADD.L	A3,D6
	MOVE	D0,D4
	SUB	D7,D4
	MOVE	D4,D7
	SWAP	D7
	MOVE	D0,D7
	BRA.S	L0T466_002
L0T466_001:
	MULU	D7,D6
	MOVE.L	A1,A3
	ADDA.L	D6,A3
	MOVE.L	A3,D6
L0T466_002:
	CLR.L	(A1)
	CLR.L	4(A1)
	MOVEQ	#15,D0
	MOVEQ	#0,D4
	LEA	L0V466_1_Ma(PC),A4
	LEA	L0V466_2_Ma(PC),A5
	LEA	L0V466_3_Bi(PC),A6
L0T466_003_:
	MOVE.B	(A0)+,D3
	MOVE.B	D3,D2
	BMI.S	L0T466_008_
	LSR.B	#4,D3
	BEQ.S	L0T466_012
	AND	#15,D2
	MOVEQ	#1,D1
	ADD.B	D3,D1
L0T466_004:
	LSL	#3,D2
	MOVE.L	A6,A2
	ADDA	D2,A2
L0T466_005:
	BSR.S	L0T466_013_
	TST	D1
	BEQ.S	L0T466_003_
	CMPI	#16,D1
	BCS.S	L0T466_005
	MOVE.L	(A2),D3
	MOVE.L	4(A2),D5
	SUBI	#16,D1
L0T466_006:
	MOVE.L	D3,(A1)+
	MOVE.L	D5,(A1)+
	CMPA.L	A1,A3
	BNE.S	L0T466_007
	BSR	L0T466_018_(PC)
L0T466_007:
	SUBI	#16,D1
	BCC.S	L0T466_006
	CLR.L	(A1)
	CLR.L	4(A1)
	ADDI	#16,D1
	BNE.S	L0T466_005
	BRA.S	L0T466_003_
L0T466_008_:
	ANDI	#15,D2
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	BTST	#6,D3
	BEQ.S	L0T466_009_
	ASL	#8,D1
	MOVE.B	(A0)+,D1
L0T466_009_:
	ADDQ	#1,D1
	BTST	#4,D3
	BEQ.S	L0T466_004
	BTST	#5,D3
	BEQ	L0T466_020(PC)
	MOVE.L	A1,A2
	SUBA	D7,A2
L0T466_010_:
	BSR.S	L0T466_013_
	TST.L	D5
	BEQ.S	L0T466_011
	MOVE.L	D5,A2
L0T466_011:
	ADDQ.L	#8,A2
	TST	D1
	BNE.S	L0T466_010_
L0T466_012:
	BSR	L0T466_022_(PC)
	BRA	L0T466_003_(PC)
L0T466_013_:
	MOVE.B	D0,D4
	ADD	D4,D4
	ADD	D4,D4
	MOVE.L	0(A4,D4),D3
	CMP.L	D1,D0
	BMI.S	L0T466_014_
	SUB	D1,D0
	MOVE.B	D0,D4
	ADD	D4,D4
	ADD	D4,D4
	AND.L	0(A5,D4),D3
	MOVEQ	#0,D1
	BRA.S	L0T466_015_
L0T466_014_:
	SUB	D0,D1
	SUBQ	#1,D1
	MOVEQ	#255,D0
L0T466_015_:
	MOVE.L	(A2),D5
	AND.L	D3,D5
	OR.L	D5,(A1)+
	MOVE.L	4(A2),D5
	AND.L	D3,D5
	OR.L	D5,(A1)+
	MOVEQ	#0,D5
	TST	D0
	BMI.S	L0T466_017
	SUBQ.L	#8,A1
	RTS
L0T466_016:
	ADDQ.L	#8,A1
L0T466_017:
	CMPA.L	A1,A3
	BNE.S	L0T466_019_
L0T466_018_:
	CMP.L	A1,D6
	BEQ	L0T466_042(PC)
	ADDA	D7,A3
	SWAP	D7
	ADDA	D7,A1
	MOVE.L	A2,D5
	ADD	D7,D5
	SWAP	D7
L0T466_019_:
	MOVEQ	#15,D0
	CLR.L	(A1)
	CLR.L	4(A1)
	RTS
L0T466_020:
	LSR	#1,D1
	BCC.S	L0T466_021
	BSR.S	L0T466_022_
L0T466_021:
	MOVE.B	(A0),D2
	LSR.B	#4,D2
	BSR.S	L0T466_022_
	MOVE.B	(A0)+,D2
	BSR.S	L0T466_022_
	SUBQ	#1,D1
	BNE.S	L0T466_021
	BRA	L0T466_003_(PC)
L0T466_022_:
	CLR	D3
	BSET	D0,D3
	ANDI	#15,D2
	ADD	D2,D2
	JMP	2(PC,D2)
L0T466_023:
	BRA.S	L0T466_027
	BRA.S	L0T466_026
	BRA.S	L0T466_032
	BRA.S	L0T466_025
	BRA.S	L0T466_034
	BRA.S	L0T466_029
	BRA.S	L0T466_031
	BRA.S	L0T466_024
	BRA.S	L0T466_037
	BRA.S	L0T466_036
	BRA.S	L0T466_038
	BRA.S	L0T466_035
	BRA.S	L0T466_033
	BRA.S	L0T466_028
	BRA.S	L0T466_030
	OR	D3,6(A1)
L0T466_024:
	OR	D3,4(A1)
L0T466_025:
	OR	D3,2(A1)
L0T466_026:
	OR	D3,(A1)
L0T466_027:
	SUBQ	#1,D0
	BMI	L0T466_016(PC)
	RTS
L0T466_028:
	OR	D3,6(A1)
L0T466_029:
	OR	D3,4(A1)
	OR	D3,(A1)
	SUBQ	#1,D0
	BMI	L0T466_016(PC)
	RTS
L0T466_030:
	OR	D3,6(A1)
L0T466_031:
	OR	D3,4(A1)
L0T466_032:
	OR	D3,2(A1)
	SUBQ	#1,D0
	BMI	L0T466_016(PC)
	RTS
L0T466_033:
	OR	D3,6(A1)
L0T466_034:
	OR	D3,4(A1)
	SUBQ	#1,D0
	BMI	L0T466_016(PC)
	RTS
L0T466_035:
	OR	D3,2(A1)
L0T466_036:
	OR	D3,(A1)
L0T466_037:
	OR	D3,6(A1)
	SUBQ	#1,D0
	BMI	L0T466_016(PC)
	RTS
L0T466_038:
	OR	D3,6(A1)
	OR	D3,2(A1)
	SUBQ	#1,D0
	BMI	L0T466_016(PC)
	RTS
L0V466_1_Ma:
	ORI.B	#1,D1
	ORI.B	#3,D3
	ORI.B	#7,D7
	ORI.B	#15,A7
	ORI.B	#31,(A7)+
	ORI.B	#63,*** Illegal Mode 111 ***
	ORI	#127,*** Illegal Mode 111 ***
	ORI*** illegal size3 ***#255,*** Illegal Mode 111 ***
	BSET	D0,*** Illegal Mode 111 ***
	BSET	D0,*** Illegal Mode 111 ***
	BSET	D1,*** Illegal Mode 111 ***
	BSET	D1,*** Illegal Mode 111 ***
	BSET	D3,*** Illegal Mode 111 ***
	BSET	D3,*** Illegal Mode 111 ***
	BSET	D7,*** Illegal Mode 111 ***
	BSET	D7,*** Illegal Mode 111 ***
	MOVE.B	*** Illegal Mode 111 ***,*** Illegal Mode 111 ***
	MOVE.B	*** Illegal Mode 111 ***,*** Illegal Mode 111 ***
	MOVE	*** Illegal Mode 111 ***,*** Illegal Mode 111 ***
	MOVE	*** Illegal Mode 111 ***,*** Illegal Mode 111 ***
	MOVEQ	#255,D7
	MOVEQ	#255,D7
	*** illegal 1111 ***
	*** illegal 1111 ***
L0V466_2_Ma:
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	ASR.B	#8,D0
	ASR.B	#8,D0
	AND.B	D0,D0
	AND.B	D0,D0
	OR.B	D0,D0
	OR.B	D0,D0
	ORI.B	#0,D0
L0V466_3_Bi:
	ORI.B	#0,D0
	ORI.B	#0,D0
	*** illegal 1111 ***
	ORI.B	#0,D0
	ORI.B	#0,D0
	*** illegal 1111 ***
	ORI.B	#0,D0
	*** illegal 1111 ***
	*** illegal 1111 ***
	ORI.B	#0,D0
	ORI.B	#0,D0
	*** illegal 1111 ***
	ORI.B	#-1,D0
	ORI.B	#-1,D0
	ORI.B	#0,D0
	*** illegal 1111 ***
	*** illegal 1111 ***
	ORI.B	#-1,D0
	*** illegal 1111 ***
	*** illegal 1111 ***
	ORI.B	#0,D0
	ORI.B	#0,D0
	*** illegal 1111 ***
	*** illegal 1111 ***
	ORI.B	#0,D0
	*** illegal 1111 ***
	ORI.B	#-1,D0
	ORI.B	#-1,D0
	*** illegal 1111 ***
	*** illegal 1111 ***
	ORI.B	#-1,D0
	ORI.B	#0,D0
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	ORI.B	#-1,D0
	*** illegal 1111 ***
	ORI.B	#-1,D0
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
	*** illegal 1111 ***
L0T466_042:
	ADDQ.L	#4,A7
	MOVEM.L	(A7)+,D4-D7/A2-A6
L1:
	UNLK	A6
	RTS
L$0:	.EQU	#0
