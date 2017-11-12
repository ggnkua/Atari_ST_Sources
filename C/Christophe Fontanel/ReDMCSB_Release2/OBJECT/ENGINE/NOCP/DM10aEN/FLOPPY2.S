CODE SEG "start"
F452_xxxx_:/* global */
	LINK	A6,L$0
	MOVEM.L	A3/D7-D6,-(A7)
	MOVE	G631_i_Gra(A4),D6
	BEQ.S	L2
	MOVE	#1,G631_i_Gra(A4)
	JSR	F478_gzzz_(PC)
L2:
	CLR	-(A7)
	MOVE.L	#1024,-(A7)
	JSR	F468_ozzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,A3
	JSR	F450_xxxx_(PC)
	MOVE	#2,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE	#1,-(A7)
	CLR	-(A7)
	CLR.L	-(A7)
	MOVE.L	A3,-(A7)
	MOVE	#8,-(A7)
	JSR	R056_aaal_(PC)
	ADDA	#20,A7
	TST	D0
	BEQ.S	L3
	MOVE	#3,D7
	BRA.S	L4
L3:
	MOVE	#1,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE	#10,-(A7)
	CLR	-(A7)
	CLR.L	-(A7)
	MOVE.L	A3,-(A7)
	MOVE	#8,-(A7)
	JSR	R056_aaal_(PC)
	ADDA	#20,A7
	TST	D0
	BNE.S	L5
	CLR	D7
	BRA.S	L6
L5:
	MOVE.L	A3,-(A7)
	CLR	-(A7)
	JSR	F449_xxxx_(PC)
	ADDQ.L	#6,A7
	TST	D0
	BEQ.S	L7
	MOVE	#2,D7
	BRA.S	L8
L7:
	MOVE	#1,D7
L8:
L6:
L4:
	MOVE.L	#1024,-(A7)
	JSR	F469_rzzz_(PC)
	ADDQ.L	#4,A7
	MOVE	D6,D0
	BEQ.S	L9
	JSR	F477_izzz_(PC)
	MOVE	D6,G631_i_Gra(A4)
L9:
	MOVE	D7,D0
L1:
	MOVEM.L	(A7)+,D6-D7/A3
	UNLK	A6
	RTS
L$0:	.EQU	#0
