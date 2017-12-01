*	OPT	O+
NBMAX=100
ECRAN=$60000
ECRAN2=$70000

AFFV	MACRO
	MOVE.W	(A1),(A0)
	MOVE.W	8(A1),8(A0)
	LEA	16(A0),A0
	LEA	16(A1),A1
	ENDM

EFFV	MACRO
	MOVE.W	D1,(A0)
	MOVE.W	D1,8(A0)
	LEA	16(A0),A0
	ENDM

TEXT
	CLR.L	-(SP)
	MOVE.W	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.B	$484.W
	DC.W	$A00A
	MOVE.B	#$12,$FFFC02


	MOVE.W	#0,-(SP)
	PEA	ECRAN
	PEA	ECRAN
	MOVE.W	#5,-(SP)
	TRAP	#$0E
	ADD.L	#12,SP
	
	LEA	ECRAN,A0
	LEA	ECRAN2,A1
	MOVEQ	#0,D0
	MOVE.W	#$A000-1,D1
EFF_SCREENS
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	DBRA	D1,EFF_SCREENS
	
	MOVEM.L	$FFFF8240.W,D0-D7
	MOVEM.L	D0-D7,OLD_PAL
	
	MOVEM.L	PAL,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

	MOVE.W	#0,ALPHA
	MOVE.W	#0,BETA
	MOVE.W	#0,GAMMA

	BSR	INIT_TABLE
	MOVE.L	#ATARI,A0
	BSR	INIT_OBJET

	MOVE.W	#$2700,SR
	LEA	SAVE,A0
	MOVE.L	$70.W,(A0)+
	MOVE.L	$120.W,(A0)+
	MOVE.B	$FFFA07,(A0)+
	MOVE.B	$FFFA09,(A0)+
	MOVE.B	$FFFA13,(A0)+
	MOVE.B	$FFFA17,(A0)+
	MOVE.B	$FFFA1B,(A0)+
	MOVE.B	$FFFA21,(A0)+
	CLR.B	$FFFA07
	ORI.B	#1,$FFFA07
	CLR.B	$FFFA09
	CLR.B	$FFFA13
	ORI.B	#1,$FFFA13
	BCLR	#3,$FFFA17
	MOVE.L	#VBL,$70.W
	CLR.B	$FFFA1B
	MOVE.B	#180,$FFFA21
	MOVE.B	#8,$FFFA1B
	MOVE.L	#HBL,$120.W
	MOVEQ	#1,D0
	JSR	ZIK
	MOVE.W	#$2300,SR

WAIT_VBL
	TST.W	VBL_FLAG
	BEQ.S	WAIT_VBL
	MOVE.W	#1,NB_VBL

	BSR	CALC_MAT		* CALCUL DE LA MATRICE
	BSR	ROTA		* ROTATION DES BALLES
	BSR	TRIE
	BSR	EFF_PLOTS		* EFFACAGE DES BALLES
	BSR	AFF_PLOTS		* AFFICHAGE DES BALLES

PEK_JMP
	JSR	NONE
PEK_AD1
	ADD.W	#4,BETA
	CMP.W	#360,BETA
	BLT.S	INF_360
	SUB.W	#360,BETA
INF_360
PEK_AD2
	ADD.W	#3,ALPHA
	CMP.W	#360,ALPHA
	BLT.S	INF_360_2
	SUB.W	#360,ALPHA
INF_360_2
PEK_AD3
	ADD.W	#3,GAMMA
	CMP.W	#360,GAMMA
	BLT.S	INF_360_3
	SUB.W	#360,GAMMA
INF_360_3
	CMP.B	#$4E,$FFFC02
	BNE.S	PAS_PLUS
	SUB.L	#10,ZDEP
	BRA.S	SUITE
PAS_PLUS
	CMP.B	#$4A,$FFFC02
	BNE.S	SUITE
	ADD.L	#10,ZDEP
SUITE
	TST.W	CHANGE_FLAG
	BEQ	PAS_F1
	MOVE.W	#0,CHANGE_FLAG
PEK_OBJ
	MOVE.L	#TAB_OBJ,A1
	MOVE.L	(A1)+,A0
	MOVE.L	(A1)+,A2
	MOVE.L	(A1)+,PEK_JMP+2
	MOVE.W	(A1)+,ALPHA
	MOVE.W	(A1)+,BETA
	MOVE.W	(A1)+,GAMMA
	MOVE.W	(A1)+,PEK_AD1+2
	MOVE.W	(A1)+,PEK_AD2+2
	MOVE.W	(A1)+,PEK_AD3+2
	MOVE.L	(A1)+,XDEP
	MOVE.L	(A1)+,YDEP
	MOVE.L	(A1)+,PEK_Z+2
	MOVEM.L	(A2),D0-D7
	MOVEM.L	D0-D7,PAL
	CMP.L	#F_TABOBJ,A1
	BNE.S	PAS_FTAB
	MOVE.L	#TAB_OBJ,A1
PAS_FTAB
	MOVE.L	A1,PEK_OBJ+2
	BSR	INIT_OBJET
	BSR	EFF_ECRANS
	MOVE.L	#5500,ZDEP
	MOVE.W	#1,SCROLL_FLAG
PAS_F1
	CMP.B	#$4B,$FFFC02
	BNE.S	PAS_FG
	SUB.L	#16384,XDEP
PAS_FG
	CMP.B	#$4D,$FFFC02
	BNE.S	PAS_FD
	ADD.L	#16384,XDEP
PAS_FD
	CMP.B	#$50,$FFFC02
	BNE.S	PAS_FB
	ADD.L	#16384,YDEP
PAS_FB
	CMP.B	#$48,$FFFC02
	BNE.S	PAS_FH
	SUB.L	#16384,YDEP
PAS_FH
	TST.W	DISP_FLAG
	BEQ.S	PAS_DISP
	ADD.L	#100,ZDEP
	CMP.L	#5700,ZDEP
	BLT.S	PAS_DISP
	MOVE.W	#1,CHANGE_FLAG
	MOVE.W	#0,DISP_FLAG
PAS_DISP
	TST.W	APPEAR_FLAG
	BEQ.S	PAS_APP
	SUB.L	#100,ZDEP
PEK_Z
	CMP.L	#100,ZDEP
	BGE.S	PAS_APP
	MOVE.L	PEK_Z+2,ZDEP
	MOVE.W	#1,SCROLL_FLAG
	MOVE.W	#0,APPEAR_FLAG
PAS_APP
	BSR	SWAP_ECRAN
	MOVE.B	SCREEN+5,$FF8201
	MOVE.B	SCREEN+6,$FF8203

	MOVE.W	#0,VBL_FLAG

	BRA	WAIT_VBL		* ALORS ON CONTINUE
NONE
	RTS

Z_FINAL
	DC.W	0

ROUT_SERP
	MOVE.L	#COS_MAG,A1
	LEA	OBJ+4,A2
	MOVE.W	#14,D7
DO_SERP
	MOVE.W	(A1)+,(A2)
	ADDQ.L	#8,A2
	CMP.L	#FIN_COS,A1
	BNE.S	PAS_FCOS
	MOVE.L	#COS_MAG,A1
PAS_FCOS
	DBRA	D7,DO_SERP
	ADDQ.L	#2,ROUT_SERP+2
	CMP.L	#FIN_COS,ROUT_SERP+2
	BNE.S	PAS_FCOS2
	MOVE.L	#COS_MAG,ROUT_SERP+2
PAS_FCOS2
	RTS
ROUT_HORL
	MOVE.L	#OBJ+10,A0
PEK_HORL
	MOVE.L	#COS_HOR,A1
PEK_HORL2
	MOVE.L	#COS_HOR+100,A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	(A1),D0
	MOVE.W	2(A1),D1
	MOVE.W	D0,(A0)
	MOVE.W	D1,2(A0)
	ADD.W	D0,D0
	ADD.W	D1,D1
	MOVE.W	D0,8(A0)
	MOVE.W	D1,10(A0)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	(A2),D0
	MOVE.W	2(A2),D1
	MOVE.W	D0,16(A0)
	MOVE.W	D1,18(A0)
	ADD.W	D0,D0
	ADD.W	D1,D1
	MOVE.W	D0,24(A0)
	MOVE.W	D1,26(A0)
	ADDQ.L	#4,PEK_HORL+2
	CMP.L	#F_COS_HOR,PEK_HORL+2
	BNE.S	PAS_FORL
	MOVE.L	#COS_HOR,PEK_HORL+2
	ADD.L	#16,PEK_HORL2+2
	CMP.L	#F_COS_HOR,PEK_HORL2+2
	BLT.S	PAS_FORL
	MOVE.L	#COS_HOR,PEK_HORL2+2
PAS_FORL
	MOVE.L	#OBJ+42,A0
PEK_HORL3
	MOVE.L	#COS_HOR+52,A1
	MOVE.W	(A1)+,D0	* X
	MOVE.W	(A1)+,D1	* Y
	MOVEQ	#15,D2
	ADD.W	D1,D2
	MOVE.W	D0,(A0)
	MOVE.W	D2,2(A0)

	ADD.W	D0,D0
	ADD.W	D1,D1
	MOVEQ	#15,D2
	ADD.W	D1,D2
	MOVE.W	D0,8(A0)
	MOVE.W	D2,10(A0)

	ADD.W	D0,D0
	ADD.W	D1,D1
	MOVEQ	#15,D2
	ADD.W	D1,D2
	MOVE.W	D0,16(A0)
	MOVE.W	D2,18(A0)

	ADD.W	D0,D0
	ADD.W	D1,D1
	MOVEQ	#15,D2
	ADD.W	D1,D2
	MOVE.W	D0,24(A0)
	MOVE.W	D2,26(A0)
PEK_JMPH
	JSR	BALANCIER1
	RTS
BALANCIER1
	ADDQ.L	#4,PEK_HORL3+2
	CMP.L	#COS_HOR+152,PEK_HORL3+2
	BNE.S	PAS_FBAL1
	MOVE.L	#BALANCIER2,PEK_JMPH+2
PAS_FBAL1
	RTS
BALANCIER2
	SUBQ.L	#4,PEK_HORL3+2
	CMP.L	#COS_HOR+52,PEK_HORL3+2
	BNE.S	PAS_FBAL2
	MOVE.L	#BALANCIER1,PEK_JMPH+2
PAS_FBAL2
	RTS

ROUT_EQUA
	RTS

ROUT_PEND
	ADDQ.W	#2,GAMMA
	CMP.W	#78,GAMMA
	BNE.S	PAS_FPEND1
	MOVE.L	#ROUT_PEND2,PEK_JMP+2
PAS_FPEND1
	RTS
ROUT_PEND2
	SUBQ.W	#2,GAMMA
	CMP.W	#-78,GAMMA
	BNE.S	PAS_FPEND2
	MOVE.L	#ROUT_PEND,PEK_JMP+2
PAS_FPEND2
	RTS
FIN_DEMO
	MOVEM.L	OLD_PAL,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

	MOVE.W	#$2700,SR
	MOVE.L	#SAVE,A0
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$120.W
	MOVE.B	(A0)+,$FFFA07
	MOVE.B	(A0)+,$FFFA09
	MOVE.B	(A0)+,$FFFA13
	MOVE.B	(A0)+,$FFFA17
	MOVE.B	(A0)+,$FFFA1B
	MOVE.B	(A0)+,$FFFA21
	MOVE.W	#$2300,SR

	DC.W	$A009
	MOVE.B	#$8,$FFFC02
	MOVE.B	#7,$484.W

	CLR.L	-(SP)		* BYE BYE
	TRAP	#1

SCROLL_FLAG
	DC.W	1
VBL
	MOVEM.L	D0-D7/A0-A6,-(SP)
	CLR.B	$FFFA1B
	MOVE.B	#199,$FFFA21
	MOVE.B	#8,$FFFA1B
	MOVE.L	#HBL,$120.W
	MOVEM.L	PAL,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	CMP.B	#$39,$FFFC02
	BEQ	FIN_DEMO
	TST.W	SCROLL_FLAG
	BEQ.S	PAS_SCROLL
	BSR	SCROLL
PAS_SCROLL
	JSR	ZIK+6
	MOVEM.L	(SP)+,D0-D7/A0-A6
	MOVE.W	#1,VBL_FLAG
	ADDQ	#1,NB_VBL
	RTE

EFF_ECRANS
	LEA	ECRAN,A0
	LEA	ECRAN2,A1
	MOVEQ	#0,D0
	MOVE.W	#7999,D1
EFF_SCREENS2
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	DBRA	D1,EFF_SCREENS2
	RTS

SCROLL
	JSR	ROUT1
	RTS
ROUT1
	MOVE.L	#ROUT2,SCROLL+2
ROUT1B
PEKM
	MOVE.L	#MESS,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ	NEXT_LIG
	CMP.B	#$FF,D0
	BEQ	FIN_MESS
	CMP.B	#1,D0
	BEQ	CHANGE_OBJ
	CMP.B	#2,D0
	BEQ	CHG2_OBJ
	SUB.B	#' ',D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	TAB_FNT,A1
	MOVE.L	(A1,D0.W),A1
	MOVE.L	A1,A3
	SUB.L	#40*48,A3
	MOVE.L	A3,PEKADR1+2
PEKECR1
	MOVE.L	#0,A2
	MOVE.L	A2,PEKECR2+2
	MOVE.L	A2,PEKECR3+2
	MOVE.L	A2,PEKECR4+2
	MOVE.L	A2,A4
	ADD.L	#ECRAN+160*218,A2
	ADD.L	#ECRAN2+160*218,A4
	MOVEQ	#15,D7
AFF_01
	MOVE.W	(A1),(A2)
	MOVE.W	(A1),(A4)
	LEA	40(A1),A1
	LEA	160(A2),A2
	LEA	160(A4),A4
	DBRA	D7,AFF_01
	ADDQ.L	#1,PEKM+2
	ADDQ.L	#8,PEKECR1+2
	RTS
NEXT_LIG
	MOVE.L	#0,PEKECR1+2
	ADDQ.L	#1,PEKM+2
	MOVE.L	#ROUT5A,SCROLL+2
	RTS
FIN_MESS
	MOVE.L	#MESS,PEKM+2
	MOVE.L	#0,PEKECR1+2
	BRA	ROUT1
CHANGE_OBJ
	MOVE.W	#1,DISP_FLAG
	MOVE.W	#0,SCROLL_FLAG
	ADDQ.L	#1,PEKM+2
	MOVE.L	#ROUT1,SCROLL+2
	RTS
CHG2_OBJ
	MOVE.W	#1,APPEAR_FLAG
	MOVE.W	#0,SCROLL_FLAG
	ADDQ.L	#1,PEKM+2
	MOVE.L	#ROUT1,SCROLL+2
	RTS
CHANGE_FLAG
	DC.W	0
ROUT2
PEKADR1
	MOVE.L	#IMG+34,A0
	MOVE.L	A0,A3
	SUB.L	#40*48,A3
	MOVE.L	A3,PEKADR2+2
PEKECR2
	MOVE.L	#0,A1
	MOVE.L	A1,A2
	ADD.L	#ECRAN+160*218,A1
	ADD.L	#ECRAN2+160*218,A2
	MOVEQ	#15,D7
AFF_02
	MOVE.W	(A0),(A1)
	MOVE.W	(A0),(A2)
	LEA	40(A0),A0
	LEA	160(A1),A1
	LEA	160(A2),A2
	DBRA	D7,AFF_02
	MOVE.L	#ROUT3,SCROLL+2
	RTS
ROUT3
PEKADR2
	MOVE.L	#IMG+34,A0
	MOVE.L	A0,A3
	SUB.L	#40*48,A3
	MOVE.L	A3,PEKADR3+2
PEKECR3
	MOVE.L	#0,A1
	MOVE.L	A1,A2
	ADD.L	#ECRAN+160*218,A1
	ADD.L	#ECRAN2+160*218,A2
	MOVEQ	#15,D7
AFF_03
	MOVE.W	(A0),(A1)
	MOVE.W	(A0),(A2)
	LEA	40(A0),A0
	LEA	160(A1),A1
	LEA	160(A2),A2
	DBRA	D7,AFF_03
	MOVE.L	#ROUT4,SCROLL+2
	RTS
ROUT4
PEKADR3
	MOVE.L	#IMG+34,A0
	MOVE.L	A0,A3
PEKECR4
	MOVE.L	#ECRAN+160*218,A1
	MOVE.L	A1,A2
	ADD.L	#ECRAN+160*218,A1
	ADD.L	#ECRAN2+160*218,A2
	MOVEQ	#15,D7
AFF_04
	MOVE.W	(A0),(A1)
	MOVE.W	(A0),(A2)
	LEA	40(A0),A0
	LEA	160(A1),A1
	LEA	160(A2),A2
	DBRA	D7,AFF_04
	MOVE.L	#ROUT1,SCROLL+2
	RTS
ROUT5A
	SUBQ.W	#1,CPT_SCROL
	BNE.S	FIN_ROUT5A
	MOVE.W	#50,CPT_SCROL
	MOVE.L	#ROUT5,SCROLL+2
FIN_ROUT5A
	RTS
CPT_SCROL
	DC.W	50

ROUT5
	MOVE.L	PEKM+2,A0
	SUBQ.L	#2,A0
DO_IT_AGAIN
	MOVE.B	(A0),D0
	CMP.B	#1,D0
	BEQ.S	GO_ON
	CMP.B	#2,D0
	BEQ.S	GO_ON
	BRA.S	SUITE_SCR
GO_ON
	SUBQ.L	#1,A0
	BRA.S	DO_IT_AGAIN
SUITE_SCR
	MOVE.L	A0,PEKM2+2
	MOVE.L	#152,PEK_ADRMCS+2
ROUT5B
PEKM2
	MOVE.L	#MESS,A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	BEQ	ROUT9
	CMP.B	#1,D0
	BEQ	ROUT9
	CMP.B	#2,D0
	BEQ	ROUT9
	SUB.B	#' ',D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	TAB_FNT,A1
	MOVE.L	(A1,D0.W),A1
	SUB.L	#40*48*2,A1
	MOVE.L	A1,A3
	ADD.L	#40*48,A3
	MOVE.L	A3,PEK_MAG1+2
PEK_ADRMCS
	MOVE.L	#152,A0
	MOVE.L	A0,PEK_MCS1+2
	MOVE.L	A0,PEK_MCS2+2
	MOVE.L	A0,PEK_MCS3+2
	MOVE.L	A0,A4
	ADD.L	#ECRAN+160*218,A0
	ADD.L	#ECRAN2+160*218,A4
	MOVEQ	#15,D7
AFF_05
	MOVE.W	(A1),(A0)
	MOVE.W	(A1),(A4)
	LEA	160(A0),A0
	LEA	160(A4),A4
	LEA	40(A1),A1
	DBRA	D7,AFF_05
	MOVE.L	#ROUT6,SCROLL+2
	SUBQ.L	#1,PEKM2+2
	SUBQ.L	#8,PEK_ADRMCS+2
	RTS
ROUT6
PEK_MCS1
	MOVE.L	#ECRAN+160*218,A0
PEK_MAG1
	MOVE.L	#IMG+34,A1
	MOVE.L	A1,A3
	ADD.L	#40*48,A3
	MOVE.L	A3,PEK_MAG2+2
	MOVE.L	A0,A2
	ADD.L	#ECRAN+160*218,A0
	ADD.L	#ECRAN2+160*218,A2
	MOVEQ	#15,D7
AFF_06
	MOVE.W	(A1),(A0)
	MOVE.W	(A1),(A2)
	LEA	160(A0),A0
	LEA	160(A2),A2
	LEA	40(A1),A1
	DBRA	D7,AFF_06
	MOVE.L	#ROUT7,SCROLL+2
	RTS
ROUT7
PEK_MCS2
	MOVE.L	#ECRAN+160*218,A0
PEK_MAG2
	MOVE.L	#IMG+34,A1
	MOVE.L	A0,A2
	ADD.L	#ECRAN+160*218,A0
	ADD.L	#ECRAN2+160*218,A2
	MOVEQ	#15,D7
AFF_07
	MOVE.W	(A1),(A0)
	MOVE.W	(A1),(A2)
	LEA	160(A0),A0
	LEA	160(A2),A2
	LEA	40(A1),A1
	DBRA	D7,AFF_07
	MOVE.L	#ROUT8,SCROLL+2
	RTS
ROUT8
PEK_MCS3
	MOVE.L	#ECRAN+160*218,A0
	MOVE.L	A0,A2
	ADD.L	#ECRAN+160*218,A0
	ADD.L	#ECRAN2+160*218,A2
	MOVEQ	#0,D0
	MOVEQ	#15,D7
AFF_08
	MOVE.L	D0,(A0)
	MOVE.L	D0,(A2)
	MOVE.L	D0,4(A0)
	MOVE.L	D0,4(A2)
	LEA	160(A0),A0
	LEA	160(A2),A2
	DBRA	D7,AFF_08
	MOVE.L	#ROUT5B,SCROLL+2
	RTS
ROUT9
	MOVE.L	#ROUT1,SCROLL+2
	RTS

NB_VBL
	DC.W	0

HBL
timer2
	move.w	#$2700,sr
	MOVEM.L	D0/A0,-(SP)
	lea	$fffffa21.w,a0
	move.b	(a0),d0
sync	cmp.b	(a0),d0
	beq.s	sync
	bclr	#1,$ff820a
	rept	10
	nop
	endr
	bset	#1,$ff820a
	movem.l	(sp)+,d0/a0
	clr.b	$fffffa1b
	MOVE.B 	#1,$FFFA21
	MOVE.B	#8,$FFFA1B
	MOVE.L	#HBL2,$120.W
	rte

HBL2
	MOVE.W	#$2700,SR
	MOVE.W	#$2,$FFFF8240.W
	MOVE.L	#HBL3,$120.W
	MOVE.W	#$2300,SR
	RTE
HBL3
	MOVE.W	#$2700,SR
	MOVE.W	#$3,$FFFF8240.W
	MOVE.L	#HBL4,$120.W
	MOVE.W	#$2300,SR
	RTE
HBL4
	MOVE.W	#$2700,SR
	MOVE.W	#$5,$FFFF8240.W
	MOVE.L	#HBL5,$120.W
	MOVE.W	#$2300,SR
	RTE
HBL5
	MOVE.W	#$2700,SR
	MOVE.W	#$6,$FFFF8240.W
	MOVE.L	#HBL6,$120.W
	MOVE.W	#$2300,SR
	RTE
HBL6
	MOVE.W	#$2700,SR
	MOVE.W	#$7,$FFFF8240.W
	CLR.B	$FFFA1B
	MOVE.B	#11,$FFFA21
	MOVE.B	#8,$FFFA1B
	MOVE.L	#HBL7,$120.W
	MOVE.W	#$2300,SR
	RTE
HBL7
	MOVE.W	#$2700,SR
	CLR.B	$FFFA1B
	MOVE.B	#1,$FFFA21
	MOVE.B	#8,$FFFA1B
	MOVE.L	#HBL8,$120.W
	MOVE.L	#R_FONT,PEK_RST+2
	MOVE.W	#$2300,SR
	RTE
HBL8
	MOVE.W	#$2700,SR
PEK_RST
	MOVE.W	R_FONT,$FFFF8242.W
	ADDQ.L	#2,PEK_RST+2
	MOVE.W	#$2300,SR
	RTE
	
SWAP_ECRAN
	MOVE.L	BUF,D0
	MOVE.L	BUF+4,D1
	MOVE.L	D0,BUF+4
	MOVE.L	D1,BUF

	MOVE.L	SCREEN,D0
	MOVE.L	SCREEN+4,D1
	MOVE.L	D0,SCREEN+4
	MOVE.L	D1,SCREEN
	RTS	

EFF_PLOTS
	MOVE.L	BUF,A0
	MOVEM.L	NILL,D0-D3
	MOVE.W	NBDOTS,D7
EFF_THEM
	MOVE.L	(A0)+,A1
	MOVE.L	(A0)+,A2
	JMP	(A2)

EFF_16

M	SET	0
	REPT	13
	MOVEM.L	D0-D3,M(A1)
M	SET	M+160
	ENDR
	DBRA	D7,EFF_THEM
	RTS

EFF_8

M	SET	0
	REPT	8
	MOVEM.L	D0-D3,M(A1)
M	SET	M+160
	ENDR
	DBRA	D7,EFF_THEM
	RTS
EFF_32

M	SET	0
	REPT	31
	MOVEM.L	D0-D3,M(A1)
	MOVEM.L	D0-D3,M+8(A1)
M	SET	M+160
	ENDR
	DBRA	D7,EFF_THEM
	RTS

AFF_PLOTS
	CMP.L	#5000,ZDEP
	BGE	FIN_AFF
	CMP.L	#10,ZDEP
	BLE	FIN_AFF
	LEA	POINTS,A1
	MOVE.L	#TAB_PUT,D4
	LEA	TAB_160,A3
	MOVE.L	BUF,A4
	MOVE.L	SCREEN,A0
	LEA	ROUT_BALL,A5

	MOVE.L	A0,D6
	MOVE.L	A5,D5
	MOVE.L	#AFF_PL1,A6
	MOVE.W	NBDOTS,D7
AFF_THEM
	MOVE.L	D4,A2
	MOVE.L	D6,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEM.W	(A1)+,D0-D3

	TST.W	D2
	BLE.S	PAS_AFF

	CMP.W	#16,D0
	BGT.S	PAS_ZERO_0
	MOVEQ #16,D0
PAS_ZERO_0
	CMP.W	#16,D1
	BGT.S	PAS_ZERO_1
	MOVEQ #16,D1
PAS_ZERO_1
	CMP.W	#305,D0
	BLE.S	PAS_ZERO_2
	MOVE.W	#305,D0
PAS_ZERO_2
	CMP.W	#200,D1
	BLE.S	PAS_ZERO_3
	MOVE.W	#200,D1
PAS_ZERO_3
	JMP	(A6,D3.W)

AFF_PL1
	MOVE.L	D5,A5

	SUBQ.W	#8,D0
	SUBQ.W	#8,D1

	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	(A2,D0.W),A0
	ADD.W	2(A2,D0.W),A5

	ADD.W	D1,D1
	ADD.W	(A3,D1.W),A0
	MOVE.L	A0,(A4)+
	MOVE.L	#EFF_16,(A4)+
	JSR	(A5)
PAS_AFF
	DBRA	D7,AFF_THEM
FIN_AFF
	RTS

AFF_PL2
	LEA	ROUT_BALL2,A5

	SUBQ.W	#8,D0
	SUBQ.W	#8,D1

	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	(A2,D0.W),A0
	ADD.W	2(A2,D0.W),A5

	ADD.W	D1,D1
	ADD.W	(A3,D1.W),A0
	MOVE.L	A0,(A4)+
	MOVE.L	#EFF_16,(A4)+
	JSR	(A5)
	DBRA	D7,AFF_THEM
	RTS

AFF_PL3
	MOVE.L	D4,A2
	ADD.L	#TAB_PUT3-TAB_PUT,A2
	LEA	ROUT_BALL3,A5

	SUBQ.W	#8,D0
	SUBQ.W	#8,D1

	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	(A2,D0.W),A0
	ADD.W	2(A2,D0.W),A5

	ADD.W	D1,D1
	ADD.W	(A3,D1.W),A0
	MOVE.L	A0,(A4)+
	MOVE.L	#EFF_16,(A4)+
	JSR	(A5)
	DBRA	D7,AFF_THEM
	RTS

AFF_PL4
	MOVE.L	D4,A2
	ADD.L	#TAB_PUT3-TAB_PUT,A2
	LEA	ROUT_BALL4,A5

	SUBQ.W	#8,D0
	SUBQ.W	#8,D1

	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	(A2,D0.W),A0
	ADD.W	2(A2,D0.W),A5

	ADD.W	D1,D1
	ADD.W	(A3,D1.W),A0
	MOVE.L	A0,(A4)+
	MOVE.L	#EFF_16,(A4)+
	JSR	(A5)
	DBRA	D7,AFF_THEM
	RTS

AFF_PL5
	MOVE.L	D4,A2
	ADD.L	#TAB_PUT5-TAB_PUT,A2
	LEA	ROUT_BALL5,A5

	SUB.W	#16,D0
	SUB.W	#16,D1

	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	(A2,D0.W),A0
	ADD.W	2(A2,D0.W),A5

	ADD.W	D1,D1
	ADD.W	(A3,D1.W),A0
	MOVE.L	A0,(A4)+
	MOVE.L	#EFF_32,(A4)+
	JSR	(A5)
	DBRA	D7,AFF_THEM
	RTS

AFF_PL6
	MOVE.L	D4,A2
	ADD.L	#TAB_PUT6-TAB_PUT,A2
	LEA	ROUT_BALL6,A5

	SUBQ.W	#4,D0
	SUBQ.W	#4,D1

	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	(A2,D0.W),A0
	ADD.W	2(A2,D0.W),A5

	ADD.W	D1,D1
	ADD.W	(A3,D1.W),A0
	MOVE.L	A0,(A4)+
	MOVE.L	#EFF_8,(A4)+
	JSR	(A5)
	DBRA	D7,AFF_THEM
	RTS

INIT_TABLE
	LEA	TAB_160,A0
	MOVEQ	#0,D0
	MOVE.W	#199,D1
CALC_160
	MOVE.W	D0,(A0)+
	ADD.W	#160,D0
	DBRA	D1,CALC_160
	RTS

INIT_OBJET
	LEA	OBJ(PC),A1
	LEA	POINTS,A2
	MOVE.W	#NBMAX*4-1,D1
EFF_OBJ
	MOVE.W	#0,(A1)+
	MOVE.W	#0,(A2)+
	DBRA	D1,EFF_OBJ

	LEA	OBJ(PC),A1
	MOVE.W	(A0)+,D7
	MOVE.W	D7,(A1)+
	MOVE.W	D7,NBDOTS
COP_OBJET
	MOVE.W	(A0)+,D1
	MOVE.W	D1,(A1)+
	MOVE.W	(A0)+,(A1)+
	MOVE.W	(A0)+,(A1)+
	MOVE.W	(A0)+,D0
	TST.W	D0
	BNE.S	PAS_NULL
	MOVE.W	#0,(A1)+
	BRA.S	NEXT_OBJ
PAS_NULL
	CMP.W	#1,D0
	BNE.S	PAS_1
	MOVE.W	#AFF_PL2-AFF_PL1,(A1)+
	BRA.S	NEXT_OBJ
PAS_1
	CMP.W	#2,D0
	BNE.S	PAS_2
	MOVE.W	#AFF_PL3-AFF_PL1,(A1)+
	BRA.S	NEXT_OBJ
PAS_2
	CMP.W	#3,D0
	BNE.S	PAS_3
	MOVE.W	#AFF_PL4-AFF_PL1,(A1)+
	BRA.S	NEXT_OBJ
PAS_3
	CMP.W	#4,D0
	BNE.S	PAS_4
	MOVE.W	#AFF_PL5-AFF_PL1,(A1)+
	BRA.S	NEXT_OBJ
PAS_4
	CMP.W	#8,D0
	BNE.S	PAS_8
	MOVE.W	#AFF_PL6-AFF_PL1,(A1)+
PAS_8
NEXT_OBJ
	DBRA	D7,COP_OBJET

	MOVE.L	#POINTS,A0
	MOVEQ	#0,D0
	MOVE.W	NBDOTS,D0
	MULU	#8,D0
	ADDQ.W	#8,D0
	ADD.W	D0,A0
	MOVE.L	A0,FIN_POINTS
	RTS

TRIE
	MOVE.W	NBDOTS,D7
	LEA	POINTS,A0
	MOVE.L	FIN_POINTS,A2
CONT_TRIE2
	LEA	8(A0),A1
CONT_TRIE1
	MOVE.W	4(A0),D0
	CMP.W	4(A1),D0
	BGT.S	PAS_SWAP
	MOVEM.L	(A0),D2-D3
	MOVEM.L	(A1),D4-D5
	MOVEM.L	D4-D5,(A0)
	MOVEM.L	D2-D3,(A1)
PAS_SWAP
	ADDQ	#8,A1
	CMP.L	A2,A1
	BLE.S	CONT_TRIE1
	ADDQ	#8,A0
	DBF	D7,CONT_TRIE2
	RTS

******************************************
* rotation de tout les points de l'objet *
******************************************

ROTA
rotation:	lea obj(pc),a0
	lea POINTS,a1
	lea matrice,a2
	move.w (a0)+,d7
	move.w #160,d6

rota_pt:	move.l a2,a3
	moveq #0,d3
	moveq #0,d4
	moveq #0,d5

	movem.w (a0)+,d0-d2	* x,y,z
	move.l d0,a6
	move.l d1,a4
	move.l d2,a5

	move.w (a3)+,d3
	bne.s coef1_pn
	moveq #0,d0
	bra.s coef2
coef1_pn:	muls d3,d0
coef2:	move.w (a3)+,d3
	bne.s coef2_pn
	moveq #0,d1
	bra.s coef3
coef2_pn:	muls d3,d1
coef3:	move.w (a3)+,d3
	bne.s coef3_pn
	moveq #0,d2
	bra.s coef4
coef3_pn:	muls d3,d2
coef4:	add.l d2,d0
	add.l d1,d0

	add.l xdep,d0		* xdep=0=0*16384

	move.l a6,d1
	move.l a4,d2
	move.l a5,d3

	move.w (a3)+,d4
	bne.s coef4_pn
	moveq #0,d1
	bra.s coef5
coef4_pn:	muls d4,d1
coef5:	move.w (a3)+,d4
	bne.s coef5_pn
	moveq #0,d2
	bra.s coef6
coef5_pn:	muls d4,d2
coef6:	move.w (a3)+,d4
	bne.s coef6_pn
	moveq #0,d3
	bra.s coef7
coef6_pn:	muls d4,d3
coef7:	add.l d3,d1
	add.l d2,d1

	add.l ydep,d1	* ydep=0=0*16384

	move.l a6,d2
	move.l a4,d3
	move.l a5,d4

	move.w (a3)+,d5
	bne.s coef7_pn
	moveq #0,d2
	bra.s coef8
coef7_pn:	muls d5,d2
coef8:	move.w (a3)+,d5
	bne.s coef8_pn
	moveq #0,d3
	bra.s coef9
coef8_pn:	muls d5,d3
coef9:	move.w (a3)+,d5
	bne.s coef9_pn
	moveq #0,d4
	bra.s coef10
coef9_pn:	muls d5,d4
coef10:	add.l d4,d2
	add.l d3,d2

ptvision=-45		* ptf=-512
	asr.l #5,d0		* 5:14-9:2^9/2^14
	asr.l #5,d1
	asl.l #2,d2
	swap d2

	add.l zdep,d2	* zdep=300
	tst.w d2
	bmi.s touche
	add.w #-ptvision,d2
	
	TST.W d2
	bne.s pas_nul
	moveq #1,d2

pas_nul:	divs d2,d0
	divs d2,d1
	add.w d6,d0
	add.w #100,d1

	movem.w d0-d2,(a1)
	MOVE.W	(A0)+,6(A1)
	addq #8,a1		* 8 pour etre bien
	DBRA d7,rota_pt

	rts
TOUCHE
	RTS
CALC_MAT

***************************************
*  calcul de la matrice de rotation   *
***************************************

calc_matrice:
	lea cosinus(pc),a0	* cos en .l
	lea 90*4(a0),a1	* sin
	lea angle_rota,a2
	lea matrice,a3
	movem.w (a2),d0-d2

	move.w d2,d3
	sub.w d1,d3		* d3=gamma-beta=a1
	add.w d3,d3		* ON PEUT GAGNER SI ANGLE DE 4 EN 4
	add.w d3,d3
	move.l 0(a0,d3.w),(a3)	* cos(a1) dans mat(1,1)
	move.l 0(a1,d3.w),d3	
	neg.l d3
	move.l d3,12(a3)	* sin(a1) dans mat(2,1)

	move.w d2,d3
	add.w d1,d3
	add.w d3,d3
	add.w d3,d3
	move.l 0(a0,d3.w),d4
	add.l d4,(a3)	* +cos(a2) dans mat(1,1)
	move.l 0(a1,d3.w),d3	
	neg.l d3
	add.l d3,12(a3)	* +sin(a2) dans mat(2,1)

	move.w d1,d3
	add.w d3,d3
	add.w d3,d3
	move.l 0(a1,d3.w),d3
	neg.l d3
	move.l d3,24(a3)	* sin(beta) dans mat(3,1)

	move.w d2,a4
	sub.w d1,a4
	add.w d0,a4		* gamma-beta+alpha
	add.w a4,a4
	add.w a4,a4
	move.l 0(a1,a4.w),d7
	neg.l d7		* a6=sin(a5)
	move.l d7,a6
	move.l 0(a0,a4.w),a4	* a4=cos(a5)

	move.w d2,d3
	add.w d1,d3
	sub.w d0,d3		* gamma+beta-alpha
	add.w d3,d3
	add.w d3,d3
	move.l 0(a1,d3.w),d4	
	neg.l d4		* d4=sin(a6)
	move.l 0(a0,d3.w),d3	* d3=cos(a6)

	move.w d2,d5
	sub.w d1,d5
	sub.w d0,d5		* gamma-beta-alpha
	add.w d5,d5
	add.w d5,d5
	move.l 0(a1,d5.w),d6
	neg.l d6		* d6=sin(a7)
	move.l 0(a0,d5.w),d5	* d5=cos(a7)

	move.w d2,a5
	add.w d1,a5
	add.w d0,a5		* gamma+beta+alpha
	add.w a5,a5
	add.w a5,a5
	move.l 0(a1,a5.w),d7
	neg.l d7		* d7=sin(a8)
	move.l 0(a0,a5.w),a5	* a5=cos(a8)


	lea 16(a3),a2
	move.l a6,(a2)
	add.l d4,(a2)
	sub.l d6,(a2)
	sub.l d7,(a2)

	lea 8(a3),a2
	move.l a6,(a2)
	add.l d6,(a2)
	sub.l d4,(a2)
	sub.l d7,(a2)

	lea 4(a3),a2
	move.l a4,(a2)
	add.l d3,(a2)
	sub.l d5,(a2)
	move.l a5,d7
	sub.l d7,(a2)

	lea 20(a3),a2
	move.l a4,(a2)
	add.l d5,(a2)
	sub.l d3,(a2)
	move.l a5,d7
	sub.l d7,(a2)
*****
	move.w d2,d3
	sub.w d0,d3		* gamma-alpha=a3
	add.w d3,d3
	add.w d3,d3
	move.l 0(a1,d3.w),d4	* d4=sin(a3)
	neg.l d4
	move.l 0(a0,d3.w),d3	* d3=cos(a3)

	move.w d2,d5
	add.w d0,d5		* gamma+alpha
	add.w d5,d5
	add.w d5,d5
	move.l 0(a1,d5.w),d6	* d6=sin(a4)
	neg.l d6
	move.l 0(a0,d5.w),d5	* d5=cos(a4)

	lea 4(a3),a2
	move.l (a2),d2
	asr.l #1,d2
	sub.l d4,d2
	sub.l d6,d2
	asr.l #1,d2
	move.l d2,(a2)

	lea 16(a3),a2
	move.l (a2),d2
	asr.l #1,d2
	add.l d3,d2
	add.l d5,d2
	asr.l #1,d2
	move.l d2,(a2)

	lea 8(a3),a2
	move.l (a2),d2
	asr.l #1,d2
	sub.l d3,d2
	add.l d5,d2
	asr.l #1,d2
	move.l d2,(a2)

	lea 20(a3),a2
	move.l (a2),d2
	neg.l d2
	asr.l #1,d2
	sub.l d4,d2
	add.l d6,d2
	asr.l #1,d2
	move.l d2,(a2)

	move.w d0,d2
	sub.w d1,d2		* alpha-beta
	add.w d2,d2
	add.w d2,d2
	move.l 0(a1,d2.w),d3	* -sin(a9)
	move.l 0(a0,d2.w),d2	* cos(a9)

	add.w d1,d0		* alpha+beta
	add.w d0,d0
	add.w d0,d0
	move.l 0(a1,d0.w),d4	* -sin(a10)
	move.l 0(a0,d0.w),d0	* cos(a10)
	add.l d4,d3
	add.l d0,d2
	
	asr.l #1,d3
	asr.l #1,d2
	move.l d3,28(a3)
	move.l d2,32(a3)

	move.l (a3),d0
	move.l 12(a3),d1
	asr.l #1,d0
	asr.l #1,d1
	move.l d0,(a3)
	move.l d1,12(a3)

	moveq #9-1,d7
	move.l a3,a2

trans_mat:
	move.l (a3)+,d0
	asr.l #2,d0
	move.w d0,(a2)+
	dbf d7,trans_mat
	rts

	DATA
SCREEN
	DC.L	ECRAN,ECRAN2
TAB_DAT
VBL_FLAG
	DC.W	0
COS_MAG
	INCBIN	COS.MAG
FIN_COS
angle:	incbin \angle_l.dat
cosinus=angle+3*360*4
XDEP
	DC.L	0
YDEP
	DC.L	0
ZDEP
	DC.L	600
FIN_POINTS
	DC.L	0
TAB_OBJ
	DC.L	HORLOGE,PAL3,ROUT_HORL
	DC.W	0,0,0,4,0,0
	DC.L	0,$FFFE0000,$78
F_TABOBJ

ATARI
HORLOGE
	INCBIN	HORLOGE.OBJ
OBJ
	DCB.W	NBMAX*4+1,0
POINTS
	DCB.W	NBMAX*4	* X,Y,Z
TAB_PUT
M	SET	0
	REPT	20
	DC.W	M
          DC.W  0
	DC.W	M
          DC.W  310
	DC.W	M
          DC.W  620
	DC.W	M
          DC.W  996
	DC.W	M
          DC.W  1466
	DC.W	M
          DC.W  1986
	DC.W	M
          DC.W  2554
	DC.W	M
          DC.W  3124
	DC.W	M
          DC.W  3740
	DC.W	M
          DC.W  4356
	DC.W	M
          DC.W  4972
	DC.W	M
          DC.W  5584
	DC.W	M
          DC.W  6154
	DC.W	M
          DC.W  6724
	DC.W	M
          DC.W  7250
	DC.W	M
          DC.W  7728
M	SET	M+8
	ENDR
TAB_PUT3
M	SET	0
	REPT	20
	DC.W	M
          DC.W  0
	DC.W	M
          DC.W  388
	DC.W	M
          DC.W  776
	DC.W	M
          DC.W  1248
	DC.W	M
          DC.W  1838
	DC.W	M
          DC.W  2490
	DC.W	M
          DC.W  3202
	DC.W	M
          DC.W  3916
	DC.W	M
          DC.W  4688
	DC.W	M
          DC.W  5460
	DC.W	M
          DC.W  6232
	DC.W	M
          DC.W  7000
	DC.W	M
          DC.W  7714
	DC.W	M
          DC.W  8428
	DC.W	M
          DC.W  9086
	DC.W	M
          DC.W  9684
M	SET	M+8
	ENDR
TAB_PUT5
M	SET	0
	REPT	20
	DC.W	M
          DC.W  0
	DC.W	M
          DC.W  1382
	DC.W	M
          DC.W  2762
	DC.W	M
          DC.W  4142
	DC.W	M
          DC.W  5676
	DC.W	M
          DC.W  7254
	DC.W	M
          DC.W  8930
	DC.W	M
          DC.W  10616
	DC.W	M
          DC.W  12344
	DC.W	M
          DC.W  14078
	DC.W	M
          DC.W  15816
	DC.W	M
          DC.W  17554
	DC.W	M
          DC.W  19248
	DC.W	M
          DC.W  20940
	DC.W	M
          DC.W  22538
	DC.W	M
          DC.W  24086
M	SET	M+8
	ENDR
TAB_PUT6
M	SET	0
	REPT	20
	DC.W	M
          DC.W  0
	DC.W	M
          DC.W  166
	DC.W	M
          DC.W  332
	DC.W	M
          DC.W  498
	DC.W	M
          DC.W  664
	DC.W	M
          DC.W  830
	DC.W	M
          DC.W  996
	DC.W	M
          DC.W  1162
	DC.W	M
          DC.W  1328
	DC.W	M
          DC.W  1494
	DC.W	M
          DC.W  1660
	DC.W	M
          DC.W  1892
	DC.W	M
          DC.W  2174
	DC.W	M
          DC.W  2500
	DC.W	M
          DC.W  2828
	DC.W	M
          DC.W  3114
M	SET	M+8
	ENDR
ROUT_BALL
	INCBIN	BALL.BIN
ROUT_BALL2
	INCBIN	BALL2.BIN
ROUT_BALL3
	INCBIN	BALL3.BIN
ROUT_BALL4
	INCBIN	BALL4.BIN
ROUT_BALL5
	INCBIN	BALL5.BIN
ROUT_BALL6
	INCBIN	BALL6.BIN
BUF
	DC.L	BUF1,BUF2
BUF1
	REPT	NBMAX
	DC.L	ECRAN,EFF_16
	ENDR
BUF2
	REPT	NBMAX
	DC.L	ECRAN,EFF_16
	ENDR
PAL
	dc.w	$0000,$0444,$0555,$0777,$0400,$4,$40,$0
	dc.w	$0500,$5,$50,$0,$0700,$7,$70,$0
PAL1
	dc.w	$0000,$0444,$0555,$0777,$0404,$4,$440,$0
	dc.w	$0505,$5,$550,$0,$0707,$7,$770,$0
PAL2
	dc.w	$0000,$0400,$0500,$0700,$044,$4,$440,$0
	dc.w	$055,$5,$550,$0,$077,$7,$770,$0
PAL3
	dc.w	$0000,$0444,$0555,$0777,$0400,$4,$40,$0
	dc.w	$0500,$5,$50,$0,$0700,$7,$70,$0

R_FONT
	DC.W	$0,$111,$222,$333,$444,$555,$666,$777,$777,$666
	DC.W	$555,$444,$333,$222,$111,$0
	DCB.W	35,$0

********************************************************
*     BALLE 2 PLANS : 8 OCTETS/LIGNE , 13 LIGNES       *
*  (C) M.C.S 1991   (DRAWN BY ZORGLUB, USED BY MAGNUM) *
********************************************************
IMG
	INCBIN	'FNTVEC.BIN'
FNT	EQU	IMG+40*48*3
SPACE	EQU	FNT+40*16*2+2*18
TAB_FNT 
	DC.L	SPACE
	DC.L	FNT+40*16+2*17
	DC.L	FNT+40*16*2+2*2
	DC.L	SPACE
	DC.L	SPACE
	DC.L	SPACE
	DC.L	SPACE
	DC.L	SPACE
	DC.L	FNT+40*16+2*18
	DC.L	FNT+40*16+2*19
	DC.L	SPACE
	DC.L	SPACE
	DC.L	FNT+40*16*2+2*4
	DC.L	SPACE
	DC.L	FNT+40*16*2
	DC.L	SPACE
	DC.L	FNT+40*16+2*6
	DC.L	FNT+40*16+2*7
	DC.L	FNT+40*16+2*8
	DC.L	FNT+40*16+2*9
	DC.L	FNT+40*16+2*10
	DC.L	FNT+40*16+2*11
	DC.L	FNT+40*16+2*12
	DC.L	FNT+40*16+2*13
	DC.L	FNT+40*16+2*14
	DC.L	FNT+40*16+2*15
	DC.L	FNT+40*16*2+2
	DC.L	FNT+40*16*2+2*3
	DC.L	SPACE
	DC.L	SPACE
	DC.L	SPACE
	DC.L	FNT+40*16+2*16
	DC.L	SPACE
M	SET	0
	REPT	20
	DC.L	FNT+M
M	SET	M+2
	ENDR
M	SET	0
	REPT	6
	DC.L	FNT+40*16+M
M	SET	M+2
	ENDR
	EVEN
	DC.B	0
MESS
	DC.B	'  AT THE BEGINNING  ',0
	DC.B	'GOD CREATED EARTH ! ',0,1
	DC.B	'THEN HE CREATED THE ',2,0
	DC.B	'       ATARI ST     ',0
	DC.B	'BUT A DAY HE SAID : ',0
	DC.B	'"I NEED SOME PEOPLE"',0
	DC.B	'TO USE THIS MACHINE.',1,0
	DC.B	'SO HE CREATED M.C.S.',2,0
	DC.B	'BUT WHEN HE SAW US ;',0
	DC.B	'HE SAID : "THEY ARE ',0
	DC.B	'TOO PERFECT, SO, TO ',0
	DC.B	'EQUILIBRATE, HE MADE',1,0
	DC.B	'   THE OVERLANDERS  ',2,0
	DC.B	'AND ESPECIALLY A MAN',1,0
	DC.B	'CALLED : ZIGGY DUST ',2,0
	DC.B	'(NOT A STAR !).     ',0
	DC.B	'BUT WE MET AND MADE ',0
	DC.B	'    THE ALLIANCE    ',1,2,0
	DC.B	'   TIME PASSED...   ',1,2,0
	DC.B	' AND OVR DECIDED TO ',0
	DC.B	' LEAVE THE ALLIANCE ',0
	DC.B	'SO WE (MCS) WANT TO ',0
	DC.B	'  MAKE THE ALLIANCE ',0
	DC.B	'         AGAIN      ',0
	DC.B	'(WITHOUT OVERLAMERS)',1,0
	DC.B	'  OK NOW SOME FUNNY ',0
	DC.B	'       OBJECTS...   ',0
	DC.B	'   FIRST : A GLASS  ',2,0
	DC.B	'NICE ? NO ? OK...   ',1,0,2
	DC.B	' AND SOME GLASSES.. ',0
	DC.B	'   ORIGINAL ? NO ?  ',0,1
	DC.B	'  NOW A XMAS TREE   ',2,0
	DC.B	'NOT VERY GOOD BUT I ',0
	DC.B	'   AM ONLY A CODER  ',0
	DC.B	'  PISS OFF TREE !!  ',1,0,2
	DC.B	'   WHAT IS THAT ??? ',0
	DC.B	' JUST A DELIRIUM..  ',0,1,2
	DC.B	'  THIS TIME ZORGLUB ',0
	DC.B	'   WAS DRUNK....    ',0,1,2
	DC.B	'IS IT A LIGHT ? YES.',0
	DC.B	'NOW A STRANGE THING ',0,1,2
	DC.B	'                    ',0
	DC.B	' GET OUT OFF HERE   ',1,0
	DC.B	'  NOW A GEOMETRICAL ',2,0
	DC.B	'       OBJECT !!!   ',0
	DC.B	' I FIND IT FUNNY... ',0,1
	DC.B	' I MADE IT AGAIN !!!',0,2
	DC.B	'NEVER DONE BEFORE ON',0
	DC.B	'   THE ATARI ST...  ',0
	DC.B	'  IT SHOWS THAT A   ',0
	DC.B	'  VECTORBALL CAN BE ',0
	DC.B	'      ORIGINAL..    ',0,1
	DC.B	' FUCKIN OBJECT !!!  ',2,0
	DC.B	' NOW A JOYSTICK...  ',0,1,2
	DC.B	' I WONT PLAY WITH IT',0
	DC.B	'NOW JUST SOME HELLOS',0,1
	DC.B	'   HELLO GOES TO :  ',0,2
	DC.B	' NEXT (MIT ET DBUG) ',0,1,2
	DC.B	' TBC (DOCPROF,CONAN)',0,1
	DC.B	'FINISH FOR NOW .....',0,2
	DC.B	0,$FF
	EVEN
DISP_FLAG
	DC.W	0
APPEAR_FLAG
	DC.W	0
AD70
	DC.L	0
NILL
	DCB.L	4,$0
ZIK
	INCBIN	CZ4.MUS
SAVE
	DS.L	6
MATRICE
	DS.L	9
ANGLE_ROTA
ALPHA
	DS.W	1
BETA
	DS.W	1
GAMMA
	DS.W	1
TAB_160
	DS.W	200
NBDOTS
	DS.W	1
BUF_ADR
	DS.L	4
OLD_PAL
	DS.W	16
COS_HOR
	INCBIN	'HORLOGE.DAT'
F_COS_HOR