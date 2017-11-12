BSS SEG "bss"
G0_pc_Syst:/* global */
	.WORD	#4
CODE SEG "main"
main:/* global */
	LINK	A6,L$0
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE.L	_base(A4),D0
	MOVE.L	D0,A3
	MOVE.L	4(A3),D7
	MOVE.L	_base(A4),D6
DATA SEG "s!"
s!:
	DATA 73 74 61 72 74 2E 70 61 6B 00 
CODE SEG "main"
	CLR	-(A7)
	PEA	s!(A4)
	MOVE	#61,-(A7)
	JSR	R3_gemdos(PC)
	ADDQ.L	#8,A7
	MOVE	D0,-36(A6)
	CMPI	#0,D0
	BGE	L2(PC)
L4:
L5:
	BRA	L4(PC)
L6:
L2:
	PEA	-22(A6)
	MOVE.L	#22,-(A7)
	MOVE	-36(A6),-(A7)
	MOVE	#63,-(A7)
	JSR	R3_gemdos(PC)
	ADDA	#12,A7
	CMPI	#24602,-18(A6)
	BEQ	L7(PC)
L9:
L10:
	BRA	L9(PC)
L11:
L7:
	MOVE	#2,-(A7)
	MOVE	-36(A6),-(A7)
	CLR.L	-(A7)
	MOVE	#66,-(A7)
	JSR	R3_gemdos(PC)
	ADDA	#10,A7
	MOVE.L	D0,-30(A6)
	CLR	-(A7)
	MOVE	-36(A6),-(A7)
	MOVE.L	#32,-(A7)
	MOVE	#66,-(A7)
	JSR	R3_gemdos(PC)
	ADDA	#10,A7
	MOVE.L	D0,-26(A6)
	MOVE.L	D7,D5
	MOVE.L	-30(A6),D1
	SUB.L	-26(A6),D1
	ADDQ.L	#1,D1
	AND.L	#-2,D1
	SUB.L	D1,D5
	MOVE.L	D6,D4
	ADD.L	#16000,D4
	MOVE.L	D5,-(A7)
	MOVE.L	-30(A6),D0
	SUB.L	-26(A6),D0
	MOVE.L	D0,-(A7)
	MOVE	-36(A6),-(A7)
	MOVE	#63,-(A7)
	JSR	R3_gemdos(PC)
	ADDA	#12,A7
	MOVE.L	D4,-(A7)
	MOVE.L	-22(A6),-(A7)
	MOVE.L	D5,D0
	ADD.L	#3840,D0
	MOVE.L	D0,-(A7)
	MOVE.L	D5,-(A7)
	JSR	F4_Decompr(PC)
	ADDA	#16,A7
	MOVE.L	D4,D0
	MOVE.L	-16(A6),D1
	ADD.L	-12(A6),D1
	ADD.L	-4(A6),D1
	MOVE.L	D1,-34(A6)
	ADD.L	D1,D0
	MOVE.L	D0,A3
	MOVE.L	-34(A6),D0
	ASR.L	#2,D0
	ADDQ.L	#1,D0
	MOVE.L	D0,-34(A6)
	MOVE.L	(A3)+,D0
	ADD.L	D4,D0
	MOVE.L	D0,A2
	MOVE.L	A3,D0
	MOVE.L	D0,-40(A6)
	MOVE.L	D6,D0
	ADD.L	#256,D0
	ADD.L	D0,(A2)
	BRA	L12(PC)
L13:
	CMPI.L	#1,-30(A6)
	BNE	L15(PC)
	ADDA.L	#1016,A2
	BRA	L16(PC)
L15:
	MOVE.L	A2,D0
	ADD.L	-30(A6),D0
	MOVE.L	D0,A2
	MOVE.L	D6,D0
	ADD.L	#256,D0
	ADD.L	D0,(A2)
L16:
L12:
	MOVE.L	-40(A6),A0
	ADDQ.L	#1,-40(A6)
	MOVE.B	(A0),D0
	AND	#255,D0
	EXT.L	D0
	MOVE.L	D0,-30(A6)
	CMPI.L	#0,D0
	BNE	L13(PC)
L14:
	MOVE.L	_base(A4),D0
	ADD.L	#12,D0
	MOVE.L	D0,A3
	MOVE.L	-16(A6),(A3)+
	MOVE.L	D6,D0
	ADD.L	-16(A6),D0
	ADD.L	#256,D0
	MOVE.L	D0,(A3)+
	MOVE.L	-12(A6),(A3)+
	MOVE.L	D6,D0
	ADD.L	-16(A6),D0
	ADD.L	-12(A6),D0
	ADD.L	#256,D0
	MOVE.L	D0,(A3)+
	MOVE.L	-8(A6),(A3)
	LEA	L0CopyDecom(PC),A0
	MOVE.L	D5,A1
	MOVE.L	A1,A2
	MOVE	#32,D0
L0Loop1:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,L0Loop1
	MOVE.L	D7,A7
	MOVE.L	_base(A4),A1
	MOVE.L	A1,-(A7)
	ADDA.L	#256,A1
	MOVE.L	D4,A0
	MOVE.L	-34(A6),D0
	JMP	(A2)
L0CopyDecom:
	MOVE.L	A1,A2
L0Loop2:
	MOVE.L	(A0)+,(A1)+
	DBF	D0,L0Loop2
	JSR	(A2)
L1:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$0:	.EQU	#-40
_initargcv:/* global */
	RTS
R3_gemdos:/* global */
	MOVE.L	A2,D3
	MOVE.L	(A7)+,G0_pc_Syst(A4)
	TRAP	#1
	MOVE.L	G0_pc_Syst(A4),A0
	MOVE.L	D3,A2
	JMP	(A0)
F4_Decompr:/* global */
	LINK	A6,L$17
	MOVEM.L	A3-A2/D5-D4,-(A7)
	MOVE.L	8(A6),A3
	MOVE.L	20(A6),A1
	MOVE.L	12(A6),A0
	MOVE.L	16(A6),D4
	MOVEQ	#0,D3
	MOVEQ	#15,D1
	MOVEQ	#8,D0
L1MainLoop:
	SUBQ.L	#1,D4
	BMI	L1RestoreRe(PC)
	MOVEQ	#1,D5
	BSR.S	L1ClearD2An
	CMP	D0,D2
	BPL.S	L1LessFrequ
	MOVEQ	#1,D5
	BSR.S	L1GetNibble
	ADD	D2,D2
	MOVE	0(A3,D2),(A1)+
	BRA.S	L1MainLoop
L1LessFrequ:
	CMP	D1,D2
	BEQ.S	L1DirectWor
	MOVEQ	#2,D5
	BSR.S	L1GetNibble
	SUB.L	#1920,D2
	ADD	D2,D2
	MOVE	0(A3,D2),(A1)+
	BRA.S	L1MainLoop
L1DirectWor:
	MOVEQ	#4,D5
	BSR.S	L1ClearD2An
	MOVE	D2,(A1)+
	BRA.S	L1MainLoop
L1ClearD2An:
	CLR	D2
L1GetNibble:
	SWAP	D2
L1Loop:
	SUBQ	#1,D3
	BPL.S	L1NibbleInD
	MOVEQ	#3,D3
	MOVE	(A0)+,D2
L1NibbleInD:
	LSL.L	#4,D2
	SUBQ	#1,D5
	BNE.S	L1Loop
	SWAP	D2
	RTS
L1RestoreRe:
	MOVEM.L	(A7)+,D4-D5/A2-A3
L18:
	UNLK	A6
	RTS
L$17:	.EQU	#0
