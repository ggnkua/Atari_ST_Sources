CODE SEG "start"
F448_xxxx_:/* global */
	LINK	A6,L$0
	MOVEM.L	D7-D4,-(A7)
DATA SEG "s!"
s!:
	DATA 1B 66 00 00 
CODE SEG "start"
	PEA	s!(A4)
	MOVE	#9,-(A7)
	JSR	R057_rzzz_(PC)
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
	MOVE.L	D0,D4
	MOVE.L	1266.W,A1
	MOVE.L	12(A1),D6
	MOVE.L	20(A1),A0
	MOVE.L	4(A0),D5
	SUB.L	D6,D5
	MOVE.L	D4,-(A7)
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
	MOVE.L	D0,-(A7)
	JSR	F475_ozzz_(PC)
	ADDA	#16,A7
L1:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$0:	.EQU	#0
