CODE SEG "start"
F449_xxxx_:/* global */
	LINK	A6,L$0
	MOVE	#1,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE	#1,-(A7)
	CLR	-(A7)
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	MOVE	#8,-(A7)
	JSR	R056_aaal_(PC)
	ADDA	#20,A7
	MOVE	#1,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE	#1,-(A7)
	CLR	-(A7)
	CLR.L	-(A7)
	MOVE.L	8(A6),-(A7)
	MOVE	#9,-(A7)
	JSR	R056_aaal_(PC)
	ADDA	#20,A7
	CMPI.L	#-13,D0
	SEQ	D0
	AND	#1,D0
L1:
	UNLK	A6
	RTS
L$0:	.EQU	#0
F450_xxxx_:/* global */
	LINK	A6,L$2
	CLR	-(A7)
	CLR	-(A7)
	MOVE	#2,-(A7)
	CLR.L	-(A7)
	CLR	-(A7)
	MOVE	#4,-(A7)
	JSR	R055_xxxx_(PC)
	ADDA	#14,A7
DATA SEG "s!"
s!:
	DATA 46 00 
CODE SEG "start"
	CLR	-(A7)
	PEA	s!(A4)
	MOVE	#78,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#8,A7
L3:
	UNLK	A6
	RTS
L$2:	.EQU	#0
