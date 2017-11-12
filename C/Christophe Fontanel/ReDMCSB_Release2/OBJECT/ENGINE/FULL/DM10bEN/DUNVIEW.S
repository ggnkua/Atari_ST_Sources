BSS SEG "bss"
G000_s_Gra:/* global */
	.WORD	#8
G001_s_Gra:/* global */
	.WORD	#8
G002_s_Gra:/* global */
	.WORD	#8
G003_s_Gra:/* global */
	.WORD	#8
G004_s_Gra:/* global */
	.WORD	#8
G005_s_Gra:/* global */
	.WORD	#8
G006_s_Gra:/* global */
	.WORD	#8
G007_s_Gra:/* global */
	.WORD	#8
G008_s_Gra:/* global */
	.WORD	#8
G009_s_Gra:/* global */
	.WORD	#8
G010_s_Gra:/* global */
	.WORD	#8
G011_s_Gra:/* global */
	.WORD	#8
G012_s_Gra:/* global */
	.WORD	#8
G013_s_Gra:/* global */
	.WORD	#8
G014_s_Gra:/* global */
	.WORD	#8
G015_s_Gra:/* global */
	.WORD	#8
G016_s_Gra:/* global */
	.WORD	#8
G017_auc_G:/* global */
	.WORD	#16
G018_ai_Gr:/* global */
	.WORD	#140
G019_aui_G:/* global */
	.WORD	#32
G020_aui_G:/* global */
	.WORD	#32
G021_aaui_:/* global */
	.WORD	#192
G022_i_Gra:/* global */
	.WORD	#2
G023_aac_G:/* global */
	.WORD	#32
G024_ac_Gr:/* global */
	.WORD	#4
G025_ac_Gr:/* global */
	.WORD	#8
G026_ai_Gr:/* global */
	.WORD	#14
G027_ac_Gr:/* global */
	.WORD	#4
G028_s_Gra:/* global */
	.WORD	#8
G029_auc_G:/* global */
	.WORD	#16
G030_as_Gr:/* global */
	.WORD	#276
G031_i_Gra:/* global */
	.WORD	#2
G032_s_Gra:/* global */
	.WORD	#8
G033_s_Gra:/* global */
	.WORD	#8
G034_s_Gra:/* global */
	.WORD	#8
G035_s_Gra:/* global */
	.WORD	#8
G036_s_Gra:/* global */
	.WORD	#8
G037_s_Gra:/* global */
	.WORD	#8
G038_ai_Gr:/* global */
	.WORD	#76
G039_ai_Gr:/* global */
	.WORD	#32
G040_ai_Gr:/* global */
	.WORD	#12
G041_s_Gra:/* global */
	.WORD	#8
G042_auc_G:/* global */
	.WORD	#128
G043_auc_G:/* global */
	.WORD	#128
G044_auc_G:/* global */
	.WORD	#16
G045_auc_G:/* global */
	.WORD	#16
G046_auc_G:/* global */
	.WORD	#4
G047_s_Gra:/* global */
	.WORD	#4
G048_s_Gra:/* global */
	.WORD	#8
G049_s_Gra:/* global */
	.WORD	#8
G050_auc_G:/* global */
	.WORD	#6
G051_ac_Gr:/* global */
	.WORD	#2
G052_ac_Gr:/* global */
	.WORD	#2
G053_ac_Gr:/* global */
	.WORD	#6
G054_ai_Gr:/* global */
	.WORD	#32
G055_aaaui:/* global */
	.WORD	#48
G056_aaui_:/* global */
	.WORD	#24
G057_ai_Gr:/* global */
	.WORD	#60
G058_i_Gra:/* global */
	.WORD	#2
G059_auc_G:/* global */
	.WORD	#8
G060_as_Gr:/* global */
	.WORD	#176
G061_s_Gra:/* global */
	.WORD	#8
G062_s_Gra:/* global */
	.WORD	#8
G063_s_Gra:/* global */
	.WORD	#8
G064_al_Gr:/* global */
	.WORD	#16
G065_al_Gr:/* global */
	.WORD	#16
G066_ac_Gr:/* global */
	.WORD	#2
G067_i_Gra:/* global */
	.WORD	#2
CODE SEG "init!"
	MOVE	#15,G069_ui_St(A4)
BSS SEG "bss"
G069_ui_St:/* global */
	.WORD	#2
G070_B_Sec:/* global */
	.WORD	#2
G071_B_Sec:/* global */
	.WORD	#2
G072_ui_Gr:/* global */
	.WORD	#2
G074_puc_B:/* global */
	.WORD	#4
G075_apuc_:/* global */
	.WORD	#16
G076_B_Use:/* global */
	.WORD	#2
G077_B_DoN:/* global */
	.WORD	#2
CODE SEG "init!"
	MOVE	#1,G078_B_Fuz(A4)
BSS SEG "bss"
G078_B_Fuz:/* global */
	.WORD	#2
G079_ai_St:/* global */
	.WORD	#36
G080_aai_D:/* global */
	.WORD	#12
G081_ai_Fu:/* global */
	.WORD	#64
G082_ac_Co:/* global */
	.WORD	#68
CODE SEG "init!"
	LEA	G083_apc_G(A4),A1
	LEA	G081_ai_Fu(A4),A0
	MOVE.L	A0,(A1)+
	LEA	G070_B_Sec(A4),A0
	MOVE.L	A0,(A1)+
	LEA	G078_B_Fuz(A4),A0
	MOVE.L	A0,(A1)+
	LEA	G071_B_Sec(A4),A0
	MOVE.L	A0,(A1)+
BSS SEG "bss"
G083_apc_G:/* global */
	.WORD	#16
G084_puc_B:/* global */
	.WORD	#4
G085_puc_B:/* global */
	.WORD	#4
G086_puc_B:/* global */
	.WORD	#4
G087_puc_B:/* global */
	.WORD	#4
G088_apuc_:/* global */
	.WORD	#60
G089_ac_Co:/* global */
	.WORD	#68
G090_puc_B:/* global */
	.WORD	#4
G091_puc_B:/* global */
	.WORD	#4
G092_puc_B:/* global */
	.WORD	#4
G093_puc_B:/* global */
	.WORD	#4
G094_puc_B:/* global */
	.WORD	#4
G095_puc_B:/* global */
	.WORD	#4
G096_puc_B:/* global */
	.WORD	#4
G097_puc_B:/* global */
	.WORD	#4
G098_puc_B:/* global */
	.WORD	#4
G099_puc_B:/* global */
	.WORD	#4
G100_ac_Co:/* global */
	.WORD	#68
G101_aai_C:/* global */
	.WORD	#64
G102_aai_C:/* global */
	.WORD	#64
G103_aai_C:/* global */
	.WORD	#68
CODE SEG "init!"
	LEA	G104_apc_C(A4),A1
	LEA	G082_ac_Co(A4),A0
	MOVE.L	A0,(A1)+
	LEA	G089_ac_Co(A4),A0
	MOVE.L	A0,(A1)+
	LEA	G100_ac_Co(A4),A0
	MOVE.L	A0,(A1)+
BSS SEG "bss"
G104_apc_C:/* global */
	.WORD	#12
G105_s_Gra:/* global */
	.WORD	#4
G106_s_Gra:/* global */
	.WORD	#4
G107_s_Gra:/* global */
	.WORD	#4
G108_s_Gra:/* global */
	.WORD	#4
G109_s_Gra:/* global */
	.WORD	#4
G110_s_Gra:/* global */
	.WORD	#8
G111_s_Gra:/* global */
	.WORD	#8
G112_s_Gra:/* global */
	.WORD	#8
G113_s_Gra:/* global */
	.WORD	#8
G114_s_Gra:/* global */
	.WORD	#8
G115_s_Gra:/* global */
	.WORD	#8
G116_s_Gra:/* global */
	.WORD	#8
G117_s_Gra:/* global */
	.WORD	#8
G118_s_Gra:/* global */
	.WORD	#8
G119_s_Gra:/* global */
	.WORD	#8
G120_s_Gra:/* global */
	.WORD	#8
G121_s_Gra:/* global */
	.WORD	#8
G122_s_Gra:/* global */
	.WORD	#8
G123_s_Gra:/* global */
	.WORD	#8
G124_s_Gra:/* global */
	.WORD	#8
G125_s_Gra:/* global */
	.WORD	#8
G126_s_Gra:/* global */
	.WORD	#8
G127_s_Gra:/* global */
	.WORD	#8
G128_s_Gra:/* global */
	.WORD	#8
G129_s_Gra:/* global */
	.WORD	#8
G130_s_Gra:/* global */
	.WORD	#8
G131_s_Gra:/* global */
	.WORD	#8
G132_s_Gra:/* global */
	.WORD	#8
G133_s_Gra:/* global */
	.WORD	#8
G134_s_Gra:/* global */
	.WORD	#8
G135_s_Gra:/* global */
	.WORD	#8
G136_s_Gra:/* global */
	.WORD	#8
G137_s_Gra:/* global */
	.WORD	#8
G138_s_Gra:/* global */
	.WORD	#8
G139_s_Gra:/* global */
	.WORD	#8
G140_s_Gra:/* global */
	.WORD	#8
G141_s_Gra:/* global */
	.WORD	#8
G142_s_Gra:/* global */
	.WORD	#8
G143_s_Gra:/* global */
	.WORD	#8
G144_s_Gra:/* global */
	.WORD	#8
G145_s_Gra:/* global */
	.WORD	#8
G146_s_Gra:/* global */
	.WORD	#8
G147_s_Gra:/* global */
	.WORD	#8
G148_s_Gra:/* global */
	.WORD	#8
G149_s_Gra:/* global */
	.WORD	#8
G150_s_Gra:/* global */
	.WORD	#8
G151_s_Gra:/* global */
	.WORD	#8
G152_s_Gra:/* global */
	.WORD	#8
G153_s_Gra:/* global */
	.WORD	#8
G154_s_Gra:/* global */
	.WORD	#8
G155_s_Gra:/* global */
	.WORD	#8
G156_s_Gra:/* global */
	.WORD	#8
G157_s_Gra:/* global */
	.WORD	#8
G158_s_Gra:/* global */
	.WORD	#8
G159_s_Gra:/* global */
	.WORD	#8
G160_s_Gra:/* global */
	.WORD	#8
G161_s_Gra:/* global */
	.WORD	#4
G162_s_Gra:/* global */
	.WORD	#4
G163_as_Gr:/* global */
	.WORD	#112
G164_s_Gra:/* global */
	.WORD	#8
G165_s_Gra:/* global */
	.WORD	#8
G166_s_Gra:/* global */
	.WORD	#8
G167_s_Gra:/* global */
	.WORD	#8
G168_s_Gra:/* global */
	.WORD	#8
G169_s_Gra:/* global */
	.WORD	#8
G170_s_Gra:/* global */
	.WORD	#8
G171_s_Gra:/* global */
	.WORD	#8
G172_s_Gra:/* global */
	.WORD	#8
G173_s_Gra:/* global */
	.WORD	#8
G174_s_Gra:/* global */
	.WORD	#8
G175_s_Gra:/* global */
	.WORD	#8
G176_s_Gra:/* global */
	.WORD	#8
G177_s_Gra:/* global */
	.WORD	#8
G178_s_Gra:/* global */
	.WORD	#8
G179_s_Gra:/* global */
	.WORD	#80
G180_s_Gra:/* global */
	.WORD	#80
G181_s_Gra:/* global */
	.WORD	#80
G182_s_Gra:/* global */
	.WORD	#80
G183_s_Gra:/* global */
	.WORD	#80
G184_s_Gra:/* global */
	.WORD	#80
G185_s_Gra:/* global */
	.WORD	#80
G186_s_Gra:/* global */
	.WORD	#80
G187_s_Gra:/* global */
	.WORD	#80
G188_as_Gr:/* global */
	.WORD	#96
G189_i_Gra:/* global */
	.WORD	#2
G190_auc_G:/* global */
	.WORD	#12
G191_auc_G:/* global */
	.WORD	#10
G192_auc_G:/* global */
	.WORD	#4
G193_ai_Gr:/* global */
	.WORD	#2
G194_auc_G:/* global */
	.WORD	#60
G195_auc_G:/* global */
	.WORD	#10
G196_auc_G:/* global */
	.WORD	#12
G197_auc_G:/* global */
	.WORD	#2
G198_auc_G:/* global */
	.WORD	#16
G199_auc_G:/* global */
	.WORD	#16
G200_auc_G:/* global */
	.WORD	#16
G201_auc_G:/* global */
	.WORD	#16
G202_ac_Gr:/* global */
	.WORD	#4
G203_ac_Gr:/* global */
	.WORD	#4
G204_ac_Gr:/* global */
	.WORD	#16
G205_aaauc:/* global */
	.WORD	#624
G206_aaauc:/* global */
	.WORD	#162
G207_aaauc:/* global */
	.WORD	#72
G208_aaauc:/* global */
	.WORD	#24
G209_as_Gr:/* global */
	.WORD	#510
G210_as_Gr:/* global */
	.WORD	#84
G211_as_Gr:/* global */
	.WORD	#8
G212_auc_G:/* global */
	.WORD	#16
G213_auc_G:/* global */
	.WORD	#16
G214_auc_G:/* global */
	.WORD	#16
G215_auc_G:/* global */
	.WORD	#8
G216_auc_G:/* global */
	.WORD	#6
G217_aauc_:/* global */
	.WORD	#32
G218_aaaau:/* global */
	.WORD	#300
G219_as_Gr:/* global */
	.WORD	#324
G220_as_Gr:/* global */
	.WORD	#182
G221_auc_G:/* global */
	.WORD	#16
G222_auc_G:/* global */
	.WORD	#16
G223_aac_G:/* global */
	.WORD	#24
G224_aaaau:/* global */
	.WORD	#330
G225_aai_G:/* global */
	.WORD	#60
G226_aaai_:/* global */
	.WORD	#120
G227_aai_G:/* global */
	.WORD	#42
G228_aai_G:/* global */
	.WORD	#42
G229_i_Gra:/* global */
	.WORD	#2
CODE SEG "init!"
	MOVE	#-1,G230_i_Cur(A4)
BSS SEG "bss"
G230_i_Cur:/* global */
	.WORD	#2
CODE SEG "init!"
	MOVE	#-1,G231_i_Cur(A4)
BSS SEG "bss"
G231_i_Cur:/* global */
	.WORD	#2
CODE SEG "show"
F093_xxxx_:/* global */
	LINK	A6,L$0
	MOVEM.L	D7-D5,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	CLR	D5
	BRA.S	L2
L3:
	MOVE	D5,D0
	MOVE	D6,D1
	MULS	#14,D1
	LEA	G220_as_Gr(A4),A0
	ADDA	D1,A0
	ASL.L	#1,D0
	LEA	(A0),A0
	ADDA	D0,A0
	MOVE	(A0),D0
	MOVE	D7,D1
	MOVE	D5,D2
	MULS	#32,D2
	LEA	G021_aaui_(A4),A0
	ADD.L	A0,D2
	ASL.L	#1,D1
	MOVE.L	D2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L4:
	ADDQ	#1,D5
L2:
	CMPI	#6,D5
	BLT.S	L3
L5:
	MOVE	D6,D0
	MULS	#14,D0
	LEA	G220_as_Gr+12(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	LEA	G222_auc_G(A4),A0
	ADDA	D7,A0
	AND	#255,D0
	MOVE.B	D0,(A0)
	MOVE	D6,D0
	MULS	#14,D0
	LEA	G220_as_Gr+13(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	LEA	G221_auc_G(A4),A0
	ADDA	D7,A0
	AND	#255,D0
	MOVE.B	D0,(A0)
L1:
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L$0:	.EQU	#0
F094_mzzz_:/* global */
	LINK	A6,L$6
	MOVE	D7,-(A7)
	MOVE	8(A6),D7
	MOVE	G230_i_Cur(A4),D0
	CMP	D7,D0
	BEQ.S	L8
	MOVE	D7,G230_i_Cur(A4)
	MOVE	D7,D0
	MULS	#2,D0
	ADD	#75,D0
	MOVE	D0,D7
	CLR	-(A7)
	CLR	-(A7)
	MOVE.L	G084_puc_B(A4),-(A7)
	MOVE	D7,-(A7)
	JSR	F490_lzzz_(PC)
	ADDA	#10,A7
	CLR	-(A7)
	CLR	-(A7)
	MOVE.L	G085_puc_B(A4),-(A7)
	MOVE	D7,D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	JSR	F490_lzzz_(PC)
	ADDA	#10,A7
L8:
L7:
	MOVE	(A7)+,D7
	UNLK	A6
	RTS
L$6:	.EQU	#0
F095_izzz_:/* global */
	LINK	A6,L$9
	MOVEM.L	A3/D7-D6,-(A7)
	MOVE	8(A6),D7
	MOVE	G231_i_Cur(A4),D0
	CMP	D7,D0
	BNE.S	L12
	MOVE	G523_B_Res(A4),D0
	BEQ	L11(PC)
L12:
	MOVE	D7,G231_i_Cur(A4)
	MOVE	D7,D0
	MULS	#13,D0
	ADD	#77,D0
	MOVE	D0,D7
	LEA	G088_apuc_+4(A4),A0
	MOVE.L	A0,D0
	MOVE.L	D0,A3
	MOVE	D7,D0
	ADD	#13,D0
	MOVE	D0,D6
	BRA.S	L13
L14:
	CLR	-(A7)
	CLR	-(A7)
	MOVE.L	(A3)+,-(A7)
	MOVE	D7,D0
	ADDQ	#1,D7
	MOVE	D0,-(A7)
	JSR	F490_lzzz_(PC)
	ADDA	#10,A7
L13:
	MOVE	D7,D0
	CMP	D6,D0
	BLT.S	L14
L15:
	MOVE.B	G171_s_Gra+5(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G171_s_Gra+4(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G088_apuc_(A4),-(A7)
	MOVE.L	G088_apuc_+8(A4),-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.B	G163_as_Gr+101(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G163_as_Gr+100(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G088_apuc_+56(A4),-(A7)
	MOVE.L	G088_apuc_+52(A4),-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
L11:
L10:
	MOVEM.L	(A7)+,D6-D7/A3
	UNLK	A6
	RTS
L$9:	.EQU	#0
F096_qzzz_:/* global */
	LINK	A6,L$16
CODE SEG "init!"
	MOVE	#1,4G232_B_Fi(A4)
BSS SEG "bss"
4G232_B_Fi:
	.WORD	#2
CODE SEG "show"
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE	4G232_B_Fi(A4),D0
	BNE.S	L18
	MOVE	G661_B_Lar(A4),D0
	SEQ	D0
	TST.B	D0
L18:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-10(A6)
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	14(A0),D5
	AND	#15,D5
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	14(A0),D4
	AND	#240,D4
	LSR	#4,D4
	MOVE	-10(A6),D0
	BNE.S	L21
	MOVE	D5,D0
	MOVE	G230_i_Cur(A4),D1
	CMP	D1,D0
	SNE	D0
	TST.B	D0
L21:
	SNE	D0
	TST.B	D0
	BNE.S	L20
	MOVE	D4,D0
	MOVE	G231_i_Cur(A4),D1
	CMP	D1,D0
	SNE	D0
	TST.B	D0
L20:
	AND	#1,D0
	MOVE	D0,-22(A6)
	BEQ.S	L19
	CLR	-(A7)
	CLR	-(A7)
	JSR	F428_AA39_(PC)
	ADDQ.L	#4,A7
	JSR	F477_izzz_(PC)
	BRA.S	L22
L19:
L24:
L23:
	MOVE	G625_i_Flo(A4),D0
	BNE.S	L24
L25:
L22:
	MOVE	D5,-(A7)
	JSR	F094_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	D4,-(A7)
	JSR	F095_izzz_(PC)
	ADDQ.L	#2,A7
	MOVE	G661_B_Lar(A4),D0
	BEQ	L26(PC)
	CLR	-(A7)
	MOVE.L	#5112,-(A7)
	JSR	F468_ozzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,G074_puc_B(A4)
	MOVE	#1,G578_B_Use(A4)
	MOVE.B	G163_as_Gr+5(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G163_as_Gr+4(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+48(A4),D0
	MOVE.L	D0,G095_puc_B(A4)
	MOVE.L	D0,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#408,-(A7)
	MOVE	#10,-(A7)
	MOVE.L	G090_puc_B(A4),-(A7)
	JSR	F134_zzzz_(PC)
	ADDQ.L	#8,A7
	MOVE	#-1,-(A7)
	MOVE	#64,-(A7)
	MOVE	#64,-(A7)
	CLR	-(A7)
	MOVE	#11,-(A7)
	PEA	G161_s_Gra(A4)
	MOVE.L	G090_puc_B(A4),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE.B	G163_as_Gr+29(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G163_as_Gr+28(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+44(A4),D0
	MOVE.L	D0,G096_puc_B(A4)
	MOVE.L	D0,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#639,-(A7)
	MOVE	#10,-(A7)
	MOVE.L	G091_puc_B(A4),-(A7)
	JSR	F134_zzzz_(PC)
	ADDQ.L	#8,A7
	MOVE	#-1,-(A7)
	MOVE	#72,-(A7)
	MOVE	#72,-(A7)
	CLR	-(A7)
	MOVE	#8,-(A7)
	PEA	G162_s_Gra(A4)
	MOVE.L	G091_puc_B(A4),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE.L	#5112,-(A7)
	JSR	F469_rzzz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	G163_as_Gr+53(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G163_as_Gr+52(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G092_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+40(A4),D0
	MOVE.L	D0,G097_puc_B(A4)
	MOVE.L	D0,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.B	G163_as_Gr+85(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G163_as_Gr+84(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G094_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+36(A4),D0
	MOVE.L	D0,G098_puc_B(A4)
	MOVE.L	D0,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.B	G163_as_Gr+85(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G163_as_Gr+84(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G093_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+32(A4),D0
	MOVE.L	D0,G099_puc_B(A4)
	MOVE.L	D0,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
L26:
	CLR	-(A7)
	MOVE.L	#1100,-(A7)
	JSR	F468_ozzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,A2
	MOVE	#140,-(A7)
	MOVE.L	A2,-(A7)
	PEA	G018_ai_Gr(A4)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	#70,D4
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	12(A0),D0
	AND	#240,D0
	LSR	#4,D0
	BEQ.S	L28
	MOVE	G661_B_Lar(A4),D0
	BEQ.S	L27
L28:
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	#40,(A0)
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	#26,(A0)
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	#27,(A0)
L27:
	LEA	G079_ai_St+34(A4),A0
	MOVE.L	A0,-4(A6)
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	14(A0),D6
	AND	#240,D6
	LSR	#4,D6
	MULU	#18,D6
	ADD	#90,D6
	MOVE	D6,D7
	ADD	#18,D7
	BRA.S	L29
L30:
	MOVE	G661_B_Lar(A4),D0
	BNE.S	L32
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	D6,(A0)
L32:
	MOVE	D6,D0
	ADDQ	#1,D6
	MOVE.L	-4(A6),A0
	SUBQ.L	#2,-4(A6)
	MOVE	D0,(A0)
L29:
	MOVE	D6,D0
	CMP	D7,D0
	BLT.S	L30
L31:
	MOVE	#556,D7
	MOVE	G661_B_Lar(A4),D0
	BNE.S	L33
	SUBQ	#6,D7
L33:
	MOVE	#533,D6
	BRA.S	L34
L35:
	MOVE	D6,D0
	ADDQ	#1,D6
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L34:
	MOVE	D6,D0
	CMP	D7,D0
	BLT.S	L35
L36:
	CLR	D6
	BRA.S	L37
L38:
	MOVE	#360,D5
	MOVE	D6,D1
	MULS	#6,D1
	LEA	G209_as_Gr(A4),A0
	ADDA	D1,A0
	MOVE.B	(A0),D3
	AND	#255,D3
	ADD	D3,D5
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	D5,(A0)
	MOVE	D6,D0
	MULS	#6,D0
	LEA	G209_as_Gr+4(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	AND	#16,D0
	BEQ.S	L41
	MOVE	D5,D0
	ADDQ	#1,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L41:
L39:
	ADDQ	#1,D6
L37:
	CMPI	#85,D6
	BLT.S	L38
L40:
	CLR	D6
	BRA.S	L42
L43:
	MOVE	#316,D5
	MOVE	D6,D1
	MULS	#6,D1
	LEA	G210_as_Gr(A4),A0
	ADDA	D1,A0
	MOVE.B	(A0),D3
	AND	#255,D3
	ADD	D3,D5
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	D5,(A0)
	MOVE	D6,D0
	MULS	#6,D0
	LEA	G210_as_Gr+4(A4),A0
	ADDA	D0,A0
	MOVE	(A0),D0
	AND	#3,D0
	MOVE	D0,D7
	CMPI	#3,D0
	BEQ.S	L46
	MOVE	D5,D0
	ADDQ	#1,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
	CMPI	#2,D7
	BEQ.S	L47
	MOVE	D5,D0
	ADDQ	#2,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L47:
L46:
L44:
	ADDQ	#1,D6
L42:
	CMPI	#14,D6
	BLT.S	L43
L45:
	MOVE	#348,D6
	BRA.S	L48
L49:
	MOVE	D6,D0
	ADDQ	#1,D6
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L48:
	CMPI	#360,D6
	BLT.S	L49
L50:
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	14(A0),D0
	AND	#3840,D0
	LSR	#8,D0
	MOVE.B	D0,-6(A6)
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	14(A0),D0
	AND	#-4096,D0
	LSR	#4,D0
	LSR	#8,D0
	MOVE.B	D0,-5(A6)
	CLR	D5
	BRA.S	L51
L52:
	MOVE	D5,D0
	ASL.L	#1,D0
	LEA	G080_aai_D+8(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-4(A6)
	MOVE	#108,D6
	MOVE	D5,D1
	LEA	-6(A6),A0
	ADDA	D1,A0
	MOVE.B	(A0),D1
	AND	#255,D1
	MULS	#3,D1
	ADD	D1,D6
	MOVE	D6,D7
	ADDQ	#3,D7
	BRA.S	L55
L56:
	MOVE	G661_B_Lar(A4),D0
	BNE.S	L58
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	D6,(A0)
L58:
	MOVE	D6,D0
	ADDQ	#1,D6
	MOVE.L	-4(A6),A0
	MOVE	D0,(A0)
	SUBQ.L	#4,-4(A6)
L55:
	MOVE	D6,D0
	CMP	D7,D0
	BLT.S	L56
L57:
L53:
	ADDQ	#1,D5
L51:
	CMPI	#1,D5
	BLS.S	L52
L54:
	MOVE	#2,-(A7)
	MOVE	#-1,-(A7)
	MOVE	#3,-(A7)
	PEA	G267_ai_Cu(A4)
	JSR	F010_aAA7_(PC)
	ADDA	#10,A7
	MOVE	#2,-(A7)
	MOVE	#-1,-(A7)
	MOVE	#1,-(A7)
	PEA	G268_ai_Cu(A4)
	JSR	F010_aAA7_(PC)
	ADDA	#10,A7
	CLR	-18(A6)
	CLR	-20(A6)
	MOVE	#-1,G266_i_Cur(A4)
	CLR	D5
	BRA	L59(PC)
L60:
	MOVE	#121,D6
	MOVE	D5,D1
	LEA	G261_auc_C(A4),A0
	ADDA	D1,A0
	MOVE.B	(A0),D1
	AND	#255,D1
	MOVE	D1,D7
	MULS	#2,D1
	ADD	D1,D6
	MOVE	D5,D0
	ASL.L	#2,D0
	LEA	G101_aai_C(A4),A0
	ADDA	D0,A0
	MOVE	D6,(A0)
	CLR	-16(A6)
	BRA.S	L63
L64:
	MOVE	D7,D0
	LEA	G192_auc_G(A4),A0
	ADDA	-16(A6),A0
	MOVE.B	(A0),D1
	AND	#255,D1
	CMP	D1,D0
	BNE.S	L67
	MOVE	-18(A6),D0
	ADDQ	#1,-18(A6)
	ASL.L	#1,D0
	LEA	G267_ai_Cu(A4),A0
	ADDA	D0,A0
	MOVE	D5,(A0)
	CMPI	#2,D7
	BNE.S	L68
	MOVE	D5,G266_i_Cur(A4)
L68:
L67:
L65:
	ADDQ	#1,-16(A6)
L63:
	CMPI	#3,-16(A6)
	BLT.S	L64
L66:
	CLR	-16(A6)
	BRA.S	L69
L70:
	MOVE	D7,D0
	MOVE	-16(A6),D1
	ASL.L	#1,D1
	LEA	G193_ai_Gr(A4),A0
	ADDA	D1,A0
	CMP	(A0),D0
	BNE.S	L73
	MOVE	-20(A6),D0
	ADDQ	#1,-20(A6)
	ASL.L	#1,D0
	LEA	G268_ai_Cu(A4),A0
	ADDA	D0,A0
	MOVE	D5,(A0)
L73:
L71:
	ADDQ	#1,-16(A6)
L69:
	CMPI	#1,-16(A6)
	BLT.S	L70
L72:
	LEA	G194_auc_G(A4),A0
	ADDA	D7,A0
	MOVE.B	(A0),D0
	MOVE	D5,D1
	ASL.L	#2,D1
	LEA	G101_aai_C+2(A4),A0
	ADDA	D1,A0
	AND	#255,D0
	MOVE	D0,(A0)
	MULS	#78,D0
	LEA	G205_aaauc(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A3
	MOVE	G661_B_Lar(A4),D0
	BNE.S	L74
	MOVE	D6,D0
	ADDQ	#1,D6
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
	MOVE	D6,D0
	ADDQ	#1,D6
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L74:
	MOVE	#4,D7
	MOVE	D5,D1
	MULU	#4,D1
	ADD	D1,D7
	MOVE	D7,D6
	ADDQ	#4,D7
	BRA.S	L75
L76:
	MOVE	D6,D0
	OR	#-32768,D0
	MOVE	D0,-(A7)
	JSR	F480_AA07_(PC)
	ADDQ.L	#2,A7
	MOVE.B	4(A3),D0
	MOVE.B	5(A3),D1
	AND	#255,D1
	AND	#255,D0
	MULS	D1,D0
	MOVE	D6,D1
	ADDQ	#1,D6
	ASL.L	#1,D1
	MOVE.L	G639_pi_De(A4),A0
	ADDA	D1,A0
	MOVE	D0,(A0)
	MOVE	D7,D0
	SUB	D6,D0
	CMPI	#2,D0
	BNE.S	L78
	MOVE	#18,D0
	BRA.S	L79
L78:
	MOVE	#12,D0
L79:
	EXT.L	D0
	ADDA.L	D0,A3
L75:
	MOVE	D6,D0
	CMP	D7,D0
	BLT.S	L76
L77:
L61:
	ADDQ	#1,D5
L59:
	MOVE	D5,D0
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	10(A0),D1
	AND	#15,D1
	CMP	D1,D0
	BLS	L60(PC)
L62:
	CLR	D5
	BRA.S	L80
L81:
	MOVE	#247,D6
	MOVE	D5,D1
	LEA	G262_auc_C(A4),A0
	ADDA	D1,A0
	MOVE.B	(A0),D1
	AND	#255,D1
	MOVE	D1,D7
	MULS	#6,D1
	ADD	D1,D6
	MOVE	D5,D0
	ASL.L	#2,D0
	LEA	G102_aai_C(A4),A0
	ADDA	D0,A0
	MOVE	D6,(A0)
	LEA	G195_auc_G(A4),A0
	ADDA	D7,A0
	MOVE.B	(A0),D0
	MOVE	D5,D1
	ASL.L	#2,D1
	LEA	G102_aai_C+2(A4),A0
	ADDA	D1,A0
	AND	#255,D0
	MOVE	D0,(A0)
	MOVE	G661_B_Lar(A4),D0
	BNE.S	L84
	MOVE	D6,D7
	ADDQ	#6,D7
	BRA.S	L85
L86:
	MOVE	D6,D0
	ADDQ	#1,D6
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L85:
	MOVE	D6,D0
	CMP	D7,D0
	BLT.S	L86
L87:
L84:
L82:
	ADDQ	#1,D5
L80:
	MOVE	D5,D0
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	10(A0),D1
	AND	#3840,D1
	LSR	#8,D1
	CMP	D1,D0
	BCS.S	L81
L83:
	CLR	D5
	BRA	L88(PC)
L89:
	MOVE	#303,D6
	MOVE	D5,D1
	LEA	G263_auc_C(A4),A0
	ADDA	D1,A0
	MOVE.B	(A0),D1
	AND	#255,D1
	MOVE	D1,D7
	ADD	D1,D6
	MOVE	D5,D0
	ASL.L	#2,D0
	LEA	G103_aai_C(A4),A0
	ADDA	D0,A0
	MOVE	D6,(A0)
	MOVE	G661_B_Lar(A4),D0
	BNE.S	L92
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	D6,(A0)
L92:
	LEA	G196_auc_G(A4),A0
	ADDA	D7,A0
	MOVE.B	(A0),D0
	MOVE	D5,D1
	ASL.L	#2,D1
	LEA	G103_aai_C+2(A4),A0
	ADDA	D1,A0
	AND	#255,D0
	MOVE	D0,(A0)
	MULS	#18,D0
	LEA	G207_aaauc(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A3
	MOVE	#68,D7
	MOVE	D5,D1
	MULU	#2,D1
	ADD	D1,D7
	MOVE	D7,D6
	ADDQ	#2,D7
	BRA.S	L93
L94:
	MOVE	D6,D0
	OR	#-32768,D0
	MOVE	D0,-(A7)
	JSR	F480_AA07_(PC)
	ADDQ.L	#2,A7
	MOVE.B	4(A3),D0
	MOVE.B	5(A3),D1
	AND	#255,D1
	AND	#255,D0
	MULS	D1,D0
	MOVE	D6,D1
	ADDQ	#1,D6
	ASL.L	#1,D1
	MOVE.L	G639_pi_De(A4),A0
	ADDA	D1,A0
	MOVE	D0,(A0)
	ADDQ.L	#6,A3
L93:
	MOVE	D6,D0
	CMP	D7,D0
	BLT.S	L94
L95:
L90:
	ADDQ	#1,D5
L88:
	MOVE	D5,D0
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	12(A0),D1
	AND	#15,D1
	CMP	D1,D0
	BCS	L89(PC)
L91:
	MOVE	#102,D0
	MOVE	D0,D7
	MOVE	#0,D0
	MOVE	D0,D6
	BRA.S	L96
L97:
	MOVE	D6,D0
	ADD	#315,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
	LEA	G197_auc_G(A4),A0
	ADDA	D6,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MULS	#24,D0
	LEA	G208_aaauc+6(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A3
	MOVE.B	4(A3),D0
	MOVE.B	5(A3),D1
	AND	#255,D1
	AND	#255,D0
	MULS	D1,D0
	MOVE	D7,D1
	ADDQ	#1,D7
	ASL.L	#1,D1
	MOVE.L	G639_pi_De(A4),A0
	ADDA	D1,A0
	MOVE	D0,(A0)
	ADDQ.L	#6,A3
	MOVE.B	4(A3),D0
	MOVE.B	5(A3),D1
	AND	#255,D1
	AND	#255,D0
	MULS	D1,D0
	MOVE	D7,D1
	ADDQ	#1,D7
	ASL.L	#1,D1
	MOVE.L	G639_pi_De(A4),A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L98:
	ADDQ	#1,D6
L96:
	CMPI	#1,D6
	BLT.S	L97
L99:
	MOVE	#8,-(A7)
	MOVE	#9,-(A7)
	JSR	F093_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#12,-(A7)
	MOVE	#10,-(A7)
	JSR	F093_xxxx_(PC)
	ADDQ.L	#4,A7
	CLR	-8(A6)
	BRA	L100(PC)
L101:
	MOVE.L	G264_puc_C(A4),A0
	ADDA	-8(A6),A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE	D0,D7
	MULS	#12,D0
	LEA	G219_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,D0
	MOVE.L	D0,A3
	MOVE.L	A3,D5
	MOVE.L	D5,A0
	MOVE.B	11(A0),D5
	AND	#255,D5
	AND	#15,D5
	BEQ.S	L104
	MOVE	D5,D0
	SUBQ	#1,D0
	MOVE	D0,-(A7)
	MOVE	#9,-(A7)
	JSR	F093_xxxx_(PC)
	ADDQ.L	#4,A7
L104:
	MOVE.L	A3,D5
	MOVE.L	D5,A0
	MOVE.B	11(A0),D5
	AND	#255,D5
	ASR	#4,D5
	AND	#15,D5
	BEQ.S	L105
	MOVE	D5,D0
	SUBQ	#1,D0
	MOVE	D0,-(A7)
	MOVE	#10,-(A7)
	JSR	F093_xxxx_(PC)
	ADDQ.L	#4,A7
L105:
	MOVE	G661_B_Lar(A4),D0
	BNE	L106(PC)
	MOVE	D7,D0
	MULS	#26,D0
	LEA	G243_as_Gr+1(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE	D0,D5
	BEQ.S	L107
	CMPI	#6,D5
	BHI.S	L107
	MOVE	D5,D0
	ADD	#549,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L107:
	MOVE	#446,D6
	MOVE.L	A3,D1
	MOVE.L	D1,A0
	ADD	(A0),D6
	MOVE	D4,D0
	ADDQ	#1,D4
	ASL.L	#1,D0
	MOVE.L	A2,A0
	ADDA	D0,A0
	MOVE	D6,(A0)
	MOVE	D7,D5
	MULS	#26,D5
	LEA	G243_as_Gr+4(A4),A0
	ADDA	D5,A0
	MOVE	(A0),D5
	MOVE	D5,D0
	AND	#8,D0
	BEQ.S	L108
	ADDQ	#1,D6
	MOVE	D6,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L108:
	MOVE	D5,D0
	AND	#16,D0
	BEQ.S	L109
	ADDQ	#1,D6
	MOVE	D6,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L109:
	MOVE	D5,D0
	AND	#128,D0
	BEQ.S	L110
	MOVE	D5,D0
	AND	#256,D0
	BNE.S	L110
	ADDQ	#1,D6
	MOVE	D6,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L110:
	MOVE	D5,D0
	AND	#32,D0
	BEQ.S	L111
	ADDQ	#1,D6
	MOVE	D6,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L111:
	MOVE	D5,D0
	AND	#3,D0
	MOVE	D0,-14(A6)
	BEQ.S	L112
L113:
	MOVE	D5,D0
	AND	#4,D0
	BNE.S	L116
	ADDQ	#1,D6
	MOVE	D6,D0
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L116:
L114:
	SUBQ	#1,-14(A6)
	BNE.S	L113
L115:
L112:
L106:
L102:
	ADDQ	#1,-8(A6)
L100:
	MOVE	-8(A6),D0
	MOVE.L	G269_ps_Cu(A4),A0
	MOVE	12(A0),D1
	AND	#240,D1
	LSR	#4,D1
	CMP	D1,D0
	BCS	L101(PC)
L103:
	MOVE	-10(A6),D0
	BEQ	L117(PC)
	MOVE	G661_B_Lar(A4),D0
	BEQ	L118(PC)
	MOVE	#90,D5
	BRA.S	L119
L120:
	MOVE	D5,D0
	ADDQ	#1,D5
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L119:
	CMPI	#108,D5
	BCS.S	L120
L121:
	MOVE	#108,D5
	BRA.S	L122
L123:
	MOVE	D5,D0
	ADDQ	#1,D5
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L122:
	CMPI	#120,D5
	BCS.S	L123
L124:
	MOVE	#121,D5
	BRA.S	L125
L126:
	MOVE	D5,D0
	ADDQ	#1,D5
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L125:
	CMPI	#247,D5
	BCS.S	L126
L127:
	MOVE	#247,D5
	BRA.S	L128
L129:
	MOVE	D5,D0
	ADDQ	#1,D5
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L128:
	CMPI	#301,D5
	BCS.S	L129
L130:
	MOVE	#303,D5
	BRA.S	L131
L132:
	MOVE	D5,D0
	ADDQ	#1,D5
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L131:
	CMPI	#316,D5
	BCS.S	L132
L133:
	MOVE	#446,D5
	BRA.S	L134
L135:
	MOVE	D5,D0
	ADDQ	#1,D5
	MOVE	D4,D1
	ADDQ	#1,D4
	ASL.L	#1,D1
	MOVE.L	A2,A0
	ADDA	D1,A0
	MOVE	D0,(A0)
L134:
	CMPI	#533,D5
	BCS.S	L135
L136:
L118:
	MOVE	D4,-(A7)
	MOVE.L	A2,-(A7)
	JSR	F484_gzzz_(PC)
	ADDQ.L	#6,A7
L117:
	MOVE	-22(A6),D0
	BEQ.S	L137
	JSR	F478_gzzz_(PC)
L137:
	MOVE.L	#1100,-(A7)
	JSR	F469_rzzz_(PC)
	ADDQ.L	#4,A7
	MOVE	#1,G297_B_Dra(A4)
	MOVE	#1,G342_B_Ref(A4)
	CLR	4G232_B_Fi(A4)
L17:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$16:	.EQU	#-22
F097_lzzz_:/* global */
	LINK	A6,L$138
	CMPI	#2,8(A6)
	BNE.S	L140
	MOVE	G322_B_Pal(A4),G323_B_Ena(A4)
	BRA.S	L141
L140:
	MOVE	8(A6),G323_B_Ena(A4)
L141:
	MOVE	#1,G324_B_Dra(A4)
	MOVE	#37,-(A7)
	JSR	R056_aaal_(PC)
	ADDQ.L	#2,A7
L139:
	UNLK	A6
	RTS
L$138:	.EQU	#0
F098_rzzz_:/* global */
	LINK	A6,L$142
	MOVE	#4144,-(A7)
	MOVE.L	G086_puc_B(A4),-(A7)
	JSR	F008_aA19_(PC)
	ADDQ.L	#6,A7
	MOVE	#3248,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G085_puc_B(A4),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	#7840,-(A7)
	MOVE.L	G087_puc_B(A4),-(A7)
	MOVE.L	G084_puc_B(A4),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	CLR	G297_B_Dra(A4)
L143:
	UNLK	A6
	RTS
L$142:	.EQU	#0
F099_xxxx_:/* global */
	LINK	A6,L$144
	MOVE	16(A6),D0
	MULU	18(A6),D0
	MOVE	D0,-(A7)
	MOVE.L	12(A6),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	18(A6),-(A7)
	MOVE	16(A6),-(A7)
	MOVE.L	12(A6),-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L145:
	UNLK	A6
	RTS
L$144:	.EQU	#0
F100_xxxx_:/* global */
	LINK	A6,L$146
	MOVE.L	A3,-(A7)
	MOVE.L	12(A6),A3
	MOVE.B	4(A3),D0
	BEQ.S	L148
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	7(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	6(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L148:
L147:
	MOVE.L	(A7)+,A3
	UNLK	A6
	RTS
L$146:	.EQU	#0
F102_xxxx_:/* global */
	LINK	A6,L$149
	MOVE.L	A3,-(A7)
	MOVE.L	8(A6),A3
	MOVE.B	4(A3),D0
	BEQ.S	L151
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	7(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	6(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L151:
L150:
	MOVE.L	(A7)+,A3
	UNLK	A6
	RTS
L$149:	.EQU	#0
F103_xxxx_:/* global */
	LINK	A6,L$152
	MOVE.L	A3,-(A7)
	MOVE.L	12(A6),A3
	MOVE.B	4(A3),D0
	BEQ.S	L154
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	7(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	6(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	8(A6),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L154:
L153:
	MOVE.L	(A7)+,A3
	UNLK	A6
	RTS
L$152:	.EQU	#0
F104_xxxx_:/* global */
	LINK	A6,L$155
	MOVE.L	A3,-(A7)
	MOVE.L	10(A6),A3
	MOVE.B	4(A3),D0
	BEQ.S	L157
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	7(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	6(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE	8(A6),-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L157:
L156:
	MOVE.L	(A7)+,A3
	UNLK	A6
	RTS
L$155:	.EQU	#0
F105_xxxx_:/* global */
	LINK	A6,L$158
	MOVE.L	A3,-(A7)
	MOVE.L	10(A6),A3
	MOVE.B	4(A3),D0
	BEQ.S	L160
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE	8(A6),-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	7(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	6(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L160:
L159:
	MOVE.L	(A7)+,A3
	UNLK	A6
	RTS
L$158:	.EQU	#0
F106_rzzz_:/* global */
	LINK	A6,L$161
	CMPI	#5,G072_ui_Gr(A4)
	BCC.S	L163
	MOVE	G078_B_Fuz(A4),D0
	BNE.S	L163
	MOVE	G625_i_Flo(A4),D0
	BNE.S	L164
	MOVE	G315_i_Sec(A4),D0
	AND	#1,D0
	BNE.S	L164
	ORI	#1,G315_i_Sec(A4)
	ADDQ	#1,G072_ui_Gr(A4)
L164:
	ANDI	#-2,G316_i_Sec(A4)
	MOVE	#15,G069_ui_St(A4)
	MOVE	#1,G078_B_Fuz(A4)
L163:
L162:
	UNLK	A6
	RTS
L$161:	.EQU	#0
F107_xxxx_:/* global */
	LINK	A6,L$165
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	D7,D0
	BEQ	L167(PC)
	SUBQ	#1,D7
	MOVE	D7,D5
	ASL.L	#2,D5
	LEA	G101_aai_C(A4),A0
	ADDA	D5,A0
	MOVE	(A0),D5
	MOVE	D6,D0
	MOVE	D7,D1
	ASL.L	#2,D1
	LEA	G101_aai_C+2(A4),A0
	ADDA	D1,A0
	MOVE	(A0),D1
	MOVE	D1,D4
	MULS	#78,D1
	LEA	G205_aaauc(A4),A0
	ADD.L	A0,D1
	MULS	#6,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A3
	MOVE	D7,-(A7)
	JSR	F149_aawz_(PC)
	ADDQ.L	#2,A7
	MOVE	D0,-12(A6)
	MOVE	D7,D0
	CMP	G265_i_Cur(A4),D0
	SEQ	D0
	AND	#1,D0
	MOVE	D0,-10(A6)
	BEQ.S	L168
	CLR	-(A7)
	MOVE	G290_T_Dun(A4),-(A7)
	PEA	-92(A6)
	JSR	F168_ajzz_(PC)
	ADDQ.L	#8,A7
L168:
	CLR	-(A7)
	JSR	F106_rzzz_(PC)
	ADDQ.L	#2,A7
	CMPI	#10,D6
	BLT	L169(PC)
	CMPI	#12,D6
	BNE	L170(PC)
	MOVE	-10(A6),D0
	BEQ	L171(PC)
	MOVE	#-1,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	G163_as_Gr+52(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE	#28,-(A7)
	MOVE	#94,-(A7)
	PEA	G202_ac_Gr(A4)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+40(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	LEA	-92(A6),A0
	MOVE.L	A0,A3
	MOVE	#120,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-4(A6)
	CLR	-14(A6)
L172:
	CLR	D7
	MOVE.L	A3,A2
	BRA.S	L175
L176:
	ADDQ	#1,D7
L175:
	MOVE.B	(A2)+,D0
	AND	#255,D0
	CMP	#128,D0
	BLT.S	L176
L177:
	MOVE	#112,D0
	MOVE	D7,D1
	ASL	#2,D1
	SUB	D1,D0
	MOVE.B	D0,-22(A6)
	AND	#255,D0
	ADDQ	#7,D0
	MOVE.B	D0,-21(A6)
	MOVE	-14(A6),D0
	ADDQ	#1,-14(A6)
	LEA	G203_ac_Gr(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE.B	D0,-19(A6)
	AND	#255,D0
	SUBQ	#7,D0
	MOVE.B	D0,-20(A6)
	BRA.S	L178
L179:
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE	#144,-(A7)
	CLR	-(A7)
	MOVE.B	(A3)+,D0
	AND	#255,D0
	ASL	#3,D0
	MOVE	D0,-(A7)
	PEA	-22(A6)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	ADDQ.B	#8,-22(A6)
	ADDQ.B	#8,-21(A6)
L178:
	MOVE	D7,D0
	SUBQ	#1,D7
	TST	D0
	BNE.S	L179
L180:
L173:
	MOVE.B	(A3)+,D0
	AND	#255,D0
	CMP	#129,D0
	BNE	L172(PC)
L174:
	BRA	L14T107_031(PC)
L171:
	ADDQ	#1,D5
	MOVE	#4,-(A7)
	PEA	G291_aauc_+20(A4)
	MOVE.L	A3,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	-12(A6),G286_B_Fac(A4)
	MOVE	G078_B_Fuz(A4),D0
	BEQ.S	L181
	MOVE	D7,D0
	CMP	G266_i_Cur(A4),D0
	SEQ	D0
	TST.B	D0
L181:
	SNE	D0
	AND	#1,D0
	MOVE	D0,G287_B_Fac(A4)
	CLR	G288_B_Fac(A4)
	CLR	D4
	BRA.S	L182
L183:
	MOVE	D4,D0
	ASL.L	#1,D0
	LEA	G268_ai_Cu(A4),A0
	ADDA	D0,A0
	MOVE	(A0),D0
	CMP	D7,D0
	BNE.S	L186
	MOVE	#1,G288_B_Fac(A4)
	BRA.S	L185
L186:
L184:
	ADDQ	#1,D4
L182:
	CMPI	#1,D4
	BLT.S	L183
L185:
L170:
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A2
	CMPI	#11,D6
	BNE.S	L187
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A2,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.L	G074_puc_B(A4),A2
L187:
	CLR	D4
	BRA	L188(PC)
L169:
	CLR	-6(A6)
	CMPI	#6,D6
	SEQ	D0
	TST.B	D0
	BNE.S	L190
	CMPI	#1,D6
	SEQ	D0
	TST.B	D0
L190:
	AND	#1,D0
	MOVE	D0,-8(A6)
	BEQ.S	L189
	MOVE	D4,D0
	MULS	#78,D0
	LEA	G205_aaauc+66(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	BRA.S	L191
L189:
	CMPI	#5,D6
	BEQ.S	L193
	CMPI	#0,D6
	BNE.S	L192
L193:
	MOVE	D4,D0
	MULS	#78,D0
	LEA	G205_aaauc+60(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	BRA.S	L194
L192:
	ADDQ	#1,D5
	MOVE	D4,D0
	MULS	#78,D0
	LEA	G205_aaauc+72(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	CMPI	#7,D6
	BNE.S	L195
	MOVE	#6,-6(A6)
	BRA.S	L196
L195:
	CMPI	#9,D6
	BNE.S	L197
	MOVE	#-6,-6(A6)
L197:
L196:
L194:
L191:
	MOVE.L	A3,D4
	MOVE	-6(A6),D3
	EXT.L	D3
	ADD.L	D3,D4
	MOVE.L	D4,A0
	MOVE.B	1(A0),D4
	MOVE.L	A3,D1
	MOVE	-6(A6),D3
	EXT.L	D3
	ADD.L	D3,D1
	MOVE.L	D1,A0
	AND	#255,D4
	MOVE.B	(A0),D3
	AND	#255,D3
	SUB	D3,D4
	MOVE	#4,D0
	MOVE	D7,D1
	ASL	#2,D1
	ADD	D1,D0
	LEA	G190_auc_G(A4),A0
	ADDA	D6,A0
	MOVE.B	(A0),D3
	AND	#255,D3
	ADD	D3,D0
	MOVE	D0,D7
	MOVE	D0,-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BNE.S	L198
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-4(A6)
	CMPI	#4,D6
	BGT.S	L199
	LEA	G198_auc_G(A4),A0
	MOVE.L	A0,D0
	BRA.S	L200
L199:
	LEA	G199_auc_G(A4),A0
	MOVE.L	A0,D0
L200:
	MOVE.L	D0,-(A7)
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE	D4,D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	MOVE.B	5(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A2),D0
	AND	#255,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE	D7,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE	D7,-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L198:
	MOVE	D7,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A2
	MOVE	-8(A6),D0
	BEQ.S	L201
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A2,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.L	G074_puc_B(A4),A2
	MOVE	#15,D0
	MOVE	D4,D1
	AND	#15,D1
	SUB	D1,D0
	MOVE	D0,D4
	BRA.S	L202
L201:
	CMPI	#7,D6
	BNE.S	L203
	MOVE.B	1(A3),D0
	AND	#255,D0
	MOVE.B	(A3),D3
	AND	#255,D3
	SUB	D3,D0
	SUB	D0,D4
	BRA.S	L204
L203:
	CLR	D4
L204:
L202:
L188:
	MOVE	-10(A6),D0
	BEQ.S	L205
	MOVE.L	A3,-4(A6)
	LEA	-92(A6),A0
	MOVE.L	A0,A3
	CLR	D5
L206:
	BRA.S	L209
L210:
	ADDQ.L	#1,A3
L209:
	MOVE.B	(A3),D0
	AND	#255,D0
	CMP	#128,D0
	BLT.S	L210
L211:
	ADDQ	#1,D5
L207:
	MOVE.B	(A3)+,D0
	AND	#255,D0
	CMP	#129,D0
	BNE.S	L206
L208:
	MOVE.L	-4(A6),A3
	CMPI	#4,D5
	BGE.S	L212
	MOVE	#8,-(A7)
	PEA	-22(A6)
	MOVE.L	A3,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	LEA	-22(A6),A0
	MOVE.L	A0,A3
	LEA	G190_auc_G(A4),A0
	ADDA	D6,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MULS	#3,D0
	ADD	D5,D0
	LEA	G204_ac_Gr+-1(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),3(A3)
L212:
L205:
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	MOVE	D4,-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A2,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	CMPI	#12,D6
	BNE.S	L213
	MOVE	G289_i_Dun(A4),D0
	SUBQ	#1,G289_i_Dun(A4)
	TST	D0
	BEQ.S	L213
	MOVE	#1,-(A7)
	MOVE	#112,-(A7)
	MOVE	#128,-(A7)
	MOVE	G289_i_Dun(A4),D0
	ASR	#3,D0
	MULS	#29,D0
	MOVE	D0,-(A7)
	MOVE	G289_i_Dun(A4),D0
	AND	#7,D0
	ASL	#5,D0
	MOVE	D0,-(A7)
	PEA	G109_s_Gra(A4)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE	#26,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L213:
L14T107_031:
	MOVE	-12(A6),D0
	BRA.S	L166
L167:
	MOVE	#0,D0
L166:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$165:	.EQU	#-92
F108_xxxx_:/* global */
	LINK	A6,L$214
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	D7,D0
	BEQ	L216(PC)
	MOVE	D7,D4
	AND	#-32768,D4
	BEQ.S	L217
	MOVE	D7,D0
	AND	#32767,D0
	MOVE	D0,D7
	BNE.S	L218
	BRA	L15T108_005(PC)
L218:
L217:
	SUBQ	#1,D7
	MOVE	D7,D5
	ASL.L	#2,D5
	LEA	G102_aai_C(A4),A0
	ADDA	D5,A0
	MOVE	(A0),D5
	MOVE	D6,D1
	LEA	G191_auc_G(A4),A0
	ADDA	D1,A0
	MOVE.B	(A0),D3
	AND	#255,D3
	ADD	D3,D5
	MOVE	D6,D0
	MOVE	D7,D1
	ASL.L	#2,D1
	LEA	G102_aai_C+2(A4),A0
	ADDA	D1,A0
	MOVE	(A0),D1
	MULS	#54,D1
	LEA	G206_aaauc(A4),A0
	ADD.L	A0,D1
	MULS	#6,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	CMPI	#8,D6
	BEQ.S	L220
	CMPI	#5,D6
	BEQ.S	L220
	CMPI	#2,D6
	BEQ.S	L220
	CMPI	#15,D7
	BNE.S	L219
	MOVE	G076_B_Use(A4),D0
	BEQ.S	L219
	CMPI	#7,D6
	BEQ.S	L221
	CMPI	#4,D6
	BEQ.S	L221
	CMPI	#1,D6
	BNE.S	L219
L221:
L220:
	MOVE.B	5(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),D0
	MOVE.L	D0,A3
	MOVE.L	D0,-(A7)
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	BRA.S	L222
L219:
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
L222:
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE.L	A2,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L15T108_005:
	MOVE	D4,D0
	BEQ.S	L223
	MOVE	D6,-(A7)
	MOVE	#16,-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
L223:
L216:
L215:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$214:	.EQU	#0
F109_xxxx_:/* global */
	LINK	A6,L$224
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	D7,D0
	BEQ	L226(PC)
	SUBQ	#1,D7
	MOVE	D7,D5
	ASL.L	#2,D5
	LEA	G103_aai_C(A4),A0
	ADDA	D5,A0
	MOVE	(A0),D5
	MOVE	D6,D0
	MOVE	D7,D1
	ASL.L	#2,D1
	LEA	G103_aai_C+2(A4),A0
	ADDA	D1,A0
	MOVE	(A0),D1
	MOVE	D1,D4
	MULS	#18,D1
	LEA	G207_aaauc(A4),A0
	ADD.L	A0,D1
	MULS	#6,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A3
	CMPI	#2,D6
	BNE.S	L227
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A2
	MOVE	#48,D6
	BRA	L228(PC)
L227:
	MOVE	#68,D0
	MOVE	D7,D1
	MULS	#2,D1
	ADD	D1,D0
	ADD	D6,D0
	MOVE	D0,D7
	MOVE	D0,-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BNE	L229(PC)
	MOVE	D4,D0
	MULS	#18,D0
	LEA	G207_aaauc+12(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-4(A6)
	CMPI	#0,D6
	BNE.S	L230
	LEA	G200_auc_G(A4),A0
	MOVE.L	A0,D0
	BRA.S	L231
L230:
	LEA	G201_auc_G(A4),A0
	MOVE.L	A0,D0
L231:
	MOVE.L	D0,-(A7)
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	1(A3),D0
	AND	#255,D0
	MOVE.B	(A3),D3
	AND	#255,D3
	SUB	D3,D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	MOVE.B	5(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A2),D0
	AND	#255,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE	D7,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE	D7,-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L229:
	MOVE	D7,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A2
	CMPI	#0,D6
	BNE.S	L232
	MOVE	#24,D6
	BRA.S	L233
L232:
	MOVE	#32,D6
L233:
L228:
	MOVE	#9,-(A7)
	MOVE	D6,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A2,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L226:
L225:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$224:	.EQU	#-4
F110_xxxx_:/* global */
	LINK	A6,L$234
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	D7,D0
	BEQ	L236(PC)
	SUBQ	#1,D7
	MOVE	D7,D5
	ADD	#315,D5
	MOVE	D6,D0
	LEA	G197_auc_G(A4),A0
	ADDA	D7,A0
	MOVE.B	(A0),D1
	AND	#255,D1
	MOVE	D1,D4
	MULS	#24,D1
	LEA	G208_aaauc(A4),A0
	ADD.L	A0,D1
	MULS	#6,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A3
	CMPI	#3,D6
	BNE.S	L237
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A2
	MOVE	#4,-(A7)
	PEA	G291_aauc_+20(A4)
	MOVE.L	A3,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	BRA	L238(PC)
L237:
	MOVE	#102,D0
	MOVE	D7,D1
	MULS	#2,D1
	ADD	D1,D0
	MOVE	D6,D1
	BNE.S	L240
	MOVE	#0,D1
	BRA.S	L241
L240:
	MOVE	D6,D1
	SUBQ	#1,D1
L241:
	ADD	D1,D0
	MOVE	D0,D7
	MOVE	D0,-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BNE	L239(PC)
	MOVE	D4,D0
	MULS	#24,D0
	LEA	G208_aaauc+18(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	MOVE	D5,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-4(A6)
	CMPI	#2,D6
	BNE.S	L242
	LEA	G199_auc_G(A4),A0
	MOVE.L	A0,D0
	BRA.S	L243
L242:
	LEA	G198_auc_G(A4),A0
	MOVE.L	A0,D0
L243:
	MOVE.L	D0,-(A7)
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	1(A3),D0
	AND	#255,D0
	MOVE.B	(A3),D3
	AND	#255,D3
	SUB	D3,D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	MOVE.B	5(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A2),D0
	AND	#255,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE	D7,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE	D7,-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L239:
	MOVE	D7,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A2
L238:
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A2,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L236:
L235:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$234:	.EQU	#-4
F111_xxxx_:/* global */
	LINK	A6,L$244
	MOVEM.L	A3-A2/D7-D6,-(A7)
	MOVE	10(A6),D7
	MOVE.L	20(A6),A3
	CMPI	#0,D7
	BEQ	L246(PC)
	MOVE.L	G284_apuc_(A4),D0
	MOVE	8(A6),D1
	AND.L	#65535,D1
	ASL.L	#2,D1
	ADD.L	D1,D0
	MOVE.L	D0,A2
	MOVE	16(A6),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE	2(A2),D0
	AND	#1,D0
	MOVE	D0,D6
	ASL.L	#1,D0
	MOVE.L	12(A6),A0
	ADDA	D0,A0
	MOVE	(A0),-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	18(A6),-(A7)
	MOVE	2(A2),D0
	AND	#30,D0
	LSR	#1,D0
	MOVE	D0,-(A7)
	JSR	F109_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	D6,D0
	ASL.L	#1,D0
	LEA	G275_as_Cu(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	AND	#4,D0
	BEQ.S	L247
	JSR	F028_a000_(PC)
	TST	D0
	BEQ.S	L248
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L248:
	JSR	F028_a000_(PC)
	TST	D0
	BEQ.S	L249
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F131_xxxx_(PC)
	ADDQ.L	#8,A7
L249:
L247:
	MOVE.L	A3,D0
	LEA	G186_s_Gra(A4),A0
	CMP.L	A0,D0
	BNE.S	L250
	MOVE.B	G407_s_Par+3202(A4),D0
	BEQ.S	L250
	MOVE	#2,-(A7)
	MOVE	#17,-(A7)
	JSR	F109_xxxx_(PC)
	ADDQ.L	#4,A7
L250:
	CMPI	#4,D7
	BNE.S	L251
	LEA	(A3),A0
	MOVE.L	A0,-(A7)
	JSR	F102_xxxx_(PC)
	ADDQ.L	#4,A7
	BRA.S	L245
L251:
	CMPI	#5,D7
	BNE.S	L252
	MOVE	18(A6),-(A7)
	MOVE	#16,-(A7)
	JSR	F109_xxxx_(PC)
	ADDQ.L	#4,A7
	LEA	(A3),A0
	MOVE.L	A0,-(A7)
	JSR	F102_xxxx_(PC)
	ADDQ.L	#4,A7
	BRA.S	L245
L252:
	SUBQ	#1,D7
	MOVE	2(A2),D0
	AND	#32,D0
	LSR	#5,D0
	BEQ.S	L253
	MOVE	D7,D0
	ASL.L	#3,D0
	LEA	8(A3),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-(A7)
	JSR	F102_xxxx_(PC)
	ADDQ.L	#4,A7
	BRA.S	L254
L253:
	MOVE	D7,D0
	ASL.L	#3,D0
	LEA	32(A3),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-(A7)
	JSR	F102_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	D7,D0
	ASL.L	#3,D0
	LEA	56(A3),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-(A7)
	JSR	F102_xxxx_(PC)
	ADDQ.L	#4,A7
L254:
L246:
L245:
	MOVEM.L	(A7)+,D6-D7/A2-A3
	UNLK	A6
	RTS
L$244:	.EQU	#0
F112_xxxx_:/* global */
	LINK	A6,L$255
	MOVE	D7,-(A7)
	PEA	16(A6)
	PEA	14(A6)
	MOVE	#-1,-(A7)
	MOVE	G272_i_Cur(A4),-(A7)
	JSR	F154_afzz_(PC)
	ADDA	#12,A7
	MOVE	D0,D7
	CMPI	#0,D0
	BLT.S	L257
	MOVE	14(A6),D0
	MOVE	D7,D1
	ASL.L	#2,D1
	MOVE.L	G279_pppuc(A4),A0
	ADDA	D1,A0
	ASL.L	#2,D0
	MOVE.L	(A0),A0
	ADDA	D0,A0
	MOVE.L	(A0),A0
	ADDA	16(A6),A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE	D0,D7
	ASR	#5,D0
	CMPI	#2,D0
	BNE.S	L257
	MOVE	D7,D0
	AND	#8,D0
	BEQ.S	L257
	MOVE	18(A6),D0
	BEQ.S	L258
	MOVE.L	10(A6),-(A7)
	MOVE	8(A6),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L259
L258:
	MOVE.L	10(A6),-(A7)
	MOVE	8(A6),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L259:
L257:
L256:
	MOVE	(A7)+,D7
	UNLK	A6
	RTS
L$255:	.EQU	#0
F113_xxxx_:/* global */
	LINK	A6,L$260
	MOVEM.L	A3-A2,-(A7)
	MOVE.L	8(A6),A3
	MOVE.B	3(A3),D0
	AND	#255,D0
	CMP	#255,D0
	BNE.S	L262
	MOVE.L	#0,A2
	BRA.S	L263
L262:
	MOVE.B	4(A3),D0
	MOVE.B	5(A3),D1
	AND	#255,D1
	AND	#255,D0
	MULS	D1,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),D0
	MOVE.L	D0,A2
	MOVE.L	D0,-(A7)
	MOVE	#69,D0
	MOVE.B	3(A3),D1
	AND	#255,D1
	AND	#127,D1
	ADD	D1,D0
	MOVE	D0,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE.B	3(A3),D0
	AND	#255,D0
	AND	#128,D0
	BEQ.S	L264
	MOVE.B	5(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	4(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A2,-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L264:
L263:
	CLR	-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	#73,D0
	MOVE.B	(A3),D3
	AND	#255,D3
	ADD	D3,D0
	MOVE	D0,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-4(A6)
	CLR	-(A7)
	MOVE.B	6(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	2(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE	#112,-(A7)
	JSR	F027_AA59_(PC)
	AND	#31,D0
	MOVE	D0,-(A7)
	JSR	F028_a000_(PC)
	MOVE.B	1(A3),D3
	AND	#255,D3
	ADD	D3,D0
	MOVE	D0,-(A7)
	MOVE.L	12(A6),-(A7)
	CLR	-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	MOVE.L	A2,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	F133_xxxx_(PC)
	ADDA	#32,A7
	CLR	-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	#-32768,-(A7)
	JSR	F480_AA07_(PC)
	ADDQ.L	#2,A7
L261:
	MOVEM.L	(A7)+,A2-A3
	UNLK	A6
	RTS
L$260:	.EQU	#-4
F114_xxxx_:/* global */
	LINK	A6,L$265
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	D7,D0
	ASL.L	#1,D0
	LEA	G211_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	CMPI	#32,10(A6)
	BLS.S	L267
	MOVE	#32,10(A6)
L267:
	MOVE.B	(A2),D6
	AND	#255,D6
	MULU	10(A6),D6
	MOVE	10(A6),D1
	LSR	#1,D1
	ADD	D1,D6
	LSR	#5,D6
	MOVE.B	1(A2),D5
	AND	#255,D5
	MULU	10(A6),D5
	MOVE	10(A6),D1
	LSR	#1,D1
	ADD	D1,D5
	LSR	#5,D5
	CMPI	#32,10(A6)
	BNE.S	L268
	CMPI	#3,D7
	BEQ.S	L268
	MOVE	D7,D0
	ADD	#348,D0
	MOVE	D0,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA	L269(PC)
L268:
	MOVE	D7,D0
	MULU	#14,D0
	MOVE	10(A6),D1
	LSR	#1,D1
	ADD	D1,D0
	ADD	#436,D0
	MOVE	D0,D4
	MOVE	D0,-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BEQ.S	L270
	MOVE	D4,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA.S	L271
L270:
	MOVE	#2,-(A7)
	MOVE	D7,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	ADD	#348,D0
	MOVE	D0,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-4(A6)
	CMPI	#3,D7
	BNE.S	L272
	LEA	G212_auc_G(A4),A0
	MOVE.L	A0,D0
	BRA.S	L273
L272:
	LEA	G017_auc_G(A4),A0
	MOVE.L	A0,D0
L273:
	MOVE.L	D0,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE.B	1(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	(A2),D0
	AND	#255,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE	D4,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE.L	D0,-(A7)
	MOVE.L	-4(A6),-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE	D4,-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L271:
L269:
	MOVE.L	12(A6),A0
	MOVE	D6,(A0)
	MOVE.L	16(A6),A0
	MOVE	D5,(A0)
	MOVE.L	A3,D0
L266:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$265:	.EQU	#-4
F115_xxxx_:/* global */
	LINK	A6,L$274
	MOVEM.L	A3-A2/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	16(A6),D6
	CMPI	#-2,D7
	BNE.S	L276
	BRA	L275(PC)
L276:
	CLR.L	-58(A6)
	MOVE	#-1,-54(A6)
	MOVE	#0,D0
	MOVE	D0,-158(A6)
	MOVE	D0,-134(A6)
	MOVE	D0,-108(A6)
	CLR	-48(A6)
	MOVE	D7,-44(A6)
	MOVE	18(A6),D0
	AND	#8,D0
	BEQ.S	L277
	MOVE	18(A6),D0
	AND	#1,D0
	ADDQ	#1,D0
	MOVE	D0,-110(A6)
	MOVE	18(A6),D0
	LSR	#4,D0
	MOVE	D0,18(A6)
	BRA.S	L278
L277:
	CLR	-110(A6)
L278:
	MOVE	18(A6),D0
	AND.L	#65535,D0
	MOVE.L	D0,-4(A6)
	SEQ	D0
	AND	#1,D0
	MOVE	D0,-20(A6)
	MOVE	D6,-46(A6)
	MOVE	D6,D0
	ADDQ	#3,D0
	EXT.L	D0
	DIVS	#3,D0
	SWAP	D0
	MOVE	D0,-26(A6)
	MOVE	G069_ui_St(A4),D0
	AND	#254,D0
	CMPI	#10,D0
	SEQ	D0
	TST.B	D0
	BEQ.S	L279
	MOVE	G070_B_Sec(A4),D0
L279:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-172(A6)
L280:
	MOVE	-20(A6),D0
	BEQ.S	L283
	MOVE	#4,D5
	MOVE	10(A6),D0
	ADDQ	#2,D0
	AND	#3,D0
	MOVE	D0,-28(A6)
	MOVE	#2,-50(A6)
	BRA.S	L284
L283:
	MOVE.L	-4(A6),D5
	AND	#15,D5
	SUBQ	#1,D5
	MOVE	D5,-136(A6)
	MOVE.L	-4(A6),D0
	LSR.L	#4,D0
	MOVE.L	D0,-4(A6)
	ADDQ	#1,-48(A6)
	MOVE	D5,D0
	ADD	10(A6),D0
	AND	#3,D0
	MOVE	D0,-28(A6)
	MOVE	-44(A6),D7
	MOVE	-46(A6),D6
	CLR	-50(A6)
L284:
	MOVE	-28(A6),D0
	AND	#1,D0
	ASL	#3,D0
	ADD	D0,-50(A6)
	CLR	-132(A6)
L285:
	MOVE	D7,D0
	AND	#15360,D0
	LSR	#2,D0
	LSR	#8,D0
	MOVE	D0,D4
	CMPI	#4,D0
	BNE.S	L288
	MOVE	D7,-54(A6)
	BRA	L286(PC)
L288:
	CMPI	#14,D4
	BNE.S	L289
	MOVE	#1,-134(A6)
	BRA	L286(PC)
L289:
	CMPI	#15,D4
	BNE.S	L290
	MOVE	#1,-158(A6)
	BRA	L286(PC)
L290:
	CMPI	#0,D6
	BLT	L291(PC)
	CMPI	#9,D6
	BGT	L291(PC)
	MOVE	D7,D0
	LSR	#6,D0
	LSR	#8,D0
	MOVE	-28(A6),D1
	CMP	D1,D0
	BNE	L291(PC)
	MOVE	D7,-(A7)
	JSR	F141_anzz_(PC)
	ADDQ.L	#2,A7
	MULS	#6,D0
	LEA	G237_as_Gr+2(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MULS	#6,D0
	LEA	G209_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	MOVE	#360,D4
	MOVE.B	(A2),D3
	AND	#255,D3
	ADD	D3,D4
	MOVE	-20(A6),D0
	BEQ.S	L294
	MOVE.B	4(A2),D0
	AND	#255,D0
	AND	#16,D0
L294:
	SNE	D0
	TST.B	D0
	BEQ.S	L293
	MOVE	-26(A6),D0
	SEQ	D0
	TST.B	D0
L293:
	AND	#1,D0
	MOVE	D0,-34(A6)
	BEQ.S	L292
	ADDQ	#1,D4
L292:
	MOVE	D6,D1
	MOVE.B	5(A2),D0
	AND	#255,D0
	MULS	#100,D0
	LEA	G218_aaaau(A4),A0
	ADD.L	A0,D0
	MULS	#10,D1
	ADD.L	D0,D1
	MOVE	D5,D0
	ASL.L	#1,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-16(A6)
	MOVE.L	-16(A6),A0
	MOVE.B	1(A0),D0
	BNE.S	L295
	BRA	L286(PC)
L295:
L22T115_015:
	MOVE.B	4(A2),D0
	AND	#255,D0
	AND	#1,D0
	BEQ.S	L297
	MOVE	-34(A6),D0
	SEQ	D0
	TST.B	D0
L297:
	SNE	D0
	TST.B	D0
	BEQ.S	L296
	CMPI	#2,-26(A6)
	SEQ	D0
	TST.B	D0
	BNE.S	L298
	MOVE	-26(A6),D0
	SEQ	D0
	TST.B	D0
	BEQ.S	L299
	CMPI	#1,D5
	SEQ	D0
	TST.B	D0
	BNE.S	L300
	CMPI	#2,D5
	SEQ	D0
	TST.B	D0
L300:
	TST.B	D0
L299:
	TST.B	D0
L298:
	TST.B	D0
L296:
	AND	#1,D0
	MOVE	D0,-36(A6)
	CLR	-30(A6)
	CMPI	#9,D6
	BEQ.S	L302
	CMPI	#6,D6
	BLT.S	L301
	CMPI	#2,D5
	BLT.S	L301
L302:
	MOVE	-26(A6),D0
	SEQ	D0
	TST.B	D0
	BEQ.S	L303
	MOVE	-132(A6),D0
	SEQ	D0
	TST.B	D0
L303:
	AND	#1,D0
	MOVE	D0,-38(A6)
	CLR	-52(A6)
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE.B	2(A2),D0
	AND	#255,D0
	MOVE	D0,-22(A6)
	MOVE.B	3(A2),D0
	AND	#255,D0
	MOVE	D0,-24(A6)
	MOVE	-36(A6),D0
	BEQ.S	L304
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.L	G074_puc_B(A4),A3
L304:
	BRA	L305(PC)
L301:
	CLR	-38(A6)
	MOVE	#104,D0
	MOVE.B	1(A2),D3
	AND	#255,D3
	ADD	D3,D0
	MOVE	D0,-18(A6)
	CMPI	#6,D6
	BGE.S	L307
	CMPI	#3,D6
	BLT.S	L306
	CMPI	#2,D5
	BLT.S	L306
L307:
	ADDQ	#1,-18(A6)
	MOVE	#1,-52(A6)
	MOVE.B	2(A2),D0
	AND	#255,D0
	MULS	#20,D0
	ADD	#10,D0
	ASR	#5,D0
	MOVE	D0,-22(A6)
	MOVE.B	3(A2),D0
	AND	#255,D0
	MULS	#20,D0
	ADD	#10,D0
	ASR	#5,D0
	MOVE	D0,-24(A6)
	LEA	G214_auc_G(A4),A0
	MOVE.L	A0,-8(A6)
	BRA.S	L308
L306:
	MOVE	#2,-52(A6)
	MOVE.B	2(A2),D0
	AND	#255,D0
	MULS	#16,D0
	ADDQ	#8,D0
	ASR	#5,D0
	MOVE	D0,-22(A6)
	MOVE.B	3(A2),D0
	AND	#255,D0
	MULS	#16,D0
	ADDQ	#8,D0
	ASR	#5,D0
	MOVE	D0,-24(A6)
	LEA	G213_auc_G(A4),A0
	MOVE.L	A0,-8(A6)
L308:
	MOVE	-36(A6),D0
	BEQ.S	L309
	ADDQ	#2,-18(A6)
	MOVE	#7,D0
	MOVE	-22(A6),D1
	SUBQ	#1,D1
	AND	#7,D1
	SUB	D1,D0
	ASL	#1,D0
	MOVE	D0,-30(A6)
	BRA.S	L310
L309:
	MOVE	-34(A6),D0
	BEQ.S	L311
	ADDQ	#4,-18(A6)
L311:
L310:
	MOVE	-18(A6),-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BEQ.S	L312
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA.S	L313
L312:
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-12(A6)
	MOVE.L	-8(A6),-(A7)
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE.B	3(A2),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	2(A2),D0
	AND	#255,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE.L	D0,-(A7)
	MOVE.L	-12(A6),-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE	-36(A6),D0
	BEQ.S	L314
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),D0
	ADDQ	#7,D0
	AND	#-8,D0
	MOVE	D0,-(A7)
	MOVE.L	A3,-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L314:
	MOVE	-18(A6),-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L313:
L305:
	MOVE.L	-16(A6),A0
	MOVE.B	(A0),D4
	AND	#255,D4
	MOVE.L	-16(A6),A0
	MOVE.B	1(A0),-39(A6)
	MOVE	-132(A6),D0
	BNE.S	L315
	MOVE	-50(A6),D0
	ASL.L	#1,D0
	LEA	G217_aauc_(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	MOVE	-52(A6),D1
	AND.L	#65535,D1
	ASL.L	#3,D1
	LEA	G223_aac_G(A4),A0
	ADD.L	A0,D1
	AND	#255,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	EXT	D0
	ADD	D0,D4
	MOVE	-50(A6),D0
	ASL.L	#1,D0
	LEA	G217_aauc_+1(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	MOVE	-52(A6),D1
	AND.L	#65535,D1
	ASL.L	#3,D1
	LEA	G223_aac_G(A4),A0
	ADD.L	A0,D1
	AND	#255,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	ADD.B	D0,-39(A6)
	ADDQ	#1,-50(A6)
	MOVE	-20(A6),D0
	BEQ.S	L316
	CMPI	#14,-50(A6)
	BCS.S	L317
	MOVE	#2,-50(A6)
L317:
	BRA.S	L318
L316:
	ANDI	#15,-50(A6)
L318:
L315:
	MOVE.B	-39(A6),D0
	MOVE	-24(A6),D1
	SUBQ	#1,D1
	AND	#255,D0
	SUB	D1,D0
	MOVE.B	D0,-40(A6)
	MOVE.B	-39(A6),D0
	AND	#255,D0
	CMP	#135,D0
	BLE.S	L319
	MOVE.B	#-121,-39(A6)
L319:
	MOVE	D4,D0
	ADD	-22(A6),D0
	MOVE	D0,-(A7)
	MOVE	#223,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,-41(A6)
	MOVE	D4,D0
	SUB	-22(A6),D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,-42(A6)
	BEQ.S	L320
	MOVE	-36(A6),D0
	BEQ.S	L321
	MOVE	-30(A6),D4
	BRA.S	L322
L321:
	CLR	D4
L322:
	BRA.S	L323
L320:
	MOVE	-22(A6),D0
	SUB	D4,D0
	SUBQ	#1,D0
	MOVE	D0,D4
L323:
	MOVE	-38(A6),D0
	BEQ	L324(PC)
	MOVE.L	A3,-12(A6)
	MOVE	D5,D0
	ASL.L	#2,D0
	LEA	G291_aauc_(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A3
	MOVE.B	(A3),D0
	AND	#255,D0
	CMP	#255,D0
	BNE.S	L325
	MOVE	#4,-(A7)
	MOVE.L	A3,-(A7)
	PEA	-42(A6)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE.B	3(A3),D0
	AND	#255,D0
	MOVE.B	2(A3),D3
	AND	#255,D3
	SUB	D3,D0
	MOVE	D0,-32(A6)
	CMPI	#14,D0
	BGE.S	L326
	MOVE	-32(A6),D0
	ASR	#1,D0
	MOVE	D0,-32(A6)
	MOVE	-32(A6),D0
	SUBQ	#7,D0
	ADD.B	D0,2(A3)
	CMPI	#4,-32(A6)
	BGE.S	L327
	MOVE	-32(A6),D0
	SUBQ	#3,D0
	SUB.B	D0,3(A3)
L327:
L326:
	BRA.S	L328
L325:
	MOVE.B	-42(A6),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,(A3)
	MOVE.B	-41(A6),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	1(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,1(A3)
	MOVE.B	-40(A6),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	2(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,2(A3)
	MOVE.B	-39(A6),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	3(A3),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,3(A3)
L328:
	MOVE.L	-12(A6),A3
	MOVE	D5,D0
	ASL.L	#1,D0
	LEA	G292_aT_Pi(A4),A0
	ADDA	D0,A0
	MOVE	D7,(A0)
L324:
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE	-22(A6),D0
	ADDQ	#7,D0
	AND	#-8,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	MOVE	D4,-(A7)
	PEA	-42(A6)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE	-132(A6),D0
	BEQ.S	L329
	BRA	L22T115_171(PC)
L329:
L291:
L286:
	MOVE	D7,-(A7)
	JSR	F159_rzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	D0,D7
	CMPI	#-2,D0
	BNE	L285(PC)
L287:
	CMPI	#4,D5
	BNE.S	L330
	BRA	L282(PC)
L330:
	CMPI	#0,D6
	BGE.S	L331
	BRA	L282(PC)
L331:
	CMPI	#1,D5
	SLE	D0
	TST.B	D0
	BNE.S	L333
	CMPI	#1,-48(A6)
	SEQ	D0
	TST.B	D0
L333:
	TST.B	D0
	BEQ.S	L332
	MOVE.L	-4(A6),D0
	SEQ	D0
	TST.B	D0
	BNE.S	L334
	MOVE.L	-4(A6),D0
	AND.L	#15,D0
	CMPI.L	#3,D0
	SCC	D0
	TST.B	D0
L334:
	TST.B	D0
L332:
	AND	#1,D0
	MOVE	D0,-96(A6)
	CMPI	#-1,-54(A6)
	BEQ.S	L336
	MOVE	-108(A6),D0
	BEQ.S	L335
L336:
	BRA	L22T115_129(PC)
L335:
	CMPI.L	#0,-58(A6)
	BNE	L337(PC)
	MOVE	-54(A6),D0
	AND	#1023,D0
	MOVE.L	G284_apuc_+16(A4),D1
	MULS	#16,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-58(A6)
	MOVE.L	-58(A6),A0
	MOVE.B	5(A0),D0
	AND	#255,D0
	MULS	#16,D0
	MOVE.L	G375_ps_Ac(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-62(A6)
	MOVE.L	-58(A6),A0
	MOVE.B	4(A0),D0
	AND	#255,D0
	MULS	#26,D0
	LEA	G243_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-66(A6)
	MOVE.L	-66(A6),A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MULS	#12,D0
	LEA	G219_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-70(A6)
	MOVE.L	-66(A6),A0
	MOVE	2(A0),D0
	AND	#3,D0
	MOVE	D0,-72(A6)
	MOVE.L	-66(A6),A0
	MOVE	4(A0),-76(A6)
L337:
	MOVE.L	-70(A6),D0
	MOVE.L	D0,A2
	MOVE	-28(A6),-(A7)
	MOVE.L	-58(A6),-(A7)
	JSR	F176_avzz_(PC)
	ADDQ.L	#6,A7
	MOVE	D0,D7
	BEQ.S	L338
	SUBQ	#1,D7
	MOVE	D7,D0
	MOVE	D0,-82(A6)
	BRA.S	L339
L338:
	CMPI	#1,-72(A6)
	BNE.S	L340
	CLR	D7
	MOVE	#-1,-82(A6)
	BRA.S	L341
L340:
	BRA	L22T115_129(PC)
L341:
L339:
	MOVE.L	-62(A6),A0
	MOVE.B	2(A0),D0
	MOVE	D7,D1
	ASL	#1,D1
	AND	#255,D0
	ASR	D1,D0
	AND	#3,D0
	MOVE	D0,-182(A6)
	MOVE	10(A6),D0
	SUB	-182(A6),D0
	AND	#3,D0
	MOVE	D0,-74(A6)
	CLR	-94(A6)
	MOVE.L	-62(A6),A0
	MOVE.B	3(A0),D0
	AND	#255,D0
	MOVE	D0,D4
	CMPI	#255,D0
	BNE.S	L342
	MOVE.L	-4(A6),D0
	BNE.S	L344
	CMPI	#1,-110(A6)
	BNE.S	L343
L344:
	BRA	L22T115_129(PC)
L343:
	MOVE	#1,-108(A6)
	CMPI	#1,-72(A6)
	BNE.S	L345
	MOVE	-74(A6),D0
	AND	#1,D0
	BEQ.S	L345
	MOVE	#3,D5
	BRA.S	L346
L345:
	MOVE	#4,D5
L346:
	BRA	L347(PC)
L342:
	CMPI	#1,-72(A6)
	BNE	L348(PC)
	MOVE	-96(A6),D0
	BNE.S	L349
	MOVE.L	-4(A6),D0
	BEQ.S	L349
	CMPI	#0,-82(A6)
	BGE	L348(PC)
L349:
	MOVE	-96(A6),D0
	BEQ.S	L350
	CMPI	#2,-110(A6)
	BEQ.S	L350
	CMPI	#0,-82(A6)
	BLT.S	L351
	MOVE	-74(A6),D0
	AND	#1,D0
	BEQ.S	L351
	MOVE	#2,D5
	BRA.S	L352
L351:
	BRA	L22T115_129(PC)
L352:
	BRA	L353(PC)
L350:
	CMPI	#1,-110(A6)
	BEQ.S	L354
	MOVE.L	-4(A6),D0
	BNE.S	L354
	MOVE	-74(A6),D0
	AND	#1,D0
	BEQ.S	L355
	CMPI	#0,-82(A6)
	BLT.S	L356
	MOVE	#4,D5
	BRA.S	L357
L356:
	BRA	L22T115_129(PC)
L357:
	BRA.S	L358
L355:
	MOVE	#1,-108(A6)
	CMPI	#0,-82(A6)
	BGE.S	L359
	CLR	-82(A6)
L359:
	MOVE.L	-58(A6),A0
	MOVE	14(A0),D0
	AND	#96,D0
	LSR	#5,D0
	MOVE	D0,-94(A6)
	MOVE	D4,D0
	MOVE	D7,D1
	ASL	#1,D1
	ASR	D1,D0
	AND	#3,D0
	MOVE	D0,D4
	CMP	10(A6),D0
	BEQ.S	L361
	MOVE	D4,D0
	MOVE	10(A6),D1
	SUBQ	#1,D1
	AND	#3,D1
	CMP	D1,D0
	BNE.S	L360
L361:
	CLR	D5
	BRA.S	L362
L360:
	MOVE	#1,D5
L362:
L358:
	BRA.S	L363
L354:
	BRA	L22T115_129(PC)
L363:
L353:
	BRA.S	L364
L348:
	CMPI	#0,-72(A6)
	BEQ.S	L365
	BRA	L22T115_129(PC)
L365:
L364:
L347:
	MOVE.L	-62(A6),A0
	LEA	12(A0),A0
	ADDA	-82(A6),A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE	D0,-78(A6)
	CMPI	#9,D6
	BLE.S	L366
	SUBQ	#1,D6
L366:
L22T115_077:
	MOVE	D6,D1
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	10(A0),D0
	AND	#255,D0
	ASR	#4,D0
	AND	#15,D0
	MULS	#110,D0
	LEA	G224_aaaau(A4),A0
	ADD.L	A0,D0
	MULS	#10,D1
	ADD.L	D0,D1
	MOVE	D5,D0
	ASL.L	#1,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-16(A6)
	MOVE.L	-16(A6),A0
	MOVE.B	1(A0),D0
	BNE.S	L367
	BRA	L22T115_126(PC)
L367:
	MOVE	-76(A6),D7
	MOVE	#446,D4
	MOVE.L	A2,D1
	MOVE.L	D1,A0
	ADD	(A0),D4
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE	2(A0),-18(A6)
	MOVE	D7,D0
	AND	#8,D0
	BEQ.S	L369
	MOVE	-74(A6),D0
	AND	#1,D0
L369:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-98(A6)
	BEQ.S	L368
	MOVE	#0,D0
	MOVE	D0,-100(A6)
	MOVE	D0,-106(A6)
	MOVE	D0,-104(A6)
	ADDQ	#1,D4
	ADDQ	#2,-18(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	6(A0),D0
	AND	#255,D0
	MOVE	D0,-22(A6)
	MOVE	D0,-86(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	7(A0),D0
	AND	#255,D0
	MOVE	D0,-24(A6)
	MOVE	D0,-88(A6)
	BRA	L370(PC)
L368:
	MOVE	D7,D0
	AND	#16,D0
	BEQ.S	L371
	CMPI	#0,-74(A6)
	SEQ	D0
	TST.B	D0
L371:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-100(A6)
	MOVE	-100(A6),D0
	SEQ	D0
	TST.B	D0
	BEQ.S	L374
	MOVE	-78(A6),D0
	AND	#128,D0
L374:
	SNE	D0
	TST.B	D0
	BEQ.S	L373
	MOVE	D7,D0
	AND	#32,D0
L373:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-104(A6)
	BEQ.S	L372
	CLR	-106(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	8(A0),D0
	AND	#255,D0
	MOVE	D0,-22(A6)
	MOVE	D0,-86(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	9(A0),D0
	AND	#255,D0
	MOVE	D0,-24(A6)
	MOVE	D0,-88(A6)
	ADDQ	#1,D4
	ADDQ	#2,-18(A6)
	MOVE	D7,D0
	AND	#8,D0
	BEQ.S	L375
	ADDQ	#1,D4
	ADDQ	#2,-18(A6)
L375:
	MOVE	D7,D0
	AND	#16,D0
	BEQ.S	L376
	ADDQ	#1,D4
	ADDQ	#2,-18(A6)
L376:
	BRA	L377(PC)
L372:
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	4(A0),D0
	AND	#255,D0
	MOVE	D0,-22(A6)
	MOVE	D0,-86(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	5(A0),D0
	AND	#255,D0
	MOVE	D0,-24(A6)
	MOVE	D0,-88(A6)
	MOVE	-100(A6),D0
	BEQ.S	L378
	CLR	-106(A6)
	MOVE	D7,D0
	AND	#8,D0
	BEQ.S	L379
	ADDQ	#2,D4
	ADDQ	#4,-18(A6)
	BRA.S	L380
L379:
	ADDQ	#1,D4
	ADDQ	#2,-18(A6)
L380:
	BRA.S	L381
L378:
	MOVE	D7,D0
	AND	#4,D0
	BEQ.S	L383
	MOVE	-78(A6),D0
	AND	#64,D0
L383:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-106(A6)
	BEQ.S	L382
	ADDQ	#2,-18(A6)
	MOVE	D7,D0
	AND	#8,D0
	BEQ.S	L384
	ADDQ	#2,-18(A6)
L384:
	MOVE	D7,D0
	AND	#16,D0
	BEQ.S	L385
	ADDQ	#2,-18(A6)
L385:
	MOVE	D7,D0
	AND	#32,D0
	BEQ.S	L386
	ADDQ	#2,-18(A6)
L386:
L382:
L381:
L377:
L370:
	CMPI	#6,D6
	BLT	L387(PC)
	CLR	-90(A6)
	CLR	-52(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	10(A0),D0
	AND	#255,D0
	AND	#15,D0
	MOVE	D0,-84(A6)
	MOVE	-98(A6),D0
	BEQ.S	L388
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	CMPI	#1,-74(A6)
	BNE.S	L389
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.L	G074_puc_B(A4),A3
L389:
	BRA	L390(PC)
L388:
	MOVE	-100(A6),D0
	BNE.S	L392
	MOVE	-106(A6),D0
	BNE.S	L391
L392:
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE	-104(A6),D0
	BEQ.S	L393
	MOVE	-78(A6),D0
	AND	#64,D0
	BEQ.S	L393
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
	MOVE.L	G074_puc_B(A4),A3
L393:
	BRA.S	L394
L391:
	MOVE	-18(A6),-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BEQ.S	L395
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA.S	L396
L395:
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-12(A6)
	MOVE	D7,D0
	AND	#4,D0
	BEQ.S	L397
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),-(A7)
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE.L	D0,-(A7)
	MOVE.L	-12(A6),-(A7)
	JSR	F099_xxxx_(PC)
	ADDA	#12,A7
L397:
	MOVE	-18(A6),-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L396:
L394:
L390:
	BRA	L398(PC)
L387:
	MOVE	-106(A6),D0
	BEQ.S	L399
	ADDQ	#1,-18(A6)
L399:
	CMPI	#3,D6
	BLT.S	L400
	ADDQ	#1,-18(A6)
	MOVE	#1,-52(A6)
	MOVE	D7,D0
	AND	#128,D0
	BEQ.S	L403
	MOVE	-98(A6),D0
	SEQ	D0
	TST.B	D0
L403:
	SNE	D0
	TST.B	D0
	BEQ.S	L402
	MOVE	-100(A6),D0
	SEQ	D0
	TST.B	D0
L402:
	TST.B	D0
	BEQ.S	L401
	MOVE	-104(A6),D0
	SEQ	D0
	TST.B	D0
L401:
	AND	#1,D0
	MOVE	D0,-102(A6)
	LEA	G222_auc_G(A4),A0
	MOVE.L	A0,-8(A6)
	MOVE	#20,-112(A6)
	BRA.S	L404
L400:
	MOVE	#2,-52(A6)
	CLR	-102(A6)
	LEA	G221_auc_G(A4),A0
	MOVE.L	A0,-8(A6)
	MOVE	#16,-112(A6)
L404:
	MOVE	-86(A6),D0
	MULS	-112(A6),D0
	MOVE	-112(A6),D1
	ASR	#1,D1
	ADD	D1,D0
	ASR	#5,D0
	MOVE	D0,-22(A6)
	MOVE	-88(A6),D0
	MULS	-112(A6),D0
	MOVE	-112(A6),D1
	ASR	#1,D1
	ADD	D1,D0
	ASR	#5,D0
	MOVE	D0,-24(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	10(A0),D0
	AND	#255,D0
	AND	#15,D0
	MOVE.L	-8(A6),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	EXT.L	D0
	DIVS	#10,D0
	MOVE	D0,-84(A6)
	MOVE	-18(A6),-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	D0,-114(A6)
	BEQ.S	L405
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA.S	L406
L405:
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-12(A6)
	MOVE.L	-8(A6),-(A7)
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE	-88(A6),-(A7)
	MOVE	-86(A6),D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE.L	D0,-(A7)
	MOVE.L	-12(A6),-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE	-18(A6),-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L406:
	MOVE	-98(A6),D0
	BEQ.S	L409
	CMPI	#1,-74(A6)
	BEQ.S	L408
L409:
	MOVE	-104(A6),D0
	BEQ.S	L410
	MOVE	-78(A6),D0
	AND	#64,D0
	BNE.S	L408
L410:
	MOVE	-102(A6),D0
	BEQ.S	L411
	MOVE	D7,D0
	AND	#256,D0
	BNE.S	L408
L411:
	MOVE	-106(A6),D0
	BEQ.S	L407
	MOVE	D7,D0
	AND	#4,D0
	BEQ.S	L407
L408:
	MOVE	-106(A6),D0
	BEQ.S	L413
	MOVE	-114(A6),D0
	BNE.S	L412
L413:
	MOVE	-22(A6),D4
	ADDQ	#7,D4
	AND	#-8,D4
	MOVE	-106(A6),D0
	BNE.S	L414
	MOVE	D4,D0
	MULS	-24(A6),D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE.L	G074_puc_B(A4),A3
L414:
	MOVE	-24(A6),-(A7)
	MOVE	D4,-(A7)
	MOVE.L	A3,-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L412:
	MOVE	#7,D0
	MOVE	-22(A6),D1
	SUBQ	#1,D1
	AND	#7,D1
	SUB	D1,D0
	ASL	#1,D0
	MOVE	D0,-90(A6)
	BRA.S	L415
L407:
	CLR	-90(A6)
L415:
L398:
	MOVE.L	-16(A6),A0
	MOVE.B	1(A0),D4
	AND	#255,D4
	MOVE	-78(A6),D0
	ASR	#3,D0
	AND	#7,D0
	MOVE	-52(A6),D1
	AND.L	#65535,D1
	ASL.L	#3,D1
	LEA	G223_aac_G(A4),A0
	ADD.L	A0,D1
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	EXT	D0
	ADD	D0,D4
	MOVE	#135,-(A7)
	MOVE	D4,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,-39(A6)
	MOVE	D4,D0
	MOVE	-24(A6),D1
	SUBQ	#1,D1
	SUB	D1,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,-40(A6)
	MOVE.L	-16(A6),A0
	MOVE.B	(A0),D4
	AND	#255,D4
	MOVE	-78(A6),D0
	AND	#7,D0
	MOVE	-52(A6),D1
	AND.L	#65535,D1
	ASL.L	#3,D1
	LEA	G223_aac_G(A4),A0
	ADD.L	A0,D1
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	EXT	D0
	ADD	D0,D4
	CMPI	#1,-26(A6)
	BNE.S	L416
	SUB	#100,D4
	BRA.S	L417
L416:
	MOVE	-26(A6),D0
	BEQ.S	L418
	ADD	#100,D4
L418:
L417:
	MOVE	#223,-(A7)
	MOVE	D4,D0
	ADD	-22(A6),D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	JSR	F026_a003_(PC)
	ADDQ.L	#6,A7
	MOVE.B	D0,-41(A6)
	BNE.S	L419
	BRA.S	L22T115_126
L419:
	MOVE	#223,-(A7)
	MOVE	D4,D0
	SUB	-22(A6),D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	JSR	F026_a003_(PC)
	ADDQ.L	#6,A7
	MOVE.B	D0,-42(A6)
	BEQ.S	L420
	MOVE.B	-42(A6),D0
	AND	#255,D0
	CMP	#223,D0
	BNE.S	L421
	BRA.S	L22T115_126
L421:
	MOVE	-90(A6),D7
	BRA.S	L422
L420:
	MOVE	-90(A6),D7
	MOVE	-22(A6),D1
	SUB	D4,D1
	SUBQ	#1,D1
	ADD	D1,D7
L422:
	MOVE	-84(A6),-(A7)
	MOVE	#112,-(A7)
	MOVE	-22(A6),D0
	ADDQ	#7,D0
	AND	#-8,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	MOVE	D7,-(A7)
	PEA	-42(A6)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L22T115_126:
	MOVE	-94(A6),D0
	BEQ.S	L423
	CLR	-94(A6)
	MOVE	-82(A6),D0
	SEQ	D0
	AND	#1,D0
	MOVE.L	-62(A6),A0
	LEA	12(A0),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE	D0,-78(A6)
	CMPI	#1,D5
	BNE.S	L424
	CLR	D5
	BRA.S	L425
L424:
	MOVE	#1,D5
L425:
	BRA	L22T115_077(PC)
L423:
L22T115_129:
	MOVE	-134(A6),D0
	BEQ.S	L427
	MOVE	-46(A6),D0
	MOVE	D0,D6
	CMPI	#9,D0
	BGT.S	L427
	MOVE	-136(A6),D0
	MOVE	D0,D5
	MOVE	D6,D1
	MULS	#10,D1
	LEA	G218_aaaau(A4),A0
	ADD.L	A0,D1
	ASL.L	#1,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE	D0,-122(A6)
	BNE.S	L426
L427:
	BRA	L281(PC)
L426:
	MOVE	-44(A6),D7
L428:
	MOVE	D7,D0
	AND	#15360,D0
	LSR	#2,D0
	LSR	#8,D0
	CMPI	#14,D0
	BNE	L431(PC)
	MOVE	D7,D0
	LSR	#6,D0
	LSR	#8,D0
	MOVE	-28(A6),D1
	CMP	D1,D0
	BNE	L431(PC)
	MOVE	D7,D0
	AND	#1023,D0
	MOVE.L	G284_apuc_+56(A4),D1
	ASL.L	#3,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-118(A6)
	MOVE.L	-118(A6),A0
	MOVE	2(A0),-(A7)
	JSR	F142_aqzz_(PC)
	ADDQ.L	#2,A7
	MOVE	D0,D4
	CMPI	#0,D0
	BGE	L432(PC)
	MOVE	D4,D0
	NEG	D0
	MULS	#6,D0
	LEA	G210_as_Gr+-6(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,D0
	MOVE.L	D0,A2
	MOVE.L	A2,D4
	MOVE.L	D4,A0
	MOVE.B	(A0),D4
	AND	#255,D4
	ADD	#316,D4
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE	4(A0),D0
	AND	#3,D0
	MOVE	D0,-126(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE	4(A0),D0
	AND	#256,D0
	SEQ	D0
	AND	#1,D0
	MOVE	D0,-130(A6)
	BNE.S	L434
	MOVE.L	-118(A6),A0
	MOVE.B	4(A0),D0
	AND	#255,D0
	CMP	#255,D0
	BNE.S	L433
L434:
	CMPI	#9,D6
	BNE.S	L433
	CLR	-112(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	2(A0),D0
	AND	#255,D0
	MOVE	D0,-22(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	3(A0),D0
	AND	#255,D0
	MOVE	D0,-24(A6)
	BRA	L435(PC)
L433:
	MOVE	D6,D0
	EXT.L	D0
	DIVS	#3,D0
	ASL	#1,D0
	MOVE	D5,D1
	ASR	#1,D1
	ADD	D1,D0
	MOVE	D0,-52(A6)
	MOVE	-52(A6),D0
	LEA	G215_auc_G(A4),A0
	ADDA	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	MOVE	D0,-112(A6)
	MOVE	-130(A6),D0
	BNE.S	L436
	MOVE.L	-118(A6),A0
	MOVE.B	4(A0),D0
	AND	#255,D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	MOVE	#96,-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,-192(A6)
	MOVE	-112(A6),D0
	MULS	-192(A6),D0
	ASR	#8,D0
	MOVE	D0,-112(A6)
L436:
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	2(A0),D0
	AND	#255,D0
	MULS	-112(A6),D0
	MOVE	-112(A6),D1
	ASR	#1,D1
	ADD	D1,D0
	ASR	#5,D0
	MOVE	D0,-22(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	3(A0),D0
	AND	#255,D0
	MULS	-112(A6),D0
	MOVE	-112(A6),D1
	ASR	#1,D1
	ADD	D1,D0
	ASR	#5,D0
	MOVE	D0,-24(A6)
L435:
	CMPI	#0,-126(A6)
	SEQ	D0
	AND	#1,D0
	MOVE	D0,-140(A6)
	BEQ.S	L437
	MOVE	12(A6),D0
	ADD	14(A6),D0
	AND	#1,D0
	MOVE	D0,-138(A6)
L437:
	CMPI	#3,-126(A6)
	BNE.S	L438
	CLR	-128(A6)
	MOVE	#0,D0
	MOVE	D0,-36(A6)
	MOVE	D0,-142(A6)
	BRA	L439(PC)
L438:
	MOVE.L	-118(A6),A0
	MOVE	6(A0),D0
	MULS	#10,D0
	MOVE.L	G370_ps_Ev(A4),A0
	ADDA	D0,A0
	MOVE	8(A0),D0
	AND	#3072,D0
	LSR	#2,D0
	LSR	#8,D0
	MOVE	D0,-124(A6)
	AND	#1,D0
	MOVE	10(A6),D1
	AND	#1,D1
	CMP	D1,D0
	BEQ.S	L440
	CMPI	#2,-126(A6)
	BNE.S	L441
	MOVE	#1,-128(A6)
	BRA.S	L442
L441:
	MOVE	#2,-128(A6)
L442:
	MOVE	-140(A6),D0
	BEQ.S	L443
	MOVE	D5,D0
	SEQ	D0
	TST.B	D0
	BNE.S	L444
	CMPI	#3,D5
	SEQ	D0
	TST.B	D0
L444:
	AND	#1,D0
	MOVE	D0,-36(A6)
	MOVE	-138(A6),D0
	MOVE	D0,-142(A6)
	BNE.S	L445
	MOVE	-36(A6),D0
	SEQ	D0
	AND	#1,D0
	MOVE	D0,-36(A6)
L445:
	BRA.S	L446
L443:
	CLR	-142(A6)
	MOVE	10(A6),D0
	ADDQ	#1,D0
	AND	#3,D0
	CMP	-124(A6),D0
	SEQ	D0
	AND	#1,D0
	MOVE	D0,-36(A6)
L446:
	BRA	L447(PC)
L440:
	CMPI	#2,-126(A6)
	BGE.S	L449
	CMPI	#1,-126(A6)
	BNE.S	L450
	MOVE	-124(A6),D0
	CMP	10(A6),D0
	BNE.S	L449
L450:
	MOVE	-140(A6),D0
	BEQ.S	L448
	MOVE	-138(A6),D0
	BEQ.S	L448
L449:
	CLR	-128(A6)
	BRA.S	L451
L448:
	MOVE	#1,-128(A6)
L451:
	MOVE	-140(A6),D0
	BEQ.S	L452
	CMPI	#2,D5
	SLT	D0
	TST.B	D0
L452:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-142(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE	4(A0),D0
	AND	#16,D0
	BEQ.S	L453
	CMPI	#2,-26(A6)
	SEQ	D0
	TST.B	D0
	BNE.S	L454
	MOVE	-26(A6),D0
	SEQ	D0
	TST.B	D0
	BEQ.S	L455
	CMPI	#1,D5
	SEQ	D0
	TST.B	D0
	BNE.S	L456
	CMPI	#2,D5
	SEQ	D0
	TST.B	D0
L456:
	TST.B	D0
L455:
	TST.B	D0
L454:
	TST.B	D0
	SEQ	D0
	TST.B	D0
L453:
	SNE	D0
	AND	#1,D0
	MOVE	D0,-36(A6)
L447:
L439:
	ADD	-128(A6),D4
	CLR	-30(A6)
	MOVE	-112(A6),D0
	BNE.S	L457
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA	L458(PC)
L457:
	MOVE	-36(A6),D0
	BEQ.S	L459
	MOVE	#7,D0
	MOVE	-22(A6),D1
	SUBQ	#1,D1
	AND	#7,D1
	SUB	D1,D0
	ASL	#1,D0
	MOVE	D0,-30(A6)
L459:
	MOVE	-130(A6),D0
	BEQ.S	L460
	MOVE	#282,D0
	MOVE.L	A2,D1
	MOVE.L	D1,A0
	MOVE.B	1(A0),D3
	AND	#255,D3
	ADD	D3,D0
	MOVE	-128(A6),D1
	MULS	#6,D1
	ADD	D1,D0
	ADD	-52(A6),D0
	MOVE	D0,-18(A6)
	MOVE	D0,-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	TST	D0
	BEQ.S	L460
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA.S	L461
L460:
	MOVE	D4,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-12(A6)
	MOVE	-130(A6),D0
	BEQ.S	L462
	MOVE	-18(A6),-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	BRA.S	L463
L462:
	MOVE.L	G074_puc_B(A4),A3
L463:
	MOVE	-52(A6),D0
	LSR	#1,D0
	ASL.L	#2,D0
	LEA	G075_apuc_(A4),A0
	ADDA	D0,A0
	MOVE.L	(A0),-(A7)
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	3(A0),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	2(A0),D0
	AND	#255,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE.L	A3,-(A7)
	MOVE.L	-12(A6),-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE	-130(A6),D0
	BEQ.S	L464
	MOVE	-18(A6),-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
L464:
L461:
L458:
	MOVE	-36(A6),D0
	BNE.S	L466
	MOVE	-142(A6),D0
	BEQ.S	L465
L466:
	MOVE	-22(A6),D4
	ADDQ	#7,D4
	AND	#-8,D4
	MOVE.L	A3,D0
	CMP.L	G074_puc_B(A4),D0
	BEQ.S	L467
	MOVE	D4,D0
	MULS	-24(A6),D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE.L	G074_puc_B(A4),A3
L467:
	MOVE	-142(A6),D0
	BEQ.S	L468
	MOVE	-24(A6),-(A7)
	MOVE	D4,-(A7)
	MOVE.L	A3,-(A7)
	JSR	F131_xxxx_(PC)
	ADDQ.L	#8,A7
L468:
	MOVE	-36(A6),D0
	BEQ.S	L469
	MOVE	-24(A6),-(A7)
	MOVE	D4,-(A7)
	MOVE.L	A3,-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L469:
L465:
	MOVE	-24(A6),D0
	ASR	#1,D0
	ADD	#47,D0
	MOVE.B	D0,-39(A6)
	MOVE	#47,D0
	MOVE	-24(A6),D1
	ASR	#1,D1
	SUB	D1,D0
	MOVE	-24(A6),D1
	AND	#1,D1
	SEQ	D1
	AND	#1,D1
	ADD	D1,D0
	MOVE.B	D0,-40(A6)
	MOVE	-122(A6),D0
	ADD	-22(A6),D0
	MOVE	D0,-(A7)
	MOVE	#223,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,-41(A6)
	MOVE	-122(A6),D0
	SUB	-22(A6),D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,-42(A6)
	BEQ.S	L470
	MOVE	-36(A6),D0
	BEQ.S	L471
	MOVE	-30(A6),D4
	BRA.S	L472
L471:
	CLR	D4
L472:
	BRA.S	L473
L470:
	MOVE	-22(A6),D0
	SUB	-122(A6),D0
	SUBQ	#1,D0
	MOVE	D0,-(A7)
	MOVE	-30(A6),-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,D4
L473:
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE	-22(A6),D0
	ADDQ	#7,D0
	AND	#-8,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	MOVE	D4,-(A7)
	PEA	-42(A6)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	BRA.S	L474
L432:
	CLR	-34(A6)
	MOVE	-122(A6),D0
	MOVE.B	D0,-120(A6)
	MOVE.B	#47,-119(A6)
	LEA	-120(A6),A0
	MOVE.L	A0,-16(A6)
	MOVE	D4,D0
	MULS	#6,D0
	LEA	G209_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,A2
	MOVE.B	(A2),D4
	AND	#255,D4
	ADD	#360,D4
	MOVE	#1,-132(A6)
	BRA	L22T115_015(PC)
L474:
L431:
L22T115_171:
L429:
	MOVE	D7,-(A7)
	JSR	F159_rzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	D0,D7
	CMPI	#-2,D0
	BNE	L428(PC)
L430:
	MOVE	-172(A6),D0
	BEQ.S	L475
	CLR	-172(A6)
	MOVE	G069_ui_St(A4),D0
	ADDQ	#6,D0
	MOVE	D0,G069_ui_St(A4)
	CMPI	#16,D0
	BLS.S	L476
	SUBQ	#3,G069_ui_St(A4)
L476:
L475:
L281:
	MOVE.L	-4(A6),D0
	BNE	L280(PC)
L282:
	MOVE	-158(A6),D0
	BNE.S	L477
	BRA	L275(PC)
L477:
	CLR.L	-150(A6)
	MOVE	-46(A6),D6
	ADDQ	#3,D6
	MOVE	D6,D0
	EXT.L	D0
	DIVS	#3,D0
	MOVE	D0,-46(A6)
	MOVE	-44(A6),D7
L478:
	MOVE	D7,D0
	AND	#15360,D0
	LSR	#2,D0
	LSR	#8,D0
	CMPI	#15,D0
	BNE	L481(PC)
	MOVE	D7,D5
	LSR	#6,D5
	LSR	#8,D5
	MOVE	D7,D0
	AND	#1023,D0
	MOVE.L	G284_apuc_+60(A4),D1
	ASL.L	#2,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-146(A6)
	MOVE.L	-146(A6),A0
	MOVE	2(A0),D0
	AND	#127,D0
	MOVE	D0,D4
	CMPI	#100,D0
	SGE	D0
	AND	#1,D0
	MOVE	D0,-160(A6)
	BEQ.S	L482
	CMPI	#3,D6
	BLT.S	L483
	CMPI	#9,D6
	BGT.S	L483
	MOVE	D5,D0
	CMP	-28(A6),D0
	BEQ.S	L482
L483:
	BRA	L479(PC)
L482:
	CLR	-162(A6)
	CMPI	#0,D4
	BEQ.S	L485
	CMPI	#2,D4
	BEQ.S	L485
	CMPI	#101,D4
	BNE.S	L484
L485:
	CLR	D4
	BRA	L486(PC)
L484:
	CMPI	#6,D4
	BEQ.S	L488
	CMPI	#7,D4
	BNE.S	L487
L488:
	MOVE	#2,D4
	BRA	L489(PC)
L487:
	CMPI	#40,D4
	BNE.S	L490
	MOVE	#1,-162(A6)
	MOVE	#3,D4
	BRA	L491(PC)
L490:
	CMPI	#100,D4
	BNE	L492(PC)
	MOVE	#-126,-(A7)
	JSR	F142_aqzz_(PC)
	ADDQ.L	#2,A7
	NEG	D0
	MULS	#6,D0
	LEA	G210_as_Gr+-6(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,D0
	MOVE.L	D0,A2
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	(A0),D0
	AND	#255,D0
	ADD	#317,D0
	MOVE	D0,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE	D6,D0
	MULS	#6,D0
	LEA	G228_aai_G+-18(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-154(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	2(A0),D0
	MOVE.L	-154(A6),A0
	AND	#255,D0
	MULS	4(A0),D0
	MOVE.L	-154(A6),A0
	MOVE	4(A0),D1
	ASR	#1,D1
	ADD	D1,D0
	ASR	#5,D0
	MOVE	D0,-22(A6)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	3(A0),D0
	MOVE.L	-154(A6),A0
	AND	#255,D0
	MULS	4(A0),D0
	MOVE.L	-154(A6),A0
	MOVE	4(A0),D1
	ASR	#1,D1
	ADD	D1,D0
	ASR	#5,D0
	MOVE	D0,-24(A6)
	CMPI	#9,D6
	BEQ.S	L493
	PEA	G017_auc_G(A4)
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	3(A0),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.L	A2,D0
	MOVE.L	D0,A0
	MOVE.B	2(A0),D0
	AND	#255,D0
	ASL	#1,D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE.L	G074_puc_B(A4),A3
L493:
	BRA	L22T115_200(PC)
L492:
	CMPI	#50,D4
	BNE.S	L494
	CMPI	#4,D6
	BLT.S	L495
	MOVE.L	-146(A6),-150(A6)
L495:
	BRA	L479(PC)
L494:
	MOVE	#1,D4
L491:
L489:
L486:
	CMPI	#12,D6
	BNE	L496(PC)
	MOVE	-162(A6),D0
	BEQ.S	L497
	SUBQ	#1,D4
L497:
	MOVE	D4,D0
	MULS	#3,D0
	MOVE	D0,D4
	MOVE.L	-146(A6),A0
	MOVE	2(A0),D5
	AND	#-256,D5
	LSR	#8,D5
	LSR	#5,D5
	BEQ.S	L498
	ADDQ	#1,D4
	CMPI	#3,D5
	BLE.S	L499
	ADDQ	#1,D4
L499:
L498:
	CLR	-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	D4,D0
	ADD	#351,D0
	MOVE	D0,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,A3
	MOVE	-162(A6),D0
	BEQ.S	L500
	PEA	G212_auc_G(A4)
	MOVE	#32,-(A7)
	MOVE	#48,-(A7)
	MOVE	#32,-(A7)
	MOVE	#48,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F129_szzz_(PC)
	ADDA	#20,A7
	MOVE.L	G074_puc_B(A4),A3
L500:
	CLR	-(A7)
	CLR	-(A7)
	MOVE	#138,-(A7)
	MOVE	#112,-(A7)
	JSR	F027_AA59_(PC)
	AND	#63,D0
	MOVE	D0,-(A7)
	JSR	F029_AA19_(PC)
	ADD	#87,D0
	MOVE	D0,-(A7)
	PEA	G105_s_Gra(A4)
	CLR	-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	CLR.L	-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F133_xxxx_(PC)
	ADDA	#32,A7
	CLR	-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	#-32768,-(A7)
	JSR	F480_AA07_(PC)
	ADDQ.L	#2,A7
	CMPI	#136,G031_i_Gra(A4)
	BEQ.S	L501
	PEA	G295_ac_Se(A4)
	JSR	F277_jzzz_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BNE.S	L501
	MOVE	#136,G189_i_Gra(A4)
L501:
	BRA	L502(PC)
L496:
	MOVE	-160(A6),D0
	BEQ.S	L503
	MOVE	D6,D0
	MULS	#6,D0
	LEA	G227_aai_G+-18(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-154(A6)
	MOVE.L	-154(A6),A0
	MOVE	4(A0),-156(A6)
	BRA	L504(PC)
L503:
	MOVE.L	-146(A6),A0
	MOVE	2(A0),D0
	AND	#128,D0
	LSR	#7,D0
	BEQ.S	L505
	MOVE	D6,D0
	ASL.L	#2,D0
	LEA	G225_aai_G(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-154(A6)
	BRA.S	L506
L505:
	MOVE	D5,D0
	CMP	10(A6),D0
	BEQ.S	L508
	MOVE	D5,D0
	MOVE	10(A6),D1
	SUBQ	#1,D1
	AND	#3,D1
	CMP	D1,D0
	BNE.S	L507
L508:
	CLR	D5
	BRA.S	L509
L507:
	MOVE	#1,D5
L509:
	MOVE	D5,D0
	MOVE	D6,D1
	EXT.L	D1
	ASL.L	#3,D1
	LEA	G226_aaai_(A4),A0
	ADD.L	A0,D1
	ASL.L	#2,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-154(A6)
L506:
	MOVE.L	-146(A6),A0
	MOVE	2(A0),D0
	AND	#-256,D0
	LSR	#8,D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	MOVE	#48,-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE	-46(A6),D1
	LEA	G216_auc_G(A4),A0
	ADDA	D1,A0
	MOVE.B	(A0),D1
	AND	#255,D1
	MULS	D1,D0
	ASR	#8,D0
	MOVE	D0,-(A7)
	MOVE	#4,-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	AND	#-2,D0
	MOVE	D0,-156(A6)
L504:
	PEA	-24(A6)
	PEA	-22(A6)
	MOVE	-156(A6),-(A7)
	MOVE	D4,-(A7)
	JSR	F114_xxxx_(PC)
	ADDA	#12,A7
	MOVE.L	D0,A3
L22T115_200:
	JSR	F028_a000_(PC)
	MOVE	D0,-142(A6)
	JSR	F028_a000_(PC)
	MOVE	D0,-36(A6)
	BEQ.S	L510
	MOVE	#7,D0
	MOVE	-22(A6),D1
	SUBQ	#1,D1
	AND	#7,D1
	SUB	D1,D0
	ASL	#1,D0
	MOVE	D0,-30(A6)
L510:
	MOVE.L	-154(A6),A0
	MOVE	2(A0),D0
	MOVE	-24(A6),D1
	ASR	#1,D1
	ADD	D1,D0
	MOVE	D0,-(A7)
	MOVE	#135,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE.B	D0,-39(A6)
	MOVE.L	-154(A6),A0
	MOVE	2(A0),D0
	MOVE	-24(A6),D1
	ASR	#1,D1
	SUB	D1,D0
	MOVE	-24(A6),D1
	AND	#1,D1
	SEQ	D1
	AND	#1,D1
	ADD	D1,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,D4
	CMPI	#136,D4
	BLT.S	L511
	BRA	L479(PC)
L511:
	MOVE	D4,D0
	MOVE.B	D0,-40(A6)
	MOVE.L	-154(A6),A0
	MOVE	(A0),D0
	ADD	-22(A6),D0
	MOVE	D0,-(A7)
	MOVE	#223,-(A7)
	JSR	F024_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,D4
	CMPI	#0,D0
	BGE.S	L512
	BRA	L479(PC)
L512:
	MOVE	D4,D0
	MOVE.B	D0,-41(A6)
	MOVE.L	-154(A6),A0
	MOVE	(A0),D4
	MOVE	#223,-(A7)
	MOVE	D4,D0
	SUB	-22(A6),D0
	ADDQ	#1,D0
	MOVE	D0,-(A7)
	CLR	-(A7)
	JSR	F026_a003_(PC)
	ADDQ.L	#6,A7
	MOVE.B	D0,-42(A6)
	BEQ.S	L513
	MOVE	-36(A6),D0
	BEQ.S	L514
	MOVE	-30(A6),D4
	BRA.S	L515
L514:
	CLR	D4
L515:
	BRA.S	L516
L513:
	MOVE	-22(A6),D0
	SUB	D4,D0
	SUBQ	#1,D0
	MOVE	D0,-(A7)
	MOVE	-30(A6),-(A7)
	JSR	F025_aatz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,D4
L516:
	MOVE.B	-41(A6),D0
	MOVE.B	-42(A6),D1
	AND	#255,D1
	AND	#255,D0
	CMP	D1,D0
	BGT.S	L517
	BRA	L479(PC)
L517:
	MOVE	-22(A6),D0
	ADDQ	#7,D0
	AND	#-8,D0
	MOVE	D0,-22(A6)
	MOVE	-36(A6),D0
	BNE.S	L519
	MOVE	-142(A6),D0
	BEQ.S	L518
L519:
	MOVE	-22(A6),D0
	MULS	-24(A6),D0
	MOVE	D0,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE.L	G074_puc_B(A4),A3
L518:
	MOVE	-36(A6),D0
	BEQ.S	L520
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L520:
	MOVE	-142(A6),D0
	BEQ.S	L521
	MOVE	-24(A6),-(A7)
	MOVE	-22(A6),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F131_xxxx_(PC)
	ADDQ.L	#8,A7
L521:
	MOVE	#10,-(A7)
	MOVE	#112,-(A7)
	MOVE	-22(A6),-(A7)
	CLR	-(A7)
	MOVE	D4,-(A7)
	PEA	-42(A6)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE.L	A3,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L502:
L481:
L479:
	MOVE	D7,-(A7)
	JSR	F159_rzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	D0,D7
	CMPI	#-2,D0
	BNE	L478(PC)
L480:
	CMPI.L	#0,-150(A6)
	BEQ.S	L522
	CMPI	#1,-110(A6)
	BEQ.S	L522
	MOVE	G077_B_DoN(A4),D0
	BNE.S	L522
	SUBQ	#3,D6
	MOVE	#8,-(A7)
	PEA	-170(A6)
	MOVE	D6,D0
	ASL.L	#3,D0
	LEA	G188_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	ADDQ.B	#1,-170(A6)
	MOVE	D6,D0
	ASL.L	#3,D0
	LEA	G163_as_Gr(A4),A0
	ADDA	D0,A0
	LEA	(A0),A0
	MOVE.L	A0,-(A7)
	PEA	-170(A6)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L522:
L275:
	MOVEM.L	(A7)+,D4-D7/A2-A3
	UNLK	A6
	RTS
L$274:	.EQU	#-192
F116_xxxx_:/* global */
	LINK	A6,L$523
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L525:
	CMP	#19,D0
	BEQ.S	L526
	BRA.S	L528
L526:
	MOVE	-6(A6),D0
	BEQ.S	L530
	PEA	G110_s_Gra(A4)
	MOVE	G079_ai_St+34(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L531
L530:
	PEA	G121_s_Gra(A4)
	MOVE	G079_ai_St+20(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L531:
	BRA	L23T116_015(PC)
	BRA.S	L529
L528:
	CMP	#0,D0
	BEQ.S	L529
	BRA.S	L532
L529:
	PEA	G163_as_Gr+8(A4)
	MOVE.L	G088_apuc_+48(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	CLR	-(A7)
	MOVE	-6(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#2,-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BEQ.S	L534
	CLR	D4
	BRA	L23T116_017(PC)
L534:
	BRA	L524(PC)
	BRA.S	L533
L532:
	CMP	#16,D0
	BEQ.S	L533
L535:
	CMP	#18,D0
	BEQ.S	L533
	BRA.S	L536
L533:
	MOVE	#801,D4
	BRA	L23T116_016(PC)
	BRA.S	L537
L536:
	CMP	#17,D0
	BEQ.S	L537
	BRA.S	L538
L537:
	CLR	-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#536,-(A7)
	MOVE	#1,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G164_s_Gra(A4)
	MOVE.L	G088_apuc_+20(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G179_s_Gra(A4)
	CLR	-(A7)
	MOVE	#984,-(A7)
	PEA	G080_aai_D+8(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#841,D4
	BRA.S	L23T116_017
	BRA.S	L539
L538:
	CMP	#2,D0
	BEQ.S	L539
	BRA.S	L540
L539:
	MOVE	-6(A6),D0
	BNE.S	L542
	PEA	G140_s_Gra(A4)
	MOVE	#49,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L542:
	BRA.S	L541
L540:
	CMP	#5,D0
	BEQ.S	L541
L543:
	CMP	#1,D0
	BEQ.S	L541
	BRA.S	L544
L541:
L23T116_015:
	MOVE	#13345,D4
L23T116_016:
	CLR	-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
L23T116_017:
	MOVE	D4,-(A7)
	MOVE	#1,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L544:
L545:
L527:
	CMPI	#5,-10(A6)
	BNE.S	L546
	MOVE	-6(A6),D0
	BEQ.S	L546
	PEA	G163_as_Gr+8(A4)
	PEA	G188_as_Gr+8(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L546:
L524:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$523:	.EQU	#-10
F117_xxxx_:/* global */
	LINK	A6,L$547
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L549:
	CMP	#19,D0
	BEQ.S	L550
	BRA.S	L552
L550:
	MOVE	-6(A6),D0
	BEQ.S	L554
	PEA	G112_s_Gra(A4)
	MOVE	G079_ai_St+34(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L555
L554:
	PEA	G123_s_Gra(A4)
	MOVE	G079_ai_St+20(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
L555:
	BRA	L24T117_016(PC)
	BRA.S	L553
L552:
	CMP	#0,D0
	BEQ.S	L553
	BRA.S	L556
L553:
	PEA	G163_as_Gr+16(A4)
	MOVE.L	G088_apuc_+48(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#1,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#4,-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BEQ.S	L558
	CLR	D4
	BRA	L24T117_018(PC)
L558:
	BRA	L548(PC)
	BRA.S	L557
L556:
	CMP	#16,D0
	BEQ.S	L557
L559:
	CMP	#18,D0
	BEQ.S	L557
	BRA.S	L560
L557:
	MOVE	#1042,D4
	BRA	L24T117_017(PC)
	BRA.S	L561
L560:
	CMP	#17,D0
	BEQ.S	L561
	BRA	L562(PC)
L561:
	MOVE	#2,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#296,-(A7)
	MOVE	#2,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#704,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+20(A4),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	PEA	G165_s_Gra(A4)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F103_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	-4(A6),D0
	MOVE.L	G284_apuc_(A4),D1
	ASL.L	#2,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE	2(A0),D0
	AND	#64,D0
	LSR	#6,D0
	BEQ.S	L564
	CLR	-(A7)
	MOVE	#1,-(A7)
	JSR	F110_xxxx_(PC)
	ADDQ.L	#4,A7
L564:
	PEA	G181_s_Gra(A4)
	CLR	-(A7)
	MOVE	#984,-(A7)
	PEA	G080_aai_D+8(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#1081,D4
	BRA.S	L24T117_018
	BRA.S	L563
L562:
	CMP	#2,D0
	BEQ.S	L563
	BRA.S	L565
L563:
	MOVE	-6(A6),D0
	BNE.S	L567
	PEA	G142_s_Gra(A4)
	MOVE	#49,-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
L567:
	BRA.S	L566
L565:
	CMP	#5,D0
	BEQ.S	L566
L568:
	CMP	#1,D0
	BEQ.S	L566
	BRA.S	L569
L566:
L24T117_016:
	MOVE	#17170,D4
L24T117_017:
	MOVE	#2,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
L24T117_018:
	MOVE	D4,-(A7)
	MOVE	#2,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L569:
L570:
L551:
	CMPI	#5,-10(A6)
	BNE.S	L571
	MOVE	-6(A6),D0
	BEQ.S	L571
	PEA	G163_as_Gr+16(A4)
	PEA	G188_as_Gr+16(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L571:
L548:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$547:	.EQU	#-10
F118_xxxx_:/* global */
	LINK	A6,L$572
	MOVEM.L	A3/D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L574:
	CMP	#19,D0
	BEQ.S	L575
	BRA.S	L577
L575:
	MOVE	-6(A6),D0
	BEQ.S	L579
	PEA	G111_s_Gra(A4)
	MOVE	G079_ai_St+32(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L580
L579:
	PEA	G122_s_Gra(A4)
	MOVE	G079_ai_St+18(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L580:
	BRA	L25T118_027(PC)
	BRA.S	L578
L577:
	CMP	#0,D0
	BEQ.S	L578
	BRA.S	L581
L578:
	PEA	G163_as_Gr(A4)
	MOVE.L	G088_apuc_+48(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#3,-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BEQ.S	L583
	CLR	D4
	BRA	L25T118_028(PC)
L583:
	BRA	L573(PC)
	BRA.S	L582
L581:
	CMP	#17,D0
	BEQ.S	L582
	BRA	L584(PC)
L582:
	MOVE	#1,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#536,-(A7)
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G166_s_Gra(A4)
	MOVE.L	G088_apuc_+16(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#704,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+16(A4),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	PEA	G167_s_Gra(A4)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F103_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	-4(A6),D0
	MOVE.L	G284_apuc_(A4),D1
	ASL.L	#2,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE	2(A0),D0
	AND	#64,D0
	LSR	#6,D0
	BEQ.S	L586
	MOVE	#1,-(A7)
	MOVE	#1,-(A7)
	JSR	F110_xxxx_(PC)
	ADDQ.L	#4,A7
L586:
	PEA	G180_s_Gra(A4)
	CLR	-(A7)
	MOVE	#984,-(A7)
	PEA	G080_aai_D+8(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#841,D4
	BRA	L25T118_028(PC)
	BRA.S	L585
L584:
	CMP	#2,D0
	BEQ.S	L585
	BRA.S	L587
L585:
	MOVE	-6(A6),D0
	BNE.S	L589
	PEA	G141_s_Gra(A4)
	MOVE	#50,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L589:
	BRA.S	L588
L587:
	CMP	#5,D0
	BEQ.S	L588
	BRA	L590(PC)
L588:
	CMPI	#15,G069_ui_St(A4)
	BCS	L592(PC)
	MOVE	G625_i_Flo(A4),D0
	BNE	L592(PC)
	MOVE.L	G319_ul_Lo(A4),D0
	CMP.L	#66531,D0
	BGE.S	L594
	MOVE.L	G313_ul_Ga(A4),D0
	CMP.L	#65530,D0
	BGT.S	L593
L594:
	MOVE.L	G313_ul_Ga(A4),D0
	MOVE.L	G319_ul_Lo(A4),D1
	ADD.L	#8192,D1
	CMP.L	D1,D0
	BLS	L592(PC)
L593:
	JSR	F029_AA19_(PC)
L595:
	CMP	#0,D0
	BEQ.S	L596
	BRA.S	L598
L596:
	LEA	F123_xxxx_(PC),A0
	MOVE.L	A0,A3
	BRA.S	L597
	BRA.S	L599
L598:
	CMP	#1,D0
	BEQ.S	L599
	BRA.S	L600
L599:
	LEA	F124_xxxx_(PC),A0
	MOVE.L	A0,A3
	BRA.S	L597
	BRA.S	L601
L600:
	CMP	#2,D0
	BEQ.S	L601
	BRA.S	L602
L601:
	LEA	F122_xxxx_(PC),A0
	MOVE.L	A0,A3
	BRA.S	L597
	BRA.S	L603
L602:
	CMP	#3,D0
	BEQ.S	L603
	BRA.S	L604
L603:
	LEA	F126_xxxx_(PC),A0
	MOVE.L	A0,A3
L604:
L605:
L597:
	MOVE	#3,-(A7)
	PEA	G104_apc_C(A4)
	PEA	G625_i_Flo(A4)
	MOVE.L	G643_puc_F(A4),-(A7)
	MOVE	#538,-(A7)
	PEA	F489_ayzz_(PC)
	MOVE.L	A3,-(A7)
	JSR	F137_pzzz_(PC)
	ADDA	#24,A7
	ORI	#1,G644_i_Flo(A4)
	ORI	#1,G314_i_Sec(A4)
	SUBI	#10,G069_ui_St(A4)
	CLR	G071_B_Sec(A4)
L592:
	BRA.S	L591
L590:
	CMP	#1,D0
	BEQ.S	L591
	BRA.S	L606
L591:
L25T118_027:
	MOVE	#13345,D4
	MOVE	#1,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
L25T118_028:
	MOVE	D4,-(A7)
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L606:
L607:
L576:
	CMPI	#5,-10(A6)
	BNE.S	L608
	MOVE	-6(A6),D0
	BEQ.S	L608
	PEA	G163_as_Gr(A4)
	PEA	G188_as_Gr(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L608:
L573:
	MOVEM.L	(A7)+,D4-D7/A3
	UNLK	A6
	RTS
L$572:	.EQU	#-10
F119_xxxx_:/* global */
	LINK	A6,L$609
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L611:
	CMP	#19,D0
	BEQ.S	L612
	BRA.S	L614
L612:
	MOVE	-6(A6),D0
	BEQ.S	L616
	PEA	G113_s_Gra(A4)
	MOVE	G079_ai_St+30(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L617
L616:
	PEA	G124_s_Gra(A4)
	MOVE	G079_ai_St+16(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L617:
	BRA	L26T119_018(PC)
	BRA.S	L615
L614:
	CMP	#0,D0
	BEQ.S	L615
	BRA.S	L618
L615:
	PEA	G163_as_Gr+32(A4)
	MOVE.L	G088_apuc_+44(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#5,-(A7)
	MOVE	-6(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#7,-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BEQ.S	L620
	CLR	D4
	BRA	L26T119_020(PC)
L620:
	BRA	L610(PC)
	BRA.S	L619
L618:
	CMP	#18,D0
	BEQ.S	L619
	BRA.S	L621
L619:
	PEA	G132_s_Gra(A4)
	MOVE	G079_ai_St+6(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L622
L621:
	CMP	#16,D0
	BEQ.S	L622
	BRA.S	L623
L622:
	MOVE	#834,D4
	BRA	L26T119_019(PC)
	BRA.S	L624
L623:
	CMP	#17,D0
	BEQ.S	L624
	BRA.S	L625
L624:
	MOVE	#3,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#536,-(A7)
	MOVE	#4,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G173_s_Gra(A4)
	MOVE.L	G088_apuc_+28(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G182_s_Gra(A4)
	MOVE	#1,-(A7)
	MOVE	#1952,-(A7)
	PEA	G080_aai_D+4(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#841,D4
	BRA.S	L26T119_020
	BRA.S	L626
L625:
	CMP	#2,D0
	BEQ.S	L626
	BRA.S	L627
L626:
	PEA	G143_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L629
	MOVE	#57,D0
	BRA.S	L630
L629:
	MOVE	#51,D0
L630:
	MOVE	D0,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L628
L627:
	CMP	#5,D0
	BEQ.S	L628
L631:
	CMP	#1,D0
	BEQ.S	L628
	BRA.S	L632
L628:
L26T119_018:
	MOVE	#13345,D4
L26T119_019:
	MOVE	#3,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
L26T119_020:
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G152_s_Gra(A4)
	MOVE	#63,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
	MOVE	D4,-(A7)
	MOVE	#4,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L632:
L633:
L613:
	CMPI	#5,-10(A6)
	BNE.S	L634
	MOVE	-6(A6),D0
	BEQ.S	L634
	PEA	G163_as_Gr+32(A4)
	PEA	G188_as_Gr+32(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L634:
L610:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$609:	.EQU	#-10
F120_xxxx_:/* global */
	LINK	A6,L$635
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L637:
	CMP	#19,D0
	BEQ.S	L638
	BRA.S	L640
L638:
	MOVE	-6(A6),D0
	BEQ.S	L642
	PEA	G115_s_Gra(A4)
	MOVE	G079_ai_St+30(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L643
L642:
	PEA	G126_s_Gra(A4)
	MOVE	G079_ai_St+16(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
L643:
	BRA	L27T120_027(PC)
	BRA.S	L641
L640:
	CMP	#0,D0
	BEQ.S	L641
	BRA	L644(PC)
L641:
	PEA	G163_as_Gr+40(A4)
	MOVE.L	G088_apuc_+44(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#6,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#9,-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BEQ.S	L646
	CLR	D4
	BRA	L27T120_029(PC)
L646:
	CMPI	#6,G069_ui_St(A4)
	BHI	L647(PC)
	MOVE	G071_B_Sec(A4),D0
	BEQ	L647(PC)
	MOVE	G625_i_Flo(A4),D0
	BNE	L647(PC)
	MOVE	G315_i_Sec(A4),D0
	AND	#1,D0
	BNE.S	L649
	MOVE	G644_i_Flo(A4),D0
	AND	#1,D0
	BNE.S	L648
L649:
	MOVE	G316_i_Sec(A4),D0
	AND	#1,D0
	BEQ.S	L650
	MOVE	G315_i_Sec(A4),D0
	AND	#1,D0
	BEQ.S	L651
	ADDQ	#1,G072_ui_Gr(A4)
	ANDI	#-2,G315_i_Sec(A4)
L651:
	ANDI	#-2,G316_i_Sec(A4)
	BRA.S	L652
L650:
	BRA.S	L27T120_011
L652:
	ADDI	#10,G069_ui_St(A4)
L27T120_011:
	BRA.S	L653
L648:
	CLR	G070_B_Sec(A4)
	MOVE	#3,-(A7)
	PEA	G104_apc_C(A4)
	PEA	G083_apc_G(A4)
	MOVE.L	G643_puc_F(A4),-(A7)
	MOVE	#21,-(A7)
	PEA	F489_ayzz_(PC)
	JSR	F028_a000_(PC)
	TST	D0
	BEQ.S	L654
	LEA	F124_xxxx_(PC),A0
	MOVE.L	A0,D0
	BRA.S	L655
L654:
	LEA	F125_xxxx_(PC),A0
	MOVE.L	A0,D0
L655:
	MOVE.L	D0,-(A7)
	JSR	F137_pzzz_(PC)
	ADDA	#24,A7
	ADDQ	#5,G069_ui_St(A4)
L653:
L647:
	BRA	L636(PC)
	BRA.S	L645
L644:
	CMP	#18,D0
	BEQ.S	L645
	BRA.S	L656
L645:
	PEA	G133_s_Gra(A4)
	MOVE	G079_ai_St+6(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L657
L656:
	CMP	#16,D0
	BEQ.S	L657
	BRA.S	L658
L657:
	MOVE	#1073,D4
	BRA	L27T120_028(PC)
	BRA.S	L659
L658:
	CMP	#17,D0
	BEQ.S	L659
	BRA.S	L660
L659:
	MOVE	#5,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#296,-(A7)
	MOVE	#5,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G175_s_Gra(A4)
	MOVE.L	G088_apuc_+28(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G184_s_Gra(A4)
	MOVE	#1,-(A7)
	MOVE	#1952,-(A7)
	PEA	G080_aai_D+4(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#1081,D4
	BRA.S	L27T120_029
	BRA.S	L661
L660:
	CMP	#2,D0
	BEQ.S	L661
	BRA.S	L662
L661:
	PEA	G145_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L664
	MOVE	#57,D0
	BRA.S	L665
L664:
	MOVE	#51,D0
L665:
	MOVE	D0,-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L663
L662:
	CMP	#5,D0
	BEQ.S	L663
L666:
	CMP	#1,D0
	BEQ.S	L663
	BRA.S	L667
L663:
L27T120_027:
	MOVE	#17170,D4
L27T120_028:
	MOVE	#5,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#1,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G154_s_Gra(A4)
	MOVE	#63,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
L27T120_029:
	MOVE	D4,-(A7)
	MOVE	#5,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L667:
L668:
L639:
	CMPI	#5,-10(A6)
	BNE.S	L669
	MOVE	-6(A6),D0
	BEQ.S	L669
	PEA	G163_as_Gr+40(A4)
	PEA	G188_as_Gr+40(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L669:
L636:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$635:	.EQU	#-10
F121_xxxx_:/* global */
	LINK	A6,L$670
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L672:
	CMP	#19,D0
	BEQ.S	L673
	BRA.S	L675
L673:
	MOVE	-6(A6),D0
	BEQ.S	L677
	PEA	G114_s_Gra(A4)
	MOVE	G079_ai_St+28(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L678
L677:
	PEA	G125_s_Gra(A4)
	MOVE	G079_ai_St+14(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L678:
	BRA	L28T121_015(PC)
	BRA.S	L676
L675:
	CMP	#0,D0
	BEQ.S	L676
	BRA.S	L679
L676:
	PEA	G163_as_Gr+24(A4)
	MOVE.L	G088_apuc_+44(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#8,-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BEQ.S	L681
	CLR	D4
	BRA	L28T121_016(PC)
L681:
	BRA	L671(PC)
	BRA.S	L680
L679:
	CMP	#17,D0
	BEQ.S	L680
	BRA	L682(PC)
L680:
	MOVE	#4,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#536,-(A7)
	MOVE	#3,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G174_s_Gra(A4)
	MOVE.L	G088_apuc_+28(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G168_s_Gra(A4)
	MOVE.L	G088_apuc_+12(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#1560,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+12(A4),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	PEA	G169_s_Gra(A4)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F103_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	-4(A6),D0
	MOVE.L	G284_apuc_(A4),D1
	ASL.L	#2,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE	2(A0),D0
	AND	#64,D0
	LSR	#6,D0
	BEQ.S	L684
	MOVE	#2,-(A7)
	MOVE	#1,-(A7)
	JSR	F110_xxxx_(PC)
	ADDQ.L	#4,A7
L684:
	PEA	G183_s_Gra(A4)
	MOVE	#1,-(A7)
	MOVE	#1952,-(A7)
	PEA	G080_aai_D+4(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#841,D4
	BRA.S	L28T121_016
	BRA.S	L683
L682:
	CMP	#2,D0
	BEQ.S	L683
	BRA.S	L685
L683:
	PEA	G144_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L687
	MOVE	#58,D0
	BRA.S	L688
L687:
	MOVE	#52,D0
L688:
	MOVE	D0,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L686
L685:
	CMP	#5,D0
	BEQ.S	L686
L689:
	CMP	#1,D0
	BEQ.S	L686
	BRA.S	L690
L686:
L28T121_015:
	MOVE	#13345,D4
	MOVE	#4,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G153_s_Gra(A4)
	MOVE	#64,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
L28T121_016:
	MOVE	D4,-(A7)
	MOVE	#3,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L690:
L691:
L674:
	CMPI	#5,-10(A6)
	BNE.S	L692
	MOVE	-6(A6),D0
	BEQ.S	L692
	PEA	-10(A6)
	PEA	G163_as_Gr+24(A4)
	PEA	G188_as_Gr+24(A4)
	JSR	F113_xxxx_(PC)
	ADDA	#12,A7
L692:
L671:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$670:	.EQU	#-10
F122_xxxx_:/* global */
	LINK	A6,L$693
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L695:
	CMP	#19,D0
	BEQ.S	L696
	BRA.S	L698
L696:
	MOVE	-6(A6),D0
	BEQ.S	L700
	PEA	G116_s_Gra(A4)
	MOVE	G079_ai_St+26(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L701
L700:
	PEA	G127_s_Gra(A4)
	MOVE	G079_ai_St+12(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L701:
	BRA	L29T122_019(PC)
	BRA.S	L699
L698:
	CMP	#0,D0
	BEQ.S	L699
	BRA.S	L702
L699:
	PEA	G163_as_Gr+56(A4)
	MOVE.L	G088_apuc_+40(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#10,-(A7)
	MOVE	-6(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	BRA	L694(PC)
	BRA.S	L703
L702:
	CMP	#18,D0
	BEQ.S	L703
	BRA.S	L704
L703:
	MOVE	-6(A6),D0
	BEQ.S	L706
	PEA	G134_s_Gra(A4)
	MOVE	G079_ai_St+4(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L707
L706:
	PEA	G136_s_Gra(A4)
	MOVE	G079_ai_St+2(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L707:
	BRA.S	L705
L704:
	CMP	#16,D0
	BEQ.S	L705
	BRA.S	L708
L705:
	MOVE	#50,D4
	BRA	L29T122_020(PC)
	BRA.S	L709
L708:
	CMP	#17,D0
	BEQ.S	L709
	BRA.S	L710
L709:
	MOVE	#6,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#40,-(A7)
	MOVE	#7,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G176_s_Gra(A4)
	MOVE.L	G088_apuc_+24(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G185_s_Gra(A4)
	MOVE	#2,-(A7)
	MOVE	#4224,-(A7)
	PEA	G080_aai_D(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#57,D4
	BRA.S	L29T122_021
	BRA.S	L711
L710:
	CMP	#2,D0
	BEQ.S	L711
	BRA.S	L712
L711:
	PEA	G146_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L714
	MOVE	#59,D0
	BRA.S	L715
L714:
	MOVE	#53,D0
L715:
	MOVE	D0,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L713
L712:
	CMP	#5,D0
	BEQ.S	L713
L716:
	CMP	#1,D0
	BEQ.S	L713
	BRA.S	L717
L713:
L29T122_019:
	MOVE	#50,D4
L29T122_020:
	MOVE	#6,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G155_s_Gra(A4)
	MOVE	#65,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
L29T122_021:
	MOVE	D4,-(A7)
	MOVE	#7,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L717:
L718:
L697:
	CMPI	#5,-10(A6)
	BNE.S	L719
	MOVE	-6(A6),D0
	BEQ.S	L719
	PEA	-10(A6)
	PEA	G163_as_Gr+56(A4)
	PEA	G188_as_Gr+56(A4)
	JSR	F113_xxxx_(PC)
	ADDA	#12,A7
L719:
L694:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$693:	.EQU	#-10
F123_xxxx_:/* global */
	LINK	A6,L$720
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L722:
	CMP	#19,D0
	BEQ.S	L723
	BRA.S	L725
L723:
	MOVE	-6(A6),D0
	BEQ.S	L727
	PEA	G118_s_Gra(A4)
	MOVE	G079_ai_St+26(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L728
L727:
	PEA	G129_s_Gra(A4)
	MOVE	G079_ai_St+12(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
L728:
	BRA	L30T123_019(PC)
	BRA.S	L726
L725:
	CMP	#0,D0
	BEQ.S	L726
	BRA.S	L729
L726:
	PEA	G163_as_Gr+64(A4)
	MOVE.L	G088_apuc_+40(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#11,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	BRA	L721(PC)
	BRA.S	L730
L729:
	CMP	#18,D0
	BEQ.S	L730
	BRA.S	L731
L730:
	MOVE	-6(A6),D0
	BEQ.S	L733
	PEA	G135_s_Gra(A4)
	MOVE	G079_ai_St+4(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L734
L733:
	PEA	G137_s_Gra(A4)
	MOVE	G079_ai_St+2(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
L734:
	BRA.S	L732
L731:
	CMP	#16,D0
	BEQ.S	L732
	BRA.S	L735
L732:
	MOVE	#65,D4
	BRA	L30T123_020(PC)
	BRA.S	L736
L735:
	CMP	#17,D0
	BEQ.S	L736
	BRA.S	L737
L736:
	MOVE	#8,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#24,-(A7)
	MOVE	#8,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G178_s_Gra(A4)
	MOVE.L	G088_apuc_+24(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G187_s_Gra(A4)
	MOVE	#2,-(A7)
	MOVE	#4224,-(A7)
	PEA	G080_aai_D(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#73,D4
	BRA.S	L30T123_021
	BRA.S	L738
L737:
	CMP	#2,D0
	BEQ.S	L738
	BRA.S	L739
L738:
	PEA	G148_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L741
	MOVE	#59,D0
	BRA.S	L742
L741:
	MOVE	#53,D0
L742:
	MOVE	D0,-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L740
L739:
	CMP	#5,D0
	BEQ.S	L740
L743:
	CMP	#1,D0
	BEQ.S	L740
	BRA.S	L744
L740:
L30T123_019:
	MOVE	#65,D4
L30T123_020:
	MOVE	#8,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#1,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G157_s_Gra(A4)
	MOVE	#65,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
L30T123_021:
	MOVE	D4,-(A7)
	MOVE	#8,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L744:
L745:
L724:
	CMPI	#5,-10(A6)
	BNE.S	L746
	MOVE	-6(A6),D0
	BEQ.S	L746
	PEA	-10(A6)
	PEA	G163_as_Gr+64(A4)
	PEA	G188_as_Gr+64(A4)
	JSR	F113_xxxx_(PC)
	ADDA	#12,A7
L746:
L721:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$720:	.EQU	#-10
F124_xxxx_:/* global */
	LINK	A6,L$747
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
	MOVE	D0,G285_i_Squ(A4)
L749:
	CMP	#19,D0
	BEQ.S	L750
	BRA.S	L752
L750:
	MOVE	-6(A6),D0
	BEQ.S	L754
	PEA	G117_s_Gra(A4)
	MOVE	G079_ai_St+24(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L755
L754:
	PEA	G128_s_Gra(A4)
	MOVE	G079_ai_St+10(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L755:
	BRA	L31T124_017(PC)
	BRA.S	L753
L752:
	CMP	#0,D0
	BEQ.S	L753
	BRA	L756(PC)
L753:
	CLR	G286_B_Fac(A4)
	CLR	G287_B_Fac(A4)
	CLR	G288_B_Fac(A4)
	MOVE.B	G407_s_Par+3202(A4),D0
	BEQ	L758(PC)
	MOVE	#1,-(A7)
	JSR	F491_xzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	#-1,-(A7)
	MOVE	#48,-(A7)
	MOVE	#112,-(A7)
	MOVE.B	G106_s_Gra+2(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	MOVE.B	G106_s_Gra(A4),D0
	AND	#255,D0
	MOVE	D0,-(A7)
	PEA	G107_s_Gra(A4)
	MOVE	#1,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE	#41,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-14(A6)
	MOVE	#10,-(A7)
	MOVE	#48,-(A7)
	MOVE	#48,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	PEA	G107_s_Gra(A4)
	MOVE	#1,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	MOVE.L	-14(A6),-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
L758:
	PEA	G163_as_Gr+48(A4)
	MOVE.L	G088_apuc_+40(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	#12,-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F107_xxxx_(PC)
	ADDQ.L	#4,A7
	TST	D0
	BEQ.S	L759
	CLR	-(A7)
	MOVE	#6,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L759:
	MOVE.B	G407_s_Par+3202(A4),D0
	BEQ.S	L760
	MOVE	#9,-(A7)
	MOVE	#112,-(A7)
	MOVE	#48,-(A7)
	CLR	-(A7)
	CLR	-(A7)
	PEA	G106_s_Gra(A4)
	MOVE.L	G296_puc_B(A4),-(A7)
	MOVE	#1,-(A7)
	JSR	F492_mzzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	MOVE	#1,-(A7)
	JSR	F493_hzzz_(PC)
	ADDQ.L	#2,A7
	MOVE	#-32767,-(A7)
	JSR	F480_AA07_(PC)
	ADDQ.L	#2,A7
L760:
	BRA	L748(PC)
	BRA.S	L757
L756:
	CMP	#17,D0
	BEQ.S	L757
	BRA	L761(PC)
L757:
	MOVE	#7,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	MOVE	#536,-(A7)
	MOVE	#6,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	PEA	G177_s_Gra(A4)
	MOVE.L	G088_apuc_+24(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G170_s_Gra(A4)
	MOVE.L	G088_apuc_+8(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	PEA	G171_s_Gra(A4)
	MOVE.L	G088_apuc_(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	-4(A6),D0
	MOVE.L	G284_apuc_(A4),D1
	ASL.L	#2,D0
	MOVE.L	D1,A0
	ADDA	D0,A0
	MOVE	2(A0),D0
	AND	#64,D0
	LSR	#6,D0
	BEQ.S	L763
	MOVE	#3,-(A7)
	MOVE	#1,-(A7)
	JSR	F110_xxxx_(PC)
	ADDQ.L	#4,A7
L763:
	PEA	G186_s_Gra(A4)
	MOVE	#2,-(A7)
	MOVE	#4224,-(A7)
	PEA	G080_aai_D(A4)
	MOVE	-6(A6),-(A7)
	MOVE	-4(A6),-(A7)
	JSR	F111_xxxx_(PC)
	ADDA	#16,A7
	MOVE	#841,D4
	BRA.S	L31T124_018
	BRA.S	L762
L761:
	CMP	#2,D0
	BEQ.S	L762
	BRA.S	L764
L762:
	PEA	G147_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L766
	MOVE	#60,D0
	BRA.S	L767
L766:
	MOVE	#54,D0
L767:
	MOVE	D0,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L765
L764:
	CMP	#5,D0
	BEQ.S	L765
L768:
	CMP	#1,D0
	BEQ.S	L765
	BRA.S	L769
L765:
L31T124_017:
	MOVE	#13345,D4
	MOVE	#7,-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F108_xxxx_(PC)
	ADDQ.L	#4,A7
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G156_s_Gra(A4)
	MOVE	#66,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
L31T124_018:
	MOVE	D4,-(A7)
	MOVE	#6,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
L769:
L770:
L751:
	CMPI	#5,-10(A6)
	BNE.S	L771
	MOVE	-6(A6),D0
	BEQ.S	L771
	PEA	-10(A6)
	PEA	G163_as_Gr+48(A4)
	PEA	G188_as_Gr+48(A4)
	JSR	F113_xxxx_(PC)
	ADDA	#12,A7
L771:
L748:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$747:	.EQU	#-14
F125_xxxx_:/* global */
	LINK	A6,L$772
	MOVEM.L	D7-D5,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L774:
	CMP	#18,D0
	BEQ.S	L775
	BRA.S	L777
L775:
	PEA	G138_s_Gra(A4)
	MOVE	G079_ai_St(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA	L773(PC)
	BRA.S	L778
L777:
	CMP	#2,D0
	BEQ.S	L778
	BRA.S	L779
L778:
	PEA	G149_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L781
	MOVE	#61,D0
	BRA.S	L782
L781:
	MOVE	#55,D0
L782:
	MOVE	D0,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L780
L779:
	CMP	#1,D0
	BEQ.S	L780
L783:
	CMP	#16,D0
	BEQ.S	L780
L784:
	CMP	#5,D0
	BEQ.S	L780
	BRA.S	L785
L780:
	MOVE	#2,-(A7)
	MOVE	#10,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	BRA.S	L776
	BRA.S	L786
L785:
	CMP	#0,D0
	BEQ.S	L786
	BRA.S	L787
L786:
	PEA	G163_as_Gr+80(A4)
	MOVE.L	G088_apuc_+36(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	BRA.S	L773
L787:
L788:
L776:
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G158_s_Gra(A4)
	MOVE	#67,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
	CMPI	#5,-10(A6)
	BNE.S	L789
	MOVE	-6(A6),D0
	BEQ.S	L789
	PEA	G163_as_Gr+80(A4)
	PEA	G188_as_Gr+80(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L789:
L773:
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L$772:	.EQU	#-10
F126_xxxx_:/* global */
	LINK	A6,L$790
	MOVEM.L	D7-D5,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L792:
	CMP	#18,D0
	BEQ.S	L793
	BRA.S	L795
L793:
	PEA	G139_s_Gra(A4)
	MOVE	G079_ai_St(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA	L791(PC)
	BRA.S	L796
L795:
	CMP	#2,D0
	BEQ.S	L796
	BRA.S	L797
L796:
	PEA	G151_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L799
	MOVE	#61,D0
	BRA.S	L800
L799:
	MOVE	#55,D0
L800:
	MOVE	D0,-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L798
L797:
	CMP	#1,D0
	BEQ.S	L798
L801:
	CMP	#16,D0
	BEQ.S	L798
L802:
	CMP	#5,D0
	BEQ.S	L798
	BRA.S	L803
L798:
	MOVE	#1,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G160_s_Gra(A4)
	MOVE	#67,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#1,-(A7)
	MOVE	#11,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	BRA.S	L794
	BRA.S	L804
L803:
	CMP	#0,D0
	BEQ.S	L804
	BRA.S	L805
L804:
	PEA	G163_as_Gr+88(A4)
	MOVE.L	G088_apuc_+32(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	BRA.S	L791
L805:
L806:
L794:
	CMPI	#5,-10(A6)
	BNE.S	L807
	MOVE	-6(A6),D0
	BEQ.S	L807
	PEA	G163_as_Gr+88(A4)
	PEA	G188_as_Gr+88(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L807:
L791:
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L$790:	.EQU	#-10
F127_xxxx_:/* global */
	LINK	A6,L$808
	MOVEM.L	D7-D5,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	PEA	-10(A6)
	JSR	F172_awzz_(PC)
	ADDA	#10,A7
	MOVE	-10(A6),D0
L810:
	CMP	#16,D0
	BEQ.S	L811
	BRA.S	L813
L811:
	MOVE.B	G407_s_Par+3202(A4),D0
	BEQ.S	L815
	MOVE	#1968,-(A7)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE.L	G088_apuc_+4(A4),-(A7)
	JSR	F007_aAA7_(PC)
	ADDA	#10,A7
	MOVE	#9,-(A7)
	MOVE	#16,-(A7)
	MOVE	#48,-(A7)
	CLR	-(A7)
	MOVE.B	G172_s_Gra(A4),D0
	AND	#255,D0
	MOVE.B	G106_s_Gra(A4),D3
	AND	#255,D3
	SUB	D3,D0
	MOVE	D0,-(A7)
	PEA	G108_s_Gra(A4)
	MOVE.L	G074_puc_B(A4),-(A7)
	MOVE	#41,-(A7)
	JSR	F489_ayzz_(PC)
	ADDQ.L	#2,A7
	MOVE.L	D0,-(A7)
	JSR	F132_xzzz_(PC)
	ADDA	#22,A7
	PEA	G172_s_Gra(A4)
	MOVE.L	G074_puc_B(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
	BRA.S	L816
L815:
	PEA	G172_s_Gra(A4)
	MOVE.L	G088_apuc_+4(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
L816:
	BRA.S	L812
	BRA.S	L814
L813:
	CMP	#19,D0
	BEQ.S	L814
	BRA.S	L817
L814:
	MOVE	-6(A6),D0
	BEQ.S	L819
	PEA	G119_s_Gra(A4)
	MOVE	G079_ai_St+22(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	PEA	G120_s_Gra(A4)
	MOVE	G079_ai_St+22(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
	BRA.S	L820
L819:
	PEA	G130_s_Gra(A4)
	MOVE	G079_ai_St+8(A4),-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
	PEA	G131_s_Gra(A4)
	MOVE	G079_ai_St+8(A4),-(A7)
	JSR	F105_xxxx_(PC)
	ADDQ.L	#6,A7
L820:
	BRA.S	L812
	BRA.S	L818
L817:
	CMP	#2,D0
	BEQ.S	L818
	BRA.S	L821
L818:
	PEA	G150_s_Gra(A4)
	MOVE	-6(A6),D0
	BEQ.S	L823
	MOVE	#62,D0
	BRA.S	L824
L823:
	MOVE	#56,D0
L824:
	MOVE	D0,-(A7)
	JSR	F104_xxxx_(PC)
	ADDQ.L	#6,A7
L821:
L822:
L812:
	CLR	-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	PEA	G159_s_Gra(A4)
	MOVE	#68,-(A7)
	JSR	F112_xxxx_(PC)
	ADDA	#12,A7
	MOVE	#33,-(A7)
	MOVE	#9,-(A7)
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	MOVE	-8(A6),-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	CMPI	#5,-10(A6)
	BNE.S	L825
	MOVE	-6(A6),D0
	BEQ.S	L825
	PEA	G163_as_Gr+72(A4)
	PEA	G188_as_Gr+72(A4)
	JSR	F113_xxxx_(PC)
	ADDQ.L	#8,A7
L825:
L809:
	MOVEM.L	(A7)+,D5-D7
	UNLK	A6
	RTS
L$808:	.EQU	#-10
F128_rzzz_:/* global */
	LINK	A6,L$826
	MOVEM.L	D7-D4,-(A7)
	MOVE	8(A6),D7
	MOVE	10(A6),D6
	MOVE	12(A6),D5
	CLR	D4
	MOVE	G297_B_Dra(A4),D0
	BEQ.S	L828
	JSR	F098_rzzz_(PC)
L828:
	MOVE	#1,G578_B_Use(A4)
	MOVE	#24,-(A7)
	PEA	G291_aauc_(A4)
	JSR	F008_aA19_(PC)
	ADDQ.L	#6,A7
	MOVE	#4,-(A7)
	MOVE	#255,-(A7)
	MOVE	#6,-(A7)
	PEA	G291_aauc_(A4)
	JSR	F009_aA49_(PC)
	ADDA	#10,A7
	CLR	-(A7)
	MOVE.L	#8880,-(A7)
	JSR	F468_ozzz_(PC)
	ADDQ.L	#6,A7
	MOVE.L	D0,G074_puc_B(A4)
	MOVE	D6,D0
	ADD	D5,D0
	ADD	D7,D0
	AND	#1,D0
	MOVE	D0,G076_B_Use(A4)
	BEQ.S	L829
	MOVE	#70,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	G087_puc_B(A4),-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
	MOVE	G661_B_Lar(A4),D4
	BEQ.S	L830
	MOVE.L	G090_puc_B(A4),G088_apuc_+48(A4)
	MOVE.L	G091_puc_B(A4),G088_apuc_+44(A4)
	MOVE.L	G092_puc_B(A4),G088_apuc_+40(A4)
	MOVE.L	G093_puc_B(A4),G088_apuc_+36(A4)
	MOVE.L	G094_puc_B(A4),G088_apuc_+32(A4)
L830:
	BRA.S	L831
L829:
	MOVE	#29,-(A7)
	MOVE	#112,-(A7)
	MOVE.L	G296_puc_B(A4),-(A7)
	JSR	F130_xxxx_(PC)
	ADDQ.L	#8,A7
L831:
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	#-2,-(A7)
	MOVE	#3,-(A7)
	MOVE	D7,-(A7)
	JSR	F153_yzzz_(PC)
	ADDA	#10,A7
	CMPI	#0,D0
	BNE.S	L832
	PEA	G163_as_Gr+104(A4)
	MOVE.L	G088_apuc_+52(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
L832:
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	#2,-(A7)
	MOVE	#3,-(A7)
	MOVE	D7,-(A7)
	JSR	F153_yzzz_(PC)
	ADDA	#10,A7
	CMPI	#0,D0
	BNE.S	L833
	PEA	G163_as_Gr+96(A4)
	MOVE.L	G088_apuc_+56(A4),-(A7)
	JSR	F100_xxxx_(PC)
	ADDQ.L	#8,A7
L833:
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#-1,-(A7)
	MOVE	#4,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	#1,-(A7)
	MOVE	#-2,-(A7)
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F162_afzz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#1,-(A7)
	MOVE	#4,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	#1,-(A7)
	MOVE	#-1,-(A7)
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F162_afzz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	CLR	-(A7)
	MOVE	#4,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	#1,-(A7)
	MOVE	#-3,-(A7)
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	JSR	F162_afzz_(PC)
	ADDQ.L	#4,A7
	MOVE	D0,-(A7)
	JSR	F115_xxxx_(PC)
	ADDA	#12,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#-1,-(A7)
	MOVE	#3,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F116_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#1,-(A7)
	MOVE	#3,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F117_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	CLR	-(A7)
	MOVE	#3,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F118_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#-1,-(A7)
	MOVE	#2,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F119_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#1,-(A7)
	MOVE	#2,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F120_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	CLR	-(A7)
	MOVE	#2,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F121_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#-1,-(A7)
	MOVE	#1,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F122_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#1,-(A7)
	MOVE	#1,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F123_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	CLR	-(A7)
	MOVE	#1,-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F124_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#-1,-(A7)
	CLR	-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F125_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D6,-2(A6)
	MOVE	D5,-4(A6)
	PEA	-4(A6)
	PEA	-2(A6)
	MOVE	#1,-(A7)
	CLR	-(A7)
	MOVE	D7,-(A7)
	JSR	F150_wzzz_(PC)
	ADDA	#14,A7
	MOVE	-4(A6),-(A7)
	MOVE	-2(A6),-(A7)
	MOVE	D7,-(A7)
	JSR	F126_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D5,-(A7)
	MOVE	D6,-(A7)
	MOVE	D7,-(A7)
	JSR	F127_xxxx_(PC)
	ADDQ.L	#6,A7
	MOVE	D4,D0
	BEQ.S	L834
	MOVE.L	G095_puc_B(A4),G088_apuc_+48(A4)
	MOVE.L	G096_puc_B(A4),G088_apuc_+44(A4)
	MOVE.L	G097_puc_B(A4),G088_apuc_+40(A4)
	MOVE.L	G098_puc_B(A4),G088_apuc_+36(A4)
	MOVE.L	G099_puc_B(A4),G088_apuc_+32(A4)
L834:
	MOVE	#1,G071_B_Sec(A4)
	MOVE.L	#8880,-(A7)
	JSR	F469_rzzz_(PC)
	ADDQ.L	#4,A7
	CMPI	#255,G309_i_Par(A4)
	SNE	D0
	AND	#1,D0
	MOVE	D0,-(A7)
	JSR	F097_lzzz_(PC)
	ADDQ.L	#2,A7
	CMPI	#255,G309_i_Par(A4)
	BEQ.S	L835
	JSR	F098_rzzz_(PC)
L835:
L827:
	MOVEM.L	(A7)+,D4-D7
	UNLK	A6
	RTS
L$826:	.EQU	#-4
