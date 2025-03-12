	TEXT
Begin	
	BRA	L0004
L0000	DC.B	'super.lum',0,0,0,0,0,0,0
L0001	DS.W	1
L0002	DC.B	'cycle.PRG',0
L0003	DC.B	$1B,$45,$1B,$66,$1B,$77
	DC.B	'MESSAGE TO APPEAR AT FRONT OF LOADER',13,10
	DC.B	'HI FROM EGB... ETC',13,10
	DC.B	0
	EVEN

L0004	MOVEA.L	4(A7),A5	
	MOVE.L	12(A5),D0
	ADD.L	20(A5),D0
	ADD.L	28(A5),D0
	ADDI.L	#$200,D0
	ADDI.L	#$4008,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.L	#$4A0000,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	DC.B	$A0,$0A
	PEA	L0003
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	DC.B	$A0,$09
	MOVE.L	#L00AF,L009E
	MOVE.L	#L0000,L009A
	MOVE.L	#L0001,L009B
	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	LEA	L0096(PC),A6
	MOVE.L	D0,(A6)
	MOVE.L	$00000084.L,L000A
	MOVE.L	#L0006,$00000084.L
	MOVE.L	L0096(PC),-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
L0005	CLR.L	L009C
	MOVEA.L	#L0005,A7
	MOVE.L	#L0000,L0099
	MOVE.L	#-$16,L0098
	CLR.L	$00060000
	PEA	$00060000
	PEA	$00060000
	MOVE.L	#L0002,-(A7)
	MOVE.L	#$4B0000,-(A7)
	TRAP	#1
	LEA	16(A7),A7
	CLR.W	-(A7)
	TRAP	#1
L0006	TST.W	L009D
	BNE	L0009
	MOVEM.L	A0-A6/D0-D7,L00A0
	MOVEA.L	A7,A1
	ADDQ.L	#6,A1
	MOVE.W	(A7),D0
	BTST	#13,D0
	BNE.S	L0007
	MOVE	USP,A1
L0007	CMPI.W	#$3D,(A1)
	BEQ	L000B
	CMPI.W	#$3F,(A1)
	BEQ	L0014
	CMPI.W	#$3E,(A1)
	BEQ	L0032
	CMPI.W	#$3C,(A1)
	BEQ	L0042
	CMPI.W	#$40,(A1)
	BEQ	L0045
	CMPI.W	#$42,(A1)
	BEQ	L0039
	CMPI.W	#$4E,(A1)
	BEQ	L0046
	CMPI.W	#$4F,(A1)
	BEQ	L0051
	CMPI.W	#$45,(A1)
	BEQ	L0052
	CMPI.W	#$46,(A1)
	BEQ	L0053
L0008	MOVEM.L	L00A0(PC),A0-A6/D0-D7
L0009	JMP	$00000000.L
L000A	EQU	L0009+2
L000B	MOVE.W	#1,L009D
	BSR	L0055
	MOVE.L	D0,D7
	MOVE.L	D0,D6
	MOVEA.L	A0,A5
	MOVEA.L	2(A1),A6
	MOVE.W	6(A1),-(A7)
	MOVE.L	A6,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	TST.L	D0
	BPL	L000D
	CLR.L	D6
	MOVEA.L	A6,A0
	MOVEA.L	L009A,A4
	BSR	L0057
	TST.L	D0
	BMI	L0041
	LEA	L0095,A1
	MOVE.L	D7,D6
	LSL.L	#2,D6
	MOVE.L	D0,0(A1,D6.W)
	LEA	L00A4,A1
	CLR.L	0(A1,D6.W)
	LEA	L00A8,A1
	MOVE.L	A4,0(A1,D6.W)
	LEA	L00A5,A1
	MOVE.L	14(A0),0(A1,D6.W)
	LEA	L00A7,A1
	MOVE.L	18(A0),0(A1,D6.W)
	CLR.L	D0
	MOVEA.L	L009E,A0
	MOVE.W	200(A0),D0
	MULU	#$16,D0
	ADDQ.L	#2,D0
	ANDI.L	#$FFFF,D0
	ADD.L	D0,0(A1,D6.W)
	MOVE.L	D7,D6
	LSL.L	#5,D7
	LEA	L00A6,A0
	ADDA.L	D7,A0
	MOVEA.L	A6,A2
L000C	MOVE.B	(A2)+,(A0)+
	BNE.S	L000C
	BRA	L0013
L000D	MOVE.L	D0,D4
	CLR.L	L00AB
	PEA	L00AB
	MOVE.L	#8,-(A7)
	MOVE.W	D4,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	CLR.W	-(A7)
	MOVE.W	D4,-(A7)
	CLR.L	-(A7)
	MOVE.W	#$42,-(A7)
	TRAP	#1
	LEA	10(A7),A7
	MOVEA.L	A6,A4
	MOVE.L	#$1F,D0
L000E	MOVE.B	(A6)+,(A5)+
	DBF	D0,L000E
	LSL.L	#2,D7
	LEA	L00A4,A0
	MOVE.L	#0,0(A0,D7.W)
	LEA	L00A7,A0
	MOVE.L	#0,0(A0,D7.W)
	CMPI.L	#"AU5$",L00AB
	BEQ.S	L000F
	LEA	L0095,A0
	MOVE.L	D4,0(A0,D7.W)
	LEA	L00A8,A0
	MOVE.L	#0,0(A0,D7.W)
	CMPI.L	#"AU5C",L00AB
	BNE	L0013
	MOVE.L	#-1,0(A0,D7.W)
	LEA	L00A5,A0
	MOVE.L	L00AC,0(A0,D7.W)
	BRA	L0010
L000F	LEA	L00A5,A0
	MOVE.L	L00AC,0(A0,D7.W)
	LEA	L0095,A0
	MOVE.L	#-1,0(A0,D7.W)
	LEA	L00A8,A0
	MOVE.L	#0,0(A0,D7.W)
	MOVE.W	D4,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
L0010	LEA	L00A3,A5
L0011	TST.B	(A4)
	BEQ.S	L0012
	CMPM.B	(A4)+,(A5)+
	BEQ.S	L0011
	BRA.S	L0013
L0012	TST.B	(A5)
	BNE.S	L0013
	MOVE.L	D6,L009C
L0013	CLR.W	L009D
	MOVE.L	D6,-(A7)
	MOVEM.L	L00A0,A0-A6/D0-D7
	MOVE.L	(A7)+,D0
	RTE
L0014	CLR.L	D0
	MOVE.W	2(A1),D0
	TST.W	D0
	BMI	L0015
	MOVE.W	D0,D1
	LSL.L	#2,D1
	LEA	L0095,A0
	MOVE.L	0(A0,D1.W),D2
	CMP.W	#-1,D2
	BEQ	L0019
	LEA	L00A8,A0
	MOVE.L	0(A0,D1.W),D3
	TST.L	D3
	BNE	L001F
L0015	MOVE.W	#1,L009D
	MOVE.L	8(A1),D7
	MOVE.L	D7,-(A7)
	MOVE.L	4(A1),-(A7)
	MOVE.W	D2,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVE.L	D0,D5
	MOVEA.L	D7,A0
	CLR.L	D0
	MOVE.B	(A0),D0
	LSL.W	#8,D0
	MOVE.B	1(A0),D0
	SWAP	D0
	MOVE.B	2(A0),D0
	LSL.W	#8,D0
	MOVE.B	3(A0),D0
	CMP.L	#"AU5!",D0
	BNE	L0031
	LEA	-200(A0),A1
	MOVEA.L	A1,A2
	LEA	L00A9,A3
	MOVE.L	#$C7,D1
L0016	MOVE.B	(A2)+,(A3)+
	DBF	D1,L0016
L0017	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D5
	BNE.S	L0017
	MOVEA.L	A2,A1
	LEA	-200(A1),A0
	MOVE.L	A0,-(A7)
	BSR	L0075
	MOVEA.L	(A7)+,A0
	LEA	L00A9,A1
	MOVE.L	#$C7,D1
L0018	MOVE.B	(A1)+,(A0)+
	DBF	D1,L0018
	BRA	L0031
L0019	CMP.L	L009C,D0
	BEQ	L001B
	MOVEA.L	A1,A5
	MOVE.W	#1,L009D
	MOVE.L	D0,L009C
	LSL.L	#5,D0
	LEA	L00A6,A0
	ADDA.L	D0,A0
	MOVEA.L	A0,A1
	LEA	L00A3,A2
	MOVE.W	#$1F,D0
L001A	MOVE.B	(A1)+,(A2)+
	DBF	D0,L001A
	CLR.W	-(A7)
	MOVE.L	A0,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	MOVE.W	D0,D6
	MOVE.L	L009E,-(A7)
	MOVE.L	#$2008,-(A7)
	MOVE.W	D0,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVE.W	D6,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	CLR.W	L009D
	MOVEA.L	L009E,A0
	LEA	200(A0),A1
	MOVE.L	4(A0),D7
	BSR	L0075
	MOVEA.L	A5,A1
L001B	MOVE.L	4(A1),D0
	MOVE.L	D0,D5
	MOVEA.L	8(A1),A0
	MOVE.L	L009C,D1
	LSL.L	#2,D1
	LEA	L00A4,A2
	LEA	L00A5,A3
	MOVE.L	0(A2,D1.W),D2
	MOVE.L	0(A3,D1.W),D3
	MOVEA.L	L009E,A1
	LEA	200(A1),A1
	ADDA.L	D2,A1
L001C	MOVE.B	(A1)+,(A0)+
	ADDQ.L	#1,D2
	CMP.L	D2,D3
	BLT.S	L001D
	SUBQ.L	#1,D0
	BNE.S	L001C
	BRA.S	L001E
L001D	MOVE.L	D3,D2
L001E	MOVE.L	D2,0(A2,D1.W)
	SUB.L	D0,D5
	BRA	L0031
L001F	MOVE.W	#1,L009D
	CMP.L	L009C,D0
	BEQ	L0021
	MOVE.L	D0,L009C
	LEA	L00A8,A0
	MOVEA.L	0(A0,D1.W),A5
	CMPA.L	L00A3,A5
	BEQ	L0021
	MOVEA.L	A1,A5
	LSL.L	#5,D0
	LEA	L00A6,A1
	ADDA.L	D0,A1
	LEA	L00A3,A2
	MOVE.W	#$1F,D0
L0020	MOVE.B	(A1)+,(A2)+
	DBF	D0,L0020
	MOVE.L	D2,D7
	CLR.W	-(A7)
	MOVE.W	D7,-(A7)
	CLR.L	-(A7)
	MOVE.W	#$42,-(A7)
	TRAP	#1
	LEA	10(A7),A7
	PEA	L00AB
	MOVE.L	#$400,-(A7)
	MOVE.W	D7,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVE.L	L00AC,D0
	MOVE.L	L00AD,D2
	SUBQ.L	#1,D2
	EORI.L	#-1,D2
	AND.L	D2,D0
	MOVE.L	D0,L00AA
	MOVE.L	#-1,L009F
	MOVEA.L	A5,A1
	MOVE.L	D7,D2
	MOVE.L	L009C,D0
	MOVE.L	D0,D1
	LSL.L	#2,D1
L0021	LEA	L00A4,A0
	MOVE.L	0(A0,D1.W),D4
	MOVE.L	4(A1),D5
	MOVE.L	D4,D7
	ADD.L	D5,D7
	CMP.L	D4,D7
	BLT.S	L0022
	LEA	L00A5,A0
	CMP.L	0(A0,D1.W),D7
	BLT	L0023
L0022	MOVE.L	0(A0,D1.W),D7
L0023	SUB.L	D4,D7
	MOVE.L	D7,D5
	MOVEA.L	8(A1),A4
	MOVEA.L	A4,A5
	ADDA.L	D5,A5
	SUBA.L	#1,A5
	TST.L	D5
	BEQ	L0031
	LEA	L00A4,A0
	LEA	L00A7,A1
	MOVE.L	0(A1,D1.W),D0
	ADD.L	D0,0(A0,D1.W)
	MOVE.W	D2,L00A1
	MOVE.L	D5,D2
	LEA	L00A4,A0
	MOVE.L	0(A0,D1.W),D0
	MOVEA.L	D0,A2
	MOVEA.L	A2,A3
	MOVE.L	L00AD,D3
	SUBQ.L	#1,D3
	AND.L	D3,D0
	MOVE.L	D3,D7
	MOVE.L	D0,D6
	EORI.L	#-1,D3
	MOVE.L	A2,D0
	AND.L	D3,D0
	MOVE.L	D0,D4
	ADDA.L	D5,A3
	MOVE.L	A3,D5
	AND.L	D7,D5
	MOVE.L	A3,D0
	AND.L	D3,D0
	MOVE.L	D0,D3
	SUB.L	D4,D0
	MOVE.L	L00AD,D7
	DIVU	D7,D0
	MOVE.L	D0,D7
	MOVE.L	D4,D0
	MOVE.L	L00AD,D2
	LEA	L00AE,A0
	CMP.L	L00AA,D0
	BNE.S	L0024
	DIVU	D2,D0
	LSL.L	#2,D0
	MOVE.L	L00AC,D1
	BRA.S	L0025
L0024	DIVU	D2,D0
	LSL.L	#2,D0
	MOVE.L	4(A0,D0.W),D1
L0025	MOVE.L	0(A0,D0.W),D2
	MOVE.L	D1,D0
	SUB.L	D2,D0
	CMP.L	L009F,D4
	BEQ	L0026
	MOVE.L	D4,L009F
	CLR.W	-(A7)
	MOVE.W	L00A1,-(A7)
	MOVE.L	D2,-(A7)
	MOVE.L	D0,D2
	MOVE.W	#$42,-(A7)
	TRAP	#1
	LEA	10(A7),A7
	MOVE.L	L009E,-(A7)
	MOVE.L	D2,-(A7)
	MOVE.W	L00A1,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVEA.L	L009E,A0
	LEA	200(A0),A1
	BSR	L0070
	BRA	L0027
L0026	TST.L	D7
	BEQ	L002C
	CLR.W	-(A7)
	MOVE.W	L00A1,-(A7)
	MOVE.L	D1,-(A7)
	MOVE.W	#$42,-(A7)
	TRAP	#1
	LEA	10(A7),A7
L0027	CMP.L	#1,D7
	BLE	L002C
	MOVE.L	D7,-(A7)
	LSL.L	#2,D7
	MOVE.L	D4,D0
	MOVE.L	L00AD,D2
	LEA	L00AE,A0
	DIVU	D2,D0
	LSL.L	#2,D0
	MOVE.L	4(A0,D0.W),D1
	ADDA.L	D7,A0
	MOVE.L	0(A0,D0.W),D2
	MOVE.L	D2,D0
	SUB.L	D1,D0
	MOVEA.L	A4,A6
	ADDA.L	L00AD,A6
	SUBA.L	D6,A6
	LEA	-200(A6),A3
	MOVE.L	A3,D7
	MOVE.L	#$C7,D1
	BTST	#0,D7
	BEQ.S	L0028
	ADDQ.L	#1,A3
	SUBQ.L	#1,D1
L0028	MOVE.L	(A7),D7
	MOVE.L	D6,-(A7)
	MOVE.L	L00AD,D6
	MULU	D6,D7
	MOVE.L	(A7)+,D6
	ADDA.L	D7,A6
	MOVE.L	(A7)+,D7
	LEA	L00A9,A0
	MOVEA.L	A3,A1
	MOVE.L	D1,D2
L0029	MOVE.B	(A1)+,(A0)+
	DBF	D1,L0029
	MOVE.L	A3,-(A7)
	MOVE.L	D0,-(A7)
	MOVE.W	L00A1,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	LEA	L00AE,A2
	MOVE.L	D4,D0
	MOVE.L	D6,-(A7)
	MOVE.L	L00AD,D6
	DIVU	D6,D0
	MOVE.L	(A7)+,D6
	LSL.L	#2,D0
	ADDQ.L	#4,D0
	ADDA.L	D0,A2
	MOVE.L	D7,-(A7)
	LSL.L	#2,D7
	SUBQ.L	#4,D7
	SUBA.L	L00AD,A6
L002A	SUBA.L	L00AD,A6
	SUBQ.L	#4,D7
	MOVEA.L	A3,A0
	MOVE.L	0(A2,D7.W),D0
	SUB.L	(A2),D0
	ADDA.L	D0,A0
	MOVEA.L	A6,A1
	BSR	L0070
	TST.W	D7
	BNE.S	L002A
	MOVE.L	(A7)+,D7
	LEA	L00A9,A0
	MOVEA.L	A3,A1
	MOVE.L	D2,D1
L002B	MOVE.B	(A0)+,(A1)+
	DBF	D1,L002B
L002C	MOVEA.L	L009E,A0
	LEA	200(A0),A0
	ADDQ.L	#1,A5
	ADDA.L	D6,A0
	MOVEA.L	A4,A1
L002D	CMPA.L	A1,A5
	BEQ.S	L002E
	CMP.L	L00AD,D6
	BEQ.S	L002E
	MOVE.B	(A0)+,(A1)+
	ADDQ.L	#1,D6
	BRA.S	L002D
L002E	SUBQ.L	#1,A5
	TST.L	D7
	BEQ.S	L0030
	TST.L	D5
	BEQ.S	L0030
	MOVE.L	D3,L009F
	MOVE.L	L00AD,D3
	MULU	D3,D7
	MOVE.L	L009F,D3
	MOVE.L	L009E,-(A7)
	MOVE.L	L00AD,-(A7)
	MOVE.W	L00A1,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVEA.L	L009E,A0
	LEA	200(A0),A1
	BSR	L0070
	MOVEA.L	L009E,A0
	LEA	200(A0),A0
	MOVEA.L	A5,A1
	ADDQ.L	#1,A1
	SUBA.L	D5,A1
	SUBQ.L	#1,D5
L002F	MOVE.B	(A0)+,(A1)+
	DBF	D5,L002F
L0030	SUBA.L	A4,A5
	ADDQ.L	#1,A5
	MOVE.L	A5,D5
	MOVE.L	L009C,D0
	LSL.L	#2,D0
	LEA	L00A7,A0
	MOVE.L	0(A0,D0.W),D1
	LEA	L00A4,A0
	SUB.L	D1,0(A0,D0.W)
	ADD.L	D5,0(A0,D0.W)
L0031	CLR.W	L009D
	MOVE.L	D5,-(A7)
	MOVEM.L	L00A0,A0-A6/D0-D7
	MOVE.L	(A7)+,D0
	RTE
L0032	CLR.L	D0
	CLR.L	D7
	MOVE.W	2(A1),D7
	MOVE.L	D7,D6
	MOVE.L	D7,D5
	MOVE.L	D7,D4
	LSL.L	#2,D6
	LEA	L0095,A5
	TST.W	D7
	BMI.S	L0034
	LSL.L	#5,D4
	LEA	L00A6,A4
	TST.B	0(A4,D4.W)
	BNE.S	L0033
	MOVE.L	#-$25,D0
	BRA	L0038
L0033	MOVE.L	0(A5,D6.W),D5
	CMP.L	#-1,D5
	BEQ.S	L0035
L0034	MOVE.W	#1,L009D
	MOVE.W	D5,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	CLR.W	L009D
	TST.L	D0
	BMI.S	L0038
L0035	TST.W	D7
	BMI.S	L0038
	CMP.L	L009C,D7
	BNE.S	L0036
	MOVE.L	#-1,L009C
L0036	CLR.W	D5
	SWAP	D5
	TST.W	D5
	BEQ.S	L0037
	CMP.W	#-1,D5
	BEQ.S	L0037
	MOVE.L	D5,0(A5,D6.W)
	BRA	L0038
L0037	LSL.L	#5,D7
	LEA	L00A6,A5
	MOVE.B	#0,0(A5,D7.W)
L0038	MOVE.L	D0,-(A7)
	MOVEM.L	L00A0,A0-A6/D0-D7
	MOVE.L	(A7)+,D0
	RTE
L0039	LEA	L00A4,A2
	LEA	L00A5,A3
	CLR.L	D0
	MOVE.W	6(A1),D0
	LSL.L	#2,D0
	CLR.L	D1
	MOVE.W	8(A1),D1
	MOVE.L	2(A1),D2
	TST.W	D1
	BNE.S	L003A
	MOVE.L	D2,D3
	BRA.S	L003D
L003A	CMP.W	#1,D1
	BNE.S	L003B
	MOVE.L	0(A2,D0.W),D3
	ADD.L	D2,D3
	BRA.S	L003D
L003B	TST.L	D2
	BPL.S	L003C
	NEG.L	D2
L003C	MOVE.L	0(A3,D0.W),D3
	SUB.L	D2,D3
L003D	MOVE.L	0(A3,D0.W),D4
	CMP.L	D3,D4
	BGT.S	L003E
	MOVE.L	D4,D3
L003E	TST.L	D3
	BGT.S	L003F
	CLR.L	D3
L003F	MOVE.L	D3,0(A2,D0.W)
	LEA	L0095,A0
	MOVE.L	0(A0,D0.W),D4
	CMP.L	#-1,D4
	BEQ.S	L0040
	LEA	L00A8,A0
	MOVE.L	0(A0,D0.W),D5
	TST.L	D5
	BNE.S	L0040
	MOVE.W	#1,L009D
	MOVE.W	D1,-(A7)
	MOVE.W	D4,-(A7)
	MOVE.L	D2,-(A7)
	MOVE.W	#$42,-(A7)
	TRAP	#1
	LEA	10(A7),A7
	MOVE.L	D0,D3
	CLR.W	L009D
L0040	MOVE.L	D3,-(A7)
	MOVEM.L	L00A0,A0-A6/D0-D7
	MOVE.L	(A7)+,D0
	RTE
L0041	CLR.W	L009D
	MOVE.L	D0,-(A7)
	MOVEM.L	L00A0,A0-A6/D0-D7
	MOVE.L	(A7)+,D0
	RTE
L0042	MOVE.W	#1,L009D
	BSR	L0055
	MOVE.L	D0,D7
	MOVEA.L	A0,A5
	MOVE.W	6(A1),-(A7)
	MOVE.L	2(A1),-(A7)
	MOVE.W	#$3C,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	TST.W	D0
	BMI	L0044
L0043	MOVE.B	#$49,(A5)
	LEA	L0095,A0
	MOVE.L	D7,D6
	LSL.L	#2,D7
	MOVE.L	D0,0(A0,D7.W)
	MOVE.L	D6,D0
L0044	CLR.W	L009D
	MOVE.L	D0,-(A7)
	MOVEM.L	L00A0,A0-A6/D0-D7
	MOVE.L	(A7)+,D0
	RTE
L0045	CLR.L	D0
	MOVE.W	2(A1),D0
	TST.W	D0
	BMI	L0008
	LSL.L	#2,D0
	LEA	L0095,A0
	MOVE.L	0(A0,D0.W),D1
	MOVE.W	D1,2(A1)
	BRA	L0008
L0046	MOVE.L	2(A1),D5
	MOVE.W	6(A1),D6
	MOVE.W	#1,L009D
	LEA	L0097,A0
	MOVEA.L	D5,A1
	MOVE.L	#$D,D0
L0047	MOVE.B	(A1)+,(A0)+
	DBF	D0,L0047
	MOVE.L	#-$16,L0098
	MOVE.L	#L0000,L0099
	MOVE.W	D6,-(A7)
	MOVE.L	D5,-(A7)
	MOVE.W	#$4E,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	CLR.L	D6
	TST.W	D0
	BEQ.S	L004A
	MOVEA.L	D5,A0
	MOVEA.L	L009A,A4
L0048	BSR	L0057
	TST.W	D0
	BMI	L0050
	MOVE.L	A4,L0099
	LEA	-202(A0),A6
	SUBA.L	L009E,A6
	MOVE.L	A6,L0098
	MOVEA.L	A0,A6
	MOVE.W	D0,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	MOVE.W	#$2F,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	MOVEA.L	D0,A0
	LEA	26(A0),A0
	MOVE.L	14(A6),(A0)+
	MOVEQ	#$D,D0
L0049	MOVE.B	(A6)+,(A0)+
	DBF	D0,L0049
	MOVEQ	#0,D0
	BRA	L0050
L004A	MOVE.W	#$2F,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	MOVE.L	D0,D7
	ADDI.L	#$1E,D0
	MOVEA.L	D0,A0
	MOVE.L	D0,D4
	LEA	L0000,A1
	LEA	L0001,A2
	ADDQ.L	#1,A1
	ADDQ.L	#1,A2
L004B	CLR.L	D0
L004C	MOVE.B	0(A1,D0.W),D1
	CMP.B	0(A0,D0.W),D1
	BNE.S	L004D
	ADDQ.L	#1,D0
	TST.B	D1
	BNE.S	L004C
	MOVE.L	#-$21,D0
	TST.L	D6
	BRA	L0051
L004D	LEA	16(A1),A1
	CMPA.L	A2,A1
	BNE.S	L004B
	CLR.W	-(A7)
	MOVE.L	D4,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	TST.L	D0
	BMI.S	L004F
	MOVE.W	D0,D6
	CLR.L	L00A1
	PEA	L00A1
	MOVE.L	#8,-(A7)
	MOVE.W	D0,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVE.W	D6,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	LEA	L00A1,A0
	CMPI.L	#"AU5$",(A0)
	BEQ.S	L004E
	CMPI.L	#"AU5!",(A0)
	BNE.S	L004F
L004E	MOVEA.L	D7,A1
	MOVE.L	4(A0),26(A1)
L004F	CLR.L	D0
L0050	CLR.W	L009D
	MOVE.L	D0,-(A7)
	MOVEM.L	L00A0,A0-A6/D0-D7
	MOVE.L	(A7)+,D0
	RTE
L0051	MOVE.W	#1,L009D
	MOVE.L	L0098,D6
	ADDI.L	#$16,D6
	MOVE.W	#$4F,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	TST.L	D0
	BEQ	L004A
	LEA	L0097,A0
	MOVEA.L	L0099,A4
	BRA	L0048
L0052	MOVE.W	#1,L009D
	BSR	L0055
	MOVE.L	D0,D7
	MOVEA.L	A0,A5
	MOVE.W	2(A1),D5
	MOVE.W	D5,-(A7)
	MOVE.W	#$45,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	TST.W	D0
	BMI	L0041
	NEG.L	D5
	SWAP	D5
	MOVE.W	D0,D5
	MOVE.L	D5,D0
	BRA	L0043
L0053	CLR.L	D0
	MOVE.W	4(A1),D0
	LEA	L0095,A5
	TST.W	D0
	BMI.S	L0054
	LSL.L	#2,D0
	MOVE.L	0(A5,D0.W),D0
	MOVE.W	D0,4(A1)
L0054	CLR.L	D1
	MOVE.W	2(A1),D1
	LSL.L	#2,D1
	MOVE.L	D0,0(A5,D1.W)
	BRA	L0008
L0055	LEA	L00A6,A0
	LEA	160(A0),A0
	MOVE.L	#5,D0
L0056	ADDQ.L	#1,D0
	LEA	32(A0),A0
	TST.B	(A0)
	BNE.S	L0056
	RTS
L0057	MOVE.L	D0,D5
	BSR	L0060
	MOVEA.L	A0,A6
	MOVEA.L	L009B,A5
L0058	CMPA.L	A4,A5
	BEQ	L005C
L0059	BSR	L005A
	MOVE.L	D0,D4
	TST.L	D0
	BMI	L005E
	PEA	L00AB
	MOVE.L	#$400,-(A7)
	MOVE.W	D4,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVE.L	#-1,L009F
	MOVE.L	A4,L00A3
	MOVE.L	L00AC,D0
	MOVE.L	L00AD,D2
	SUBQ.L	#1,D2
	EORI.L	#-1,D2
	AND.L	D2,D0
	MOVE.L	D0,L00AA
	CLR.W	-(A7)
	MOVE.W	D4,-(A7)
	MOVE.L	L00AE,-(A7)
	MOVE.W	#$42,-(A7)
	TRAP	#1
	LEA	10(A7),A7
	MOVE.L	L009E,-(A7)
	MOVE.L	L00AD,-(A7)
	MOVE.W	D4,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(A7),A7
	MOVEA.L	L009E,A0
	LEA	200(A0),A1
	BSR	L0070
	BSR	L005B
	TST.L	D0
	BMI.S	L005E
	MOVEA.L	D0,A0
	MOVE.L	D4,D0
	RTS
L005A	CLR.W	-(A7)
	MOVE.L	A4,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	RTS
L005B	MOVEA.L	A6,A0
	CLR.L	D0
	MOVE.W	(A1),D0
	MULU	#$16,D0
	ADDQ.L	#2,A1
	MOVEA.L	A1,A2
	ADDA.L	D0,A2
	ADDA.L	D6,A1
	BSR	L0064
	RTS
L005C	CMPA.L	#L0001,A5
	BNE.S	L005D
	CMPI.L	#L0000,L009A
	BEQ.S	L005D
	MOVEA.L	L009A,A5
	MOVEA.L	#L0000,A4
	BRA	L0059
L005D	MOVE.L	D5,D0
	RTS
L005E	TST.W	D4
	BMI.S	L005F
	MOVE.W	D4,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
L005F	LEA	16(A4),A4
	BRA	L0058
L0060	CMPI.B	#$3A,1(A0)
	BNE.S	L0061
	ADDQ.L	#2,A0
L0061	MOVEA.L	A0,A1
L0062	CMPI.B	#$5C,(A1)+
	BNE.S	L0063
	MOVEA.L	A1,A0
L0063	TST.B	(A1)
	BNE.S	L0062
	RTS
L0064	CLR.W	D1
	CLR.W	D2
L0065	MOVE.B	0(A0,D1.W),D0
	CMP.B	#$61,D0
	BLT.S	L0066
	CMP.B	#$7A,D0
	BGT.S	L0066
	ANDI.B	#-$21,D0
L0066	CMP.B	#$3F,D0
	BNE.S	L0067
	TST.B	0(A1,D2.W)
	BEQ.S	L006E
	CMPI.B	#$2E,0(A1,D2.W)
	BEQ.S	L006E
	BRA.S	L0069
L0067	CMP.B	0(A1,D2.W),D0
	BNE.S	L006A
L0068	TST.B	D0
	BEQ.S	L006F
L0069	ADDQ.B	#1,D1
	ADDQ.B	#1,D2
	BRA.S	L0065
L006A	CMP.B	#$2A,D0
	BNE.S	L006E
	ADDQ.B	#1,D1
	MOVE.B	0(A0,D1.W),D0
	CMP.B	#$61,D0
	BLT.S	L006B
	CMP.B	#$7A,D0
	BGT.S	L006B
	ANDI.B	#-$21,D0
L006B	TST.B	D0
	BEQ.S	L006D
L006C	ADDQ.B	#1,D2
	CMP.B	0(A1,D2.W),D0
	BEQ.S	L0068
	CMPI.B	#$2E,0(A1,D2.W)
	BEQ.S	L0068
	TST.B	0(A1,D2.W)
	BNE.S	L006C
	BRA.S	L006E
L006D	ADDQ.B	#1,D2
	CMPI.B	#$2E,0(A1,D2.W)
	BEQ.S	L006E
	TST.B	0(A1,D2.W)
	BNE.S	L006D
	BRA.S	L006F
L006E	LEA	22(A1),A1
	CMPA.L	A1,A2
	BGT	L0064
	MOVEA.L	#-1,A1
L006F	MOVE.L	A1,D0
	RTS
L0070	MOVEM.L	A0-A6/D0-D7,-(A7)
	CLR.L	D0
	MOVE.B	(A0),D0
	LSL.W	#8,D0
	MOVE.B	1(A0),D0
	SWAP	D0
	MOVE.B	2(A0),D0
	LSL.W	#8,D0
	MOVE.B	3(A0),D0
	CMP.L	#"AU5!",D0
	BEQ	L0071
	CMP.L	#"AU5$",D0
	BNE	L0072
L0071	BSR	L0075
	BRA	L0074
L0072	MOVE.L	L00AD,D0
	ADDA.L	D0,A0
	ADDA.L	D0,A1
	SUBQ.L	#1,D0
L0073	MOVE.B	-(A0),-(A1)
	DBF	D0,L0073
L0074	MOVEM.L	(A7)+,A0-A6/D0-D7
	RTS

L0075
ice_depack
	move.w	$ffff8240.w,-(a7)
	bsr.s	getinfo		; ein Langwort holen
	cmpi.l	#'AU5!',d0	; Kennung gefunden?
	bne	not_packed	; nein: nicht gepackt
	bsr.s	getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	getinfo		; ungepackte LÑnge holen (original)
;	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	move.l	a1,a4		; a4 = Zielpuffer
	move.l	a1,a6
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr	normal_bytes

	bsr	get_1_bit 	;; Picture decrunch!
	bcc.s	not_packed	;; These marked lines may be
	move.w	#$0f9f,d7 	;; removed in your own sources
ice_00:	moveq	#3,d6		;; if you do not use the
ice_01:	move.w	-(a3),d4		;; additional algorithm.
	moveq	#3,d5		;;
ice_02:	add.w	d4,d4		;;
	addx.w	d0,d0		;;
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,ice_02 	;;
	dbra	d6,ice_01 	;;
	movem.w	d0-d3,(a3)	;;
	dbra	d7,ice_00 	;;

not_packed:
	rts

getinfo:	moveq	#3,d1		; ein Langwort vom Anfang
getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,getbytes
	rts

normal_bytes:	
	bsr.s	get_1_bit
	bcc.s	test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	get_1_bit
	bcc.s	copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	direkt_tab+20(pc),a1
	moveq.l	#4,d3
nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,nextgb 	; ja: dann weiter Bits lesen
no_more:	add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
copy_direkt:	
	move.w	d0,$ffff8240.w
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,copy_direkt	; noch ein Byte
test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	strings		; Weiter wenn Ende nicht erreicht
	move.l	d7,d5
	move.l	(a7)+,d0
	move.w	(a7)+,$ffff8240.w
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	bitfound		; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
bitfound:	rts	

get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


strings:	lea.l	length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
get_length_bit:	
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit	; nÑchstes Bit holen
no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	no_Åber		; kein öberschuû nîtig
get_Åber: bsr.s	get_d0_bits
no_Åber:	move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	more_offset(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
getoffs:	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	depack_bytes


get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	get_1_bit
	bcc.s	less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
less_40:	bsr.s	get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,dep_b	; und noch ein Mal
	bra	normal_bytes	; Jetzt kommen wieder normale Bytes


direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

length_tab:
	dc.b 9,1,0,-1,-1	; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

more_offset:
	dc.b	  11,4,7,0	; Bits lesen
	dc.w	$11f,-1,$1f	; Standard Offset
	dc.b	0


L0092	DC.B	$0A,$03,$02,$02,$0E,$07,$04,$01
L0093	DC.B	$0A,$02,$01,$00,$00,$0A,$06,$04
	DC.B	$03,$02
L0094	DC.B	$0B,$04,$07,$00,$01,$20,$00,$00
	DC.B	$00,$20,$00,$00
L0095	DS.W	3
	DC.B	$00,$01,$00,$00,$00,$02,$00,$00
	DC.B	$00,$03,$00,$00,$00,$04,$00,$00
	DC.B	$00,$05,$00,$00,$00,$00,$00,$00
	DS.W	29
L0096	DS.W	2
L0097	DS.W	7
L0098	DS.W	2
L0099	DS.W	2
L009A	DS.W	2
L009B	DS.W	2
L009C	DS.W	2
L009D	DS.W	1
L009E	DS.W	2
L009F	DS.W	2
L00A0	DS.W	32
L00A1	DS.W	8
L00A2	DS.W	2
L00A3	DS.W	16
L00A4	DS.W	32
L00A5	DS.W	32
L00A6	DS.W	256
L00A7	DS.W	32
L00A8	DS.W	32
L00A9	DS.W	100
L00AA	DS.W	2
L00AB	DS.W	2
L00AC	DS.W	2
L00AD	DS.W	2
L00AE	DS.W	506
L00AF	DS.W	2
ZUEND		END