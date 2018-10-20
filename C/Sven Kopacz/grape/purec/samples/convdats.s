	EXPORT convDatS
	
convDatS:
	MOVEM.L	D3-D4/A2,-(A7)
	MOVEA.L	A0,A2
	MOVEQ	#-$46,D0
	ADD.W	$A(A2),D0
	MOVE.W	8(A2),D1
	BRA.B	L1A0104
L1A00FE:
	SUBQ.W	#1,D0
	ADD.W	#$C,D1
L1A0104:
	TST.W	D1
	BMI.B	L1A00FE
	BRA.B	L1A0110
L1A010A:
	ADDQ.W	#1,D0
	SUB.W	#$C,D1
L1A0110:
	CMP.W	#$C,D1
	BGE.B	L1A010A
	TST.W	D0
	BPL.B	L1A011E
	MOVEQ	#-1,D0
	BRA.B	L1A018C
L1A011E:
	MOVEQ	#1,D2
	ADD.W	D0,D2
	ASR.W	#2,D2
	MOVE.W	D0,D3
	MULS.W	#$16D,D3
	ADD.W	D2,D3
	MOVE.W	D1,D4
	EXT.L	D4
	ADD.L	D4,D4
	LEA	days_in_month,A0
	ADD.W	0(A0,D4.L),D3
	ADD.W	6(A2),D3
	SUBQ.W	#1,D3
	MOVEQ	#2,D2
	ADD.W	D0,D2
	AND.W	#3,D2
	BNE.B	L1A0154
	CMP.W	#2,D1
	BLT.B	L1A0154
	ADDQ.W	#1,D3
L1A0154:
	MOVE.W	D3,D1
	EXT.L	D1
	MOVE.L	D1,D0
	ADD.L	D0,D0
	ADD.L	D1,D0
	LSL.L	#3,D0
	MOVE.W	4(A2),D2
	EXT.L	D2
	ADD.L	D2,D0
	MOVE.L	D0,D3
	MOVE.L	D0,D1
	LSL.L	#4,D1
	SUB.L	D0,D1
	LSL.L	#2,D1
	MOVE.W	2(A2),D4
	EXT.L	D4
	ADD.L	D4,D1
	MOVE.L	D1,D3
	MOVE.L	D1,D2
	LSL.L	#4,D2
	SUB.L	D1,D2
	LSL.L	#2,D2
	MOVE.W	(A2),D0
	EXT.L	D0
	ADD.L	D0,D2
	MOVE.L	D2,D0
L1A018C:
	MOVEM.L	(A7)+,D3-D4/A2
	RTS

days_in_month: dc.w 0x0000
							 dc.w 0x001F
							 dc.w 0x003B 
							 dc.w 0x005A
							 dc.w 0x0078
							 dc.w 0x0097
							 dc.w 0x00B5
							 dc.w 0x00D4
							 dc.w 0x00F3
							 dc.w 0x0111
							 dc.w 0x0130
							 dc.w 0x014E