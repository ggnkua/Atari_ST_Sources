**************************************************************************
**							 		**
**	NEW ORDER Menu version 5.04 Coded by J.I.M.M.Y          	**
**							 		**
**************************************************************************

	SECTION TEXT
	OPT	O-,D-,S-

num_fil	EQU	2				;number of files (max 9)

**************
*INTRO ON\OFF*
**************
intro01	EQU	1 				;intro (0=Yes / 1=no)

txt_col	EQU	$777				;scroller colour
bak_col	EQU	$000				;star background colour
vol1	EQU	$700				;volume bar 1
vol2	EQU	$070				;volume bar 2
vol3	EQU	$007				;volume bar 3

single	EQU	1				;single tune
double	EQU	0				;two tunes
treble	EQU	0				;three tunes
fourpl	EQU	0				;four or more tunes
MADMAX	EQU	0				;TUNE IN MADMAX FORMAT

debug	EQU	0				;debug (ESC  0=ON/1=OFF)

	BRA.S	start
	DC.B	"FUCK OFF YOU LAME TEXT EDITING BASTARD",0
	EVEN

start	MOVE.L	4(A7),A5
	LEA	stack,A7
	MOVE.L	$C(A5),D0
	ADDI.L	#$100,D0
	MOVE.L	D0,-(SP)
	MOVE.L	A5,-(SP)
	MOVE.L	#$4A0000,-(SP)
	TRAP	#1
	LEA	12(SP),SP

	MOVE.W	#4,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.W	D0,old_rez
	CMPI.W	#2,D0
	BEQ	quit_2

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,old_sp

	PEA	mse_off(PC)
	MOVE.L	#$190000,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP

	DC.W	$A00A

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,old_scr

	MOVE.L	#big_scr+256,D0
	ANDI.L	#-256,D0
	MOVE.L	D0,scr_adr

	MOVE.L	D0,A0
	MOVE.W	#280*40,D7
clr_scr	CLR.L	(A0)+
	DBF	D7,clr_scr

	MOVE.B	$FFFF820A.W,hz
	MOVE.B	#254,$FFFF820A.W

	CLR.W	-(SP)
	MOVE.L	scr_adr,-(SP)
	MOVE.L	(SP),-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

	MOVE.W	#1,$4EE.W

	LEA	old_mfp,A0
	MOVE.B	$FFFFFA07.W,(A0)+
	MOVE.B	$FFFFFA09.W,(A0)+
	MOVE.B	$FFFFFA13.W,(A0)+
	MOVE.B	$FFFFFA15.W,(A0)+
	MOVE.B	$FFFFFA1F.W,(A0)+
	MOVE.B	$FFFFFA19.W,(A0)+
	MOVE.B	$FFFFFA17.W,(A0)+

	CLR.B	$484.W

	IFEQ	intro01				;*INTRO START*
	BSR	imus_on
	BSR	stargen

	MOVE.L	#$0000111,$FFFF8240.W
	MOVE.L	#$2220333,$FFFF8244.W
	MOVE.L	#$4440555,$FFFF8248.W
	MOVE.L	#$6660777,$FFFF824C.W

	MOVE.W	#$333,$FF8250			; STARS COLOUR

	LEA	swing(PC),A6
iloop	MOVE.W	#-1,$468.W
.vbl	TST.W	$468.W
	BNE.S	.vbl
	MOVE.L	scr_adr,A1
	ADDA.W	(A6)+,A1
	BSR	logo
	BSR	int_str
	CMPI.W	#$FFFF,(A6)
	BNE.S	ikey
	LEA	swing(PC),A6
ikey	MOVE.L	#$600FF,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	CMP.B	#' ',D0
	BNE	iloop
iquit	BSR	mus_off

	MOVE.L	scr_adr,A0
	MOVE.W	#7999,D7
.clrscr	CLR.L	(A0)+
	DBF	D7,.clrscr
	ENDC					;*INTRO FINISH*

	MOVE.W	#$2700,SR
	MOVE.L	#hblank1,$120.W
	LEA	keyvec,A0
	MOVE.L	$118.W,6(A0)
	MOVE.L	$118.W,key_vec
	MOVE.L	A0,$118.W
	LEA	new_vbl(PC),A0
	MOVE.L	$70.W,2(A0)
	MOVE.L	$70.W,old_vbl
	MOVE.L	#vblank,$70.W
	MOVE.B	#%01000000,$FFFFFA15.W
	MOVE.B	#%00000001,$FFFFFA07.W
	BSET.B	#3,$FFFFFA17.W
	MOVE.W	#$2300,SR
	MOVEQ	#-1,D7
over	NOP
	DBF	D7,over	
	MOVE.L	#vol_bar,$4E2.W
	MOVE.L	#vbl_str,$4E6.W
	BSR	mus_on

	CMPI.B	#252,hz
	BNE	NEXT
	BSR	CHANGEC

NEXT	LEA	piccy(PC),A0
	ADDQ.L	#2,A0
	MOVE.L	(A0),COL0
	MOVE.L	4(A0),COL1
	MOVE.L	8(A0),COL2
	MOVE.L	$10(A0),COL3
	MOVE.L	$14(A0),COL4
	MOVE.L	$18(A0),COL5
	MOVE.L	A0,$45A.W
	LEA	32(A0),A0

	MOVE.W	speed,var

	MOVE.L	scr_adr,A1
	LEA	5*160(A1),A1
	LEA	32000(A0),A2
	LEA	32000(A1),A3
	MOVEQ	#49,D7
.pic1	MOVEQ	#39,D6
.pic2	MOVE.L	(A0)+,(A1)+
	MOVE.L	-(A2),-(A3)
	NOP
	DBF	D6,.pic2 

	ADDA.L	#160,A0
	ADDA.L	#160,A1
	SUBA.L	#160,A2
	SUBA.L	#160,A3

	MOVEQ	#39,D6
.pic22	MOVE.L	(A0)+,(A1)+
	MOVE.L	-(A2),-(A3)
	NOP
	DBF	D6,.pic22 

	MOVE.W	#-1,$468.W
.vsync	TST.W	$468.W
	BNE.S	.vsync

	ADDA.L	#160,A0
	ADDA.L	#160,A1
	SUBA.L	#160,A2
	SUBA.L	#160,A3

	DBF	D7,.pic1

scroll	LEA	text(PC),A6
chr_val	MOVEQ	#0,D0
	MOVE.B	(A6)+,D0
	BEQ.S	scroll
	SUBI.B	#32,D0
	MOVEQ	#16,D3
	MULU	#128,D0
	MOVE.L	D0,CHRADD
	LEA	font(PC),A1
	ADDA.L	D0,A1
	LEA	sct_pad,A0
	MOVEQ	#24,D0
s_pad	MOVE.W	(A1),(A0)+
	MOVE.W	4(A1),(A0)+
	ADDA.L	#8,A1
	DBF	D0,s_pad
waitvbl	SUBQ.W	#1,var
	BNE.S	intscr
	MOVE.B	$469.W,D0
vbl	CMP.B	$469.W,D0
	BEQ.S	vbl
	MOVE.W	speed,var
	MOVE.L	#$600FF,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	SWAP	D0
	TST.B	D0
	BEQ.S	intscr
	SWAP	D0
	IFEQ	debug
	CMPI.B	#27,D0
	BEQ	quit
	ENDC
	CMPI.B	#43,D0
	BEQ	plus
	CMPI.B	#45,D0
	BEQ	minus
	CMPI.B	#48,D0
	BEQ	hertz
	SUB.B	#48,D0
	CMPI.B	#1,D0
	BGE.S	.lmax
	BRA.S	intscr
.lmax	CMPI.B	#num_fil,D0
	BGT.S	intscr
	MOVE.B	D0,file+1
	BRA	quit
intscr	LEA	sct_pad,A1
	MOVE.L	#SCROLLSP,A0
*	ADDA.L	#207*160,A0
	MOVEQ	#24,D1
chrcpy	LSL	(A1)+
	ROXL	152(A0)
	ROXL	144(A0)
	ROXL	136(A0)
	ROXL	128(A0)
	ROXL	120(A0)
	ROXL	112(A0)
	ROXL	104(A0)
	ROXL	96(A0)
	ROXL	88(A0)
	ROXL	80(A0)
	ROXL	72(A0)
	ROXL	64(A0)
	ROXL	56(A0)
	ROXL	48(A0)
	ROXL	40(A0)
	ROXL	32(A0)
	ROXL	24(A0)
	ROXL	16(A0)
	ROXL	8(A0)
	ROXL	(A0)
	LEA	160(A0),A0
	DBF	D1,chrcpy
	SUBQ.W	#1,D3
	BNE	waitvbl

	MOVEQ	#16,D3
	LEA	font(PC),A1
	ADDA.L	CHRADD,A1
	ADDA.L	#2,A1
	LEA	sct_pad,A0
	MOVEQ	#15,D0
s_pad2	MOVE.W	(A1),(A0)+
	MOVE.W	4(A1),(A0)+
	ADDA.L	#8,A1
	DBF	D0,s_pad2

waitvbl2	SUBQ.W	#1,var
	BNE.S	intscr2
	MOVE.B	$469.W,D0
vbl2	CMP.B	$469.W,D0
	BEQ.S	vbl2
	MOVE.W	speed,var

intscr2	LEA	sct_pad,A1
	MOVE.L	#SCROLLSP,A0
*	ADDA.L	#207*160,A0
	MOVEQ	#24,D1
chrcpy2	LSL	(A1)+
	ROXL	152(A0)
	ROXL	144(A0)
	ROXL	136(A0)
	ROXL	128(A0)
	ROXL	120(A0)
	ROXL	112(A0)
	ROXL	104(A0)
	ROXL	96(A0)
	ROXL	88(A0)
	ROXL	80(A0)
	ROXL	72(A0)
	ROXL	64(A0)
	ROXL	56(A0)
	ROXL	48(A0)
	ROXL	40(A0)
	ROXL	32(A0)
	ROXL	24(A0)
	ROXL	16(A0)
	ROXL	8(A0)
	ROXL	(A0)
	LEA	160(A0),A0
	DBF	D1,chrcpy2
	SUBQ.W	#1,D3
	BNE	waitvbl2

	BRA	chr_val

quit	BSR	hbl_off

	PEA	mse_on(PC)
	MOVE.L	#$190000,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP

	DC.W	$A009

	MOVE.W	#-1,$4EE.W

	MOVE.W	#0,-(SP)
	MOVE.L	old_scr,-(SP)
	MOVE.L	(SP),-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

	MOVE.B	hz,$FFFF820A.W

	MOVE.L	#$00000777,$FF8240

	BSR	mus_off
	CLR.L	$4E2.W
	CLR.L	$4E6.W

	MOVE.L	$44E,A0
	MOVE.W	#2000-1,D7
CLP21	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBRA	D7,CLP21

	MOVE.L	old_sp,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	IFEQ	debug
	TST.W	file
	BEQ.S	quit_2
	ENDC	

	MOVE.W	file,D0
	MOVEQ	#0,D1
	MOVE.W	D0,D1
	SUBQ.W	#1,D1
	LSL	#2,D1
	LEA	fnames(PC),A0
	ADDA.L	D1,A0
	MOVE.L	(A0),A6
	PEA	env_com(PC)
	PEA	env_com(PC)
	MOVE.L	A6,-(SP)
	MOVE.L	#$4B0000,-(SP)
	TRAP	#1
	LEA	16(SP),SP

quit_2	CLR.W	-(SP)
	TRAP	#1

vbl_str	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	#SCROLLSP,A0
	MOVE.L	scr_adr,A1
	ADDA.L	#160*207,A1
	ADDA.L	#6,A1
	MOVE.W	#24,D1

VSLP	MOVE.W	(A0),160(A1)
	MOVE.W	8(A0),8+160(A1)
	MOVE.W	16(A0),16+160(A1)
	MOVE.W	24(A0),24+160(A1)
	MOVE.W	32(A0),32+160(A1)
	MOVE.W	40(A0),40+160(A1)
	MOVE.W	48(A0),48+160(A1)
	MOVE.W	56(A0),56+160(A1)
	MOVE.W	64(A0),64+160(A1)
	MOVE.W	72(A0),72+160(A1)
	MOVE.W	80(A0),80+160(A1)
	MOVE.W	88(A0),88+160(A1)
	MOVE.W	96(A0),96+160(A1)
	MOVE.W	104(A0),104+160(A1)
	MOVE.W	112(A0),112+160(A1)
	MOVE.W	120(A0),120+160(A1)
	MOVE.W	128(A0),128+160(A1)
	MOVE.W	136(A0),136+160(A1)
	MOVE.W	144(A0),144+160(A1)
	MOVE.W	152(A0),152+160(A1)

	MOVE.W	(A0),(A1)
	MOVE.W	8(A0),8(A1)
	MOVE.W	16(A0),16(A1)
	MOVE.W	24(A0),24(A1)
	MOVE.W	32(A0),32(A1)
	MOVE.W	40(A0),40(A1)
	MOVE.W	48(A0),48(A1)
	MOVE.W	56(A0),56(A1)
	MOVE.W	64(A0),64(A1)
	MOVE.W	72(A0),72(A1)
	MOVE.W	80(A0),80(A1)
	MOVE.W	88(A0),88(A1)
	MOVE.W	96(A0),96(A1)
	MOVE.W	104(A0),104(A1)
	MOVE.W	112(A0),112(A1)
	MOVE.W	120(A0),120(A1)
	MOVE.W	128(A0),128(A1)
	MOVE.W	136(A0),136(A1)
	MOVE.W	144(A0),144(A1)
	MOVE.W	152(A0),152(A1)

	ADDA.L	#320,A1
	ADDA.L	#160,A0
	DBRA	D1,VSLP
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

vol_bar	MOVEM.L	D4-D7/A0-A1,-(SP)
	LEA	$FFFF8800.W,A0
	MOVEQ	#2,D5
.chans	MOVEQ	#8,D4
	ADD.W	D5,D4
	MOVE.B	D4,(A0)
	MOVE.B	(A0),D4
	ANDI.B	#15,D4
	MOVEQ	#0,D7
	MOVE.L	scr_adr,A1
	ADDA.L	#160*209,A1
	MOVE.L	D5,D6
	MULU	#(15*160),D6
	ADD.W	D5,D6
	ADD.W	D5,D6
	ADDA.W	D6,A1
	MOVE.B	D4,D7
.plot	MOVE.W	#$FFFF,(0*160)(A1)
	MOVE.W	#$FFFF,(1*160)(A1)
	MOVE.W	#$FFFF,(2*160)(A1)
	MOVE.W	#$FFFF,(3*160)(A1)
	MOVE.W	#$FFFF,(4*160)(A1)
	MOVE.W	#$FFFF,(5*160)(A1)
	MOVE.W	#$FFFF,(6*160)(A1)
	MOVE.W	#$FFFF,(7*160)(A1)
	MOVE.W	#$FFFF,(8*160)(A1)
	MOVE.W	#$FFFF,(9*160)(A1)
	MOVE.W	#$FFFF,(10*160)(A1)
	MOVE.W	#$FFFF,(11*160)(A1)
	MOVE.W	#$FFFF,(12*160)(A1)
	MOVE.W	#$FFFF,(13*160)(A1)
	ADDQ.L	#8,A1
	DBF	D7,.plot
	MOVEQ	#15,D7
	SUB.B	D4,D7
.unplot	CLR.W	(0*160)(A1)
	CLR.W	(1*160)(A1)
	CLR.W	(2*160)(A1)
	CLR.W	(3*160)(A1)
	CLR.W	(4*160)(A1)
	CLR.W	(5*160)(A1)
	CLR.W	(6*160)(A1)
	CLR.W	(7*160)(A1)
	CLR.W	(8*160)(A1)
	CLR.W	(9*160)(A1)
	CLR.W	(10*160)(A1)
	CLR.W	(11*160)(A1)
	CLR.W	(12*160)(A1)
	CLR.W	(13*160)(A1)
	ADDQ.L	#8,A1
	DBF	D7,.unplot
	DBF	D5,.chans
	MOVEM.L	(SP)+,D4-D7/A0-A1
	RTS

hblank1	MOVE.W	#0,$FF8240
	CLR.B	$FFFFFA1B.W
	MOVE.L	#HBLANK2,$120.W
	MOVE.B	#181,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR.B	#0,$FFFFFA0F.W
	RTE

HBLANK2	CLR.B	$FFFFFA1B.W
	MOVE.L	#hblank3,$120.W
	MOVE.B	#23,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR.B	#0,$FFFFFA0F.W

	MOVE.W	HZCOL,$FF8240
	MOVE.W	#vol1,$FF8242
	MOVE.W	#vol2,$FF8244
	MOVE.W	#vol3,$FF8248

	MOVE.W	#txt_col,$FF8250
	MOVE.W	#txt_col,$FF8252
	MOVE.W	#txt_col,$FF8254
	MOVE.W	#txt_col,$FF8258

	RTE

hblank3	MOVE.L	D0,-(SP)
	MOVE.W	SR,-(SP)
	MOVE.W	#$2700,SR
	MOVEQ	#24,D0
.hbl1	NOP
	DBF	D0,.hbl1
	CLR.B	$FFFF820A.W
	MOVEQ	#4,D0
.hbl2	NOP
	DBF	D0,.hbl2
	MOVE.B	#2,$FFFF820A.W
	MOVE.W	(SP)+,SR

	MOVE.L	(SP)+,D0

	BCLR.B	#0,$FFFFFA0F.W
	RTE

vblank	MOVE.L	COL0,$FFFF8240.W
	MOVE.L	COL1,$FFFF8244.W
	MOVE.L	COL2,$FFFF8248.W
	MOVE.L	COL3,$FFFF8250.W
	MOVE.L	COL4,$FFFF8254.W
	MOVE.L	COL5,$FFFF8258.W
	MOVE.B	#1,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	ORI.B	#1,$FFFFFA07.W
	ORI.B	#1,$FFFFFA13.W
	MOVE.L	D0,-(SP)
	MOVE	SR,-(SP)
	MOVE.W	#$2700,SR
	MOVE.L	#1403,D0
.wait	DBRA	D0,.wait
	MOVE.B	#0,$FFFF820A.W
	MOVE.W	#3,D0
.wait2	DBF	D0,.wait2
	MOVE.B	#2,$FFFF820A.W
	MOVE.W	(SP)+,SR
	MOVE.L	#hblank1,$120.W
.wait3	MOVE.L	(SP)+,D0
	CLR.B	$FFFFFA1B.W
	MOVE.B	#24,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
new_vbl	JMP	$0.L

keyvec	MOVE.W	#$2500,SR
	JMP	$0.L

ipl_nul	BCLR.B	#5,$FFFFFA0F.W
	RTE

	IFEQ	intro01
imus_on	moveq #1,d0				music #1
	Jsr int_mus				call init
	LEA	$456.W,A0
	MOVE.L	(A0),A0
.islot	TST.L	(A0)+
	BNE.S	.islot
	MOVE.L	#int_mus+8,-(A0)
	RTS

stargen	LEA	starbuf,A4
	MOVE.W	#198,D7
.gen	MOVE.W	#319,D3
	MOVE.W	#511,D4
	BSR.S	rand
	MOVEQ	#10,D3
	MOVEQ	#15,D4
	BSR.S	rand
	DBF	D7,.gen
	CLR.L	(A4)
	RTS
rand	MOVE.W	#$11,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	AND.W	D4,D0
	CMP.W	D3,D0
	BLE.S	.ok
	SUB.W	D3,D0
.ok	ADDQ.W	#1,D0
	MOVE.W	D0,(A4)+
	RTS

int_str	MOVE.L	$44E.W,A1
	ADDA.L	#6,A1
	LEA	starbuf,A0
.stars	LEA	160(A1),A1
 	MOVE.W	2(A0),D0
	SUB.W	D0,(A0)
	BGE.S	.ok
	ADDI.W	#320,(A0)
	CLR.W	(A1)
.ok	MOVE.W	(A0),D0
	MOVE.W	D0,D1
	ANDI.W	#$F,D0
	SUB.W	D0,D1
	LSR	D1
	MOVE.W	#$8000,D2
	LSR	D0,D2
	MOVE.W	D2,(A1,D1.W)
	CLR.W	8(A1,D1.W)
	ADDQ.L	#4,A0
	TST.L	(A0)
	BNE.S	.stars
	RTS

logo	MOVEQ	#3,D7
.clr_t	CLR.L	(A1)
	CLR.L	8(A1)
	CLR.L	16(A1)
	CLR.L	24(A1)
	CLR.L	32(A1)
	CLR.L	40(A1)
	CLR.L	48(A1)
	CLR.L	56(A1)
	CLR.L	64(A1)
	CLR.L	72(A1)
	CLR.L	80(A1)
	CLR.L	88(A1)
	LEA	160(A1),A1
	DBF	D7,.clr_t
	LEA	int_pic,A0
	MOVEQ	#49,D7
.copy	MOVE.L	(A0)+,(A1)
	MOVE.W	(A0)+,4(A1)
	MOVE.L	(A0)+,8(A1)
	MOVE.W	(A0)+,12(A1)
	MOVE.L	(A0)+,16(A1)
	MOVE.W	(A0)+,20(A1)
	MOVE.L	(A0)+,24(A1)
	MOVE.W	(A0)+,28(A1)
	MOVE.L	(A0)+,32(A1)
	MOVE.W	(A0)+,36(A1)
	MOVE.L	(A0)+,40(A1)
	MOVE.W	(A0)+,44(A1)
	MOVE.L	(A0)+,48(A1)
	MOVE.W	(A0)+,52(A1)
	MOVE.L	(A0)+,56(A1)
	MOVE.W	(A0)+,60(A1)
	MOVE.L	(A0)+,64(A1)
	MOVE.W	(A0)+,68(A1)
	MOVE.L	(A0)+,72(A1)
	MOVE.W	(A0)+,76(A1)
	MOVE.L	(A0)+,80(A1)
	MOVE.W	(A0)+,84(A1)
	MOVE.L	(A0)+,88(A1)
	MOVE.W	(A0)+,92(A1)
	MOVE.L	(A0)+,96(A1)
	MOVE.W	(A0)+,100(A1)
	MOVE.L	(A0)+,104(A1)
	MOVE.W	(A0)+,108(A1)
	MOVE.L	(A0)+,112(A1)
	MOVE.W	(A0)+,116(A1)
	MOVE.L	(A0)+,120(A1)
	MOVE.W	(A0)+,124(A1)
	MOVE.L	(A0)+,128(A1)
	MOVE.W	(A0)+,132(A1)
	MOVE.L	(A0)+,136(A1)
	MOVE.W	(A0)+,140(A1)
	MOVE.L	(A0)+,144(A1)
	MOVE.W	(A0)+,148(A1)
	MOVE.L	(A0)+,152(A1)
	MOVE.W	(A0)+,156(A1)
*	LEA	48(A0),A0
	LEA	160(A1),A1
	DBF	D7,.copy
	MOVEQ	#3,D7
.clr_b	CLR.L	(A1)
	CLR.L	8(A1)
	CLR.L	16(A1)
	CLR.L	24(A1)
	CLR.L	32(A1)
	CLR.L	40(A1)
	CLR.L	48(A1)
	CLR.L	56(A1)
	CLR.L	64(A1)
	CLR.L	72(A1)
	CLR.L	80(A1)
	CLR.L	88(A1)
	LEA	160(A1),A1
	DBF	D7,.clr_b
	RTS
	ENDC

hbl_off	MOVE.W	#$2700,SR
	MOVE.L	key_vec,$118.W
	MOVE.L	old_vbl,$70.W
	MOVE.L	#ipl_nul,$120.W
	LEA	old_mfp,A0
	MOVE.B	(A0)+,$FFFFFA07.W
	MOVE.B	(A0)+,$FFFFFA09.W
	MOVE.B	(A0)+,$FFFFFA13.W
	MOVE.B	(A0)+,$FFFFFA15.W
	MOVE.B	(A0)+,$FFFFFA1F.W
	MOVE.B	(A0)+,$FFFFFA19.W
	MOVE.B	(A0)+,$FFFFFA17.W
	MOVE.W	#$2300,SR
	RTS

plus	CMPI.W	#10,speed
	BEQ	intscr 
	ADDQ.W	#1,speed
	BRA	intscr

minus	CMPI.W	#3,speed
	BEQ	intscr
	SUBQ.W	#1,speed
	BRA	intscr

hertz	EORI.B	#2,hz
	JSR	CHANGEC
.end	BRA	intscr

CHANGEC	EORI.W	#2,HZCOL
	RTS


mus_off	LEA	$456.W,A0
	MOVE.L	(A0),A0
.slot	TST.L	(A0)+
	BNE.S	.slot
	CLR.L	-8(A0) 
	LEA	$FFFF8800.W,A0
	MOVE.L 	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	MOVE.B	#$7,$484.W
	RTS

	IFEQ	MADMAX
mus_on	moveq #1,d0				music #1
	Jsr music				call init
	LEA	$456.W,A0
	MOVE.L	(A0),A0
.slot	TST.L	(A0)+
	BNE.S	.slot
	MOVE.L	#music+4,-(A0)
	RTS
	ENDC

	IFEQ	single
mus_on	CLR.B	$484.W
	MOVE.W	music,D0
	JSR	music+2
	LEA	$456.W,A0
	MOVE.L	(A0),A0
.slot	TST.L	(A0)+
	BNE.S	.slot
	MOVE.L	#music+4,-(A0)
	RTS
	ENDC

	SECTION DATA

text	DC.B	"       YO TERMINATOR     THIS IS          MANIX          PRESENTING NEW ORDER MENU CODE VERSION 5.04 WRITTEN BY THE ALMIGHTY J.I.M.M.Y. (WHICH MEANS IT WAS WRITTEN BY THE MONSTER)       THIS IS NOT ALL "
	DC.B    "THAT THIS CODE CAN DO (WELL HURAHH - I HEAR YOU SHOUT) IT ALSO HAS AN INTRO WHICH IS TURNED OFF IN THIS SOURCE (IVE LEFT THE CODE IN THOUGH) BECAUSE I DONT HAVE THE CONVERTER THAT CONVERTS PICCYS INTO"
	DC.B	" BOBS.     YOU CAN SEE WHAT THE INTRO LOOKS LIKE BY HITTING 1     OR YOU CAN HIT 2 TO GO TO DESKTOP.           10          9          8          7          6          5          4          3          2"     
	DC.B	"          1                0                LETS WRAP IT D.J.                          ...............................................................................                          ",0
	DC.B	"FRONT OF YOU SOON AS ITS ONLY THE BORDER ROUTINES THAT NEED CHANGING.       MESSAGE TO ALL NEW CONTACTS.....     I DO NOT COLLECT GAMES  -  JUST MENUS SO PLEASE DONT SEND ME LISTS WITH 200 ODD GAMES ON COS ILL "
        DC.B    "JUST RIP THEM UP.      I WONT BORE YOU ANY LONGER... HERES THE GREETZ.....      PERSONAL GREETZ GO TO...     DEABY     INVERSE LOJIK     DANNY     THE MONSTER BEETLE     CHRIS OF WEST LONDON     BRATTY     KY     "
        DC.B    "SIMON IN PENDEFORD     PAUL RIED     THE TERMINATOR     THE DREAM MASTER     MANI OF NORTHSIDE (GOOD MENU 01)     JOE OF THE STD CREW     AND MOB OF AUTOMATION          GROUP GREETZ GO TO.....     THE POMPEY "
        DC.B    "PIRATES     AUTOMATION     THE B.B.C.     F.O.F     AWESOME     THUNDERFORCE     WYRD MAJIK     THE DREAM WEAVERS     THE ST CONNECTION     THE ELITE (FRENCH)     THE REPLICANTS     PERSISTANCE OF VISION     T.C.B "
        DC.B    "    T.L.B     THE INNER CIRCLE     THE STD CREW     PHALANX     THE OVERLANDERS     AND     SEWER SOFTWARE.          IF YOU ARE TOTALLY PISS BORED THEN HIT 1 TO SEE THE LIST IF NOT THEN KEEP READING                             "
        DC.B    "              IM STILL HERE.    I LEFT THE SPACE SO THAT YOU COULD GET A GLIMPSE OF THOSE CRAPPY V.U METERS!     FOR THOSE OF YOU THAT ARE WONDERING WHAT HAS HAPPENED TO DEADLY FX I WILL NOW EXPLAIN.....        WE DECIDED "
        DC.B    "TO STOP DOING MENUS ALTOGETHER AROUND A MONTH AGO BECAUSE PEOPLE THAT WE RELIED ON KEPT LETTING US DOWN.     A COUPLE OF WEEKS AGO BOTH ME AND T.M.B WERE DISCUSSING HOW MUCH WE MISSED OUR NAMES FLASHING UP ON MONITORS ALL "
        DC.B    "AROUND THE GLOBE AND SO WE HAVE DECIDED TO START UP AGAIN AROUND OCTOBER TIME.     UNTIL THEN WE WILL BE WORKING ON SOME GREAT NEW CODE TO GIVE D.FX A COMPLETE FACELIFT.     MEMBERS LIST AS FOLLOWS.....     MANIX     T.M.B"
        DC.B    "     DEABY     CAPTAIN HOODED   AND   SIGON.     LOOK OUT FOR US.     WE WILL BE ON A TV SCREEN NEAR YOU SOON!!!!          WELL I THINK THAT WILL HAVE TO DO FOR NOW AS I HAVE AROUND 60 DISKS TO COPY.     5     4     3     2     1"
        DC.B    "     0          WRAP             PS- YES YOU ARE LISTENING TO COUNT ZERO MUSIC          PPS- POMPEY PIRATES ARE GETTING LAZIER BY THE DAY.               ...........................................                                 "
	IFEQ	intro01

swing	DC.W	0*160,0*160,0*160,1*160,2*160,3*160,4*160,5*160,7*160,9*160,11*160,13*160,15*160,18*160,21*160
	DC.W	24*160,27*160,30*160,33*160,36*160,39*160,42*160,45*160,48*160,51*160,54*160
	DC.W	57*160,60*160,63*160,66*160,69*160,72*160,75*160,78*160
	DC.W	81*160,84*160,87*160,90*160,93*160,96*160,99*160,102*160,104*160
	DC.W	106*160,108*160,110*160,112*160,114*160,116*160,117*160,118*160,119*160,120*160,121*160,121*160

	DC.W	120*160,120*160,119*160,118*160,117*160,116*160,114*160,112*160,110*160,108*160,106*160,104*160,102*160,99*160
	DC.W	96*160,93*160,90*160,87*160,84*160,81*160,78*160,75*160,72*160,69*160,66*160,63*160,60*160,57*160
	DC.W	54*160,51*160,48*160,45*160,42*160,39*160,36*160,33*160,30*160,27*160,24*160,21*160,18*160,15*160
	DC.W	13*160,11*160,9*160,7*160,5*160,4*160,3*160,2*160,1*160,0*160,0*160
	DC.W	$FFFF
	ENDC

COLS	DC.W	$000,$777,$333,$001,$FFFF

env_com	DC.L	0
mse_off	DC.B	$12,$00
mse_on	DC.B	$08,$00
file	DC.W	0
speed	DC.W	6
hz	DC.B	252
	EVEN
file1	DC.B	'intro.prg',0		;Slot file names of programs
file2   dc.b    'desktop.inf',0
        EVEN
fnames	DC.L	file1
        dc.l    file2
font	INCBIN	pompey.fnt    ;VERTICAL SINGLE BIT-PLANE
	EVEN
piccy	INCBIN	logopic2.PI1		;LOW RES DEGAS UN-COMPRESSED
	EVEN
music	INCBIN	countz_3.DAT		;MAIN MENU MUSIC (IN MADMAX FOLDER)
	EVEN
	IFEQ	intro01
int_mus	INCBIN	a:.dat	;INTRO MUSIC (SINGLE TUNE)
	EVEN
int_pic	INCBIN	NEWORDER.PC1
	EVEN
	ENDC

	SECTION BSS

IMGSPCE	DS.B	160*10

SCROLLSP	DS.B	6000

HZCOL	DS.W	1
CHRADD	DS.L	1
old_mfp	DS.B	8
icol1	DS.W	1
COL0	DS.L	1
COL1	DS.L	1
COL2	DS.L	1
COL3	DS.L	1
COL4	DS.L	1
COL5	DS.L	1
old_rez	DS.W	1
tune_no	DS.W	1
var	DS.W	1
key_vec	DS.L	1
old_sp	DS.L	1
old_vbl	DS.L	1
old_scr	DS.L	1
scr_adr	DS.L	1
wve_pos	DS.L	1
sct_pad	DS.L	11
	DS.L	100
stack	DS.L	1
oldint	dS.l	0
	IFEQ	intro01
starbuf	DS.L	200
	ENDC
big_scr	DS.L	1
