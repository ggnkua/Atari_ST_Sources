CODE SEG "start"
F448_xxxx_:/* global */
	LINK	A6,L$0
	MOVEM.L	A3-A2/D7-D5,-(A7)
DATA SEG "s!"
s!:
	DATA 1B 66 00 00 
CODE SEG "start"
	PEA	s!(A4)
	MOVE	#9,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#6,A7
	PEA	S059_aaac_(PC)
	MOVE	#38,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#6,A7
	MOVE.L	#-1,-(A7)
	MOVE	#72,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#6,A7
	SUB.L	#20,D0
	MOVE.L	D0,D7
	CLR.L	-(A7)
	MOVE	#32,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,A2
	MOVE.L	1266.W,A1
	MOVE.L	12(A1),D6
	MOVE.L	20(A1),A0
	MOVE.L	4(A0),D5
	SUB.L	D6,D5
	MOVE.L	A2,-(A7)
	MOVE	#32,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D5,-(A7)
	MOVE.L	D6,-(A7)
	MOVE.L	D7,-(A7)
	MOVE.L	D7,-(A7)
	MOVE	#72,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,A3
	MOVE.L	D0,-(A7)
	JSR	F475_ozzz_(PC)
	ADDA	#16,A7
	JSR	F479_izzz_(PC)
	JSR	F460_xxxx_(PC)
	JSR	F437_xxxx_(PC)
	CLR	-(A7)
	JSR	F094_mzzz_(PC)
	ADDQ.L	#2,A7
	CLR	-(A7)
	JSR	F095_izzz_(PC)
	ADDQ.L	#2,A7
	JSR	F054_aAA1_(PC)
	JSR	F031_aAA2_(PC)
	MOVE	#32,-(A7)
	PEA	G346_aui_P(A4)
	PEA	G021_aaui_(A4)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	#32,-(A7)
	PEA	G347_aui_P(A4)
	PEA	G021_aaui_(A4)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	JSR	F066_aalz_(PC)
	PEA	F018_aaat_(PC)
	MOVE	#38,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#6,A7
	MOVE	#5,-(A7)
	MOVE	#26,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#4,A7
	JSR	F062_aalz_(PC)
	MOVE	#37,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#2,A7
	JSR	F441_xxxx_(PC)
	BRA.S	L2
L3:
	JSR	F477_izzz_(PC)
	JSR	F441_xxxx_(PC)
L2:
	JSR	F435_xxxx_(PC)
	CMPI	#1,D0
	BNE.S	L3
L4:
	JSR	F477_izzz_(PC)
	JSR	F396_pzzz_(PC)
	JSR	F476_mzzz_(PC)
	JSR	F462_xxxx_(PC)
	JSR	F478_gzzz_(PC)
	MOVE	G298_B_New(A4),D0
	BEQ.S	L5
	MOVE	G307_i_Par(A4),-(A7)
	MOVE	G306_i_Par(A4),-(A7)
	CLR	-(A7)
	MOVE	#-1,-(A7)
	MOVE	#-1,-(A7)
	JSR	F267_dzzz_(PC)
	ADDA	#10,A7
L5:
	JSR	F078_xzzz_(PC)
	JSR	F357_qzzz_(PC)
L1:
	MOVEM.L	(A7)+,D5-D7/A2-A3
	UNLK	A6
	RTS
L$0:	.EQU	#0
