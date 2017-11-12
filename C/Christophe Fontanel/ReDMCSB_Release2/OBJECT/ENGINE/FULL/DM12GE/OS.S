BSS SEG "bss"
G518_pc_Sy:/* global */
	.WORD	#4
CODE SEG "main"
R055_xxxx_:/* global */
	MOVE.L	A2,D3
	MOVE.L	(A7)+,G518_pc_Sy(A4)
	TRAP	#13
	MOVE.L	G518_pc_Sy(A4),A0
	MOVE.L	D3,A2
	JMP	(A0)
R056_aaal_:/* global */
	MOVE.L	A2,D3
	MOVE.L	(A7)+,G518_pc_Sy(A4)
	TRAP	#14
	MOVE.L	G518_pc_Sy(A4),A0
	MOVE.L	D3,A2
	JMP	(A0)
R057_rzzz_:/* global */
	MOVE.L	A2,D3
	MOVE.L	(A7)+,G518_pc_Sy(A4)
	TRAP	#1
	MOVE.L	G518_pc_Sy(A4),A0
	MOVE.L	D3,A2
	JMP	(A0)
S058_xxxx_:/* global */
	MOVEQ	#255,D0
	RTS
S059_aaac_:/* global */
	LEA	S058_xxxx_(PC),A0
	MOVE.L	A0,1028.W
	RTS
