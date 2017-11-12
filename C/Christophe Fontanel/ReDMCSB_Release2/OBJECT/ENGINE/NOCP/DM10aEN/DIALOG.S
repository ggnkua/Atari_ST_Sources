CODE SEG "init!"
DATA SEG "s!"
s!:
	DATA 50 55 54 20 47 41 4D 45 20 53 41 56 45 20 44 49 53 4B 20 49 4E 20 44 52 49 56 45 20 41 3A 00 00 
CODE SEG "init!"
	LEA	s!(A4),A0
	MOVE.L	A0,G548_pc_D0(A4)
BSS SEG "bss"
G548_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 47 41 4D 45 20 4C 4F 41 44 45 44 2C 20 52 45 41 44 59 20 54 4F 20 50 4C 41 59 2E 00 
CODE SEG "init!"
	LEA	s!+32(A4),A0
	MOVE.L	A0,G536_pc_D0(A4)
BSS SEG "bss"
G536_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 43 41 4E 27 54 20 4D 4F 44 49 46 59 20 44 55 4E 47 45 4F 4E 20 4D 41 53 54 45 52 20 44 49 53 4B 21 00 
CODE SEG "init!"
	LEA	s!+60(A4),A0
	MOVE.L	A0,G537_pc_D0(A4)
BSS SEG "bss"
G537_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 50 55 54 20 44 55 4E 47 45 4F 4E 20 4D 41 53 54 45 52 20 44 49 53 4B 20 49 4E 20 41 3A 00 
CODE SEG "init!"
	LEA	s!+94(A4),A0
	MOVE.L	A0,G549_pc_D0(A4)
BSS SEG "bss"
G549_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 54 48 41 54 27 53 20 4E 4F 54 20 54 48 45 20 4D 41 53 54 45 52 20 44 49 53 4B 21 00 
CODE SEG "init!"
	LEA	s!+124(A4),A0
	MOVE.L	A0,G538_pc_D0(A4)
BSS SEG "bss"
G538_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 50 55 54 20 41 20 42 4C 41 4E 4B 20 44 49 53 4B 20 49 4E 20 44 52 49 56 45 20 41 3A 00 00 
CODE SEG "init!"
	LEA	s!+152(A4),A0
	MOVE.L	A0,G550_pc_D0(A4)
BSS SEG "bss"
G550_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 43 41 4E 27 54 20 46 49 4E 44 20 53 41 56 45 44 20 47 41 4D 45 21 00 00 
CODE SEG "init!"
	LEA	s!+182(A4),A0
	MOVE.L	A0,G539_pc_D0(A4)
BSS SEG "bss"
G539_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 55 4E 41 42 4C 45 20 54 4F 20 53 41 56 45 20 47 41 4D 45 21 00 00 
CODE SEG "init!"
	LEA	s!+206(A4),A0
	MOVE.L	A0,G540_pc_D0(A4)
BSS SEG "bss"
G540_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 54 48 41 54 27 53 20 54 48 45 20 44 55 4E 47 45 4F 4E 20 4D 41 53 54 45 52 20 44 49 53 4B 21 00 
CODE SEG "init!"
	LEA	s!+228(A4),A0
	MOVE.L	A0,G542_pc_D0(A4)
BSS SEG "bss"
G542_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 54 48 41 54 20 44 49 53 4B 20 49 53 20 57 52 49 54 45 2D 50 52 4F 54 45 43 54 45 44 21 00 
CODE SEG "init!"
	LEA	s!+260(A4),A0
	MOVE.L	A0,G544_pc_D0(A4)
BSS SEG "bss"
G544_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 54 48 41 54 20 44 49 53 4B 20 49 53 20 55 4E 52 45 41 44 41 42 4C 45 2E 00 00 
CODE SEG "init!"
	LEA	s!+290(A4),A0
	MOVE.L	A0,G545_pc_D0(A4)
BSS SEG "bss"
G545_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 54 48 41 54 27 53 20 4E 4F 54 20 54 48 45 20 53 41 4D 45 20 47 41 4D 45 2E 00 
CODE SEG "init!"
	LEA	s!+316(A4),A0
	MOVE.L	A0,G546_pc_D0(A4)
BSS SEG "bss"
G546_pc_D0:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 4C 4F 41 44 20 53 41 56 45 44 20 47 41 4D 45 00 
CODE SEG "init!"
	LEA	s!+342(A4),A0
	MOVE.L	A0,G556_pc_D1(A4)
BSS SEG "bss"
G556_pc_D1:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 53 41 56 45 20 41 4E 44 20 50 4C 41 59 00 
CODE SEG "init!"
	LEA	s!+358(A4),A0
	MOVE.L	A0,G557_pc_D1(A4)
BSS SEG "bss"
G557_pc_D1:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 53 41 56 45 20 41 4E 44 20 51 55 49 54 00 
CODE SEG "init!"
	LEA	s!+372(A4),A0
	MOVE.L	A0,G558_pc_D1(A4)
BSS SEG "bss"
G558_pc_D1:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 46 4F 52 4D 41 54 20 46 4C 4F 50 50 59 00 
CODE SEG "init!"
	LEA	s!+386(A4),A0
	MOVE.L	A0,G559_pc_D1(A4)
BSS SEG "bss"
G559_pc_D1:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 4F 4B 00 00 
CODE SEG "init!"
	LEA	s!+400(A4),A0
	MOVE.L	A0,G560_pc_D1(A4)
BSS SEG "bss"
G560_pc_D1:/* global */
	.WORD	#4
CODE SEG "init!"
DATA SEG "s!"
	DATA 43 41 4E 43 45 4C 00 00 
CODE SEG "init!"
	LEA	s!+404(A4),A0
	MOVE.L	A0,G561_pc_D1(A4)
BSS SEG "bss"
G561_pc_D1:/* global */
	.WORD	#4
CODE SEG "start"
F424_xxxx_:/* global */
	LINK	A6,L$0
	MOVE.L	G441_ps_Pr(A4),-4(A6)
	MOVE.L	G442_ps_Se(A4),-8(A6)
	MOVE.L	G443_ps_Pr(A4),-12(A6)
	MOVE.L	G444_ps_Se(A4),-16(A6)
	MOVE.L	#0,D0
	MOVE.L	D0,G444_ps_Se(A4)
	MOVE.L	D0,G443_ps_Pr(A4)
	MOVE.L	D0,G442_ps_Se(A4)
	MOVE	8(A6),D0
	MOVE	10(A6),D1
	MULS	#16,D1
	LEA	G480_aaps_+-4(A4),A0
	ADD.L	A0,D1
	ASL.L	#2,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE.L	(A0),G441_ps_Pr(A4)
	JSR	F357_qzzz_(PC)
	MOVE	#99,G335_i_Sel(A4)
L2:
	JSR	F380_xzzz_(PC)
	MOVE	#37,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#2,A7
	CMPI	#99,G335_i_Sel(A4)
	BNE.S	L5
	CMPI	#1,8(A6)
	BNE.S	L5
	MOVE	#11,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BEQ.S	L5
	MOVE	#7,-(A7)
	JSR	R057_rzzz_(PC)
	ADDQ.L	#2,A7
	CMPI	#13,D0
	BNE.S	L5
	MOVE	#1,G335_i_Sel(A4)
L5:
L3:
	CMPI	#99,G335_i_Sel(A4)
	BEQ.S	L2
L4:
	CLR	G578_B_Use(A4)
	MOVE	#8,-(A7)
	PEA	-34(A6)
	MOVE	G335_i_Sel(A4),D0
	MULS	#12,D0
	MOVE.L	G441_ps_Pr(A4),A0
	ADDA	D0,A0
	LEA	-10(A0),A0
	MOVE.L	A0,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	SUBQ	#3,-34(A6)
	ADDQ	#3,-32(A6)
	SUBQ	#3,-30(A6)
	ADDQ	#4,-28(A6)
	JSR	F077_aA39_(PC)
	MOVE	#1,G297_B_Dra(A4)
	CLR	-26(A6)
	CLR	-22(A6)
	MOVE	-28(A6),D0
	SUB	-30(A6),D0
	ADDQ	#3,D0
	MOVE	D0,-20(A6)
	MOVE	-32(A6),D0
	SUB	-34(A6),D0
	ADDQ	#3,D0
	MOVE	D0,-24(A6)
	MOVE	#-1,-(A7)
	MOVE	#160,-(A7)
	MOVE	#160,-(A7)
	MOVE	-30(A6),-(A7)
	MOVE	-34(A6),-(A7)
	PEA	-26(A6)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE	#37,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#2,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	-22(A6),-20(A6)
	MOVE	#160,-(A7)
	MOVE	#5,-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	-26(A6),-24(A6)
	SUBQ	#1,-20(A6)
	MOVE	#160,-(A7)
	MOVE	#5,-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	SUBQ	#1,-20(A6)
	MOVE	-20(A6),D0
	MOVE	D0,-22(A6)
	SUBQ	#2,-26(A6)
	MOVE	#160,-(A7)
	CLR	-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	-24(A6),-26(A6)
	MOVE	#160,-(A7)
	CLR	-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#5,-(A7)
	JSR	F022_aaaU_(PC)
	ADDQ.L	#2,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	ADDQ	#1,-22(A6)
	MOVE	-22(A6),D0
	MOVE	D0,-20(A6)
	SUBQ	#2,-24(A6)
	MOVE	#160,-(A7)
	MOVE	#5,-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	ADDQ	#1,-26(A6)
	MOVE	-26(A6),D0
	MOVE	D0,-24(A6)
	SUBQ	#1,-20(A6)
	MOVE	#160,-(A7)
	MOVE	#5,-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	SUBQ	#1,-24(A6)
	MOVE	-24(A6),D0
	MOVE	D0,-26(A6)
	MOVE	#160,-(A7)
	CLR	-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	-20(A6),D0
	SUBQ	#2,D0
	MOVE	D0,-20(A6)
	MOVE	D0,-22(A6)
	ADDQ	#1,-26(A6)
	MOVE	#160,-(A7)
	CLR	-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	-20(A6),D0
	ADDQ	#2,D0
	MOVE	D0,-20(A6)
	MOVE	D0,-22(A6)
	SUBQ	#1,-26(A6)
	ADDQ	#2,-24(A6)
	MOVE	#160,-(A7)
	MOVE	#13,-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#8,-(A7)
	PEA	-26(A6)
	PEA	-34(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	-24(A6),D0
	ADDQ	#3,D0
	MOVE	D0,-24(A6)
	MOVE	D0,-26(A6)
	ADDQ	#2,-20(A6)
	MOVE	#160,-(A7)
	MOVE	#13,-(A7)
	PEA	-26(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F135_xzzz_(PC)
	ADDA	#12,A7
	MOVE	#5,-(A7)
	JSR	F022_aaaU_(PC)
	ADDQ.L	#2,A7
	ADDQ	#3,-32(A6)
	ADDQ	#3,-28(A6)
	MOVE	#-1,-(A7)
	MOVE	#160,-(A7)
	MOVE	#160,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	PEA	-34(A6)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	JSR	F078_xzzz_(PC)
	MOVE.L	-4(A6),G441_ps_Pr(A4)
	MOVE.L	-8(A6),G442_ps_Se(A4)
	MOVE.L	-12(A6),G443_ps_Pr(A4)
	MOVE.L	-16(A6),G444_ps_Se(A4)
	JSR	F357_qzzz_(PC)
	MOVE	G335_i_Sel(A4),D0
L1:
	UNLK	A6
	RTS
L$0:	.EQU	#-34
F425_xxxx_:/* global */
	LINK	A6,L$6
	CMPI.L	#0,12(A6)
	BEQ.S	L8
	MOVE.L	12(A6),-(A7)
	JSR	strlen(PC)
	ADDQ.L	#4,A7
	MULS	#6,D0
	ASR	#1,D0
	SUB	D0,16(A6)
	MOVE.L	12(A6),-(A7)
	MOVE	#5,-(A7)
	MOVE	#9,-(A7)
	MOVE	18(A6),-(A7)
	MOVE	16(A6),-(A7)
	MOVE	#112,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F040_aacZ_(PC)
	ADDA	#18,A7
L8:
L7:
	UNLK	A6
	RTS
L$6:	.EQU	#0
F427_xxxx_:/* global */
	LINK	A6,L$9
	MOVEM.L	D7-D4,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G343_puc_G(A4),-(A7)
	JSR	F466_rzzz_(PC)
	ADDA	#12,A7
	MOVE	#1,D4
	CMPI.L	#0,20(A6)
	BEQ.S	L11
	ADDQ	#1,D4
L11:
	CMPI.L	#0,24(A6)
	BEQ.S	L12
	ADDQ	#1,D4
L12:
	CMPI.L	#0,28(A6)
	BEQ.S	L13
	ADDQ	#1,D4
L13:
	MOVE	36(A6),D0
	BEQ.S	L14
	MOVE	#32,-(A7)
	PEA	-32(A6)
	JSR	F008_aA19_(PC)
	ADDQ.L	#6,A7
	PEA	-32(A6)
	JSR	F436_xxxx_(PC)
	ADDQ.L	#4,A7
L14:
	MOVE	34(A6),D0
	BEQ.S	L15
	MOVE	#32000,-(A7)
	MOVE.L	G348_pl_Bi(A4),-(A7)
	JSR	F008_aA19_(PC)
	ADDQ.L	#6,A7
L15:
	CLR	G578_B_Use(A4)
	CMPI	#1,D4
	BNE.S	L16
	CLR	-(A7)
	MOVE.L	#8400,-(A7)
	JSR	F468_ozzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,-44(A6)
	MOVE	#-1,-(A7)
	MOVE	#112,-(A7)
	MOVE	#112,-(A7)
	MOVE	#14,-(A7)
	CLR	-(A7)
	PEA	G467_s_Gra(A4)
	MOVE.L	-44(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE	#-1,-(A7)
	MOVE	#112,-(A7)
	PEA	G468_s_Gra(A4)
	MOVE.L	-44(A6),-(A7)
	JSR	F020_aAA5_(PC)
	ADDA	#12,A7
	MOVE.L	#8400,-(A7)
	JSR	F469_rzzz_(PC)
	ADDQ.L	#4,A7
	MOVE	#114,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	16(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	BRA	L17(PC)
L16:
	CMPI	#2,D4
	BNE.S	L18
	MOVE	#-1,-(A7)
	MOVE	#112,-(A7)
	MOVE	#112,-(A7)
	MOVE	#52,-(A7)
	MOVE	#102,-(A7)
	PEA	G469_s_Gra(A4)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE	#77,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	16(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#114,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	20(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	BRA	L19(PC)
L18:
	CMPI	#3,D4
	BNE.S	L20
	MOVE	#77,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	16(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#114,-(A7)
	MOVE	#59,-(A7)
	MOVE.L	20(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#114,-(A7)
	MOVE	#166,-(A7)
	MOVE.L	24(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	BRA	L21(PC)
L20:
	CMPI	#4,D4
	BNE	L22(PC)
	MOVE	#-1,-(A7)
	MOVE	#112,-(A7)
	MOVE	#112,-(A7)
	MOVE	#99,-(A7)
	MOVE	#102,-(A7)
	PEA	G470_s_Gra(A4)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE	#77,-(A7)
	MOVE	#59,-(A7)
	MOVE.L	16(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#77,-(A7)
	MOVE	#166,-(A7)
	MOVE.L	20(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#114,-(A7)
	MOVE	#59,-(A7)
	MOVE.L	24(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#114,-(A7)
	MOVE	#166,-(A7)
	MOVE.L	28(A6),-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F425_xxxx_(PC)
	ADDA	#12,A7
L22:
L21:
L19:
L17:
	MOVE	#29,D5
	CMPI.L	#0,8(A6)
	BEQ.S	L23
	MOVE.L	8(A6),-(A7)
	JSR	strlen(PC)
	ADDQ.L	#4,A7
	MOVE.L	D0,D1
	MULS	#6,D1
	ASR	#1,D1
	MOVE	#113,D0
	SUB	D1,D0
	MOVE	D0,D6
	MOVE.L	8(A6),-(A7)
	MOVE	#5,-(A7)
	MOVE	#11,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F040_aacZ_(PC)
	ADDA	#18,A7
	ADDQ	#8,D5
L23:
	CMPI.L	#0,12(A6)
	BEQ.S	L24
	MOVE.L	12(A6),-(A7)
	JSR	strlen(PC)
	ADDQ.L	#4,A7
	MOVE.L	D0,D1
	MULS	#6,D1
	ASR	#1,D1
	MOVE	#113,D0
	SUB	D1,D0
	MOVE	D0,D6
	MOVE.L	12(A6),-(A7)
	MOVE	#5,-(A7)
	MOVE	#9,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F040_aacZ_(PC)
	ADDA	#18,A7
L24:
	MOVE	32(A6),D0
	BEQ.S	L25
	MOVE	#33,-36(A6)
	MOVE	#168,-34(A6)
	MOVE	#47,-40(A6)
	MOVE	#270,-38(A6)
	JSR	F077_aA39_(PC)
	MOVE	#-1,-(A7)
	MOVE	#112,-(A7)
	PEA	-40(A6)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F021_a002_(PC)
	ADDA	#12,A7
	JSR	F078_xzzz_(PC)
	BRA.S	L26
L25:
	CLR	-(A7)
	JSR	F097_lzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	#37,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#2,A7
L26:
	MOVE	36(A6),D0
	BEQ.S	L27
	PEA	G347_aui_P(A4)
	JSR	F436_xxxx_(PC)
	ADDQ.L	#4,A7
L27:
	MOVE	#1,G297_B_Dra(A4)
L10:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$9:	.EQU	#-44
F428_AA39_:/* global */
	LINK	A6,L$28
	MOVEM.L	A3/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	#1,D5
	MOVE.L	#0,A3
	BRA.S	L30
L31:
	MOVE	#0,D5
	MOVE	D5,D7
	MOVE	D6,-(A7)
	MOVE	D6,-(A7)
	MOVE	D6,-(A7)
	CLR.L	-(A7)
	CLR.L	-(A7)
	CLR.L	-(A7)
	MOVE.L	G560_pc_D1(A4),-(A7)
	MOVE.L	G549_pc_D0(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F427_xxxx_(PC)
	ADDA	#30,A7
	CMPI	#0,G587_i_Hid(A4)
	SLE	D4
	TST.B	D4
	SEQ	D4
	AND	#1,D4
	BEQ.S	L33
	JSR	F078_xzzz_(PC)
L33:
	MOVE	D6,-(A7)
	MOVE	#1,-(A7)
	JSR	F424_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	D4,D0
	BEQ.S	L34
	JSR	F077_aA39_(PC)
L34:
	MOVE.L	G538_pc_D0(A4),A3
L30:
	MOVE	D7,D0
	BNE.S	L31
	JSR	F452_xxxx_(PC)
	TST	D0
	BNE.S	L31
L32:
	MOVE	D5,D0
L29:
	MOVEM.L	(A7)+,D4-D7/A3
	UNLK	A6
	RTS
L$28:	.EQU	#0
