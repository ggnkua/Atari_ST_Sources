CODE SEG "init!"
DATA SEG "s!"
s!:
	DATA 41 3A 5C 44 4D 47 41 4D 45 2E 44 41 54 00 
CODE SEG "init!"
	LEA	s!(A4),A0
	MOVE.L	A0,G519_pc_D0(A4)
BSS SEG "bss"
G519_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 41 3A 5C 44 4D 47 41 4D 45 2E 42 41 4B 00 
CODE SEG "init!"
	LEA	s!+14(A4),A0
	MOVE.L	A0,G520_pc_D0(A4)
BSS SEG "bss"
G520_pc_D0:/* global */
	.WORD	#4
G521_i_Gam:/* global */
	.WORD	#2
G522_l_Unr:/* global */
	.WORD	#4
G523_B_Res:/* global */
	.WORD	#2
G524_B_Res:/* global */
	.WORD	#2
G525_l_Gam:/* global */
	.WORD	#4
G533_ac_Co:/* global */
	.WORD	#68
CODE SEG "start"
F415_xxxx_:/* global */
	LINK	A6,L$0
	MOVE.L	D7,-(A7)
	MOVE	12(A6),D0
	AND.L	#65535,D0
	MOVE.L	D0,D7
	CMPI.L	#0,D0
	BNE.S	L2
	MOVE	#1,D0
	BRA.S	L1
L2:
	MOVE.L	8(A6),-(A7)
	MOVE.L	D7,D0
	MOVE.L	D0,-(A7)
	MOVE	G521_i_Gam(A4),-(A7)
	MOVE	#63,-(A7)
	JSR	R057_rzzz_(PC)
	ADDA	#12,A7
	MOVE.L	D7,D1
	CMP.L	D1,D0
	SEQ	D0
	AND	#1,D0
L1:
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS
L$0:	.EQU	#0
F416_xxxx_:/* global */
	LINK	A6,L$3
	MOVE.L	D7,-(A7)
	MOVE	12(A6),D0
	AND.L	#65535,D0
	MOVE.L	D0,D7
	CMPI.L	#0,D0
	BNE.S	L5
	MOVE	#1,D0
	BRA.S	L4
L5:
	MOVE.L	8(A6),-(A7)
	MOVE.L	D7,D0
	MOVE.L	D0,-(A7)
	MOVE	G521_i_Gam(A4),-(A7)
	MOVE	#64,-(A7)
	JSR	R057_rzzz_(PC)
	ADDA	#12,A7
	MOVE.L	D7,D1
	CMP.L	D1,D0
	SEQ	D0
	AND	#1,D0
L4:
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS
L$3:	.EQU	#0
F417_xxxx_:/* global */
	LINK	A6,L$6
	MOVEM.L	A3/D7-D5,-(A7)
	MOVE.L	8(A6),A3
	MOVE	12(A6),D7
	MOVE	14(A6),D6
	MOVE	D7,D5
L8:
	ADD	(A3),D5
	MOVE	D7,D0
	EOR	D0,(A3)
	ADD	(A3)+,D5
	ADD	D6,D7
L9:
	SUBQ	#1,D6
	BNE.S	L8
L10:
	MOVE	D5,D0
L7:
	MOVEM.L	(A7)+,D5-D7/A3
	UNLK	A6
	RTS
L$6:	.EQU	#0
F418_xxxx_:/* global */
	LINK	A6,L$11
	MOVEM.L	A3/D7-D5,-(A7)
	MOVE.L	8(A6),A3
	MOVE	12(A6),D7
	MOVE	14(A6),D6
	MOVE	D7,D5
L13:
	ADD	(A3),D5
	MOVE	(A3)+,D0
	EOR	D7,D0
	ADD	D0,D5
	ADD	D6,D7
L14:
	SUBQ	#1,D6
	BNE.S	L13
L15:
	MOVE	D5,D0
L12:
	MOVEM.L	(A7)+,D5-D7/A3
	UNLK	A6
	RTS
L$11:	.EQU	#0
F419_xxxx_:/* global */
	LINK	A6,L$16
	MOVE	12(A6),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F415_xxxx_(PC)
	ADDQ.L	#6,A7
	TST	D0
	BEQ.S	L18
	MOVE	12(A6),D0
	LSR	#1,D0
	MOVE	D0,-(A7)
	MOVE	14(A6),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F417_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	D0,-10(A6)
	MOVE	16(A6),D0
	CMP	-10(A6),D0
	SEQ	D0
	TST.B	D0
L18:
	SNE	D0
	AND	#1,D0
L17:
	UNLK	A6
	RTS
L$16:	.EQU	#-10
F420_xxxx_:/* global */
	LINK	A6,L$19
	MOVEM.L	A3/D7-D6,-(A7)
	MOVE.L	8(A6),A3
	MOVE	12(A6),D0
	LSR	#1,D0
	MOVE	D0,D6
	MOVE	D0,-(A7)
	MOVE	14(A6),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F417_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE.L	16(A6),A0
	MOVE	D0,(A0)
	MOVE	12(A6),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F416_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D0,D7
	MOVE	D6,-(A7)
	MOVE	14(A6),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F417_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	D7,D0
L20:
	MOVEM.L	(A7)+,D6-D7/A3
	UNLK	A6
	RTS
L$19:	.EQU	#0
