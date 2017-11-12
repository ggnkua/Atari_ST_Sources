BSS SEG "bss"
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
G526_ui_Du:/* global */
	.WORD	#2
G527_i_Pla:/* global */
	.WORD	#2
G528_i_For:/* global */
	.WORD	#2
G529_i_Use:/* global */
	.WORD	#2
G530_B_Loa:/* global */
	.WORD	#2
G531_puc_D:/* global */
	.WORD	#4
G532_l_Dec:/* global */
	.WORD	#4
G533_ac_Co:/* global */
	.WORD	#68
G534_ac_Sa:/* global */
	.WORD	#132
CODE SEG "start"
F414_xxxx_:/* global */
	LINK	A6,L$0
	MOVE.L	8(A6),A0
	CLR.B	(A0)
	MOVE	#126,-(A7)
	MOVE.L	12(A6),-(A7)
	JSR	index(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,-4(A6)
	CMPI.L	#0,D0
	BEQ.S	L2
	MOVE.L	-4(A6),D0
	SUB.L	12(A6),D0
	MOVE	D0,-6(A6)
	MOVE	D0,-(A7)
	MOVE.L	12(A6),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	strncpy(PC)
	ADDA	#10,A7
	MOVE	-6(A6),D0
	MOVE.L	8(A6),A0
	ADDA	D0,A0
	CLR.B	(A0)
	MOVE	G567_B_Sin(A4),D0
	BNE.S	L4
	CMPI	#1,16(A6)
	BNE.S	L3
L4:
	MOVE.L	G571_pc_D1(A4),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	strcat(PC)
	ADDQ.L	#8,A7
	BRA.S	L5
L3:
	MOVE.L	G572_pc_D1(A4),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	strcat(PC)
	ADDQ.L	#8,A7
L5:
	MOVE.L	-4(A6),D0
	ADDQ.L	#1,D0
	MOVE.L	D0,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	strcat(PC)
	ADDQ.L	#8,A7
L2:
L1:
	UNLK	A6
	RTS
L$0:	.EQU	#-6
F415_xxxx_:/* global */
	LINK	A6,L$6
	MOVE.L	D7,-(A7)
	MOVE	12(A6),D0
	AND.L	#65535,D0
	MOVE.L	D0,D7
	CMPI.L	#0,D0
	BNE.S	L8
	MOVE	#1,D0
	BRA.S	L7
L8:
	MOVE	G530_B_Loa(A4),D0
	BEQ.S	L9
	MOVE.L	D7,D0
	CMP.L	G532_l_Dec(A4),D0
	BLE.S	L10
	MOVE	#0,D0
	BRA.S	L7
L10:
	MOVE.L	D7,D0
	MOVE	D0,-(A7)
	MOVE.L	8(A6),-(A7)
	MOVE.L	G531_puc_D(A4),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE.L	D7,D0
	ADD.L	D0,G531_puc_D(A4)
	MOVE.L	D7,D0
	SUB.L	D0,G532_l_Dec(A4)
	MOVE	#1,D0
	BRA.S	L7
L9:
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
L7:
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS
L$6:	.EQU	#0
F416_xxxx_:/* global */
	LINK	A6,L$11
	MOVE.L	D7,-(A7)
	MOVE	12(A6),D0
	AND.L	#65535,D0
	MOVE.L	D0,D7
	CMPI.L	#0,D0
	BNE.S	L13
	MOVE	#1,D0
	BRA.S	L12
L13:
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
L12:
	MOVE.L	(A7)+,D7
	UNLK	A6
	RTS
L$11:	.EQU	#0
F417_xxxx_:/* global */
	LINK	A6,L$14
	MOVEM.L	A3/D7-D5,-(A7)
	MOVE.L	8(A6),A3
	MOVE	12(A6),D7
	MOVE	14(A6),D6
	MOVE	D7,D5
L16:
	ADD	(A3),D5
	MOVE	D7,D0
	EOR	D0,(A3)
	ADD	(A3)+,D5
	ADD	D6,D7
L17:
	SUBQ	#1,D6
	BNE.S	L16
L18:
	MOVE	D5,D0
L15:
	MOVEM.L	(A7)+,D5-D7/A3
	UNLK	A6
	RTS
L$14:	.EQU	#0
F418_xxxx_:/* global */
	LINK	A6,L$19
	MOVEM.L	A3/D7-D5,-(A7)
	MOVE.L	8(A6),A3
	MOVE	12(A6),D7
	MOVE	14(A6),D6
	MOVE	D7,D5
L21:
	ADD	(A3),D5
	MOVE	(A3)+,D0
	EOR	D7,D0
	ADD	D0,D5
	ADD	D6,D7
L22:
	SUBQ	#1,D6
	BNE.S	L21
L23:
	MOVE	D5,D0
L20:
	MOVEM.L	(A7)+,D5-D7/A3
	UNLK	A6
	RTS
L$19:	.EQU	#0
F419_xxxx_:/* global */
	LINK	A6,L$24
	MOVE	12(A6),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F415_xxxx_(PC)
	ADDQ.L	#6,A7
	TST	D0
	BEQ.S	L26
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
L26:
	SNE	D0
	AND	#1,D0
L25:
	UNLK	A6
	RTS
L$24:	.EQU	#-10
F420_xxxx_:/* global */
	LINK	A6,L$27
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
L28:
	MOVEM.L	(A7)+,D6-D7/A3
	UNLK	A6
	RTS
L$27:	.EQU	#0
F421_xxxx_:/* global */
	LINK	A6,L$29
	MOVEM.L	A3-A2/D7-D6,-(A7)
	MOVE.L	8(A6),A3
	MOVE.L	12(A6),A2
	MOVE	16(A6),D7
	CLR	D6
	MOVE	D7,-(A7)
	MOVE.L	A3,-(A7)
	JSR	F415_xxxx_(PC)
	ADDQ.L	#6,A7
	TST	D0
	BNE.S	L31
	MOVE	#0,D0
	BRA.S	L30
L31:
	BRA.S	L32
L33:
	MOVE.B	(A3)+,D0
	AND	#255,D0
	ADD	D0,D6
L32:
	MOVE	D7,D0
	SUBQ	#1,D7
	TST	D0
	BNE.S	L33
L34:
	MOVE	D6,D0
	ADD	D0,(A2)
	MOVE	#1,D0
L30:
	MOVEM.L	(A7)+,D6-D7/A2-A3
	UNLK	A6
	RTS
L$29:	.EQU	#0
F422_xxxx_:/* global */
	LINK	A6,L$35
	MOVEM.L	A3-A2/D7-D6,-(A7)
	MOVE.L	8(A6),A3
	MOVE.L	12(A6),A2
	MOVE	16(A6),D7
	CLR	D6
	MOVE	D7,-(A7)
	MOVE.L	A3,-(A7)
	JSR	F416_xxxx_(PC)
	ADDQ.L	#6,A7
	TST	D0
	BNE.S	L37
	MOVE	#0,D0
	BRA.S	L36
L37:
	BRA.S	L38
L39:
	MOVE.B	(A3)+,D0
	AND	#255,D0
	ADD	D0,D6
L38:
	MOVE	D7,D0
	SUBQ	#1,D7
	TST	D0
	BNE.S	L39
L40:
	MOVE	D6,D0
	ADD	D0,(A2)
	MOVE	#1,D0
L36:
	MOVEM.L	(A7)+,D6-D7/A2-A3
	UNLK	A6
	RTS
L$35:	.EQU	#0
